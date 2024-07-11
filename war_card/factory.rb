require_relative 'domain'
include BlackJackDomains

CARD_SUITS = [
    CardTypes::HEART,
    CardTypes::SPADE,
    CardTypes::DIAMOND,
    CardTypes::CLUB
]



module Factorys
    include BlackJackDomains

    class DeckFactory #カードのデッキを作成する
        

        def initialize(card_type: Card,has_joker:false)
            @has_joker = has_joker
            raise  TypeError("カードクラスではありません！！") unless  card_type <= Card
            @card_type = card_type #<= CardクラスまたはCardクラスを継承したクラスオブジェクト
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
                all_cards.concat(_create_cards_by(suit))
            end

            all_cards<< @card_type.new(no: :JOKER,suit: Suit.new("JOKER")) if @has_joker

            return all_cards
        end
        
        private
        def _create_cards_by(suit)
            return (1..13).map { |i| @card_type.new(no:i,suit:suit)}
        end
    end



    class Players
        def self.create_players count
            return (1..count).map {|i| Player.new(i)}
        end
    end



end





