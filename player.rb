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
      puts 
      puts "最終的な手札はこちらです"
    elsif action == 2
      puts
      puts "最終的な手札はこちらです"
    else
      puts 
      puts "半角の1か2を選択して下さい"

      decide_exchange(deck)
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

    @selected_ids.each{|id| 
      selected_hand = @hands[id - 1]
      puts selected_hand.show
      @discards << selected_hand
    }

    discard
    
    #選択した手札を表示
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