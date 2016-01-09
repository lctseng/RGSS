#encoding:utf-8

=begin
*******************************************************************************************

   ＊ 圖像精靈強化 ＊

                       for RGSS3

        Ver 2.0.0   2015.07.29

   原作者：魂(Lctseng)，巴哈姆特論壇ID：play123
   

   轉載請保留此標籤

   個人小屋連結：http://home.gamer.com.tw/homeindex.php?owner=play123

   主要功能：
                       一、大部分Lctseng發布的圖像有關腳本都需要有此腳本作為前置腳本
                       
    前置腳本：Lctseng::Easing
                       
   更新紀錄：
    Ver 1.0.0 ：
    日期：2014.09.24
    摘要：■、最初版本

    Ver 1.1.0 ：
    日期：2014.12.02
    摘要：■、更新Sprite_Drawer，新增param_change_color
    
    Ver 1.3.0：
    日期：2015.07.19
    摘要：■、更新Sprite_Drawer，新增狀態繪製
    
    Ver 2.0.0：
    日期：2015.07.29
    摘要：■、新增SpriteShadow
    
    撰寫摘要：一、此腳本修改或重新定義以下類別：
                           ■ Sprite
                          
                        二、此腳本新定義以下類別和模組：
                           ■ SpriteDrawer
                           ■ SpriteFader
                           ■ SpriteSlider
                           ■ SpriteSensor
                           ■ SpriteZoomer
                           ■ SpriteShadow
                          

*******************************************************************************************
=end


#*******************************************************************************************
#
#   請勿修改從這裡以下的程式碼，除非你知道你在做什麼！
#   DO NOT MODIFY UNLESS YOU KNOW WHAT TO DO ! 
#
#*******************************************************************************************

#--------------------------------------------------------------------------
# ★ 紀錄腳本資訊
#--------------------------------------------------------------------------
if !$lctseng_scripts  
  $lctseng_scripts = {}
end


$lctseng_scripts[:sprite_ex] = "2.0.0"

puts "載入腳本：Lctseng - 圖像精靈強化，版本：#{$lctseng_scripts[:sprite_ex]}"



#encoding:utf-8
#==============================================================================
# ■ Sprite
#------------------------------------------------------------------------------
# 　精靈。
#==============================================================================

class  Sprite
  #--------------------------------------------------------------------------
  # ● 執行精靈居中
  #--------------------------------------------------------------------------
  def center_sprite
    center_origin
    self.x = Graphics.width / 2
    self.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 執行精靈原點居中
  #--------------------------------------------------------------------------
  def center_origin
    if self.bitmap
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
  end
  #--------------------------------------------------------------------------
  # ● 滑鼠是否在精靈內？
  #--------------------------------------------------------------------------
  def mouse_in_area?
    if self.bitmap
      Mouse.area?(self.x - self.ox,self.y - self.oy,self.bitmap.width,self.bitmap.height)
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 當前位置
  #--------------------------------------------------------------------------
  def current_pos
    [self.x , self.y]
  end
  #--------------------------------------------------------------------------
  # ● 設定位置
  #--------------------------------------------------------------------------
  def set_pos(pos)
    self.x = pos[0]
    self.y = pos[1]
  end
end


