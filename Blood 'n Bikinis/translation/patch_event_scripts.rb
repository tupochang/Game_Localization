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
translations=JSON.parse(File.read(File.join(root,'extra_info_translations.json'),encoding:'UTF-8'))
skill_names={'Isabelle'=>'伊莎貝兒','Karine'=>'卡琳','Orange'=>'奧蘭潔','Alison'=>'艾莉森','Nancy'=>'南希'}
def prepare_classes(bytes)
  bytes.scan(/RPG::[A-Za-z:]+/).uniq.sort_by(&:length).each do |name|
    parent=RPG
    name.split('::').drop(1).each do |part|
      parent.const_set(part,Class.new) unless parent.const_defined?(part,false)
      parent=parent.const_get(part,false)
    end
  end
end
count=0
name_count=0
actor_name_count=0
files=Dir.glob(File.join(source,'Map[0-9][0-9][0-9].rxdata'))+
  ['CommonEvents.rxdata','Troops.rxdata'].map{|name|File.join(source,name)}
files.each do |path|
  name=File.basename(path)
  over=File.join(target,name)
  bytes=File.binread(File.exist?(over) ? over : path)
  prepare_classes(bytes)
  object=Marshal.load(bytes)
  events=name.start_with?('Map') ? object.instance_variable_get(:@events).values : object.compact
  lists=events.flat_map do |event|
    if name=='CommonEvents.rxdata'
      [event.instance_variable_get(:@list)]
    else
      event.instance_variable_get(:@pages).map{|page|page.instance_variable_get(:@list)}
    end
  end
  changed=false
  lists.each do |list|
    list.each do |command|
      if command.instance_variable_get(:@code)==320
        params=command.instance_variable_get(:@parameters)
        raw=params[1]
        if raw.is_a?(String) && !raw.empty?
          english=raw.b.force_encoding('Windows-31J').encode('UTF-8')
          chinese={
            'FRENCH-KISS'=>'法式接吻','KISS'=>'親吻','BOOB-SLAP'=>'拍胸','SPANK'=>'打屁股',
            "I'd love to make a painting of Cindy"=>'我想替辛蒂畫張畫',
            "I'd love to make a painting of Nancy"=>'我想替南希畫張畫'
          }[english]
          if chinese.nil?
            {'LAURA'=>'蘿拉','NANCY'=>'南希','CINDY'=>'辛蒂','SANDY'=>'珊蒂',
             'ALISON'=>'艾莉森','ISA'=>'伊莎','KARINE'=>'卡琳','ORANGE'=>'奧蘭潔'}.each do |en,zh|
              if english==en || english.start_with?(en+' ')
                tail=english[en.length..-1].gsub('ﾂ､','♥')
                chinese=zh+tail
                break
              end
            end
          end
          abort "Untranslated actor name: #{english}" if chinese.nil?
          params[1]=chinese.encode('UTF-8').b
          actor_name_count+=1
          changed=true
        end
      end
      next unless [355,655].include?(command.instance_variable_get(:@code))
      params=command.instance_variable_get(:@parameters)
      old=params[0]
      next unless old.is_a?(String)
      code=old.b
      if m=code.match(/\A(\s*line[123]\s*=\s*")([^"]*)("\s*)\z/n)
        english=m[2].force_encoding('Windows-31J').encode('UTF-8')
        chinese=translations[english]
        if chinese
          code=(m[1]+chinese.b+m[3]).b
          count+=1
          changed=true
        end
      elsif m=code.match(/\A(\$game_system\.skills\[\d+\]\.name=")([A-Za-z]+)(")\z/n)
        chinese=skill_names[m[2]]
        if chinese
          code=(m[1]+chinese.b+m[3]).b
          name_count+=1
          changed=true
        end
      end
      params[0]=code if changed
    end
  end
  if changed
    FileUtils.mkdir_p(target)
    File.binwrite(over,Marshal.dump(object))
    Marshal.load(File.binread(over))
  end
end
abort "Tooltip coverage mismatch: #{count}/528" unless count==528
abort "Skill-name coverage mismatch: #{name_count}/5" unless name_count==5
abort "Actor-name coverage mismatch: #{actor_name_count}/96" unless actor_name_count==96
puts "Translated #{count} embedded tooltip lines, #{name_count} skill names and #{actor_name_count} event actor names"
