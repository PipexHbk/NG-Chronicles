# Boulder Push SE trigger (al terminar movimiento)
# Reconoce múltiples nombres de evento: "Boulder", "Piedra Rod"

class Game_Event
  alias __fl_boulder_update update
  def update
    was_moving = moving?
    old_x = @x
    old_y = @y
    __fl_boulder_update
    # Reproducir SE si el evento dejó de moverse y es un boulder válido
    if was_moving && !moving? &&
       ["Boulder", "Piedra Rod"].include?(self.name) &&
       ($game_player.x == @x || $game_player.y == @y) &&
       (($game_player.x - @x).abs + ($game_player.y - @y).abs) <= 2
      pbSEPlay("Boulder Push")
    end
  end
end
