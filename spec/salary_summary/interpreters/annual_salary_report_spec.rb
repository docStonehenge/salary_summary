require 'spec_helper'

module SalarySummary
  module Interpreters
    describe AnnualSalaryReport do
      let(:calculator) { double(:calculator, total_amount: 300.0) }

      let(:expected_report) do
        CSV.read('spec/support/test_file.csv')
      end

      let(:produced_report) do
        CSV.read("dump/salary_summary/salary_report_test.csv")
      end

      subject { described_class.new(calculator) }

      describe '#save_as_simple_document' do
        after do
          FileUtils.rm("dump/salary_summary/salary_report_test.csv")
        end

        it 'creates directory and saves file with all salaries and total amount' do
          allow(calculator).to receive(:salaries).and_return(
                                 january: 100.0, february: 200.0
                               )

          subject.save_as_simple_document('salary_report_test')

          expect(produced_report).to eql expected_report
        end
      end
    end
  end
end
