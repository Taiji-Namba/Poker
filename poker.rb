class Deck
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
  attr_reader :score

  #カードを初期化
  def initialize(suit, number)
    @suit = suit
    @number = number
    @score = 0 #とりあえずの初期値
  end

  #カードの表示
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

  #役判定メソッド
  def judge_ranks
    
    rearrange
    take_difference
    count_number_of_suits_types
    count_number_of_scores_types

    a_pair = @number_of_each_score.count(2) == 1
    two_pair = @number_of_each_score.count(2) == 2
    three_of_a_kind = @number_of_each_score.include?(3)
    straight = @differences.count(1) == 4
    flush = @number_of_suits_types == 1
    a_full_house = a_pair && three_of_a_kind
    four_of_a_kind = @number_of_each_score.include?(4)
    straight_flush = straight && flush
    royal_straight_flush = straight && flush && @sort_hands[0].score == 10

    #役判定
    if royal_straight_flush
      @rank = "ローヤルストレートフラッシュ"
    elsif straight_flush
      @rank = "ストレートフラッシュ"
    elsif four_of_a_kind
      @rank = "フォーカード"
    elsif a_full_house
      @rank = "フルハウス"
    elsif a_full_house
      @rank = "フラッシュ"
    elsif straight
      @rank = "ストレート"
    elsif three_of_a_kind
      @rank = "スリーカード"
    elsif two_pair
      @rank = "ツーペア"
    elsif a_pair
      @rank = "ワンペア"
    else
      @rank = "ハイカード"
    end

    puts <<~EOS

    あなたの役は
    #{@rank}
    EOS

  end

  #カードをscoreの昇順に並び替え
  def rearrange
    #@scoreに値をセット
    @hands.each {|hand| hand.set_score}
    
    #並び替え
    @sort_hands = @hands.sort {|a, b| a.score <=> b.score}
  end
  
  #隣り合う@sort_handsのscoreの差を配列で取得
  def take_difference
    @differences = [
      @sort_hands[1].score - @sort_hands[0].score,
      @sort_hands[2].score - @sort_hands[1].score,
      @sort_hands[3].score - @sort_hands[2].score,
      @sort_hands[4].score - @sort_hands[3].score
    ]
  end

  #同じsuitのカードが何枚あるか
  def count_number_of_suits_types
    #@sort_hands中の@suitの値を配列で取得
    @suits = []

    @sort_hands.each {|hand|
    suit = hand.instance_variable_get(:@suit)
    @suits << suit 
    }
    
    #スートの種類とぞれぞれの枚数をhashで取得
    @hash_of_suits_types = @suits.group_by(&:itself).transform_values(&:size)

    #スートは何種類あるか
    @number_of_suits_types = @hash_of_suits_types.size

    #1つのスートがそれぞれ何枚ずつあるか配列で取得
    @number_of_each_suit = @hash_of_suits_types.values
  end

  #同じscoreのカードが何枚あるか
  def count_number_of_scores_types
    #@sort_hands中の@scoreの値を配列で取得
    @scores = []

    @sort_hands.each {|hand|
    score = hand.instance_variable_get(:@score)
    @scores << score 
    }
    
    #scoreの種類と数をhashで取得
    @hash_of_scores_types = @scores.group_by(&:itself).transform_values(&:size)

    #scoreは何種類あるか
    @number_of_scores_types = @hash_of_scores_types.size

    #1つのscoreがそれぞれ何枚ずつあるか配列で取得
    @number_of_each_score = @hash_of_scores_types.values
  end

  def display_hands
    @hands.each.with_index(1) do |hand, i|
      puts "#{i}枚目 ： #{hand.show}"
    end
  end

  def discard
    @hands.delete_if{|hand|
      @discards.include?(hand)
    }
  end

end

class Player < Hand

  #プレイヤーの手札を表示
  def display_player_hands
    puts <<~EOS

    -------------Player手札-------------
    EOS

    display_hands

    puts "------------------------------------"
  end

      #手札を交換するか決める
  def decide_exchange(deck)
    puts <<~EOS

      1.手札を交換する  2.手札を交換しない
    EOS

    #交換の是非
    action = gets.chomp.to_i
    if action == 1
      select_discard
      player_discard
      player_draw_for_exchange(deck)
    elsif action == 2
      return
    end

  end

  #捨てる手札の選択
  def select_discard
    
    select_message

    #捨てるカードの選択
    @selected_ids = gets.split(' ').map(&:to_i)
    
    puts 

  end

  #交換メッセージ
  def select_message
    puts <<~EOS

    何枚目のカードを交換するか数字で入力して下さい
    複数枚を選択する際は間に半角スペースをあけて下さい
    例)1 2 3
    EOS
  end
  
  #選択した手札を捨てる
  def player_discard
    discard

    #選択した手札を表示
    @selected_ids.each{|id| 
      selected_hand = @hands[id - 1]
      puts selected_hand.show
      @discards << selected_hand
    }

    puts <<~EOS
      を交換しました
    EOS
  end
    
  #捨てた枚数分山札から引く
  def player_draw_for_exchange(deck)
    @selected_ids.size.times {|hand|
      hand = deck.draw
      @hands << hand
    }   
  end

end

