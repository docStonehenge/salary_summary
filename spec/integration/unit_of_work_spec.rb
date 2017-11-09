require 'spec_helper'

describe 'Persistence::UnitOfWork integration tests', integration: true do
  subject do
    SalarySummary::Persistence::UnitOfWork.new(
      SalarySummary::Persistence::EntityRegistry.new
    )
  end

  it 'sets unit of work object into current Thread only' do
    SalarySummary::Persistence::UnitOfWork.current = subject
    expect(SalarySummary::Persistence::UnitOfWork.current).to equal subject

    uow_variable = "uow_variable"

    Thread.new do
      uow_variable = SalarySummary::Persistence::UnitOfWork.current
    end.join

    expect(uow_variable).to be_nil
  end

  it 'sets a new unit of work object into current Thread' do
    SalarySummary::Persistence::UnitOfWork.new_current

    expect(
      SalarySummary::Persistence::UnitOfWork.current
    ).to be_an_instance_of SalarySummary::Persistence::UnitOfWork

    uow_variable = "uow_variable"

    Thread.new do
      uow_variable = SalarySummary::Persistence::UnitOfWork.current
    end.join

    expect(uow_variable).to be_nil
  end
end
