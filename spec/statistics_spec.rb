require_relative '../lib/tf2stats.rb'

describe Tf2Stats::Statistics do
  context 'a new Statistics' do
    let(:stats) { Tf2Stats::Statistics.new }

    describe '#kills' do
      it 'has zero kills for team red' do
        stats.kills[:red].should be_empty
      end

      it 'has zero kills for team blu' do
        stats.kills[:blu].should be_empty
      end
    end

    describe '#assists' do
      it 'has zero assists for team red' do
        stats.assists[:red].should be_empty
      end

      it 'has zero assists for team blu' do
        stats.assists[:blu].should be_empty
      end
    end

    describe '#deaths' do
      it 'has zero deaths for team red' do
        stats.deaths[:red].should be_empty
      end

      it 'has zero deaths for team blu' do
        stats.deaths[:blu].should be_empty
      end
    end

    describe '#heals' do
      it 'has zero heals for team red' do
        stats.heals[:red].should be_empty
      end

      it 'has zero heals for team blu' do
        stats.heals[:blu].should be_empty
      end
    end

    describe '#damage' do
      it 'has zero damage for team red' do
        stats.damage[:red].should be_empty
      end

      it 'has zero damage for team blu' do
        stats.damage[:blu].should be_empty
      end
    end

    describe '#healed' do
      it 'has zero healed for team red' do
        stats.healed[:red].should be_empty
      end

      it 'has zero healed for team blu' do
        stats.healed[:blu].should be_empty
      end
    end
  end
end