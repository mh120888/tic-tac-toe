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

  describe "#get_move" do
    it 'returns -1 if passed a non-number string' do
      human_player.input = StringIO.new('random string')
      human_player.output = StringIO.new
      expect(human_player.get_move).to eq(-1)
    end

    it "returns one less than the user's choice of move if it is (a string representation of) an integer" do
      human_player.input = StringIO.new('5')
      human_player.output = StringIO.new
      expect(human_player.get_move).to eq(4)
    end
  end
end
