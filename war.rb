
class Card
  attr_reader :mark, :number, :strong

  #定数にして中身が変えられないようにする
  MARK = ["ハート", "クローバー", "スペード", "ダイヤ"]
  NUMBER = {"A"=>14,2=>2,3=>3,4=>4,5=>5,6=>6,7=>7,8=>8,9=>9,10=>10,"J"=>11,"Q"=>12,"K"=>13}

  def initialize(mark, number, strong)
    
    @mark = mark
    @number = number
    @strong = NUMBER[@number]

  end
end

class Deck
  attr_reader :cards
  #52枚のカードを配列に
  def initialize
    #マークごとに13通りのcardクラスのインスタンスを生成し配列✖️４　[[ハートの13通り],[クローバーの13通り],[スペードの13通り],[ダイヤのの13通り]]を1つの配列に　[ハートの13通り,クローバーの13通り....]
    @cards = Card::MARK.flat_map do |m|
      Card::NUMBER.map { |n,s| Card.new(m, n, s) }
    end
  end
end

class Player
  attr_reader :name
  attr_accessor :open_card, :hand, :get_card
  def initialize(name)
    @name=name
    #gameクラスのsliceメソッドで生成
    @hand=[]
    #openメソッドで生成　手札の配列から末尾の要素を取り出したもの
    @open_card=[]
    #gameクラスのgetメソッドで生成 勝ったときに手に入れた場札
    @get_card=[]
  end

  #カードを出す
  def open
    @open_card = @hand.pop 
    puts "#{@name}は#{@open_card.mark}の#{@open_card.number}を出しました"
  end

  #合計手札と、獲得済みの場札の合計枚数をかえす
  def total_length
    return @hand.length+@get_card.length
  end

  #手札が0の場合 場札をシャッフルして手札に加える
  def charge
    @hand.concat(@get_card)
    @hand.shuffle!
    @get_card = []
    puts "#{@name}は獲得済みだった場札を手札に加えました。手札は残り#{@hand.length}枚です。"
  end
end

class Game
  attr_reader :player_array, :winner, :opened_card
  def initialize
    #player_makeメゾットで生成
    @player_array=[]
    #デッキ作成
    @deck=Deck.new
    #judgeメゾットで生成　
    @card_judge=[]
    #judgeメゾットで生成　勝者のplayerクラスのインスタンス
    @winner=nil
    #collectメソッドで生成　場札
    @opened_card=[]

  end


  #player作成
  def player_make

    #ユーザーにプレーヤー人数を入力してもらうための処理
    correct=true
    #2~5の整数を入力しない間はwhile文の処理が繰り返される
    while correct do
      puts "プレイヤーの人数を入力してください（2〜5）:"
      n=gets.to_i
      #while文を抜ける
      break if n >= 2 && n <= 5
      puts "2~5の整数を入力してください"  unless n >= 2 && n <= 5
    end

    #ユーザーにプレーヤー人数を入力してもらうための処理
    1.upto(n) do |m| 

      puts "プレイヤー#{m}の名前を入力してください:"
      name=gets.chomp
      @player_array << Player.new(name)
    end
  end

  #プレーヤにカードを配る
  #@deck.cards=[cardクラスのインスタンス,...]
  def slice
    #カードをシャッフルする
    shuffled_cards = @deck.cards.shuffle
    shuffled_cards.each_with_index do |v,i|
      n=i%@player_array.length
      @player_array[n].hand << v
    end
  end

  #handが空になったplayerがいないか確認
  #handが空になった時の動き
  def check
    should_continue = true
    @player_array.each do |i|
      #手札と場札を合わせた数が０だったら
      if i.total_length == 0
         puts "#{i.name}の手札が0になりました。ゲームを終了します。"
         #結果発表
         result
         #checkメソッド実行時の返り値がfalseとなる
         should_continue=false
         #最初に当てはまったプレーヤーがいた時点でeach文を抜ける
         break  
       #手札のみ、0の場合       
      elsif i.hand.empty?
        #場札を手札に加える
          i.charge
      end  
    end
    #手札と場札を合わせた数が0という条件に当てはまらなければ、checkメソッド実行時の返り値はtrueとなる
    return should_continue
  end

  #ゲーム繰り返し部分
  def play
    #checkメソッドの返り値がtrueの間はwhile文の処理を続ける
    while check do
      puts "戦争！"
      #カードを出す　openメソッドをplayer一人ずつに実行
      @player_array.each(&:open)
      #勝者の判定
      judge
    end
  end


  #勝者の判定
  def judge
    @player_array.each do |player|
      #出したカードインスタンス、playerインスタンスを一つの配列に[[出したカード,プレーヤー],[出したカード,プレーヤー]]
      @card_judge << [player.open_card, player]
    end

    max_value = @card_judge.map { |card, name| card.strong }.max
    #[[出したカード,プレーヤー],[２つ目の配列]...]から[出したカード,プレーヤー]を順番に取り出し、出したカードの強さが一番大きい値をもった配列を、すべてsame_valueに代入
    same_value = @card_judge.filter { |card, name| card.strong == max_value }

    #一番強いカードを出したプレーヤーが複数人いるとき　same_valueに代入された配列が１つ以上ある時　[[],[]]
    if same_value.length > 1 
      
      a = same_value.filter{|card, name| card.strong == 14 }
      spade = a.filter{|card, name| card.mark == "スペード"}
        #スペードのAを出したプレーヤーが存在した場合
        if spade.length == 1
          @winner=spade[0][1]
          #場札を集める
          collect
          #勝者が場札を受け取る
          get
          #配列のリセット
          @card_judge = []
        else     
          puts "引き分けです"
        end
  
    #一番強いカードを出したプレーヤーが１人の場合 [[]]
    else
      #[[]]この形の配列を一つの配列にまとめる[]
      same_value.flatten!
      #配列の2つ目の要素であるプレーヤーインスタンスを代入
      @winner = same_value[1]
      puts "#{@winner.name}が勝ちました。#{@winner.name}はカードを#{@card_judge.length}枚もらいました。"
      #場札を集める
      collect
      #勝者が場札を受け取る
      get
      #配列のリセット
      @card_judge =[]
    end
  end


  #だれかの手札が0になったら表示する結果発表
  def result

    #[プレーヤーインスタンス,手札の枚数,手札と場札をあわせた合計枚数]を各々のプレーヤーインスタンス分、配列に格納
    final_data = @player_array.map do |i|
      [i,i.hand.length,i.total_length]
    end
    #手札と場札を降順になるように配列を並び替え　[[1つ目の配列],[2つ目の配列]...]
    final_data.sort_by! do |player, hand, total|
      [-hand, -total]
    end
    #結果発表
    #[[1つ目の配列],[2つ目の配列]...]から[1つ目の配列]を取り出す　
    final_data.each_with_index do |item, index|
    #[1つ目の配列]の１つ目の要素であるplayerインスタンスをplayerに代入
    player = item[0]
    puts "#{index + 1}位は#{player.name}で、手札は#{player.hand.length}枚、獲得済みの場札は#{player.get_card.length}枚です。"
    end
  end

#場札を集める　#全員のopen_cardをリセットする
  def collect
    @player_array.each do |i|
      @opened_card << i.open_card
      i.open_card = []
    end
  end

  #勝者が場札を受け取る
  #playerインスタンスを引数に入れる
  def get
    @winner.get_card << @opened_card
    @winner.get_card.flatten!
    @opened_card = []
  end
end

game=Game.new
#player作成、配列にまとめる
game.player_make
#playerのインスタンス変数hand（配列）にデッキをふりわけ
game.slice
game.play