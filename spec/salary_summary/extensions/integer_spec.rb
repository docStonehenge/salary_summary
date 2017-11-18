require 'spec_helper'

describe 'Integer class extension' do
  describe '#try_convert value' do
    context 'when value is parseable' do
      it 'returns integer value' do
        expect(Integer.try_convert("100")).to eql 100
        expect(Integer.try_convert(1)).to eql 1
        expect(Integer.try_convert(159.99)).to eql 159
      end
    end

    context "when value isn't convertable" do
      it 'returns nil' do
        expect(Integer.try_convert(nil)).to be_nil
      end
    end

    context 'when value argument is an invalid float point' do
      it 'returns nil' do
        expect(Integer.try_convert('')).to be_nil
      end
    end
  end
end
