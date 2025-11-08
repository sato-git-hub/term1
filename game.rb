require_relative 'deck'
require_relative 'game_master'
require_relative 'player'
class Game
  attr_reader :players, :opened_card

  def initialize
    # player_makeメゾットで生成
    @players = []
    # デッキ作成
    @deck = Deck.new
    # ゲームマスター生成
    @game_master = GameMaster.new
    # collectメソッドで生成　場札
    @opened_card = []
    @card_judge = []
  end

  # playerの初期設定
  def decide_about_player
    num = decide_number
    # ask_name から配列 (names) を受け取る
    names = ask_name(num)

    names.each do |name|
      # Player インスタンスを作成し、@players 配列に追加
      @players << Player.new(name)
    end

    # 登録されたプレイヤー名を表示
    puts '--- 登録完了 ---'
    @players.each_with_index do |player, index|
      puts "プレイヤー #{index + 1}: #{player.name}"
    end
  end

  # プレーヤにカードを配る
  # @deck=[@mark=ハート,@number="A",@strong=14,cardクラスのインスタンス...]
  def slice
    # カードをシャッフルする
    shuffled_cards = @deck.cards.shuffle
    shuffled_cards.each_with_index do |v, i|
      n = i % @players.length
      @players[n].hand << v
    end
  end

  # handが空になったplayerがいないか確認
  # handが空になった時の動き
  def check
    should_continue = true
    @players.each do |player|
      # 手札と場札を合わせた数が０だったら
      if player.total_length == 0
        @game_master.announce_game_end(player.name)
        # 結果発表
        result
        # checkメソッド実行時の返り値がfalseとなる
        should_continue = false
        # 最初に当てはまったプレーヤーがいた時点でeach文を抜ける
        break
      # 手札のみ、0の場合
      elsif player.hand.empty?
        # 場札を手札に加える
        data = player.charge
        @game_master.announce_charge(data)
      end
    end
    # 手札と場札を合わせた数が0という条件に当てはまらなければ、checkメソッド実行時の返り値はtrueとなる
    should_continue
  end

  # ゲーム繰り返し部分
  def play
    # checkメソッドの返り値がtrueの間はwhile文の処理を続ける
    while check
      # カードを出す　openメソッドをplayer一人ずつに実行
      @players.each do |player|
        data = player.open
        @game_master.announce_open(data)
      end
      # 勝者の判定
      judge
    end
  end

  # playerインスタンスとのplayerのcardの強さを配列にまとめる
  def collect_card_strong
    @players.each do |player|
      # 出したカードの強さ(値)、playerインスタンスを一つの配列に[[出したカードの強さ,プレーヤー],[出したカードの強さ,プレーヤー]]
      @card_judge << [player.open_card.strong, player]
    end
    @card_judge
  end

  # 勝者の判定
  def judge
    @card_judge = collect_card_strong
    # 一番大きい強さをもったカードの値を返り値にする
    max_value = @card_judge.map { |card, _name| card }.max

    # [[出したカードの強さ,プレーヤー],[２つ目の配列]...]から[出したカードの強さ,プレーヤー]を順番に取り出し、出したカードの強さが一番大きい値をもった配列を、すべてsame_valueに代入
    same_value = @card_judge.filter { |card, _name| card == max_value }

    # 一番強いカードを出したプレーヤーが複数人いるとき　same_valueに代入された配列が１つ以上ある時　[[],[]]
    if same_value.length > 1
      @game_master.announce_draw
      # 場札を集める
      collect
      @card_judge = []
    # 一番強いカードを出したプレーヤーが１人の場合 [[]]
    else
      # [[]]この形の配列を一つの配列にまとめる[]
      same_value.flatten!
      # 配列の2つ目の要素であるプレーヤーインスタンスを代入
      winner = same_value[1]
      @game_master.announce_winner(winner.name, @card_judge.length)
      # 場札を集める
      collect
      # 勝者が場札を受け取る
      get(winner)
      @card_judge = []
    end
  end

  # だれかの手札が0になったら表示する結果発表
  def result
    # [プレーヤーインスタンス,手札の枚数,手札と場札をあわせた合計枚数]を各々のプレーヤーインスタンス分、配列に格納
    final_data = @players.map do |i|
      [i, i.hand.length, i.total_length]
    end
    # 手札と場札を降順になるように配列を並び替え　[[1つ目の配列],[2つ目の配列]...]
    final_data.sort_by! do |_player, hand, total|
      [-hand, -total]
    end
    # 結果発表
    # [[1つ目の配列],[2つ目の配列]...]から[1つ目の配列]を取り出す
    final_data.each_with_index do |item, index|
      # [1つ目の配列]の１つ目の要素であるplayerインスタンスをplayerに代入
      player = item[0]
      @game_master.announce_result(index, player)
    end
  end

  # 場札を配列に集める　#全員のopen_cardをリセットする
  def collect
    @players.each do |i|
      @opened_card << i.open_card
      i.open_card = nil
    end
  end

  # 勝者が場札を受け取る
  # playerインスタンスを引数に入れる
  def get(winner)
    winner.get_card << @opened_card
    winner.get_card.flatten!
    @opened_card = []
  end

  private

  def decide_number
    num = ask_number
    while num < 2 || num > 5
      puts '人数が範囲外です（2〜5で入力してください）。'
      num = ask_number
    end
    # 戻り値
    num
  end

  def ask_number
    puts 'プレーヤー人数は？'
    gets.to_i
  end

  def ask_name(num)
    player_names = []
    1.upto(num) do |number|
      puts "プレーヤー#{number}の名前は？"
      name = gets.chomp
      player_names << name
    end
    # 戻り値
    player_names
  end
end
