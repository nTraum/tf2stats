require_relative '../lib/tf2stats.rb'

describe Tf2Stats::Parser do
  let(:parser){ Tf2Stats::Parser.new }
  describe '#new' do
    it 'takes zero arguments and returns a Parser object' do
      parser.should be_an_instance_of Tf2Stats::Parser
    end
  end

  describe '#parse_file' do

    it 'doesnt explode on invalid utf-8 characters' do
      special_characters_file = File.expand_path('../files/special_characters.log',  __FILE__)
      expect {
        parser.parse_file(special_characters_file)
      }.to_not raise_error
    end
  end
end
