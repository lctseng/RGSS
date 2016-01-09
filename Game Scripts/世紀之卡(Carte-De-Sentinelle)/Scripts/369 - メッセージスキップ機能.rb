#==============================================================================
# ■ RGSS3 メッセージスキップ機能 Ver1.01 by 星潟
#------------------------------------------------------------------------------
# メッセージウィンドウに表示された文章を一気に読み飛ばします。
# テストモード限定化機能と、特定のスイッチがONの時だけ
# メッセージスキップを有効にする機能も併せて持っています。
#------------------------------------------------------------------------------
# Ver1.01 入力待ち無視（\^）が無効になる不具合を修正しました。
#============================================================================== 
module M_SKIP
  
  #メッセージスキップの効果をテストモードに限定するか？
  #trueでテストモード限定、falseで常時
  
  T_LIMT = true
  
  #メッセージスキップ有効化スイッチIDの設定。
  #0にするとスイッチによる判定は消滅。
  #1以上にすると、そのスイッチがONの時のみメッセージスキップ有効。
  
  SWITID = 0
  
  #メッセージスキップに使用するキーの設定。
  #文字送りキーとしても機能します。
  #nilにするとメッセージスキップ機能全てを無効化。
  
  KEY    = :CTRL
  
end
class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_mb update
  def update
    if skip_execute
      @pause_skip = true
      @show_fast = true
    end
    update_mb
  end
  #--------------------------------------------------------------------------
  # ● スキップ判定
  #--------------------------------------------------------------------------
  def skip_execute
    if M_SKIP::T_LIMT
      unless $TEST or $BTEST
        return false
      end
    end
    if M_SKIP::SWITID != 0
      return false unless $game_switches[M_SKIP::SWITID]
    end
    return false unless Input.press?(M_SKIP::KEY)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 入力処理
  #--------------------------------------------------------------------------
  def process_input
    if $game_message.choice?
      input_choice
    elsif $game_message.num_input?
      input_number
    elsif $game_message.item_choice?
      input_item
    else
      input_pause unless @pause_skip or skip_execute
    end
  end
  #--------------------------------------------------------------------------
  # ● 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    if M_SKIP::KEY == nil
      Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
    else
      if M_SKIP::T_LIMT == true
        if $TEST or $BTEST
          Fiber.yield until (Input.trigger?(:B) || Input.trigger?(:C) || Input.press?(M_SKIP::KEY) ) &&!$game_system.disable_message_continue
        else
          Fiber.yield until (Input.trigger?(:B) || Input.trigger?(:C))&&!$game_system.disable_message_continue
        end
      else
        Fiber.yield until (Input.trigger?(:B) || Input.trigger?(:C) || Input.press?(M_SKIP::KEY))&&!$game_system.disable_message_continue
      end
    end
    Input.update
    self.pause = false
  end
end