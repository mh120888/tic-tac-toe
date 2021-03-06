# logic for calculating the optimal move updating game state for the computer player
class ComputerPlayer
  attr_reader :best_move

  def find_move(board)
    negamax(board)
    @best_move[:space]
  end

  private

  def negamax(board, depth = 1, alpha = -100, beta = 100, color = 1)
    return score(board, depth) * color if board.stop_playing?
    board.all_free_spaces.each do |space|
      potential_move = {space: space, score: 0, marker: board.turn}
      board.mark_board(potential_move[:space], potential_move[:marker])
      potential_move[:score] = -negamax(board, depth + 1, -beta, -alpha, -color)
      board.unmark_board(potential_move[:space])
      if potential_move[:score] > alpha
        alpha = potential_move[:score]
        @best_move = potential_move if depth == 1
      end
      if alpha >= beta
        return alpha
      end
    end
    alpha
  end


  def score(board, depth)
    if board.winner == board.human_marker
      -50 + depth
    elsif board.winner == board.computer_marker
      50 - depth
    else
      0
    end
  end
end
