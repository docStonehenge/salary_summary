require 'spec_helper'

module SalarySummary
  module Builders
    describe TableBuilder do
      let(:repository) { double(:repository) }
      let(:salary_1)   { double(:salary, period: 'January', amount: 200.0) }
      let(:salary_2)   { double(:salary, period: 'February', amount: 250.0) }

      before do
        $stdout = File.open(File::NULL)
      end

      subject { described_class.new(repository) }

      describe '#build_entries collection_name' do
        it 'prints each entry on the table' do
          expect(
            repository
          ).to receive(:find_on).with('salaries').and_return [salary_1, salary_2]


          expect {
            subject.build_entries_on('salaries')
          }.to output(
                 "January----200.0\nFebruary----250.0\n"
               ).to_stdout
        end
      end

      describe '#build_sum_footer_for collection_name' do
        it 'prints sum information footer on table' do
          expect(repository).to receive(:sum).with('salaries').and_return 450.0

          expect {
            subject.build_sum_footer_for('salaries')
          }.to output(
                 "Annual Salary----450.0\n"
               ).to_stdout
        end
      end
    end
  end
end