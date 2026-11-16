require 'zlib'
require 'fileutils'

root = File.dirname(__FILE__)
source = File.join(root, 'extracted', 'Data', 'Scripts.rxdata')
target = File.join(root, 'overlay', 'Data', 'Scripts.rxdata')
scripts = Marshal.load(File.binread(source))
changes = {
  16 => {
    'attr_reader   :name                     # name' =>
      "attr_reader   :name                     # name\n" +
      "  def name\n" +
      "    return @name unless @name.is_a?(String)\n" +
      "    names = {'GARY'=>'蓋瑞','LAURA'=>'蘿拉','NANCY'=>'南希','CINDY'=>'辛蒂',\n" +
      "             'SANDY'=>'珊蒂','ALISON'=>'艾莉森','ISA'=>'伊莎',\n" +
      "             'KARINE'=>'卡琳','ORANGE'=>'奧蘭潔'}\n" +
      "    names.each do |english, chinese|\n" +
      "      if @name == english\n" +
      "        return chinese\n" +
      "      elsif @name[0, english.length] == english\n" +
      "        tail = @name[english.length, @name.length]\n" +
      "        return chinese + (tail[0, 2] == ' [' ? tail : '')\n" +
      "      end\n" +
      "    end\n" +
      "    return @name\n" +
      "  end"
  },
  14 => {
    'self.damage = "Miss"' => 'self.damage = "未命中"'
  },
  51 => {
    '"EQUIPMENT"' => '"裝備"',
    '"KILLS"' => '"擊殺"',
    '"DEFEATS"' => '"敗北"',
    '"FIGHTS"' => '"戰鬥"',
    '"NXT"' => '"升級"'
  },
  52 => {
    'name = "Autosave"' => 'name = "自動存檔"'
  },
  53 => {
    '@commands = ["Buy", "Drop", "Exit"]' => '@commands = ["購買", "賣出", "離開"]'
  },
  57 => {
    '"    Owned:"' => '"    持有："'
  },
  62 => {
    '@commands = ["Fight", "Auto", "Flee"]' => '@commands = ["戰鬥", "自動", "逃跑"]'
  },
  63 => {
    '"LEVEL UP!"' => '"升級！"'
  },
  87 => {
    "'Permission to write to the save file was denied.'" => "'沒有寫入存檔的權限。'",
    "'Please check the permission on the save file folder and on any save files you have.'" => "'請檢查存檔資料夾和存檔檔案的權限。'",
    "'Running the game in protected mode can mean that you cannot overwrite old saves.'" => "'若遊戲在受保護模式下執行，可能無法覆寫舊存檔。'",
    "'There is not enough free space left to save the file.'" => "'剩餘空間不足，無法儲存。'",
    "'An unidenfied error occurred while saving the file.'" => "'儲存時發生不明錯誤。'",
    "'Try saving again in the same slot or another.'" => "'請重試原存檔欄位，或改用其他欄位。'"
  },
  88 => {
    "'Permission to load the save file was denied'" => "'沒有讀取存檔的權限。'",
    "'An error occured while trying to load the save.'" => "'讀取存檔時發生錯誤。'",
    '"Please install a newer version of #{System::VISUAL_GAME_NAME}"' => '"請安裝較新版本的 #{System::VISUAL_GAME_NAME}"',
    "'Save file is corrupt. You cannot use this save.'" => "'存檔已損毀，無法使用。'",
    "'There is unfortunately not much you can do about this'" => "'很遺憾，這個存檔可能無法修復。'",
    "'This save was made with a later version of the game.'" => "'此存檔由較新版本的遊戲建立。'",
    "'Loading it may lead to unstable game play.'" => "'讀取後遊戲可能不穩定。'",
    "'Do you want to proceed?'" => "'仍要繼續嗎？'"
  },
  89 => {
    's1 = "TITLE SCREEN"' => 's1 = "標題畫面"',
    's2 = "SHUTDOWN"' => 's2 = "結束遊戲"',
    's3 = "CANCEL"' => 's3 = "取消"'
  },
  110 => {
    '@help_window.set_text("Escape", 1)' => '@help_window.set_text("逃跑", 1)'
  },
  109 => {
    'target.damage != "Miss"' => 'target.damage != "未命中"'
  },
  130 => {
    '"not avail. (visit castle to recruit)"' => '"尚未加入隊伍"',
    '"You cannot remove"' => '"不能移除"',
    '"the last party member!"' => '"最後一名隊員！"'
  },
  143 => {
    '"CRITICAL"' => '"暴擊"'
  },
  172 => {
    "['Yes', 'No', 'No, don\\'t ask me again']" => "['是', '否', '不要再詢問']"
  },
  174 => {
    'Text_In_Bar = "OPTIONS MENU"' => 'Text_In_Bar = "選項設定"'
  },
  175 => {
    "['ACCEPT', 'CANCEL']" => "['確定', '取消']"
  },
  37 => {
    'self.contents.font.name = ["Impact", "Arial", "Times New Roman"]' =>
      'self.contents.font.name = ["Microsoft JhengHei", "Arial", "Times New Roman"]'
  },
  61 => {
    'self.contents.font.name = ["Impact","Arial","Lucida Console", "Verdana"]' =>
      'self.contents.font.name = ["Microsoft JhengHei", "Arial", "Verdana"]',
    'while ((c = text.slice!(/./m)) != nil)' =>
      "while ((c = text.slice!(/./m)) != nil)\n" +
      "        if c.size == 1\n" +
      "          lead = c[0]\n" +
      "          extra = lead >= 0xF0 && lead <= 0xF7 ? 3 :\n" +
      "                  lead >= 0xE0 && lead <= 0xEF ? 2 :\n" +
      "                  lead >= 0xC0 && lead <= 0xDF ? 1 : 0\n" +
      "          extra.times { c << text.slice!(/./m) if text.size > 0 }\n" +
      "        end"
  },
  79 => {
    's1 = "START"' => 's1 = "開始"',
    's2 = "LOAD"' => 's2 = "讀取"',
    's3 = "QUIT"' => 's3 = "離開"'
  },
  81 => {
    's4 = "INFO"' => 's4 = "資訊"',
    's5 = "TEAM"' => 's5 = "隊伍"',
    's6 = "GIRLS"' => 's6 = "女孩"',
    's7 = "SAVE"' => 's7 = "存檔"',
    's8 = "EXIT"' => 's8 = "離開"',
    's9 = "OPTIONS"' => 's9 = "選項"'
  },
  177 => {
    "@commands = ['YES', 'NO']" => "@commands = ['是', '否']",
    'self.contents.font.name = ["Impact", "Times New Roman"]' =>
      'self.contents.font.name = ["Microsoft JhengHei", "Arial"]'
  },
  188 => {
    'Text_In_Bar = "GIRLS <3 <3 <3"' => 'Text_In_Bar = "女孩們 ♥♥♥"'
  },
  189 => {
    '@command_window = Window_Command.new(160, @commands)' =>
      '@command_window = Window_Command.new(160, @commands.map { |c| {"Obedience" => "順從度", "Love" => "好感度", "Main Menu" => "主選單"}.fetch(c, c) })',
    'return @commands[index]' =>
      'return {"Obedience" => "順從度", "Love" => "好感度", "Main Menu" => "主選單"}.fetch(@commands[index], @commands[index])'
  },
  197 => {
    '"Who:"' => '"人物："',
    '"Where:"' => '"地點："',
    '"What:"' => '"目標："',
    '"No quests have been completed"' => '"尚未完成任何任務"',
    '"Return to the main menu"' => '"返回主選單"',
    '"Switch to completed quests"' => '"查看已完成任務"',
    '"Switch to pending quests"' => '"查看待完成任務"'
  },
  226 => {
    "TEXT_FULLSCREEN = 'FULL SCREEN'" => "TEXT_FULLSCREEN = '全螢幕'",
    "TEXT_PLAY_BGM = 'MUSIC ON'" => "TEXT_PLAY_BGM = '播放音樂'",
    "TEXT_PLAY_SE = 'SFX ON'" => "TEXT_PLAY_SE = '播放音效'",
    '"MOUSE ON"' => '"啟用滑鼠"',
    '"MESSAGES ON"' => '"顯示訊息"',
    '"GORE ON"' => '"顯示血腥畫面"'
  },
  204 => {
    '"Gained"' => '"獲得"',
    '"Gained "' => '"獲得 "'
  },
  214 => {
    "'Enable mouse control?'" => "'要啟用滑鼠操作嗎？'",
    "'Mouse has been enabled! You can disable the mouse '" => "'已啟用滑鼠操作！如需停用滑鼠，'",
    '"script manually in #{System::INI_FILENAME}"' => '"請在 #{System::INI_FILENAME} 中手動設定。"',
    "'Mouse has been disabled! You can enable the mouse '" => "'已停用滑鼠操作！如需啟用滑鼠，'"
  },
  257 => {
    'Font.default_name = ["Impact", "Arial", "Verdana", "Times New Roman"]' =>
      'Font.default_name = ["Microsoft JhengHei", "Arial", "Verdana", "Times New Roman"]'
  }
}

