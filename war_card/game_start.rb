# frozen_string_literal: true

require_relative "gameContext"


def main
    context = GameProces::GameContext.new
    context.run(GameProces::GameStartState.new(is_continue: true, message: "戦争を開始します。"))
end



main
