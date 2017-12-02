require 'spec_helper'

module SalarySummary
  module Repositories
    describe Base do
      let(:client) { double(:client) }
      let(:uow) { double(:uow) }
      let(:entity) { double(:entity, id: 1) }
      let(:entity2) { double(:entity, id: 2) }

      let(:described_class) do
        class TestRepository
          include Base

          private

          def entity_klass
            Entities::Salary
          end

          def collection_name
            :salaries
          end
        end

        TestRepository
      end

      subject { described_class.new(client: client) }

      describe 'attributes' do
        specify do
          expect(subject.instance_variable_get(:@connection)).to eql client
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

        context 'when entity is not yet loaded on registry' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
            allow(uow).to receive(:get).once.with(Entities::Salary, '123').and_return nil
          end

          it 'queries for entity with id, sets into current uow and returns entity object' do
            expect(client).to receive(:find_on).once.with(
                                :salaries, filter: { _id: '123' }, sort: {}
                              ).and_return [{ '_id' => '123' }]

            expect(Entities::Salary).to receive(:new).once.with(
                                          '_id' => '123'
                                        ).and_return entity

            expect(uow).to receive(:register_clean).once.with(entity).and_return entity

            expect(subject.find('123')).to eql entity
          end
        end

        context 'when entity is already loaded on registry' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow
            allow(uow).to receive(:get).once.with(Entities::Salary, '123').and_return entity
          end

          it 'returns entity got from uow clean entities list' do
            expect(client).not_to receive(:find_on).with(any_args)
            expect(Entities::Salary).not_to receive(:new).with(any_args)
            expect(subject.find('123')).to eql entity
          end
        end

        context 'when entity ID is not found' do
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
                              [{ '_id' => 1 }]
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
                                ).and_return [{ '_id' => 1 }]

              expect(uow).to receive(:get).once.with(Entities::Salary, 1).and_return nil
            end

            it 'returns a set of entity objects found on database' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            '_id' => 1
                                          ).and_return entity

              expect(uow).to receive(:register_clean).once.with(entity).and_return entity

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [entity]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).with(
                                  :salaries, filter: {}, sort: {}
                                ).and_return(
                                  [
                                    { '_id' => 1 },
                                    { '_id' => 2 }
                                  ]
                                )

              expect(uow).to receive(:get).once.with(Entities::Salary, 1).and_return nil
              expect(uow).to receive(:get).once.with(Entities::Salary, 2).and_return nil
            end

            it 'returns all documents as entity objects' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 1 }
                                          ).and_return entity

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 2 }
                                          ).and_return entity2

              expect(uow).to receive(:register_clean).once.with(entity).and_return entity
              expect(uow).to receive(:register_clean).once.with(entity2).and_return entity2

              expect(subject.find_all).to eql [entity, entity2]
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
                                    { '_id' => 2 },
                                    { '_id' => 1 }
                                  ]
                                )
            end

            it 'returns all documents sorted as entity objects' do
              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 2 }
                                          ).and_return entity2

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 1 }
                                          ).and_return entity

              expect(uow).to receive(:register_clean).once.with(entity2).and_return entity2
              expect(uow).to receive(:register_clean).once.with(entity).and_return entity

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [entity2, entity]
            end
          end
        end

        context 'when UnitOfWork contains clean entities instances loaded' do
          before do
            allow(Persistence::UnitOfWork).to receive(:current).and_return uow

            @loaded_entity = Entities::Salary.new

            expect(uow).to receive(
                             :get
                           ).once.with(Entities::Salary, 124).and_return @loaded_entity

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
                                    { '_id' => 124 },
                                    { '_id' => 125 }
                                  ]
                                )
            end

            it 'returns a set of entity objects already loaded' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124 }
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125 }
                                          ).and_return entity

              expect(uow).to receive(:register_clean).once.with(entity).and_return entity

              expect(
                subject.find_all(modifier: { period: Date.parse('January/2016') })
              ).to eql [@loaded_entity, entity]
            end
          end

          context 'when not provided with a query modifier' do
            before do
              expect(client).to receive(:find_on).once.with(
                                  :salaries, filter: {}, sort: {}
                                ).and_return(
                                  [
                                    { '_id' => 124 },
                                    { '_id' => 125 }
                                  ]
                                )
            end

            it 'returns all documents as entity objects' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124 }
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125 }
                                          ).and_return entity

              expect(uow).to receive(:register_clean).once.with(entity).and_return entity

              expect(subject.find_all).to eql [@loaded_entity, entity]
            end
          end

          context 'when provided with a sorted_by option' do
            before do
              expect(client).to receive(:find_on).with(
                                  :salaries, filter: {}, sort: { period: 1 }
                                ).and_return(
                                  [
                                    { '_id' => 124 },
                                    { '_id' => 125 }
                                  ]
                                )
            end

            it 'returns all documents sorted as entity objects' do
              expect(Entities::Salary).not_to receive(:new).with(
                                                { '_id' => 124 }
                                              )

              expect(Entities::Salary).to receive(:new).once.with(
                                            { '_id' => 125 }
                                          ).and_return entity

              expect(uow).to receive(:register_clean).once.with(entity).and_return entity

              expect(subject.find_all(sorted_by: { period: 1 })).to eql [@loaded_entity, entity]
            end
          end
        end
      end

      describe '#insert entity' do
        let(:entity_to_save) { Entities::Salary.new }

        it 'saves an entry from entity instance on collection, based on its mapped fields' do
          allow(entity_to_save).to receive(:to_mongo_document).once.and_return(
                             _id: 1, amount: 200.0, period: Date.parse('1990/01/01')
                           )

          expect(client).to receive(:insert_on).once.with(
                              :salaries,
                              _id: 1, amount: 200.0, period: Date.parse('1990/01/01')
                            )

          subject.insert entity_to_save
        end

        it "raises ArgumentError if entity isn't an instance of entity_klass" do
          expect(entity).not_to receive(:to_mongo_document)
          expect(client).not_to receive(:insert_on).with(any_args)

          expect {
            subject.insert OpenStruct.new
          }.to raise_error(
                 ArgumentError,
                 "Entity must be of class: SalarySummary::Entities::Salary. "\
                 "This repository cannot operate on OpenStruct entities."
               )
        end
      end

      describe '#update entity' do
        let(:entity_to_save) { Entities::Salary.new }

        it 'calls document update on collection, using entity id as identifier' do
          allow(entity_to_save).to receive(:id).and_return '123'

          expect(entity_to_save).to receive(
                                      :to_mongo_document
                                    ).once.with(include_id_field: false).and_return(
                                      amount: 200.0, period: Date.parse('1990/01/01')
                                    )

          expect(client).to receive(:update_on).once.with(
                              :salaries,
                              { _id: '123' },
                              { '$set' => { amount: 200.0, period: Date.parse('1990/01/01') } }
                            )

          subject.update entity_to_save
        end

        it "raises ArgumentError if entity isn't an instance of entity_klass" do
          expect(entity).not_to receive(:to_mongo_document).with(any_args)
          expect(client).not_to receive(:update_on).with(any_args)

          expect {
            subject.update OpenStruct.new
          }.to raise_error(
                 ArgumentError,
                 "Entity must be of class: SalarySummary::Entities::Salary. "\
                 "This repository cannot operate on OpenStruct entities."
               )
        end
      end

      describe '#delete entity' do
        let(:entity_to_save) { Entities::Salary.new }

        it 'calls document delete on collection, using entity id as identifier' do
          allow(entity_to_save).to receive(:id).and_return '123'

          expect(client).to receive(:delete_from).once.with(:salaries, _id: '123')

          subject.delete entity_to_save
        end

        it "raises ArgumentError if entity isn't an instance of entity_klass" do
          expect(client).not_to receive(:delete_from).with(any_args)

          expect {
            subject.delete OpenStruct.new
          }.to raise_error(
                 ArgumentError,
                 "Entity must be of class: SalarySummary::Entities::Salary. "\
                 "This repository cannot operate on OpenStruct entities."
               )
        end
      end

      describe '#aggregate' do
        it 'calls aggregation pipeline on collection, allowing stage append on block' do
          expect(client).to receive(:aggregate_on).once.with(
                              :salaries,
                              { :$group => { _id: 'Sum', count: { :$sum => 1 } } },
                              { :$foo => 'bar' }
                            ).and_return [{ '_id' => 'Sum', 'count' => 12 }]

          expect(
            subject.aggregate do |stages|
              stages << { :$group => { _id: 'Sum', count: { :$sum => 1 } } }
              stages << { :$foo => 'bar' }
            end
          ).to eql [{ '_id' => 'Sum', 'count' => 12 }]
        end
      end
    end
  end
end
