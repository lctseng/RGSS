#===============================================================================
# Mouse System
# By Jet10985(Jet)
# Some code by Daniel Martin
#===============================================================================
# This script will allow full use of the mouse inside of Ace for various
# purposes.
# This script has: 11 customization options.
#===============================================================================
# Overwritten Methods:
# Game_Player: move_by_input
# Window_NameInput: item_max
#-------------------------------------------------------------------------------
# Aliased methods:
# Scene_Map: update, terminate, update_transfer_player
# Input: update, trigger?, press?, repeat?, dir8/dir4
# Window_Selectable: update
# Scene_File: update, top_index=
# Game_Event: update, setup_page
# Game_Player: check_action_event, get_on_off_vehicle
# Game_System: initialize
#===============================================================================
=begin
Showing text above event when mouse hovers:

If you want a message to appear over an event's head if the mouse is hovering
over the event, put this comment in the event:

MOUSE TEXT MESSAGE HERE

everything after TEXT will be the hovering display.
--------------------------------------------------------------------------------
Change mouse picture above event when mouse hovers:

If you want the mouse's picture to temporarily change whne over an event, put
this comment in the event

MOUSE PIC NAME/NUMBER

if you put a name, the mouse will become that picture, but if you put a number
then the mouse will become the icon that is the id number
--------------------------------------------------------------------------------
Specific mouse click movement routes:

If you want the player to land specifically in a square around an event when
they click to move on the event, put one of these comments in the event:

MOUSE MOVE UP/LEFT/RIGHT/DOWN

only put the direction that you want the player to land on.
--------------------------------------------------------------------------------
Click to activate:

If you want an event to automatically start when it is clicked on, place
this in an event comment:

MOUSE CLICK
--------------------------------------------------------------------------------
Ignore Events:

To have an event be ignored when the mouse makes it's movement path(as if the
event isn't there), put this comment in the event:

MOUSE THROUGH
--------------------------------------------------------------------------------
You can do some extra things with the mouse using event "Script..." commands:

Mouse.set_pos(x, y) will set the mouse's position to the x and y specified.

Mouse.area?(x, y, width, height) will check if the mouse is inside the given
rectangle, on-screen. This does not account for a scrolled map.

Mouse.grid will return where on the screen the mouse is, not accounting for
a scrolled map. Returns an array: [x, y]

Mouse.true_grid will return where on the map the mouse is, accounting for a
scrolled map. Returns an array: [x, y]

Mouse.click?(1 or 2) will return true/false depending on if a mouse button was
clicked, in only the current frame. Use 1 for left-click, 2 for right-click.

Mouse.press?(1 or 2) will return true/false depending on if a mouse button is
currently being pressed. Use 1 for left-click, 2 for right-click.
--------------------------------------------------------------------------------
Extra Notes:

You can activate action button events by standing next to the event and clicking
on it with the mouse.
=end

module Jet
  module MouseSystem
    
    # This is the image used to display the cursor in-game.
    CURSOR_IMAGE = "cursor-mouse"
    
    # If the above image does not exist, the icon at this index will be used.
    CURSOR_ICON = 147
    
    # turning ths switch on will completely disable the mouse.
    TURN_MOUSE_OFF_SWITCH = 99
    
    # Do you want the player to be able to move using the mouse?
    # This can be changed in-game using toggle_mouse_movement(true/false)
    ALLOW_MOUSE_MOVEMENT = true
    
    # Do you want to check for diagonal movement as well? Please note this
    # enables regular diagonal movement with the keyboard as well.
    DO_DIAGONAL_MOVEMENT = false
    
    # If the tile they click on for movement is not passable, do you want
    # to check the surround tiles for a movable area?
    CHECK_FOR_MOVES = true
    
    # Would you like a black box to outline the exact tile the mouse is over?
    DEV_OUTLINE = true
    
  end
  
  module HoverText
    
    # This is the font for the hovering mouse text.
    FONT = "Verdana"
    
    # This is the font color for hovering mouse text.
    COLOR = Color.new(255, 255, 255, 255)
    
    # This is the font size for hovering mouse text.
    SIZE = 20
    
  end
  
  module Pathfinder
    
    # While mainly for coders, you may change this value to allow the
    # pathfinder more time to find a path. 1000 is default, as it is enough for
    # a 100x100 maze.
    MAXIMUM_ITERATIONS = 1000
    
  end
end

