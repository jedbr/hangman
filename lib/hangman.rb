require 'colorize'
require 'pstore'

class Hangman
  def initialize
    dictionary = []

    File.foreach('5desk.txt') do |line|
      current_line = line.chomp
      dictionary << current_line.upcase if current_line.size.between?(5, 12)
    end

    unless load_game?
      @phrase = dictionary.sample
      @guess = '_' * @phrase.size
      @lives = @phrase.size
      @incorrect = []
      @correct = []
      @game_won = false
    end
  end

  def play
    until @game_won == true || @lives == 0
      print_status
      make_guess
      update_status
    end
    finish_game
  end

  private

  def print_status
    system('clear')
    lives_to_print = '💖 '.red * @lives
    puts lives_to_print.ljust(@lives * 16 +
         (@phrase.size - @lives) * 2, '💖 '), "\n"
    puts @guess.scan(/./).join(' ').center(50), "\n"
    print 'Correct: '
    puts @correct.join(', ')
    print 'Incorrect: '
    puts @incorrect.join(', '), "\n"
  end

  def make_guess
    loop do
      puts "What's your next guess? (type 'menu' to open menu)"
      @letter = gets.chomp.upcase
      if @letter.size == 1
        if (@correct | @incorrect).include?(@letter)
          puts "Already checked! Try again.", "\n"
        else
          break
        end
      else
        if @letter.upcase == 'MENU'
          game_menu
        else
          puts 'Invalid input. Try again.', "\n"
        end
      end
    end
  end

  def update_status
    if @phrase.include? @letter
      @correct << @letter
      @phrase.each_char.with_index do |c, i|
        @guess[i] = c if c == @letter
      end
      @game_won = true if @guess == @phrase
    else
      @incorrect << @letter
      @lives -= 1
    end
  end

  def finish_game
    if @game_won
      puts "\n", "#{@guess}\n", 'Congratulations, you have won!'
    else
      puts "\n", 'You lose!'
      puts "Correct phrase: #{@phrase}"
    end
  end

  def game_menu
    print_status
    puts 'Game menu'
    puts '1. Save game'
    puts '2. Back to game'
    puts '3. Quit game'
    loop do
      case gets.chomp
      when "1"
        save_game
        return
      when "2" then return
      when "3" then exit
      else puts "Unknown command (type '1', '2' or '3')"
      end
    end
  end

  def save_game
    Dir.mkdir('saves') unless File.exists?('saves')
    print "Filename: "
    filename = "./saves/#{gets.chomp}"
    data = PStore.new(filename)
    data.transaction do
      data[:phrase] = @phrase
      data[:guess] = @guess
      data[:lives] = @lives
      data[:correct] = @correct
      data[:incorrect] = @incorrect
      data.commit
    end
    puts "Game saved.\n"
  end

  def load_game?
    puts "Welcome to Hangman!\n1. New game\n2. Load game\n3. Quit"
    loop do
      case gets.chomp
      when "1" then return false
      when "2"
        load_game
        return true
      when "3" then exit
      else puts "Unknown command (type '1', '2' or '3')"
      end
    end
  end

  def load_game

  end
end