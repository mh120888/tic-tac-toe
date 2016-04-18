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

# responsible for handling user input and updating game state for the human player
class HumanPlayer
  def find_move(board)
    move = nil
    loop do
      move = gets.chomp.to_i - 1
      valid_play = (0..board.spaces_across**2).include?(move) && (board.grid[move] == Board::EMPTY_SPACE)
      break if valid_play
      puts "Please enter a number between 1 and #{board.spaces_across**2} that has not already been taken"
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

  def minimax(board, depth = 1, alpha = -100, beta = 100)
    return score(board) if board.stop_playing?
    if board.turn == board.computer_marker
      board.all_free_spaces.each do |space|
        potential_board = board.deep_copy
        potential_move = {space: space, score: 0, marker: potential_board.turn}
        potential_board.mark_board(potential_move[:space], potential_move[:marker])
        potential_move[:score] = minimax(potential_board, depth + 1, alpha, beta)
        if potential_move[:score] > alpha
          alpha = potential_move[:score]
          @best_move = potential_move if depth == 1
        end
        if alpha >= beta
          return alpha
        end
      end
      alpha
    else
      board.all_free_spaces.each do |space|
        potential_board = board.deep_copy
        potential_move = {space: space, score: 0, marker: potential_board.turn}
        potential_board.mark_board(potential_move[:space], potential_move[:marker])
        potential_move[:score] = minimax(potential_board, depth + 1, alpha, beta)
        if potential_move[:score] < beta
          beta = potential_move[:score]
        end
        if alpha >= beta
          return beta
        end
      end
      beta
    end
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
      -50 + board.computer_turns
    elsif board.winner == board.computer_marker
      50 - board.computer_turns
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
    board_size = @ui.determine_board_size
    @board = Board.new(human_marker, starting_marker, board_size)
    until @board.stop_playing?
      @ui.display_board(@board)
      @ui.display_instructions(@board.turn, @board.human_marker, @board)
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
    board.grid.each_slice(board.spaces_across) do |slice|
      slice.each { |space| space == Board::EMPTY_SPACE ? print("_ ") : print("#{space} ") }
      puts
    end
    puts
    puts "=" * 6
  end

  def display_instructions(current_marker, human_marker, board)
    current_marker == human_marker ? display_human_instructions(board) : display_computer_instructions
  end

  def display_human_instructions(board)
    puts "Your turn. Choose a space, 1-#{board.spaces_across**2}, to play on the board."
  end

  def display_computer_instructions
    puts "Computer's turn. He's thinking."
    sleep(1)
  end

  def determine_board_size
    board_size = 0
    loop do
      puts "What size board would you like to play? 3x3 (3) or 4x4 (4)?"
      board_size = gets.chomp.to_i
      break if (3..4).include?(board_size)
    end
    board_size
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
