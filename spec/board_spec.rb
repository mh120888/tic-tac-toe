require_relative '../lib/board'

RSpec.describe Board do
  let(:board) { Board.new(Board::X_MARKER, Board::O_MARKER, 3) }

  it "starts off with the correct number of empty board spaces" do
    expect(board.grid.length).to eq(9)
    expect(board.grid.select { |space| space == Board::EMPTY_SPACE }.length).to eq(9)
  end

  it "has no winner before a game is played/by default" do
    expect(board.winner).to eq(false)
  end

  describe '#mark_board' do
    it "marks the board at the given spot with the given marker" do
      spot_to_mark = rand(9)
      board.mark_board(spot_to_mark, Board::X_MARKER)
      expect(board.grid[spot_to_mark]).to eq(Board::X_MARKER)
    end
  end

  describe '#unmark_board' do
    it 'removes a mark from the board at a given spot' do
      spot_to_mark = rand(9)
      board.mark_board(spot_to_mark, Board::X_MARKER)
      board.unmark_board(spot_to_mark)
      expect(board.grid[spot_to_mark]).to eq(Board::EMPTY_SPACE)
    end

    it 'switches turns' do
      first_player = board.turn
      board.mark_board(1, first_player)
      second_player = board.turn
      board.unmark_board(1)
      expect(board.turn).to eq(first_player)
    end

    it 'updates the winner' do
      board.mark_board(0, Board::X_MARKER)
      board.mark_board(1, Board::X_MARKER)
      board.mark_board(2, Board::X_MARKER)
      expect(board.winner).to equal(Board::X_MARKER)
      board.unmark_board(2)
      expect(board.winner).to equal(false)
    end
  end

  describe '#check_if_winner' do
    it "returns false if there is no winner" do
      expect(board.check_if_winner(Board::X_MARKER)).to eq(false)
    end

    it "returns the winner's marker if there is a winner" do
      random_winning_combo = board.winning_combos[rand(board.winning_combos.length)]
      random_winning_combo.each do |index|
        board.mark_board(index, Board::X_MARKER)
      end
      expect(board.check_if_winner(Board::X_MARKER)).to eq(Board::X_MARKER)
    end
  end

  describe "#valid_move?" do
    it 'returns true for a valid move' do
      expect(board.valid_move?(2)).to eq(true)
    end

    it 'returns false for an already marked space' do
      board.mark_board(3, Board::X_MARKER)
      expect(board.valid_move?(3)).to eq(false)
    end

    it 'returns false for a space that does not exist' do
      expect(board.valid_move?(30)).to eq(false)
    end
  end

  describe '#number_of_spaces' do
    it 'returns the number of total spaces on a board' do
      expect(board.number_of_spaces).to eq(9)
    end
  end

  describe '#board_full?' do
    it 'returns false for a new board' do
      expect(board.board_full?).to eq(false)
    end

    it 'returns false for a partially filled out board' do
      random_number_of_marks = rand(9)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.board_full?).to eq(false)
    end

    it 'returns true for a completely filled out board' do
      (0..9).to_a.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.board_full?).to eq(true)
    end
  end

  describe "#all_taken_spaces" do
    it 'returns an empty array by default' do
      expect(board.all_taken_spaces.empty?).to eq(true)
    end

    it 'returns [0, 1, 2] if those spaces are hard-coded' do
      board.grid[0] = Board::X_MARKER
      board.grid[1] = Board::O_MARKER
      board.grid[2] = Board::X_MARKER
      expect(board.all_taken_spaces).to eq([0, 1, 2])
    end

    it 'returns the correct indices for a randomly marked board' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.all_taken_spaces).to eq(random_indices)
    end
  end

  describe '#all_free_spaces' do
    it 'returns a board with nine free spaces by default' do
      expect(board.all_free_spaces.length == 9).to eq(true)
    end

    it 'returns the correct number of free spaces for a board that has been played on' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks)
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.all_free_spaces.length).to eq(9 - random_number_of_marks)
    end

    it 'correctly identifies which spaces are free' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      (0..8).to_a.each { |index| board.mark_board(index, Board::X_MARKER) }
      random_indices.each { |index| board.grid[index] = (Board::EMPTY_SPACE) }
      expect(board.all_free_spaces).to eq(random_indices)
    end
  end

  describe "#spaces_taken_by" do
    it 'returns an empty array by default' do
      expect(board.spaces_taken_by(Board::X_MARKER).empty?).to eq(true)
    end

    it 'returns [0, 1, 2] if those spaces are hard-coded' do
      board.grid[0] = Board::X_MARKER
      board.grid[1] = Board::X_MARKER
      board.grid[2] = Board::X_MARKER
      expect(board.spaces_taken_by(Board::X_MARKER)).to eq([0, 1, 2])
    end

    it 'returns the correct indices for a randomly marked board' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      random_indices.each { |index| board.grid[index] = Board::X_MARKER }
      expect(board.spaces_taken_by('x')).to eq(random_indices)
    end
  end

  describe '#find_winning_indices' do
    it 'returns an empty array for an empty board (e.g. a board without a win)' do
      marked_spaces = []
      expect(board.find_winning_indices(marked_spaces).empty?).to eq(true)
    end

    it 'returns an array of the winning indices when the supplied marked spaces contain a winning combo' do
      marked_spaces = [0, 1, 2, 5, 6]
      expect(board.find_winning_indices(marked_spaces)).to eq([0, 1, 2])
    end
  end
end