class Dealer < Hand

  def dealer_exchange(deck)
    rearrange
    take_difference
    count_number_of_suits_types
    count_number_of_scores_types
    dealer_decide_card

  end

  def dealer_decide_card

    #フラッシュドロー(4枚のスートが同じ)の定義
    flush_draw = @number_of_each_suit.include?(4)
    #ストレートドロー(1枚だけscoreが連続していない)の定義
    straight_draw = @differences.count(1) == 3

    #ストレート系が完成済み
    if @rank == "ストレート"
      return #ストレート系を確定

    #フォーカードかフルハウスが完成済み
    elsif @rank == "フォーカード"
      return #フォーカード か フルハウスを確定

    #フルハウスが完成済み
    elsif @rank == "フルハウス"
      return #フルハウスを確定

    #フラッシュが完成済み
    elsif @rank == "フラッシュ"
      return #フラッシュを確定

    #スートが同じ札が4枚でストレートが完成済み
    elsif flush_draw && @rank == "ストレート"
      #1/3の確率でストレートを確定, 2/3の確率でフラッシュ(あるいはストレートフラッシュ狙い)で交換
      probability = rand(3)
      probability == 0 ? return : action_for_flush
    
    #スートが同じ札が4枚
    elsif flush_draw
      action_for_flush #フラッシュ狙いでスートが違う1枚交換
    
    # @differences.count(1) == 3 かつ 1枚だけ2以上離れている
    elsif straight_draw 
      action_for_straight
      
    #スリーカード完成済み
    elsif @rank == "スリーカード"
      #スリーカードになっていない1枚交換
      action_when_three_of_a_kind

    #ツーペア形成済み, ペアになっていない札を交換
    elsif @rank == "ツーペア"
      action_when_two_pair

    #ワンペア形成済み, ペア以外を交換
    elsif @rank == "ワンペア"
      action_when_a_pair

    else 
      action_when_high_card
    end
  end

  #ストレート狙いのアクション
  def action_for_straight
    #1枚目のscoreが連続していない
    if @scores[1] - @scores[0] >= 2
      #1枚目を交換
      @discards << @sorts_hands[0]
      
      dealer_draw(1)
      
    #5枚目のscoreが連続していない
    elsif @scores[4] - @scores[3] >= 2
      #5枚目を交換
      @discards << @sorts_hands[4]

      dealer_draw(1)
    
    #2,3枚目もしくは3,4枚目が同じ
    elsif @scores[1] == @scores[2] || @scores[2] == @scores[3]
      #同じscoreの札を交換
      @discards << @sorts_hands[2]

      dealer_draw(1)

    end
  end

  #フラッシュ狙いの行動
  def action_for_flush
    #1枚だけ違うsuitのカードを交換
    if suit = @suits.find{|suit| suit == @hash_of_suits_types.key(1)}
      @sort_hands.delete(suit)
      
      hand = deck.draw
      @hands << hand
    end
  end

  #スリーペアのときの行動
  def action_when_three_of_a_kind
    #1,2,3枚目のscoreが同じ
    if @scores[0] == @scores[1] && @scores[1] && @scores[2]
      #フルハウス狙いで4枚目を交換
      @discards << @sorts_hands[3]

      dealer_draw(1)

    #2,3,4枚目のscoreが同じ
    elsif @scores[1] == @scores[2] && @scores[2] && @scores[3]
      #フルハウス狙いで1枚目を交換
      @discards << @sorts_hands[0]

      dealer_draw(1)

    #3,4,5枚目のscoreが同じ
    elsif @scores[2] == @scores[3] && @scores[3] && @scores[4]
      #フルハウス狙いで1枚目を交換
      @discards << @sorts_hands[0]

      dealer_draw(1)

    end
  end

  #ツーペアのときの行動
  def action_when_two_pair
    if @scores[0] == @scores[1] && @scores[2] && @scores[3]
      #フルハウス狙いで5枚目を交換
      @discards << @sorts_hands[4]

      dealer_draw(1)

    elsif @scores[0] == @scores[1] && @scores[3] && @scores[4]
      #フルハウス狙いで3枚目を交換
      @discards << @sorts_hands[2]

      dealer_draw(1)
    
    elsif @scores[1] == @scores[2] && @scores[3] && @scores[4]
      #フルハウス狙いで1枚目を交換
      @discards << @sorts_hands[0]

      dealer_draw(1)
    
    end
  end

  def action_when_a_pair
    if @scores[0] == @scores[1]
      #フルハウス狙いで3,4,5枚目を交換
      @discards.push(@sorts_hands[2], @sorts_hands[3], @sorts_hands[4])

      dealer_draw(3)

    elsif @scores[1] == @scores[2]
      #フルハウス狙いで1,4,5枚目を交換
      @discards.push(@sorts_hands[0], @sorts_hands[3], @sorts_hands[4])

      dealer_draw(3)

    elsif @scores[2] == @scores[3]
      #フルハウス狙いで1,2,5枚目を交換
      @discards.push(@sorts_hands[0], @sorts_hands[1], @sorts_hands[4])

      dealer_draw(1)

    elsif @scores[3] == @scores[4]
      #フルハウス狙いで1,2,3枚目を交換
      @discards.push(@sorts_hands[0], @sorts_hands[1], @sorts_hands[2])

      dealer_draw(1)

    end
  end

  #ハイカードのときの行動
  def action_when_high_card
    #ランダムな枚数交換
  end

  def dealer_draw(i)
    discard

    i.times {|hand|
      hand = deck.draw
      @hands << hand
    }

  end

  #dealerの手札公開
  def display_dealer_hand
    puts <<~EOS

    -------------Dealer手札-------------
    EOS

    display_hands

    puts "------------------------------------"

  end
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
    dealer.start_distribute(deck)


    player.display_player_hands
    
    player.decide_exchange(deck)
    player.display_player_hands
    
    # player.rearrange
    player.judge_ranks

    dealer.dealer_exchange(deck)
    dealer.display_dealer_hand


  end

  

end

games_controller = GamesController.new
games_controller.start