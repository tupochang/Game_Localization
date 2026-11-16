require 'zlib'
require 'fileutils'
root=File.dirname(__FILE__)
scripts=Marshal.load(File.binread(File.join(root,'extracted','Data','Scripts.rxdata')))
out=File.join(root,'scripts_unpacked')
FileUtils.mkdir_p(out)
scripts.each_with_index do |entry,i|
  next if entry.nil? || entry[2].nil?
  File.binwrite(File.join(out,format('%03d.rb',i)),Zlib::Inflate.inflate(entry[2]))
end
