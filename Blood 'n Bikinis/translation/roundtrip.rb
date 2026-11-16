class Dynamic
  def self.const_missing(name)
    const_set(name, Class.new(Dynamic))
  end
end
module RPG
  def self.const_missing(name)
    const_set(name, Class.new(Dynamic))
  end
end
class Table < Dynamic
  def self._load(raw)
    o = allocate
    o.instance_variable_set(:@raw, raw)
    o
  end
  def _dump(_limit)
    @raw
  end
end
class Color < Table; end
class Tone < Table; end
source, target = ARGV
bytes = File.binread(source)
bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
  parts = name.split('::').drop(1)
  parent = RPG
  parts.each do |part|
    parent.const_set(part, Class.new(Dynamic)) unless parent.const_defined?(part, false)
    parent = parent.const_get(part, false)
  end
end
object = Marshal.load(bytes)
File.binwrite(target, Marshal.dump(object))
Marshal.load(File.binread(target))
puts "Round-trip OK: #{source}"
