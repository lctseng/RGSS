#~ =begin
#~ #===============================================================================
#~  Title: Unlimited Resolution
#~  Date: Oct 24, 2013
#~ --------------------------------------------------------------------------------
#~  ** Change log
#~  Nov 6, 2013
#~    - added some plane modifications to fix parallax images
#~  Oct 24, 2013
#~    - Initial release
#~ --------------------------------------------------------------------------------   
#~  ** Terms of Use
#~  * Free
#~ --------------------------------------------------------------------------------
#~  ** Description
#~  
#~  This script modifies Graphics.resize_screen to overcome the 640x480 limitation.
#~  It also includes some code to properly display maps that are smaller than the
#~  screen size.
#~  
#~  Now you can have arbitrarily large game resolutions.
#~  
#~ --------------------------------------------------------------------------------
#~  ** Installation
#~  
#~  You should place this script above all custom scripts
#~  
#~ --------------------------------------------------------------------------------
#~  ** Usage

#~  As usual, simply resize your screen using the script call
#~  
#~    Graphics.resize_screen(width, height)

#~ --------------------------------------------------------------------------------
#~  ** Credits
#~  
#~  Unknown author for overcoming the 640x480 limitation
#~  Lantier, from RMW forums for posting the snippet above
#~  Esrever for handling the viewport
#~  Jet, for the custom Graphics code

#~ #===============================================================================
#~ =end
#~ $imported = {} if $imported.nil?
#~ $imported["TH_UnlimitedResolution"] = true
#~ #===============================================================================
#~ # ** Configuration
#~ #===============================================================================
#~ class << SceneManager
#~   
#~   alias resolution_run run
#~   def run(*args, &block)
#~     Graphics.ensure_sprite
#~     resolution_run(*args, &block)
#~   end
#~ end

#~ module Graphics
#~   
#~   @@super_sprite = Sprite.new
#~   @@super_sprite.z = (2 ** (0.size * 8 - 2) - 1)
#~   
#~   class << self
#~     alias :th_large_screen_resize_screen :resize_screen
#~     
#~     def freeze(*args, &block)
#~       @@super_sprite.bitmap = snap_to_bitmap
#~     end
#~     
#~     def transition(time = 10, filename = nil, vague = nil)
#~       if filename
#~         @@super_sprite.bitmap = Bitmap.new(filename)
#~       end
#~       @@super_sprite.opacity = 255
#~       incs = 255.0 / time
#~       time.times do |i|
#~         @@super_sprite.opacity = 255.0 - incs * i
#~         Graphics.wait(1)
#~       end
#~       @@super_sprite.bitmap.dispose if @@super_sprite.bitmap
#~       reform_sprite_bitmap
#~       Graphics.brightness = 255
#~     end
#~     
#~     def reform_sprite_bitmap
#~       @@super_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
#~       @@super_sprite.bitmap.fill_rect(@@super_sprite.bitmap.rect, Color.new(0, 0, 0, 255))
#~     end
#~     
#~     def fadeout(frames)
#~       incs = 255.0 / frames
#~       frames.times do |i|
#~         i += 1
#~         Graphics.brightness = 255 - incs * i
#~         Graphics.wait(1)
#~       end
#~     end
#~     
#~     def fadein(frames)
#~       incs = 255.0 / frames
#~       frames.times do |i|
#~         Graphics.brightness = incs * i
#~         Graphics.wait(1)
#~       end
#~     end

