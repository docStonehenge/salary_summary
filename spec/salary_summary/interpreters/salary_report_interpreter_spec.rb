require 'spec_helper'

module SalarySummary
  module Interpreters
    describe SalaryReportInterpreter do
      let(:calculator) { double(:calculator) }
      let(:january)    { double(:salary) }
      let(:february)   { double(:salary) }

      subject { described_class.new(calculator) }

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
          expect(Resources::Salary).to receive(:new).once.
                                        with(amount: 200.0, period: 'January').
                                        and_return january

          expect(Resources::Salary).to receive(:new).once.
                                        with(amount: 200.0, period: 'February').
                                        and_return february

          expect(calculator).to receive(:enqueue).with(january)
          expect(calculator).to receive(:enqueue).with(february)
          expect(calculator).to receive(:sum!).once

          subject.read_from_file('test')
        end
      end
    end
  end
end
