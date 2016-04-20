# responsible for program/game flow
class Game
  attr_reader :board, :computer_player, :human_player

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

  def determine_starting_marker(starting_player, human_marker)
    starting_player == @human_player ? human_marker : ([Board::X_MARKER, Board::O_MARKER] - [human_marker]).first
  end

  def switch_players(current_player)
    current_player == @human_player ? @computer_player : @human_player
  end
end
