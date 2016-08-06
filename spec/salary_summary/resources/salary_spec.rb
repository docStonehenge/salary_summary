require 'spec_helper'

module SalarySummary
  module Resources
    describe Salary do
      subject { described_class.new(amount: 200.0, period: 'January, 2016') }

      context 'attributes' do
        it { is_expected.to have_attributes(id: nil, amount: 200.0, period: Date.parse('January, 2016')) }
      end

      describe '#year' do
        it 'returns the year of the current salary' do
          expect(subject.year).to eql 2016
        end
      end

      describe '#month' do
        it 'returns the month name of the current salary' do
          expect(subject.month).to eql 'January'
        end
      end
    end
  end
end
