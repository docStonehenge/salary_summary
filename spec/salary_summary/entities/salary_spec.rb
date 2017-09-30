require 'spec_helper'

module SalarySummary
  module Entities
    describe Salary do
      context 'can be initialized with any atributes' do
        it 'initializes only with amount' do
          subject = described_class.new(amount: 200)
          expect(subject.amount).to eql 200
          expect(subject.id).to be_nil
          expect(subject.period).to be_nil
        end

        it 'initializes only with period' do
          subject = described_class.new(period: Date.parse("29/09/2017"))
          expect(subject.period).to eql Date.parse("29/09/2017")
          expect(subject.id).to be_nil
          expect(subject.amount).to be_nil
        end

        it 'initializes only with amount and period' do
          subject = described_class.new(amount: 200, period: Date.parse('27/10/2018'))
          expect(subject.id).to be_nil
          expect(subject.period).to eql Date.parse('27/10/2018')
          expect(subject.amount).to eql 200
        end
      end

      subject { described_class.new(id: 123, amount: 200.0, period: Date.parse('January, 2016')) }

      context 'attributes' do
        describe '.field_list' do
          it 'returns attributes collection set for accessors' do
            expect(described_class.fields_list).to eql [:id, :amount, :period]
          end
        end

        it { is_expected.to have_attributes(id: 123, amount: 200.0, period: Date.parse('January, 2016')) }

        it { is_expected.to respond_to(:id=) }
        it { is_expected.to respond_to(:amount=) }
        it { is_expected.to respond_to(:period=) }

        it '#_id' do
          expect(subject._id).to eql subject.id
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
        context 'when subject has no id' do
          before { allow(subject).to receive(:id).and_return nil }

          it 'raises comparison error on less than' do
            expect {
              subject < described_class.new(id: 124, amount: 200.0, period: Date.parse('January, 2016'))
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on greater than' do
            expect {
              subject > described_class.new(id: 124, amount: 200.0, period: Date.parse('January, 2016'))
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on less than or equal' do
            expect {
              subject <= described_class.new(id: 124, amount: 200.0, period: Date.parse('January, 2016'))
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on greater than or equal' do
            expect {
              subject >= described_class.new(id: 124, amount: 200.0, period: Date.parse('January, 2016'))
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end
        end

        context 'when other object has no id' do
          before do
            @other_salary = described_class.new(
              amount: 200.0, period: Date.parse('January, 2016')
            )
          end

          it 'raises comparison error on less than' do
            expect {
              subject < @other_salary
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on greater than' do
            expect {
              subject > @other_salary
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on less than or equal' do
            expect {
              subject <= @other_salary
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end

          it 'raises comparison error on greater than or equal' do
            expect {
              subject >= @other_salary
            }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
          end
        end

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
    end
  end
end
