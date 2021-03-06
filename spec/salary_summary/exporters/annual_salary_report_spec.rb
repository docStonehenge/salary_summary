require 'spec_helper'

module SalarySummary
  module Exporters
    describe AnnualSalaryReport do
      let(:repository) { double(:repository) }
      let(:salary_1)   { double(:salary, month: 'January', year: 2016, amount: 100.0) }
      let(:salary_2)   { double(:salary, month: 'February', year: 2016, amount: 200.0) }

      subject { described_class.new(repository) }

      describe '#export, report_file_name' do
        before do
          expect(repository).to receive(:find_all).with(
                                  sorted_by: { period: 1 }
                                ).and_return [salary_1, salary_2]

          expect(repository).to receive(:sum_by_amount).and_return 300.0
        end

        it 'creates directory and saves file with all salaries and total amount' do
          file = double(:file)

          expect(File).to receive(:open).once.with(
                            'dump/salary_summary/report-name.csv', 'w'
                          ).and_yield file

          expect(file).to receive(:puts).once.with('January/2016, 100.0')
          expect(file).to receive(:puts).once.with('February/2016, 200.0')

          expect(file).to receive(:puts).once.with('Total, 300.0')

          subject.export('report-name')
        end

        context 'integration test', integration: true do
          let(:expected_report) do
            CSV.read('spec/support/test_file.csv')
          end

          let(:produced_report) do
            CSV.read("dump/salary_summary/salary_report_test.csv")
          end

          it 'creates directory and saves file with all salaries and total amount' do
            subject.export('salary_report_test')

            expect(produced_report).to eql expected_report
          end

          after do
            FileUtils.rm("dump/salary_summary/salary_report_test.csv")
          end
        end
      end
    end
  end
end
