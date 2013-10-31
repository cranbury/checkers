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
    piece = self[from_p]
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
    piece = self[from_p]
    if piece == nil
      raise ArgumentError.new "That piece is empty."
    elsif color != piece.color
      raise ArgumentError.new "Move your own piece"
    elsif !good_jump?(color, from_p, to_p)
      raise ArgumentError.new "Bad jump"
    end
    move_piece!(from_p, to_p)
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
    elsif (from_p[1] - to_p[1]).abs != 1
      return false
    end

    return true if self[from_p].kinged
    #Forward
    return false if !forward?(color, from_p, to_p)

    true
  end

  def jumped_spot(from_p, to_p)
    jumped = from_p
    jumped[0] += from_p[0] -to_p[0]
    jumped[1] += from_p[1] - to_p[1]
    jumped
  end

  def forward?(color, from_p, to_p)
    case color
    when :black
      return false if (from_p[0] - to_p[0]) <= 0
    when :red
      return false if (from_p[0] - to_p[0]) >= 0
    end

    true
  end

  def good_jump? (color, from_p, to_p)
    #should this be bad_jump??
    if (from_p[0] - to_p[0]).abs != 2
      return false
    elsif (from_p[1] - to_p[1]).abs != 2
      return false
    end

    return false if self[jumped_spot(from_p, to_p)].nil?

    return true if self[from_p].kinged
    #Forward
    return false if !forward?(color, from_p, to_p)

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
new_board.move_piece!([0, 1], [4, 1])
new_board.render
new_board.jump_piece(:black, [5,0], [3, 2])
new_board.render