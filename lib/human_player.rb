# responsible for handling user input and updating game state for the human player
class HumanPlayer
  def find_move(board, move=nil)
    loop do
      move ||= get_move
      break if board.valid_move?(move)
      puts "Please enter a number between 1 and #{board.number_of_spaces} that has not already been taken"
      move = nil
    end
    move
  end

  def get_move
    gets.chomp.to_i - 1
  end
end
