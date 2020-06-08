require 'yaml'

class Board

	attr_accessor :correct_guesses
	attr_accessor :hangman
	attr_accessor :wrong_guesses
	attr_accessor :num_wrong_guess
	attr_reader :deadman

	def initialize(saved_board=false, data ={})
		pick_word

		@hangman =[" "," "," "," "," ", " ", " "]
		@deadman = ['0', "|", "/", "\\", "|", "/", "\\" ]
		@num_wrong_guess = 0
		@correct_guesses =[]
		@wrong_guesses =[]
		box = ["\u25A2"]
		for i in 0...word_to_guess.length
			@correct_guesses[i] = box
		end
		if saved_board
			@hangman=data[:hangman]
			@word_to_guess = data[:word_to_guess]
			@num_wrong_guess = data[:num_wrong_guess]
			@correct_guesses = data[:correct_guesses]
			@wrong_guesses = data[:wrong_guesses]
		end
	end


	def show_board
		puts "__HangMan__"
		puts "wrong guesses #{wrong_guesses.join(" ")}"
		puts " ___ "
		puts "|   |"
		puts "|   #{hangman[0]}"
		puts "|  #{hangman[2]}#{hangman[1]}#{hangman[3]}"
		puts "|   #{hangman[4]}"
		puts "|  #{hangman[5]} #{hangman[6]}"
		puts "|_______"
		puts "correct guesses #{correct_guesses.join(" ")}"
	end

	attr_accessor :word_to_guess
	def pick_word()
		dictionary= File.open('dict.txt')
		@word_to_guess =""

		while @word_to_guess.length <4
			dictionary_length = dictionary.count
			dictionary.rewind
			random_index = rand(dictionary_length)

			dictionary.each_with_index do |word,line_num|
				if line_num == random_index
					@word_to_guess = word[0..-3]
					break
				end
			end
		end
	end

	def check_letter(letter)
		positions =[]
		word_to_guess.split("").each_with_index do |right_letter, position|
			if letter == right_letter
				positions.push(position)
			end
		end
		positions
	end


	def set_letter(character)
		if correct_guesses.any?(character) or wrong_guesses.any?(character)
			puts "Already guessed!, guess again"
			new_letter = gets.chomp
			set_letter(new_letter)
		elsif word_to_guess.split("").any?(character)
			spots = check_letter(character)
			spots.each do |position|
				correct_guesses[position]=character
			end
			true
		else 
			wrong_guesses.push(character)
			hangman[num_wrong_guess] = deadman[num_wrong_guess]
			@num_wrong_guess += 1
			false
		end
	end

	def player_win?
		return correct_guesses.join("")==word_to_guess
	end

	def player_lose?
		return hangman[6] == "\\"
	end

	def to_yaml
		YAML.dump ({
			:hangman => @hangman,
			:num_wrong_guess => @num_wrong_guess,
			:correct_guesses => @correct_guesses,
			:wrong_guesses => @wrong_guesses,
			:word_to_guess => @word_to_guess
		})
	end


	def self.from_yaml(string)
		data = YAML.load string
		self.new(true, data)	
	end	
end

class Game

	attr_accessor :our_board
	def initialize(saved_game = false, file ="")
		if saved_game
			@our_board = Board.from_yaml(file)
		else
			@our_board = Board.new
		end
	end

	def self.load_saved_game(file)
		file = File.open(file,'r')
		file = IO.read(file)
		self.new(true, file)
	end

	def save_file
		file_name = "saved_hangman.txt"
		saved_game = our_board.to_yaml
		File.write(file_name, saved_game, mode: 'w+')
		exit()
	end

	def end_round(win)
		if win
			puts "congratz, you slayed"
		else
			puts "sorry, yOU WRONG"
			puts "The word was #{our_board.word_to_guess}"
		end
		puts "play again? [y/n]"
		gets.chomp
	end

	def play
		puts "continue saved gaame or start new one? [contine/start]"
		response = gets.chomp[0]
		if response =='c'
			@our_board = Game.load_saved_game("saved_hangman.txt").our_board
			@our_board.show_board
		else
			@our_board = Board.new
		end
		until @our_board.player_win? or @our_board.player_lose?
			@our_board.show_board
			puts "guess letter or type 'save' to save"
			response = gets.chomp
			if response == 'save'
				save_file
			end
			if@our_board.set_letter(response)
				puts "Correct! nice"
			else
				puts "errrr, nah"
			end
		end

		response = end_round(@our_board.player_win?)

		if response[0]=='y'
			@our_board = Board.new
			play
		end
		puts "dueces"
	end
end

Game.new.play