#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'
require 'yaml'
require 'tempfile'
require 'base64'
require 'tween'


$data = YAML.parse(DATA.read)

def with_data(key,&block)
  Tempfile.open(File.basename(__FILE__)) do |tmp|
    tmp.binmode
    tmp.write( Base64.decode64($data[key].value) )
    tmp.close
    
    block.call(tmp.path)
  end
end



module Z
  Background, Graph, Text, Ball = (1..100).to_a
end

class MyWindow < Gosu::Window
  WIDTH = 640
  HEIGHT = 480
  TITLE = "Tween Demo"
  
  TOP_COLOR = Gosu::Color.new(0xFFF5F5F5)
  BOTTOM_COLOR = Gosu::Color.new(0xFFBEBEBE)
  GRAPH_COLOR = Gosu::Color::BLACK
  
  
  
  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = TITLE
    
    @last_frame = Gosu::milliseconds
    
    with_data('globe.png') do |png|
      @ball = Gosu::Image.new(self, png, false)
    end
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @smallfont = Gosu::Font.new(self, Gosu::default_font_name, 15)
    
    @x, @y = width / 2, height / 2
    @tween = nil
    @easer = Tween::EASERS[0]

    begin
      require 'gl'

      Gl.glEnable(Gl::GL_LINE_SMOOTH)
      Gl.glHint(Gl::GL_LINE_SMOOTH_HINT, Gl::GL_NICEST)
    rescue LoadError
    end
  end
  
  
  
  def update
    calculate_delta
  end
  
  def calculate_delta
    @this_frame = Gosu::milliseconds
    @delta = (@this_frame - @last_frame) / 1000.0
    
    # Update game objects here
    unless @tween.nil? or @tween.done
      @tween.update(@delta)
      @x, @y = @tween.x, @tween.y
    end
    
    @last_frame = @this_frame
  end
  
  
  
  def draw
    draw_background
    draw_graph
    draw_easer_name
    draw_instructions
    draw_ball
  end
  
  def draw_ball
    @ball.draw(
      @x - (@ball.width / 2),
      @y - (@ball.height / 2),
      Z::Ball
    )
  end
  
  def draw_background
    draw_quad(
      0,     0,      TOP_COLOR,
      WIDTH, 0,      TOP_COLOR,
      0,     HEIGHT, BOTTOM_COLOR,
      WIDTH, HEIGHT, BOTTOM_COLOR,
      Z::Background)
  end
  
  def draw_graph
    left = width * 0.2
    right = left + width * 0.6
    bottom = height * 0.8
    top = bottom - height * 0.6
    
    draw_line(
      left, top, GRAPH_COLOR,
      left, bottom + 20, GRAPH_COLOR,
      Z::Graph
    )
    
    draw_line(
      left - 20, bottom, GRAPH_COLOR,
      right, bottom, GRAPH_COLOR,
      Z::Graph
    )
        
    graph = (0..100).map do |idx|
      @easer.ease(idx, bottom, top - bottom, 100.0)
    end
    
    (1..99).map do |idx|
      draw_line(
        left + Tween::Linear.ease(idx - 1, 0, right - left, 100),
        graph[idx - 1],
        GRAPH_COLOR,
        
        left + Tween::Linear.ease(idx, 0, right - left, 100),
        graph[idx], 
        GRAPH_COLOR,
        
        Z::Graph
      )
    end
  end
  
  def draw_easer_name
    @font.draw(
      @easer.to_s,
      10, 10, Z::Text,
      1.0, 1.0,
      GRAPH_COLOR
    )
  end
  
  def draw_instructions
    @smallfont.draw(
      "Click to move globe, press left and right to change easer",
      20, height - 20, Z::Text,
      1.0, 1.0,
      GRAPH_COLOR
    )
  end
  
  
  def needs_cursor?
    true
  end
  
  def button_down(id)
    case id
    when Gosu::MsLeft
      @tween = Tween.new(
        [@x.to_f, @y.to_f],
        [mouse_x.to_f, mouse_y.to_f],
        @easer,
        1
      )
      
    when Gosu::KbEscape
      close
      
    when Gosu::KbRight
      next_easer
      
    when Gosu::KbLeft
      last_easer
    end
  end
  
  
  def next_easer
    idx = Tween::EASERS.index(@easer) + 1
    
    if idx == Tween::EASERS.length
      idx = 0
    end
    
    @easer = Tween::EASERS[idx]
  end
  
  def last_easer
    idx = Tween::EASERS.index(@easer) - 1
    
    if idx == -1
      idx = Tween::EASERS.length - 1
    end
    
    @easer = Tween::EASERS[idx]
  end
end

MyWindow.new.show

__END__
--- 
globe.png: |
  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

