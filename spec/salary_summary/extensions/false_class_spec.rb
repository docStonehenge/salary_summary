require 'spec_helper'

describe 'FalseClass extension' do
  describe '#to_mongo_value' do
    it 'returns itself' do
      expect(false.to_mongo_value).to eql false
    end
  end
end