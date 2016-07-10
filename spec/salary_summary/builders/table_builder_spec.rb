require 'spec_helper'

module SalarySummary
  module Builders
    describe TableBuilder do
      let(:calculator) { double(:calculator) }

      before do
        $stdout = File.open(File::NULL)
      end

      describe '.build_entries collection_name' do
        it 'prints each entry on the table' do
          expect(
            Exporters::SalariesRepository
          ).to receive(:find_on).with('salaries').and_return [
                 { '_id' => 1, 'period' => 'January', 'amount' => 200.0 },
                 { '_id' => 2, 'period' => 'February', 'amount' => 250.0 }
               ]

          expect {
            described_class.build_entries_on('salaries')
          }.to output(
                 "January----200.0\nFebruary----250.0\n"
               ).to_stdout
        end
      end

      describe '.build_sum_footer_with calculator' do
        it 'prints sum information footer on table' do
          expect(calculator).to receive(:sum).and_return 450.0

          expect {
            described_class.build_sum_footer_with(calculator)
          }.to output(
                 "Annual Salary----450.0\n"
               ).to_stdout
        end
      end
    end
  end
end
