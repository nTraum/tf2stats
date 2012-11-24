require_relative '../lib/tf2stats.rb'

describe Tf2Stats::Match do
  context 'a new Match' do
    let(:match) { Tf2Stats::Match.new }

    describe '#rounds' do
      it 'has zero rounds' do
        match.rounds.should be_empty
      end
    end

    describe '#winner' do
      it 'has no winner' do
        match.winner.should be_nil
      end
    end

    describe '#start_time' do
      it 'starts at relative time 0' do
        match.start_time.should eql 0
      end
    end

    describe '#duration' do
      it 'has no duration' do
        match.duration.should be_nil
      end
    end

    describe '#end_time' do
      it 'has no endtime' do
        match.end_time.should be_nil
      end
    end

    describe '#won_blu?' do
      it 'is not won by blu' do
        match.won_blu?.should be_false
      end
    end

    describe '#won_red?' do
      it 'is not won by red' do
        match.won_red?.should be_false
      end
    end

    describe '#score' do
      it 'has zero points for team red' do
        match.score[:red].should eql 0
      end
      it 'has zero points for team blu' do
        match.score[:blu].should eql 0
      end
    end

    describe '#stalemate?' do
      it 'starts with a tie' do
        match.stalemate?.should be_true
      end
    end
  end
end