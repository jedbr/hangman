require 'colorize'

class Hangman
  def initialize
    dictionary = []

    File.foreach('5desk.txt') do |line|
      current_line = line.chomp
      dictionary << current_line.upcase if current_line.size.between?(5, 12)
    end

    @phrase = dictionary.sample
    @guess = '_' * @phrase.size
    @lives = @phrase.size
    @incorrect = []
    @correct = []
    @game_won = false
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
    choice = ''
    until choice.to_i.between?(1, 3)
      choice = gets.chomp
      case choice
      when "1" then save_game
      when "2" then return
      when "3" then exit
      end
    end
  end

  def save_game
    puts 'Game saved.'
  end
end