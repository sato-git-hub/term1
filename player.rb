class Player
  attr_reader :name
  attr_accessor :open_card, :hand, :get_card

  def initialize(name)
    @name = name
    # gameクラスのsliceメソッドで生成
    @hand = []

    @open_card = nil
    # gameクラスのgetメソッドで生成 勝ったときに手に入れた場札
    @get_card = []
  end

  # カードを出す
  def open
    @open_card = @hand.pop
    [self, open_card]
  end

  # 合計手札と、獲得済みの場札の合計枚数をかえす
  def total_length
    @hand.length + @get_card.length
  end

  # 手札が0の場合 場札をシャッフルして手札に加える
  def charge
    @hand.concat(@get_card)
    @hand.shuffle!
    hand = @hand
    @get_card = []
    [self, hand]
  end
end
