require_relative '../lib/console_ui'
require_relative '../lib/board'

RSpec.describe ConsoleUI do
  let(:human_marker) { Board::X_MARKER }
  let(:computer_marker) { Board::O_MARKER }
  let(:board) { Board.new(human_marker, Board::O_MARKER, 3) }
  let(:console_ui) { ConsoleUI.new }

  describe '#display_instructions' do
    it "calls a method to display human instructions if it's the human's turn" do
      allow(console_ui).to receive(:display_human_instructions)
      console_ui.display_instructions(human_marker, human_marker, board)
      expect(console_ui).to have_received(:display_human_instructions)
    end

    it "calls a method to display computer instructions if it's the computer's turn" do
      allow(console_ui).to receive(:display_computer_instructions)
      console_ui.display_instructions(human_marker, computer_marker, board)
      expect(console_ui).to have_received(:display_computer_instructions)
    end
  end

  describe '#get_board_size' do
    it 'returns 0 if passed a non-number string' do
      console_ui.input = StringIO.new('random string')
      expect(console_ui.get_board_size).to eq(0)
    end

    it "returns the user's choice of move if it is (a string representation of) an integer" do
      console_ui.input = StringIO.new('5')
      expect(console_ui.get_board_size).to eq(5)
    end
  end

  describe '#get_user_input' do
    it "returns the user's input downsized" do
      console_ui.input = StringIO.new('Y')
      expect(console_ui.get_user_input).to eq('y')
    end
  end

  describe '#display_result' do
    it 'displays correct output when human wins' do
      allow(board).to receive_messages(:winner => human_marker)
      console_ui.output = StringIO.new
      console_ui.display_result(board)
      expect(console_ui.output.string).to include(ConsoleUI::HUMAN_WON_MESSAGE)
    end

    it 'displays correct output when computer wins' do
      allow(board).to receive_messages(:winner => computer_marker)
      console_ui.output = StringIO.new
      console_ui.display_result(board)
      expect(console_ui.output.string).to include(ConsoleUI::COMPUTER_WON_MESSAGE)
    end

    it 'displays correct output when the game is a draw' do
      allow(board).to receive_messages(:winner => nil)
      console_ui.output = StringIO.new
      console_ui.display_result(board)
      expect(console_ui.output.string).to include(ConsoleUI::DRAW_MESSAGE)
    end
  end
end
