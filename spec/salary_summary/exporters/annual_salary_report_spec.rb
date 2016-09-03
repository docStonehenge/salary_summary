require 'spec_helper'

module SalarySummary
  module Exporters
    describe AnnualSalaryReport do
      let(:repository) { double(:repository) }
      let(:salary_1)   { double(:salary, month: 'January', year: 2016, amount: 100.0) }
      let(:salary_2)   { double(:salary, month: 'February', year: 2016, amount: 200.0) }

      let(:expected_report) do
        CSV.read('spec/support/test_file.csv')
      end

      let(:produced_report) do
        CSV.read("dump/salary_summary/salary_report_test.csv")
      end

      subject { described_class.new(repository) }

      describe '#export, report_file_name' do
        after do
          FileUtils.rm("dump/salary_summary/salary_report_test.csv")
        end

        it 'creates directory and saves file with all salaries and total amount' do
          expect(repository).to receive(:find_all).and_return [salary_1, salary_2]
          expect(repository).to receive(:sum).and_return 300.0

          subject.export('salary_report_test')

          expect(produced_report).to eql expected_report
        end
      end
    end
  end
end