#===============================================================================
# DON'T EDIT FURTHER UNLESS YOU KNOW WHAT TO DO.
#===============================================================================
module Mouse
  
  Get_Message = Win32API.new('user32', 'GetMessage', 'plll', 'l')
  GetAsyncKeyState = Win32API.new("user32", "GetAsyncKeyState", 'i', 'i')
  GetKeyState = Win32API.new("user32", "GetKeyState", 'i', 'i')
  GetCursorPo = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
  SetCursorPos = Win32API.new('user32', 'SetCursorPos', 'nn', 'n')
  ScreenToClient = Win32API.new('user32', 'ScreenToClient', 'lp', 'i')
  GetClientRect = Win32API.new('user32', 'GetClientRect', 'lp', 'i')
  GetWindowRect = Win32API.new('user32', 'GetWindowRect', 'lp', 'i')
  a = Win32API.new('kernel32', 'GetPrivateProfileString', 'pppplp', 'l')
  b = Win32API.new('user32', 'FindWindow', 'pp', 'i')
  a.call("Game", "Title", "", title = "\0" * 256, 256, ".//Game.ini")
  @handle = b.call("RGSS Player", title.unpack("C*").collect {|a| a.chr }.join.delete!("\0"))
  
  Win32API.new('user32', 'ShowCursor', 'i', 'i').call(0)
  
  module_function
  
  def click?(button)
    return true if @keys.include?(button)
    return false
  end
  
  def press?(button)
    return true if @press.include?(button)
    return false
  end
  
  def set_pos(x_pos = 0, y_pos = 0)
    width,height = client_size
    if (x_pos.between?(0, width) && y_pos.between?(0, height))
      SetCursorPos.call(client_pos[0] + x_pos,client_pos[1] + y_pos)
    end
  end
  
  def moved?
    @pos != @old_pos
  end
  
  def set_cursor(image)
    (@cursor ||= Sprite_Cursor.new).set_cursor(image)
  end
  
  def revert_cursor
    (@cursor ||= Sprite_Cursor.new).revert
  end
  
  def update
    if !$game_switches.nil? 
      if $game_switches[Jet::MouseSystem::TURN_MOUSE_OFF_SWITCH]
        @keys, @press = [], []
        @pos = [-1, -1]
        @cursor.update
        return
      end
    end
    @old_pos = @pos.dup
    @pos = Mouse.pos
    @keys.clear
    @press.clear
    @keys.push(1) if GetAsyncKeyState.call(1)&0x01 == 1
    @keys.push(2) if GetAsyncKeyState.call(2)&0x01 == 1
    @keys.push(3) if GetAsyncKeyState.call(4)&0x01 == 1
    @press.push(1) if pressed?(1)
    @press.push(2) if pressed?(2)
    @press.push(3) if pressed?(4)
    @cursor.update rescue @cursor = Sprite_Cursor.new
  end
  
  def init
    @keys = []
    @press = []
    @pos = Mouse.pos
    @cursor = Sprite_Cursor.new
  end
  
  def pressed?(key)
    return true unless GetKeyState.call(key).between?(0, 1)
    return false
  end
  
  def global_pos
    pos = [0, 0].pack('ll')
    GetCursorPo.call(pos) != 0 ? (return pos.unpack('ll')) : (return [0, 0])
  end
  
  def pos
    x, y = screen_to_client(*global_pos)
    width, height = client_size
    begin
      x = 0 if x <= 0; y = 0 if y <= 0
      x = width if x >= width; y = height if y >= height
      return x, y
    end
  end
  
  def screen_to_client(x, y)
    return nil unless x && y
    pos = [x, y].pack('ll')
    if ScreenToClient.call(@handle, pos) != 0
      return pos.unpack('ll')
    else
      return [0, 0]
    end
  end
  
  def client_size
    rect = [0, 0, 0, 0].pack('l4')
    GetClientRect.call(@handle, rect)
    right,bottom = rect.unpack('l4')[2..3]
    return right, bottom
  end
  
  def client_pos
    rect = [0, 0, 0, 0].pack('l4')
    GetWindowRect.call(@handle, rect)
    left, upper = rect.unpack('l4')[0..1]
    return left + 4, upper + 30
  end
  
  def grid
    [(@pos[0]/32),(@pos[1]/32)]
  end
  
  def true_grid
    xy = @pos
    x = ((xy[0] + ($game_map.display_x * 32)) / 32).floor
    y = ((xy[1] + ($game_map.display_y * 32)) / 32).floor
    [x, y]
  end
  
  def grid_by_pos
    [pos[0] / 32, pos[1] / 32]
  end
  
  def true_grid_by_pos
    xy = pos
    x = ((xy[0] + ($game_map.display_x * 32)) / 32).floor
    y = ((xy[1] + ($game_map.display_y * 32)) / 32).floor
    [x, y]
  end
  
  def area?(x, y, width, height)
    @pos[0].between?(x, width + x) && @pos[1].between?(y, height + y)
  end
  
  class Sprite_Cursor < Sprite
    
    def initialize
      super(nil)
      self.z = 50000
      @bitmap_cache = initial_bitmap
      if Jet::MouseSystem::DEV_OUTLINE
        @outline = Sprite.new(nil)
        @outline.bitmap = Bitmap.new(32, 32)
        @outline.bitmap.fill_rect(0, 0, 32, 32, Color.new(0, 0, 0, 190))
        @outline.bitmap.fill_rect(1, 1, 30, 30, Color.new(0, 0, 0, 0))
      end
    end
    
    def initial_bitmap
      begin
        self.bitmap = Cache.system(Jet::MouseSystem::CURSOR_IMAGE)
      rescue
        self.bitmap = Bitmap.new(24, 24)
        icon_index = Jet::MouseSystem::CURSOR_ICON
        rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        self.bitmap.blt(0, 0, Cache.system("Iconset"), rect, 255)
      end
      self.bitmap.dup
    end
    
    def set_cursor(image)
      if image.is_a?(Integer)
        self.bitmap = Bitmap.new(24, 24)
        icon_index = image
        rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        self.bitmap.blt(0, 0, Cache.system("Iconset"), rect, 255)
      else
        self.bitmap = Cache.picture(image)
      end
    end
    
    def revert
      self.bitmap = @bitmap_cache.dup
    end
    
    def update
      super
      self.x, self.y = *Mouse.pos
      self.visible = !$game_switches[Jet::MouseSystem::TURN_MOUSE_OFF_SWITCH]
      if !@outline.nil?
        @outline.visible = SceneManager.scene_is?(Scene_Map)
        x = Mouse.true_grid_by_pos[0] * 32
        x -= $game_map.display_x.floor * 32
        x -= ($game_map.display_x % 1) * 32
        y = Mouse.true_grid_by_pos[1] * 32
        y -= $game_map.display_y.floor * 32
        y -= ($game_map.display_y % 1) * 32
        @outline.x = x
        @outline.y = [y, 1].max
      end
    end
  end
