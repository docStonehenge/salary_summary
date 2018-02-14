require 'spec_helper'

module SalarySummary
  module Repositories
    describe SalariesRepository do
      let(:client) { double(:client) }

      subject { described_class.new(client: client) }

      describe 'attributes' do
        specify do
          expect(subject.instance_variable_get(:@connection)).to eql client
          expect(subject.instance_variable_get(:@entity_klass)).to eql Entities::Salary
          expect(subject.instance_variable_get(:@collection_name)).to eql :salaries
        end
      end

      describe '#sum_by_amount' do
        it 'returns the sum of all amount entries on the collection' do
          expect(subject).to receive(:aggregate).once.and_yield

          expect(subject).to receive(:group).once.with(
                               nil, { sum: { :$sum => '$amount' } }
                             ).and_return [{ '_id' => nil, 'sum' => 1000.0 }]

          expect(subject.sum_by_amount).to eql 1000.0
        end

        it 'returns zero if aggregation returns empty' do
          expect(subject).to receive(:aggregate).once.and_yield

          expect(subject).to receive(:group).once.with(
                               nil, { sum: { :$sum => '$amount' } }
                             ).and_return []

          expect(subject.sum_by_amount).to be_zero
        end
      end
    end
  end
end
