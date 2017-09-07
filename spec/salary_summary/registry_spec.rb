require 'spec_helper'

module SalarySummary
  describe Registry do
    subject { described_class.instance }

    it { is_expected.to have_attributes(salaries: {}) }

    describe '.salaries_list' do
      it 'returns singleton instance salaries map as an array of salaries' do
        salary = Resources::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

        allow(subject).to receive(:salaries).and_return(123 => salary)

        expect(described_class.salaries_list).to contain_exactly(salary)
      end

      it 'returns singleton instance salaries map as empty array' do
        allow(subject).to receive(:salaries).and_return({})

        expect(described_class.salaries_list).to be_empty
      end
    end

    describe '.salaries' do
      it 'returns singleton instance salaries map' do
        expect(described_class.salaries).to eql subject.salaries
      end
    end

    describe '.set object' do
      it 'uses singleton instance and sets argument into its map' do
        allow(subject).to receive(:salaries).and_return({})

        salary = Resources::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

        described_class.set(salary)

        expect(subject.salaries.size).to eql 1
        expect(subject.salaries).to have_key(123)
        expect(subject.salaries.dig(123)).to equal salary
      end
    end

    describe '.get id' do
      context "when map doesn't contain id as key" do
        it 'returns nil' do
          result = described_class.get(123)

          expect(result).to be_nil
        end
      end

      context 'when map contains id as key' do
        it 'returns object mapped by id key' do
          salary = Resources::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

          allow(subject).to receive(:salaries).once.and_return(123 => salary)

          result = described_class.get(123)

          expect(result).to equal salary
        end
      end
    end

    describe '#set instance' do
      it 'adds instance argument into its salaries map' do
        allow(subject).to receive(:salaries).and_return({})

        salary = Resources::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

        subject.set(salary)

        expect(subject.salaries.size).to eql 1
        expect(subject.salaries).to have_key(123)
        expect(subject.salaries.dig(123)).to equal salary
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
          allow(subject).to receive(:salaries).once.and_return(123 => salary)

          result = subject.get(123)

          expect(result).to equal salary
        end
      end
    end
  end
end
