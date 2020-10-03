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
  def player_exchange(deck)
    puts <<~EOS

      y.手札を交換する  n.手札を交換しない
      yかnを入力してください 
    EOS

    #交換の是非
    action = gets.chomp
    if action == "y"
      select_discard
      player_discard
      player_draw_for_exchange(deck)
      puts 
      puts "あなたの手札はこうなりました"
    elsif action == "n"
      puts
      puts "あなたの手札はこうなりました"
    else
      puts 
      puts "半角のyかnを選択して下さい"

      player_exchange(deck)
    end

  end

  #捨てる手札の選択
  def select_discard
    
    select_message

    #捨てるカードの選択
    @selected_ids = gets.split(' ').map(&:to_i)
    if ! @selected_ids.select {|n| n < 1 || n > 5}.empty?
      puts <<~EOS

        半角数字の1-5のみ入力できます
      EOS
      @selected_ids = gets.split(' ').map(&:to_i)
    elsif @selected_ids.uniq != @selected_ids
      puts <<~EOS

        同じ数字が2回以上入力されています
        再度入力し直して下さい
      EOS
        @selected_ids = gets.split(' ').map(&:to_i)
    end
    
    
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