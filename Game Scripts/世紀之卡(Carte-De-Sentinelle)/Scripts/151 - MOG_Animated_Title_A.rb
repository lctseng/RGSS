#~ #　★タイトル設定
#~ #==============================================================================
#~ # +++ MOG - Animated Title A (v2.2) +++
#~ #==============================================================================
#~ # By Moghunter 
#~ # http://www.atelier-rgss.com/
#~ #==============================================================================
#~ # Tela de titulo animado, com logo, imagens aleatórias e outros efeitos visuais.
#~ #==============================================================================

#~ #==============================================================================
#~ # IMAGENS NECESSÁRIAS
#~ #==============================================================================
#~ # Serão necessários as seguintes imagens na pasta Graphics/Titles2/
#~ #
#~ # Cursor.png   
#~ # Commmand_Name.png (image filename = name of command)
#~ # Particle.png   (Opcional)
#~ # Logo.jpg       (Opcional)
#~ # Animated.png   (Opcional)
#~ #==============================================================================

#~ #==============================================================================
#~ # NOTA 1 - Para definir a imagem de texto basta selecionar no banco de dados
#~ # a imagem do titulo numero 2 (Segunda camada)
#~ #==============================================================================

#~ #==============================================================================
#~ # NOTA 2 - O nome da imagem de comando é iguál ao nome do comando definido
#~ # no banco de dados do Rpg Maker.
#~ #==============================================================================


#~ #==============================================================================
#~ # ● Histórico (Version History)
#~ #==============================================================================
#~ # v 2.2 - Possibilidade de colocar valores de movemento negativo nas partículas.
#~ # v 2.1 - Correção do Bug quando a quantidade de imagens aleatórias é definida
#~ #         com a quantidade menor  que 1.
#~ # v 2.0 - Adição do Sprite Animado. (Opcional)
#~ #       - Adição de cores aleatórias nas partículas.
#~ #       - Adição do multiplas camadas de imagens. (Opcional)
#~ #       - Adição do efeito Wave no texto do titulo.  
#~ #       - Opção de definir a velocidade de movimento das partículas.
#~ #       - Opção de ativar ou não o tremor na seleção de comando.
#~ #
#~ # v 1.2 - Melhoria no sistema de dispose de imagens.
#~ #
#~ # v 1.1 - Opção de pular o logo ao apertar alguma tecla.
#~ #       - Adição de comandos em pictures.
#~ #       - Adição de cursor de comando.
#~ #==============================================================================

#~ module MOG_SCENE_TITLE_A

