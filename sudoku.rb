require 'sinatra'

require 'sinatra/partial' 
set :partial_template_engine, :erb

require 'rack-flash'
use Rack::Flash

require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions 

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def easy_puzzle(sudoku)
  nil_positions = Array.new(40, 1).map {|one| one * rand(81)}
  puzzle = sudoku.map {|i| i }
  nil_positions.each { |n| puzzle[n] = '' }
  puzzle
end

def hard_puzzle(sudoku)
  nil_positions = Array.new(56, 1).map {|one| one * rand(81)}
  puzzle = sudoku.map {|i| i }
  nil_positions.each { |n| puzzle[n] = '' }
  puzzle
end

def box_order_to_row_order(cells)
  box_indicies = ([0,3,6,27,30,33,54,57,60].map{ |i| [i, i+1, i+2, i+9, i+10, i+11,i+18, i+19, i+20]}).flatten
  box_indicies.map{|box_index| cells[box_index]}
end

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = easy_puzzle(sudoku)
  session[:current_solution] = session[:puzzle]
end

def generate_new_hard_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = hard_puzzle(sudoku)
  session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  if @check_solution
    flash[:notice] = "Incorrect values are highlighted in yellow"
  end
  session[:check_solution] = nil 
end

get '/' do 
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  sudoku = random_sudoku
  erb :index
end

get '/solution' do
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  @current_solution = session[:solution]
  erb :index
end

post '/' do
  cells = box_order_to_row_order(params["cell"])
  session[:current_solution] = cells.map {|value| value }
  session[:check_solution] = true
  redirect to ("/")
end

get '/hard' do
  session[:current_solution] = nil
  prepare_to_check_solution
  generate_new_hard_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  sudoku = random_sudoku
  erb :index
end

helpers do

  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value == ''
    tried_to_guess = current_solution_value != ''
    guessed_incorrectly = current_solution_value != solution_value

    if solution_to_check && 
        must_be_guessed && 
        tried_to_guess && 
        guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value-provided'
    end
  end

  def cell_value(value)
    # value.to_i == 0 ? '' : value
    value 
  end 

end


