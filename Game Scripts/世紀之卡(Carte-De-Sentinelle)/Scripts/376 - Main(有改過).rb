#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
#　模塊和類的定義結束之後被實行的處理。
#==============================================================================

Font.default_name =  'Microsoft JhengHei'
rgss_main do
  begin
    SceneManager.run
  rescue => e
    e_dump = Marshal.load(Marshal.dump(e))
    Kernel.delete_log_file
    Kernel.log_to_file("=========例外發生！時間：#{Time.now}=========")
    Kernel.log_to_file("例外訊息：" + e.inspect)
    Kernel.log_to_file("發生追朔：")
    e.backtrace.each do |e| 
      e.gsub!(/\{(\d+)\}\:(\d+)/i)  do |m| 
        
        "腳本 #{$1} -- #{ScriptNames[$1.to_i]}, 行數: #{$2}" 
      end
    end
    e.backtrace.each do |str|
      
      Kernel.log_to_file(str)
    end
    raise e_dump
  end
  
  

end