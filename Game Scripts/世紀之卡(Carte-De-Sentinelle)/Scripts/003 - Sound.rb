#encoding:utf-8
#==============================================================================
# ■ Sound
#------------------------------------------------------------------------------
#  本模塊用于播放聲效。會自動獲取并並播放數據庫中 $data_system 設置好的聲效。
#==============================================================================

module Sound

  # 系統聲音
  def self.play_system_sound(n)
    $data_system.sounds[n].play
  end

  # 光標移動
  def self.play_cursor
    play_system_sound(0)
  end

  # 確定
  def self.play_ok
    play_system_sound(1)
  end

  # 取消
  def self.play_cancel
    play_system_sound(2)
  end

  # 無效
  def self.play_buzzer
    play_system_sound(3)
  end

  # 裝備
  def self.play_equip
    play_system_sound(4)
  end

  # 存檔
  def self.play_save
    play_system_sound(5)
  end

  # 讀檔
  def self.play_load
    play_system_sound(6)
  end

  # 戰斗開始
  def self.play_battle_start
    play_system_sound(7)
  end

  # 撤退
  def self.play_escape
    play_system_sound(8)
  end

  # 敵人普通攻擊
  def self.play_enemy_attack
    play_system_sound(9)
  end

  # 敵人受到傷害
  def self.play_enemy_damage
    play_system_sound(10)
  end

  # 敵人被消滅
  def self.play_enemy_collapse
    play_system_sound(11)
  end

  # 首領被消滅 1
  def self.play_boss_collapse1
    play_system_sound(12)
  end

  # 首領被消滅 2
  def self.play_boss_collapse2
    play_system_sound(13)
  end

  # 隊友受到傷害
  def self.play_actor_damage
    play_system_sound(14)
  end

  # 隊友無法戰斗
  def self.play_actor_collapse
    play_system_sound(15)
  end

  # 恢復
  def self.play_recovery
    play_system_sound(16)
  end

  # 落空
  def self.play_miss
    play_system_sound(17)
  end

  # 閃避普通攻擊
  def self.play_evasion
    play_system_sound(18)
  end

  # 閃避魔法攻擊
  def self.play_magic_evasion
    play_system_sound(19)
  end

  # 反射魔法攻擊
  def self.play_reflection
    play_system_sound(20)
  end

  # 商店
  def self.play_shop
    play_system_sound(21)
  end

  # 使用物品
  def self.play_use_item
    play_system_sound(22)
  end

  # 使用技能
  def self.play_use_skill
    play_system_sound(23)
  end

end
