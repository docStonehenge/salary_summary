require 'spec_helper'

module SalarySummary
  module Resources
    describe Salary do
      subject { described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016')) }

      context 'attributes' do
        it { is_expected.to have_attributes(id: 123, amount: 200.0, period: Date.parse('January, 2016'), comparable_key: :id) }

        it '#_id' do
          expect(subject._id).to eql subject.id
        end

        describe '#comparable_key=' do
          it 'sets new comparable key when value is a valid method on salary' do
            subject.comparable_key = :amount
            expect(subject.comparable_key).to eql :amount
          end

          it 'defaults to ID key when value is not a valid method on salary' do
            subject.comparable_key = :foo
            expect(subject.comparable_key).to eql :id
          end

          it 'does not change key when value is not a valid method on salary' do
            subject.comparable_key = :amount
            subject.comparable_key = :foo
            expect(subject.comparable_key).to eql :amount
          end
        end
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

      describe '#<=> other' do
        context 'using default comparable key' do
          it 'compares less than with other salary by id' do
            expect(
              subject
            ).to be < described_class.new(id: 124, amount: 200.0, period: Date.parse('January, 2016'))
          end

          it 'compares greater than with other salary by id' do
            expect(
              subject
            ).to be > described_class.new(id: 122, amount: 200.0, period: Date.parse('January, 2016'))
          end

          it 'compares less than or equal to with other salary by id' do
            expect(
              subject
            ).to be <= described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016'))
          end

          it 'compares greater than or equal to with other salary by id' do
            expect(
              subject
            ).to be >= described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016'))
          end
        end

        context 'using another comparable key' do
          before do
            subject.comparable_key = :amount
          end

          it 'compares less than with other salary' do
            expect(
              subject
            ).to be < described_class.new(id: 124, amount: 300.0, period: Date.parse('January, 2016'))
          end

          it 'compares greater than with other salary' do
            expect(
              subject
            ).to be > described_class.new(id: 122, amount: 150.0, period: Date.parse('January, 2016'))
          end

          it 'compares less than or equal to with other salary' do
            expect(
              subject
            ).to be <= described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016'))
          end

          it 'compares greater than or equal to with other salary' do
            expect(
              subject
            ).to be >= described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016'))
          end
        end
      end
    end
  end
end
