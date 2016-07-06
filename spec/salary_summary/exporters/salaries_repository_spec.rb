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
    end
  end
end
