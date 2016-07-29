require 'spec_helper'

module SalarySummary
  module Calculators
    describe AnnualSalaryCalculator do
      subject { described_class.new(collection: 'salaries') }

      describe '#sum' do
        it 'sums up all salaries amounts using the repository' do
          expect(
            Exporters::SalariesRepository
          ).to receive(:sum).with('salaries').and_return 1000.0

          expect(subject.sum).to eql 1000.0
        end
      end
    end
  end
end
