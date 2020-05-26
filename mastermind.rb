module Pins
	require 'colorize'
	COLORS =[:red, :blue, :green, :cyan, :magenta, :yellow, :white, :black]

	PEGS = {
		red: " ".colorize(:background => :red),
		blue: " ".colorize(:background => :blue),
		green: " ".colorize(:background => :green),
		cyan: " ".colorize(:background => :light_cyan),
		magenta: " ".colorize(:background => :magenta),
		yellow: " ".colorize(:background => :yellow),
		white: " ".colorize(:background => :white),
		black: " ".colorize(:background => :light_black)
	}

	def pick_peg
		puts "1 2 3 4 5 6 "

		for j in 0..5
			print "#{PEGS[COLORS[j]]} "
		end
		puts ""
		color = COLORS[gets.chomp.to_i-1]
		valid_choice?(color)
		PEGS[color]
	end

	def valid_choice?(color)
		if COLORS.slice(0,6).any?(color)
			return
		else
			puts "invalid choice"
			pick_peg
		end
	end
end


class Board
	include Pins

	attr_accessor :guesses
	attr_accessor :check

	def initialize()
		@guesses = []
		@check =[]
		for i in 0..9
			guesses[i] =[" ", " ", " ", " "]
			check[i] = [" ", " ", " ", " "]
		end
		@num_turns = 8
	end

	def display
		p "    MasterMind " 
		p "--------------------"
		for i in 0...@num_turns
			puts "| #{guesses[i][0]} | #{guesses[i][1]} | #{guesses[i][2]} | #{guesses[i][3]} ||#{check[i][0]}|#{check[i][1]}|"
			puts "|___|___|___|___||#{check[i][2]}|#{check[i][3]}|"
			puts "======================"
		end
	end

	def set(round, turn, guess)
		guesses()[round][turn] = guess
	end

	def reveal(round,black_pins, white_pins)
		for i in 0...black_pins
			check[round][i] =  PEGS[:black]
		end

		for i in black_pins...black_pins+white_pins
			check[round][i]=PEGS[:white]
		end
	end

	def player_wins?(guess, correct_pattern)
		return guess == correct_pattern
	end

	def full?
		return guesses[@num_turns-1][3]!=" "
	end
end

class Coder
	include Pins

	def random_pattern
		@pattern =[]
		for i in 0..3
			color = COLORS[rand(6)]
			@pattern[i] = PEGS[color]
		end
		@pattern
	end

	def choose_pattern
		@pattern =[]
		suffixes =["st", "nd", "rd", "th"]
		for i in 0..3
			puts "pick your #{i+1}#{suffixes[i]} peg"
			@pattern[i] = pick_peg
		end
		puts "your pattern is"
		show_pattern
		return @pattern
	end

	def show_pattern
		@pattern.each {|peg| print "#{peg} "}
		puts ""
	end
end

class Game
	include Pins

	def initialize
		@board = Board.new
		@mastermind = Coder.new
		@board.display
		@round_guess =[]
	end

	def player_wins?(correct_pattern)
		return @board.player_wins?(@round_guess, correct_pattern)
	end

	def copy_pattern(pattern)
		copy =[]
		pattern.each_with_index do |value, index|
			copy[index] = value
		end
		return copy
	end

	def pattern_this_round(round)
		suffixes =["st", "nd", "rd", "th"]
		for i in 0..3
			puts "Round #{round}"
			puts "pick your #{i+1}#{suffixes[i]} peg"
			@round_guess[i] = pick_peg
			@board.set(round-1,i,@round_guess[i])
			@board.display
		end
	end

	def right_position?(correct_pattern,player_guess)
		correct_pattern.each_with_index do |correct_peg, index|
			if player_guess[index] == correct_peg
				@right_guess += 1
				player_guess[index] = nil
				correct_pattern[index] = nil
			end
		end
	end

	def correct_colors(correct_pattern,player_guess)
		right_colors = 0
		correct_pattern.each do |value|
			if player_guess.any?(value)
				right_colors +=1
			end
		end
		return right_colors
	end

	def check(correct_pattern)
		@right_guess = 0

		correct_pattern = copy_pattern(correct_pattern)
		player_guess = copy_pattern(@round_guess)

		right_position?(correct_pattern,player_guess)

		player_guess.delete(nil)
		correct_pattern.delete(nil)

		white_pins = correct_colors(correct_pattern,player_guess)

		return [@right_guess,white_pins]
	end

	def choose_opponent()
		puts "would you like to play against the computer? [yes/no]"
		computer_play = gets.chomp.downcase[0]=='y'
		if computer_play
			correct_pattern = @mastermind.random_pattern
		else
			correct_pattern = @mastermind.choose_pattern
		end
	end

	def end_prompt(correct_pattern)
		puts "the correct correct_pattern is"
		@mastermind.show_pattern

		if player_wins?(correct_pattern)
			puts "You Win! Congratz."
		else
			puts "You Lost. Unfortunate"
		end

		puts" Play again? [yes/no]"
		response = gets.chomp[0].downcase

		if response =='y'
			@board = Board.new
			play()
		else
			puts "See ya"
		end
	end

	def play()
		correct_pattern = choose_opponent
		puts ""
		round =1

		@right_guess = 0

		until player_wins?(correct_pattern) or @board.full?
			pattern_this_round(round)
			black_pins, white_pins = check(correct_pattern)
			@board.reveal(round-1,black_pins, white_pins)
			@board.display
			round +=1
		end

		end_prompt(correct_pattern)
	end
end

Game.new.play