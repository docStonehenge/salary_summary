require 'spec_helper'

describe 'Repositories integration tests', db_integration: true do
  include_context 'StubRepository'
  include_context 'StubEntity'

  describe 'insertions' do
    it 'correctly inserts entity on collection' do
      entity.id = BSON::ObjectId.new
      entity.first_name = 'John'
      entity.age = 32
      entity.wage = 32_000

      result = repo.insert entity

      expect(result).to be_ok
      expect(result.written_count).to eql 1
    end

    it 'raises error when trying to insert a different entity' do
      expect {
        repo.insert OpenStruct.new(id: 123)
      }.to raise_error SalarySummary::Repositories::InvalidEntityError
    end

    it 'raises error when trying to insert an entity without id' do
      entity.first_name = 'John'
      entity.age = 32
      entity.wage = 32_000

      expect {
        repo.insert entity
      }.to raise_error SalarySummary::Repositories::InvalidEntityError
    end

    it 'raises error when trying to insert an entity with same id as another' do
      entity.id = BSON::ObjectId.new
      entity.first_name = 'John'
      entity.age = 32
      entity.wage = 32_000

      repo.insert entity

      expect {
        repo.insert StubEntity.new(id: entity.id, first_name: 'Bob', age: 50, wage: 60_000)
      }.to raise_error(SalarySummary::Repositories::InsertionError)
    end
  end

  describe 'querying by id' do
    before do
      SalarySummary::Persistence::UnitOfWork.new_current

      entity.id = BSON::ObjectId.new
      entity.first_name = 'John'
      entity.age = 32
      entity.wage = 32_000

      repo.insert entity
    end

    it 'returns entity found by id parameter' do
      result = repo.find(entity.id)

      expect(result.id).to eql entity.id
      expect(result.first_name).to eql entity.first_name
      expect(result.age).to eql entity.age
      expect(result.wage).to eql entity.wage
    end

    it 'returns the same entity object after first query' do
      result1 = repo.find(entity.id)
      result2 = repo.find(entity.id)
      result3 = repo.find(entity.id)

      expect(result2).to equal result1
      expect(result2).to equal result3
      expect(result3).to equal result1
      expect(result3).to equal result2
    end

    it "raises Queries::EntityNotFoundError when id provided isn't found" do
      expect {
        repo.find(BSON::ObjectId.new)
      }.to raise_error(SalarySummary::Queries::EntityNotFoundError)
    end
  end

  describe 'querying with filters and sorting' do
    before do
      SalarySummary::Persistence::UnitOfWork.new_current

      @entity1 = StubEntity.new(id: BSON::ObjectId.new)
      @entity2 = StubEntity.new(id: BSON::ObjectId.new, first_name: 'John', age: 32, wage: 150)
      @entity3 = StubEntity.new(id: BSON::ObjectId.new, first_name: 'Bob', age: 50, wage: 600)
      @entity4 = StubEntity.new(id: BSON::ObjectId.new, first_name: 'Quack', age: 28, wage: 1200)

      repo.insert @entity1
      repo.insert @entity2
      repo.insert @entity3
      repo.insert @entity4
    end

    it 'returns all entities without using filters or sorting' do
      expect(repo.find_all).to include(@entity1, @entity2, @entity3, @entity4)
    end

    it 'returns always the same entities after first query' do
      first_query = repo.find_all

      entity1 = first_query[0]
      entity2 = first_query[1]
      entity3 = first_query[2]
      entity4 = first_query[3]
      expect(entity1.id).to eql @entity1.id
      expect(entity2.id).to eql @entity2.id
      expect(entity3.id).to eql @entity3.id
      expect(entity4.id).to eql @entity4.id

      second_query = repo.find_all

      expect(second_query[0]).to equal entity1
      expect(second_query[1]).to equal entity2
      expect(second_query[2]).to equal entity3
      expect(second_query[3]).to equal entity4

      second_query = repo.find_all

      expect(second_query[0]).to equal entity1
      expect(second_query[1]).to equal entity2
      expect(second_query[2]).to equal entity3
      expect(second_query[3]).to equal entity4
    end

    it 'returns entities correctly filtered' do
      result = repo.find_all(filter: { age: { '$gte' => 30 } })

      entity1 = result[0]
      entity2 = result[1]

      expect(entity1.id).to eql @entity2.id
      expect(entity2.id).to eql @entity3.id
    end

    it 'returns entities correctly sorted' do
      result = repo.find_all(sorted_by: { age: -1 })

      entity1 = result[0]
      entity2 = result[1]
      entity3 = result[2]
      entity4 = result[3]
      expect(entity1.id).to eql @entity3.id
      expect(entity2.id).to eql @entity2.id
      expect(entity3.id).to eql @entity4.id
      expect(entity4.id).to eql @entity1.id
    end

    it 'returns entities correctly filtered and sorted' do
      result = repo.find_all(filter: { age: { '$gte' => 30 } }, sorted_by: { age: -1 })

      entity1 = result[0]
      entity2 = result[1]

      expect(entity1.id).to eql @entity3.id
      expect(entity2.id).to eql @entity2.id
    end

    it 'returns empty collection when no entities are found' do
      expect(repo.find_all(filter: { age: { '$gt' => 60 } })).to be_empty
    end
  end
end
