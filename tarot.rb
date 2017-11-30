require 'singleton'
require 'numbers_and_words'
require_relative 'meanings'

# Global settings
$lineWidth = 80

# Utilities
class String
  def cyan
    "\e[36m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end
end

def title string
  puts
  puts "~" * $lineWidth
  puts string.upcase.center($lineWidth).red
  puts "~" * $lineWidth
  puts
end

def subtitle string
  puts
  puts " #{string.upcase} ".center($lineWidth, "~").red
  puts
end

def dialogue string
  puts string.cyan
  puts
end

def pause time = 1
  sleep time
  puts # line break
end

def continue? string = "Press enter when you're ready to continue"
  puts string
  puts
  continue = gets.chomp
end

# DEBUG
def print_deck
  pack = Array.new

  $deck.cards.each do | card |
    pack << "#{card.title} (#{card.reversed?})"
  end

  puts pack
  puts
end

def print_card card
  puts "#{card.title.upcase} #{card.suit} (Reversed: #{card.reversed?}) - #{card.meaning}"
  puts
end

# Modeling
class Card
  attr_reader :title, :number, :suit
  attr_writer :reversed

  @@cards = Array.new

  def initialize(title, number, suit, meaning, meaning_reversed)
    @title = title
    @number = number.to_s
    @suit = suit
    @meaning = meaning
    @meaning_reversed = meaning_reversed

    @@cards << self
  end

  def reversed?
    @reversed || false
  end

  def meaning
    if reversed?
      @meaning_reversed
    else
      @meaning
    end
  end

  def display
    puts "#{$username}".center($lineWidth/3)
    puts self.number.blue.center($lineWidth/3)
    puts self.title.cyan.center($lineWidth/3)
    puts self.meaning.blue.center($lineWidth/3)
    puts
  end

  def self.s # 'Card.s'
    @@cards
  end

  def self.s= cards
    @@cards = cards
  end
end

class Deck
  include Singleton

  def initialize
    @cards = Card.s
  end

  def shuffle!
    @cards.shuffle! # shuffle at least once
    orient_cards # simulate card reversal
    shuffling # continue shuffling if they like
  end

  def draw!
    @cards.shift
  end

  def cards
    @cards
  end

  private

    def shuffling
      dialogue("Would you like me to mix these up more?")
      choice = generate_menu(["no", "yes"])
      if choice == "no"
        dialogue("These seem pretty well mixed.")
      else
        @cards.shuffle!
        orient_cards
        pause
        shuffling
      end
    end

    def orient_cards
      @cards.each do | card | 
        if rand.round == 0
          card.reversed = false
        else
          card.reversed = true
        end
      end
    end
end

class Spread
  attr_reader :steps, :title
  attr_accessor :cards

  @@spreads = Array.new

  def initialize(title, steps, cards = [])
    @steps = steps
    @cards = cards
    @title = title

    @@spreads << self
  end

  def place_card card
    @cards << card
  end

  def self.s # 'Spread.s'
    @@spreads
  end

  def self.s= spreads
    @@spreads = spreads
  end

  # def sort

  # end
end

#UI
def make_menu_hash options
  Hash[options.each_with_index.map{|e,i| [i+1, e] }]
end

def render_menu menu_hash
  menu_hash.each{|k,v| puts "  [#{k}]".blue + " #{v}".cyan}
  puts
end

def show_menu menu_hash
  render_menu menu_hash
  get_menu_selection menu_hash
end

def get_menu_selection menu_hash
  print "Choose a number > "
  i = STDIN.gets.strip.to_i
  puts
  if i > menu_hash.count
    puts "That number is out of range.".red
  end
  puts
  menu_hash.fetch(i, nil)
end

def generate_menu options
  until selection = show_menu(make_menu_hash( options )); end
  return selection
end