#~     def brightness=(i)
#~       @@super_sprite.opacity = 255.0 - i
#~     end
#~     
#~     def brightness
#~       255 - @@super_sprite.opacity
#~     end
#~     
#~     def ensure_sprite
#~       if @@super_sprite.disposed?
#~         @@super_sprite = Sprite.new
#~         @@super_sprite.z = (2 ** (0.size * 8 - 2) - 1)
#~         reform_sprite_bitmap
#~       end
#~     end
#~   end
#~   
#~   #-----------------------------------------------------------------------------
#~   # Unknown Scripter. Copied from http://pastebin.com/sM2MNJZj 
#~   #-----------------------------------------------------------------------------
#~   def self.resize_screen(width, height)
#~     wt, ht = width.divmod(32), height.divmod(32)
#~     #wt.last + ht.last == 0 || fail('Incorrect width or height')
#~     wh = -> w, h, off = 0 { [w + off, h + off].pack('l2').scan /.{4}/ }
#~     w, h = wh.(width, height)
#~     ww, hh = wh.(width, height, 32)
#~     www, hhh = wh.(wt.first.succ, ht.first.succ)
#~     base = 0x10000000  # fixed?
#~     mod = -> adr, val { DL::CPtr.new(base + adr)[0, val.size] = val }
#~     mod.(0x195F, "\x90" * 5)  # ???
#~     mod.(0x19A4, h)
#~     mod.(0x19A9, w)
#~     mod.(0x1A56, h)
#~     mod.(0x1A5B, w)
#~     mod.(0x20F6, w)
#~     mod.(0x20FF, w)
#~     mod.(0x2106, h)
#~     mod.(0x210F, h)
#~     # speed up y?
#~     #mod.(0x1C5E3, h)
#~     #mod.(0x1C5E8, w)
#~     zero = [0].pack ?l
#~     mod.(0x1C5E3, zero)
#~     mod.(0x1C5E8, zero)
#~     mod.(0x1F477, h)
#~     mod.(0x1F47C, w)
#~     mod.(0x211FF, hh)
#~     mod.(0x21204, ww)
#~     mod.(0x21D7D, hhh[0])
#~     mod.(0x21E01, www[0])
#~     mod.(0x10DEA8, h)
#~     mod.(0x10DEAD, w)
#~     mod.(0x10DEDF, h)
#~     mod.(0x10DEF0, w)
#~     mod.(0x10DF14, h)
#~     mod.(0x10DF18, w)
#~     mod.(0x10DF48, h)
#~     mod.(0x10DF4C, w)
#~     mod.(0x10E6A7, w)
#~     mod.(0x10E6C3, h)
#~     mod.(0x10EEA9, w)
#~     mod.(0x10EEB9, h)
#~     th_large_screen_resize_screen(width, height)
#~   end
#~ end

#~ #===============================================================================
#~ # Esrever's code from
#~ # http://www.rpgmakervxace.net/topic/100-any-chance-of-higher-resolution-or-larger-sprite-support/page-2#entry7997
#~ #===============================================================================
#~ class Game_Map

#~   #--------------------------------------------------------------------------
#~   # overwrite method: scroll_down
#~   #--------------------------------------------------------------------------
#~   def scroll_down(distance)
#~     if loop_vertical?
#~       @display_y += distance
#~       @display_y %= @map.height * 256
#~       @parallax_y += distance
#~     else
#~       last_y = @display_y
#~       dh = Graphics.height > height * 32 ? height : screen_tile_y
#~       @display_y = [@display_y + distance, height - dh].min
#~       @parallax_y += @display_y - last_y
#~     end
#~   end

#~   #--------------------------------------------------------------------------
#~   # overwrite method: scroll_right
#~   #--------------------------------------------------------------------------
#~   def scroll_right(distance)
#~     if loop_horizontal?
#~       @display_x += distance
#~       @display_x %= @map.width * 256
#~       @parallax_x += distance
#~     else
#~       last_x = @display_x
#~       dw = Graphics.width > width * 32 ? width : screen_tile_x
#~       @display_x = [@display_x + distance, width - dw].min
#~       @parallax_x += @display_x - last_x
#~     end
#~   end

#~ end # Game_Map

#~ #==============================================================================
#~ # ■ Spriteset_Map
#~ #==============================================================================

#~ class Spriteset_Map

#~   #--------------------------------------------------------------------------
#~   # overwrite method: create_viewports
#~   #--------------------------------------------------------------------------
#~   def create_viewports
#~     if Graphics.width > $game_map.width * 32 && !$game_map.loop_horizontal?
#~       dx = (Graphics.width - $game_map.width * 32) / 2
#~     else
#~       dx = 0
#~     end
#~     dw = [Graphics.width, $game_map.width * 32].min
#~     dw = Graphics.width if $game_map.loop_horizontal?
#~     if Graphics.height > $game_map.height * 32 && !$game_map.loop_vertical?
#~       dy = (Graphics.height - $game_map.height * 32) / 2
#~     else
#~       dy = 0
#~     end
#~     dh = [Graphics.height, $game_map.height * 32].min
#~     dh = Graphics.height if $game_map.loop_vertical?
#~     @viewport1 = Viewport.new(dx, dy, dw, dh)
#~     @viewport2 = Viewport.new(dx, dy, dw, dh)
#~     @viewport3 = Viewport.new(dx, dy, dw, dh)
#~     @viewport2.z = 50
#~     @viewport3.z = 100
#~   end

