# console-based view layer
class ConsoleUI
  attr_accessor :input, :output

  HUMAN_WON_MESSAGE = "You won!".freeze
  COMPUTER_WON_MESSAGE = "The computer won :(".freeze
  DRAW_MESSAGE = "It's a draw".freeze

  def initialize
    @input = $stdin
    @output = $stdout
  end

  def display_board(board)
    @output.puts
    board.grid.each_slice(board.spaces_across) do |slice|
      slice.each { |space| space == Board::EMPTY_SPACE ? @output.print("_ ") : @output.print("#{space} ") }
      @output.puts
    end
    @output.puts
    @output.puts "=" * 6
  end

  def display_instructions(current_marker, human_marker, board)
    current_marker == human_marker ? display_human_instructions(board) : display_computer_instructions
  end

  def display_human_instructions(board)
    @output.puts "Your turn. Choose a space, 1-#{board.spaces_across**2}, to play on the board."
  end

  def display_computer_instructions
    @output.puts "Computer's turn. He's thinking."
    sleep(1)
  end

  def determine_board_size
    board_size = 0
    loop do
      @output.puts "What size board would you like to play? 3x3 (3) or 4x4 (4)?"
      board_size = get_board_size
      break if (3..4).include?(board_size)
    end
    board_size
  end

  def get_board_size
    @input.gets.chomp.to_i
  end

  def human_plays_first?
    go_first = ''
    loop do
      @output.puts "Would you like to go first? (y/n)"
      go_first = get_user_input
      break if go_first == 'y' || go_first == 'n'
    end
    go_first == 'y'
  end

  def get_user_input
    @input.gets.chomp.downcase
  end

  def which_marker
    marker = ''
    loop do
      @output.puts "Would you like to play with #{Board::X_MARKER} or #{Board::O_MARKER}?"
      marker = get_user_input
      break if marker == Board::X_MARKER || marker == Board::O_MARKER
    end
    marker
  end

  def display_result(board)
    display_board(board)
    @output.puts "Game Over"
    if board.winner
      board.winner == board.human_marker ? @output.puts(HUMAN_WON_MESSAGE) : @output.puts(COMPUTER_WON_MESSAGE)
    else
      @output.puts DRAW_MESSAGE
    end
  end
end
