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