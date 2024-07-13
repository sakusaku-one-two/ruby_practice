require_relative 'domain'
include CardGameDomains

CARD_SUITS = [
    CardTypes::HEART,
    CardTypes::SPADE,
    CardTypes::DIAMOND,
    CardTypes::CLUB
]



module Factorys
    include CardGameDomains

    class DeckFactory #カードのデッキを作成する
        
        def initialize(has_joker:false)
            @has_joker = has_joker #ジョーカーをデッキに含めるかのフラグ
        end

        #デッキを作成するメソッド
        def create_deck
            cards = create_cards()
            5.times do
                cards.shuffle!()
            end
            return Deck.new(card_list: cards)
        end

        #　4種類のマーク　☓　1〜13のカードとジョーカーを合計したカードオブジェクトの配列を返す。
        def create_cards
            all_cards = []
            CARD_SUITS.each do  |suit|
                all_cards.concat(_create_cards_based_on(suit))
            end
            all_cards << Card.new(card_numeric_value: Float::INFINITY ,suit: Suit.new("最強")) if @has_joker
            return all_cards
        end
        
        private
        # マークの1~13のカードを生成
        def _create_cards_based_on(suit)
            return (1..13).map { |card_number| 
            card_number_value = CardNumericValue.new(card_number)
            Card.new(card_numeric_value: card_number_value,suit: suit)
            }
        end

    end



    class Players
        def self.create_players count
            return (1..count).map {|i| Player.new(i)}
        end
    end



end





