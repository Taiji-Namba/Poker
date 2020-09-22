class Dealer < Hand
attr_reader :point, :sub_point

  def dealer_exchange(deck)

    rearrange
    take_difference
    count_number_of_suits_types
    count_number_of_scores_types
    dealer_decide_card(deck)

  end

  def dealer_decide_card(deck)

    #フラッシュドロー(4枚のスートが同じ)の定義
    flush_draw = @number_of_each_suit.include?(4)

    #ストレートドロー(1枚だけscoreが連続していない)の定義
    straight_draw = @differences.count(1) == 3

    #ストレート系が完成済み
    if @rank == "ストレート"
      return #ストレート系を確定

    #フォーカードかフルハウスが完成済み
    elsif @rank == "フォーカード"
      return #フォーカードを確定

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
      probability == 0 ? return : action_for_flush(deck)
    
    #スートが同じ札が4枚
    elsif flush_draw
      action_for_flush(deck) #フラッシュ狙いでスートが違う1枚交換
    
    # @differences.count(1) == 3 かつ 1枚だけ2以上離れている
    elsif straight_draw
      action_for_straight(deck)
      
    #スリーカード完成済み
    elsif @rank == "スリーカード"
      action_when_three_of_a_kind(deck)

    #ツーペア形成済み, ペアになっていない札を交換
    elsif @rank == "ツーペア"
      action_when_two_pair(deck)

    #ワンペア形成済み, ペア以外を交換
    elsif @rank == "ワンペア"
      action_when_a_pair(deck)
    else 
      action_when_high_card(deck)
    end
  end

  #ストレート狙いのアクション
  def action_for_straight(deck)
    #1枚目のscoreが連続していない
    if @scores[1] - @scores[0] >= 2
      #1枚目を交換
      @discards << @sort_hands[0]
      
      dealer_draw(deck)
      
    #5枚目のscoreが連続していない
    elsif @scores[4] - @scores[3] >= 2
      #5枚目を交換
      @discards << @sort_hands[4]

      dealer_draw(deck)
    
    #2,3枚目もしくは3,4枚目が同じ
    elsif @scores[1] == @scores[2] || @scores[2] == @scores[3]
      #3枚目を交換
      @discards << @sort_hands[2]

      dealer_draw(deck)

    end
  end

  #フラッシュ狙いの行動
  def action_for_flush(deck)
    #1枚だけ違うsuitのカードを交換
    if suit = @suits.find{|suit| suit == @hash_of_suits_types.key(1)}
      @sort_hands.delete(suit)
      
      dealer_draw(deck)

    end

    p "action_for_flush"
  end

  #スリーペアのときの行動
  def action_when_three_of_a_kind(deck)
    #1,2,3枚目のscoreが同じ
    if @scores[0] == @scores[1] && @scores[1] && @scores[2]
      #フルハウス狙いで4枚目を交換
      @discards << @sort_hands[3]

      dealer_draw(deck)

    #2,3,4枚目のscoreが同じ
    elsif @scores[1] == @scores[2] && @scores[2] && @scores[3]
      #フルハウス狙いで1枚目を交換
      @discards << @sort_hands[0]

      dealer_draw(deck)

    #3,4,5枚目のscoreが同じ
    elsif @scores[2] == @scores[3] && @scores[3] && @scores[4]
      #フルハウス狙いで1枚目を交換
      @discards << @sort_hands[0]

      dealer_draw(deck)

    end
  end

  #ツーペアのときの行動
  def action_when_two_pair(deck)
    if @scores[0] == @scores[1] && @scores[2] && @scores[3]
      #フルハウス狙いで5枚目を交換
      @discards << @sort_hands[4]

      dealer_draw(deck)

    elsif @scores[0] == @scores[1] && @scores[3] && @scores[4]
      #フルハウス狙いで3枚目を交換
      @discards << @sort_hands[2]

      dealer_draw(deck)
    
    elsif @scores[1] == @scores[2] && @scores[3] && @scores[4]
      #フルハウス狙いで1枚目を交換
      @discards << @sort_hands[0]

      dealer_draw(deck)
    
    end
  end

  def action_when_a_pair(deck)

    #交換する枚数
    number_of_units_to_be_replaced = 3

    if @scores[0] == @scores[1]
      #フルハウス狙いで3,4,5枚目を交換
      @discards.push(@sort_hands[2], @sort_hands[3], @sort_hands[4])

      number_of_units_to_be_replaced.times{dealer_draw(deck)}

    elsif @scores[1] == @scores[2]
      #フルハウス狙いで1,4,5枚目を交換
      @discards.push(@sort_hands[0], @sort_hands[3], @sort_hands[4])

      number_of_units_to_be_replaced.times{dealer_draw(deck)}

    elsif @scores[2] == @scores[3]
      #フルハウス狙いで1,2,5枚目を交換
      @discards.push(@sort_hands[0], @sort_hands[1], @sort_hands[4])

      number_of_units_to_be_replaced.times{dealer_draw(deck)}

    elsif @scores[3] == @scores[4]
      #フルハウス狙いで1,2,3枚目を交換
      @discards.push(@sort_hands[0], @sort_hands[1], @sort_hands[2])

      number_of_units_to_be_replaced.times{dealer_draw(deck)}

    end
  end

  #ハイカードのときの行動
  def action_when_high_card(deck)
    #ランダムに3-5枚交換
    n = rand(3..5)
    discards = @sort_hands.sample(n)
    discards.each {|discard|
    @discards << discard
    }

    number_of_units_to_be_replaced = n
    number_of_units_to_be_replaced.times{dealer_draw(deck)}

  end

  def dealer_draw(deck)
    discard

      hand = deck.draw
      @hands << hand

  end

  def exchange_message
    number = @discards.size
    puts "ディーラーのターンです"
    puts number >0 ? "ディーラーは#{number}枚交換しました" : "ディーラーは交換しませんでした"
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