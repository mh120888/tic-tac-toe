require_relative '../lib/board'
require_relative '../lib/computer_player'

RSpec.describe ComputerPlayer do
  let(:board) { Board.new(Board::X_MARKER, Board::X_MARKER, 3) }
  let(:computer_player) { ComputerPlayer.new }

  describe '#find_move' do
    it 'returns an integer' do
      expect(computer_player.find_move(board)).to be_an(Integer)
    end

    it 'will block an imminent win' do
      board.mark_board(0, Board::X_MARKER)
      board.mark_board(5, Board::O_MARKER)
      board.mark_board(1, Board::X_MARKER)
      expect(computer_player.find_move(board)).to be(2)
    end

    it 'will play to win if possible' do
      board.mark_board(0, Board::X_MARKER)
      board.mark_board(4, Board::O_MARKER)
      board.mark_board(1, Board::X_MARKER)    
      board.mark_board(2, Board::O_MARKER)    
      board.mark_board(5, Board::X_MARKER)
      expect(computer_player.find_move(board)).to be(6)    
    end
  end  
end
