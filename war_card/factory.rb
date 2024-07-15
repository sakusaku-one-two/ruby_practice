# frozen_string_literal: true


require_relative "domain"
include CardGameElement

CARD_SUITS = [
    CardTypes::HEART,
    CardTypes::SPADE,
    CardTypes::DIAMOND,
    CardTypes::CLUB
]



module Factorys
  include CardGameElement

  class DeckFactory # カードのデッキを作成する
    def initialize(has_joker: false)
      @has_joker = has_joker # ジョーカーをデッキに含めるかのフラグ
    end

    # デッキを作成するメソッド
    def create_deck
      cards = create_cards()
      5.times do
        cards.shuffle!()
      end
      Deck.new(cards)
    end

    # 　4種類のマーク　☓　1〜13のカードとジョーカーを合計したカードオブジェクトの配列を返す。
    def create_cards
      all_cards = []
      CARD_SUITS.each do  |suit|
        all_cards.concat(_create_cards_based_on(suit))
      end
      all_cards << Card.new(card_numeric_value: Float::INFINITY, suit: Suit.new("最強")) if @has_joker
      all_cards
    end

      private
        # 引数のマークで1~13のカードを生成
        def _create_cards_based_on(suit)
          (1..13).map { |card_number|
              card_number_value = CardNumericValue.new(card_number)
              Card.new(card_numeric_value: card_number_value, suit: suit)
            }
        end
  end



  class Players
    def initialize(player_type: Player)
      @player_type = player_type
    end

    # 数値で作成
    def create_players(count)
      (1..count).map { |i| @player_type.new("プレイヤー #{i}") }
    end

    # 　名前を指定した回数入力して作成　advancedで利用
    def create_players_by_names
      while true
        print "プレイヤーの人数を入力してください（2〜5）: "
        max_count = gets.chomp.to_i
        break if  max_count.instance_of?(Integer) && (max_count >= 2 && max_count <= 5)
      end

      (1..max_count).map  { |i|
            print "プレイヤー#{i}の名前を入力してください: "
            player_name = gets.chomp
            @player_type.new(player_name)
          }
    end
  end
end



if __FILE__ == $0

  puts Factorys::Players.new(player_type: WarCardPlayer).create_players_by_names()
end
