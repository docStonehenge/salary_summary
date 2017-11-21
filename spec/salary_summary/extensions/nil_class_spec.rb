require 'spec_helper'

describe 'NilClass extension' do
  describe '#to_mongo_value' do
    it 'returns itself' do
      expect(nil.to_mongo_value).to eql nil
    end
  end
end
