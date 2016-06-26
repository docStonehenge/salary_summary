require 'spec_helper'

module SalarySummary
  module Interpreters
    describe SalaryReportInterpreter do
      it { is_expected.to have_attributes(entries: {}, sum: 0) }

      describe '#read_from_file file_name' do
        before do
          FileUtils.mkdir("#{Dir.home}/salary_summary")
          File.open("#{Dir.home}/salary_summary/test.csv", 'w') do |f|
            f.puts 'January, 200.0'
            f.puts 'February, 200.0'
            f.puts 'Annual Salary, 400.0'
          end
        end

        after do
          FileUtils.remove_dir("#{Dir.home}/salary_summary")
        end

        it 'reads csv file based on file name and passes information to calculator' do
          subject.read_from_file('test')
          expect(subject.entries).to include january: 200.0, february: 200.0
          expect(subject.entries).not_to include :"Annual Salary" => 400.0
          expect(subject.sum).to eql 400.0
        end
      end
    end
  end
end
