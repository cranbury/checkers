require 'debugger'
class Board
  def initialize(new_game = true)
    set_up_board if new_game
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  def to_s
    counter = 1
    @rows.flatten.each do |spot|
      if spot.nil?
        print "|_|"
      else
        print spot.render
      end
      puts if counter % 8 == 0
      counter += 1
    end
  end

  def set_up_board
    @rows = Array.new(8) { Array.new(8)}
    place_pieces(:black)
    place_pieces(:red)
  end

  def place_pieces(color)
    8.times do |col|
      (3).times do |inc|
        row = (color == :black) ? 5 : 0
        row += inc
        Piece.new(color, self, [row, col]) if (row + col).odd?
      end
    end
  end

  def [](pos)
    @rows[pos.first][pos.last]
  end

  def []=(pos, piece)
    ##raise "invalid pos" unless valid_pos?(pos)
    i, j = pos
    pos
    @rows[i][j] = piece
  end
end

class Piece
  attr_reader :board, :color #####
  attr_accessor :pos######

  def initialize(color, board, pos)
    @color, @board, @pos = color, board, pos

    board.add_piece(self, pos)
  end

  def render
    rend = (color == :black) ? '|b|' : '|r|'
  end

end

class Game
end

class User
end

new_board = Board.new
print new_board