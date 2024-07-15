# frozen_string_literal: true

# ゲームの状況に応じて処理を変化させる。
# デザインパターンのステートパターンで実装しました。

require_relative "factory"
require_relative "signale"



module GameProces
  #################################################################################



  # 　ゲームの要素とステートをまとめるオブジェクト
  class GameContext
    attr_accessor :game_elements_package, :signale, :players, :main_card_deck, :current_field, :old_card_stack

    def initialize
      @current_field = []
      @old_card_stack = []
      @signale = GameSignale.instance
      @players = []
      @main_card_deck = nil
    end

    def players_append(players)
      @players.concat(players)
    end

    def rank
      sort_list = players.sort { |player_1, player_2|
            player_2.len <=> player_1.len
          }
      rank_listt = sort_list.map { |player| "#{player}の手札の枚数は#{player.len}枚です。 " }
      puts rank_listt.join(" ")
    end

    # ゲームのメインループ
    def run(first_state)
      @current_state = first_state

      begin
        next_state = @current_state.do_next_scene(self) # ステートオブジェクトにゲームロジックを移譲、　返り値は次のステートオブジェクト
        @current_state = next_state
      end while @current_state.can_do? # 返されたステートオブジェクトが遷移して処理しても問題ないかのフラグ

      puts "ﾊﾞｲﾊﾞｲ(@^^)/~~~"
    end
  end



  #################################################################################



  # 　基底となるステートオブジェクト
  class BaseState
    attr_reader :can_do, :message

    def initialize(is_continue:, message:)
      @can_do = is_continue
      @message = message
    end

    # 継承先でオーバーライドしてゲームロジックを記述するメソッド。次のステートを返す
    def exec_by_state(current_context) # -> next state
      raise NotImplementedError.new("実装されていません")
    end

    # 　コンテキスト側が呼び出すインターフェース　
    def do_next_scene(current_context) # -> next state
      next_state = exec_by_state(current_context)
      next_state
    end

    def can_do? # コンテキスト側のメインループを抜けるか継続かのグラグ
      @can_do
    end

    def to_s
      @message
    end
  end



  #################################################################################

  #--------------------------------------------------------------



  class GameOverState < BaseState
    def exec_by_state(current_context)
      puts message
      GameOverState.new(is_continue: false, message: "")
    end
  end

  # ⇑⇑⇑

  class ResultState < BaseState
    def exec_by_state(current_context)
      sort_list = current_context.players.sort { |player_1, player_2|
            player_2.len <=> player_1.len
          }

      rank_group = sort_list.group_by { |player| player.len }

      rank_list = []
      cnt = 1
      for _, players in rank_group
        for player in players
          rank_list << "#{player}の手札の枚数は#{player.len}枚で#{cnt}位です "
        end
        cnt += 1
      end

      puts rank_list.join("")

      GameOverState.new(is_continue: true, message: "戦争を終了します")
    end
  end


  # ⇑⇑⇑


  class JudgeState < BaseState
    def exec_by_state(current_context)
      winner_list = Judge(current_context.current_field)

      if winner_list.size == 0
        puts "引き分けです"
        loser_list = empty_player(current_context.players)
        current_context.old_card_stack.concat(current_context.current_field)
        return WarStartState.new(is_continue: true, message: "戦争！") if loser_list.size == 0

        puts loser_list.map { |player| "#{player}の手札のがなくなりました。" }.join(" ")
        return ResultState.new(is_continue: true, message: "ゲーム終了")
      end

      winner_card_and_player = winner_list[0]
      win_player = winner_card_and_player[:player]
      winner_card_and_player[:card]
      current_context.old_card_stack.concat(current_context.current_field)
      field_card = current_context.old_card_stack.map { |card_and_player| card_and_player[:card] }
      current_context.old_card_stack = []
      puts "#{win_player}が勝ちました 。#{win_player}はカードを#{field_card.size}枚もらいました。"
      win_player.insert_drawn_card_list(field_card)

      loser_list = empty_player(current_context.players)

      return WarStartState.new(is_continue: true, message: "戦争！") if loser_list.size == 0


      puts loser_list.map { |player| "#{player}の手札のがなくなりました。" }.join(" ")
      ResultState.new(is_continue: true, message: "ゲーム終了")
    end

    private
      def Judge(current_field_list)
        max_card_and_player = current_field_list.max { |card_and_player_1, card_and_player_2|
          card_and_player_1[:card] <=> card_and_player_2[:card]
        }

        winners = current_field_list.select { |card_and_player|
          card_and_player[:card] == max_card_and_player[:card]
        }

        return winners if winners.size == 1

        if max_card_and_player[:card].card_numeric_value.raw_value == 1
          return  winners.select { |card_and_player|
                 card_and_player[:card].suit == :スペード
               }
        end

        []
      end

      def empty_player(player_list) # -> Player
        player_list.select { |player|
          player.len == 0
        }
      end

      def winner_insert_all_cards(win_player, current_field_list)
        field_card = current_field_list.map { |card_and_player| card_and_player[:card] }
        win_player.insert_drawn_card_list(field_card)
      end
  end

  # ⇑⇑⇑

  class WarStartState < BaseState
    def exec_by_state(current_context)
      puts message

      current_context.current_field = current_context.players.map { |player|
        player_and_card = player.present_a_card
        player = player_and_card[:player]
        card = player_and_card[:card]
        card.show_card_contents(player)
        player_and_card
      }


      JudgeState.new(is_continue: true, message: "")
    end
  end

  # ⇑⇑⇑


  class GameStartState < BaseState
    def exec_by_state(current_context)
      puts message

      deck, players = create_deck_and_player()
      current_context.players_append(players)
      current_context.main_card_deck = deck
      deck_cards_into_player(deck, players)

      current_context.signale.card_num_type__sig__insert_rule do # カードを比較する際のメソッドを動的に変更
        if @raw_value == 1
          14
        else
          @raw_value
        end
      end


      puts "カードが配られました。"

      WarStartState.new(is_continue: true, message: "戦争！")
    end


      private
        def create_deck_and_player
          players = Factorys::Players.new().create_players_by_names()
          deck = Factorys::DeckFactory.new(has_joker: true).create_deck()
          return deck, players
        end

        def deck_cards_into_player(deck, players)
          players.each do |player|
            player.setup_hand_of_cards(
                deck.draw_card(5)
              )
          end
        end
  end

  #--------------------------------------------------------------
end

def test
  context = GameProces::GameContext.new
  context.run(GameProces::GameStartState.new(is_continue: true, message: "戦争を開始します。"))
end

if __FILE__ == $0
  test
end
