# Tf2Stats
[![Build Status](https://secure.travis-ci.org/nTraum/tf2stats.png)](http://travis-ci.org/nTraum/tf2stats)

Tf2Stats is a log file parser for Team Fortress 2, very similiar to http://tf2logs.com (checkout the website and [barncow/tf2logparser](https://github.com/barncow/tf2logparser).

It reads log files from competitive matches (`mp_tournament 1`) and extracts it's various information (kills, deaths, caps, heals, damages) in a much more accessible manner. To receive all mentioned stats, you have to install either [tf2log's Supplemental Stats Plugin](http://tf2logs.com/plugins) (SourceMod plugin) or Anakin's [TFTrue](http://tftrue.redline-utilities.net/) (standalone) on your gameserver.

## Installation

Add this line to your application's `Gemfile`:

    gem 'tf2stats'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tf2stats

## Usage

Feed the Parser with a log file:

```ruby
require 'tf2stats'
parser = Tf2Stats::Parser.new
match = match = parser.parse_file('example.log', :red => 'TLR', :blu => 'CC', :map => 'cp_granary')
# match = parser.parse_file('example.log')
```

The parsed information can be found inside the returned `Match` object.

### Winner
```ruby
match.winner #=> :blu
match.stalemate? #=> false
match.won_blu? #=> true
match.won_red? #=> false
```

### Score(s)
```ruby
match.scores
#=> [{:red=>0, :blu=>0}, {:red=>1, :blu=>0}, {:red=>1, :blu=>1}, {:red=>1, :blu=>2}, {:red=>1, :blu=>3}, {:red=>2, :blu=>3}, {:red=>3, :blu=>3}, {:red=>3, :blu=>4}, {:red=>3, :blu=>5}]
match.final_score #=> {:red=>3, :blu=>5}
```
### General Information
```ruby
match.blu #=> 'CC'
match.red #=> 'TLR'
match.duration #=> 1805.0 (in seconds)
match.date #=> 2012-10-04 23:27:42 +0200
match.map #=> "cp_granary"
```

### Player statistics
Statistics are collected for both teams and all their players. They're stored in corresponding hashes:
* `kills`
* `deaths`
* `damage`
* `healed` (heals *received*)
* `heals` (heals *given*)

```ruby
match.stats.kills[:blu] #=> {"cc//ipz-"=>19, "cc//TviQ"=>29, "cc//Retsh0ck"=>25, "cc//smZI"=>22, "cc//minimoose"=>21}
# match.kills
match.stats.heals[:red]['TLR Evilmoon'] #=> 10044
```

### Break down
The `Match` object also holds an array of all rounds that has been played:

```ruby
match.rounds[3].start_time #=> 543.0 (relative to match begin)
match.rounds[3].end_time #=> 1031.0 (relative to match begin)
match.rounds[3].duration #=> 488.0
match.rounds[3].winner #=> :blu
```

including all the player statistics as well:
```ruby
match.rounds[3].stats.deaths
# => {:red=>{"TLR Cyber"=>5, "TLR dONut"=>7, "TLR Evilmoon"=>3, "TLR droso"=>6, "TLR HYS"=>7, "TLR Traxantic"=>6}, :blu=>{"cc//Retsh0ck"=>5, "cc//minimoose"=>6, "cc//smZI"=>5, "cc//TviQ"=>8, "cc//ipz-"=>2, "cc//Admirable"=>1}}
```

and a list of captures:
```ruby
match.rounds[3].captures[0].name #=> "Granary_cap_cp3"
match.rounds[0].captures[0].number #=> "2"
match.rounds[0].captures[0].winner #=> :blu
```

...that yet again holds the various players' information:
```ruby
match.rounds[0].captures[0].stats.healed[:blu] #=> {"cc//ipz-"=>80, "cc//minimoose"=>43, "cc//Retsh0ck"=>49}
```

Long story short, you can access all the gathered statistics on any level (whole match, one round, one capture).