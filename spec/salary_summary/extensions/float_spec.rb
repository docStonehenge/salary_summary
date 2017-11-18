require 'spec_helper'

describe 'Float class extension' do
  describe '#try_convert value' do
    context 'when value is parseable' do
      it 'returns float point value' do
        expect(Float.try_convert("100")).to eql 100.0
        expect(Float.try_convert(1)).to eql 1.0
        expect(Float.try_convert(159.00)).to eql 159.0
      end
    end

    context "when value isn't convertable" do
      it 'returns nil' do
        expect(Float.try_convert(nil)).to be_nil
      end
    end

    context 'when value argument is an invalid float point' do
      it 'returns nil' do
        expect(Float.try_convert('')).to be_nil
      end
    end
  end
end
