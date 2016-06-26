require 'spec_helper'

module SalarySummary
  module Builders
    describe TableBuilder do
      let(:salary_container) { double(:container) }

      subject { described_class.new(salary_container) }

      before do
        $stdout = File.open(File::NULL)
      end

      describe '#build_entries' do
        it 'prints each entry on the table' do
          allow(salary_container).to receive(:salaries).and_return(
                                       january: 200.0, february: 250.0
                                     )

          expect {
            subject.build_entries
          }.to output(
                 "January----200.0\nFebruary----250.0\n"
               ).to_stdout
        end
      end

      describe '#build_sum_footer' do
        it 'prints sum information footer on table' do
          allow(salary_container).to receive(:total_amount).and_return 450.0

          expect {
            subject.build_sum_footer
          }.to output(
                 "Annual Salary----450.0\n"
               ).to_stdout
        end
      end
    end
  end
end
