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
            unless  card_type <= Card
                raise  ArgumentError("カードクラスではありません！！")
            end 
            @card_type = card_type
        end

        def create_cards
            all_cards = []
            CARD_SUITS.each do  |suit|
                all_cards.concat(_create_card_by(suit))
            end
            return all_cards
        end
        

        def _create_card_by(suit)
            
            cards = (1..13).map { |i| @card_type.new(no:i,suit:suit)}

            cards <<  @card_type.new(no: :JOKER,suit:suit)  if @has_joker 
             
            return cards
        end
    end



    class Players
       
       
        def self.get_players count
            return (1..count).map {|i| Player.new(i)}
        end
    end



end





