require 'spec_helper'

module SalarySummary
  module Calculators
    describe AnnualSalaryCalculator do
      let(:january) { double(:salary, period: 'January', amount: 1000.0) }

      it { is_expected.to have_attributes salaries: {}, total_amount: 0 }

      describe '#enqueue salary' do
        it 'appends a salary to its hash with period as key' do
          subject.enqueue january

          expect(subject.salaries).to include january: 1000.0
        end
      end

      describe '#sum!' do
        it 'sums up all salaries amounts' do
          allow(subject).to receive(:salaries).and_return(
                              january: 1000.0, february: 1550.0
                            )

          subject.sum!

          expect(subject.total_amount).to eql 2550.0
        end
      end
    end
  end
end
