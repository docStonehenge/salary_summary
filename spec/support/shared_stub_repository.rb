require 'spec_helper'

shared_context 'StubRepository' do
  class StubRepository
    include SalarySummary::Repositories::Base

    private

    def entity_klass
      StubEntity
    end

    def collection_name
      :stubs
    end
  end

  let(:repo) { StubRepository.new }
end
