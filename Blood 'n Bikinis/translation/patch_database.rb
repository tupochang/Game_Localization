require 'json'
require 'fileutils'

module RPG; end
class Table
  def self._load(raw); o=allocate; o.instance_variable_set(:@raw,raw); o; end
  def _dump(_limit); @raw; end
end
class Color < Table; end
class Tone < Table; end

root=File.dirname(__FILE__)
source=File.join(root,'extracted','Data')
target=File.join(root,'overlay','Data')
data=JSON.parse(File.read(File.join(root,'database_translations.json'),encoding:'UTF-8'))
def prepare_classes(bytes)
  bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
    parent=RPG
    name.split('::').drop(1).each do |part|
      parent.const_set(part,Class.new) unless parent.const_defined?(part,false)
      parent=parent.const_get(part,false)
    end
  end
end
data.each do |name,rows|
  bytes=File.binread(File.join(source,"#{name}.rxdata"))
  prepare_classes(bytes)
  object=Marshal.load(bytes)
  count=0
  rows.each do |id,values|
    row=name=='MapInfos' ? object[id.to_i] : object[id.to_i]
    abort "Missing #{name} row #{id}" if row.nil?
    ['@name','@description'].each_with_index do |field,index|
      next if values[index].nil?
      old=row.instance_variable_get(field)
      abort "Missing #{name} #{id} #{field}" unless old.is_a?(String)
      old_text=old.b.force_encoding('Windows-31J').encode('UTF-8')
      new_text=values[index]
      abort "Empty #{name} #{id} #{field}" if new_text.empty?
      row.instance_variable_set(field,new_text.encode('UTF-8').b)
      count+=1 if old_text!=new_text
    end
  end
  FileUtils.mkdir_p(target)
  out=File.join(target,"#{name}.rxdata")
  File.binwrite(out,Marshal.dump(object))
  Marshal.load(File.binread(out))
  puts "#{name}: #{count} fields in #{rows.length} rows"
end
