class Deck
  attr_accessor :suit
  #山札を生成
  def initialize(cards:)
    @cards = []

    #スートと数字を定義
    suits = ["スペード", "ハート", "ダイヤ", "クローバー"]
    numbers = ["A","2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

    #それぞれのスートにそれぞれの数字を当てはめたインスタンスを作成し、追加
    suits.each do |suit|
      numbers.each do |number|
        card = Card.new(suit, number)
        @cards << card
      end
    end
    #デッキをシャッフル
    @cards.shuffle!
  end

  def draw
    @cards.shift
  end
end

class Hand
  
end



class Porker
  deck = Deck.new
  hand = Hand.new
end

deck.draw