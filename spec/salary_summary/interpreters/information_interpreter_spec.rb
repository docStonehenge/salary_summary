require 'spec_helper'

module SalarySummary
  module Interpreters
    describe InformationInterpreter do
      let(:salary) { double(:salary) }

      describe 'parse' do
        it 'parses a string to create a salary object' do
          expect(
            Entities::Salary
          ).to receive(:new).with(amount: 100.0, period: Date.parse('August/2016')).
                and_return salary

          expect(
            subject.parse "August/2016: R$ 100,00"
          ).to eql salary
        end

        it 'halts execution if salary creation returns an error' do
          expect(Entities::Salary).not_to receive(:new).with(any_args)
          expect(subject.parse('Foo/2016: R$100,00')).to be_nil
        end
      end
    end
  end
end
