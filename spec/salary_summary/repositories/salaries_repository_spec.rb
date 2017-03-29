require 'spec_helper'

module SalarySummary
  module Repositories
    describe SalariesRepository do
      let(:mongodb_client) { double(:client) }
      let(:collection)     { double(:collection) }
      let(:entries)        { double(:entries) }
      let(:salary)         { double(:salary, period: Date.parse('01/2016'), amount: 150.0) }
      let(:january)        { double(:salary, id: 1, period: Date.parse('January, 2016'), amount: 150.0) }
      let(:february)       { double(:salary, id: 2, period: Date.parse('February, 2016'), amount: 200.0) }

      describe '.collection' do
        it 'creates a collection named salaries' do
          expect(Client).to receive(:instance).and_return mongodb_client
          expect(mongodb_client).to receive(:[]).with(:salaries).and_return collection
          expect(described_class.collection).to eql collection
        end
      end

      describe '.save salary' do
        it 'saves a salary instance on salaries collection' do
          expect(described_class).to receive(:collection).and_return collection

          expect(collection).to receive(:insert_one).with(
                                  period: Date.parse('01/2016'), amount: 150.0
                                )

          described_class.save salary
        end
      end

      describe '.find_all option_hash = {}' do
        context 'when provided with a query modifier' do
          before do
            expect(described_class).to receive(:collection).and_return collection
            expect(collection).to receive(:find).with(period: Date.parse('January/2016')).and_return entries

            expect(entries).to receive(:entries).and_return(
                                 [{ '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]
                               )
          end

          it 'returns a set of Salary objects found on database' do
            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 1, period: Date.parse('January, 2016'), amount: 150.0
                                         ).and_return salary

            expect(
              described_class.find_all(modifier: { period: Date.parse('January/2016') })
            ).to eql [salary]
          end
        end

        context 'when not provided with a query modifier' do
          before do
            expect(described_class).to receive(:collection).and_return collection
            expect(collection).to receive(:find).with({}).and_return entries

            expect(entries).to receive(:entries).and_return(
                                 [
                                   { '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                   { '_id' => 2, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                 ]
                               )
          end

          it 'returns all documents as Salary objects' do
            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 1, period: Date.parse('January, 2016'), amount: 150.0
                                         ).and_return january

            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 2, period: Date.parse('February, 2016'), amount: 200.0
                                         ).and_return february

            expect(described_class.find_all).to eql [january, february]
          end
        end

        context 'when provided with a sorted_by option' do
          before do
            expect(described_class).to receive(:collection).and_return collection
            expect(collection).to receive(:find).with({}).and_return entries
            expect(entries).to receive(:sort).with(period: 1).and_return entries

            expect(entries).to receive(:entries).and_return(
                                 [
                                   { '_id' => 2, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                   { '_id' => 1, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                 ]
                               )
          end

          it 'returns all documents sorted as salaries' do
            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 2, period: Date.parse('January, 2016'), amount: 150.0
                                         ).and_return january

            expect(Resources::Salary).to receive(:new).once.with(
                                           id: 1, period: Date.parse('February, 2016'), amount: 200.0
                                         ).and_return february

            expect(described_class.find_all(sorted_by: { period: 1 })).to eql [january, february]
          end
        end
      end

      describe '.sum_by_amount' do
        before do
          expect(described_class).to receive(:collection).and_return collection

          expect(collection).to receive(:aggregate).with(
                                  [
                                    { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
                                  ]
                                ).and_return entries
        end

        it 'returns a document with the sum of all entries on the collection' do
          expect(entries).to receive(:entries).and_return [{ '_id' => 'Sum', 'sum' => 1000.0 }]

          expect(described_class.sum_by_amount).to eql 1000.0
        end

        it 'returns zero if aggregation returns empty' do
          expect(entries).to receive(:entries).and_return []
          expect(described_class.sum_by_amount).to be_zero
        end
      end
    end
  end
end
