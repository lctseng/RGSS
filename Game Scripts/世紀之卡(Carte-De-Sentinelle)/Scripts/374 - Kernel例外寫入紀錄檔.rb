module Kernel
  
  
  def log_to_file(txt)
    return if !$TEST
    File.open("log.txt", "a") { |f|
      f.puts(txt)
    } # close file
    File.open("permanent_log.txt", "a") { |f|
      f.puts(txt)
    } # close file
  end

  
  def delete_log_file
    File.delete("log.txt") rescue false
  end
  
end
