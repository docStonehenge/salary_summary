require 'spec_helper'

module SalarySummary
  module Databases
    module MongoDB
      describe AggregationWrapper do
        it { is_expected.to have_attributes(stages: []) }

        describe '#project specifications' do
          it 'puts a Hash with $project key pointing to specifications into stages' do
            subject.project(foo: true)
            expect(subject.stages).to include(:$project => { foo: true })
          end
        end

        describe '#match specifications' do
          it 'puts a Hash with $match key pointing to specifications into stages' do
            subject.match(foo: 'name')
            expect(subject.stages).to include(:$match => { foo: 'name' })
          end
        end

        describe '#redact specifications' do
          it 'puts a Hash with $redact key pointing to specifications into stages' do
            subject.redact(foo: 'name')
            expect(subject.stages).to include(:$redact => { foo: 'name' })
          end
        end

        describe '#limit specifications' do
          it 'puts a Hash with $limit key pointing to limit number into stages' do
            subject.limit(3)
            expect(subject.stages).to include(:$limit => 3)
          end
        end

        describe '#skip specifications' do
          it 'puts a Hash with $skip key pointing to skip number into stages' do
            subject.skip(3)
            expect(subject.stages).to include(:$skip => 3)
          end
        end

        describe '#unwind field_name' do
          it 'puts a Hash with $unwind key pointing to unwinding field into stages' do
            subject.unwind(:field)
            expect(subject.stages).to include(:$unwind => '$field')
          end
        end

        describe '#group expression_id, grouping_expression' do
          it 'puts a Hash with $group key pointing to group process into stages' do
            subject.group(
              { period: '$date_of_birth' },
              { avg_salary: { '$avg' => '$amount' } }
            )

            expect(subject.stages).to include(
                                        :$group => {
                                          _id: { period: '$date_of_birth' },
                                          avg_salary: { '$avg' => '$amount' }
                                        }
                                      )
          end
        end

        describe '#sample sample_size' do
          it 'puts a Hash with $sample key pointing to sizing document into stages' do
            subject.sample(3)
            expect(subject.stages).to include(:$sample => { size: 3 })
          end
        end

        describe '#sort specifications' do
          it 'puts a Hash with $sort key pointing to sorting document into stages' do
            subject.sort(field1: -1)
            expect(subject.stages).to include(:$sort => { field1: -1 })
          end
        end
      end
    end
  end
end
