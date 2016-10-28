require 'colorize'
require 'pstore'

class Hangman
  def initialize
    @dictionary = []

    File.foreach('5desk.txt') do |line|
      current_line = line.chomp
      @dictionary << current_line.upcase if current_line.size.between?(5, 12)
    end
  end

  def play
    loop do
      setup && system("clear")
      until @game_won == true || @lives == 0
        print_status
        make_guess
        update_status
      end
      finish_game
      gets && system("clear")
    end
  end

  private

  def setup
    unless load_game?
      @phrase = @dictionary.sample
      @guess = '_' * @phrase.size
      @lives = @phrase.size
      @incorrect = []
      @correct = []
      @game_won = false
    end
  end

  def print_status(final = false)
    system('clear')
    print_lives
    puts @guess.scan(/./).join(' ').center(50), "\n"
    unless final
      print 'Correct: '
      puts @correct.join(', ')
      print 'Incorrect: '
      puts @incorrect.join(', '), "\n"
    end
  end

  def print_lives
    lives_to_print = '💖 '.red * @lives
    puts lives_to_print.ljust(@lives * 16 +
         (@phrase.size - @lives) * 2, '💖 '), "\n"
  end

  def make_guess
    loop do
      puts "What's your next guess? (type 'menu' to open menu)"
      @letter = gets.chomp.upcase
      if @letter.match(/^[[:alpha:]]$/)
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
    print_status(true)
    if @game_won
      puts "\nCongratulations, you have won!"
    else
      puts "\n#{@phrase}\nYou lose!"
    end
  end

  def game_menu
    print_status
    puts 'Game menu'
    puts "1. Save game\n2. Back to game\n3. Quit game"
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
    Dir.mkdir('saves') unless File.exist?('saves')
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
    system("clear")
    puts "Welcome to Hangman!\n1. New game\n2. Load game\n3. Quit"
    loop do
      case gets.chomp
      when "1" then return false
      when "2"
        return load_game
      when "3" then exit
      else puts "Unknown command (type '1', '2' or '3')"
      end
    end
  end

  def load_game
    filename = filename_to_load
    unless filename.upcase == "SAVES/NEW"
      data = PStore.new(filename)
      data.transaction do
        @phrase = data[:phrase]
        @guess = data[:guess]
        @lives = data[:lives]
        @correct = data[:correct]
        @incorrect = data[:incorrect]
      end
      return true
    else
      return false
    end
  end

  def filename_to_load
    while true
      filename = "saves/"
      print "\nFile to load: "
      filename += gets.chomp
      break if File.exist?(filename) || filename.upcase == "SAVES/NEW"
      puts "File does not exist. Try again. (type 'new' to start new game)"
    end
    filename
  end
end