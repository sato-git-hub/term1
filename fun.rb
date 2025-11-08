#実行ファイル
require_relative 'game'
game = Game.new
game.decide_about_player
# playerのインスタンス変数hand（配列）にデッキをふりわけ
game.slice
game.play