end

Mouse.init

class << Input

  alias jet5888_press? press?
  def press?(arg)
    if arg == Input::C
      return true if Mouse.press?(1)
    elsif arg == Input::B
      return true if Mouse.press?(2)
    end
    jet5888_press?(arg)
  end
  
  alias jet5888_repeat? repeat?
  def repeat?(arg)
    if arg == Input::C
      return true if Mouse.click?(1)
    elsif arg == Input::B
      return true if Mouse.click?(2)
    end
    jet5888_repeat?(arg)
  end
  
  alias jet5888_trigger? trigger?
  def trigger?(arg)
    if arg == Input::C
      return true if Mouse.click?(1)
    elsif arg == Input::B
      return true if Mouse.click?(2)
    end
    jet5888_trigger?(arg)
  end
  
  if Jet::MouseSystem::DO_DIAGONAL_MOVEMENT
  
    alias jet3845_dir8 dir8
    def dir8(*args, &block)
      if (orig = jet3845_dir8(*args, &block)) == 0
        if !$game_temp.nil? && SceneManager.scene_is?(Scene_Map)
          if !(a = $game_temp.mouse_character).nil? && a.movable?
            if !$game_temp.mouse_path.nil? && !$game_temp.mouse_path.empty?
              return $game_temp.mouse_path.shift
            end
          end
        end
      end
      $game_temp.mouse_path = nil if !$game_temp.nil?
      return orig
    end
    
  else
    
    alias jet3845_dir4 dir4
    def dir4(*args, &block)
      if (orig = jet3845_dir4(*args, &block)) == 0
        if !$game_temp.nil? && SceneManager.scene_is?(Scene_Map)
          if !(a = $game_temp.mouse_character).nil? && a.movable?
            if !$game_temp.mouse_path.nil? && !$game_temp.mouse_path.empty?
              return $game_temp.mouse_path.shift
            end
          end
        end
      end
      $game_temp.mouse_path = nil if !$game_temp.nil?
      return orig
    end
  end
  
  alias jet8432_update update
  def update(*args, &block)
    jet8432_update(*args, &block)
    Mouse.update
  end
