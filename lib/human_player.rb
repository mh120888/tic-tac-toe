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
