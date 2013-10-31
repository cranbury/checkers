require 'debugger'
class Board
  def initialize(new_game = true)
    set_up_board if new_game
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  def render
    counter = 1
    puts
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

  def slide_piece(color, from_p, to_p)
    piece = self[start]
    if piece == nil
      raise ArgumentError.new "That piece is empty."
    elsif color != piece.color
      raise ArgumentError.new "Move your own piece"
    elsif !good_slide?(color, from_p, to_p)
      raise ArgumentError.new "Bad slide"
    end
    move_piece!
  end

  def jump_piece(color, from_p, to_p)
    piece = self[start]

    move_piece!
  end

  def move_piece!(from_p, to_p)
    piece = self[from_p]
    self[to_p] = [piece]
    self[from_p] = nil
    piece.pos = to_p
  end

  def good_slide?(color, from_p, to_p)
    #Slide one spot
    if (from_p[0] - to_p[0]).abs != 1
      return false
    elsif (from_p[1] - to_p[01]).abs != 1
      return false
    end

    return ture if self[from_p].kinged
    #Forward
    case color
    when :black
      return false if (from_p[0] - to_p[0]) <= 0
    when :red
      return false if (from_p[0] - to_p[0]) >= 0
    end

    true
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
  attr_accessor :pos, :kinged######

  def initialize(color, board, pos)
    @color, @board, @pos = color, board, pos
    @kinged = false
    board.add_piece(self, pos)
  end

  def render
    rend = (color == :black) ? '|b|' : '|r|'
    rend.upcase if @kinged
    rend
  end

end

class Game
end

class User
end

new_board = Board.new
new_board.render
new_board.move_piece!([5,0], [4,1])
new_board.render