end

class Window_Selectable
  
  alias jet1084_update update
  def update(*args, &block)
    jet1084_update(*args, &block)
    update_mouse if self.active && self.visible && Mouse.moved?
  end
  
  def update_mouse
    return if $game_switches[Jet::MouseSystem::TURN_MOUSE_OFF_SWITCH]
    orig_index = @index
    rects = []
    add_x = self.x + 16 - self.ox
    add_y = self.y + 16 - self.oy
    if !self.viewport.nil?
      add_x += self.viewport.rect.x - self.viewport.ox
      add_y += self.viewport.rect.y - self.viewport.oy
    end
    self.item_max.times {|i|
      @index = i
      mouse_update_cursor
      rects << cursor_rect.dup
    }
    @index = orig_index
    rects.each_with_index {|rect, i|
      if Mouse.area?(rect.x + add_x, rect.y + add_y, rect.width, rect.height)
        @index = i
      end
    }
    update_cursor
    call_update_help
  end
  
  def mouse_update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, contents.width, row_max * item_height)
    elsif @index < 0
      cursor_rect.empty
    else
      cursor_rect.set(item_rect(@index))
    end
  end
end

class Window_NameInput
  
  def item_max
    90
  end
end

#~ class Scene_File
#~   
#~   alias jet3467_update update
#~   def update(*args, &block)
#~     update_mouse if Mouse.moved?
#~     jet3467_update(*args, &block)
#~   end
#~   
#~   alias jet7222_top_index top_index=
#~   def top_index=(*args, &block)
#~     @last_cursor_move = 0 if @last_cursor_move.nil?
#~     @last_cursor_move -= 1
#~     return if @last_cursor_move > 0 && Mouse.moved?
#~     jet7222_top_index(*args, &block)
#~     @last_cursor_move = 10
#~   end
#~   
#~   def update_mouse
#~     self.item_max.times {|i|
#~       ix = @savefile_windows[i].x
#~       iy = @savefile_windows[i].y + 48 - @savefile_viewport.oy
#~       iw = @savefile_windows[i].width
#~       ih = @savefile_windows[i].height
#~       if Mouse.area?(ix, iy, iw, ih)
#~         @savefile_windows[@index].selected = false
#~         @savefile_windows[i].selected = true
#~         @index = i
#~       end
#~     }
#~     ensure_cursor_visible
#~   end
#~ end

class Game_Temp
  
  attr_accessor :mouse_character, :mouse_movement, :mouse_path
  
end

class Game_CharacterBase

  def mouse_path(target_x, target_y, did_dir = false)
    return if target_x == self.x && target_y == self.y
    f = $game_map.find_path(target_x.to_i, target_y.to_i, @x.to_i, @y.to_i, self)
    if f.empty? && !did_dir && Jet::MouseSystem::CHECK_FOR_MOVES
      [[0, 1], [0, -1], [1, 0], [-1, 0]].each {|a|
        next if !f.empty?
        f = $game_map.find_path(target_x.to_i + a[0], target_y.to_i + a[1],
          @x.to_i, @y.to_i, self)
      }
    end
    $game_temp.mouse_path = f
  end
end

class Game_Player
  
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    dir = (Jet::MouseSystem::DO_DIAGONAL_MOVEMENT ? Input.dir8 : Input.dir4)
    if dir % 2 == 0 || !Jet::MouseSystem::DO_DIAGONAL_MOVEMENT
      move_straight(dir) if dir > 0 && dir % 2 == 0
    else
      horz = case dir; when 1,7; 4; when 3,9; 6; end
      vert = case dir; when 7,9; 8; when 1,3; 2; end
      move_diagonal(horz, vert)
    end
  end
  
  alias jet3745_check_action_event check_action_event
  def check_action_event(*args, &block)
    return false unless Input.jet5888_trigger?(:C)
    jet3745_check_action_event(*args, &block)
  end
  
  alias jet3745_get_on_off_vehicle get_on_off_vehicle
  def get_on_off_vehicle(*args, &block)
    if !Input.jet5888_trigger?(:C)
      [:boat, :ship, :airship].each {|a|
        if $game_map.send(a).pos?(*Mouse.true_grid)
          jet3745_get_on_off_vehicle(*args, &block)
          return
        end
      }
    elsif Input.jet5888_trigger?(:C)
      jet3745_get_on_off_vehicle(*args, &block)
    end
  end
  
  def get_on_vehicle_mouse(veh)
    return if vehicle
    @vehicle_type = veh.type
    if vehicle
      turn_toward_character(veh)
      @vehicle_getting_on = true
      force_move_forward unless in_airship?
      @followers.gather
    end
    @vehicle_getting_on
  end
