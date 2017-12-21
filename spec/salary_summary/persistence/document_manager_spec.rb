require 'spec_helper'

module SalarySummary
  module Persistence
    describe DocumentManager do
      let(:client) { double(:client, id_generator: id_gen) }
      let(:id_gen) { double(:id_generator) }
      let(:unit_of_work) { double(:unit_of_work) }

      before do
        allow(
          Databases::MongoDB::Client
        ).to receive(:current_or_new_connection).once.and_return client

        allow(UnitOfWork).to receive(:current).once.and_return unit_of_work
      end

      describe 'initialization' do
        context 'when unit of work is already set' do
          it 'initializes with a current UnitOfWork object' do
            described_class.new
          end
        end

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
        let(:repository) { double(:repository) }
        let(:entity) { double(:entity, id: BSON::ObjectId.new) }

        before do
          expect(
            Repositories::Registry
          ).to receive(:[]).once.with(Class).and_return repository
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
    end
  end
end
