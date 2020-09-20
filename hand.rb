class Hand
  attr_accessor :point
  #ゲーム開始時にドローする回数
  NUMBER_OF_DRAW_TIMES_AT_START = 5
  
  #手札の配列を生成
  def initialize
    @hands = []
    @discards = []
    @point = point
  end

  #ゲーム開始時に手札を配る
  def start_distribute(deck)
    NUMBER_OF_DRAW_TIMES_AT_START.times {|hand|
      hand = deck.draw
      @hands << hand
    }
  end

  #役判定メソッド
  def judge_rank(character)
    
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
      @point = 1000000000
    elsif straight_flush
      @rank = "ストレートフラッシュ"
      @point = 100000000
    elsif four_of_a_kind
      @rank = "フォーカード"
      @point = 10000000
    elsif a_full_house
      @rank = "フルハウス"
      @point = 1000000
    elsif a_full_house
      @rank = "フラッシュ"
      @point = 100000
    elsif straight
      @rank = "ストレート"
      @point = 10000
    elsif three_of_a_kind
      @rank = "スリーカード"
      @point = 1000
    elsif two_pair
      @rank = "ツーペア"
      @point = 100
    elsif a_pair
      @rank = "ワンペア"
      @point = 10
    else
      @rank = "ハイカード"
      @point = 1
    end

    rank_message(character)

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

  def set_point
    if @rank == "ローヤルストレートフラッシュ"
      @point = 1000000000
    elsif @rank == "ストレートフラッシュ"
      @point = 100000000
    elsif @rank == "フォーカード"
      @point = 10000000
    elsif @rank == "フルハウス"
      @point = 1000000
    elsif @rank == "フラッシュ"
      @point = 100000
    elsif @rank == "ストレート"
      @point = 10000
    elsif @rank == "スリーカード"
      @point = 1000
    elsif @rank == "ワンペア"
      @point = 10
    elsif @rank == "ハイカード"
      @point = 1
    end
  end

  def rank_message(character)
    puts <<~EOS

    #{character}の役は
    #{@rank}になりました

    EOS
  end

end