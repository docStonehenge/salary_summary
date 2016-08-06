require 'spec_helper'

module SalarySummary
  module Builders
    describe TableBuilder do
      let(:repository) { double(:repository) }
      let(:salary_1)   { double(:salary, month: 'January', year: 2016, amount: 200.0) }
      let(:salary_2)   { double(:salary, month: 'February', year: 2016, amount: 250.0) }

      before do
        $stdout = File.open(File::NULL)
      end

      subject { described_class.new(repository) }

      describe '#build_entries' do
        it 'prints each entry on the table' do
          expect(repository).to receive(:find).and_return [salary_1, salary_2]

          expect {
            subject.build_entries
          }.to output(
                 "January, 2016 ---- 200.0\nFebruary, 2016 ---- 250.0\n"
               ).to_stdout
        end
      end

      describe '#build_sum_footer' do
        it 'prints sum information footer on table' do
          expect(repository).to receive(:sum).and_return 450.0

          expect {
            subject.build_sum_footer
          }.to output("Total ---- 450.0\n").to_stdout
        end
      end
    end
  end
end
