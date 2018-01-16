require 'spec_helper'

describe 'Persistence::DocumentManager integration tests', db_integration: true do
  include_context 'StubRepository'
  include_context 'StubEntity'

  let(:dm) { SalarySummary::Persistence::DocumentManager.new }
  let(:uow) { SalarySummary::Persistence::UnitOfWork.current }

  context 'persisting on UnitOfWork' do
    it "persists entity setting its ID field" do
      dm.persist entity

      expect(uow.managed?(entity)).to be true
      expect(entity.id).not_to be_nil
    end

    it "doesn't change entity id when persisting entity with id" do
      id = BSON::ObjectId.new

      entity.id = id

      dm.persist entity
      expect(uow.managed?(entity)).to be true
      expect(entity.id).to eql id
    end

    it "can't persist an entity that will be removed" do
      id = BSON::ObjectId.new
      entity.id = id
      dm.remove entity

      dm.persist entity

      expect(uow.managed?(entity)).to be false
    end

    it "can't persist an entity about to be updated" do
      dm.persist entity
      dm.commit

      loaded_entity = dm.find(entity.class, entity.id)

      loaded_entity.age = 48
      loaded_entity.first_name = 'Joe'

      dm.persist loaded_entity
      dm.persist entity

      expect(uow.new_entities).not_to include loaded_entity
      expect(uow.new_entities).not_to include entity
    end
  end

  context 'removing entities' do
    it 'sets entity as removed on UnitOfWork' do
      entity.id = BSON::ObjectId.new

      dm.remove entity

      expect(uow.removed_entities).to include entity
    end

    it 'removes entity from managed state when removing it' do
      dm.persist entity

      expect(uow.managed?(entity)).to be true

      dm.remove entity

      expect(uow.managed?(entity)).to be false
    end

    it 'removes an entity loaded from database' do
      dm.persist entity
      dm.commit

      loaded_entity = dm.find(entity.class, entity.id)

      dm.remove loaded_entity

      expect(uow.managed?(entity)).to be false
      expect(uow.managed?(loaded_entity)).to be false
    end
  end

  context 'insertions' do
    before do
      dm.persist entity
    end

    it 'correctly inserts entity into database' do
      expect(dm.commit).to be true
    end

    it 'raises error when entity ID field is removed' do
      entity.id = nil

      expect {
        dm.commit
      }.to raise_error(SalarySummary::Repositories::InvalidEntityError)
    end
  end
end
