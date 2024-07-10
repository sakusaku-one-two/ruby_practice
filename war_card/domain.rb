
# 基本ルール　
#・実行開始時に、デイーラーとプレイヤー全員に2枚ずつカードが配られる。
#・自分のカードが21に近づくよう、カードを追加するか、追加しないかを決める
#・プレイヤーはカードの合計値が21、好きなカードを追加できる
#・
#
#


module BlackJackDomains

    class Suit #英語でトランプの柄をスートと言うそうです。　ｂｙ　google 先生
        def initialize (suit_name)
            @suit_name = suit_name
        end 
        def to_s
            return @suit_name
        end
        def get_suit_name
            return @suit_name
        end
    end 



    module CardTypes
        HEART = Suit.new('ハート')
        SPADE = Suit.new('スペード')
        DIAMOND = Suit.new('ダイア')
        CLUB = Suit.new('クラブ')
        def self.getLists()
            return [
                HEART,
                SPADE,
                DIAMOND,
                CLUB,
            ]
        end
    end 




    class Card
        
        attr_reader :no,:suit
        
        CARD_NUMBER_TO_STRING = Proc.new {|no|
            case no 
                when 1
                    "A" 
                when 11
                    "J"
                when 12
                    "Q"
                when 13
                    "K"
                else
                    no
            end
        }
        def initialize(no:,suit:)
            unless suit.is_a?(Suit)
                raise  ArgumentError,"カードタイプクラス以外の型が渡されています。"
            end 
            @no = CARD_NUMBER_TO_STRING.call(no) #もし11や13などの数値を文字　例　11＝＞J　に変換する
            @original_no = no
            @card_suit = suit
            @is_show = false
        end 

        def to_s
            "#{@card_suit}の #{@no}"
        end

        def show_card_contents(player)
            puts "#{player}のカードは#{@card_suit}の#{@no}です。"
        end 
    end 




    class WarCard < Card
        include Comparable
        attr_reader :amount
        CHANGE_AMOUNT = Proc.new { |amount|
            case amount
                when 1
                    14
                when :JOKER
                    15
                else
                    amount    
            end 
        }

        def initialize(**kwargs)
            super(**kwargs)
            @amount = CHANGE_AMOUNT.call(kwargs[:no])
        end

        def <=> (other_card) 
           return @amount <=> other_card.amount
        end

    end




    class BasePlayer
        NAME ="基本プレイヤー"
        attr_accessor :player_name,:is_parent
        def initialize(player_no=1)
            @player_name = "プレイヤ-#{player_no}"
            @has_cards = []
            @total_amount = 0
            @is_parent = false
        end

        def to_s
            return @player_name
        end 
        def name
            self.class::NAME#
        end

        def draw_card(a_card)
            a_card.show_card_contents(self)
        end
        

    end     

    class Player < BasePlayer
        NAME ="プレイヤー"

    end 

    class Dealer < BasePlayer
        NAME = "ディーラー"


    end 

end


