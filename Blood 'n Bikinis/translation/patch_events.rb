require 'json'
require 'fileutils'

module RPG; end
class Table
  def self._load(raw)
    o = allocate
    o.instance_variable_set(:@raw, raw)
    o
  end
  def _dump(_limit); @raw; end
end
class Color < Table; end
class Tone < Table; end

root = File.dirname(__FILE__)
data = File.join(root, 'extracted', 'Data')
overlay = File.join(root, 'overlay', 'Data')
translations = {}
['map001_translation.json', 'translation_master.json'].each do |filename|
  JSON.parse(File.read(File.join(root, filename), encoding: 'UTF-8')).each do |english, chinese|
    if translations.key?(english) && translations[english] != chinese
      abort "Conflicting translation: #{english}"
    end
    translations[english] = chinese
  end
end

def prepare_classes(bytes)
  bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
    parent = RPG
    name.split('::').drop(1).each do |part|
      parent.const_set(part, Class.new) unless parent.const_defined?(part, false)
      parent = parent.const_get(part, false)
    end
  end
end

def lists_for(object, filename)
  if filename.start_with?('Map')
    object.instance_variable_get(:@events).values.flat_map do |event|
      event.instance_variable_get(:@pages).map { |page| page.instance_variable_get(:@list) }
    end
  elsif filename == 'CommonEvents.rxdata'
    object.compact.map { |event| event.instance_variable_get(:@list) }
  else
    object.compact.flat_map do |troop|
      troop.instance_variable_get(:@pages).map { |page| page.instance_variable_get(:@list) }
    end
  end
end

counts = {}
found = []
files = Dir.glob(File.join(data, 'Map[0-9][0-9][0-9].rxdata')) +
  ['CommonEvents.rxdata', 'Troops.rxdata'].map { |name| File.join(data, name) }
files.each do |source|
  filename = File.basename(source)
  bytes = File.binread(source)
  prepare_classes(bytes)
  object = Marshal.load(bytes)
  count = 0
  lists_for(object, filename).each do |commands|
    commands.each do |command|
      code = command.instance_variable_get(:@code)
      next unless [101, 401, 102].include?(code)
      params = command.instance_variable_get(:@parameters)
      strings = code == 102 ? params[0] : params
      strings.each_with_index do |old, index|
        next unless old.is_a?(String)
        english = old.b.force_encoding('Windows-31J').encode('UTF-8')
        chinese = translations[english]
        next unless chinese
        controls = /\\[A-Za-z]\[\d+\]/
        if english.scan(controls) != chinese.scan(controls)
          abort "Control code mismatch: #{filename}: #{english} => #{chinese}"
        end
        strings[index] = chinese.encode('UTF-8').b
        count += 1
        found << english
      end
    end
  end
  next if count == 0
  FileUtils.mkdir_p(overlay)
  target = File.join(overlay, filename)
  File.binwrite(target, Marshal.dump(object))
  Marshal.load(File.binread(target))
  counts[filename] = count
end

missing = translations.keys - found
abort "Unmatched translations: #{missing.inspect}" unless missing.empty?
puts "Translated #{counts.values.sum} event strings across #{counts.length} files"
puts counts.sort_by(&:first).map { |file, count| "#{file}: #{count}" }
