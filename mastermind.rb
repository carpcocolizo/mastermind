# frozen_string_literal: true

class CodeGame
  @@colorspool = %w[red blue green yellow pink orange]

  def randomselection
    secretcode = []
    4.times do
      secretcode.push(@@colorspool[rand(6)])
    end
    secretcode
  end
end

class Computer < CodeGame
  attr_reader :secretcode

  def initialize
    @@colors = %w[red blue green yellow pink orange]
    @@colorsspool = []
    @@lasttry = 'red'
  end

  def newcode
    @secretcode = randomselection
  end

  def random1color
    colors = %w[blue green yellow pink orange]
    random = []
    selection = []
    random.push(colors[rand(5)])
    4.times do
      selection.push(random.join)
    end
    @@lasttry = selection[0]
    selection
  end

  def randomcolors
    selection = []
    selection.push(@@colorsspool).flatten!
    random = []
    random.push(@@colors[rand(@@colors.length)])
    selection.push(random.join) until selection.length == 4
    @@colorsspool.push(random[0])
    @@lasttry = random[0]
    selection
  end

  def findcode(guess)
    if guess.nil?
      %w[red red red red]
    elsif guess == []
      @@colors.delete(@@lasttry)
      @@lasttry = ''
      random1color
    elsif guess.length.positive? && guess.length < 4 && @@colorsspool.length <= guess.length
      @@colorsspool.push(@@lasttry) until @@colorsspool.length == guess.length
      @@colors.delete(@@lasttry)
      randomcolors
    elsif guess.length.positive? && guess.length < 4 && @@colorsspool.length > guess.length
      @@colorsspool.delete(@@lasttry)
      @@colors.delete(@@lasttry)
      randomcolors
    elsif guess.length == 4
      @@colorsspool - ['']
      @@colorsspool.push(@@lasttry) until @@colorsspool.length == 4
      @@colorsspool.shuffle
    end
  end
end

class BreakGame
  def inputbreak(trycode)
    puts 'Please, select four colors, press enter after each entry'
    until trycode.length == 4
      ans = gets.chop.downcase
      case ans
      when 'red', 'blue', 'green', 'yellow', 'pink', 'orange'
        trycode.push(ans)
      else
        puts 'Invalid answer, try again, write one of red, blue, green, yellow, pink or orange'
        puts "Your selection until now is #{trycode}"
      end
    end
    trycode
  end
end

class Human < BreakGame
  attr_reader :trycode, :playersecret

  def playerguess
    try = []
    @trycode = inputbreak(try)
  end

  def playercode
    secretcode = []
    puts 'Please, create a code, press enter after each entry'
    until secretcode.length == 4
      ans = gets.chop.downcase
      case ans
      when 'red', 'blue', 'green', 'yellow', 'pink', 'orange'
        secretcode.push(ans)
      else
        puts 'Invalid answer, try again, write one of red, blue, green, yellow, pink or orange'
        puts "Your selection until now is #{secretcode}"
      end
    end
    @playersecret = secretcode
    secretcode
  end
end

class Game
  attr_accessor :guess

  def newgame
    puts(<<-EOT)
           HELLO, YOU ARE GOING TO PLAY A GAME OF MASTERMIND
           THE COMPUTER WILL GENERATE A CODE AND YOU HAVE TO BREAK IT
           YOU HAVE TO SELECT 4 OF THE FOLLOWING COLORS.
           RED, BLUE, GREEN, YELLOW, PINK and ORANGE
           THEY CAN BE IN ANY ORDER AND CAN BE REPEATED THRUOGH THE CODE
           YOU HAVE 12 TURNS TO SOLVE THE CODE
           AND AFTER EACH TURN YOU WILL GET A FEEDBACK
           YOU GET an "X" FOR GUESSING THE CORRECT COLOR AND POSITION#{' '}
           AND YOU GET a "o" FOR GUESSING THE CORRECT COLOR BUT NO THE POSITION
           BUT YOU DONT GET TO KNOW WHICH OF YOUR GUESSES ARE RIGHT
    EOT
    @computer = Computer.new
    @player = Human.new
    @@turns = 12
    playthegame
  end

  def newgameinverted
    puts(<<-EOT)
             HELLO, YOU ARE GOING TO PLAY A GAME OF MASTERMIND
             YOU WILL GENERATE A CODE AND THE COMPUTER WILL HAVE TO BREAK IT
             YOU HAVE TO SELECT 4 OF THE FOLLOWING COLORS.
             RED, BLUE, GREEN, YELLOW, PINK and ORANGE
             THEY CAN BE IN ANY ORDER AND CAN BE REPEATED THRUOGH THE CODE
             THE COMPUTER HAVE 12 TURNS TO SOLVE THE CODE
             YOU WILL SEE THE FEEDBACK AFTER EACH TURN
             AN "X" is FOR GUESSING THE CORRECT COLOR AND POSITION#{' '}
             A "o" is FOR GUESSING THE CORRECT COLOR BUT NO THE POSITION
    EOT
    @computer = Computer.new
    @player = Human.new
    @@turns = 12
    playinvertedgame
  end

  def playinvertedgame
    @player.playercode
    until @@turns.zero?
      puts "THERE IS #{@@turns} turns remaining"
      computerguess = @computer.findcode(@guess)
      puts "THE COMPUTER GUESS IS #{computerguess}"
      sleep(2)
      feedback(@player.playersecret, computerguess)
      @@turns -= 1
    end
    if @@turns.zero?
      puts 'YOU WIN, THE CODE WAS TOO GOOD FOR THE COMPUTER'
      askforplay
    end
  end

  def playthegame
    @computer.newcode
    until @@turns.zero?
      puts "YOU HAVE #{@@turns} turns remaining"
      @player.playerguess
      feedback(@computer.secretcode, @player.trycode)
      @@turns -= 1
      puts "YOU LOST, THE SECRET CODE WAS #{@computer.secretcode}" if @@turns.zero?
    end
  end

  def feedback(secretcode, trycode)
    if secretcode == trycode
      puts 'THE CODE IS BREAK, GAME ENDED'
      askforplay
      @@turns = 1
    end
    guess = []
    revistedcode = []
    secretcode.each { |color| revistedcode.push(color) }
    trycode.each_with_index do |color, pos|
      next unless secretcode[pos] == color

      guess.push('X')
      revistedcode[pos] = 'X'
      trycode[pos] = 'Z'
    end
    revistedcode.each_with_index do |color, pos|
      next unless trycode.include?(color)

      guess.push('o')
      revistedcode[pos] = 'O'
      trycode[trycode.find_index(color)] = 'M'
    end
    puts(<<-EOT)
           THE FEEDBACK IS #{guess.sort}
    EOT
    @guess = guess
  end

  def askforplay
    puts 'You Wanna play again? (Y/N)'
    ans = gets.chop
    case ans
    when 'Y', 'y'
      Game.new.askfornewgame
    when 'N', 'n'
      puts 'Thanks for playing'
      exit
    else
      puts 'INVALID ANSWER'
      askforplay
    end
  end

  def askfornewgame
    puts 'Hey this is mastermind, do you wanna create a code or break it?'
    puts 'Select 1 to be the codebreaker and select 2 to create the code'
    ans = gets.chop
    case ans
    when '1'
      Game.new.newgame
    when '2'
      Game.new.newgameinverted
    else
      puts 'YOU HAVE TO SELECT 1 or 2'
      askfornewgame
    end
  end
end

newgame = Game.new.askfornewgame
