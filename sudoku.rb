require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions 

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def puzzle(sudoku)
  nil_positions = Array.new(45, 1).map {|one| one * rand(81)}
  puzzle = sudoku.map {|i| i }

  nil_positions.each { |n| puzzle[n] = '' }

  # puzzle.each_with_index do |number, index|
  #   nil_positions.include?(index) ? '' : number 
  #   end
  puzzle
end


get '/' do 
  sudoku = random_sudoku
  session[:solution] = sudoku
  @current_solution = puzzle(sudoku)
  erb :index
end

get '/solution' do
  @current_solution = session[:solution]
  erb :index
end


