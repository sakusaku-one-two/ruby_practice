require 'singleton'
require_relative "factory"

include Factorys


module domainSarvices

    class GameHnadler
        include singleton
        def initialize(all_players:,deck:,initial_card_count_for_player:)
            @all_players = all_players
            @deck = deck
            @initial_card_count_for_player  = initial_card_count_for_player
            
            

        end


    class Main  

        def initialize
            @players = Players.get_players
        end        

end