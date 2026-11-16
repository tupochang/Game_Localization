require 'json'
require 'fileutils'

class Dynamic; end
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
source = File.join(root, 'extracted', 'Data', 'Map001.rxdata')
target = File.join(root, 'overlay', 'Data', 'Map001.rxdata')
translations = JSON.parse(File.read(File.join(root, 'map001_translation.json'), encoding: 'UTF-8'))
bytes = File.binread(source)
bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
  parent = RPG
  name.split('::').drop(1).each do |part|
    parent.const_set(part, Class.new) unless parent.const_defined?(part, false)
    parent = parent.const_get(part, false)
  end
end
map = Marshal.load(bytes)
replaced = 0
found = []
map.instance_variable_get(:@events).each_value do |event|
  event.instance_variable_get(:@pages).each do |page|
    page.instance_variable_get(:@list).each do |command|
      code = command.instance_variable_get(:@code)
      next unless [101, 401, 102].include?(code)
      params = command.instance_variable_get(:@parameters)
      strings = code == 102 ? params[0] : params
      strings.each_with_index do |original, i|
        next unless original.is_a?(String)
        english = original.b.force_encoding('Windows-31J').encode('UTF-8')
        chinese = translations[english]
        next unless chinese
        strings[i] = chinese.encode('UTF-8').b
        found << english
        replaced += 1
      end
    end
  end
end
missing = translations.keys - found
abort "Unmatched entries: #{missing.inspect}" unless missing.empty?
FileUtils.mkdir_p(File.dirname(target))
File.binwrite(target, Marshal.dump(map))
Marshal.load(File.binread(target))
puts "Replaced #{replaced} visible strings; round-trip OK: #{target}"
