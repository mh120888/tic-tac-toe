require_relative '../lib/human_player'
require_relative '../lib/board'

RSpec.describe HumanPlayer do
  let(:board) { Board.new(Board::X_MARKER, Board::O_MARKER, 3) }
  let(:human_player) { HumanPlayer.new }

  describe "#find_move" do
    it 'confirms a valid move and returns it' do
      expect(human_player.find_move(board, 1)).to eq(1)
    end
  end
end
