#******************************************************************************
#
#   ＊ メッセージ履歴画面 ＊
#
#                       for RGSS3
#
#        Ver 1.00   2012.09.13
#
#   ◆使い方
#     １．▼素材セクション以下の適当な場所に導入してください。
#
#     ２．ゲーム中にコンフィグ項目で設定したボタンを押すことで、
#         メッセージ履歴画面を呼び出します。
#
#     ３．コンフィグ項目で設定したスイッチをオンにすることで、
#         メッセージ履歴の保存を一時停止することができます。
#
#     ４．操作方法
#         ・十字キーの上下で１行ずつスクロール
#         ・十字キーの左右で５行ずつスクロール
#         ・ＬＲボタンで１５行ずつスクロール
#         ・Ｂボタンで元の画面に復帰します。
#
#   提供者：睡工房　http://hime.be/
#
#******************************************************************************

#==============================================================================
# コンフィグ項目
#==============================================================================
module SUI
module LOG
  # 履歴保存のオンオフスイッチ
  # ゲームスイッチの番号を入力してください。
  SW_ONOFF = 102
  
  # 履歴保存の最大行数
  # この行数を超えた履歴は削除されます。
  MAX_ROW = 100
  
  # 選択肢を保存するか？
  SAVE_CHOICE = true
  
  # 履歴表示モードへの移行ボタン
  # :L のシンボル形式で指定して下さい。
  BTN_MODE = Input::R
  
  # 開啟的回顧的方法
  OPEN_LOG_METHOD = Kboard.method(:keyboard)
  
  #開啟回顧的鍵盤參數
  OPEN_LOG_ARGS = $R_Key_C # 鍵盤按鍵C
  
end
end
#==============================================================================
# 設定完了
#==============================================================================



class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ● 全テキストの処理
  #--------------------------------------------------------------------------
  alias sui_process_all_text process_all_text
  def process_all_text
    log = convert_escape_characters($game_message.all_text)
    SUI::LOG.push(log)
    sui_process_all_text
  end
end


class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  alias sui_make_command_list make_command_list
  def make_command_list
    sui_make_command_list
    return unless SUI::LOG::SAVE_CHOICE
    log = ""
    $game_message.choices.each do |choice|
      next if choice.empty?
      log += "　　" + choice + "\n"
    end
    return if log.empty?
    SUI::LOG.push(log)
  end
end


module SUI::LOG
  LOG = []
  #--------------------------------------------------------------------------
  # ● 履歴の追加
  #--------------------------------------------------------------------------
  def self.push(text)
    LOG.push(text)
    LOG.shift if LOG.size > MAX_ROW
  end
end

#==============================================================================
# ■ Window_MessageLog
#------------------------------------------------------------------------------
# 　メッセージ履歴を表示するウィンドウです。
#==============================================================================

class Window_MessageLog < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.z = Lctseng_Message_Face_Settings::Log_Window_Z
    self.opacity = 0
    self.active = false
    self.openness = 0
    self.padding *= 2
    @index = 0
    create_background
    open
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
    @back.bitmap.dispose
    @back.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    return if @opening || @closing
    dispose if close?
    if !self.disposed? && self.open?
      if SUI::LOG::OPEN_LOG_METHOD.call(SUI::LOG::OPEN_LOG_ARGS)
        Sound.play_cancel
        close
      elsif Input::repeat?(:UP)
        self.index = @index - 1
      elsif Input::repeat?(:DOWN)
        self.index = @index + 1
      elsif Input::repeat?(:LEFT)
        self.index = @index - 5
      elsif Input::repeat?(:RIGHT)
        self.index = @index + 5
      elsif Input::repeat?(:L)
        self.index = @index - 15
      elsif Input::repeat?(:R)
        self.index = @index + 15
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 1 ページに表示できる行数の取得
  #--------------------------------------------------------------------------
  def page_row_max
    contents_height / line_height
  end
  #--------------------------------------------------------------------------
  # ● 表示領域移動
  #--------------------------------------------------------------------------
  def index=(row)
    @index = [[row, @row_max - page_row_max + 1].min, 0].max
    self.oy = @index * line_height
  end
  #--------------------------------------------------------------------------
  # ● 背景の作成
  #--------------------------------------------------------------------------
  def create_background
    @back = Sprite.new
    @back.x = 0
    @back.y = 0
    @back.z = self.z - 1
    @back.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @back.bitmap.fill_rect(@back.bitmap.rect, Color.new(0, 0, 0, 150))
  end
  #--------------------------------------------------------------------------
  # ● ログの追加
  #--------------------------------------------------------------------------
  def push(text)
    SUI::LOG::LOG.push(text)
    SUI::LOG::LOG.shift if SUI::LOG::LOG.size > SUI::LOG::MAX_ROW
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の作成
  #--------------------------------------------------------------------------
  def create_contents2(size)
    self.contents.dispose
    self.contents = Bitmap.new(width - padding * 2, [height - padding * 2, size * line_height].max)
  end
  #--------------------------------------------------------------------------
  # ● 特殊文字の変換
  #--------------------------------------------------------------------------
  def convert_special_characters(text)
    text.gsub!(/\e.\[.+\]/)        { "" }
    text.gsub!(/\e./)              { "" }
    text
  end
  #--------------------------------------------------------------------------
  # ● ログの描画
  #--------------------------------------------------------------------------
  def refresh
    y = 0
    texts = []
    for i in 0...SUI::LOG::LOG.size
      texts.push("") if i > 0
      texts.concat(SUI::LOG::LOG[i].split("\n"))
    end
    create_contents2(texts.size)
    for i in 0...texts.size
      text = convert_special_characters(texts[i])
      self.contents.draw_text(0, y, self.width - padding * 2, line_height, text)
      y += line_height
    end
    @row_max = texts.size
    self.index = texts.size
  end
end


class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias sui_update update
  def update
    if @window_log
      update_message_log
    elsif SUI::LOG::OPEN_LOG_METHOD.call(SUI::LOG::OPEN_LOG_ARGS)#Input.trigger?(SUI::LOG::BTN_MODE)
      @window_log = Window_MessageLog.new
      update_message_log
    else
      sui_update
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ履歴更新
  #--------------------------------------------------------------------------
  def update_message_log
    Graphics.update
    Input.update
    @window_log.update
    @window_log = nil if @window_log.disposed?
  end
end