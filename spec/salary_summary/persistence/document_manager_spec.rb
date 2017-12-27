require 'spec_helper'

module SalarySummary
  module Persistence
    describe DocumentManager do
      let(:client) { double(:client, id_generator: id_gen) }
      let(:id_gen) { double(:id_generator) }
      let(:unit_of_work) { double(:unit_of_work) }
      let(:repository) { double(:repository) }
      let(:entity) { double(:entity, id: BSON::ObjectId.new) }

      before do
        allow(
          Databases::MongoDB::Client
        ).to receive(:current_or_new_connection).once.and_return client

        allow(UnitOfWork).to receive(:current).once.and_return unit_of_work
      end

      describe 'initialization' do
        context "when unit of work isn't already set" do
          it 'initializes with a new UnitOfWork object' do
            allow(UnitOfWork).to receive(:current).once.and_raise(
                                    UnitOfWorkNotStartedError
                                  )

            expect(UnitOfWork).to receive(:new_current).once.and_return unit_of_work

            described_class.new
          end
        end
      end

      describe '#find entity_type, entity_id' do
        before do
          expect(
            subject
          ).to receive(:repository_for).once.with(Class).and_return repository
        end

        context 'when entity is not found' do
          it 'raises Queries::EntityNotFoundError' do
            expect(repository).to receive(:find).once.with(entity.id).and_raise(
                                    Queries::EntityNotFoundError.new(
                                      id: entity.id, entity_name: Class
                                    )
                                  )

            expect {
              subject.find(Class, entity.id)
            }.to raise_error(an_instance_of(Queries::EntityNotFoundError))
          end
        end

        context 'when entity is found' do
          it 'returns entity' do
            expect(repository).to receive(:find).once.with(entity.id).and_return entity

            expect(subject.find(Class, entity.id)).to eql entity
          end
        end
      end

      describe '#find_all entity_type, modifier: {}, sorted_by: {}' do
        before do
          expect(
            subject
          ).to receive(:repository_for).once.with(Class).and_return repository
        end

        it 'returns collection of entities from query without modifier or sort' do
          expect(repository).to receive(
                                  :find_all
                                ).once.with(modifier: {}, sorted_by: {}).and_return [entity]

          expect(subject.find_all(Class)).to eql [entity]
        end

        it 'returns collection of entities from query with modifier, without sort' do
          expect(repository).to receive(
                                  :find_all
                                ).once.with(
                                  modifier: { foo: 'bar' }, sorted_by: {}
                                ).and_return [entity]

          expect(
            subject.find_all(Class, modifier: { foo: 'bar' })
          ).to eql [entity]
        end

        it 'returns collection of entities from query without modifier, with sort' do
          expect(repository).to receive(
                                  :find_all
                                ).once.with(
                                  modifier: {}, sorted_by: { foo: -1 }
                                ).and_return [entity]

          expect(
            subject.find_all(Class, sorted_by: { foo: -1 })
          ).to eql [entity]
        end

        it 'returns collection of entities from query with modifier and sort' do
          expect(repository).to receive(
                                  :find_all
                                ).once.with(
                                  modifier: { foo: 'bar' }, sorted_by: { foo: -1 }
                                ).and_return [entity]

          expect(
            subject.find_all(Class, modifier: { foo: 'bar' }, sorted_by: { foo: -1 })
          ).to eql [entity]
        end
      end

      describe '#repository_for entity_type' do
        it 'returns repository found for entity_type from registry' do
          expect(
            Repositories::Registry
          ).to receive(:[]).once.with(Class).and_return repository

          expect(subject.repository_for(Class)).to eql repository
        end
      end

      describe '#persist entity' do
        context "when entity hasn't an ID" do
          before { allow(entity).to receive(:id).and_return nil }

          it 'sets entity ID and registers on UnitOfWork as new' do
            expect(id_gen).to receive(:generate).once.and_return 123
            expect(entity).to receive(:id=).once.with(123)
            expect(unit_of_work).to receive(:register_new).once.with(entity)
            subject.persist entity
          end
        end

        context 'when entity already has an ID' do
          it "doesn't replace entity's ID and just calls UnitOfWork registration" do
            expect(id_gen).not_to receive(:generate)
            expect(entity).not_to receive(:id=).with(any_args)
            expect(unit_of_work).to receive(:register_new).once.with(entity)
            subject.persist entity
          end
        end
      end

      describe '#remove entity' do
        it 'calls removed registration of entity on UnitOfWork' do
          expect(unit_of_work).to receive(:register_removed).once.with(entity)
          subject.remove entity
        end
      end

      describe '#detach entity' do
        it 'calls detach process for entity on UnitOfWork' do
          expect(unit_of_work).to receive(:detach).once.with(entity)
          subject.detach entity
        end
      end

      describe '#clear' do
        it 'calls clear process on UnitOfWork' do
          expect(unit_of_work).to receive(:clear).once
          subject.clear
        end
      end
    end
  end
end