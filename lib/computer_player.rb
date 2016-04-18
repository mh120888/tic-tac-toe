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
