require 'spec_helper'

module SalarySummary
  module Calculators
    describe AnnualSalaryCalculator do
      let(:salary) { double(:salary, period: 'January', amount: 1000.0) }

      it { is_expected.to have_attributes salaries: {} }

      describe '#enqueue salary' do
        it 'appends a salary to its hash with period as key' do
          subject.enqueue salary

          expect(subject.salaries).to include january: 1000.0
        end
      end
    end
  end
end
