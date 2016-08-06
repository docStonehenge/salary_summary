require 'spec_helper'

module SalarySummary
  module Interpreters
    describe InformationInterpreter do
      let(:salary) { double(:salary) }

      it 'parses a string to create a salary entry' do
        expect(
          Resources::Salary
        ).to receive(:new).with(amount: 100.0, period: 'August, 2016').
              and_return salary

        expect(
          subject.parse "August/2016: R$ 100,00"
        ).to eql salary
      end
    end
  end
end
