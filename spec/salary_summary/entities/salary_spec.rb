require 'spec_helper'

module SalarySummary
  module Entities
    describe Salary do
      let(:id) { BSON::ObjectId.new }

      it_behaves_like 'a Salary entity with document role'

      subject { described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016')) }

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
