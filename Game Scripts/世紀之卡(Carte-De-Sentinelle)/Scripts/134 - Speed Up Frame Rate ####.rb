=begin
 
 Speed Up Frame Rate During Test Play (Snippet)
 by PK8
 Created: 6/15/12
 Modified: -
 ──────────────────────────────────────────────────────────────────────────────
 ■ Author's Notes
   I made it mainly so I can wade through an unskippable cutscene for a project
   I was testing out.
 ──────────────────────────────────────────────────────────────────────────────
 ■ Introduction 
   This script lets you speed up the frame rate of your project either
   automatically or with the touch of a button during test play. Useful if you
   really want to speed up battles, unskippable cutscenes, or whatever else you
   want to fast forward through during test play.
 ──────────────────────────────────────────────────────────────────────────────
 ■ Features
   o Speed up the frame rate of your game via button press or automatically
     while testplaying.
   o Set the value of the new frame rate. Can be absolute or relative.
 ──────────────────────────────────────────────────────────────────────────────
 ■ Changelog (MM/DD/YYYY)
   o v1    (06/15/2012): Initial Release
 ──────────────────────────────────────────────────────────────────────────────
 ■ Methods Aliased
   Graphics.update
 ──────────────────────────────────────────────────────────────────────────────
 ■ Thanks
   EJlol and Kore for watching me script it during a stream.

=end

#==============================================================================
# ** CONFIGURATION
#==============================================================================

module PK8
  class Framerate_Speedup
    #--------------------------------------------------------------------------
    # * General Settings
    #--------------------------------------------------------------------------
    Switch   = true     # Set true to enable. Set false to disable.
    
    Relative = true     # Set true to raise FPS relative to the value.
                        # Set false to set absolute value to the FPS.
    Value    = 90       # Set value of new frame rate
    
    Auto     = false    # Set to true to raise the frame rate automatically.
                        # Set to false to press a button to raise the fps.
##############################################################
    #Button   = "ALT"    # Set Input button
    Button = :ALT        # 效率能"略"增XDD
##############################################################
  end
end

#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
#  The module that carries out graphics processing.
#==============================================================================

module Graphics
  class << self
    #--------------------------------------------------------------------------
    # * Alias Listings
    #--------------------------------------------------------------------------
    unless method_defined?(:pk8_frsu_update)
      alias_method(:pk8_frsu_update, :update)
    end
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    def update(*args)
      if PK8::Framerate_Speedup::Switch == true and $TEST
        button = PK8::Framerate_Speedup::Button
##############################################################
        #button = eval("Input::#{button}") if button.is_a?(String)
##############################################################
        real_fps = self.frame_rate
        if PK8::Framerate_Speedup::Relative == true
          new_fps = real_fps + PK8::Framerate_Speedup::Value
        else
          new_fps = PK8::Framerate_Speedup::Value
        end
        if PK8::Framerate_Speedup::Auto == true; self.frame_rate = new_fps
        else; self.frame_rate = (Input.press?(button) ? new_fps : real_fps)
        end
      end
      pk8_frsu_update(*args)
      if PK8::Framerate_Speedup::Switch == true and $TEST
        self.frame_rate = real_fps
      end
    end
  end
end