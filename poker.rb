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

    #役判定
    if @differences.count(1) == 4 && @number_of_suits_types == 1 && @sort_hands[0].score == 10
      @rank = "ローヤルストレートフラッシュ"
    elsif @differences.count(1) == 4 && @number_of_suits_types == 1
      @rank = "ストレートフラッシュ"
    elsif @number_of_each_score.include?(4) 
      @rank = "フォーカード"
    elsif @number_of_each_score.include?(3) && @number_of_each_score.include?(2)
      @rank = "フルハウス"
    elsif @number_of_suits_types == 1
      @rank = "フラッシュ"
    elsif @differences.count(1) == 4
      @rank = "ストレート"
    elsif @number_of_each_score.include?(3)
      @rank = "スリーカード"
    elsif @number_of_each_score.count(2) == 2
      @rank = "ツーペア"
    elsif @number_of_each_score.count(2) == 1
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
    
    #suitsの種類と数をhashで取得
    @hash_of_suits_types = @suits.group_by(&:itself).transform_values(&:size)

    #suitsの中の同じ要素の数をhashで返し、hashの要素数を取得
    @number_of_suits_types = @hash_of_suits_types.size

    #同じsuitが何枚ずつあるか
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

    #scoresの中の同じ要素の数をhashで返し、hashの要素数を取得
    @number_of_scores_types = @hash_of_scores_types.size

    #同じscoreが何枚ずつあるか
    @number_of_each_score = @hash_of_scores_types.values
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
    複数枚を選択する際は間に半角スペースをあけて下さい
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
  def player_discard
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

    #交換の是非
    action = gets.chomp.to_i
    if action == 1
      select_discard
      player_discard
      draw_for_exchange(deck)
    elsif action == 2
      return
    end

  end
end

class Dealer < Hand
  def dealer_exchange(deck)
    rearrange
    take_difference
    count_number_of_suits_types
    count_number_of_scores_types
    

    #ストレート系が完成済み
    if @differences.count(1) == 4
      return #ストレート系を確定

    #フォーカードかフルハウスが完成済み
    elsif @differences.count(0) == 3
      return #フォーカード か フルハウスを確定

    #フラッシュが完成済み
    elsif @number_of_suits_types == 1
      return #フラッシュを確定

    #ストレートが完成済みで、スートが同じ札が4枚
    elsif @number_of_each_suit == 4 && @differences.count(1) == 4
      #1/3の確率でフラッシュ狙いで交換, 2/3の確率でストレートを確定
      probability = rand(3)
      probability == 0 ? action_for_flush : return
    
    #スートが同じ札が4枚で@differences.count(0) == 2
    elsif @number_of_each_suit == 4 && @differences.count(0) == 2
      if @suits[0] != @suits[1]
        #フルハウス狙いで1枚目を交換
        @sorts_hands[0].delete
        
        hand = deck.draw
        @hands << hand

      elsif @suits[3] != @suits[4]
        #フルハウス狙いで4枚目を交換
        @sorts_hands[3].delete
        
        hand = deck.draw
        @hands << hand
      else
        return
      end

    #スートが同じ札が4枚
    elsif @number_of_each_suit == 4
      #フラッシュ狙いで1枚交換
      action_for_flush(deck)
    
    # @differences.count(1) == 3 かつ 2枚目-1枚目が1以上
    elsif @differences.count(1) == 3 && @scores[1] - @scores[0] > 1
      #ストレート狙いで1枚目を交換
      @sorts_hands[0].delete

      hand = deck.draw
      @hands << hand

    #@differences.count(1) == 3 かつ 5枚目-4枚目が1以上
    elsif @differences.count(1) == 3 && @scores[4] - @scores[3] > 1
      #ストレート狙いで5枚目を交換
      @sorts_hands[4].delete

      hand = deck.draw
      @hands << hand
      
    #1,2枚目、4,5枚目の差が1で3枚目と4枚目の差が2のとき
    elsif @scores[2] - @scores[1] == 1 && @scores[4] - @scores[3] == 1 && @scores[2] - @scores[3] == 2
      #ストレート狙いで1枚目を交換
      @sorts_hands[0].delete

      hand = deck.draw
      @hands << hand

    #スリーカード完成済み
    elsif @number_of_each_score.include?(3)
      if @scores[0] == @scores[1] && @scores[1] && @scores[2]
        #フルハウス狙いで4枚目を交換
        @sorts_hands[3].delete

        hand = deck.draw
        @hands << hand
      end
      

    else 
      puts "交換なし"
    end

    #dealerの手札公開
    @hands.each.with_index(1) do |hand, i|
      puts "#{i}枚目 ： #{hand.show}"
    end

    #フラッシュ狙いで1枚交換
    def action_for_flush(deck)
      #1枚だけ違うsuitのカードを交換
      if suit = @suits.find{|suit| suit == @hash_of_suits_types.key(1)}
        @sort_hands.delete(suit)
        
        hand = deck.draw
        @hands << hand
      end
    end
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


  end

  

end

games_controller = GamesController.new
games_controller.start