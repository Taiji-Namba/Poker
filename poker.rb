class Deck
  attr_accessor :cards

  #スートと数字を定義
  SUITS = ["スペード", "ハート", "ダイヤ", "クローバー"]
  NUMBERS = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

  #山札の配列を生成
  def initialize
    @cards = []

    #それぞれのスートにそれぞれの数字を当てはめたインスタンスを作成し、追加
    SUITS.each do |suit|
      NUMBERS.each do |number|
        card = Card.new(suit, number)
        @cards << card
      end
    end
    
    #山札をシャッフル
    @cards.shuffle!
  end

  #最初の一枚を取り出し
  def draw
    @cards.shift
  end

end

class Card
  #カードを初期化
  def initialize(suit, number)
    @suit = suit
    @number = number
    # @score = score
  end
  
  def show
    "#{@suit}の#{@number}"
  end
  
  #NUMBERSの得点
  def score
    if @number == "A"
      14
    elsif @number == "K"
      13
    elsif @number == "Q"
      12
    elsif @number == "J"
      11
    else
      @number.to_i
    end
  end

end

class Hand
  #ゲーム開始時にドローする回数
  NUMBER_OF_DRAW_TIMES_AT_START = 5
  
  #手札の配列を生成
  def initialize
    @hands = []
    @discards = []
  end

  #ゲーム開始時に手札を配る
  def start_distribute(deck)
    NUMBER_OF_DRAW_TIMES_AT_START.times {|hand|
      hand = deck.draw
      @hands << hand
    }
  end

  #カードを数字の昇順に並び替え
  def rearrange
    @hands.each {|hand|
      @score = hand.score
    }
  puts score
    # display_player_hands

  
  end

  # #役判定
  # def judge_hands
  #   if 

  #   end
  # end

end

class Player < Hand

  #プレイヤーの手札を表示
  def display_player_hands
    puts <<~EOS

    -------------Player手札-------------
    EOS

    @hands.each.with_index(1) do |hand, i|
      puts "#{i}枚目 ： #{hand.show}"
    end

    puts "------------------------------------"
  end

  #捨てる手札の選択
  def select_discard
    #交換メッセージ
    puts <<~EOS

    何枚目のカードを交換するか数字で入力して下さい
    複数枚を選択する際は数字同士の間に半角スペースをあけて下さい
    例)1 2 3
    EOS
    
    #捨てるカードの選択
    @selected_ids = gets.split(' ').map(&:to_i)
    
    #選んだ手札を表示
    puts 
    @selected_ids.each{|id| 
      selected_hand = @hands[id - 1]
      puts selected_hand.show
      @discards << selected_hand
    }
  end
  
  #選択した手札を捨てる
  def discard
    @hands.delete_if{|hand|
      @discards.include?(hand)
    }
    puts <<~EOS
      を交換しました
    EOS
  end
    
  #捨てた枚数分山札から引く
  def draw_for_exchange(deck)
    @selected_ids.size.times {|hand|
      hand = deck.draw
      @hands << hand
    }   
  end

    #手札を交換するか決める
  def decide_exchange(deck)
    puts <<~EOS

      1.手札を交換する  2.手札を交換しない
    EOS

    action = gets.chomp.to_i
    if action == 1
      select_discard
      discard
      draw_for_exchange(deck)
      # 役判定メソッド
    elsif action == 2
      # 役判定メソッド
      # puts "OK"
    end

  end

end

class Dealer < Hand

end


class GamesController
  
  def start
    puts <<~EOS
    ----------Welcome to Poker---------- 
    EOS
    
    deck = Deck.new
    hand = Hand.new
    player = Player.new
    dealer = Dealer.new
    
    player.start_distribute(deck)
    player.display_player_hands
    
    player.decide_exchange(deck)
    player.display_player_hands
    
    player.rearrange
  end

  

end

games_controller = GamesController.new
games_controller.start