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
    hand = Hand.new
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
    dealer.dealer_exchange(deck)
    dealer.exchange_message
    dealer.display_dealer_hand

    #ディーラーの役表示
    character = "ディーラー"
    player.judge_rank(character)

  end

end
