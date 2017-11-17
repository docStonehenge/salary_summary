require 'spec_helper'

describe 'Persistence::UnitOfWork integration tests', integration: true do
  let(:entity_registry) { SalarySummary::Persistence::EntityRegistry.new }

  subject { SalarySummary::Persistence::UnitOfWork.new(entity_registry) }

  before do
    Thread.current.thread_variable_set(:current_uow, nil)
  end

  it 'sets unit of work object into current Thread only' do
    SalarySummary::Persistence::UnitOfWork.current = subject
    expect(SalarySummary::Persistence::UnitOfWork.current).to equal subject

    expect {
      Thread.new { SalarySummary::Persistence::UnitOfWork.current }.join
    }.to raise_error(SalarySummary::Persistence::UnitOfWorkNotStartedError)
  end

  it 'sets a new unit of work object into current Thread' do
    SalarySummary::Persistence::UnitOfWork.new_current

    expect(
      SalarySummary::Persistence::UnitOfWork.current
    ).to be_an_instance_of SalarySummary::Persistence::UnitOfWork

    expect {
      Thread.new { SalarySummary::Persistence::UnitOfWork.current }.join
    }.to raise_error(SalarySummary::Persistence::UnitOfWorkNotStartedError)
  end

  it 'uses same entity registry from existing uow on new one registered' do
    SalarySummary::Persistence::UnitOfWork.current = subject
    new_uow = SalarySummary::Persistence::UnitOfWork.new_current

    expect(SalarySummary::Persistence::UnitOfWork.current).to equal new_uow
    expect(new_uow.clean_entities).to equal entity_registry
  end

  it 'uses new entity registry on new UnitOfWork when no current_uow is set' do
    expect {
      SalarySummary::Persistence::UnitOfWork.current
    }.to raise_error(SalarySummary::Persistence::UnitOfWorkNotStartedError)

    new_registry = double(:entity_registry)

    expect(
      SalarySummary::Persistence::EntityRegistry
    ).to receive(:new).once.and_return new_registry

    new_uow = SalarySummary::Persistence::UnitOfWork.new_current

    expect(SalarySummary::Persistence::UnitOfWork.current).to equal new_uow
    expect(new_uow.clean_entities).to equal new_registry
  end

  context 'getting entity registered as clean' do
    let(:entity) do
      SalarySummary::Entities::Salary.new(
        id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')
      )
    end

    it 'returns a clean entity set on unit of work' do
      SalarySummary::Persistence::UnitOfWork.new_current

      uow = SalarySummary::Persistence::UnitOfWork.current

      uow.register_clean(entity)

      expect(uow.get(entity.class, entity.id)).to equal entity
      expect(uow.get(entity.class, entity.id)).to equal entity
    end

    it 'returns nil if no entity is found' do
      SalarySummary::Persistence::UnitOfWork.new_current
      uow = SalarySummary::Persistence::UnitOfWork.current

      expect(uow.get(entity.class, entity.id)).to be_nil
    end
  end
end
