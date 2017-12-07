require 'spec_helper'

module SalarySummary
  module Persistence
    describe OperationError do
      subject { described_class.new("Error from database") }

      it '#message' do
        expect(subject.message).to eql(
                                     "The database operation has failed. "\
                                     "Reason: 'Error from database'"
                                   )
      end
    end
  end
end
