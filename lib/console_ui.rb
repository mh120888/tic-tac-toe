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
