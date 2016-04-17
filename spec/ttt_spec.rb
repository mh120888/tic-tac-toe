require_relative '../ttt'

RSpec.describe Board do
  board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
  it "starts off with the correct number of empty board spaces" do
    expect(board.grid.length).to eq(9)
    expect(board.grid.join('').empty?).to eq(true)
  end

  it "has no winner before a game is played/by default" do
    expect(board.winner).to eq(false)
  end

  describe '#mark_board' do
    it "marks the board at the given spot with the given marker" do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_number = rand(9)
      board.mark_board(random_number, Board::X_MARKER)
      expect(board.grid[random_number]).to eq(Board::X_MARKER)
    end
  end

  describe '#check_if_winner' do
    it "returns false if there is no winner" do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      expect(board.check_if_winner(Board::X_MARKER)).to eq(false)
    end

    it "returns the winner's marker if there is a winner" do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_winning_combo = board.winning_combos[rand(board.winning_combos.length)]
      random_winning_combo.each do |index|
        board.mark_board(index, Board::X_MARKER)
      end
      expect(board.check_if_winner(Board::X_MARKER)).to eq(Board::X_MARKER)
    end
  end

  describe '#board_full?' do
    it 'returns false for a new board' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      expect(board.board_full?).to eq(false)
    end

    it 'returns false for a partially filled out board' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_number_of_marks = rand(9)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.board_full?).to eq(false)
    end

    it 'returns true for a completely filled out board' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      (0..9).to_a.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.board_full?).to eq(true)
    end
  end

  describe "#all_taken_spaces" do
    it 'returns an empty array by default' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      expect(board.all_taken_spaces.empty?).to eq(true)
    end

    it 'returns [0, 1, 2] if those spaces are hard-coded' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      board.grid[0] = Board::X_MARKER
      board.grid[1] = Board::O_MARKER
      board.grid[2] = Board::X_MARKER
      expect(board.all_taken_spaces).to eq([0, 1, 2])
    end

    it 'returns the correct indices for a randomly marked board' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.all_taken_spaces).to eq(random_indices)
    end
  end

  describe '#all_free_spaces' do
    it 'returns a board with nine free spaces by default' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      expect(board.all_free_spaces.length == 9).to eq(true)
    end

    it 'returns the correct number of free spaces for a board that has been played on' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks)
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_indices.each { |index| board.grid[index] = ([Board::X_MARKER, Board::O_MARKER].sample) }
      expect(board.all_free_spaces.length).to eq(9 - random_number_of_marks)
    end

    it 'correctly identifies which spaces are free' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      (0..8).to_a.each { |index| board.mark_board(index, Board::X_MARKER) }
      random_indices.each { |index| board.grid[index] = (Board::EMPTY_SPACE) }
      expect(board.all_free_spaces).to eq(random_indices)
    end
  end

  describe "#spaces_taken_by" do
    it 'returns an empty array by default' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      expect(board.spaces_taken_by(Board::X_MARKER).empty?).to eq(true)
    end

    it 'returns [0, 1, 2] if those spaces are hard-coded' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      board.grid[0] = Board::X_MARKER
      board.grid[1] = Board::X_MARKER
      board.grid[2] = Board::X_MARKER
      expect(board.spaces_taken_by(Board::X_MARKER)).to eq([0, 1, 2])
    end

    it 'returns the correct indices for a randomly marked board' do
      random_number_of_marks = rand(10)
      random_indices = (0..8).to_a.sample(random_number_of_marks).sort
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      random_indices.each { |index| board.grid[index] = Board::X_MARKER }
      expect(board.spaces_taken_by('x')).to eq(random_indices)
    end
  end

  describe '#find_winning_indices' do
    it 'returns an empty array for an empty board (e.g. a board without a win)' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      marked_spaces = []
      expect(board.find_winning_indices(marked_spaces).empty?).to eq(true)
    end

    it 'returns an array of the winning indices when the supplied marked spaces contain a winning combo' do
      board = Board.new(Board::X_MARKER, Board::O_MARKER, 3)
      marked_spaces = [0, 1, 2, 5, 6]
      expect(board.find_winning_indices(marked_spaces)).to eq([0, 1, 2])
    end
  end
end