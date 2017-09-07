require 'spec_helper'

module SalarySummary
  describe Registry do
    subject { described_class.instance }

    it { is_expected.to have_attributes(salaries: {}) }

    describe '#set instance' do
      it 'adds instance argument into its salaries map' do
        salary = Resources::Salary.new(id: 1, amount: 1400.0, period: Date.parse('07/09/2017'))

        subject.set(salary)

        expect(subject.salaries).to have_key(1)
        expect(subject.salaries.dig(1)).to equal salary
      end
    end

    describe '#get id' do
      context "when map doesn't contain id as key" do
        it 'returns nil' do
          result = subject.get(123)

          expect(result).to be_nil
        end
      end

      context 'when map contains id as key' do
        it 'returns object mapped by id key' do
          salary = Resources::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))
          subject.set(salary)

          result = subject.get(123)

          expect(result).to equal salary
        end
      end
    end
  end
end
