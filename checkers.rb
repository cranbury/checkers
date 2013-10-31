class Board
  def initialize(new_game = true)
    set_up_board if new_game
  end


  def set_up_board
  end
end

class Piece
  attr_reader :board, :color #####
  attr_accessor :pos######

  def intialize(color, board, pos)
    @color, @board, @pos = color, board, pos
  end

end

class Game
end

class User
end