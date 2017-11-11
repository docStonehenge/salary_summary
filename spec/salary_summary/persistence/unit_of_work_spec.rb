require 'spec_helper'

module SalarySummary
  module Persistence
    describe UnitOfWork do
      describe '.new_current uow' do
        it 'registers a new UnitOfWork instance as current on running thread' do
          described_class.new_current

          expect(
            Thread.current.thread_variable_get(:current_uow)
          ).to be_an_instance_of(described_class)
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

      subject { described_class.new(EntityRegistry.new) }

      let(:clean_entities) { subject.instance_variable_get(:@clean_entities) }
      let(:new_entities) { subject.instance_variable_get(:@new_entities) }
      let(:changed_entities) { subject.instance_variable_get(:@changed_entities) }

      describe '#register_clean entity' do
        let(:entity) { Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')) }

        context "when clean_entities list doesn't contain entity yet" do
          it 'adds entity to clean_entities map' do
            subject.register_clean(entity)
            expect(clean_entities.get(entity.class.name, entity.id)).to equal entity
          end
        end

        context 'when clean_entities already contains entity' do
          it "doesn't add same database registry twice" do
            another_entity = Entities::Salary.new(id: entity.id)

            subject.register_clean(entity)
            subject.register_clean(another_entity)

            expect(
              clean_entities.get(Entities::Salary, another_entity.id)
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
        let(:removed_entities) { subject.instance_variable_get(:@removed_entities) }

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
            entity = Entities::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.register_clean(entity)
            subject.register_removed(entity)

            expect(clean_entities.get(Entities::Salary, 123)).to be_nil
            expect(removed_entities).to include entity
          end
        end
      end
    end
  end
end
