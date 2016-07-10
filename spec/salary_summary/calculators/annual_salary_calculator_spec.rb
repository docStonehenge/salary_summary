require 'spec_helper'

module SalarySummary
  module Calculators
    describe AnnualSalaryCalculator do
      let(:january) { double(:salary, period: 'January', amount: 1000.0) }

      subject { described_class.new(collection: 'salaries') }

      describe '#enqueue salary' do
        it 'saves the salary into the database for later use' do
          expect(Exporters::SalariesRepository).to receive(:save).with(january, 'salaries')
          subject.enqueue january
        end
      end

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
