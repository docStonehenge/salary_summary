require 'spec_helper'

module SalarySummary
  module Repositories
    describe OperationError do
      subject { described_class.new(:insertion, "Error from database") }

      it '#message' do
        expect(subject.message).to eql(
                                     "Error on insertion operation. "\
                                     "Reason: 'Error from database'"
                                   )
      end
    end
  end
end
