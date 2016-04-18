# represents game state for tie tac toe
class Board
  attr_reader :winner, :human_marker, :computer_marker, :computer_turns, :turn, :grid, :winning_combos, :spaces_across
  attr_accessor :human_marker

  EMPTY_SPACE = ''.freeze
  X_MARKER = 'x'.freeze
  O_MARKER = 'o'.freeze

  def initialize(human_marker, starting_marker, spaces_across)
    @spaces_across = spaces_across
    @grid = [EMPTY_SPACE] * (spaces_across ** 2)
    @winner = false
    @human_marker = human_marker
    @computer_marker = (@human_marker == X_MARKER ? O_MARKER : X_MARKER)
    @computer_turns = 0
    @turn = starting_marker
    @winning_combos = calculate_winning_combos
  end

  def deep_copy
    Marshal::load(Marshal.dump(self))
  end

  def mark_board(index, marker)
    @grid[index] = marker
    @computer_turns += 1 if marker == @computer_marker
    @turn = marker == @human_marker ? @computer_marker : @human_marker
  end

  def check_if_winner(marker)
    marked_spaces = spaces_taken_by(marker)
    find_winning_indices(marked_spaces).empty? ? false : @winner = marker
  end

  def board_full?
    !@grid.include?(EMPTY_SPACE)
  end

  def find_spaces
    @grid.each_index.select { |index| yield index } if block_given?
  end

  def all_taken_spaces
    find_spaces { |index| @grid[index] == X_MARKER || @grid[index] == O_MARKER }
  end

  def all_free_spaces
    find_spaces { |index| @grid[index] == EMPTY_SPACE }
  end

  def spaces_taken_by(marker)
    find_spaces { |index| @grid[index] == marker }
  end

  def find_winning_indices(marked_spaces)
    @winning_combos.select { |winning_combo| (marked_spaces & winning_combo).length == @spaces_across }.flatten
  end

  def is_there_a_winner?
    check_if_winner(X_MARKER) || check_if_winner(O_MARKER)
  end

  def stop_playing?
    is_there_a_winner? || board_full?
  end

  def calculate_winning_combos
    horizontal_wins + vertical_wins + top_left_to_bottom_right_win + top_right_to_bottom_left_win
  end

  def horizontal_wins
    (0..(@spaces_across ** 2 - 1)).each_slice(@spaces_across).to_a
  end

  def vertical_wins
    horizontal_wins.transpose
  end

  def top_left_to_bottom_right_win
    winning_combo = [0]
    (@spaces_across - 1).times do
      winning_combo << winning_combo.last + @spaces_across + 1
    end
    [winning_combo]
  end

  def top_right_to_bottom_left_win
    winning_combo = [@spaces_across - 1]
    (@spaces_across - 1).times do
      winning_combo << winning_combo.last + @spaces_across - 1
    end
    [winning_combo]
  end
end
