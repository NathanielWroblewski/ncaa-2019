require 'mechanize'
require 'csv'

URL = 'http://www.covers.com/pageLoader/pageLoader.aspx?page='
TEAMS_URL = "#{URL}/data/ncb/teams/teams.html"
RESULTS_URL = "#{URL}/data/ncb/teams/pastresults" # /2014-2015/team2518.html"
SEASONS = 1997.upto(2018).map { |year| "#{year}-#{year + 1}" }

agent = Mechanize.new

team_page = agent.get(TEAMS_URL)
teams = team_page.search('.datacell a').map do |link|
  link.attributes['href'].value.split('/').last.split('.').first
end

CSV.open('./data/spreads.csv', 'w') do |csv|
  csv << %w(moneyline winloss home away season)

  teams.each do |team|
    SEASONS.each do |season|
      begin
        results_page = agent.get("#{RESULTS_URL}/#{season}/#{team}.html")
        away_teams = results_page.search('.datarow td:nth-child(2)')
        winlosses = results_page.search('.datarow td:nth-child(3)')
        moneylines = results_page.search('.datarow td:nth-child(5)')
        home = results_page.search('.teamname h1')
          .first&.children&.first&.text&.strip.to_s
          .sub(/\s+\(N\)/, '')
          .sub('St.', 'St')
          .sub('Mt.', 'Mt')
          .sub('State', 'St')
          .sub('Northern ', 'N ')
          .sub('North ', 'N ')
          .sub('South ', 'S ')
          .sub('West ', 'W')
          .sub('East ', 'E ')
          .sub('Southeast ', 'SE ')

        away = away_teams.map do |away_team|
          away_team.text.strip.sub('@ ', '')
            .sub(/\s+\(N\)/, '')
            .sub('St.', 'St')
            .sub('Mt.', 'Mt')
            .sub('State', 'St')
            .sub('Northern ', 'N ')
            .sub('North ', 'N ')
            .sub('South ', 'S ')
            .sub('West ', 'W')
            .sub('East ', 'E ')
            .sub('Southeast ', 'SE ')
        end

        inputs = moneylines.map do |moneyline|
          moneyline.text.strip.split(' ').last.to_f
        end

        labels = winlosses.map do |winloss|
          winloss.text.strip.split(' ').first === 'W' ? 1 : 0
        end

        inputs.each_with_index do |moneyline, index|
          if !moneyline.zero?
            csv << [moneyline, labels[index], home, away[index], season]
          end
        end
      rescue Exception => e
        puts e.message
      end
    end

    sleep 0.5
  end

  sleep 0.5
end
