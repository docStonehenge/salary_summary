require 'spec_helper'

shared_examples_for 'a Salary entity as a document' do
  it '.repository' do
    expect(
      described_class.repository
    ).to eql SalarySummary::Repositories::SalariesRepository
  end

  describe '.fields_list' do
    it 'returns attributes collection set for accessors' do
      expect(described_class.fields_list).to eql [:id, :amount, :period]
    end
  end

  describe '.fields' do
    it 'returns attributes specifications correctly' do
      expect(described_class.fields).to eql(
                                          id: { type: BSON::ObjectId },
                                          amount: { type: BigDecimal },
                                          period: { type: Date }
                                        )
    end
  end
end