#~   #--------------------------------------------------------------------------
#~   # ▼ LOGO ▼
#~   #--------------------------------------------------------------------------
#~   # Apresenta um Logo ao começar a tela de titulo.
#~   # Será necessário ter a imagem LOGO.jpg (png) na pasta Graphics/Title2
#~   #--------------------------------------------------------------------------
#~   # Ativar Logo
#~   LOGO = false
#~   # Duração do logo.
#~   LOGO_DURATION = 2 #(Sec)
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ RANDOM BACKGROUND ▼
#~   #--------------------------------------------------------------------------  
#~   #Definição das pictures. 
#~   #--------------------------------------------------------------------------
#~   RANDOM_PICTURES = [
#~   "Title0",   "Title1"
#~   #"Title4","Title5","Title6","Title7"
#~   ]
#~   #Tempo de duração para ativar a troca de imagens.
#~   RANDOM_PICTURES_DURATION = 10#(sec)
#~   #Seleção aleatória.
#~   RAMDOM_SELECTION = false
#~   #Velocidade de Scrolling. (Speed X , Speed Y)
#~   RANDOM_PICTURES_SCROLL_SPEED = [0,0]
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ MULTIPLE LAYERS ▼
#~   #--------------------------------------------------------------------------
#~   # Definição de multiplas camadas. * (não há limíte na quantidade de camadas
#~   # usadas)
#~   #--------------------------------------------------------------------------
#~   # MULTIPLE_LAYERS = [  ["A",B,C,D], ["A",B,C,D], ["A",B,C D], ["A",B,C,D ], ....]
#~   #
#~   # A - Nome da imagem.
#~   # B - Velocidade de scroll na horizontal.
#~   # C - Velocidade de scroll na vertical.
#~   # D - Tipo de Blend. (0 - Normal / 2 - Add / 3 - Substract)
#~   #
#~   MULTIPLE_LAYERS = [
#~   ["Layer1",1,0,1]
#~ #  ["Layer4",0,0,0],
#~ #  ["Layer5",0,0,0],
#~ #  ["Layer6",0,0,0]
#~   ]  
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ PARTICLES ▼
#~   #--------------------------------------------------------------------------
#~   # Adiciona partículas animadas na tela do titulo.
#~   # Será necessário ter a imagem PARTICLE.png na pasta Graphics/Title2
#~   #--------------------------------------------------------------------------
#~   # Ativar Partículas.
#~   PARTICLE = true
#~   # Ativar Cores Aleatórias.
#~   PARTICLE_RANDOM_COLOR = true  
#~   # Definição do tipo de blend. (0,1,2)
#~   PARTICLE_BLEND_TYPE = 1
#~   #Definição do limite de velocidade das partículas.
#~   PARTICLE_MOVEMENT_RANGE_X = 3
#~   PARTICLE_MOVEMENT_RANGE_Y = 3
#~   PARTICLE_ANGLE_RANGE = 3
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ WAVE TITLE ▼
#~   #--------------------------------------------------------------------------  
#~   # Ativa o efeito  WAVE no texto do titulo, o Texto do titulo é definido
#~   # na camada do titulo 2, que pode ser definido através do banco de dados
#~   #--------------------------------------------------------------------------    
#~   #Ativar o efeito do titulo com efeito WAVE.
#~   TITLE_WAVE = false
#~   #Configuração do efeito WAVE
#~   #
#~   # TITLE_WAVE_CONFIG = [ AMP, LENGTH , SPEED]
#~   #
#~   TITLE_WAVE_CONFIG = [6 , 232 , 360]
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ ANIMATED_SPRITE ▼ (Opcional)
#~   #--------------------------------------------------------------------------
#~   # Adiciona um sprite animado no titulo.
#~   # A quantidade de frames é proporcional a largura dividido pela altura
#~   # da imagem, ou seja, não há limite de quantidade de frames e nem de 
#~   # tamanho da imagem.
#~   # Será necessário ter a imagem ANIMATED.png (Jpg) na pasta Graphics/Title2
#~   #--------------------------------------------------------------------------
#~   # Ativar Sprite animado.
#~   ANIMATED_SPRITE = false
#~   # Posição do Sprite animado.
#~   ANIMATED_SPRITE_POSITION = [130,150]
#~   # Velocidade da animação
#~   ANIMATED_SPRITE_SPEED = 10
#~   # Tipo de Blend. (0 - Normal / 2 - Add / 3 - Substract)
#~   ANIMATED_SPRITE_BLEND_TYPE = 1
#~   # Definição do zoom,
#~   ANIMATED_SPRITE_ZOOM = 1.5
#~   
#~   
#~   #--------------------------------------------------------------------------
#~   # ▼ COMMANDS / SELECTION ▼
#~   #--------------------------------------------------------------------------
#~   # Configuração extras da tela de titulo.
#~   #--------------------------------------------------------------------------
#~   # Posição do comando.
#~   COMMANDS_POS = [560 , 460]
#~   # Ativar o efeito de tremor ao selecionar o comando.
#~   COMMAND_SHAKE = false
#~   # Definição da posição do cursor.(Para ajustes)
#~   CURSOR_POS = [-42,-7]
#~   # Ativar flash ao mover o comando.
#~   CURSOR_FLASH_SELECTION = true
#~   # Definição da posição do flash.
#~   CURSOR_FLASH_SLECTION_POS = [-238,0]
#~   # Tipo de Blend. (0 - Normal / 2 - Add / 3 - Substract)
#~   CURSOR_FLASH_SLECTION_BLEND_TYPE = 1
#~   
#~ end

#~ #==============================================================================
#~ # ■ Window TitleCommand
#~ #==============================================================================
#~ class Window_TitleCommand < Window_Command
#~   attr_reader :list
#~ end

