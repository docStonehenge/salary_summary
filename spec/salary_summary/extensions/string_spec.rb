require 'spec_helper'

describe 'String class extension' do
  describe '#to_mongo_value' do
    it 'returns itself' do
      expect("foo".to_mongo_value).to eql "foo"
      expect("".to_mongo_value).to eql ""
    end
  end
end
