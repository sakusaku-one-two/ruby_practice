# frozen_string_literal: true

require "singleton"
require_relative "signale"

# カードゲームで使用する基本的な要素をクラスで表現
module CardGameElement
  class Suit # 英語でトランプの柄をスートと言うそうです。　google 先生調べ
    attr_accessor :suit_name
    def initialize (suit_name)
      @suit_name = suit_name
    end
    def to_s
      @suit_name.to_s
    end
  end



  module CardTypes
    HEART = Suit.new(:ハート)
    SPADE = Suit.new(:スペード)
    DIAMOND = Suit.new(:ダイア)
    CLUB = Suit.new(:クラブ)
    def self.getLists
      [
          HEART,
          SPADE,
          DIAMOND,
          CLUB,
      ]
    end
  end




  class CardNumericValue
    include Comparable
    CARD_NUMBER_TO_STRING = Proc.new { |number_value|
      case number_value
          when 1
            "A"
          when 11
            "J"
          when 12
            "Q"
          when 13
            "K"
          when Float::INFINITY # ジョーカーの場合
            "ジョーカー"
          else
            number_value.to_s
      end
    }
    attr_accessor :raw_value
    GameSignale.instance.observer_registry("card_num_type", self)
    def initialize(numeric_value_as_int_or_Infinity)
      @raw_value = numeric_value_as_int_or_Infinity
      @notation = CARD_NUMBER_TO_STRING.call(@raw_value)
    end

    def to_s
      @notation
    end

    # ゲームのルールによって数値の強さを変化させるためのメソッド　
    def order_by_rule
      @raw_value
    end

    # 動的にメッソドをオーバーライド
    def self.insert_rule(&block)
      define_method(:order_by_rule, &block)
    end

    def <=> (other_numeric)
      raise TypeError.new("CardNumericValue以外の型と比較しようとしてますよ〜。") unless other_numeric.instance_of?(self.class)
      order_by_rule() <=> other_numeric.order_by_rule()
    end
  end



  # 　カードクラス　
  class Card
    include Comparable

    # 　カードの番号がもし1や12だった場合　エースやキングに変更する
    attr_reader :notation, :card_suit, :card_numeric_value
    def initialize(card_numeric_value:, suit:)
      raise TypeError "カードのアイコンとなるスート型以外の型が渡されています。" unless suit.is_a?(Suit)
      @card_suit = suit
      @card_numeric_value = card_numeric_value
    end

    def suit
      @card_suit.suit_name
    end

    def to_s
      "#{@card_suit}の #{@card_numeric_value}"
    end

    def show_card_contents(player)
      puts "#{player}のカードは#{@card_suit}の#{@card_numeric_value}です。"
    end

    def <=> (other)
      raise TypeError.new("比較対象はカードクラスにしてください。#{self.class} <> #{other.class}") unless other.is_a?(self.class)
      @card_numeric_value <=> other.card_numeric_value
    end
  end



  class Deck
    attr_accessor :card_list, :deck_as_genelater

    def initialize(card_list)
      set_gen_deck(card_list)
    end

    def set_gen_deck(card_list)
      @card_list = card_list
      # 　コルーチンを使用してみたかった・・・だけです
      @deck_as_genelater = Fiber.new do |get_count|
        while @card_list.length >= get_count || @card_list.length >= 0
          @card_list.shuffle!
          get_count = Fiber.yield(@card_list.pop(get_count))
        end
        return @card_list
      end
    end

    def concat_list(card_list)
      set_gen_deck(
       @card_list.concat(card_list)
     )
    end

    def len
      @card_list.size
    end

    def list_tracelate # 　中の配列を外にだして、初期化　配列の移行で使用
      temp_list = @card_list # 　ジェネレーターを初期化すると副作用でインスタンス変数のcard_listの参照リストが変更されてしまうので、現在の参照リストを退避
      set_gen_deck([]) # 空配列でジェネレーターを初期化
      temp_list
    end

    def draw_card(count) # -> array[ ...crad ] or  []
      begin
        cards = @deck_as_genelater.resume(count)
      rescue StopIteletion => retrun_value
        cards = retrun_value.result
      end
      cards
    end
  end




  # 　プレイヤーの手札
  class HandOfCards
    def initialize(player)
      @player = player
      @my_deck = Deck.new([]) # 主要となるデッキ
      @sub_deck = Deck.new([]) # 取得したカードを保持するデッキ
      @signale = GameSignale.instance
      @signale.observer_registry("hand_of_cards", self)
    end

    def len
      @my_deck.len + @sub_deck.len
    end
    #
    def setup_hand_of_cards(card_list)
      @my_deck.set_gen_deck(card_list)
    end

    # 勝った際に取得したカードのリストを入れる
    def insert_drawn_card_list(card_list)
      @sub_deck.concat_list(card_list)
    end

    # カードを一枚取得
    def present_a_card
      return @my_deck.draw_card(1) if @my_deck.len >= 1

      @my_deck.concat_list(@sub_deck.list_tracelate())

      @my_deck.draw_card(1)
    end
  end


  class Player
    def initialize(player_name)
      @player_name = player_name
      @hand_of_cards = HandOfCards.new(self) # 手持ちのカード
      @signale = GameSignale.instance
      @signale.observer_registry("user", self)
    end

    def setup_hand_of_cards(card_list)
      @hand_of_cards.setup_hand_of_cards(card_list)
    end

    def insert_drawn_card_list(card_list)
      @hand_of_cards.insert_drawn_card_list(card_list)
    end

    def len
      @hand_of_cards.len
    end

    def present_a_card
      {
          player: self,
          card: @hand_of_cards.present_a_card()[0]
      }
    end



    def to_s
      @player_name
    end
  end
end


def deck_test
  deck = CardGameElement::Deck.new(["ino", "saku"])
  puts deck.draw_card(2)
  puts deck.draw_card(2)
end