end

class Window_MousePopUp < Window_Base
  
  def initialize(event, text)
    rect = Bitmap.new(1, 1).text_size(text)
    width = rect.width
    height = rect.height
    super(event.screen_x - width / 2, event.screen_y - 48, width + 32, height + 32)
    self.opacity = 0
    self.contents.font.name = Jet::HoverText::FONT
    self.contents.font.color = Jet::HoverText::COLOR
    self.contents.font.size = Jet::HoverText::SIZE
    @text = text
    @event = event
    refresh
  end
  
  def refresh
    contents.clear
    draw_text(0, 0, contents.width, contents.height, @text)
  end
  
  def update
    super
    self.visible = !@event.erased? && Mouse.true_grid_by_pos == [@event.x, @event.y]
    self.x = @event.screen_x - contents.width / 2 - 8
    self.y = @event.screen_y - 64
  end
end

class Game_Event
  
  attr_accessor :text_box
  
  def check_for_comment(regexp)
    return false if empty?
    for item in @list
      if item.code == 108 or item.code == 408
        if !item.parameters[0][regexp].nil?
          return $1.nil? ? true : $1
        end
      end
    end
    return false
  end
  
  def mouse_empty?
    return true if empty?
    return @list.reject {|a| [108, 408].include?(a.code) }.size <= 1
  end
  
  alias jet3745_setup_page setup_page
  def setup_page(*args, &block)
    jet3745_setup_page(*args, &block)
    @text_box = nil
    @mouse_activated = nil
    @mouse_cursor = nil
  end
  
  def mouse_activated?
    @mouse_activated ||= check_for_comment(/MOUSE[ ]*CLICK/i)
  end
  
  def text_box
    @text_box ||= (
      if (a = check_for_comment(/MOUSE[ ]*TEXT[ ]*(.+)/i))
        Window_MousePopUp.new(self, a)
      else
        false
      end
    )
  end
  
  def through
    if $game_temp.mouse_movement && check_for_comment(/MOUSE[ ]*THROUGH/i)
      true
    else
      super
    end
  end
  
  def mouse_cursor
    @mouse_cursor ||= (
      if (a = check_for_comment(/MOUSE[ ]*PIC[ ]*(\d+)/i))
        a.to_i
      elsif (a = check_for_comment(/MOUSE[ ]*PIC[ ]*(.+)/i))
        a
      else
        false
      end
    )
  end
  
  def erased?
    @erased
  end
  
  def movable?
    return false if moving?
    return false if $game_message.busy? || $game_message.visible
    return true
  end
  
  def check_mouse_change
    if mouse_cursor
      Mouse.set_cursor(@mouse_cursor)
      return true
    end
    return false
  end
  
  alias jet3845_update update
  def update(*args, &block)
    jet3845_update(*args, &block)
    @text_box.update if text_box
  end
end

class Game_Vehicle
  
  attr_reader :type
  
end

class Game_System
  
  attr_accessor :mouse_movement
  
  alias jet2735_initialize initialize
  def initialize(*args, &block)
    jet2735_initialize(*args, &block)
    @mouse_movement = Jet::MouseSystem::ALLOW_MOUSE_MOVEMENT
  end
end

class Game_Interpreter
  
  def toggle_mouse_movement(bool)
    $game_system.mouse_movement = bool
  end
end

