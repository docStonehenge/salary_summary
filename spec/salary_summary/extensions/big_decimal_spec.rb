require 'spec_helper'

describe 'BigDecimal extension' do
  describe '.try_convert value' do
    context 'when value is parseable' do
      it 'returns a BigDecimal object' do
        expect(BigDecimal.try_convert("100.0")).to be_an_instance_of BigDecimal
        expect(BigDecimal.try_convert(100.0)).to be_an_instance_of BigDecimal
        expect(BigDecimal.try_convert(1000)).to be_an_instance_of BigDecimal
        expect(BigDecimal.try_convert("")).to be_an_instance_of BigDecimal
        expect(BigDecimal.try_convert("foo")).to be_an_instance_of BigDecimal
      end
    end

    context 'when value is of a not parseable type' do
      it 'returns nil' do
        expect(BigDecimal.try_convert(nil)).to be_nil
        expect(BigDecimal.try_convert(false)).to be_nil
        expect(BigDecimal.try_convert({})).to be_nil
      end
    end
  end
end
