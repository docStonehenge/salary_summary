require 'spec_helper'

shared_context 'StubEntity' do
  class StubEntity
    include SalarySummary::Persistence::DocumentDefinitions::Base

    define_field :first_name, type: String
    define_field :age,        type: Integer
    define_field :wage,       type: BigDecimal

    def self.repository
      SalarySummary::Repositories::StubRepository
    end
  end

  let(:entity) { StubEntity.new }
end
