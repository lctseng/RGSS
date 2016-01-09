#encoding:utf-8
#==============================================================================
# ■ Lctseng::Spriteset_File
#------------------------------------------------------------------------------
#     處理存讀檔畫面精靈組
#==============================================================================
module Lctseng
class Spriteset_File
  #--------------------------------------------------------------------------
  # ● 等待用方法
  #--------------------------------------------------------------------------
  attr_accessor :command_method
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    @index = -1
    generate_headers
    create_viewports
    create_spritesets
  end
  #--------------------------------------------------------------------------
  # ● 產生header
  #--------------------------------------------------------------------------
  def generate_headers
    dispose_headers
    @headers = []
    6.times do |i|
      @headers[i] = DataManager.load_header(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放header
  #--------------------------------------------------------------------------
  def dispose_headers
    if @headers
      @headers.each do |h|
        h[:screen_snap].dispose if h&&h[:screen_snap]
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 產生顯示端口
  #--------------------------------------------------------------------------
  def create_viewports
    # 背景框架
    @viewport_base = Viewport.new
    # 資訊框架(Z = 10)
    @viewport_info = Viewport.new
    @viewport_info.z = 10
  end
  #--------------------------------------------------------------------------
  # ● 背景名稱
  #--------------------------------------------------------------------------
  def background_name
    ''
  end
  #--------------------------------------------------------------------------
  # ● 返回按鈕名稱
  #--------------------------------------------------------------------------
  def back_button_name
    ''
  end
  #--------------------------------------------------------------------------
  # ● 外框名稱
  #--------------------------------------------------------------------------
  def frame_name
    ''
  end
  #--------------------------------------------------------------------------
  # ● 產生精靈組
  #--------------------------------------------------------------------------
  def create_spritesets
    # 背景
    @base = Sprite.new(@viewport_base)
    @base.bitmap = Cache.picture(background_name)
    # 指令
    @back = Lctseng::Sprite_SingleButton.new([408,23],back_button_name,@viewport_info)
    # 存檔格
    @slots = []
    6.times do |i|
      @slots.push(Lctseng::Sprite_FileSlot.new(i,@headers[i],frame_name,@viewport_info))
    end
    # 資訊
    @info = Lctseng::Sprite_FileInfo.new(@viewport_info)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    dispose_spritesets
    dispose_viewports
    dispose_headers
  end
  #--------------------------------------------------------------------------
  # ● 釋放精靈組
  #--------------------------------------------------------------------------
  def dispose_spritesets
    @info.dispose
    @slots.each {|s| s.dispose}
    @back.dispose
    @base.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放顯示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport_base.dispose
    @viewport_info.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    update_index
    update_spritesets
    update_input 
  end
  #--------------------------------------------------------------------------
  # ● 更新索引
  #--------------------------------------------------------------------------
  def update_index
    last_index = @index
    got = false
    @slots.each_with_index do |slot,i|
      if slot.on
        @index = i
        got = true
        break
      end
    end
    if !got
      @index = -1
    end
    if last_index != @index
      puts "選擇：#{@index}"
      update_info
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新資訊
  #--------------------------------------------------------------------------
  def update_info
    if @index >= 0
      @info.refresh(@headers[@index]) 
    else
      @info.refresh(nil) 
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新精靈組
  #--------------------------------------------------------------------------
  def update_spritesets
    @back.update
    @slots.each {|s| s.update}
  end
  #--------------------------------------------------------------------------
  # ● 更新輸入
  #--------------------------------------------------------------------------
  def update_input
    if Input.trigger?(:B)
      Sound.play_cancel
      command_method.call(:back)
    end
    if Input.trigger?(:C)
      puts "已觸發確認鍵"
      if @index >= 0
        puts "點選檔案：#{@index}"
        command_method.call(:file,@index)
      elsif @back.on 
        if @back.check_command_availble
          @back.process_ok
          Sound.play_ok
          command_method.call(:back)
        else
          Sound.play_buzzer
        end
      end
    end
  end

end
end