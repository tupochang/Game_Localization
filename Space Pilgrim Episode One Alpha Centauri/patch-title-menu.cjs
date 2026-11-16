const fs = require('node:fs');
const zlib = require('node:zlib');
const path = require('node:path');
const game = process.argv[2];
const archivePath = path.join(game, 'Game.rgss3a');
const backupPath = archivePath + '.title-menu-test.bak';
const archive = fs.readFileSync(archivePath);
if (archive.subarray(0, 8).toString('hex') !== '5247535341440003') throw Error('Unexpected archive signature');
const indexKey = (Math.imul(archive.readUInt32LE(8), 9) + 3) >>> 0;
function xor(data, key) {
  return data.map((byte, i) => byte ^ ((key >>> ((i % 4) * 8)) & 255));
}
function cryptFile(data, key) {
  return data.map((byte, i) => {
    if (i > 0 && i % 4 === 0) key = (Math.imul(key, 7) + 3) >>> 0;
    return byte ^ ((key >>> ((i % 4) * 8)) & 255);
  });
}
let cursor = 12;
const entries = [];
while (true) {
  const offset = (archive.readUInt32LE(cursor) ^ indexKey) >>> 0;
  if (!offset) break;
  const size = (archive.readUInt32LE(cursor + 4) ^ indexKey) >>> 0;
  const key = (archive.readUInt32LE(cursor + 8) ^ indexKey) >>> 0;
  const length = (archive.readUInt32LE(cursor + 12) ^ indexKey) >>> 0;
  const name = xor(archive.subarray(cursor + 16, cursor + 16 + length), indexKey).toString();
  if (offset + size > archive.length || length > 1024) throw Error('Invalid archive index');
  entries.push({ cursor, offset, key, size, name });
  cursor += 16 + length;
}
const entry = entries.find(entry => entry.name === 'Data\\Scripts.rvdata2');
const scripts = cryptFile(archive.subarray(entry.offset, entry.offset + entry.size), entry.key);
let pos = 0;
function expect(byte) {
  if (scripts[pos++] !== byte) throw Error('Unexpected Marshal tag at ' + (pos - 1));
}
function number() {
  const size = scripts.readInt8(pos++);
  if (size === 0) return 0;
  if (size > 4) return size - 5;
  if (size < -4) return size + 5;
  let value = size < 0 ? -1 : 0;
  for (let i = 0; i < Math.abs(size); i++) {
    value = (value & ~(255 << (i * 8))) | scripts[pos++] << (i * 8);
  }
  return value;
}
function rawString() {
  const size = number();
  const start = pos;
  pos += size;
  return scripts.subarray(start, pos);
}
function string() {
  const encoded = scripts[pos] === 73;
  if (encoded) pos++;
  expect(34);
  const bytes = rawString();
  if (encoded) {
    const count = number();
    for (let i = 0; i < count; i++) {
      const tag = scripts[pos++];
      if (tag === 58) rawString();
      else if (tag === 59) number();
      else throw Error('Unexpected encoding key');
      const value = scripts[pos++];
      if (value !== 84 && value !== 70) throw Error('Unexpected encoding value');
    }
  }
  return bytes;
}
expect(4); expect(8); expect(91);
const count = number();
const sections = [];
for (let i = 0; i < count; i++) {
  expect(91);
  if (number() !== 3) throw Error('Expected three fields');
  expect(105); number();
  const name = string().toString();
  const start = pos;
  const compressed = string();
  const code = zlib.inflateSync(compressed).toString();
  sections.push({name, code, start, end: pos, compressed});
}
if (pos !== scripts.length) throw Error('Unparsed script data');
if (!process.argv.includes('--apply')) {
  for (const {name, code} of sections) {
    if (/title|main|vocab/i.test(name) || /def (?:make_command_list|command_new_game)|class (?:Scene_Title|Window_TitleCommand)/.test(code)) {
      console.log(name);
      if (/^(Scene_Title|Window_TitleCommand|Title Screen|Main)$/.test(name)) console.log(code);
      else console.log(code.split(/\r?\n/).filter(line => /Scene_Title|Window_TitleCommand|Vocab::(new_game|continue|shutdown)|add_command.*:(new_game|continue|shutdown)/.test(line)).join('\n'));
    }
  }
}




else {
  function replaceOnce(code, before, after) {
    const first = code.indexOf(before);
    if (first < 0 || first !== code.lastIndexOf(before)) {
      throw Error('Expected one occurrence of ' + before);
    }
    return code.replace(before, after);
  }

  function marshalLength(length) {
    if (length < 123) return Buffer.from([length + 5]);
    const bytes = [];
    for (let value = length; value > 0; value >>>= 8) bytes.push(value & 255);
    return Buffer.from([bytes.length, ...bytes]);
  }

  const commands = sections.find(section => section.name === 'Window_TitleCommand');
  const style = sections.find(section => section.name === 'Title Screen');
  let commandCode = commands.code;
  for (const [term, label] of [
    ['new_game', '開始新遊戲'],
    ['continue', '繼續遊戲'],
    ['shutdown', '離開遊戲'],
  ]) {
    commandCode = replaceOnce(commandCode, 'Vocab::' + term, '"' + label + '"');
  }
  commandCode = '# encoding: UTF-8\n' + commandCode;
  const styleCode = replaceOnce(style.code, 'font.name = "Constantia"', 'font.name = "Microsoft JhengHei"');

  const pieces = [];
  let previous = 0;
  for (const [section, code] of [[commands, commandCode], [style, styleCode]]) {
    const compressed = zlib.deflateSync(Buffer.from(code));
    const payload = section.compressed.byteOffset - scripts.byteOffset;
    const lengthTag = section.start + (scripts[section.start] === 73 ? 2 : 1);
    pieces.push(scripts.subarray(previous, lengthTag), marshalLength(compressed.length),
      compressed, scripts.subarray(payload + section.compressed.length, section.end));
    previous = section.end;
  }
  pieces.push(scripts.subarray(previous));
  const replacement = Buffer.concat(pieces);
  const delta = replacement.length - entry.size;
  const patched = Buffer.concat([
    archive.subarray(0, entry.offset),
    cryptFile(replacement, entry.key),
    archive.subarray(entry.offset + entry.size),
  ]);
  for (const file of entries) {
    if (file.offset > entry.offset) {
      patched.writeUInt32LE(((file.offset + delta) ^ indexKey) >>> 0, file.cursor);
    }
  }
  patched.writeUInt32LE((replacement.length ^ indexKey) >>> 0, entry.cursor + 4);

  fs.copyFileSync(archivePath, backupPath, fs.constants.COPYFILE_EXCL);
  const temporary = archivePath + '.title-menu-test.tmp';
  fs.writeFileSync(temporary, patched, {flag: 'wx'});
  fs.renameSync(temporary, archivePath);
  console.log('Title menu patched. Original saved at ' + backupPath);
}
