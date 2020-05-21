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
		PEGS[color]
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
	end

	def display
		p "    MasterMind " 
		p "--------------------"
		for i in 0..9
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

		for i in black_pins..black_pins+white_pins-1
			check[round][i]=PEGS[:white]
		end

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
	end

	def player_wins?
		return @right_guess ==4
	end

	def full_board?
		return @board.guesses[9][3]!=" "
	end

	def copy_pattern(pattern)
		copy =[]
		pattern.each_with_index do |value, index|
			copy[index] = value
		end
		return copy
	end

	def check(correct_pattern,guess)
		@right_guess = 0
		right_colors =0
		coppied_pattern = copy_pattern(correct_pattern)

		coppied_pattern.each_with_index do |value, index|
			if value == guess[index]
				@right_guess += 1
				guess[index] = nil
				coppied_pattern[index] = nil
			end
		end

		guess.delete(nil)
		coppied_pattern.delete(nil)

		coppied_pattern.each do |value|
			if guess.any?(value)
				right_colors +=1
			end
		end

		return [@right_guess,right_colors]
	end

	def play()
		puts "would you like to play against the computer?"
		computer_play = gets.chomp.downcase[0]=='y'

		if computer_play
			correct_pattern = @mastermind.random_pattern
		else
			correct_pattern = @mastermind.choose_pattern
		end

		puts ""
		round =1
		@right_guess = 0
		until player_wins? or full_board?
			suffixes =["st", "nd", "rd", "th"]
			guess =[]

			for i in 0..3
				puts "Round #{round}"
				puts "pick your #{i+1}#{suffixes[i]} peg"
				guess[i] = pick_peg
				@board.set(round-1,i,guess[i])
				@board.display
			end

			black_pins, white_pins = check(correct_pattern,guess)
			@board.reveal(round-1,black_pins, white_pins)
			@board.display
			round +=1
		end

		puts "the correct correct_pattern is"
		@mastermind.show_pattern

		if player_wins?
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
end

my_game = Game.new
my_game.play