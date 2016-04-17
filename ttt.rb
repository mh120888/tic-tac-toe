# represents game state for tie tac toe
class Board
  attr_reader :winner, :human_marker, :computer_marker, :computer_turns, :turn, :grid
  attr_accessor :human_marker

  EMPTY_SPACE = ''.freeze
  X_MARKER = 'x'.freeze
  O_MARKER = 'o'.freeze
  WINNING_COMBOS = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
    ].freeze

    def initialize(human_marker, starting_marker)
      @grid = [EMPTY_SPACE] * 9
      @winner = false
      @human_marker = human_marker
      @computer_marker = (@human_marker == X_MARKER ? O_MARKER : X_MARKER)
      @computer_turns = 0
      @turn = starting_marker
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
      WINNING_COMBOS.select { |winning_combo| (marked_spaces & winning_combo).length == 3 }.flatten
    end

    def is_there_a_winner?
      check_if_winner(X_MARKER) || check_if_winner(O_MARKER)
    end

    def stop_playing?
      is_there_a_winner? || board_full?
    end
  end

# responsible for handling user input and updating game state for the human player
class HumanPlayer
  def find_move(board)
    move = nil
    loop do
      move = gets.chomp.to_i - 1
      valid_play = (0..8).include?(move) && (board.grid[move] == Board::EMPTY_SPACE)
      break if valid_play
      puts "Please enter a number between 1 and 9 that has not already been taken"
    end
    move
  end
end

# logic for calculating the optimal move updating game state for the computer player
class ComputerPlayer
  attr_reader :best_move

  def find_move(board)
    minimax(board)
    @best_move[:space]
  end

  def minimax(board)
    return score(board) if board.stop_playing?
    moves = []
    board.all_free_spaces.each do |space|
      potential_board = board.deep_copy
      moves << (potential_move = {space: space, score: 0, marker: potential_board.turn})
      potential_board.mark_board(potential_move[:space], potential_move[:marker])
      potential_move[:score] = minimax(potential_board)
    end
    @best_move = choose_best_move(moves, board)
    @best_move[:score]
  end

  def choose_best_move(moves, board)
    if board.turn == board.computer_marker
      moves.sort_by { |move| move[:score] }.reverse.first
    else
      moves.sort_by{ |move| move[:score] }.first
    end
  end

  def score(board)
    if board.winner == board.human_marker
      -5 + board.computer_turns
    elsif board.winner == board.computer_marker
      5 - board.computer_turns
    else
      0
    end
  end
end

# responsible for program/game flow
class Game
  attr_reader :board, :computer_player

  def initialize
    @human_player = HumanPlayer.new
    @computer_player = ComputerPlayer.new
    @ui = ConsoleUI.new
  end

  def play
    player = @ui.human_plays_first? ? @human_player : @computer_player
    human_marker = @ui.which_marker
    starting_marker = determine_starting_marker(player, human_marker)
    @board = Board.new(human_marker, starting_marker)
    until @board.stop_playing?
      @ui.display_board(@board)
      @ui.display_instructions(@board.turn, @board.human_marker)
      @board.mark_board(player.find_move(@board), @board.turn)
      player = switch_players(player)
    end
    @ui.display_result(@board)
  end

  def determine_starting_marker(player, human_marker)
    player == @human_player ? human_marker : ([Board::X_MARKER, Board::O_MARKER] - [human_marker]).first
  end

  def switch_players(current_player)
    current_player == @human_player ? @computer_player : @human_player
  end

end

# console-based view layer
class ConsoleUI
  def display_board(board)
    puts
    board.grid.each_slice(3) do |slice|
      slice.each { |space| space == Board::EMPTY_SPACE ? print("_ ") : print("#{space} ") }
      puts
    end
    puts
    puts "=" * 6
  end

  def display_instructions(current_marker, human_marker)
    current_marker == human_marker ? display_human_instructions : display_computer_instructions
  end

  def display_human_instructions
    puts "Your turn. Choose a space, 1-9, to play on the board."
  end

  def display_computer_instructions
    puts "Computer's turn. He's thinking."
    sleep(1.5)
  end

  def human_plays_first?
    go_first = ''
    loop do
      puts "Would you like to go first? (y/n)"
      go_first = gets.chomp.downcase
      break if go_first == 'y' || go_first == 'n'
    end
    go_first == 'y'
  end

  def which_marker
    marker = ''
    loop do
      puts "Would you like to play with #{Board::X_MARKER} or #{Board::O_MARKER}?"
      marker = gets.chomp.downcase
      break if marker == Board::X_MARKER || marker == Board::O_MARKER
    end
    marker
  end

  def display_result(board)
    display_board(board)
    puts "Game Over"
    if board.winner
      board.winner == board.human_marker ? puts("You won!") : puts("The computer won :(")
    else
      puts "It's a draw"
    end
  end
end

if !$testing
  first_game = Game.new
  first_game.play
end
