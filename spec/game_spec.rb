require_relative '../lib/game'
require_relative '../lib/computer_player'
require_relative '../lib/console_ui'

RSpec.describe Game do
  let(:game) { Game.new }
  let(:human_player) { game.human_player }
  let(:computer_player) { game.computer_player }

  describe "#determine_starting_marker" do
    it 'returns the human marker if the human player will go first' do
      expect(game.determine_starting_marker(human_player, Board::X_MARKER)).to eq(Board::X_MARKER)
    end

    it 'does not return the human marker if the human player does not go first' do
      expect(game.determine_starting_marker(computer_player, Board::X_MARKER)).not_to eq(Board::X_MARKER)
      expect(game.determine_starting_marker(computer_player, Board::X_MARKER)).to eq(Board::O_MARKER)
    end
  end

  describe "#switch_players" do
    it 'returns the human player if called with the computer player' do
      expect(game.switch_players(human_player)).to eq(computer_player)
    end

    it 'returns the computer player if called with the human player' do
      expect(game.switch_players(computer_player)).to eq(human_player)
    end
  end

end