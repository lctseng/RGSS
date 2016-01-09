#encoding:utf-8
#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
#  定義常用語和信息。將部分資料定義為常量。用語部分來自于 $data_system 。
#==============================================================================

module Vocab

  # 商店畫面
  ShopBuy         = "買入"
  ShopSell        = "賣出"
  ShopCancel      = "取消"
  Possession      = "持有數"

  # 狀態畫面
  ExpTotal        = "目前經驗"
  ExpNext         = "下一%s"

  # 存檔／讀檔畫面
  SaveMessage     = "在哪個位置儲存存檔？"
  LoadMessage     = "讀取哪個位置的存檔？"
  File            = "儲存"

  # 有多個隊友時顯示
  PartyName       = "%s的隊伍"
  
  # 戰斗基本信息
  Emerge          = "%s出現了！"
  Preemptive      = "%s先制攻擊！"
  Surprise        = "%s被偷襲了！"
  EscapeStart     = "%s準備逃走！"
  EscapeFailure   = "逃走失敗了……"

  # 戰斗結束信息
  Victory         = "%s勝利！"
  Defeat          = "%s全滅……"
  ObtainExp       = "獲得了%s點經驗值！"
  ObtainGold      = "獲得了%s\\G！"
  ObtainItem      = "獲得了%s！"
  LevelUp         = "%s已經%s%s了！"
  ObtainSkill     = "習得%s！"

  # 物品使用
  UseItem         = "%s使用了%s！"

  # 關鍵一擊
  CriticalToEnemy = "會心一擊！"
  CriticalToActor = "痛恨一擊！"

  # 角色對象的行動結果
  ActorDamage     = "%s受到了%s點的傷害！"
  ActorRecovery   = "%s的%s恢復了%s點！"
  ActorGain       = "%s的%s恢復了%s點！"
  ActorLoss       = "%s的%s失去了%s點！"
  ActorDrain      = "%s的%s被奪走了%s點！"
  ActorNoDamage   = "%s沒有受到傷害！"
  ActorNoHit      = "空振！%s毫發無傷！"

  # 敵人對象的行動結果
  EnemyDamage     = "%s受到了%s點的傷害！"
  EnemyRecovery   = "%s的%s恢復了%s點！"
  EnemyGain       = "%s的%s恢復了%s點！"
  EnemyLoss       = "%s的%s失去了%s點！"
  EnemyDrain      = "%s的%s被奪走了%s點！"
  EnemyNoDamage   = "%s沒有受到傷害！"
  EnemyNoHit      = "空振！%s毫發無傷！"

  # 回避／反射
  Evasion         = "%s躲開了攻擊！"
  MagicEvasion    = "%s抵消了魔法效果！"
  MagicReflection = "%s反射了魔法效果！"
  CounterAttack   = "%s進行反擊！"
  Substitute      = "%s代替%s承受了攻擊！"

  # 能力強化／弱化
  BuffAdd         = "%s的%s上升了！"
  DebuffAdd       = "%s的%s下降了！"
  BuffRemove      = "%s的%s恢復了！"

  # 技能或物品的使用無效時
  ActionFailure   = "對%s無效！"

  # 出錯時的信息
  PlayerPosError  = "沒有設置玩家的初始位置。"
  EventOverflow   = "調用的公共事件超過上限。"

  # 基本狀態
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 裝備類型
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # 指令
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 貨幣單位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # 等級
  def self.level_a;     basic(1);     end   # 等級(縮寫)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP(縮寫)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP(縮寫)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP(縮寫)
  def self.fight;       command(0);   end   # 戰斗
  def self.escape;      command(1);   end   # 撤退
  def self.attack;      command(2);   end   # 攻擊
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # 物品
  def self.skill;       command(5);   end   # 技能
  def self.equip;       command(6);   end   # 裝備
  def self.status;      command(7);   end   # 狀態
  def self.formation;   command(8);   end   # 整隊
  def self.save;        command(9);   end   # 存檔
  def self.game_end;    command(10);  end   # 結束游戲
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 護甲
  def self.key_item;    command(14);  end   # 貴重物品
  def self.equip2;      command(15);  end   # 更換裝備
  def self.optimize;    command(16);  end   # 最強裝備
  def self.clear;       command(17);  end   # 全部卸下
  def self.new_game;    command(18);  end   # 開始游戲
  def self.continue;    command(19);  end   # 繼續游戲
  def self.shutdown;    command(20);  end   # 退出游戲
  def self.to_title;    command(21);  end   # 返回標題
  def self.cancel;      command(22);  end   # 取消
  #--------------------------------------------------------------------------
end
