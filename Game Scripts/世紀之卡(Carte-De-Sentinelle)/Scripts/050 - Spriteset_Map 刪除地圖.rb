#~ #encoding:utf-8
#~ #==============================================================================
#~ # ■ Spriteset_Map
#~ #------------------------------------------------------------------------------
#~ # 　處理地圖畫面精靈和圖塊的類。本類在 Scene_Map 類的內部使用。
#~ #==============================================================================

#~ class Spriteset_Map
#~   #--------------------------------------------------------------------------
#~   # ● 初始化對象
#~   #--------------------------------------------------------------------------
#~   def initialize
#~     create_viewports
#~     create_parallax
#~     create_characters
#~     create_shadow
#~     create_weather
#~     create_pictures
#~     create_timer
#~     update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成顯示端口
#~   #--------------------------------------------------------------------------
#~   def create_viewports
#~     @viewport1 = Viewport.new
#~     @viewport2 = Viewport.new
#~     @viewport3 = Viewport.new
#~     @viewport2.z = 50
#~     @viewport3.z = 100
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 讀取圖塊地圖
#~   #--------------------------------------------------------------------------
#~   def create_tilemap
#~     @tilemap = Tilemap.new(@viewport1)
#~     @tilemap.map_data = $game_map.data
#~     load_tileset
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 讀取圖塊組
#~   #--------------------------------------------------------------------------
#~   def load_tileset
#~     @tileset = $game_map.tileset
#~     @tileset.tileset_names.each_with_index do |name, i|
#~       #@tilemap.bitmaps[i] = Cache.tileset(name)
#~     end
#~     #@tilemap.flags = @tileset.flags
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成遠景圖
#~   #--------------------------------------------------------------------------
#~   def create_parallax
#~     @parallax = Plane.new(@viewport1)
#~     @parallax.z = -100
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成人物精靈
#~   #--------------------------------------------------------------------------
#~   def create_characters
#~     @character_sprites = []
#~     $game_map.events.values.each do |event|
#~       @character_sprites.push(Sprite_Character.new(@viewport1, event))
#~     end
#~     $game_map.vehicles.each do |vehicle|
#~       @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
#~     end
#~     $game_player.followers.reverse_each do |follower|
#~       @character_sprites.push(Sprite_Character.new(@viewport1, follower))
#~     end
#~     @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
#~     @map_id = $game_map.map_id
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成飛艇影子
#~   #--------------------------------------------------------------------------
#~   def create_shadow
#~     @shadow_sprite = Sprite.new(@viewport1)
#~     @shadow_sprite.bitmap = Cache.system("Shadow")
#~     @shadow_sprite.ox = @shadow_sprite.bitmap.width / 2
#~     @shadow_sprite.oy = @shadow_sprite.bitmap.height
#~     @shadow_sprite.z = 180
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成天氣
#~   #--------------------------------------------------------------------------
#~   def create_weather
#~     @weather = Spriteset_Weather.new(@viewport2)
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成圖片精靈
#~   #--------------------------------------------------------------------------
#~   def create_pictures
#~     @picture_sprites = []
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 生成計時器精靈
#~   #--------------------------------------------------------------------------
#~   def create_timer
#~     @timer_sprite = Sprite_Timer.new(@viewport2)
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放
#~   #--------------------------------------------------------------------------
#~   def dispose
#~     dispose_parallax
#~     dispose_characters
#~     dispose_shadow
#~     dispose_weather
#~     dispose_pictures
#~     dispose_timer
#~     dispose_viewports
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放地圖圖塊
#~   #--------------------------------------------------------------------------
#~   def dispose_tilemap
#~     @tilemap.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放遠景圖
#~   #--------------------------------------------------------------------------
#~   def dispose_parallax
#~     @parallax.bitmap.dispose if @parallax.bitmap
#~     @parallax.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放人物精靈
#~   #--------------------------------------------------------------------------
#~   def dispose_characters
#~     @character_sprites.each {|sprite| sprite.dispose }
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放飛艇影子
#~   #--------------------------------------------------------------------------
#~   def dispose_shadow
#~     @shadow_sprite.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放天氣
#~   #--------------------------------------------------------------------------
#~   def dispose_weather
#~     @weather.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放圖片精靈
#~   #--------------------------------------------------------------------------
#~   def dispose_pictures
#~     @picture_sprites.compact.each {|sprite| sprite.dispose }
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放計時器精靈
#~   #--------------------------------------------------------------------------
#~   def dispose_timer
#~     @timer_sprite.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 釋放顯示端口
#~   #--------------------------------------------------------------------------
#~   def dispose_viewports
#~     @viewport1.dispose
#~     @viewport2.dispose
#~     @viewport3.dispose
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新人物
#~   #--------------------------------------------------------------------------
#~   def refresh_characters
#~     dispose_characters
#~     create_characters
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新畫面
#~   #--------------------------------------------------------------------------
#~   def update
#~     update_tileset
#~     update_parallax
#~     update_characters
#~     update_shadow
#~     update_weather
#~     update_pictures
#~     update_timer
#~     update_viewports
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 監視圖塊組是否需要被切換
#~   #--------------------------------------------------------------------------
#~   def update_tileset
#~     if @tileset != $game_map.tileset
#~       load_tileset
#~       refresh_characters
#~     end
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新地圖圖塊
#~   #--------------------------------------------------------------------------
#~   def update_tilemap
#~     @tilemap.map_data = $game_map.data
#~     @tilemap.ox = $game_map.display_x * 32
#~     @tilemap.oy = $game_map.display_y * 32
#~     @tilemap.update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新遠景圖
#~   #--------------------------------------------------------------------------
#~   def update_parallax
#~     if @parallax_name != $game_map.parallax_name
#~       @parallax_name = $game_map.parallax_name
#~       @parallax.bitmap.dispose if @parallax.bitmap
#~       @parallax.bitmap = Cache.parallax(@parallax_name)
#~       Graphics.frame_reset
#~     end
#~     @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
#~     @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新人物精靈
#~   #--------------------------------------------------------------------------
#~   def update_characters
#~     refresh_characters if @map_id != $game_map.map_id
#~     @character_sprites.each {|sprite| sprite.update }
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新飛艇影子
#~   #--------------------------------------------------------------------------
#~   def update_shadow
#~     airship = $game_map.airship
#~     @shadow_sprite.x = airship.screen_x
#~     @shadow_sprite.y = airship.screen_y + airship.altitude
#~     @shadow_sprite.opacity = airship.altitude * 8
#~     @shadow_sprite.update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新天氣
#~   #--------------------------------------------------------------------------
#~   def update_weather
#~     @weather.type = $game_map.screen.weather_type
#~     @weather.power = $game_map.screen.weather_power
#~     @weather.ox = $game_map.display_x * 32
#~     @weather.oy = $game_map.display_y * 32
#~     @weather.update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新圖片精靈
#~   #--------------------------------------------------------------------------
#~   def update_pictures
#~     $game_map.screen.pictures.each do |pic|
#~       @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
#~       @picture_sprites[pic.number].update
#~     end
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新計時器精靈
#~   #--------------------------------------------------------------------------
#~   def update_timer
#~     @timer_sprite.update
#~   end
#~   #--------------------------------------------------------------------------
#~   # ● 更新顯示端口
#~   #--------------------------------------------------------------------------
#~   def update_viewports
#~     @viewport1.tone.set($game_map.screen.tone)
#~     @viewport1.ox = $game_map.screen.shake
#~     @viewport2.color.set($game_map.screen.flash_color)
#~     @viewport3.color.set(0, 0, 0, 255 - $game_map.screen.brightness)
#~     @viewport1.update
#~     @viewport2.update
#~     @viewport3.update
#~   end
#~ end
