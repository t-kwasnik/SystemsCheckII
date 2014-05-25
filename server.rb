require 'sinatra'
require 'csv'

def load_csv(csv)
[
  {
    home_team: "Patriots",
    away_team: "Broncos",
    home_score: 7,
    away_score: 3
  },
  {
    home_team: "Broncos",
    away_team: "Colts",
    home_score: 3,
    away_score: 0
  },
  {
    home_team: "Patriots",
    away_team: "Colts",
    home_score: 11,
    away_score: 7
  },
  {
    home_team: "Steelers",
    away_team: "Patriots",
    home_score: 7,
    away_score: 21
  }
]
end

def find_team_games(team)
  all_games = []
  load_csv(nil).each do |game|
    item = {}
    if game[:home_team] == team
      item[:opponent] = game[:away_team]
      item[:location] = "Home"
      item[:score] = "#{game[:home_score]} : #{game[:away_score]}"
      game[:home_score] > game[:away_score] ? item[:outcome] = "win" : item[:outcome] = "loss"
    elsif game[:away_team] == team
      item[:opponent] = game[:home_team]
      item[:location] = "Away"
      item[:score] = "#{game[:away_score]} : #{game[:home_score]}"
      game[:away_score] > game[:home_score] ? item[:outcome] = "win" : item[:outcome] = "loss"
    end
    all_games << item
  end
  all_games
end

def summarize(game_stats)

  all_games = {}

  game_stats.each do |game|
    #be sure each team has a place to write to
    [game[:home_team], game[:away_team]].each do |team|
      all_games[team] = { total_wins: 0, total_losses: 0 } if all_games[team] == nil
    end

    #figure out who won and record result
    if game[:home_score] > game[:away_score]
      all_games[game[:home_team]][:total_wins] += 1
      all_games[game[:away_team]][:total_losses] += 1
    else
      all_games[game[:away_team]][:total_wins] += 1
      all_games[game[:home_team]][:total_losses] += 1
    end
  end
  all_games.sort_by { |team| [-team[1][:total_wins],team[1][:total_losses]] }
end

get "/leaderboard" do
  @leaderboard = summarize(load_csv(nil))
  erb :leaderboard
end

get "/teams/:key" do
  @leaderboard = summarize(load_csv(nil))
  @selected_team = ""
  summarize(load_csv(nil)).each do |stat|
    @selected_team = stat if stat[0]==params[:key]
  end

  @team_games = find_team_games(params[:key])

  erb :team_stat
end

