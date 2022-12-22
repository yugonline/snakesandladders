# frozen_string_literal: true


require 'set'



# Player class has the current_position of the player and his/her name tag and knows when its the Players turn
# A player can only throw a Die. In this game the Board updates itself based on information from Player's die results
class Player
  attr_accessor :position, :tag, :is_turn

  def initialize(position, tag, is_turn)
    @position = position
    @is_turn = is_turn
    @tag = tag
  end

  def throw_die(is_turn)
    raise 'NOT YOUR TURN!!' unless is_turn

    [1, 2, 3, 4, 5, 6].sample
  end
end

# snakes = [12,25,29,50,52,55,56,61,91,97]
#
# ladders = [1,3,11,]

def create_player(player_number)
  puts 'WELCOME TO PLAYER CREATION SCREEN'
  puts '---------------'
  puts 'Please enter your battle tag!'
  tag = gets.chomp
  is_turn = player_number <= 1
  Player.new 0, tag, is_turn
end

def create_players(num)
  players = Array.new num

  (1..num).each do |index|
    player = create_player index
    players[index - 1] = player
  end
  players
end

# Board class has :players, :grid, :snakes and :ladders
# It moves players, updates grid, finds snakes and ladders
class Board
  attr_accessor :players, :grid, :snakes, :ladders

  def initialize(grid, snakes, ladders,players = [])
    @players = create_players 2 if players.empty?
    @grid = grid
    @snakes = snakes
    @ladders = ladders
  end

  def climb_ladder(position)
    @ladders.each do |each| # -> O(5)
      next unless each.include? position # -> O(1)

      each.select do |element| # -> O(2)
        return element if element != position
      end
    end
    -1
  end

  def descend_snake(position)
    @snakes.each do |each| # -> O(5)
      next unless each.include? position # -> O(1)

      each.select do |element| # -> O(2)
        return element if element != position
      end
    end
    -1
  end

  def ladder_tail?(position)
    @ladders.each do |each|
      next unless each.include? position

      puts "POSITION: #{position}"
      selection = each.select do |element|
        element if element > position
      end
      puts "SELECTION: #{selection}"
      return true unless selection.empty?
    end
    false
  end

  def at_snake_head?(position)
    @snakes.each do |each|
      next unless each.include? position

      # puts "POSITION: #{position}"
      selection = each.select do |element|
        element if element < position
      end
      # puts "SELECTION: #{selection}"
      return true unless selection.empty?
    end
    false
  end

  def move(player_idx)
    player = @players[player_idx]
    die_result = player.throw_die player.is_turn
    puts die_result
    player.position = player.position + die_result

    if at_snake_head? player.position
      puts 'SORRY!'
      player.position = descend_snake player.position
      return
    end

    if ladder_tail? player.position
      puts 'YAY!'
      player.position = climb_ladder player.position
      return
    end

    if player.position == 99
      puts "#{player.tag} WINS!"
    elsif player.position > 99
      player.position = player.position - die_result # reset to prev position if did not get correct Die result
    else
      puts 'Keep it up!'
    end
  end
end

def main
  grid = [9, 1, 0, 2, 0, 0, 0, 0, 0, 0,
          0, 5, -1, 2, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, -4, 0, 0, 0, -3,
          0, 0, 3, 0, 0, 0, 0, 1, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 5, -3, 4,
          -2, 0, 0, -4, -5, 0, 0, 0, 0, -5,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 3, 0,
          0, 4, 0, 0, 0, -2, 0, 0, 0, 0, 0,
          -1, 6, 0]

  snakes = Array.new(4) # -1 => [12,25]
  ladders = Array.new(5) # 1 => [13,27]

  100.times do |i|
    if (grid[i]).negative?
      idx = grid[i].abs
      set = Set.new
      if !snakes[idx - 1].nil?
        set = snakes[idx - 1]
        set << i

      else
        set.add i
      end
      snakes[idx - 1] = set
    end

    next unless (grid[i]).positive? && (grid[i] < 9)

    if !ladders[grid[i] - 1].nil?
      puts 'IM HERE'
      set = Set.new
      set = ladders[grid[i] - 1]
      set << i
    else
      set = Set.new
      set.add i
    end
    ladders[grid[i] - 1] = set
  end
  board = Board.new(grid, snakes, ladders)

  puts board.inspect

  loop do
    puts board.move(0)

    puts board.inspect
    puts 'MOVE AGAIN?'
    s = gets.chomp
    break if s == 'N'
  end
end

main
