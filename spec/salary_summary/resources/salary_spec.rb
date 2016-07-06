require 'spec_helper'

module SalarySummary
  module Resources
    describe Salary do
      subject { described_class.new(amount: 200.0, period: 'January') }

      context 'attributes' do
        it { is_expected.to have_attributes(id: nil, amount: 200.0, period: 'January') }
      end
    end
  end
end
