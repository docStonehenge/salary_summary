require 'spec_helper'

module SalarySummary
  module Persistence
    describe UnitOfWork do
      describe '.new_current uow' do
        context 'when there is a current UnitOfWork running' do
          before do
            described_class.current = subject
            @registry = described_class.current.clean_entities
          end

          it 'registers a new UnitOfWork instance on running thread using existing registry' do
            described_class.new_current

            expect(
              Thread.current.thread_variable_get(:current_uow)
            ).to be_an_instance_of(described_class)

            expect(described_class.current.clean_entities).to eql @registry
          end
        end

        context "when no UnitOfWork is running on current Thread" do
          before do
            Thread.current.thread_variable_set(:current_uow, nil)

            expect(
              Thread.current.thread_variable_get(:current_uow)
            ).to be_nil
          end

          it 'registers a new UnitOfWork instance on running thread using a new registry' do
            new_registry = double(:entity_registry)

            expect(Entities::Registry).to receive(:new).once.and_return new_registry

            described_class.new_current

            expect(
              Thread.current.thread_variable_get(:current_uow)
            ).to be_an_instance_of(described_class)

            expect(described_class.current.clean_entities).to equal new_registry
          end
        end
      end

      describe '.current= uow' do
        it 'registers a UnitOfWork instance as current on running thread' do
          described_class.current = subject

          expect(
            Thread.current.thread_variable_get(:current_uow)
          ).to equal subject
        end
      end

      describe '.current' do
        it 'returns current UnitOfWork instance on running thread' do
          described_class.current = subject
          expect(described_class.current).to equal subject
        end

        it 'raises UnitOfWorkNotStartedError when no instance is set on current Thread' do
          expect {
            Thread.new { described_class.current }.join
          }.to raise_error(UnitOfWorkNotStartedError)
        end
      end

      subject { described_class.new(Entities::Registry.new) }

      let(:clean_entities) { subject.instance_variable_get(:@clean_entities) }
      let(:new_entities) { subject.instance_variable_get(:@new_entities) }
      let(:changed_entities) { subject.instance_variable_get(:@changed_entities) }
      let(:removed_entities) { subject.instance_variable_get(:@removed_entities) }

      describe '#get entity_class, entity_id' do
        let(:entity) { SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }

        it 'returns the entity set on clean entities list' do
          clean_entities.add(entity)
          expect(subject.get entity.class, entity.id).to equal entity
        end

        it 'returns nil if no entity was found' do
          expect(subject.get entity.class, entity.id).to be_nil
        end
      end

      describe '#commit' do
        let(:entity_to_save) { SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }
        let(:entity_to_update) { SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }
        let(:entity_to_delete) { SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }
        let(:repository) { double(:repository) }

        before do
          subject.register_new(entity_to_save)
          subject.register_changed(entity_to_update)
          subject.register_removed(entity_to_delete)
        end

        context 'when all operations occur correctly' do
          it "traverses all lists with to-persist entities and calls repository methods" do
            expect(
              Repositories::Registry
            ).to receive(:[]).once.with(entity_to_save.class).and_return repository

            expect(repository).to receive(:insert).once.with(entity_to_save)

            expect(
              Repositories::Registry
            ).to receive(:[]).once.with(entity_to_update.class).and_return repository

            expect(repository).to receive(:update).once.with(entity_to_update)

            expect(
              Repositories::Registry
            ).to receive(:[]).once.with(entity_to_delete.class).and_return repository

            expect(repository).to receive(:delete).once.with(entity_to_delete)

            expect(Repositories::Registry).to receive(:new_repositories).once

            subject.commit

            expect(new_entities).not_to include entity_to_save
            expect(changed_entities).not_to include entity_to_update
            expect(removed_entities).not_to include entity_to_delete
          end
        end

        context 'when any operation fails' do
          it "stops all subsequent processes, doesn't clear list neither create new registry" do
            expect(
              Repositories::Registry
            ).to receive(:[]).once.with(entity_to_save.class).and_return repository

            expect(repository).to receive(:insert).once.with(entity_to_save)

            expect(
              Repositories::Registry
            ).to receive(:[]).once.with(entity_to_update.class).and_return repository

            expect(repository).to receive(:update).once.with(
                                    entity_to_update
                                  ).and_raise(Mongo::Error::OperationFailure)

            expect(
              Repositories::Registry
            ).not_to receive(:[]).with(entity_to_delete.class)

            expect(Repositories::Registry).not_to receive(:new_repositories)

            expect {
              subject.commit
            }.to raise_error(Mongo::Error::OperationFailure)

            expect(new_entities).not_to include entity_to_save
            expect(changed_entities).to include entity_to_update
            expect(removed_entities).to include entity_to_delete
          end
        end
      end

      describe '#register_clean entity' do
        let(:entity) { SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }

        context "when clean_entities list doesn't contain entity yet" do
          it 'adds entity to clean_entities map' do
            subject.register_clean(entity)
            expect(clean_entities.get(entity.class.name, entity.id)).to equal entity
          end
        end

        context 'when clean_entities already contains entity' do
          it "doesn't add same database registry twice" do
            another_entity = SalarySummary::Entities::Salary.new(id: entity.id)

            subject.register_clean(entity)
            subject.register_clean(another_entity)

            expect(
              clean_entities.get(SalarySummary::Entities::Salary, another_entity.id)
            ).not_to equal another_entity
          end
        end

        context "when entity doesn't contain ID field set" do
          let(:not_persisted_entity) { double(:entity, id: nil) }

          it "doesn't add to clean_entities list" do
            subject.register_clean(not_persisted_entity)
            expect(clean_entities).not_to include not_persisted_entity
          end
        end
      end

      describe '#register_new entity' do
        let(:entity) { double(:entity, id: 123) }

        context "when new_entities list doesn't contain entity yet" do
          it 'adds entity to new_entities list and to clean entities' do
            subject.register_new(entity)
            expect(new_entities.first).to equal entity
            expect(clean_entities.get(entity.class, 123)).to eql entity
          end
        end

        context 'when new_entities already contains entity' do
          it "doesn't add same object twice" do
            subject.register_new(entity)
            subject.register_new(entity)

            expect(new_entities).to contain_exactly(entity)
          end
        end

        context "when entity doesn't contain ID field set" do
          let(:not_persisted_entity) { double(:entity, id: nil) }

          it "doesn't add to new_entities list" do
            subject.register_new(not_persisted_entity)
            expect(new_entities).not_to include not_persisted_entity
          end
        end

        context 'when entity is present in another list' do
          it "doesn't add to new_entities list when present on changed_entities" do
            subject.register_changed(entity)
            subject.register_new(entity)

            expect(new_entities).not_to include entity
          end

          it "doesn't add to new_entities list when present on removed_entities" do
            subject.register_removed(entity)
            subject.register_new(entity)

            expect(new_entities).not_to include entity
          end
        end
      end

      describe '#register_changed entity' do
        let(:entity) { double(:entity, id: 123) }

        context "when changed_entities list doesn't contain entity yet" do
          it 'adds entity to changed_entities list' do
            subject.register_changed(entity)
            expect(changed_entities.first).to equal entity
          end
        end

        context 'when changed_entities already contains entity' do
          it "doesn't add same object twice" do
            subject.register_changed(entity)
            subject.register_changed(entity)

            expect(changed_entities).to contain_exactly(entity)
          end
        end

        context "when entity doesn't contain ID field set" do
          let(:not_persisted_entity) { double(:entity, id: nil) }

          it "doesn't add to changed_entities list" do
            subject.register_changed(not_persisted_entity)
            expect(changed_entities).not_to include not_persisted_entity
          end
        end

        context 'when entity is present in another list' do
          it "doesn't add to changed_entities list when present on new_entities" do
            subject.register_new(entity)
            subject.register_changed(entity)

            expect(changed_entities).not_to include entity
          end

          it "doesn't add to changed_entities list when present on removed_entities" do
            subject.register_removed(entity)
            subject.register_changed(entity)

            expect(changed_entities).not_to include entity
          end

          it 'adds to changed_entities when already present on clean entities' do
            subject.register_clean(entity)
            subject.register_changed(entity)

            expect(changed_entities).to include entity
          end
        end
      end

      describe '#register_removed entity' do
        let(:entity) { double(:entity, id: 123) }

        context "when removed_entities list doesn't contain entity yet" do
          it 'adds entity to removed_entities list' do
            subject.register_removed(entity)
            expect(removed_entities.first).to equal entity
          end

          it 'removes entity from clean_entities first' do
            subject.register_clean(entity)
            subject.register_removed(entity)

            expect(removed_entities.first).to equal entity
            expect(clean_entities.get(entity.class, entity.id)).to be_nil
          end
        end

        context 'when removed_entities already contains entity' do
          it "doesn't add same object twice" do
            subject.register_removed(entity)
            subject.register_removed(entity)

            expect(removed_entities).to contain_exactly(entity)
          end
        end

        context "when entity doesn't contain ID field set" do
          let(:not_persisted_entity) { double(:entity, id: nil) }

          it "doesn't add to removed_entities list" do
            subject.register_removed(not_persisted_entity)
            expect(removed_entities).not_to include not_persisted_entity
          end
        end

        context 'when entity is present in another list' do
          it "doesn't add to removed_entities and remove from new_entities" do
            subject.register_new(entity)
            expect(new_entities).to include entity

            subject.register_removed(entity)

            expect(removed_entities).not_to include entity
            expect(new_entities).not_to include entity
          end

          it "removes from changed_entities before setting on removed_entities" do
            subject.register_changed(entity)
            expect(changed_entities).to include entity

            subject.register_removed(entity)

            expect(changed_entities).not_to include entity
            expect(removed_entities).to include entity
          end

          it "removes from clean_entities before setting on removed_entities" do
            entity = SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.register_clean(entity)
            subject.register_removed(entity)

            expect(clean_entities.get(SalarySummary::Entities::Salary, entity.id)).to be_nil
            expect(removed_entities).to include entity
          end
        end
      end
    end
  end
end
