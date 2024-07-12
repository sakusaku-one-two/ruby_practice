require_relative "domain"
require_relative "factory"

include Factorys
include BlackJackDomains



def test_card(strategy_funciton)
    deck = Factorys::DeckFactory.new(card_type:WarCard,has_joker:false).create_deck()
    
    strategy_funciton.call(deck)


end



def test_get_players (cnt)
     Factorys::Players.create_players (cnt)
end


def check_deck(deck)
    player_1,player_2 = test_get_players(2) 

    puts "#{player_1}and#{player_2}"
    cnt = 0
    20.times do
        puts "---------------"
        puts deck.drow_card(10)
        puts "**--**--**--**--"
        puts deck.drow_card(2)
        puts "**--**--**--**--"
        cnt +=1
        puts cnt
    end
    puts "end" 
end



test_card(method(:check_deck))
