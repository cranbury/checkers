# encoding: UTF-8

require 'debugger'
require 'colorize'
require 'yaml'

class Game
  def initialize()
    @board = Board.new
    @players = {
          :black => HumanPlayer.new(:black),
          :red => HumanPlayer.new(:red)
                }
    @current_player = :black
  end

  def play

    until board.no_moves?(@current_player)
      @players[current_player].play_turn(@board)
      @current_player = (@current_player == :red) ? :black : :red
    end
  end
end

class HumanPlayer
  def initialize(color)
    @color = color
  end

  def play_turn(board)
    puts board.render
    puts "Current player: #{@color}"
    puts "Starting row:"
    to_p, from_p = [], []
    to_p << gets.chomp
    puts "Starting col:"
    to_p << gets.chomp
    puts "Ending row:"
    from_p << gets.chomp
    puts "Ending col:"
    from_p << gets.chomp
    [from_p, to_p]
  end

end


class Board
  SLIDE_SET = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
  JUMPSET = [[-2, -2], [-2, 2], [2, -2], [2, 2]]

  attr_accessor :rows

  def initialize(new_game = true, rows = [])
    @rows = rows
    set_up_board if new_game
  end

  def find_pieces(my_color)
    pieces = @rows.flatten.compact
    pieces.select {|p| p.color == my_color}
  end

  def possible_slides(pos)
    pos_slides = Array.new(4)
    4.times do |val, i|
      pos_slides[i][0] = pos[0] + SLIDESET[i][0]
      pos_slides[i][0] = pos[0] + SLIDESET[i][0]
    end

    pos_slides
  end

  def possible_jumps(pos)
    pos_jumps = Array.new(4)
    4.times do |val, i|
      pos_jumps[i][0] = pos[0] + JUMPSET[i][0]
      pos_jumps[i][0] = pos[0] + JUMPSET[i][0]
    end

    pos_jumps
  end

  def no_moves?(color) ###########NOT DONE.
    dummy_board = clone
    my_pieces = find_pieces(color)
    all_moves = []
    my_pieces.each do |piece|

    !(jumps_available?(dummy_board) || result = slides_available?(dummy_board))
  end

  def clone
    serialized_board = self.to_yaml
    YAML::load(serialized_board)
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

  def perform_slide(color, sequence)
    from_p, to_p = sequence
    piece = self[from_p]
    if piece == nil
      raise ArgumentError.new "That piece is empty."
    elsif color != piece.color
      raise ArgumentError.new "Move your own piece"
    elsif !good_slide?(color, from_p, to_p)
      raise ArgumentError.new "Bad slide"
    end
    perform_moves! [from_p, to_p]
  end

  def perform_jump(color, sequence)

      sequence.each_with_index do |val, i|
        next if i == (sequence.length - 1)
      piece = self[sequence[i]]
      if piece == nil
        raise ArgumentError.new "That piece is empty."
      elsif color != piece.color
        raise ArgumentError.new "Move your own piece"
      elsif !good_jump?(color, sequence[i], sequence[i + 1])
        raise ArgumentError.new "Bad jump"
      end
      perform_moves!([sequence[i], sequence[i + 1]])
      if i == 0
        self[jumped_spot(sequence[i], sequence[i + 1])] = nil
      end
    end
  end

  def perform_moves!(move_sequence)
    #move_sequence.flatten!
    until move_sequence.length == 1
      from_p = move_sequence.shift
      to_p = move_sequence.last
      #debugger
      piece = self[from_p]
      self[to_p] = piece
      self[from_p] = nil
      piece.pos = to_p

      unless self[to_p].nil?
        if self[to_p].color == :black && to_p[0] == 0
          self[to_p].promote_king
        elsif self[to_p].color == :red && to_p[0] == 7
          self[to_p].promote_king
        end
        puts "color: #{self[to_p].color}"
        puts "row: #{to_p[0]}"
      end
    end
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
    ##refactor by combining
    true
  end

  def jumped_spot(from_p, to_p)
    [(from_p[0] + to_p[0]) / 2, (from_p[1] + to_p[1]) / 2]
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


    @rows[i][j] = piece
  end

  def rows
    @rows
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

  def color
    @color
  end

  def kinged?
    @kinged
  end

  def promote_king
    @kinged = true
    puts "Promotion!"
  end

  def render
    rend = (color == :black) ? '|♳|' : '|☻|'.colorize(:red)
    rend = (color == :black) ? '|☃|' : '|⚾|'.colorize(:red)if kinged?
    rend
  end

end



new_board = Board.new
new_board.render
new_board.perform_moves!([[1, 4], [4, 1]])
new_board.perform_moves!([[0, 5], [4, 5]])

new_board.render
new_board.perform_jump(:black, [[5, 0], [3, 2], [1,4]])
new_board.render
new_board.perform_slide(:black, [[1, 4], [0, 5]])
new_board.render
#new_board.rows[0][5].promote_king
new_board.render

