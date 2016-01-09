#encoding:utf-8
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　處理戰斗畫面的精靈的類。本類在 Scene_Battle 類的內部使用。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 初始化對象
  #--------------------------------------------------------------------------
  def initialize
    create_viewports
    create_battleback1
    create_battleback2
    create_enemies
    create_actors
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # ● 生成顯示端口
  #--------------------------------------------------------------------------
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 生成戰場背景（地面）精靈
  #--------------------------------------------------------------------------
  def create_battleback1
    @back1_sprite = Sprite.new(@viewport1)
    @back1_sprite.bitmap = battleback1_bitmap
    @back1_sprite.z = 0
    center_sprite(@back1_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 生成戰場背景（墻壁）精靈
  #--------------------------------------------------------------------------
  def create_battleback2
    @back2_sprite = Sprite.new(@viewport1)
    @back2_sprite.bitmap = battleback2_bitmap
    @back2_sprite.z = 1
    center_sprite(@back2_sprite)
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（地面）的位圖
  #--------------------------------------------------------------------------
  def battleback1_bitmap
    if battleback1_name
      Cache.battleback1(battleback1_name)
    else
      create_blurry_background_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（墻壁）的位圖
  #--------------------------------------------------------------------------
  def battleback2_bitmap
    if battleback2_name
      Cache.battleback2(battleback2_name)
    else
      Bitmap.new(1, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成由地圖畫面加工而來的戰場背景
  #--------------------------------------------------------------------------
  def create_blurry_background_bitmap
    source = SceneManager.background_bitmap
    bitmap = Bitmap.new(640, 480)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    bitmap.radial_blur(120, 16)
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（地面）的文件名
  #--------------------------------------------------------------------------
  def battleback1_name
    if $BTEST
      $data_system.battleback1_name
    elsif $game_map.battleback1_name
      $game_map.battleback1_name
    elsif $game_map.overworld?
      overworld_battleback1_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（墻壁）的文件名
  #--------------------------------------------------------------------------
  def battleback2_name
    if $BTEST
      $data_system.battleback2_name
    elsif $game_map.battleback2_name
      $game_map.battleback2_name
    elsif $game_map.overworld?
      overworld_battleback2_name
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（地面）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback1_name
    $game_player.vehicle ? ship_battleback1_name : normal_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 獲取戰場背景（墻壁）文件名
  #--------------------------------------------------------------------------
  def overworld_battleback2_name
    $game_player.vehicle ? ship_battleback2_name : normal_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通時的戰場背景（地面）文件名
  #--------------------------------------------------------------------------
  def normal_battleback1_name
    terrain_battleback1_name(autotile_type(1)) ||
    terrain_battleback1_name(autotile_type(0)) ||
    default_battleback1_name
  end
  #--------------------------------------------------------------------------
  # ● 獲取普通時的戰場背景（墻壁）文件名
  #--------------------------------------------------------------------------
  def normal_battleback2_name
    terrain_battleback2_name(autotile_type(1)) ||
    terrain_battleback2_name(autotile_type(0)) ||
    default_battleback2_name
  end
  #--------------------------------------------------------------------------
  # ● 獲取與地形對應的戰場背景（地面）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback1_name(type)
    case type
    when 24,25        # 野外
      "Wasteland"
    when 26,27        # 泥地
      "DirtField"
    when 32,33        # 沙漠
      "Desert"
    when 34           # 巖地
      "Lava1"
    when 35           # 巖地（熔巖）
      "Lava2"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取與地形對應的戰場背景（墻壁）文件名
  #--------------------------------------------------------------------------
  def terrain_battleback2_name(type)
    case type
    when 20,21        # 森林
      "Forest1"
    when 22,30,38     # 山丘
      "Cliff"
    when 24,25,26,27  # 野外、泥地
      "Wasteland"
    when 32,33        # 沙漠
      "Desert"
    when 34,35        # 巖地
      "Lava"
    when 40,41        # 雪原
      "Snowfield"
    when 42           # 云端
      "Clouds"
    when 4,5          # 毒沼
      "PoisonSwamp"
    end
  end
  #--------------------------------------------------------------------------
  # ● 獲取默認的戰場背景（地面）文件名
  #--------------------------------------------------------------------------
  def default_battleback1_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 獲取默認的戰場背景（墻壁）文件名
  #--------------------------------------------------------------------------
  def default_battleback2_name
    "Grassland"
  end
  #--------------------------------------------------------------------------
  # ● 獲取乘船時的戰場背景（地面）文件名
  #--------------------------------------------------------------------------
  def ship_battleback1_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 獲取乘船時的戰場背景（墻壁）文件名
  #--------------------------------------------------------------------------
  def ship_battleback2_name
    "Ship"
  end
  #--------------------------------------------------------------------------
  # ● 獲取角色腳下的自動原件的種類
  #--------------------------------------------------------------------------
  def autotile_type(z)
    $game_map.autotile_type($game_player.x, $game_player.y, z)
  end
  #--------------------------------------------------------------------------
  # ● 精靈居中
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 敵人精靈生成
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = $game_troop.members.reverse.collect do |enemy|
      Sprite_Battler.new(@viewport1, enemy)
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成角色精靈
  #    默認下不顯示角色的圖像。為了方便使用，敵我雙方使用共通的精靈。
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = Array.new(4) { Sprite_Battler.new(@viewport1) }
  end
  #--------------------------------------------------------------------------
  # ● 生成圖片精靈
  #    游戲開始時生成空的數組，在需要使用時才添加內容。
  #--------------------------------------------------------------------------
  def create_pictures
    @picture_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 計時器精靈生成
  #--------------------------------------------------------------------------
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    dispose_battleback1
    dispose_battleback2
    dispose_enemies
    dispose_actors
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  #--------------------------------------------------------------------------
  # ● 釋放戰場背景的精靈（地面）
  #--------------------------------------------------------------------------
  def dispose_battleback1
    @back1_sprite.bitmap.dispose
    @back1_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放戰場背景的精靈（墻壁）
  #--------------------------------------------------------------------------
  def dispose_battleback2
    @back2_sprite.bitmap.dispose
    @back2_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放敵人精靈
  #--------------------------------------------------------------------------
  def dispose_enemies
    @enemy_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 釋放角色精靈
  #--------------------------------------------------------------------------
  def dispose_actors
    @actor_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 釋放圖片精靈
  #--------------------------------------------------------------------------
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 釋放計時器精靈
  #--------------------------------------------------------------------------
  def dispose_timer
    @timer_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 釋放顯示端口
  #--------------------------------------------------------------------------
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    update_battleback1
    update_battleback2
    update_enemies
    update_actors
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # ● 更新戰場背景的精靈（地面）
  #--------------------------------------------------------------------------
  def update_battleback1
    @back1_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新戰場背景的精靈（墻壁）
  #--------------------------------------------------------------------------
  def update_battleback2
    @back2_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新敵人的精靈
  #--------------------------------------------------------------------------
  def update_enemies
    @enemy_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● 更新角色的精靈
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      sprite.battler = $game_party.members[i]
      sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新圖片精靈
  #--------------------------------------------------------------------------
  def update_pictures
    $game_troop.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新計時器精靈
  #--------------------------------------------------------------------------
  def update_timer
    @timer_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 更新顯示端口
  #--------------------------------------------------------------------------
  def update_viewports
    @viewport1.tone.set($game_troop.screen.tone)
    @viewport1.ox = $game_troop.screen.shake
    @viewport2.color.set($game_troop.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - $game_troop.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
  #--------------------------------------------------------------------------
  # ● 獲取敵人和角色的精靈
  #--------------------------------------------------------------------------
  def battler_sprites
    @enemy_sprites + @actor_sprites
  end
  #--------------------------------------------------------------------------
  # ● 判定是否動畫顯示中
  #--------------------------------------------------------------------------
  def animation?
    battler_sprites.any? {|sprite| sprite.animation? }
  end
  #--------------------------------------------------------------------------
  # ● 判定效果是否執行中
  #--------------------------------------------------------------------------
  def effect?
    battler_sprites.any? {|sprite| sprite.effect? }
  end
end
