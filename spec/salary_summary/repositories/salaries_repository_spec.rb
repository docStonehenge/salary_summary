require 'spec_helper'

module SalarySummary
  module Repositories
    describe SalariesRepository do
      let(:client)         { double(:client) }
      let(:registry)       { double(:registry) }
      let(:collection)     { double(:collection) }
      let(:entries)        { double(:entries) }
      let(:salary)         { double(:salary, period: Date.parse('01/2016'), amount: 150.0) }
      let(:january)        { double(:salary, id: 1, period: Date.parse('January, 2016'), amount: 150.0) }
      let(:february)       { double(:salary, id: 2, period: Date.parse('February, 2016'), amount: 200.0) }

      subject { described_class.new(client: client) }

      before do
        expect(client).to receive(
                            :database_collection
                          ).with(:salaries).and_return collection
      end

      describe 'attributes' do
        specify do
          expect(subject.instance_variable_get(:@collection)).to eql collection
          expect(subject.instance_variable_get(:@object_klass)).to eql Entities::Salary
        end
      end

      describe '#save salary' do
        it 'saves a salary instance on salaries collection' do
          expect(collection).to receive(:insert_one).with(
                                  period: Date.parse('01/2016'), amount: 150.0
                                )

          subject.save salary
        end
      end

      describe '#find id' do
        context 'when salary is not yet loaded on registry' do
          before do
            allow(Registry).to receive(:get).once.with('123').and_return nil
          end

          it 'queries for salary with id, sets into registry and returns salary object' do
            expect(collection).to receive(:find).once.with(
                                    _id: '123'
                                  ).and_return entries

            expect(entries).to receive(:entries).and_return(
                                 [{ '_id' => '123', 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]
                               )

            expect(Entities::Salary).to receive(:new).once.with(
                                           id: '123', period: Date.parse('January, 2016'), amount: 150.0
                                         ).and_return salary

            expect(Registry).to receive(:set).once.with(salary).and_return salary

            expect(subject.find('123')).to eql salary
          end
        end

        context 'when salary is already loaded on registry' do
          before do
            allow(Registry).to receive(:get).once.with('123').and_return salary
          end

          it 'returns salary got from registry map' do
            expect(collection).not_to receive(:find).with(any_args)
            expect(Entities::Salary).not_to receive(:new).with(any_args)
            expect(subject.find('123')).to eql salary
          end
        end

        context 'when salary ID is not found' do
          it 'raises EntityNotFoundError' do
            allow(Registry).to receive(:get).once.with('123').and_return nil

            expect(collection).to receive(:find).once.with(
                                    _id: '123'
                                  ).and_return entries

            expect(entries).to receive(:entries).and_return([])

            expect { subject.find('123') }.to raise_error(
                                                Queries::EntityNotFoundError,
                                                'Unable to find SalarySummary::Entities::Salary with ID #123'
                                              )
          end
        end
      end

      describe '#find_all modifier: {}, sorted_by: {}' do
        context 'when registry has no objects loaded' do
          context 'when provided with a query modifier' do
            before do
              expect(collection).to receive(:find).with(period: Date.parse('January/2016')).and_return entries

              expect(entries).to receive(:entries).and_return(
                                   [{ '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]
                                 )

              expect(Registry).to receive(:get).once.with(1).and_return nil
            end

            it 'returns a set of Salary objects found on database' do
              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 1, period: Date.parse('January, 2016'), amount: 150.0
                                           ).and_return salary

              expect(Registry).to receive(:set).once.with(salary).and_return salary

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [salary]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(collection).to receive(:find).with({}).and_return entries

              expect(entries).to receive(:entries).and_return(
                                   [
                                     { '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                     { '_id' => 2, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                   ]
                                 )

              expect(Registry).to receive(:get).once.with(1).and_return nil
              expect(Registry).to receive(:get).once.with(2).and_return nil
            end

            it 'returns all documents as Salary objects' do
              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 1, period: Date.parse('January, 2016'), amount: 150.0
                                           ).and_return january

              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 2, period: Date.parse('February, 2016'), amount: 200.0
                                           ).and_return february

              expect(Registry).to receive(:set).once.with(january).and_return january
              expect(Registry).to receive(:set).once.with(february).and_return february

              expect(subject.find_all).to eql [january, february]
            end
          end

          context 'when provided with a sorted_by option' do
            before do
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
              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 2, period: Date.parse('January, 2016'), amount: 150.0
                                           ).and_return january

              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 1, period: Date.parse('February, 2016'), amount: 200.0
                                           ).and_return february

              expect(Registry).to receive(:set).once.with(january).and_return january
              expect(Registry).to receive(:set).once.with(february).and_return february

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [january, february]
            end
          end
        end

        context 'when registry contains salaries instances loaded' do
          before do
            @loaded_salary = Entities::Salary.new(
              id: 124, amount: 4000.0, period: Date.parse('07/01/2016')
            )

            expect(Registry).to receive(
                                  :get
                                ).once.with(124).and_return @loaded_salary

            expect(Registry).to receive(
                                  :get
                                ).once.with(125).and_return nil
          end

          context 'when provided with a query modifier' do
            before do
              expect(collection).to receive(:find).with(period: Date.parse('January/2016')).and_return entries

              expect(entries).to receive(:entries).and_return(
                                   [
                                     { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                     { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 150.0 }
                                   ]
                                 )
            end

            it 'returns a set of Salary objects already loaded' do
              expect(Entities::Salary).not_to receive(:new).with(
                                             id: 124, period: Date.parse('January, 2016'), amount: 150.0
                                           )

              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 125, period: Date.parse('February, 2016'), amount: 150.0
                                           ).and_return salary

              expect(Registry).to receive(:set).once.with(salary).and_return salary

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [@loaded_salary, salary]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(collection).to receive(:find).with({}).and_return entries

              expect(entries).to receive(:entries).and_return(
                                   [
                                     { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                     { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                   ]
                                 )
            end

            it 'returns all documents as Salary objects' do
              expect(Entities::Salary).not_to receive(:new).with(
                                             id: 124, period: Date.parse('January, 2016'), amount: 150.0
                                           )

              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 125, period: Date.parse('February, 2016'), amount: 200.0
                                           ).and_return february

              expect(Registry).to receive(:set).once.with(february).and_return february

              expect(subject.find_all).to eql [@loaded_salary, february]
            end
          end

          context 'when provided with a sorted_by option' do
            before do
              expect(collection).to receive(:find).with({}).and_return entries
              expect(entries).to receive(:sort).with(period: 1).and_return entries

              expect(entries).to receive(:entries).and_return(
                                   [
                                     { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                     { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                   ]
                                 )
            end

            it 'returns all documents sorted as salaries' do
              expect(Entities::Salary).not_to receive(:new).with(
                                             id: 124, period: Date.parse('January, 2016'), amount: 150.0
                                           )

              expect(Entities::Salary).to receive(:new).once.with(
                                             id: 125, period: Date.parse('February, 2016'), amount: 200.0
                                           ).and_return february

              expect(Registry).to receive(:set).once.with(february).and_return february

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [@loaded_salary, february]
            end
          end
        end
      end

      describe '#sum_by_amount' do
        before do
          expect(collection).to receive(:aggregate).with(
                                  [
                                    { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
                                  ]
                                ).and_return entries
        end

        it 'returns a document with the sum of all entries on the collection' do
          expect(entries).to receive(:entries).and_return [{ '_id' => 'Sum', 'sum' => 1000.0 }]

          expect(subject.sum_by_amount).to eql 1000.0
        end

        it 'returns zero if aggregation returns empty' do
          expect(entries).to receive(:entries).and_return []
          expect(subject.sum_by_amount).to be_zero
        end
      end
    end
  end
end