#~ #==============================================================================
#~ # ■ Particle Title
#~ #==============================================================================
#~ class Particle_Title < Sprite
#~   
#~   include MOG_SCENE_TITLE_A
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Initialize
#~  #--------------------------------------------------------------------------             
#~   def initialize(viewport = nil)
#~       super(viewport)
#~       self.bitmap = Cache.title2("Particle")
#~       self.tone.set(rand(255),rand(255), rand(255), 255) if PARTICLE_RANDOM_COLOR
#~       self.blend_type = PARTICLE_BLEND_TYPE
#~       @cw = self.bitmap.width
#~       @ch = self.bitmap.height
#~       @nx = PARTICLE_MOVEMENT_RANGE_X
#~       @ny = PARTICLE_MOVEMENT_RANGE_Y
#~       reset_setting
#~   end  
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Reset Setting
#~  #--------------------------------------------------------------------------               
#~   def reset_setting
#~       zoom = (50 + rand(100)) / 100.1
#~       self.zoom_x = zoom
#~       self.zoom_y = zoom
#~       self.x = (rand(Graphics.width+32) -32)
#~       self.y = rand(Graphics.height+32 + @ch) 
#~       self.opacity = 0
#~       self.angle = rand(360)
#~       nx2 = rand(@nx).abs
#~       nx2 = 1 if (@nx != 0 and nx2 < 1)      
#~       @speed_x = @nx > 0 ? nx2 : @nx < 0 ? -nx2 : 0        
#~       ny2 = rand(@ny).abs
#~       ny2 = 1 if (@ny != 0 and ny2 < 1)      
#~       @speed_y = @ny > 0 ? ny2 : @ny < 0 ? -ny2 : 0   
#~       @speed_a = [[rand(PARTICLE_ANGLE_RANGE), PARTICLE_ANGLE_RANGE].min, 0].max 
#~   end
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Dispose
#~  #--------------------------------------------------------------------------               
#~   def dispose
#~       super
#~       self.bitmap.dispose
#~   end  
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Update
#~  #--------------------------------------------------------------------------               
#~   def update
#~       super
#~       self.x += @speed_x
#~       self.y -= @speed_y
#~       self.angle += @speed_a      
#~       self.opacity += 5
#~       reset_setting if can_reset_setting?
#~   end  
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Can Reset Setting
#~  #--------------------------------------------------------------------------                 
#~   def can_reset_setting?
#~       return true if (self.x < -48 or self.x > Graphics.width+48)    
#~       return true if (self.y < -48 or self.y > Graphics.height+48)
#~       return false
#~   end  
#~ end

#~ #==============================================================================
#~ # ■ Multiple Layers Title
#~ #==============================================================================
#~ class Multiple_Layers_Title
#~   
#~   #--------------------------------------------------------------------------
#~   # ● Initialize
#~   #--------------------------------------------------------------------------  
#~   def initialize(name = "", scroll_x = 0, scroll_y = 0, blend = 0, index = 0)
#~       @layer = Plane.new
#~       @layer.bitmap = Cache.title1(name.to_s) rescue nil
#~       @layer.bitmap = Bitmap.new(32,32) if @layer.bitmap == nil
#~       @layer.z = 10 + index
#~       @layer.opacity = 0
#~       @layer.blend_type = blend
#~       @scroll_speed = [scroll_x, scroll_y]
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # ● Dispose
#~   #--------------------------------------------------------------------------  
#~   def dispose
#~       @layer.bitmap.dispose
#~       @layer.bitmap = nil
#~       @layer.dispose
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # ● Update
#~   #--------------------------------------------------------------------------  
#~   def update
#~       @layer.opacity += 2
#~       @layer.ox += @scroll_speed[0]
#~       @layer.oy += @scroll_speed[1] 
#~   end
#~   
#~ end 

