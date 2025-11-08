class Card
  attr_reader :mark, :number, :strong

  # 定数にして中身が変えられないようにする
  MARK = %w[ハート クローバー スペード ダイヤ]
  NUMBER = { 'A' => 14, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 'J' => 11, 'Q' => 12,
             'K' => 13 }

  def initialize(mark, number)
    @mark = mark
    @number = number
    @strong = NUMBER[@number]
  end
end
