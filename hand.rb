class Hand
  attr_reader :point, :sub_point1, :sub_point2, :sub_point3, :sub_point4, :sub_point5
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
  def judge_rank
    
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
      return @rank = "ローヤルストレートフラッシュ"
    elsif straight_flush
      return @rank = "ストレートフラッシュ"
    elsif four_of_a_kind
      return @rank = "フォーカード"
    elsif a_full_house
      return @rank = "フルハウス"
    elsif a_full_house
      return @rank = "フラッシュ"
    elsif straight
      return @rank = "ストレート"
    elsif three_of_a_kind
      return @rank = "スリーカード"
    elsif two_pair
      return @rank = "ツーペア"
    elsif a_pair
      return @rank = "ワンペア"
    else
      return @rank = "ハイカード"
    end

  end

  #カードをscoreの昇順に並び替え
  def rearrange
    #@scoresに値をセット
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
    #@sort_hands中の@scoresの値を配列で取得
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

  #手札を表示
  def display_hands
    @hands.each.with_index(1) do |hand, i|
      puts "#{i}枚目 ： #{hand.show}"
    end
  end

  #手札を捨てる
  def discard
    @hands.delete_if{|hand|
      @discards.include?(hand)
    }
  end

  #役の強さを決めるためのpointと、playerとdealerで@rankが被った時のためのsub_pointの設定
  #同じ@rank同士のときはsub_pointが大きいほうが勝利
  def set_point
    if @rank == "ローヤルストレートフラッシュ"
      @point = 1000000000
    elsif @rank == "ストレートフラッシュ"
      @point = 100000000
      @sub_point1 = @scores.max #一番scoreの大きいカードのscore
    elsif @rank == "フォーカード"
      @point = 10000000
      @sub_point1 = @hash_of_scores_types.key(4).to_s.to_i #フォーカードを作っているカードのscore
    elsif @rank == "フルハウス"
      @point = 1000000
      @sub_point1 = @hash_of_scores_types.key(3).to_s.to_i #3枚1組のカードのscore
    elsif @rank == "フラッシュ"
      @point = 100000
      @sub_point1 = @scores.max #一番scoreの大きいカードのscore
    elsif @rank == "ストレート"
      @point = 10000
      @sub_point1 = @scores.max #一番scoreの大きいカードのscore
    elsif @rank == "スリーカード"
      @point = 1000
      @sub_point1 = @hash_of_scores_types.key(3).to_s.to_i #3枚1組のカードのscore
    elsif @rank == "ツーペア"
      @point = 100
      @sub_point1 = @hash_of_scores_types.select{|hash_of_scores_types, v| v==2}.values_at(1).to_s.to_i #scoreの大きなペアのカードのscore
      @sub_point2 = @hash_of_scores_types.select{|hash_of_scores_types, v| v==2}.values_at(0).to_s.to_i #scoreの大きなペアのカードのscore
      @sub_point3 = @hash_of_scores_types.key(1).to_s.to_i #ペアになっていないカードのscore
    elsif @rank == "ワンペア"
      @point = 10
      @sub_point1 = @hash_of_scores_types.key(2).to_s.to_i
      @sub_point2 = @hash_of_scores_types.select{|hash_of_scores_types, v| v==1}.values_at(2).to_s.to_i #最もscoreの大きなサイドカードのscore
      @sub_point3 = @hash_of_scores_types.select{|hash_of_scores_types, v| v==1}.values_at(1).to_s.to_i #二番目にscoreの大きなサイドカードのscore
      @sub_point4 = @hash_of_scores_types.select{|hash_of_scores_types, v| v==1}.values_at(0).to_s.to_i #最も小さなscoreの大きなサイドカードのscore
    elsif @rank == "ハイカード"
      @point = 1
      #ハイカードのsub_pointはscoreの大きなカードから順番に比較
      @sub_point1 = @sort_hands[4].score
      @sub_point2 = @sort_hands[3].score
      @sub_point3 = @sort_hands[2].score
      @sub_point4 = @sort_hands[1].score
      @sub_point5 = @sort_hands[0].score
    end
  end

  #役を表示
  def rank_message(character)
    puts <<~EOS

    #{character}の役は
    #{@rank}になりました

    EOS
  end

end