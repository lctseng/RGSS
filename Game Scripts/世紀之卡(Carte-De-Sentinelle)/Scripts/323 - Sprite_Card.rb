#encoding:utf-8
#==============================================================================
# ■ CardBattle::Sprite_Card
#------------------------------------------------------------------------------
#     處理基本卡牌的外觀
#==============================================================================
module CardBattle
class Sprite_Card < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 定義實例變數
  #--------------------------------------------------------------------------
  attr_reader :card_obj
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @card_obj = nil
    @bitmap_cover = Cache.battle("battle_cardB")
    @bitmap_name_selected = ""
    @bitmap_name_unselect = ""
    @bitmap_name_reserved = ""
    @selected = false
    @reserved = false
    @cover = false
  end
  #--------------------------------------------------------------------------
  # ● 設定卡片物件 (由物件實體)
  #--------------------------------------------------------------------------
  def set_card_object(obj)
    @card_obj = obj
    set_bitmap_filename
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 設定卡面圖片
  #--------------------------------------------------------------------------
  def set_bitmap
    if @cover
      self.bitmap = @bitmap_cover 
    elsif @reserved
      if !@bitmap_name_reserved.empty?
        self.bitmap = Cache.battle(@bitmap_name_reserved)
      else
        self.bitmap = nil
      end
    elsif @selected
      if !@bitmap_name_selected.empty?
        self.bitmap = Cache.battle(@bitmap_name_selected)
      else
        self.bitmap = nil
      end
    else
      if !@bitmap_name_unselect.empty?
        self.bitmap = Cache.battle(@bitmap_name_unselect)
      else
        self.bitmap = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定卡面檔名
  #--------------------------------------------------------------------------
  def set_bitmap_filename
    if @card_obj
      filename = nil
      case @card_obj.card_type
      when :attack
        filename = "battle_cardF_atk#{@card_obj.card_point}"
      when :defend
        filename = "battle_cardF_def#{@card_obj.card_point}"
      when :special
        case @card_obj.card_effect 
        when :interrupt
          filename = "battle_cardF_sp3"
        when :deliver
          filename = "battle_cardF_sp1"
        when :exchange
          filename = "battle_cardF_sp2"
        end
      when :skill
        case @card_obj.card_skill_type
        when :speed
          filename = "battle_cardF_atkspd"
        when :attack
          filename = "battle_cardF_atkatk"
        when :magic
          case @card_obj.card_effect
          when :real_damage
            filename = "battle_cardF_atkmgc1"
          when :recovery
            filename = "battle_cardF_atkmgc2"
          end
        end
      end
      if !filename
        puts "嚴重錯誤！無法找到卡片#{@card_obj}的圖像檔案名稱！"
      end
      @bitmap_name_selected = filename + "_selected"
      @bitmap_name_unselect = filename 
      @bitmap_name_reserved = filename + "_reserved"
    else
      @bitmap_name_selected = ""
      @bitmap_name_unselect = ""
      @bitmap_name_reserved = ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # ● 轉換到已保留的圖像
  #--------------------------------------------------------------------------
  def to_reserved_effect
    @reserved = true
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 取消已保留的圖像效果
  #--------------------------------------------------------------------------
  def to_unreserve_effect
    @reserved = false
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 轉換到已選擇的圖像
  #--------------------------------------------------------------------------
  def to_selected_effect
    @selected = true
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 轉換到未選擇的圖像
  #--------------------------------------------------------------------------
  def to_unselect_effect
    @selected = false
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 卡片是否可使用
  #--------------------------------------------------------------------------
  def card_usable?
    @card_obj && !@card_obj.used
  end
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def covered?
    @cover
  end
  #--------------------------------------------------------------------------
  # ● 是否效果中？
  #--------------------------------------------------------------------------
  def effect?
    animation?
  end
end
end