#~ #==============================================================================
#~ # ■ Scene Title
#~ #==============================================================================
#~ class Scene_Title < Scene_Base
#~  include MOG_SCENE_TITLE_A 
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Start
#~  #--------------------------------------------------------------------------          
#~  def start
#~      super
#~      RPG::BGM.fade(2000)
#~      @logo_active = LOGO
#~      SceneManager.clear
#~      @phase = 1
#~      @phase_time = -1
#~      dispose_title_sprites
#~      create_logo if @logo_active
#~      create_command_window
#~      create_commands
#~      create_background
#~      create_light
#~      create_cursor
#~      create_animated_object
#~      create_flash_select
#~      create_multiple_layers
#~      play_title_music unless @logo_active
#~  end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Create Multiple Layers
#~  #--------------------------------------------------------------------------
#~  def create_flash_select
#~      return if !CURSOR_FLASH_SELECTION
#~      @flash_select = Sprite.new
#~      @flash_select.bitmap = Cache.title2("Cursor2")
#~      @flash_select.z = 99
#~      @flash_select.opacity = 0
#~      @flash_select.blend_type = CURSOR_FLASH_SLECTION_BLEND_TYPE
#~  end  
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Create Multiple Layers
#~  #--------------------------------------------------------------------------           
#~  def create_multiple_layers
#~      @m_layers = []
#~      index = 0
#~      for i in MULTIPLE_LAYERS
#~          @m_layers.push(Multiple_Layers_Title.new(i[0],i[1],i[2],i[3],index))
#~          index += 1
#~      end  
#~  end