class Scene_Map
  
  alias jet3745_update update
  def update(*args, &block)
    jet3745_update
    check_mouse_movement
    check_mouse_icon_change
  end
  
  alias jet5687_terminate terminate
  def terminate(*args, &block)
    $game_map.events.values.each {|a| 
      a.text_box.dispose if a.text_box
      a.text_box = nil
    }
    Mouse.update
    jet5687_terminate(*args, &block)
  end
  
  def mouse_char
    $game_temp.mouse_character
  end
  
  def check_mouse_icon_change
    changed_mouse = false
    $game_map.events_xy(*Mouse.true_grid_by_pos).each {|event|
      changed_mouse = changed_mouse || event.check_mouse_change
    }
    Mouse.revert_cursor unless changed_mouse
  end

  def check_mouse_movement
    $game_temp.mouse_character ||= $game_player
    if Mouse.click?(1)
      dont_move = false
      x, y = *Mouse.true_grid_by_pos
      evs = $game_map.events_xy(x, y)
      (evs + $game_map.vehicles).each {|event|
        if event.is_a?(Game_Vehicle)
          if (event.x - mouse_char.x).abs + (event.y - mouse_char.y).abs == 1
            mouse_char.get_on_vehicle_mouse(event)
            dont_move = true
          end
        elsif !!!mouse_char.vehicle
          if event.mouse_activated?
            event.start
            dont_move = true
          elsif (event.x - mouse_char.x).abs + (event.y - mouse_char.y).abs == 1
            if !event.mouse_empty? && [0, 1, 2].include?(event.trigger)
              mouse_char.turn_toward_character(event)
              event.start
              dont_move = true
            end
          else
            {UP: [0, -1], DOWN: [0, 1], LEFT: [-1, 0], RIGHT: [1, 0]}.each {|d, a|
              if event.check_for_comment(/MOUSE[ ]*MOVE[ ]*#{d.to_s}/i)
                x += a[0]; y += a[1]
                did_dir = true
              end
            }
          end
        end
      } if $game_system.mouse_movement
      if $game_system.mouse_movement
        mouse_char.mouse_path(x, y, did_dir ||= false) unless dont_move
      else
        evs.each {|event|
          if event.mouse_activated?
            event.start
          end
        }
      end
    end
  end
end

class Game_Map
  
  class Astar
  
    class PriorityQueue
    
      def initialize
        @list = []
      end
      
      def add(priority, item)
        @list << [priority, @list.length, item]
        @list.sort!
        self
      end
      
      def <<(pritem)
        add(*pritem)
      end
      
      def next
        @list.shift[2]
      end
      
      def empty?
        @list.empty?
      end
    end
    
    def initialize(map)
      @map = map
    end

    def do_find_path(goal, start, char)
      been_there = {}
      pqueue = PriorityQueue.new
      pqueue << [1, [start, [], 1]]
      iters = 0
      while !pqueue.empty?
        iters += 1
        return [] if iters > Jet::Pathfinder::MAXIMUM_ITERATIONS
        spot, path_so_far, cost_so_far = pqueue.next
        next if been_there[spot]
        newpath = [path_so_far, spot]
        if (spot == goal)
          path = []
          newpath.flatten.each_slice(2) {|i,j| path << [i,j]}
          return recreate_path(path)
        end
        been_there[spot] = 1
        spotsfrom(spot, char).each {|newspot|
          next if been_there[newspot]
          newcost = cost_so_far + 1
          pqueue << [newcost + estimate(newspot, goal), [newspot,newpath,newcost]]
        }
      end
      return []
    end

    def estimate(spot, goal)
      [(spot[0] - goal[0]).abs, (spot[1] - goal[1]).abs].max
    end
    
    def spotsfrom(spot, char)
      neighbors = []
      4.times {|i|
        i += 1
        new_x = @map.round_x_with_direction(spot[0], i * 2)
        new_y = @map.round_y_with_direction(spot[1], i * 2)
        next unless char.passable?(spot[0], spot[1], i * 2)
        neighbors << [new_x, new_y]
      }
      if Jet::MouseSystem::DO_DIAGONAL_MOVEMENT
        [2, 8].each {|a|
          [4, 6].each {|b|
            new_x = @map.round_x_with_direction(spot[0], b)
            new_y = @map.round_y_with_direction(spot[1], a)
            next unless char.diagonal_passable?(spot[0], spot[1], b, a)
            neighbors << [new_x, new_y]
          }
        }
      end
      neighbors
    end
    
    def recreate_path(path)
      rec_path = []
      hash = {[1, 0] => 6, [-1, 0] => 4, [0, 1] => 2, [0, -1] => 8,
        [-1, 1] => 1, [-1, -1] => 7, [1, 1] => 3, [1, -1] => 9}
      until path.empty?
        pos = path.shift
        nex = path[0]
        next if path.empty?
        ar = [nex[0] <=> pos[0], nex[1] <=> pos[1]]
        rec_path << hash[ar]
      end
      return rec_path
    end
  end

  
  def find_path(t_x, t_y, x, y, char = $game_player)
    @astar ||= Astar.new(self)
    @astar.do_find_path([t_x, t_y], [x, y], char)
  end
end