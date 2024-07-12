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

        def create_deck
            cards = create_cards()
            5.times do
                cards.shuffle!()
            end
            return Deck.new(card_list: cards)
        end

        def create_cards
            all_cards = []
            CARD_SUITS.each do  |suit|
                all_cards.concat(_create_cards_based_on(suit))
            end
            all_cards << Card.new(no: Float::INFINITY ,suit: Suit.new(:JOKER)) if @has_joker
            return all_cards
        end
        
        private

        def _create_cards_based_on(suit)
            return (1..13).map { |card_number| Card.new(no:card_number,suit:suit)}
        end
    end



    class Players
        def self.create_players count
            return (1..count).map {|i| Player.new(i)}
        end
    end



end





