require_relative '../lib/tf2stats.rb'

describe Tf2Stats::Parser do
  let(:parser){ Tf2Stats::Parser.new }
  describe '#new' do
    it 'takes zero arguments and returns a Parser object' do
      parser.should be_an_instance_of Tf2Stats::Parser
    end
  end
end
