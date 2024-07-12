
# 基本ルール　
#・実行開始時に、デイーラーとプレイヤー全員に2枚ずつカードが配られる。
#・自分のカードが21に近づくよう、カードを追加するか、追加しないかを決める
#・プレイヤーはカードの合計値が21、好きなカードを追加できる
#・
#
#
require_relative 'Services'
include GameHandler

#カードゲームで使用する基本的な要素をクラスで表現
module CardGameElement

    class Suit #英語でトランプの柄をスートと言うそうです。　google 先生調べ
        def initialize (suit_name)
            @suit_name = suit_name
        end 
        def to_s
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



                
    class CardNumericValue

        CARD_NUMBER_TO_STRING = Proc.new {|number_value|
            case number_value 
                when 1
                    "A" 
                when 11
                    "J"
                when 12
                    "Q"
                when 13
                    "K"
                when Float::INFINITY #ジョーカーの場合
                    :JOKER.to_s
                else
                    number_value.to_s
            end
        }

        def initialize(numeric_value_as_int_or_Infinity)
            @raw_value = numeric_value_as_int_or_Infinity
            @notation = CARD_NUMBER_TO_STRING.call(@raw_value) 
        end

        def to_s
            return @notation
        end

        def <=> (other_numeric)
            raise TypeError.new("CardNumericValue以外の型と比較しようとしてますよ〜。") if other_numeric.instance_of?(self.class)
            return @raw_value <=>  other_numeric.raw_value
        end



    #　カードクラス　
    class Card
        include Comparable
       
        #　カードの番号がもし1や12だった場合　エースやキングに変更する
        

        attr_reader :notation,:suit,:card_numeric_value
        def initialize(card_numeric_value:,suit:)
            raise  TypeError "カードのアイコンとなるスート型以外の型が渡されています。" unless suit.is_a?(Suit)
            @card_suit = suit
            @card_numeric_value = card_numeric_value
            
        end 

        def to_s
           return "#{@card_suit}の #{@card_numeric_value}"
        end

        def show_card_contents(player)
            puts "#{player}のカードは#{@card_suit}の#{@card_numeric_value}です。" 
        end
        
        def <=> (other) 
            raise TypeError.new("比較対象はカードクラスにしてください。") if other_card.is_a?(self.class)
           return   @card_numeric_value <=> other.card_numeric_value
        end
    end 



    class Deck

        def initialize(card_list:)
            #　コルーチンを使用してみたかった・・・だけです
            @deck_as_genelater = Fiber.new do |get_count|
                while card_list.length >=  get_count or card_list.length >= 0
                    card_list.shuffle!  
                    get_count = Fiber.yield( card_list.pop(get_count))
                end
                return card_list
            end
        end

        def draw_card(count)
            return [] unless @deck_as_genelater.alive?

            begin
                cards = @deck_as_genelater.resume(count)
            rescue StopIteletion => retrun_value
                cards = retrun_value.result
            end
            return cards 
        end
    end



    class BasePlayer

        def initialize(player_no)
            @player_name = "プレイヤー #{player_no}"
            @hand_of_cards = [] #手持ちのカード
            @symbolic_order = SymbolicOrder.instance #プレイヤーが従うゲームのルール  シングルトンで実装しておりメソッドをヘルパーとして利用、ヘルパーの処理内容はgaem ruleとして注入する
        end


        def to_s
            return @player_name
        end 
        
    end     

    class WarCardPlayer < BasePlayer
    
        def initialize(player_no)
            super(player_no)
        end
    end 

    class Dealer < BasePlayer
        NAME = "ディーラー"

    end 

end