# Game logic
def reset
  $deck = nil # Clear deck
  Card.s = Array.new # Clear cards
  Spread.s = Array.new # Clear spreads

  # Define cards
  define_cards # trigger meanings.rb
  
  # Card.new( "The Fool",            0,  :trump, "Beginnings, innocence, journey, spontaneity, a free spirit" )
  # Card.new( "The Magician",        1,  :trump, "Intention, focus, will power, skill, purpose, creativity, resourcefulness" )
  # Card.new( "The High Priestess",  2,  :trump, "Intuition, higher powers, wisdom, secrets, subconscious mind" )
  # Card.new( "The Empress",         3,  :trump, "Fertility, mother, lover, nature, protection, abundance" )
  # Card.new( "The Emperor",         4,  :trump, "Authority, father-figure, leadership, structure, logic, power" )
  # Card.new( "The Hierophant",      5,  :trump, "Organizations, religion, group, identifucation, social rules, tradition, school" )
  # Card.new( "The Lovers",          6,  :trump, "Relationships, love, communication, union, harmony, choices" )
  # Card.new( "The Chariot",         7,  :trump, "Direction, control, will power, victory, ambition, travel" )
  # Card.new( "The Strength",        8,  :trump, "Fortitude, inner strength, love, patience, compassion" )
  # Card.new( "The Hermit",          9,  :trump, "Solitude, soul-searching, introspection, being alone, inner guidance" )
  # Card.new( "Wheel of Fortune",    10, :trump, "Fate, good luck, karma, life cycles, destiny, changes, big picture" )
  # Card.new( "Justice",             11, :trump, "Justice, fairness, truth, law, logic, balance" )
  # Card.new( "The Hanged Man",      12, :trump, "Sacrifice, restriction, letting go, evaluation, new perspective" )
  # Card.new( "Death",               13, :trump, "Transformation, ending, beginning, transition" )
  # Card.new( "Temperance",          14, :trump, "Balance, moderation, mix, patience, adjusting" )
  # Card.new( "The Devil",           15, :trump, "Shackles, fear, self-restriction, addiction, lust, the dark side of self" )
  # Card.new( "The Tower",           16, :trump, "Destruction, false securities, upheaval, sudden change, a wake-up call" )
  # Card.new( "The Star",            17, :trump, "Hope, guidance, relief, inspiration, harmony" )
  # Card.new( "The Moon",            18, :trump, "Illusions, intuition, the unknown, fear, subconscious" )
  # Card.new( "The Sun",             19, :trump, "Illumination, clarity, fun, warmth, success, vitality, clarity" )
  # Card.new( "Judgment",            20, :trump, "Awakening, rebirth, inner calling, new perspective" )
  # Card.new( "The World",           21, :trump, "Enlightenment, completion, travel, perfect unity, accomplishment" )


  # Define Spreads
  Spread.new("Past, Present, Future", ["the past of", "the present state of", "the future of"])
  Spread.new("Relationship Spread", ["your state in", "the other person's state in", "both of you together in"])
  Spread.new("The Blindspot", ["something everyone knows about", 
                               "something others know but you do not about", 
                               "something you know and others don't about", 
                               "something no one knows about"])
  Spread.new("Celtic Cross", [ "",
                               "the main cause of",
                               "concious driving forces within",
                               "hidden forces, like emotions, you may not be aware of within",
                               "the immediate past of",
                               "the *immediate* future of",
                               "your attitude towards",
                               "external influences, like other people, on",
                               "your expectations, or perhaps hopes and fears regarding",
                               "the long term outcome of"])

  # init deck
  $deck = Deck.instance
end

def reading
  reset
  dialogue("I can do a few different types of readings.")
  dialogue("Which would you like?")

  # Map spread option titles to array
  spread_options = []
  Spread.s.each do | option |
    spread_options << "#{option.title} (#{option.steps.count} cards)"
  end

  # Make menu based on options array and store user choice
  spread_selection = generate_menu( spread_options )

  # Convert user choice back into a usable object
  current_spread = Spread.s.find {|spread| spread_selection.include? spread.title }

  dialogue("Thank you, give me a moment to shuffle the cards.")
  dialogue("Take this moment to focus on the situation in question.")
  pause 3
  $deck.shuffle!

  subtitle current_spread.title

  current_spread.steps.each_with_index do |step, i|
    continue? "Hit enter to draw the #{current_spread.steps[-1] == current_spread.steps[i] ? 'final' : (i+1).to_words(ordinal: true)} card."
    current_spread.place_card $deck.draw!

    card = current_spread.cards[i]

    puts "The #{(i+1).to_words ordinal: true} position represents #{current_spread.steps[i]} the situation.".blue.center($lineWidth)
    puts
    puts "You have drawn #{card.title}#{card.reversed? ? ', reversed' : ''}.".red.center($lineWidth)
    puts
    puts "It signifies #{card.meaning.downcase}.".blue.center($lineWidth)
    puts

    dialogue("Please take a moment to think about what this means for the situation you had in mind.")
  end

  dialogue("That concludes this reading. Would you like to do another one?")

  choice = generate_menu(["no", "yes"])
  choice == "no" ? dialogue("I hope this was insightful.") : reading # run another reading
end

def read_themes spread

end

# themes ( spread.cards )
  # count number of trumps
    # if count higher than x, return relevant string
  # count each suit
    # if any count higher than x
      # get highest counted suit
        # return relevant string
  # count appearances of numbers
    # if count higher than x, return relevant string

  # insight = if strings, collect and concat strings
  # return insight

  # ==== another idea for the above

  # sort cards by suit
    # get highest count

  # sort cards by number
    # get highest count

  # compare counts, use highest
  # return insight(type, count)

# Feedback
  # ask user how accurate the reading was, scale 1-5
  # find a way to send that to me if they have internet
  # otherwise move on silently

# Intro
def intro
  title "Tarot"

  dialogue("Hello and welcome to my tarot reading table.")
  dialogue("My name is Lisa. I've been expecting you, it's very nice to finally meet you...")
  dialogue("While I may be psychic, I'm not a mind reader. What should I call you?")
  puts "Type your response:"
  puts
  $username = gets.chomp.capitalize
  pause
  dialogue("Welcome #{$username}. How are you?")
  continue? "Type your response:"
  puts
  dialogue("Ah! Don't worry, it shouldn't affect the reading.")
  pause
  dialogue("Are you ready to begin?")
  continue?
end

def outro
  dialogue("Thank you for visiting me, and remember, #{$username}: my terminal is alway open.")
  dialogue("Come back anytime.")
  subtitle "Goodbye"
end

def main
  # reset
  # # shuffle, do celtic cross, draw ten cards
  # $deck.shuffle!
  # the_spread = Spread.s.find {|spread| "Celtic" }
  # 10.times do 
  #   the_spread.place_card $deck.draw!
  # end

  # # debug list cards
  # the_spread.cards.each do |card|
  #   puts "#{card.number}          #{card.suit}"
  # end

  # the_spread.sort_by &:number

  # the_spread.cards.each do |card|
  #   puts "#{card.number}          #{card.suit}"
  # end

  intro
  reading
  outro
end

main