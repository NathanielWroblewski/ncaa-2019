require 'mechanize'
require 'csv'

URL = 'http://kenpom.com/index.php?y='
YEARS = 2002.upto(2019).to_a

MASSEY_IDS = {
  'Kent St' => 'Kent',
  'North Carolina St' => 'NC State',
  'Western Kentucky' => 'WKU',
  'Southern Illinois' => 'S Illinois',
  "Saint Joseph's" => "St Joseph's PA",
  'UC Santa Barbara' => 'Santa Barbara',
  'College of Charleston' => 'Col Charleston',
  'Saint Louis' => 'St Louis',
  'East Tennessee St' => 'ETSU',
  'Milwaukee' => 'WI Milwaukee',
  'Arkansas Little Rock' => 'Ark Little Rock',
  'Louisiana Lafayette' => 'ULL',
  'Southwest Missouri St' => 'Missouri St',
  'Illinois Chicago' => 'IL Chicago',
  'VCU' => 'VA Commonwealth',
  'Loyola Chicago' => 'Loyola-Chicago',
  'Western Michigan' => 'W Michigan',
  'Georgia Southern' => 'Ga Southern',
  'Central Connecticut' => 'Central Conn',
  'The Citadel' => 'Citadel',
  'Troy St' => 'Troy',
  'Cal Poly' => 'Cal Poly SLO',
  'Eastern Washington' => 'E Washington',
  'UTSA' => 'UT San Antonio',
  'UMKC' => 'Missouri KC',
  'Cal St Northridge' => 'CS Northridge',
  'Northern Illinois' => 'N Illinois',
  'Louisiana Monroe' => 'ULM',
  'Florida Atlantic' => 'FL Atlantic',
  'Boston University' => 'Boston Univ',
  'George Washington' => 'G Washington',
  'Middle Tennessee' => 'MTSU',
  'Central Michigan' => 'C Michigan',
  'Texas Pan American' => 'UTRGV',
  'American' => 'American Univ',
  'Green Bay' => 'WI Green Bay',
  "Saint Mary's" => "St Mary's CA",
  'Southwest Texas St' => 'Texas St',
  'Western Carolina' => 'W Carolina',
  'Eastern Illinois' => 'E Illinois',
  'Monmouth' => 'Monmouth NJ',
  'FIU' => 'Florida Intl',
  'Northwestern St' => 'Northwestern LA',
  'Tennessee Martin' => 'TN Martin',
  'Texas A&M Corpus Chris' => 'TAM C. Christi',
  'Western Illinois' => 'W Illinois',
  'Stephen F. Austin' => 'SF Austin',
  'Loyola Marymount' => 'Loy Marymount',
  'South Carolina St' => 'S Carolina St',
  'North Carolina A&T' => 'NC A&T',
  'Southeast Missouri St' => 'SE Missouri St',
  'Sacramento St' => 'CS Sacramento',
  'Charleston Southern' => 'Charleston So',
  'Mississippi Valley St' => 'MS Valley St',
  'Cal St Fullerton' => 'CS Fullerton',
  'Bethune Cookman' => 'Bethune-Cookman',
  'Eastern Kentucky' => 'E Kentucky',
  'Maryland Eastern Shore' => 'MD E Shore',
  'Birmingham Southern' => 'Birmingham So',
  'Southeastern Louisiana' => 'SE Louisiana',
  'Coastal Carolina' => 'Coastal Car',
  'Eastern Michigan' => 'E Michigan',
  "Saint Peter's" => "St Peter's",
  'Grambling St' => 'Grambling',
  'Texas Southern' => 'TX Southern',
  'Albany' => 'Albany NY',
  'Southern' => 'Southern Univ',
  'Fairleigh Dickinson' => 'F Dickinson',
  'Prairie View A&M' => 'Prairie View',
  'LIU Brooklyn' => 'Long Island',
  'Arkansas Pine Bluff' => 'Ark Pine Bluff',
  "Mount St Mary's" => "Mt St Mary's",
  'Middle Tennessee St' => 'MTSU',
  'Utah Valley St' => 'Utah Valley',
  'Northern Colorado' => 'N Colorado',
  'North Dakota St' => 'N Dakota St',
  'South Dakota St' => 'S Dakota St',
  'Kennesaw St' => 'Kennesaw',
  'Central Arkansas' => 'Cent Arkansas',
  'Winston Salem St' => 'W Salem St',
  'USC Upstate' => 'SC Upstate',
  'Florida Gulf Coast' => 'FL Gulf Coast',
  'Cal St Bakersfield' => 'CS Bakersfield',
  'North Carolina Central' => 'NC Central',
  'SIU Edwardsville' => 'Edwardsville',
  'Houston Baptist' => 'Houston Bap',
  'Nebraska Omaha' => 'NE Omaha',
  'Northern Kentucky' => 'N Kentucky',
  'UMass Lowell' => 'MA Lowell',
  'Abilene Christian' => 'Abilene Chr',
  'UT Rio Grande Valley' => 'UTRGV',
  'Fort Wayne' => 'IPFW',
  'Little Rock' => 'Ark Little Rock'
}

agent = Mechanize.new

CSV.open('./data/kenpom.csv', 'w') do |csv|
  csv << %w(team offense defense tempo luck margin schedule_margin opponent_offense opponent_defense non_conference conf year)

  YEARS.each do |year|
    page = agent.get("#{URL}#{year}")

    teams = page.search('tr td:nth-of-type(2) a').map(&:text)
    conf = page.search('tr td:nth-of-type(3) a').map(&:text)
    adjusted_efficiency_margin = page.search('tr td:nth-of-type(5)').map(&:text)
    adjusted_offense = page.search('tr td:nth-of-type(6)').map(&:text)
    adjusted_defense = page.search('tr td:nth-of-type(8)').map(&:text)
    adjusted_tempo = page.search('tr td:nth-of-type(10)').map(&:text)
    luck = page.search('tr td:nth-of-type(12)').map(&:text)
    schedule_margin = page.search('tr td:nth-of-type(14)').map(&:text)
    opponent_off = page.search('tr td:nth-of-type(16)').map(&:text)
    opponent_def = page.search('tr td:nth-of-type(18)').map(&:text)
    non_conf = page.search('tr td:nth-of-type(20)').map(&:text)

    rows = teams.zip(
      adjusted_offense,
      adjusted_defense,
      adjusted_tempo,
      luck,
      adjusted_efficiency_margin,
      schedule_margin,
      opponent_off,
      opponent_def,
      non_conf,
      conf
    )

    rows.each do |row|
      name = row[0].sub('St.', 'St').sub('Mt.', 'Mt')
      team_name = MASSEY_IDS[name] || name
      offense = row[1]
      defense = row[2]
      tempo = row[3]
      luck = row[4]
      margin = row[5]
      schedule_margin = row[6]
      opponent_off = row[7]
      opponent_def = row[8]
      non_conf = row[9]
      conf = row[10]

      csv << [
        team_name,
        offense,
        defense,
        tempo,
        luck.sub('+', ''),
        margin.sub('+', ''),
        schedule_margin.sub('+', ''),
        opponent_off,
        opponent_def,
        non_conf.sub('+', ''),
        conf,
        year.to_i
      ]
    end

    sleep 1
  end
end
