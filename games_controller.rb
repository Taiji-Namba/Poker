require "./deck"
require "./card"
require "./hand"
require "./player"
require "./dealer"

class GamesController
  
  def start
    puts <<~EOS
    ----------Welcome to Poker---------- 
    EOS
    
    deck = Deck.new
    player = Player.new
    dealer = Dealer.new
    
    #お互いに手札を配布
    player.start_distribute(deck)
    dealer.start_distribute(deck)

    #初めにプレイヤーに配られた手札表示
    player.display_player_hands
    
    #プレイヤーが手札を交換するかどうか決定
    player.decide_exchange(deck)

    #再びプレイヤーの手札表示
    player.display_player_hands
    
    #プレイヤーの役表示
    character = "あなた"
    player.judge_rank
    player.rank_message(character)
    
    
    #ディーラーが手札を交換,交換メッセージ表示
    dealer.judge_rank
    dealer.dealer_exchange(deck)
    dealer.exchange_message
    dealer.display_dealer_hand
    
    #ディーラーの役表示
    character = "ディーラー"
    dealer.rank_message(character)

    #役の対決
    player.set_point 
    dealer.set_point

    if player.point > dealer.point
      puts "あなたの勝ちです"
    elsif player.point < dealer.point
      puts "ディーラーの勝ちです"
    else
      puts "ドロー"
      if player.sub_point1 > dealer.sub_point1
        puts "あなたの勝ちです"
      elsif player.sub_point1 < dealer.sub_point1
        puts "ディーラーの勝ちです"
      else
        if player.sub_point2 > dealer.sub_point2
          puts "あなたの勝ちです"
        elsif player.sub_point2 < dealer.sub_point2
          puts "ディーラーの勝ちです"
        else
          if player.sub_point3 > dealer.sub_point3
            puts "あなたの勝ちです"
          elsif player.sub_point3 < dealer.sub_point3
            puts "ディーラーの勝ちです"
          else
            if player.sub_point4 > dealer.sub_point4
              puts "あなたの勝ちです"
            elsif player.sub_point4 < dealer.sub_point4
              puts "ディーラーの勝ちです"
            else
              if player.sub_point5 > dealer.sub_point5
                puts "あなたの勝ちです"
              elsif player.sub_point5 < dealer.sub_point5
                puts "ディーラーの勝ちです"
              else
                puts "ドローです"
              end
            end
          end
        end
      end
    end


    #   end
    # end

    
  end

end
