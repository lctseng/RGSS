module CardBattle
  #--------------------------------------------------------------------------
  # ● 一般設定
  #--------------------------------------------------------------------------
  ## 存放角色路線的變數
  VARIABLE_STORY = 20
  
  
  ## 存放角色ID的變數
  VARIABLE_ACTOR = 10
  ## 存放敵人ID
  VARIABLE_ENEMY = 11
  
  ## 戰鬥暫存檔的存檔位置
  BATTLE_SAVE_INDEX = 98
  
  ## 鎖定角色開關
  LOCK_ACTOR_SWITCH = 11
  
  # 最大出戰卡片數
  MAX_CARD_NUMBER = 180
  
  # 最小出戰卡片數
  MIN_CARD_NUMBER = 60
  
  # 魔法型技能防禦累積最大回合數
  MAGIC_ATTACK_MAX_DEFEND_TIME = 3
  
  #--------------------------------------------------------------------------
  # ● 座標位置大小
  #--------------------------------------------------------------------------
  
  ## 卡片半寬度
  CARD_HALF_WIDTH = 30
  ## 卡片半高度
  CARD_HALF_HEIGHT = 40
  
  
  ## 玩家卡牌預備X座標起點
  PLAYER_CARD_PREPARE_X = 174 + CARD_HALF_WIDTH
  ## 玩家卡牌預備X座標間隔
  PLAYER_CARD_PREPARE_X_INTERVAL = 76
  ## 玩家卡牌預備Y座標
  PLAYER_CARD_PREPARE_Y = 396 + CARD_HALF_HEIGHT
  
  ## 敵人卡牌預備X座標起點
  ENEMY_CARD_PREPARE_X = 24 + CARD_HALF_WIDTH
  ## 敵人卡牌預備X座標間隔
  ENEMY_CARD_PREPARE_X_INTERVAL = 76
  ## 敵人卡牌預備Y座標
  ENEMY_CARD_PREPARE_Y = 9 + CARD_HALF_HEIGHT
  
  
  ## 玩家卡選擇移動的位置差
  PLAYER_CARD_SELECT_SHIFT_X = 25
  PLAYER_CARD_SELECT_SHIFT_Y = 115
  
  ## 敵人卡選擇移動的位置差
  ENEMY_CARD_SELECT_SHIFT_X = 10
  ENEMY_CARD_SELECT_SHIFT_Y = 110
  
  # 玩家已選卡的位置
  PLAYER_SELECTED_CARD_POS_X = [150,225,304,383,460,540]
  PLAYER_SELECTED_CARD_POS_Y = 286
  
  # 敵人已選卡的位置
  ENEMY_SELECTED_CARD_POS_X = [33,108,189,267,345,424]
  ENEMY_SELECTED_CARD_POS_Y = 116
  
  # 玩家生命精靈位置
  PLAYER_HP_NUMBER_POS_X = 37
  PLAYER_HP_NUMBER_POS_Y = 449
  
  # 敵人生命精靈位置
  ENEMY_HP_NUMBER_POS_X = 489
  ENEMY_HP_NUMBER_POS_Y = 1
  
  # 攤牌效果動畫ID
  UNCOVER_CARD_ANIMATION_ID = 113
  
  # 總和數值精靈位置
  # 玩家
  PLAYER_SUM_NUMBER_POS_X = 140
  PLAYER_SUM_NUMBER_POS_Y = 240
  # 敵人
  ENEMY_SUM_NUMBER_POS_X = 30
  ENEMY_SUM_NUMBER_POS_Y = 160
  
  # 總和數值顯示動畫
  SUM_SHOW_ANIMATION_ID = 117
  # 總和數值隱藏動畫
  SUM_HIDE_ANIMATION_ID = 118
  # 總和數值隱藏時間
  SUM_HIDE_TIME = 30
  
  # 攻擊數字字型
  
  temp_font = Font.new 
  temp_font.name = 'Microsoft JhengHei' #字體名稱
  temp_font.size = 56 #字體大小
  temp_font.color = (Color.new(255,0,0,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  temp_font.bold = true #是否粗體字
  temp_font.italic = false #是否斜體字
  temp_font.outline = true #是否繪製文字邊緣
  temp_font.shadow = true #是否繪製陰影
  temp_font.out_color = (Color.new(255,255,255,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)
  ATTACK_SUM_FONT = temp_font
  temp_font = nil
  
  # 防禦數字字型
  DEFEND_SUM_FONT = ATTACK_SUM_FONT.clone
  DEFEND_SUM_FONT.color = (Color.new(0,0,255,255)) 
  # 技能數字字型
  SKILL_SUM_FONT = ATTACK_SUM_FONT.clone
  SKILL_SUM_FONT.color = (Color.new(255,201,14,255)) 

  
  # 生命值字型
  
  BATTLE_HP_FONT = Font.new 
  BATTLE_HP_FONT.name = 'Microsoft JhengHei' #字體名稱
  BATTLE_HP_FONT.size = 24 #字體大小
  BATTLE_HP_FONT.color = (Color.new(255,255,255,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  BATTLE_HP_FONT.bold = true #是否粗體字
  BATTLE_HP_FONT.italic = false #是否斜體字
  BATTLE_HP_FONT.outline = true #是否繪製文字邊緣
  BATTLE_HP_FONT.shadow = true #是否繪製陰影
  BATTLE_HP_FONT.out_color = (Color.new(50,99,69,255)) #文字邊緣顏色(RGB，紅色、綠色、藍色、不透明度)

  # 計數器數字字型
  temp_font = Font.new 
  temp_font.name = 'Microsoft JhengHei' #字體名稱
  temp_font.size = 24 #字體大小
  temp_font.color = (Color.new(255,255,255,255)) #字體內容顏色(RGB，紅色、綠色、藍色、不透明度)
  temp_font.bold = false #是否粗體字
  temp_font.italic = false #是否斜體字
  temp_font.outline = false #是否繪製文字邊緣
  temp_font.shadow = false #是否繪製陰影
  BATTLE_COUNTER_FONT = temp_font
  temp_font = nil  
  
  
  # Cut-in 效果
  ULT_PICTURE_FLY_TIME = 20 # 飛入時間
  ULT_PICTURE_STOP_TIME = 30 # 停止時間
  ULT_PICTURE_FLY_OUT_TIME = 20 # 飛出時間

  
  # 角色框架位置
  PLAYER_BATTLE_FRAME_POS_X = 0
  PLAYER_BATTLE_FRAME_POS_Y = Graphics.height - 203

  
  ENEMY_BATTLE_FRAME_POS_X = Graphics.width - 171
  ENEMY_BATTLE_FRAME_POS_Y = 0
  
  # 模式精靈位置
  PLAYER_BATTLE_MODE_POS_X = 0
  PLAYER_BATTLE_MODE_POS_Y = Graphics.height - 129

  ENEMY_BATTLE_MODE_POS_X = Graphics.width - 148
  ENEMY_BATTLE_MODE_POS_Y = 0
  
  # 肖像精靈位置
  PLAYER_BATTLE_PORTRAIT_POS_X = 0
  PLAYER_BATTLE_PORTRAIT_POS_Y = Graphics.height

  ENEMY_BATTLE_PORTRAIT_POS_X = Graphics.width
  ENEMY_BATTLE_PORTRAIT_POS_Y = 0

  # 計數器位置
  PLAYER_COUNTER_BALL_POS = [113,367]
  ENEMY_COUNTER_BALL_POS = [505,105]
  
  # 保留卡移動到定位的時間
  BATTLE_RESERVE_SLIDE_TIME = 30
  # 卡片淡出並清除的時間
  BATTLE_CARD_FADING_TIME = 30
  # 玩家發卡時間
  BATTLE_PLAYER_DELIVER_TIME = 30
  # 敵人發卡時間
  BATTLE_ENEMY_DELIVER_TIME = 30
  # 自動選牌時，移動到出牌區的時間
  BATTLE_AUTO_MOVE_TO_READY_TIME = 20
  # 重抽的基礎時間
  BATTLE_REDRAW_TIME_BASE = 30
  # 重抽的隨機時間
  BATTLE_REDRAW_TIME_RANDOM = 25
  # 交換時間
  BATTLE_EXCHANGE_TIME = 60
  # 交換基礎時間
  BATTLE_EXCHANGE_TIME_BASE = 30
  # 交換隨機時間
  BATTLE_EXCHANGE_TIME_RANDOM = 25
  # 按鈕淡入時間
  BATTLE_BUTTON_FADE_TIME = 15
  # 卡片使用淡出時間
  BATTLE_CARD_USE_FADE_TIME = 30
  # 重抽淡出時間
  BATTLE_REDRAW_BUTTON_FADE_TIME = 60
  # 選牌移動時間
  BATTLE_SELECT_CARD_SLIDE_TIME = 10
  # 選擇模式時，按鈕淡入時間
  BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME = 15
  # 選擇模式時，按鈕淡出時間
  BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME = 10
  # 選擇模式中，白霧淡入時間
  BATTLE_MODE_SELECT_FOG_FADEIN_TIME = 10
  # 選擇模式中，白霧淡出時間
  BATTLE_MODE_SELECT_FOG_FADEOUT_TIME = 15
  # 選擇模式中，取消選擇時，白霧淡出時間
  BATTLE_MODE_SELECT_CANCEL_FOG_FADEOUT_TIME = 30
  # 選擇模式中，背景淡入時間
  BATTLE_MODE_SELECT_BG_FADEIN_TIME = 10
  # 選擇模式中，背景淡出時間
  BATTLE_MODE_SELECT_BG_FADEOUT_TIME = 10
  # 選擇模式中，確認提示淡入時間
  BATTLE_MODE_SELECT_CONFIRM_FADEIN_TIME = 15
  # 選擇模式中，確認提示淡出時間
  BATTLE_MODE_SELECT_CONFIRM_FADEOUT_TIME = 15
  # 選擇模式中，確認按鈕淡入時間
  BATTLE_MODE_SELECT_BUTTON_FADEIN_TIME = 10
  # 選擇模式中，確認按鈕淡出時間
  BATTLE_MODE_SELECT_BUTTON_FADEOUT_TIME = 10



  #-------------戰鬥失敗-----------------#
  
  # 失敗覆蓋的存續時間
  LOSE_COVER_TIME = 600
  # 最快可以按鍵的時間 (倒數，越小越久)
  LOSE_LEAST_WAIT_TIME = LOSE_COVER_TIME - 60
  # 快轉的處理時間
  LOSE_FAST_FORWARD_TIME = 60
  # 閃爍間隔
  LOSE_CMD_FLASH_INTERVAL = 60
  # 被選擇的閃爍間隔
  LOSE_CMD_SELECT_INTERVAL = 30
  
  
  
  #-------------戰鬥勝利-----------------#
  # 最低等待時間
  WIN_LEAST_WAIT_TIME = 180
  # 基底準備時間
  WIN_BASE_PREPARE_TIME = 60
  # 過關文字出現時間
  WIN_CLEAR_TEXT_TIME = 120
  # 過關文字校過時間
  WIN_CLEAR_EFFECT_TIME = 20

  
  #--------------------------------------------------------------------------
  # ● 取得卡片的位置 
  #--------------------------------------------------------------------------
  # 玩家
  # 已出卡位置
  def self.player_selected_pos(index)
    return [PLAYER_SELECTED_CARD_POS_X[index] + CARD_HALF_WIDTH,PLAYER_SELECTED_CARD_POS_Y + CARD_HALF_HEIGHT]
  end
  # 預備牌位置
  def self.player_prepare_pos(index)
    [PLAYER_CARD_PREPARE_X+index * PLAYER_CARD_PREPARE_X_INTERVAL,PLAYER_CARD_PREPARE_Y]
  end
  # 敵人
  # 已出卡位置
  def self.enemy_selected_pos(index)
    return [ENEMY_SELECTED_CARD_POS_X[index] + CARD_HALF_WIDTH,ENEMY_SELECTED_CARD_POS_Y + CARD_HALF_HEIGHT]
  end
  # 預備牌位置
  def self.enemy_prepare_pos(index)
    [ENEMY_CARD_PREPARE_X+index * ENEMY_CARD_PREPARE_X_INTERVAL,ENEMY_CARD_PREPARE_Y]
  end
  
  #--------------------------------------------------------------------------
  # ● 當前角色ID
  #--------------------------------------------------------------------------
  def self.current_actor_id(index)
    ($game_variables[VARIABLE_STORY] - 1) * 2 + 1 + index
  end
  #--------------------------------------------------------------------------
  # ● 角色使否鎖定
  #--------------------------------------------------------------------------
  def self.actor_locked?
    return $game_switches[LOCK_ACTOR_SWITCH]
  end
  #--------------------------------------------------------------------------
  # ● 角色ID對應的index
  #--------------------------------------------------------------------------
  def self.actor_id_to_index(id)
    id - (($game_variables[VARIABLE_STORY] - 1) * 2 + 1 )
  end
  #--------------------------------------------------------------------------
  # ● 取得角色ID(從變數)
  #--------------------------------------------------------------------------
  def self.var_actor_id
    return $game_variables[VARIABLE_ACTOR]
  end
  #--------------------------------------------------------------------------
  # ● 取得角色index(從變數)
  #--------------------------------------------------------------------------
  def self.var_actor_index
    actor_id_to_index(var_actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 取得當前故事的角色ID
  #--------------------------------------------------------------------------
  def self.story_actor_ids
    _end = ($game_variables[VARIABLE_STORY]  * 2  )
    return [_end,_end-1]
  end
  #--------------------------------------------------------------------------
  # ● 取得卡片頁索引
  #--------------------------------------------------------------------------
  def self.card_page_index
    @card_page_index ||= 0
  end
  #--------------------------------------------------------------------------
  # ● 設置卡片頁索引
  #--------------------------------------------------------------------------
  def self.card_page_index=(val)
    @card_page_index = val
  end
  #--------------------------------------------------------------------------
  # ● 取得敵人ID
  #--------------------------------------------------------------------------
  def self.enemy_id
    $game_variables[VARIABLE_ENEMY]
  end
end
