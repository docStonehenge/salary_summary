require 'spec_helper'

module SalarySummary
  module Exporters
    describe AnnualSalaryReport do
      let(:repository) { double(:repository) }

      let(:expected_report) do
        CSV.read('spec/support/test_file.csv')
      end

      let(:produced_report) do
        CSV.read("dump/salary_summary/salary_report_test.csv")
      end

      subject { described_class.new(repository) }

      describe '#save collection_name, report_file_name' do
        after do
          FileUtils.rm("dump/salary_summary/salary_report_test.csv")
        end

        it 'creates directory and saves file with all salaries and total amount' do
          expect(
            repository
          ).to receive(:find_on).with('salaries').and_return [
                 { '_id' => 1, 'period' => 'January', 'amount' => 100.0 },
                 { '_id' => 2, 'period' => 'February', 'amount' => 200.0 }
               ]

          expect(repository).to receive(:sum).with('salaries').and_return 300.0

          subject.save('salaries', 'salary_report_test')

          expect(produced_report).to eql expected_report
        end
      end
    end
  end
end
