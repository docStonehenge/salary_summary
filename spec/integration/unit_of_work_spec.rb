require 'spec_helper'

describe 'Persistence::UnitOfWork integration tests', integration: true do
  subject do
    SalarySummary::Persistence::UnitOfWork.new(
      SalarySummary::Persistence::EntityRegistry.new
    )
  end

  before do
    Thread.current[:current_uow] = nil
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