changes.each do |index, replacements|
  code = Zlib::Inflate.inflate(scripts[index][2]).b
  replacements.each do |old, new_text|
    old = old.b
    abort "Missing script text at #{index}: #{old}" unless code.include?(old)
    code = code.gsub(old, new_text.encode('UTF-8').b)
  end
  scripts[index][2] = Zlib::Deflate.deflate(code)
end
font_sections = 0
scripts.each_with_index do |entry, index|
  next unless entry && entry[2]
  code = Zlib::Inflate.inflate(entry[2]).b
  old = code.dup
  ['Impact', 'Rough Draft', 'Arial Black'].each do |font|
    code = code.gsub(%Q{"#{font}"}.b, '"Microsoft JhengHei"'.b)
  end
  code = code.gsub('font.name = "Arial"'.b, 'font.name = "Microsoft JhengHei"'.b)
  code = code.gsub('font.name = ["Arial",'.b, 'font.name = ["Microsoft JhengHei",'.b)
  code = code.gsub('font.name = ["Verdana",'.b, 'font.name = ["Microsoft JhengHei",'.b)
  if code != old
    entry[2] = Zlib::Deflate.deflate(code)
    font_sections += 1
  end
end
FileUtils.mkdir_p(File.dirname(target))
File.binwrite(target, Marshal.dump(scripts))
verify = Marshal.load(File.binread(target))
changes.each_key { |i| Zlib::Inflate.inflate(verify[i][2]) }
puts "Patched #{changes.length} text sections and #{font_sections} font sections; round-trip OK: #{target}"
