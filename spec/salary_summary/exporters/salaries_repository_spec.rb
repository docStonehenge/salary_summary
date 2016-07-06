require 'spec_helper'

module SalarySummary
  module Exporters
    describe SalariesRepository do
      let(:mongodb_client) { double(:client) }
      let(:collection)     { double(:collection) }
      let(:salary)         { double(:salary, period: 'January', amount: 150.0) }

      describe '.collection name' do
        it 'creates a collection based on a chosen name' do
          expect(Client).to receive(:instance).and_return mongodb_client
          expect(mongodb_client).to receive(:[]).with(:salaries).and_return collection
          expect(described_class.collection('salaries')).to eql collection
        end
      end

      describe '.save! salary, collection_name' do
        it 'saves a salary instance on the correct collection' do
          expect(described_class).to receive(
                                       :collection
                                     ).with('salaries').and_return collection

          expect(collection).to receive(:insert_one).with(
                                  period: 'January', amount: 150.0
                                )

          described_class.save! salary, 'salaries'
        end
      end
    end
  end
end
