require 'spec_helper'

module SalarySummary
  module Repositories
    describe SalariesRepository do
      let(:client) { double(:client) }
      let(:uow) { double(:uow) }
      let(:collection) { double(:collection) }
      let(:entries) { double(:entries) }
      let(:salary) { double(:salary, period: Date.parse('01/2016'), amount: 150.0) }
      let(:january) { double(:salary, id: 1, period: Date.parse('January, 2016'), amount: 150.0) }
      let(:february) { double(:salary, id: 2, period: Date.parse('February, 2016'), amount: 200.0) }

      subject { described_class.new(client: client) }

      describe 'attributes' do
        specify do
          expect(subject.instance_variable_get(:@connection)).to eql client
          expect(subject.instance_variable_get(:@object_klass)).to eql Entities::Salary
        end
      end

      describe '#save salary' do
        it 'saves a salary instance on salaries collection' do
          expect(client).to receive(:insert_on).once.with(
                              :salaries,
                              period: Date.parse('01/2016'), amount: 150.0
                            )

          subject.save salary
        end
      end

      describe '#find id' do
        context 'when no UnitOfWork is set on current Thread' do
          it 'raises error on call to get loaded entities' do
            expect(
              Persistence::UnitOfWork
            ).to receive(:current).and_raise Persistence::UnitOfWorkNotStartedError

            expect {
              subject.find('123')
            }.to raise_error(Persistence::UnitOfWorkNotStartedError)
          end
        end

        context 'when salary is not yet loaded on registry' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
            allow(uow).to receive(:get).once.with(Entities::Salary, '123').and_return nil
          end

          it 'queries for salary with id, sets into current uow and returns salary object' do
            expect(client).to receive(:find_on).once.with(
                                :salaries, filter: { _id: '123' }, sort: {}
                              ).and_return [{ '_id' => '123', 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]

            expect(Entities::Salary).to receive(:new).once.with(
                                          '_id' => '123', 'period' => Time.parse('2016-01-01'), 'amount' => 150.0
                                        ).and_return salary

            expect(uow).to receive(:register_clean).once.with(salary).and_return salary

            expect(subject.find('123')).to eql salary
          end
        end

        context 'when salary is already loaded on registry' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
            allow(uow).to receive(:get).once.with(Entities::Salary, '123').and_return salary
          end

          it 'returns salary got from uow clean entities list' do
            expect(client).not_to receive(:find_on).with(any_args)
            expect(Entities::Salary).not_to receive(:new).with(any_args)
            expect(subject.find('123')).to eql salary
          end
        end

        context 'when salary ID is not found' do
          it 'raises EntityNotFoundError' do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
            allow(uow).to receive(:get).once.with(Entities::Salary, '123').and_return nil

            expect(client).to receive(:find_on).once.with(
                                :salaries, filter: { _id: '123' }, sort: {}
                              ).and_return []

            expect { subject.find('123') }.to raise_error(
                                                Queries::EntityNotFoundError,
                                                'Unable to find SalarySummary::Entities::Salary with ID #123'
                                              )
          end
        end
      end

      describe '#find_all modifier: {}, sorted_by: {}' do
        it 'raises error when call to current UnitOfWork raises error' do
          expect(client).to receive(:find_on).with(
                              :salaries, filter: {}, sort: {}
                            ).and_return(
                              [{ '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]
                            )

          expect(
            Persistence::UnitOfWork
          ).to receive(:current).and_raise Persistence::UnitOfWorkNotStartedError

          expect {
            subject.find_all
          }.to raise_error(Persistence::UnitOfWorkNotStartedError)
        end

        context 'when UnitOfWork has no clean objects loaded' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
          end

          context 'when provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).once.with(
                                  :salaries, filter: { period: Date.parse('January/2016') }, sort: {}
                                ).and_return [{ '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 }]

              expect(uow).to receive(:get).once.with(Entities::Salary, 1).and_return nil
            end

            it 'returns a set of Salary objects found on database' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0
                                          ).and_return salary

              expect(uow).to receive(:register_clean).once.with(salary).and_return salary

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [salary]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).with(
                                  :salaries, filter: {}, sort: {}
                                ).and_return(
                                  [
                                    { '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                    { '_id' => 2, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                  ]
                                )

              expect(uow).to receive(:get).once.with(Entities::Salary, 1).and_return nil
              expect(uow).to receive(:get).once.with(Entities::Salary, 2).and_return nil
            end

            it 'returns all documents as Salary objects' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 1, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                          ).and_return january

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 2, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                          ).and_return february

              expect(uow).to receive(:register_clean).once.with(january).and_return january
              expect(uow).to receive(:register_clean).once.with(february).and_return february

              expect(subject.find_all).to eql [january, february]
            end
          end

          context 'when provided with a sorted_by option' do
            before do
              expect(uow).to receive(:get).once.with(Entities::Salary, 1).and_return nil
              expect(uow).to receive(:get).once.with(Entities::Salary, 2).and_return nil

              expect(client).to receive(:find_on).with(
                                  :salaries, filter: {}, sort: { period: 1 }
                                ).and_return(
                                  [
                                    { '_id' => 2, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                    { '_id' => 1, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                  ]
                                )
            end

            it 'returns all documents sorted as salaries' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 2, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                          ).and_return january

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 1, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                          ).and_return february

              expect(uow).to receive(:register_clean).once.with(january).and_return january
              expect(uow).to receive(:register_clean).once.with(february).and_return february

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [january, february]
            end
          end
        end

        context 'when UnitOfWork contains clean salaries instances loaded' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow

            @loaded_salary = Entities::Salary.new(
              id: 124, amount: 4000.0, period: Date.parse('07/01/2016')
            )

            expect(uow).to receive(
                             :get
                           ).once.with(Entities::Salary, 124).and_return @loaded_salary

            expect(uow).to receive(
                             :get
                           ).once.with(Entities::Salary, 125).and_return nil
          end

          context 'when provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).once.with(
                                  :salaries,
                                  filter: { period: Date.parse('January/2016') },
                                  sort: {}
                                ).and_return(
                                  [
                                    { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                    { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 150.0 }
                                  ]
                                )
            end

            it 'returns a set of Salary objects already loaded' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 150.0 }
                                          ).and_return salary

              expect(uow).to receive(:register_clean).once.with(salary).and_return salary

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [@loaded_salary, salary]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).once.with(
                                  :salaries, filter: {}, sort: {}
                                ).and_return(
                                  [
                                    { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                    { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                  ]
                                )
            end

            it 'returns all documents as Salary objects' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                          ).and_return february

              expect(uow).to receive(:register_clean).once.with(february).and_return february

              expect(subject.find_all).to eql [@loaded_salary, february]
            end
          end

          context 'when provided with a sorted_by option' do
            before do
              expect(client).to receive(:find_on).with(
                                  :salaries, filter: {}, sort: { period: 1 }
                                ).and_return(
                                  [
                                    { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                    { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                  ]
                                )
            end

            it 'returns all documents sorted as salaries' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124, 'period' => Time.parse('2016-01-01'), 'amount' => 150.0 },
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125, 'period' => Time.parse('2016-02-01'), 'amount' => 200.0 }
                                          ).and_return february

              expect(uow).to receive(:register_clean).once.with(february).and_return february

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [@loaded_salary, february]
            end
          end
        end
      end

      describe '#sum_by_amount' do
        it 'returns a document with the sum of all entries on the collection' do
          allow(client).to receive(:aggregate_on).once.with(
                             :salaries, { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
                           ).and_return [{ '_id' => 'Sum', 'sum' => 1000.0 }]

          expect(subject.sum_by_amount).to eql 1000.0
        end

        it 'returns zero if aggregation returns empty' do
          expect(client).to receive(:aggregate_on).once.with(
                              :salaries, { :$group => { _id: 'Sum', sum: { :$sum => '$amount' } } }
                            ).and_return []

          expect(subject.sum_by_amount).to be_zero
        end
      end
    end
  end
end