#~   #--------------------------------------------------------------------------
#~   # new method: update_viewport_sizes
#~   #--------------------------------------------------------------------------
#~   def update_viewport_sizes
#~     if Graphics.width > $game_map.width * 32 && !$game_map.loop_horizontal?
#~       dx = (Graphics.width - $game_map.width * 32) / 2
#~     else
#~       dx = 0
#~     end
#~     dw = [Graphics.width, $game_map.width * 32].min
#~     dw = Graphics.width if $game_map.loop_horizontal?
#~     if Graphics.height > $game_map.height * 32 && !$game_map.loop_vertical?
#~       dy = (Graphics.height - $game_map.height * 32) / 2
#~     else
#~       dy = 0
#~     end
#~     dh = [Graphics.height, $game_map.height * 32].min
#~     dh = Graphics.height if $game_map.loop_vertical?
#~     rect = Rect.new(dx, dy, dw, dh)
#~     for viewport in [@viewport1, @viewport2, @viewport3]
#~       viewport.rect = rect
#~     end
#~   end

#~ end # Spriteset_Map

#~ #-------------------------------------------------------------------------------
#~ # FenixFyre's custom Plane, simply drawing a sprite. Needs to do something about
#~ # the y-axis
#~ #-------------------------------------------------------------------------------
#~ class Plane
#~   attr_reader :ox, :oy
#~   
#~   alias :th_unlimited_resolution_initialize :initialize
#~   def initialize(viewport = nil)
#~     th_unlimited_resolution_initialize(viewport)
#~     @sprite = Sprite.new(viewport)
#~     @bitmap = nil
#~     @ox = 0
#~     @oy = 0
#~   end
#~   
#~   alias :th_unlimited_resolution_dispose :dispose
#~   def dispose
#~     @sprite.dispose
#~     th_unlimited_resolution_dispose
#~   end

#~   def method_missing(symbol, *args)
#~     @sprite.method(symbol).call(*args)
#~   end
#~   
#~   def bitmap=(bitmap)
#~     @bitmap = bitmap
#~     refresh
#~   end
#~   
#~   def bitmap
#~     @sprite.bitmap
#~   end
#~   
#~   def ox=(ox)
#~     w = @sprite.viewport != nil ? @sprite.viewport.rect.width : Graphics.width
#~     @ox = ox % w
#~     @sprite.ox = @ox
#~   end
#~   
#~   def oy=(oy)
#~     h = @sprite.viewport != nil ? @sprite.viewport.rect.height : Graphics.height
#~     @oy = oy % h
#~     @sprite.oy = @oy
#~   end
#~   
#~   def refresh
#~     return if @bitmap.nil?
#~     w = @sprite.viewport != nil ? @sprite.viewport.rect.width : Graphics.width
#~     h = @sprite.viewport != nil ? @sprite.viewport.rect.height : Graphics.height
#~     if @sprite.bitmap != nil
#~       @sprite.bitmap.dispose
#~     end
#~     @sprite.bitmap = Bitmap.new(w * 2, h * 2)
#~    
#~     max_x = w / @bitmap.width
#~     max_y = h / @bitmap.height
#~     for x in 0..max_x
#~       for y in 0..max_y
#~         @sprite.bitmap.blt(x * @bitmap.width, y * @bitmap.height,
#~          @bitmap, Rect.new(0, 0, @bitmap.width, @bitmap.height))
#~       end
#~     end
#~     for i in 1...4
#~       x = i % 2 * w
#~       y = i / 2 * h
#~       @sprite.bitmap.blt(x, y, @sprite.bitmap, Rect.new(0, 0, w, h))
#~     end
#~   end
#~ end

#~ #==============================================================================
#~ # ■ Scene_Map
#~ #==============================================================================

#~ class Scene_Map < Scene_Base

#~   #--------------------------------------------------------------------------
#~   # alias method: post_transfer
#~   #--------------------------------------------------------------------------
#~   alias scene_map_post_transfer_ace post_transfer
#~   def post_transfer
#~     @spriteset.update_viewport_sizes
#~     scene_map_post_transfer_ace
#~   end

#~ end # Scene_Map