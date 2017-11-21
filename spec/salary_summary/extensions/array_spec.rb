require 'spec_helper'

describe 'Array class extension' do
  describe '#to_mongo_value' do
    it 'returns itself when empty' do
      expect([].to_mongo_value).to eql []
    end

    it 'returns array with all values mapped to mongo values' do
      expect(
        [BigDecimal.new("100"), Date.parse("2017/11/21"), 123].to_mongo_value
      ).to eql ["0.1E3", Date.parse("2017/11/21"), 123]
    end

    it 'returns value mapped to nil when it cannot be transformed to a mongo value' do
      Foo = Struct.new(:field)

      expect(
        [Foo.new, 123].to_mongo_value
      ).to eql [nil, 123]
    end
  end
end