#encoding:utf-8
#==============================================================================
# ■ SpriteDrawer
#------------------------------------------------------------------------------
# 　讓精靈可以進行類似Window那樣繪製文字的模組
# UPDATE：14008062248 Ver 1.3
#==============================================================================
module SpriteDrawer
  #--------------------------------------------------------------------------
  # ● 取得視窗外框位圖
  #--------------------------------------------------------------------------
  def windowskin
    Cache.system("Window")
  end
  #--------------------------------------------------------------------------
  # ● 獲取內容尺寸
  #--------------------------------------------------------------------------
  def text_size(str)
    self.bitmap.text_size(str)
  end
  #--------------------------------------------------------------------------
  # ● 獲取項目的繪制矩形
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● 獲取項目寬度
  #--------------------------------------------------------------------------
  def item_width
    192
  end
  #--------------------------------------------------------------------------
  # ● 獲取項目高度
  #--------------------------------------------------------------------------
  def item_height
    line_height
  end
  #--------------------------------------------------------------------------
  # ● 獲取列數
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # ● 獲取行間距的寬度
  #--------------------------------------------------------------------------
  def spacing
    return 32
  end
  #--------------------------------------------------------------------------
  # ● 獲取文字顏色
  #     n : 文字顏色編號（0..31）
  #--------------------------------------------------------------------------
  def text_color(n)
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  #--------------------------------------------------------------------------
  # ● 繪製文字
  #--------------------------------------------------------------------------
  def draw_text(*args,&block)
    self.bitmap.draw_text(*args,&block)
  end
  #--------------------------------------------------------------------------
  # ● 繪制圖標
  #     enabled : 有效的標志。false 的時候使用半透明效果繪制
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    temp_bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.bitmap.blt(x, y, temp_bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # ● 繪制圖標，指定目標矩形
  #     enabled : 有效的標志。false 的時候使用半透明效果繪制
  #--------------------------------------------------------------------------
  def draw_icon_with_rect(icon_index,  target_rect ,enabled = true)
    temp_bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.bitmap.stretch_blt(target_rect, temp_bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # ● 獲取半透明繪制用的透明度
  #--------------------------------------------------------------------------
  def translucent_alpha
    return 160
  end
  #--------------------------------------------------------------------------
  # ● 繪制物品名稱
  #     enabled : 有效的標志。false 的時候使用半透明效果繪制
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # ● 繪制物品細節名稱 
  #--------------------------------------------------------------------------
  def draw_detail_name(item, x, y, enabled = true, width = 172)
    return unless item.is_a?(Game_Equip_Details)
    color = item.fmts[1]
    match_item = item.get_match
    return unless match_item
    item_name = sprintf(item.fmts[0],match_item.name)
    item_icon_index = match_item.icon_index
    if enabled
      change_color(text_color(color),true)
    else
      change_color(normal_color, false)
    end
    draw_icon(item_icon_index, x, y, enabled)
    draw_text(x + 24, y, width, line_height, item_name)
  end
  #--------------------------------------------------------------------------
  # ● 繪制名字
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112,align = 0)
    # change_color(hp_color(actor))
    draw_text(x, y, width, line_height, actor.name,align)
  end
  #--------------------------------------------------------------------------
  # ● 更改內容繪制顏色
  #     enabled : 有效的標志。false 的時候使用半透明效果繪制
  #--------------------------------------------------------------------------
  def change_color(color, enabled = true)
    self.bitmap.font.color.set(color)
    self.bitmap.font.color.alpha = translucent_alpha unless enabled
  end
  #--------------------------------------------------------------------------
  # ● 更改字型
  #--------------------------------------------------------------------------
  def change_font(font)
    self.bitmap.font = font if self.bitmap
  end
  #--------------------------------------------------------------------------
  # ● 獲取行高
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # ● 更換字體大小
  #--------------------------------------------------------------------------
  def change_font_size(sz)
    self.bitmap.font.size = sz
  end
  #--------------------------------------------------------------------------
  # ● 繪製數值條內容 
  # 給定：座標、最大值、當前值、圖檔名稱
  #--------------------------------------------------------------------------
  def draw_gauge_content(dx,dy,current,max,filename)
    bitmap = Cache.battle(filename)
    rect = bitmap.rect.clone
    if max <= 0
      rate = 0
    else
      rate = (current.to_f/max)
    end
    rect.width = (rect.width * rate + 0.5).round
    self.bitmap.blt(dx,dy,bitmap,rect)
    change_color(normal_color)
    draw_text(dx,dy-3,bitmap.rect.width - 3,16,sprintf("%d / %d",current,max),2)
  end
  #--------------------------------------------------------------------------
  # ● 繪製子彈資訊
  #--------------------------------------------------------------------------
  def draw_bullet_info_by_detail(detail,x,y,dw = 115 , dh = 18)
    # 字型大小設置：子彈型
    change_font(Lctseng.bullet_font)
    
    item = nil
    if detail
      item = detail.get_match
    end
    if item && item.need_bullet?
      ammo = detail.ammo
      bullet_item = ammo.item
      if detail.has_loaded_bullet_id? && bullet_item
        draw_bullet(ammo,x,y,dw,dh)
      else
        change_color(system_color)
        draw_text(x,y,dw,dh,"無裝備任何子彈")
      end
    else
      # 子彈不存在或不需要子彈
      change_color(system_color)
      draw_text(x,y,dw,dh,"無須使用子彈")
    end
    
  end
  #--------------------------------------------------------------------------
  # ● 繪製子彈
  #--------------------------------------------------------------------------
  def draw_bullet(ammo,x,y,total_dw,dh)
    amount_dw = 40
    dw = total_dw - amount_dw
    item = ammo.item
    bullet = ammo.bullet_obj
    # 繪製圖標
    draw_icon_with_rect(item.icon_index,Rect.new(x,y,dh,dh))
    # 基準座標位移
    diff = (dh + 1)
    x += diff
    dw -= diff
    # 繪製文字
    
    change_color(text_color(6))
    name = bullet.display_name
    text_w = text_size(name).width
    #contents.fill_rect(Rect.new(x,y,dw,dh),Color.new(255,0,0))
    draw_text(x,y,dw,dh,name)
    
    # 基準座標位移
    x += ( text_w + 1 )
    # 繪製數量
    amount = ammo.bullet_remain
    if amount > 0
      change_color(Color.new(0,255,0))
    else
      change_color(Color.new(255,0,0))
    end
    str = sprintf("(%d)",amount)
    #contents.fill_rect(Rect.new(x,y,amount_dw,dh),Color.new(255,255,0))
    draw_text(x,y,amount_dw,dh,str)
    
  end
  #--------------------------------------------------------------------------
  # ● 繪製狀態，包含時間表示
  #--------------------------------------------------------------------------
  def draw_state(battler,id,x,y)
    state = $data_states[id]
    draw_icon(state.icon_index,x,y)
    # 時間
    time = $data_states[id].auto_removal_timing > 0 ? battler.remain_state_turns(id)  : 0 
    if time > 0
      # 更改字型
      self.bitmap.font = Lctseng.state_time_font
      draw_text(x,y+12,24,16,time,2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取能力值變化的繪制色
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_up_color   if change > 0
    return power_down_color if change < 0
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● 獲取各種文字顏色
  #--------------------------------------------------------------------------
  def normal_color;      text_color(0);   end;    # 普通
  def system_color;      text_color(16);  end;    # 系統
  def crisis_color;      text_color(17);  end;    # 危險
  def knockout_color;    text_color(18);  end;    # 無法戰斗
  def gauge_back_color;  text_color(19);  end;    # 值槽背景
  def hp_gauge_color1;   text_color(20);  end;    # HP 值槽 1
  def hp_gauge_color2;   text_color(21);  end;    # HP 值槽 2
  def mp_gauge_color1;   text_color(22);  end;    # MP 值槽 1
  def mp_gauge_color2;   text_color(23);  end;    # MP 值槽 2
  def mp_cost_color;     text_color(23);  end;    # 消費 TP
  def power_up_color;    text_color(24);  end;    # 能力值提升（更換裝備時）
  def power_down_color;  text_color(25);  end;    # 能力值降低（更換裝備時）
  def tp_gauge_color1;   text_color(28);  end;    # TP 值槽 1
  def tp_gauge_color2;   text_color(29);  end;    # TP 值槽 2
  def tp_cost_color;     text_color(29);  end;    # 消費 TP
  end
  
  
  
  #encoding:utf-8
#==============================================================================
# ■ SpriteFader
#------------------------------------------------------------------------------
# 　讓精靈可以進行淡出淡入所需的原件
#==============================================================================
module SpriteFader
  #--------------------------------------------------------------------------
  # ● 初始化淡入淡出模組
  #--------------------------------------------------------------------------
  def fader_init
    @fade_count = 0
    @fade_to = 0
    @fade_real_opacity = 0.0
    @fade_speed = 0.0
    @fade_post_handler = nil
    @fade_init = true
    @fade_processing = false
  end
  #--------------------------------------------------------------------------
  # ● 設置淡入淡出 (設定目的透明度與時間)
  #--------------------------------------------------------------------------
  def fader_set_fade(to,time)
    @fade_count = time
    @fade_to = to.to_f
    @fade_real_opacity = self.opacity.to_f
    @fade_speed = ( @fade_to - @fade_real_opacity ) / @fade_count + 0.001
    @fade_processing = true
  end
  #--------------------------------------------------------------------------
  # ● 更新淡入淡出
  #--------------------------------------------------------------------------
  def fader_update
    return if !@fade_init
    if @fade_count > 0
      @fade_count -= 1
      self.opacity = @fade_real_opacity += @fade_speed
    else
      if @fade_processing
        @fade_processing = false
        fader_post_fade
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否淡入淡出？
  #--------------------------------------------------------------------------
  def fader_fading?
    @fade_init && @fade_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 設置淡入淡出結束後處理
  #--------------------------------------------------------------------------
  def fader_set_post_handler(handler)
    @fade_post_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● 呼叫淡入淡出結束後處理
  #--------------------------------------------------------------------------
  def fader_post_fade
    if @fade_post_handler
      @fade_post_handler.call
    end
  end
  #--------------------------------------------------------------------------
  # ● 清除呼叫淡入淡出結束後的處理程序
  #--------------------------------------------------------------------------
  def fader_clear_handler
    @fade_post_handler = nil
  end
end








#encoding:utf-8
#==============================================================================
# ■ SpriteSlider
#------------------------------------------------------------------------------
# 　讓精靈可以進行移動所需的原件
#==============================================================================
module SpriteSlider
  #--------------------------------------------------------------------------
  # ● 預設移動函數
  #--------------------------------------------------------------------------
  def default_sliding_function
    :circOut
  end
  #--------------------------------------------------------------------------
  # ● 初始化移動模組
  #--------------------------------------------------------------------------
  def slider_init(function = default_sliding_function)
    @slider_count = 0
    @slider_real_pos = [0.0,0.0]
    @slider_from = [0,0]
    @slider_to = [0,0]
    @slider_speed = [0.0,0.0]
    @slider_init = true
    @slider_post_handler = nil
    @slider_processing = false
    @slider_function = function
    case function
    when :expoOut,:circOut
      @slider_set_method = method("slider_set_easing")
    else
      @slider_set_method = method("slider_set_#{function}")
    end
    
    @slider_update_method = method("slider_update_#{function}")

  end
  #--------------------------------------------------------------------------
  # ● 設置移動
  #--------------------------------------------------------------------------
  def slider_set_move(from,to,time)
    @slider_count = time
    @slider_from = from.collect {|i| i.to_f}
    @slider_to = to.collect {|i| i.to_f}
    @slider_real_pos = @slider_from.clone
    @slider_processing = true
    # 呼叫特殊函數
    @slider_set_method.call(from,to,time)
  end
  #--------------------------------------------------------------------------
  # ● 設置移動：線性
  #--------------------------------------------------------------------------
  def slider_set_linear(from,to,time)
    # 設置速度
    2.times do |i|
      @slider_speed[i] = (@slider_to[i] - @slider_from[i]) / @slider_count
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置移動：Easing
  #--------------------------------------------------------------------------
  def slider_set_easing(from,to,time)
    # 設置位移
    @slider_distance = []
    2.times do |index|
      @slider_distance[index] = @slider_to[index] - @slider_from[index]
    end
    # 設置初速度：距離 / 80
    @slider_v0 = @slider_distance.collect{|d| d / 16000.0}
    # 設置時間
    @slider_duration = time
    # 設置Easing 物件
    @slider_easing = []
    2.times do |i|
      @slider_easing[i] = Lctseng::Easing.new(@slider_v0[i],@slider_duration,@slider_distance[i])
    end
    
  end

  #--------------------------------------------------------------------------
  # ● 更新移動
  #--------------------------------------------------------------------------
  def slider_update
    return if !@slider_init
    if @slider_count > 0
      @slider_count -= 1
      @slider_update_method.call
      self.x = @slider_real_pos[0]
      self.y = @slider_real_pos[1]
      2.times do |i|
        if @slider_distance[i] > 0 && @slider_real_pos[i] > @slider_to[i]
          @slider_real_pos[i] = @slider_to[i] 
        elsif @slider_distance[i] < 0 && @slider_real_pos[i] < @slider_to[i]
          @slider_real_pos[i] = @slider_to[i]
        end
      end
    else
      if @slider_processing
        slider_adjust_pos
        @slider_processing = false
        slider_post_method
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新移動：線性
  #--------------------------------------------------------------------------
  def slider_update_linear
    2.times do |i|
      @slider_real_pos[i] = @slider_real_pos[i] + @slider_speed[i]
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新移動：緩和Expo-out
  #--------------------------------------------------------------------------
  def slider_update_expoOut
    2.times do |i|
      @slider_real_pos[i] = @slider_from[i] + @slider_easing[i].evalExpoOut(@slider_duration - @slider_count)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新移動：緩和Circ-out
  #--------------------------------------------------------------------------
  def slider_update_circOut
    2.times do |i|
      @slider_real_pos[i] = @slider_from[i] + @slider_easing[i].evalCircOut(@slider_duration - @slider_count)
    end
  end
  #--------------------------------------------------------------------------
  # ● 修正最後位置
  #--------------------------------------------------------------------------
  def slider_adjust_pos
    self.x , self.y = @slider_to
  end
  #--------------------------------------------------------------------------
  # ● 是否移動動？
  #--------------------------------------------------------------------------
  def slider_sliding?
    @slider_init && @slider_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 呼叫移動後的方法
  #--------------------------------------------------------------------------
  def slider_post_method
    if @slider_post_handler
      @slider_post_handler.call
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置移動結束後處理
  #--------------------------------------------------------------------------
  def slider_set_post_handler(handler)
    @slider_post_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● 清除呼叫移動出結束後的處理程序
  #--------------------------------------------------------------------------
  def slider_clear_handler
    @slider_post_handler = nil
  end
  #--------------------------------------------------------------------------
  # ● 清除呼叫移動出結束後的處理程序
  #--------------------------------------------------------------------------
  def slider_clear_post_handler
    @slider_post_handler = nil
  end
end

#encoding:utf-8
#==============================================================================
# ■ SpriteSensor
# 更新：1408061703 Ver 1.1
#------------------------------------------------------------------------------
# 　讓精靈可以感應滑鼠放置所需的原件
#==============================================================================
module SpriteSensor
  #--------------------------------------------------------------------------
  # ● 初始化感應模組
  #--------------------------------------------------------------------------
  def sensor_init
    @sensor_init = true
    @sensor_hover_handler = nil
    @sensor_input_handler = nil
    @sensor_set_hover = false
    @sensor_set_input = false
    @active = false
  end
  #--------------------------------------------------------------------------
  # ● 其他啟動條件
  #--------------------------------------------------------------------------
  def sensor_other_active_condition
    true
  end
  #--------------------------------------------------------------------------
  # ● 啟用感應器
  #--------------------------------------------------------------------------
  def sensor_activate
    @active = true
  end
  #--------------------------------------------------------------------------
  # ● 停用感應器
  #--------------------------------------------------------------------------
  def sensor_deactivate
    @active = false
  end
  #--------------------------------------------------------------------------
  # ● 設置懸浮感應處理程序
  #--------------------------------------------------------------------------
  def sensor_set_sense_hover(handler)
    @sensor_set_hover = true
    @sensor_hover_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● 設置按鈕感應處理程序
  #--------------------------------------------------------------------------
  def sensor_set_sense_input(handler)
    @sensor_set_input = true
    @sensor_input_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● 滑鼠是否在精靈內？
  #--------------------------------------------------------------------------
  def sensor_mouse_in_area?
    if self.bitmap
      Mouse.area?(self.x - self.ox,self.y - self.oy,self.bitmap.width,self.bitmap.height)
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # ● 呼叫感應器的檢查方法
  #--------------------------------------------------------------------------
  def sensor_call_input
    if Input.trigger?(:C)
      @sensor_input_handler.call(:C)
    end
  end
  #--------------------------------------------------------------------------
  # ● 滑鼠是否在精靈內？包含啟動測試
  #--------------------------------------------------------------------------
  def sensor_mouse_in_area_safe?
    @sensor_init  && @active && sensor_mouse_in_area?
  end
  #--------------------------------------------------------------------------
  # ● 更新感應
  #--------------------------------------------------------------------------
  def sensor_update
    return if !@sensor_init 
    return if !@active
    return if !sensor_other_active_condition
    if @sensor_hover_handler
      if sensor_mouse_in_area?
        if @sensor_set_hover && @sensor_hover_handler
          @sensor_hover_handler.call(true)
        end
        if @sensor_set_input && @sensor_input_handler
          sensor_call_input
        end
      else
        if @sensor_set_hover && @sensor_hover_handler
          @sensor_hover_handler.call(false)
        end
      end
    end
  end
end

#encoding:utf-8
#==============================================================================
# ■ SpriteZoomer
#------------------------------------------------------------------------------
# 　讓精靈可以進行放大縮小所需的原件，內部實例變數以 "_" 開頭，公開方法以"zoomer"開頭
#==============================================================================
module SpriteZoomer
  #--------------------------------------------------------------------------
  # ● 初始化縮放模組
  #--------------------------------------------------------------------------
  def zoomer_init
    @_zoom_count = 0
    @_zoom_from = [0.0,0.0]
    @_zoom_to = [0.0,0.0]
    @_zoom_speed = [0.0,0.0]
    @_zoom_init = true
    @_zoom_post_handler = nil
    @_zoom_processing = false
  end
  #--------------------------------------------------------------------------
  # ● 設置縮放
  #--------------------------------------------------------------------------
  def zoomer_set_effect(from,to,time)
    self.zoom_x , self.zoom_y = from
    @_zoom_count = time
    @_zoom_from = from
    @_zoom_to = to
    # 設置速度
    2.times do |i|
      @_zoom_speed[i] = (@_zoom_to[i] - @_zoom_from[i]) / @_zoom_count
    end
    @_zoom_processing = true
    
  end
  #--------------------------------------------------------------------------
  # ● 更新縮放
  #--------------------------------------------------------------------------
  def zoomer_update
    return if !@_zoom_init
    if @_zoom_count > 0
      @_zoom_count -= 1
      self.zoom_x += @_zoom_speed[0]
      self.zoom_y += @_zoom_speed[1]
    else
      if @_zoom_processing
        @_zoom_processing = false
        zoomer_post_method
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def zoomer_effect?
    @_zoom_init && @_zoom_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 呼叫縮放後的方法
  #--------------------------------------------------------------------------
  def zoomer_post_method
    if @_zoom_post_handler
      @_zoom_post_handler.call
    end
  end
  #--------------------------------------------------------------------------
  # ● 設置縮放結束後處理
  #--------------------------------------------------------------------------
  def zoomer_set_post_handler(handler)
    @_zoom_post_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● 清除呼叫縮放出結束後的處理程序
  #--------------------------------------------------------------------------
  def zoomer_clear_handler
    @_zoom_post_handler = nil
  end
end

#encoding:utf-8
#==============================================================================
# ■ Lctseng::SpriteShadow
#------------------------------------------------------------------------------
# 　Sprite陰影模組模組
#==============================================================================

module Lctseng
module SpriteShadow
  #--------------------------------------------------------------------------
  # ● 常數設定
  #--------------------------------------------------------------------------
  SHADOW_COVER_Z = 200
  SHADOW_COVER_OPACITY = 80
  #--------------------------------------------------------------------------
  # ● 影子初始化
  #--------------------------------------------------------------------------
  def shadow_init
    @shadow = Sprite.new
    @shadow.z = SHADOW_COVER_Z
  end
  #--------------------------------------------------------------------------
  # ● 影子更新
  #--------------------------------------------------------------------------
  def shadow_update
    # 同步
    @shadow.bitmap = self.bitmap
    @shadow.x = self.x
    @shadow.y = self.y
    @shadow.visible = self.visible
    @shadow.src_rect = self.src_rect
    @shadow.ox = self.ox
    @shadow.oy = self.oy
    @shadow.zoom_x = self.zoom_x
    @shadow.zoom_y = self.zoom_y
    @shadow.mirror = self.mirror
    # 透明限制
    @shadow.opacity = [self.opacity , SHADOW_COVER_OPACITY].min
  end
  #--------------------------------------------------------------------------
  # ● 影子釋放
  #--------------------------------------------------------------------------
  def shadow_dispose
    @shadow.dispose
  end
  
  
end
end