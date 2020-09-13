class Deck
  # attr_accessor :card

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
  attr_reader :suit, :score

  #カードを初期化
  def initialize(suit, number)
    @suit = suit
    @number = number
    @score = 0 #とりあえずの初期値
  end
  
  def show
    "#{@suit}の#{@number}"
  end
  
  #NUMBERSのスコア
  def set_score
    if @number == "A"
      @score = 14
    elsif @number == "K"
      @score = 13
    elsif @number == "Q"
      @score = 12
    elsif @number == "J"
      @score = 11
    else
      @score = @number.to_i
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

  #カードをscoreの昇順に並び替え
  def rearrange
    @hands.each {|hand| hand.set_score} #@scoreに値をセット

    @sort_hands = @hands.sort {|a, b| a.score <=> b.score} #並び替え
    # p @sort_hands
    # sort_hands.each {|h| puts h.score} #表示
  end

  #役判定メソッド
  def judge_ranks
    #隣り合う@sort_handsの差を配列で取得
    differences = [
      @sort_hands[1].score - @sort_hands[0].score,
      @sort_hands[2].score - @sort_hands[1].score,
      @sort_hands[3].score - @sort_hands[2].score,
      @sort_hands[4].score - @sort_hands[3].score
    ]

    count_number_of_suits_types
    count_number_of_scores_types

    #役判定
    # if differences.count(1) == 4 && (@sort_hands[0].suit == @sort_hands[1].suit == @sort_hands[2].suit == @sort_hands[3].suit == @sort_hands[4].suit) && @sort_hands[0].score == 10
    #   @rank = "royal straight flush"
    # elsif differences.count(1) == 4 && @sort_hands[0].suit == @sort_hands[1].suit == @sort_hands[2].suit == @sort_hands[3].suit == @sort_hands[4].suit
    #   @rank = "straight flush"
    # elsif number_of_the_same_score.include?(4)
    #   @rank = "four of a kind"
    # elsif number_of_the_same_score.include?(3) == number_of_the_same_score.include?(2)
    #   @rank = "full house"
    # else puts "それ以外"
    # end

  end
  
  #同じsuitのカードが何枚あるか
  def count_number_of_suits_types
    #@sort_hands中の@suitの値を配列で取得
    suits = []

    @sort_hands.each {|hand|
    suit = hand.instance_variable_get(:@suit)
    suits << suit 
    }
    
    #suitsの中の同じ要素の数をhashで返し、hashの要素数を取得
    number_of_suits = suits.group_by(&:itself).transform_values(&:size).size
  end

  #同じscoreのカードが何枚あるか
  def count_number_of_scores_types
    #@sort_hands中の@scoreの値を配列で取得
    scores = []

    @sort_hands.each {|hand|
    score = hand.instance_variable_get(:@score)
    scores << score 
    }
    
    #scoresの中の同じ要素の数をhashで返し、hashの要素数を取得
    p number_of_scores = scores.group_by(&:itself).transform_values(&:size).size
  end

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
    player.judge_ranks
  end

  

end

games_controller = GamesController.new
games_controller.start