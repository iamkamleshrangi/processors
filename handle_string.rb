#encoding : utf-8
class HandleString
  def initialize(input_string)
    @str = input_string
  end

  attr_reader :str

  def clear_string
    str = str.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
    str = str.to_s.chomp.strip.gsub(/[^A-Za-z0-9,<\.>\/\?;:'"\[\]{}\|!@#`~$%\^\&\*\(\)\-_\=\+ \n\r\p{L}\p{M}]/i, " ").to_s.squeeze(" ").chomp.strip
    str = str.gsub(/[ áá âââââââââââââ¯âãï»¿]+/," ").squeeze(" ").chomp.strip
    str.gsub!(/^:/,"")
    if str != nil
      len = str.split(" ")
      len = len.length
      cleanstr = ''
      (0..len.to_i).each do |stat|
        if str.split(" ")[stat] != nil and  str.split(" ")[stat].length > 0
          sub = str.split(" ")[stat].strip.chomp.delete(" ")
          sub = sub.squeeze(" ").chomp.strip
          cleanstr = "#{cleanstr}\s"<< sub
        end
      end
      str = cleanstr
      str = str.to_s.chomp.strip
      str
    end
  end

  def clean_non_word
    str = clear_string(str)
    str = str.gsub(/[^a-z0-9 ]/i, " ")
    str = str.squeeze(" ")
    str = str.to_s.downcase.chomp.strip
    str = str.gsub(/[ ]/, "_")
    str
  end

  def text_clean
    txt = clear_string(str)
    txt = txt.gsub(/[\r\n\t]/, " ").to_s
    txt = txt.squeeze(" ")
    txt = txt.chomp.strip
    txt
  end
end

