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
    player.judge_rank(character)
    
    
    #ディーラーが手札を交換,交換メッセージ表示,手札表示
    
    character = "ディーラー"
    dealer.judge_rank(character)
    # player.rank_message(character)
    
    dealer.dealer_exchange(deck)
    dealer.exchange_message
    dealer.display_dealer_hand

    #ディーラーの役表示
    dealer.judge_rank(character)

    #役の対決
    player.set_point 
    dealer.set_point
    if player.point > dealer.point
      puts "あなたの勝ちです"
    elsif player.point < dealer.point
      puts "ディーラーの勝ちです"
    else player.point == dealer.point
      puts "ドローです"
    end

    
  end

end
