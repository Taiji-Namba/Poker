require "./deck"
require "./card"
require "./hand"
require "./player"
require "./dealer"

class GamesController
  
  def start
    puts <<~EOS
    ------------------------------------
    |                                  |
    |           Start of Poker         |
    |                                  |
    ------------------------------------
    EOS
    
    deck = Deck.new
    player = Player.new
    dealer = Dealer.new
    
    #お互いに手札を配布
    player.start_distribute(deck)
    dealer.start_distribute(deck)

    #初めにプレイヤーに配られた手札表示
    player.display_player_hands
    
    #プレイヤーが手札を交換(or交換しない),交換した手札の表示
    player.player_exchange(deck)

    #再びプレイヤーの手札表示
    player.display_player_hands

    #プレイヤーの役の判定
    player.judge_rank
    
    #プレイヤーの役表示
    character = "あなた"
    player.rank_message(character)
    
    #ディーラーが手札を交換,交換メッセージ表示
    dealer.judge_rank
    dealer.dealer_exchange(deck)
    dealer.exchange_message

    #ディーラーの手札表示
    dealer.display_dealer_hand
    
    #ディーラーの役判定,表示
    dealer.judge_rank
    character = "ディーラー"
    dealer.rank_message(character)

    #playerとdealerが対決
    player.set_point 
    dealer.set_point

    if player.point > dealer.point
      puts "おめでとうございます！あなたの勝ちです"
    elsif player.point < dealer.point
      puts "ディーラーの勝ちです"
    else
      if player.sub_point1 > dealer.sub_point1
        puts "おめでとうございます！あなたの勝ちです"
      elsif player.sub_point1 < dealer.sub_point1
        puts "ディーラーの勝ちです"
      else
        if player.sub_point2 > dealer.sub_point2
          puts "おめでとうございます！あなたの勝ちです"
        elsif player.sub_point2 < dealer.sub_point2
          puts "ディーラーの勝ちです"
        else
          if player.sub_point3 > dealer.sub_point3
            puts "おめでとうございます！あなたの勝ちです"
          elsif player.sub_point3 < dealer.sub_point3
            puts "ディーラーの勝ちです"
          else
            if player.sub_point4 > dealer.sub_point4
              puts "おめでとうございます！あなたの勝ちです"
            elsif player.sub_point4 < dealer.sub_point4
              puts "ディーラーの勝ちです"
            else
              if player.sub_point5 > dealer.sub_point5
                puts "おめでとうございます！あなたの勝ちです"
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
  end
    
    


end
