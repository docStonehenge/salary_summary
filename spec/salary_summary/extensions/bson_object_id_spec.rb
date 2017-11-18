require 'spec_helper'

describe 'BSON::ObjectId extension' do
  describe '#try_convert value' do
    context 'when value is a valid ObjectId' do
      it 'returns an BSON::ObjectId instance' do
        expect(
          BSON::ObjectId.try_convert(BSON::ObjectId.new)
        ).to be_an_instance_of BSON::ObjectId

        expect(
          BSON::ObjectId.try_convert(BSON::ObjectId.new.to_s)
        ).to be_an_instance_of BSON::ObjectId
      end
    end

    context "when value isn't conversible to an ObjectId" do
      it 'returns nil' do
        expect(BSON::ObjectId.try_convert(nil)).to be_nil
        expect(BSON::ObjectId.try_convert("")).to be_nil
        expect(BSON::ObjectId.try_convert("123")).to be_nil
        expect(BSON::ObjectId.try_convert(123)).to be_nil
      end
    end
  end
end
