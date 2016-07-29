require 'spec_helper'

module SalarySummary
  module Exporters
    describe SalariesRepository do
      let(:mongodb_client) { double(:client) }
      let(:collection)     { double(:collection) }
      let(:entries)        { double(:entries) }
      let(:salary)         { double(:salary, period: 'January', amount: 150.0) }

      describe '.collection name' do
        it 'creates a collection based on a chosen name' do
          expect(Client).to receive(:instance).and_return mongodb_client
          expect(mongodb_client).to receive(:[]).with(:salaries).and_return collection
          expect(described_class.collection('salaries')).to eql collection
        end
      end

      describe '.save salary, collection_name' do
        it 'saves a salary instance on the correct collection' do
          expect(described_class).to receive(
                                       :collection
                                     ).with('salaries').and_return collection

          expect(collection).to receive(:insert_one).with(
                                  period: 'January', amount: 150.0
                                )

          described_class.save salary, 'salaries'
        end
      end

      describe '.find_on collection_name, option_hash = {}' do
        context 'when provided with a option hash' do
          before do
            expect(described_class).to receive(
                                         :collection
                                       ).with('salaries').and_return collection

            expect(collection).to receive(:find).with(period: 'January').and_return entries
            expect(entries).to receive(:entries).and_return([{ '_id' => 1, 'period' => 'January', 'amount' => 150.0 }])
          end

          it 'returns a set of Salary objects found on database' do
            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 1, period: 'January', amount: 150.0
                                         ).and_return salary

            expect(
              described_class.find_on('salaries', period: 'January')
            ).to eql [salary]
          end
        end

        context 'when not provided with a option hash' do
          before do
            expect(described_class).to receive(
                                         :collection
                                       ).with('salaries').and_return collection

            expect(collection).to receive(:find).with({}).and_return entries

            expect(entries).to receive(:entries).and_return(
                                 [
                                   { '_id' => 1, 'period' => 'January', 'amount' => 150.0 },
                                   { '_id' => 2, 'period' => 'February', 'amount' => 200.0 }
                                 ]
                               )
          end

          it 'returns all documents as Salary objects' do
            january  = double(:salary, id: 1, period: 'January', amount: 150.0)
            february = double(:salary, id: 2, period: 'February', amount: 200.0)

            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 1, period: 'January', amount: 150.0
                                         ).and_return january

            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 2, period: 'February', amount: 200.0
                                         ).and_return february

            expect(
              described_class.find_on('salaries')
            ).to eql [january, february]
          end
        end
      end

      describe '.sum collection_name' do
        it 'returns a document with the sum of all entries on the collection' do
          expect(described_class).to receive(
                                       :collection
                                     ).with('salaries').and_return collection

          expect(collection).to receive(:aggregate).with(
                                  [
                                    { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
                                  ]
                                ).and_return entries

          expect(entries).to receive(:entries).and_return [{ '_id' => 'Sum', 'sum' => 1000.0 }]

          expect(described_class.sum('salaries')).to eql 1000.0
        end
      end
    end
  end
end
