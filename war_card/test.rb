require_relative "domain"
require_relative "factory"

include Factorys
include BlackJackDomains



def test_card(strategy_funciton)
    deck = Factorys::DeckFactory.new(card_type:WarCard,has_joker:false).create_cards()
    
    strategy_funciton.call(deck)


end



def test_get_players (cnt)
     Factorys::Players.get_players (cnt)
end


def check_deck(deck)
    player_1,player_2 = test_get_players(2) 

    puts "#{player_1}and#{player_2}"
    shuffle_arry = deck.shuffle
    while shuffle_arry.size >= 2
        card_1,card_2 = shuffle_arry.pop(2)
        if card_1 > card_2
            puts "#{card_1}は #{card_2}より強い"
        elsif card_1 = card_2
            puts "#{card_1}は #{card_2}はおなじ"
        else
            puts "#{card_1}は #{card_2}より弱い"
        end 


    end
    
end



test_card(method(:check_deck))
