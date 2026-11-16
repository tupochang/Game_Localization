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
source = File.join(root, 'extracted', 'Data', 'System.rxdata')
target = File.join(root, 'overlay', 'Data', 'System.rxdata')
translations = JSON.parse(File.read(File.join(root, 'system_translation.json'), encoding: 'UTF-8'))
bytes = File.binread(source)
bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
  parent = RPG
  name.split('::').drop(1).each do |part|
    parent.const_set(part, Class.new) unless parent.const_defined?(part, false)
    parent = parent.const_get(part, false)
  end
end
system = Marshal.load(bytes)
words = system.instance_variable_get(:@words)
found = []
words.instance_variables.each do |field|
  old = words.instance_variable_get(field)
  next unless old.is_a?(String)
  english = old.b.force_encoding('Windows-31J').encode('UTF-8')
  chinese = translations[english]
  next unless chinese
  words.instance_variable_set(field, chinese.encode('UTF-8').b)
  found << english
end
missing = translations.keys - found
abort "Unmatched entries: #{missing.inspect}" unless missing.empty?
FileUtils.mkdir_p(File.dirname(target))
File.binwrite(target, Marshal.dump(system))
Marshal.load(File.binread(target))
puts "Replaced #{found.length} system terms; round-trip OK: #{target}"
