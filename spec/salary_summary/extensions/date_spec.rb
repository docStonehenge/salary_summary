require 'spec_helper'

describe 'Date class extension' do
  describe '.try_convert value' do
    context 'when value is a valid date' do
      it 'returns Date object' do
        expect(Date.try_convert("2017/01/01")).to be_an_instance_of Date
      end

      it 'returns DateTime object' do
        expect(DateTime.try_convert("2017/01/01")).to be_an_instance_of DateTime

        expect(
          DateTime.try_convert("2017/01/01 12:00:00")
        ).to be_an_instance_of DateTime
      end
    end

    context 'when value argument is invalid' do
      it 'returns nil' do
        expect(Date.try_convert("2017")).to be_nil
        expect(Date.try_convert("")).to be_nil
        expect(DateTime.try_convert("2017")).to be_nil
        expect(DateTime.try_convert("")).to be_nil
      end
    end

    context 'when argument type is not conversible' do
      it 'returns nil' do
        expect(Date.try_convert(nil)).to be_nil
        expect(Date.try_convert(1)).to be_nil
        expect(DateTime.try_convert({})).to be_nil
        expect(DateTime.try_convert(:datetime)).to be_nil
      end
    end
  end
end
