require 'spec_helper'

module SalarySummary
  module Persistency
    describe UnitOfWork do
      describe '#register_clean entity' do
        let(:entity) { double(:entity, id: 123) }
        let(:clean_entities) { subject.instance_variable_get(:@clean_entities) }

        context "when clean_entities list doesn't contain entity yet" do
          it 'adds entity to clean_entities list' do
            subject.register_clean(entity)
            expect(clean_entities.first).to equal entity
          end
        end

        context 'when clean_entities already contains entity' do
          it "doesn't add same object twice" do
            subject.register_clean(entity)
            subject.register_clean(entity)

            expect(clean_entities).to contain_exactly(entity)
          end
        end

        context "when entity doesn't contain ID field set" do
          let(:not_persisted_entity) { double(:entity, id: nil) }

          it "doesn't add to clean_entities list" do
            subject.register_clean(not_persisted_entity)
            expect(clean_entities).not_to include not_persisted_entity
          end
        end

        context 'when entity is present in another list' do
          it "doesn't add to clean_entities list when present on new_entities" do
            subject.register_new(entity)
            subject.register_clean(entity)

            expect(clean_entities).not_to include entity
          end

          it "doesn't add to clean_entities list when present on changed_entities" do
            subject.register_changed(entity)
            subject.register_clean(entity)

            expect(clean_entities).not_to include entity
          end

          it "doesn't add to clean_entities list when present on removed_entities" do
            subject.register_removed(entity)
            subject.register_clean(entity)

            expect(clean_entities).not_to include entity
          end
        end
      end

      describe '#register_new entity' do
        let(:entity) { double(:entity, id: 123) }
        let(:new_entities) { subject.instance_variable_get(:@new_entities) }

        context "when new_entities list doesn't contain entity yet" do
          it 'adds entity to new_entities list' do
            subject.register_new(entity)
            expect(new_entities.first).to equal entity
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
          it "doesn't add to new_entities list when present on clean_entities" do
            subject.register_clean(entity)
            subject.register_new(entity)

            expect(new_entities).not_to include entity
          end

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
        let(:changed_entities) { subject.instance_variable_get(:@changed_entities) }

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

          it 'adds to changed_entities when present on clean_entities' do
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
          it "doesn't add to removed_entities list when present on new_entities" do
            subject.register_new(entity)
            subject.register_removed(entity)

            expect(removed_entities).not_to include entity
          end

          it "doesn't add to removed_entities list when present on changed_entities" do
            subject.register_changed(entity)
            subject.register_removed(entity)

            expect(removed_entities).not_to include entity
          end

          it 'adds to removed_entities when present on clean_entities' do
            subject.register_clean(entity)
            subject.register_removed(entity)

            expect(removed_entities).to include entity
          end
        end
      end
    end
  end
end
