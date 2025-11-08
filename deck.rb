require_relative 'card'

class Deck
  attr_reader :cards

  # 52枚のカードを配列に
  def initialize
    # マークごとに13通りのcardクラスのインスタンスを生成し配列✖️４　[[ハートの13通り],[クローバーの13通り],[スペードの13通り],[ダイヤのの13通り]]を1つの配列に　[ハートの13通り,クローバーの13通り....]
    @cards = Card::MARK.flat_map do |m|
      Card::NUMBER.map { |n, _s| Card.new(m, n) }
    end
  end
end
