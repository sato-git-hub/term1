class GameMaster
  def announce_open(data)
    puts "#{data[0].name}は#{data[1].mark}の#{data[1].number}を出しました。"
  end

  def announce_charge(data)
    puts "#{data[0].name}は獲得済みだった場札を手札に加えました。手札は残り#{data[1].length}枚です。"
  end

  def announce_game_end(player_name)
    puts "#{player_name}の手札が0になりました。ゲームを終了します。"
  end

  def announce_draw
    puts '引き分けです'
  end

  def announce_winner(winner_name, collected_cards_count)
    puts "#{winner_name}が勝ちました。#{winner_name}はカードを#{collected_cards_count}枚もらいました。"
  end

  def announce_result(index, player)
    puts "#{index + 1}位は#{player.name}で、手札は#{player.hand.length}枚、獲得済みの場札は#{player.get_card.length}枚です。"
  end
end
