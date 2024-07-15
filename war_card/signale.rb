# frozen_string_literal: true

require "singleton"

# シングルトンでオブザーバーパターンをメタプログラミングのメソッドミッシングを利用して オブジェクト同士でコミュニケーションを図れるように


class GameSignale
  include Singleton

  def initialize
    @signales = {}
  end

  def method_missing(signale_name_to_call_method_name, *args, &block)
    signale_name, call_method_name = signale_name_to_call_method_name.to_s.split("__sig__")

    return nil unless @signales.key? signale_name.to_s

    @signales[signale_name].each do |observer|
      observer.send(call_method_name, &block)
    end
  end

  def observer_registry(signale_name, observer)
    if  @signales.key? signale_name

      @signales[signale_name] << observer
    else

      @signales[signale_name] = [observer]
    end
  end

  def show
    @signales.inspect
  end
end
