class Board
	attr_accessor :board
	def initialize()
		@board = []
		for i in 1..9
			board[i] = " "
		end
	end

	def display_board()
		p "1  |2  |3  "
		p " #{board[1]} | #{board[2]} | #{board[3]} "
		p "___|___|___"
		p "4  |5  |6  "
		p " #{board[4]} | #{board[5]} | #{board[6]} "
		p "___|___|___"
		p "7  |8  |9  "
		p " #{board[7]} | #{board[8]} | #{board[9]} "
		p "   |   |   "
	end

	def set(symbol, location)
		if board[location]==" "
			board[location]= symbol
		else 
			return false
		end
	end

	def tied_game?()
		board.any?(" ") ? false :true
	end

	def round_won?

		def line_win?(line)
			symbol = line[0]
			if symbol==" "
				return false
			else
				return line.all?(symbol)
			end
		end

		for i in 0..2
			row_i =[board[3*i+1],board[3*i+2],board[3*i+3]]
			col_i = [board[1+i],board[4+i],board[7+i]]
			
			if line_win?(row_i)
				return true
			elsif line_win?(col_i)
				return true
			end
		end
		
		left_diagonal = [board[1],board[5],board[9]]
		right_diagonal = [board[3],board[5],board[7]]

		if line_win?(left_diagonal)
			return true
		end

		return line_win?(right_diagonal)
	end
end

class Player
	attr_reader :score
	def initialize
		@score =0
	end

	attr_reader :players_name
	attr_reader :symbol 
	def prompt
		p "Player name?"
		@players_name = gets.chomp
		p "X's or O's?"
		@symbol = gets.chomp
	end

	def increment_score()
		@score +=1
	end
end


class Game

	attr_reader :player_1
	attr_reader :player_2
	attr_accessor :players_turn
	attr_accessor :board
	def initialize
		@player_1 = Player.new
		@player_1.prompt
		@player_2 = Player.new
		@player_2.prompt
		@board =Board.new
	end

	def pick_player(players_turn)
		players_turn ==0 ? player_1 : player_2
	end

	def take_turn(player)
		current_player = pick_player(player)

		p "It's Player #{player+1}'s turn, pick your space, (1-9)"
		spot = gets.chomp.to_i

		unless board.set(current_player.symbol, spot)
			p "Invalid move, please go again"
			take_turn(player)
		end

		board.set(current_player.symbol,spot)
	end

	def display_scores()
		p "The score is #{player_1.players_name}: #{player_1.score}"
		p "to #{player_2.players_name}: #{player_2.score}"
		p  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	end

	def play()
		players_turn = 1

		until board.round_won? or board.tied_game?
			players_turn = 1 - players_turn
			board.display_board
			take_turn(players_turn)
		end

		board.display_board
		pick_player(players_turn).increment_score

		p "#{pick_player(players_turn).players_name} won!"
		p  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		display_scores

		p "'nother round?"
		response = gets.chomp

		if response.downcase[0] =="y"
			@board = Board.new()
			play()
		end

		p "Thanks for playing!, final scores..."
		display_scores
	end


end

my_game = Game.new()
my_game.play()