# encoding: utf-8
class RegexFormat
  def replace_space_chars(keyword)
    keyword = keyword.to_s.chomp.strip
    key_arr = keyword.to_s.squeeze(" ").chomp.strip.split(" ")
    keyword = keyword.gsub(/([^\s\w\d\p{Devanagari}])/i){'\\' << $1}
    keyword = keyword.gsub(/(\s)/, '\s+')
    keyword = keyword.gsub("*", '[^\s\p{Z}]+').gsub(/\\\[/,'[').to_s.chomp.strip
    return keyword,key_arr
  end

  def email_alert_regex(pkw)
    regex_hash = Hash.new
    regex_hash["combine"] = Hash.new
    regex_hash["single"] = ""
    the_regex = ""
    pkw.each do |keyword_info|
      if keyword_info.to_s.chomp.strip == ""
        next
      end
      if keyword_info =~ /\+/
        keyword_info = keyword_info.to_s.chomp.strip
        a = Array.new
        i = 0
        keyword_info.split("+").each do |keyword|
          re = ""
          if keyword.to_s.chomp.strip.length.to_i == 0
            next
          end
          keyword,key_arr = replace_space_chars(keyword)
          if i == 0
            i = 1
            re = '(?:\b' + keyword + '\b)'
          else
            re = '(?:'+ keyword+')'
          end
          a << re
        end
        regex_hash["combine"][keyword_info] = a
      else
        keyword = keyword_info.to_s.chomp.strip
        if keyword.to_s.chomp.strip.length.to_i > 0
          keyword,key_arr = replace_space_chars(keyword)
          if keyword.to_s.chomp.strip.length.to_i > 0
            if key_arr.size > 1
              the_regex += '(?:'+ keyword +')|'
            else
              the_regex += '(?:\b'+ keyword +'\b)|'
            end
          end
        end
      end
    end
    the_regex = the_regex.gsub(/\|$/, "")
    if the_regex.to_s.length.to_i > 0
      regex_hash["single"] = the_regex
    end
    return regex_hash
  end

  def check_for_regex(all_cases,regex_hash)
    all_cases = all_cases.gsub(/[  ᠎           ​  　﻿]+/," ").squeeze(" ").chomp.strip
    the_single_regex = regex_hash["single"]
    combine_regex_arr = regex_hash["combine"]
    keyword = ""
    flag = 0
    if the_single_regex.to_s.chomp.strip.length.to_i > 0
      if all_cases =~ /#{the_single_regex}/i
        keyword = (all_cases.match(/#{the_single_regex}/i)).to_s.chomp.strip
        flag = 1
      end
    end
    if flag.to_i == 0
      new_match_regex = ""
      combine_regex_arr.each do |key,val|
        i = 0
        val.each do |regex|
          if i == 0
            new_match_regex += regex
            i = 1
          else
            new_match_regex += '.*?' + regex
          end
        end
        if all_cases.match(/#{new_match_regex}/mi) != nil
          flag = 1
          keyword = (all_cases.match(/#{val[0]}/mi)).to_s.chomp.strip
        end
      end
    end
    keyword = keyword.gsub(/\"$/,"").gsub(/^\"/,"").chomp.strip
    return flag, keyword
  end
end
