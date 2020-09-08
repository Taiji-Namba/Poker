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
  end

  def show
    "#{@suit}の#{@number}"
  end

end

class Hand
  #ゲーム開始時にドローする回数
  NUMBER_OF_DRAW_TIMES_AT_START = 5
  
  #手札の配列を生成
  def initialize
    @hands = []
  end

  #ゲーム開始時に手札を配る
  def start_distribute(deck)
    NUMBER_OF_DRAW_TIMES_AT_START.times {|hand|
      hand = deck.draw
      @hands << hand
    }
  end

end

class Player < Hand

  #プレイヤーの手札を表示
  def display_player_hands
    puts <<~EOS

    -------------Player手札-------------
    EOS

    @hands.each.with_index(1) do |hand, i|
      puts " #{i}枚目 ： #{hand.show}"
    end

    puts "------------------------------------"
  end

  def select_exchange_cards
    # def select_cards
    #交換メッセージ
    puts <<~EOS

    何枚目のカードを交換するか数字で入力して下さい
    複数枚を選択する際は数字同士の間に半角スペースをあけて下さい
    例)1 2 3
    EOS
    
    #捨てるカードの選択
    selected_id = gets.split(' ').map(&:to_i)
    
    #選んだカードの説明
    selected_id.each{|id| 
    selected_hand = @hands[id - 1]
    puts selected_hand.show
    }
  end

  #捨てた枚数分山札から引く
  def draw_for_exchange(deck)
    size = selected_id.size
    size.times {|hand|
      hand = deck.draw
      @hands << hand
    } 
  
    @hands.each.with_index(1) do |hand, i|
      puts " #{i}枚目 ： #{hand.show}"
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
    player.select_exchange_cards
    player.draw_for_exchange


  end

  

end

games_controller = GamesController.new
games_controller.start