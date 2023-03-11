require "gosu"

WIDTH = 800
HEIGHT = 600
GAME_SECS = 30
TEXT = {
  caption: "Squash A Bug!",
  time: "TIME:",
  score: "SCORE:",
  over: "Game Over!",
  again: "Press the space bar to play again.",
}.freeze

class SquashABug < Gosu::Window
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = TEXT[:caption]
    set_defaults
  end

  def update
    return unless @playing

    update_target_position
    update_target_visibility
    update_time
    update_play_status
  end

  def button_down(id)
    record_score if @playing && id == Gosu::MsLeft
    reset_game if !@playing && id == Gosu::KbSpace
  end

  def draw
    end_game unless @playing
    draw_target if should_draw_target?
    draw_mouse_trigger
    draw_background
    @hit = 0
    draw_game_info
  end

  private

  def set_defaults
    @target = Gosu::Image.new("./assets/images/bug.png")
    @trigger = Gosu::Image.new("./assets/images/hammer.png")
    @font = Gosu::Font.new(30)
    @x = @y = 200
    @target_width = 74
    @target_height = 52
    @velocity_x = @velocity_y = 5
    @visible = @hit = @start_time = @score = 0
    @playing = true
  end

  def draw_background
    c = background_color
    draw_quad(0, 0, c, WIDTH, 0, c, WIDTH, HEIGHT, c, 0, HEIGHT, c)
  end

  def draw_game_info
    @font.draw("#{TEXT[:time]} #{@time_left}", 20, 20, 2)
    @font.draw("#{TEXT[:score]} #{@score}", 640, 20, 2)
  end

  def draw_target
    @target.draw(@x - @target_width / 2, @y - @target_height / 2, 1)
  end

  def draw_mouse_trigger
    @trigger.draw(mouse_x - 40, mouse_y - 10, 1)
  end

  def should_draw_target?
    @visible > 0
  end

  def update_time
    @time_left = (GAME_SECS - ((Gosu.milliseconds - @start_time) / 1000))
  end

  def update_play_status
    @playing = false if @time_left <= 0
  end

  def update_target_visibility
    @visible -= 1
    @visible = 60 if @visible < -10 && rand < 0.01
  end

  def update_target_position
    @x += @velocity_x
    @velocity_x *= -1 if reverse_x?

    @y += @velocity_y
    @velocity_y *= -1 if reverse_y?
  end

  def reverse_x?
    @x + @target_width / 2 > WIDTH || @x - @target_width / 2 < 0
  end

  def reverse_y?
    @y + @target_height / 2 > HEIGHT || @y - @target_height / 2 < 0
  end

  def background_color
    case @hit
    when 0
      Gosu::Color::NONE
    when 1
      Gosu::Color::GREEN
    when -1
      Gosu::Color::RED
    end
  end

  def record_score
    if Gosu.distance(mouse_x, mouse_y, @x, @y) < 40 && @visible >= 0
      @hit = 1
      @score += 5
    else
      @hit = -1
      @score -= 1
    end
  end

  def reset_game
    @playing = true
    @visible = -10
    @start_time = Gosu.milliseconds
    @score = 0
  end

  def end_game
    @font.draw(TEXT[:over], 325, 230, 3)
    @font.draw(TEXT[:again], 185, 280, 3)
    @visible = 20
  end
end

SquashABug.new.show
