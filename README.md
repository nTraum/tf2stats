# Tf2Stats
[![Build Status](https://secure.travis-ci.org/nTraum/tf2stats.png)](http://travis-ci.org/nTraum/tf2stats)

Tf2Stats is a log file parser for Team Fortress 2, very similiar to http://tf2logs.com (checkout the website and https://github.com/barncow/tf2logparser).

It reads log files from competitive matches (`mp_tournament 1`) and extracts it's various information (kills, deaths, caps, heals, damages) in a much more accessible manner. To receive all mentioned stats, you have to install either [tf2log's Supplemental Stats Plugin](http://tf2logs.com/plugins) (SourceMod plugin) or Anakin's [TFTrue](http://tftrue.redline-utilities.net/) (standalone) on your gameserver.

## Installation

Add this line to your application's Gemfile:

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
match = parser.parse_file('mylog.log', 'Epsilon', 'TLR', 'cp_badlands')
# match = parser.parse_file('mylog.log')
```

The parsed information can be found inside the returned `Match` object.

### Winner
```ruby
match.winner #=> :red
match.stalemate? #=> false
match.won_blu? #=> false
match.won_red? #=> true
```

### Score(s)
```ruby
match.scores #=> [{:red=>0, :blu=>0}, {:red=>1, :blu=>0}, {:red=>2, :blu=>0}, {:red=>3, :blu=>0}, {:red=>4, :blu=>0}, {:red=>5, :blu=>0}]
match.final_score #=> {:red=>5, :blu=>0}
```
### General Information
```ruby
match.blu #=> 'TLR'
match.red #=> 'Epsilon'
match.duration #=> 1265.0 (in seconds)
match.date #=> 2012-10-31 22:31:18 +0100
match.map #=> 'cp_badlands'
```

### Player statistics
Kills, deaths, damage, heals and healings statistics are collected for both teams and all their players. They're stored in corresponding instance variables as hashes:
* `kills`
* `deaths`
* `damage`
* `healed` (heals *received*)
* `heals` (heals *given*)

```ruby
match.kills[:blu] #=> {"TLR Traxantic"=>13, "TLR dONut"=>15, "TLR droso"=>16, "TLR Cyber"=>7, "TLR HYS"=>10}
#match.kills
match.heals[:red]['Epsilon KnOxXx'] #=> 7521
```

### Break down
The `Match` object also holds an array of all rounds that has been played:

```ruby
match.rounds[3].start_time #=> 1034.0 (relative to match begin)
match.rounds[3].end_time #=> 1110.0 (relative to match begin)
match.rounds[3].duration #=> 76.0
match.rounds[3].winner #=> :red
```

including all the player statistics as well:
```ruby
match.rounds[3].deaths
#=> {:red=>{"Epsilon wltrs"=>1, "Epsilon KnOxXx"=>1, "Epsilon GeaR"=>1, "Epsilon Mike"=>1}, :blu=>{"TLR droso"=>1, "TLR HYS"=>2, "TLR Traxantic"=>1, "TLR Cyber"=>1, "TLR dONut"=>1, "TLR Evilmoon"=>1}}
```

and a list of captures:
```ruby
match.rounds[0].captures[0].name #=> "#Badlands_cap_cp3"
match.rounds[0].captures[0].number #=> "2"
match.rounds[0].captures[0].winner #=> :red
```

...that yet again holds the various players' information:
```ruby
match.rounds[0].captures[0].healed[:blu] #=> {"TLR Cyber"=>203, "TLR droso"=>2, "TLR HYS"=>51}
```

Long story short, you can access all the gathered statistics on any level (whole match, one round, one capture).