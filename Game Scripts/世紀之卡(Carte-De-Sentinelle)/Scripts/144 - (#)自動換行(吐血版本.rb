
class Window_Message
  
  alias :iisnow_convert_escape_characters :convert_escape_characters
  def convert_escape_characters(text)
    result = iisnow_convert_escape_characters(text)
    result.gsub!(/\ek/)          { "\k" }
    result
  end

  def process_character(c, text, pos)
    case c
    when "\r"  
      return
    when "\n"  
      process_new_line(text, pos) #if !@auto_n
    when "\k"
      @auto_n = false
    when "\f"   
      process_new_page(text, pos)
    when "\e"   
      process_escape_character(obtain_escape_code(text), text, pos)
    else       
      process_normal_character(c,text,pos)
    end
  end
  
  def process_normal_character(c,text,pos)
    @auto_n = true
    text_width = text_size(c).width
    if real_width - 40 - pos[:x] > text_width
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
      pos[:x] += text_width
    else 
      process_new_line(text,pos)
      process_normal_character(c,text,pos)
    end
    wait_for_one_character
  end
  
  def real_width
    return self.width - 2 * standard_padding
  end
  
end

