require 'spec_helper'

describe 'Hash class extension' do
  describe '#to_mongo_value' do
    it 'returns itself when Hash is empty' do
      expect({}.to_mongo_value).to eql({})
    end

    it 'returns itself with all values being transformed to mongo values' do
      expect(
        {
          foo: "bar", "amount" => BigDecimal.new("459.90"), [1] => Date.parse('2017/01/01')
        }.to_mongo_value
      ).to eql(foo: 'bar', 'amount' => '0.4599E3', [1] => Date.parse('2017/01/01'))
    end

    it 'transforms value to nil if value cannot be transformed to mongo value' do
      Foo = Struct.new(:field)

      expect({foo: Foo.new(field: "hello")}.to_mongo_value).to eql(foo: nil)
    end
  end
end