#~  #--------------------------------------------------------------------------
#~  # ● Create_Logo
#~  #--------------------------------------------------------------------------            
#~  def create_animated_object
#~       return if !ANIMATED_SPRITE
#~       @object_index = 0
#~       @object_animation_speed = 0
#~       @object = Sprite.new
#~       @object.z = 98
#~       @object.opacity = 0
#~       @object.blend_type = ANIMATED_SPRITE_BLEND_TYPE
#~       @object.zoom_x = ANIMATED_SPRITE_ZOOM
#~       @object.zoom_y = ANIMATED_SPRITE_ZOOM
#~       @object_image = Cache.title2("Animated")
#~       @object_frame_max = @object_image.width / @object_image.height
#~       @object_width = @object_image.width / @object_frame_max  
#~       @object.bitmap = Bitmap.new(@object_width,@object_image.height)
#~       @object.x = ANIMATED_SPRITE_POSITION[0]
#~       @object.y = ANIMATED_SPRITE_POSITION[1]     
#~       make_object_bitmap
#~  end  
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Create_Logo
#~  #--------------------------------------------------------------------------           
#~  def create_cursor
#~      @cursor = Sprite.new
#~      @cursor.bitmap = Cache.title2("Cursor")
#~      @cursor.opacity = 0
#~      @cursor.z = 130
#~      @cursor_position = [0,0]
#~      @mx = [0,0,0]
#~  end 
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Create_Logo
#~  #--------------------------------------------------------------------------           
#~  def create_logo
#~      @phase = 0
#~      @logo = Sprite.new
#~      @logo.bitmap = Cache.title2("Logo")
#~      @logo.opacity = 0
#~      @logo_duration = 180 + (LOGO_DURATION * 60)
#~      @logo.z = 200
#~  end
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Create Commands
#~  #--------------------------------------------------------------------------           
#~  def create_commands
#~      @command_window.visible = false
#~      @commands_index_old = -1
#~      @commands = []
#~      @commands_shake_duration = 0
#~      index = 0
#~      for com in @command_window.list
#~          sprite = Sprite.new
#~          sprite.bitmap = Cache.title2(com[:name].to_s) rescue nil
#~          if sprite.bitmap == nil
#~             sprite.bitmap = Bitmap.new(200,32)
#~             sprite.bitmap.font.size = 24
#~             sprite.bitmap.font.bold = true
#~             sprite.bitmap.font.italic = true
#~             sprite.bitmap.draw_text(0, 0, 200, 32, com[:name].to_s,1)
#~          end
#~          sprite.x = COMMANDS_POS[0] - 100 - (index * 20)
#~          sprite.y = index * sprite.bitmap.height + COMMANDS_POS[1]
#~          sprite.z = 100 + index
#~          sprite.opacity = 0
#~          index += 1
#~          @commands.push(sprite)
#~      end
#~      @command_max = index  
#~  end
#~   
#~   #--------------------------------------------------------------------------
#~   # ● create_background
#~   #--------------------------------------------------------------------------
#~   def create_background
#~       @rand_title_duration = 120
#~       @old_back_index = 0
#~       @sprite1 = Plane.new
#~       @sprite1.opacity = 0
#~       @sprite1.z = 1
#~       if RAMDOM_SELECTION
#~          execute_random_picture(false)
#~       else
#~          execute_random_picture(true)
#~       end
#~       @sprite2 = Sprite.new
#~       @sprite2.bitmap = Cache.title2($data_system.title2_name)
#~       @sprite2.z = 140
#~       @sprite2.opacity = 0
#~       if TITLE_WAVE
#~           @sprite2.wave_amp = TITLE_WAVE_CONFIG[0]
#~           @sprite2.wave_length = TITLE_WAVE_CONFIG[1]
#~           @sprite2.wave_speed = TITLE_WAVE_CONFIG[2]
#~       end    
#~   end
#~   
#~   #--------------------------------------------------------------------------
#~   # ● Create Light
#~   #--------------------------------------------------------------------------  
#~   def create_light
#~       return unless PARTICLE
#~       @viewport_light = Viewport.new(-32, -32, Graphics.width  + 50, Graphics.height + 100)
#~       @viewport_light.z = 50
#~       @light_bitmap =[]
#~       for i in 0...20
#~           @light_bitmap.push(Particle_Title.new(@viewport_light))
#~       end  
#~   end
#~     
#~   #--------------------------------------------------------------------------
#~   # ● dispose Background1
#~   #--------------------------------------------------------------------------
#~   def dispose_background1
#~       @sprite1.bitmap.dispose
#~       @sprite1.bitmap = nil
#~       @sprite1.dispose
#~       @sprite1 = nil
#~   end
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Dispose Background2
#~  #--------------------------------------------------------------------------                
#~   def dispose_background2
#~       if @sprite2.bitmap != nil
#~          @sprite2.bitmap.dispose
#~          @sprite2.bitmap = nil
#~          @sprite2.dispose
#~          @sprite2 = nil
#~       end
#~   end
#~     
#~  #--------------------------------------------------------------------------
#~  # ● Dispose Light
#~  #--------------------------------------------------------------------------              
#~   def dispose_light
#~       return unless PARTICLE
#~       if @light_bitmap != nil
#~          for i in @light_bitmap
#~              i.dispose
#~          end
#~          @light_bitmap = nil
#~       end
#~       @viewport_light.dispose 
#~   end    
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Dispose Logo
#~  #--------------------------------------------------------------------------             
#~  def dispose_logo
#~      return unless @logo_active
#~      @logo.bitmap.dispose
#~      @logo.dispose
#~  end  
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Dispose Multiple Layers
#~  #--------------------------------------------------------------------------                          
#~  def dispose_multiple_layers
#~      return if @m_layers == nil
#~      @m_layers.each {|layer| layer.dispose }
#~  end 
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Terminate
#~  #--------------------------------------------------------------------------            
#~  def terminate
#~      super
#~      dispose_title_sprites     
#~  end  
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Dispose Title Sprites
#~  #--------------------------------------------------------------------------             
#~  def dispose_title_sprites
#~      return if @cursor == nil
#~      dispose_background1
#~      dispose_background2
#~      dispose_light
#~      dispose_logo
#~      dispose_multiple_layers
#~      @cursor.bitmap.dispose
#~      @cursor.dispose
#~      @cursor = nil
#~      if @flash_select != nil
#~         @flash_select.bitmap.dispose
#~         @flash_select.dispose
#~      end   
#~      for com in @commands
#~          com.bitmap.dispose
#~          com.dispose
#~      end
#~      if ANIMATED_SPRITE
#~         @object.bitmap.dispose
#~         @object.dispose
#~         @object_image.dispose
#~      end         
#~  end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Update
#~  #--------------------------------------------------------------------------             
#~  def update
#~      super
#~      update_logo
#~      update_initial_animation
#~      update_command
#~      update_background
#~      update_light
#~      update_object_animation
#~      update_multiple_layers
#~  end
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Update Multiple Layers
#~  #--------------------------------------------------------------------------                          
#~  def update_multiple_layers
#~      return if @m_layers == nil
#~      @m_layers.each {|layer| layer.update }
#~  end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Make Object bitmap
#~  #--------------------------------------------------------------------------                         
#~   def make_object_bitmap
#~       @object.bitmap.clear
#~       src_rect_back = Rect.new(@object_width * @object_index, 0,@object_width,@object_image.height)
#~       @object.bitmap.blt(0,0, @object_image, src_rect_back)  
#~   end
#~     
#~  #--------------------------------------------------------------------------
#~  # ● Update Object Animation
#~  #--------------------------------------------------------------------------                       
#~   def update_object_animation
#~       return if !ANIMATED_SPRITE 
#~       @object.opacity += 2
#~       @object_animation_speed += 1
#~       if @object_animation_speed > ANIMATED_SPRITE_SPEED
#~          @object_animation_speed = 0
#~          @object_index += 1
#~          @object_index = 0 if @object_index >= @object_frame_max
#~          make_object_bitmap    
#~       end
#~   end  
#~   
#~  #--------------------------------------------------------------------------
#~  # ● Update Cursor Position
#~  #--------------------------------------------------------------------------            
#~  def update_cursor_position
#~      @cursor.opacity += 5
#~      execute_animation_s
#~      execute_cursor_move(0,@cursor.x,@cursor_position[0] + @mx[1])
#~      execute_cursor_move(1,@cursor.y,@cursor_position[1])
#~  end  
#~  
#~   #--------------------------------------------------------------------------
#~   # ● Execute Animation S
#~   #--------------------------------------------------------------------------      
#~   def execute_animation_s
#~       @mx[2] += 1
#~       return if @mx[2] < 4
#~       @mx[2] = 0
#~       @mx[0] += 1
#~       case @mx[0]
#~          when 1..7;  @mx[1] += 1            
#~          when 8..14; @mx[1] -= 1
#~          else
#~            @mx[0] = 0
#~            @mx[1] = 0
#~       end
#~   end
#~     
#~   #--------------------------------------------------------------------------
#~   # ● Execute Cursor Move
#~   #--------------------------------------------------------------------------      
#~   def execute_cursor_move(type,cp,np)
#~       sp = 5 + ((cp - np).abs / 5)
#~       if cp > np 
#~          cp -= sp
#~          cp = np if cp < np
#~       elsif cp < np 
#~          cp += sp
#~          cp = np if cp > np
#~       end     
#~       @cursor.x = cp if type == 0
#~       @cursor.y = cp if type == 1
#~   end   
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Update Logo
#~  #--------------------------------------------------------------------------            
#~  def update_logo
#~      return if @phase != 0
#~      loop do
#~         break if  @logo_duration == 0
#~         execute_logo 
#~         Graphics.update
#~         Input.update
#~      end
#~      play_title_music 
#~  end 
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Execute Logo
#~  #--------------------------------------------------------------------------             
#~  def execute_logo
#~      if @logo_duration > 120 and (Input.trigger?(:C) or Input.trigger?(:B))
#~         @logo_duration = 120
#~      end  
#~      @logo_duration -= 1
#~      if @logo_duration > 120
#~         @logo.opacity += 5
#~      else
#~         @logo.opacity -= 5
#~      end
#~      if @logo.opacity <= 0 
#~         @logo_duration = 0
#~         @phase = 1
#~      end     
#~  end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Update Background
#~  #--------------------------------------------------------------------------              
#~  def update_background
#~      @sprite1.ox += RANDOM_PICTURES_SCROLL_SPEED[0]
#~      @sprite1.oy += RANDOM_PICTURES_SCROLL_SPEED[1]
#~      @sprite2.opacity += 2
#~      @sprite2.update
#~      return if RANDOM_PICTURES.size < 1
#~      @rand_title_duration -= 1
#~      if @rand_title_duration <= 0
#~         @sprite1.opacity -= 5 unless RANDOM_PICTURES.size < 2
#~      else
#~         @sprite1.opacity += 5
#~      end   
#~      return if @sprite1.opacity != 0
#~      execute_random_picture
#~  end
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Execute Random Picture
#~  #--------------------------------------------------------------------------              
#~  def execute_random_picture(initial = false)
#~      @rand_title_duration = [[60 * RANDOM_PICTURES_DURATION, 9999].min, 60].max 
#~      if @sprite1.bitmap != nil
#~         @sprite1.bitmap.dispose
#~         @sprite1.bitmap = nil
#~      end
#~      if RAMDOM_SELECTION
#~          rand_pic = rand(RANDOM_PICTURES.size)
#~          if rand_pic == @old_back_index
#~             rand_pic += 1
#~             rand_pic = 0 if rand_pic >= RANDOM_PICTURES.size
#~          end
#~          @old_back_index = rand_pic   
#~      else
#~          @old_back_index += 1 unless initial
#~          @old_back_index = 0 if @old_back_index >= RANDOM_PICTURES.size
#~      end
#~      pic = RANDOM_PICTURES[@old_back_index]
#~      @sprite1.bitmap = Cache.title1(pic) rescue nil
#~      @sprite1.bitmap = Cache.title1("") if @sprite1.bitmap == nil 
#~  end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Update Light
#~  #--------------------------------------------------------------------------              
#~  def update_light
#~      return unless PARTICLE
#~      if @light_bitmap != nil
#~         for i in @light_bitmap
#~             i.update
#~         end  
#~      end   
#~  end
#~     
#~  #--------------------------------------------------------------------------
#~  # ● Update Initial Animation
#~  #--------------------------------------------------------------------------               
#~  def update_initial_animation
#~      return if @phase != 1
#~      @phase_time -= 1 if @phase_time > 0
#~      if @phase_time == 0
#~         @phase = 2
#~         @phase_time = 30
#~      end   
#~      for i in @commands
#~         index = 0
#~         if i.x < COMMANDS_POS[0]
#~            i.x += 5 + (2 * index)
#~            i.opacity += 10
#~            if i.x >= COMMANDS_POS[0]
#~               i.x = COMMANDS_POS[0]
#~               i.opacity = 255
#~               if @phase_time < 15 / 2 
#~                  @phase_time = 15
#~               end   
#~            end  
#~          end
#~          index += 1
#~      end  
#~  end  
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Update Command
#~  #--------------------------------------------------------------------------              
#~  def update_command
#~      return if @phase != 2   
#~      update_command_slide
#~      update_cursor_position
#~      update_flash_select
#~  end
#~  
#~  #--------------------------------------------------------------------------
#~  # ● Update Command Slide
#~  #--------------------------------------------------------------------------               
#~  def update_command_slide
#~      if @commands_index_old != @command_window.index
#~         @commands_index_old = @command_window.index
#~         @commands_shake_duration = 30
#~         if @flash_select != nil
#~            @flash_select.opacity = 255
#~         end   
#~      end
#~      return if @commands_shake_duration == 0
#~      @commands_shake_duration -= 1 if @commands_shake_duration > 0  
#~      @commands_shake_duration = 0 if !COMMAND_SHAKE
#~      for i in @commands
#~        if (i.z - 100) == @command_window.index
#~           i.opacity += 10
#~           @cursor_position = [COMMANDS_POS[0] + CURSOR_POS[0],i.y + CURSOR_POS[1]]
#~           i.x = COMMANDS_POS[0] + rand(@commands_shake_duration)
#~        else  
#~           i.opacity -= 7 if i.opacity > 100
#~           i.x = COMMANDS_POS[0]
#~        end
#~      end  
#~    end
#~    
#~  #--------------------------------------------------------------------------
#~  # ● Update Flash Select
#~  #--------------------------------------------------------------------------                  
#~  def update_flash_select
#~      return if !CURSOR_FLASH_SELECTION
#~      @flash_select.opacity -= 8
#~      @flash_select.x = @cursor_position[0] + CURSOR_FLASH_SLECTION_POS[0]
#~      @flash_select.y = @cursor_position[1] + CURSOR_FLASH_SLECTION_POS[1]     
#~  end
#~    
#~ end

#~ $mog_rgss3_animated_title_a = true
