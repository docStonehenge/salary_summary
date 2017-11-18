require 'spec_helper'

module SalarySummary
  module Persistence
    module Entities
      describe Registry do
        it { is_expected.to have_attributes(entities: {}) }

        describe '#add entity' do
          it 'adds entity object to entities hash, with key as class name and database ID' do
            salary = SalarySummary::Entities::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            expect(subject.entities.size).to eql 1
            expect(subject.entities).to have_key("salarysummary::entities::salary>>123")

            expect(
              subject.entities.dig("salarysummary::entities::salary>>123")
            ).to equal salary
          end

          it "doesn't add another object with same ID and class when already present" do
            salary = SalarySummary::Entities::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            another_salary = SalarySummary::Entities::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(another_salary)

            expect(subject.entities.size).to eql 1
            expect(subject.entities).to have_key("salarysummary::entities::salary>>123")

            expect(
              subject.entities.dig("salarysummary::entities::salary>>123")
            ).not_to equal another_salary

            expect(
              subject.entities.dig("salarysummary::entities::salary>>123")
            ).to equal salary
          end

          it 'adds another entity object with same ID but different class' do
            id = BSON::ObjectId.new
            salary = SalarySummary::Entities::Salary.new(id: id, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            SalarySummary::Entities::AnotherEntity = Struct.new(:id)

            other_entity = SalarySummary::Entities::AnotherEntity.new(id)

            subject.add(other_entity)

            expect(subject.entities.size).to eql 2
            expect(subject.entities).to have_key("salarysummary::entities::salary>>#{id}")
            expect(subject.entities).to have_key("salarysummary::entities::anotherentity>>#{id}")

            expect(
              subject.entities.dig("salarysummary::entities::salary>>#{id}")
            ).to equal salary

            expect(
              subject.entities.dig("salarysummary::entities::anotherentity>>#{id}")
            ).to equal other_entity
          end

          it 'adds two objects of same entity and different IDs' do
            salary = SalarySummary::Entities::Salary.new(id: 123, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            other_salary = SalarySummary::Entities::Salary.new(id: 124, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(other_salary)

            expect(subject.entities.size).to eql 2
            expect(subject.entities).to have_key("salarysummary::entities::salary>>123")
            expect(subject.entities).to have_key("salarysummary::entities::salary>>124")

            expect(
              subject.entities.dig("salarysummary::entities::salary>>123")
            ).to equal salary

            expect(
              subject.entities.dig("salarysummary::entities::salary>>124")
            ).to equal other_salary
          end
        end

        describe '#get class_name, id' do
          it 'returns class_name entity object found by ID' do
            salary = SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            expect(
              subject.get(SalarySummary::Entities::Salary, salary.id)
            ).to equal salary
          end

          it 'returns class_name entity object found by ID, with name as string' do
            salary = SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            expect(
              subject.get('SalarySummary::Entities::Salary', salary.id)
            ).to equal salary
          end

          it 'returns nil if no object is found' do
            expect(
              subject.get('SalarySummary::Entities::Salary', BSON::ObjectId.new)
            ).to be_nil
          end
        end

        describe '#include? entity' do
          it 'is true if entities map has entity by class name and ID' do
            salary = SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            expect(subject.include?(salary)).to be true
          end

          it 'is false if entity is not found' do
            expect(
              subject.include?(
                SalarySummary::Entities::Salary.new(
                  id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017')
                )
              )
            ).to be false
          end
        end

        describe '#delete entity' do
          it 'removes entity from entities map and returns it' do
            salary = SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new, amount: 1400.0, period: Date.parse('07/09/2017'))

            subject.add(salary)

            expect(subject.delete(salary)).to eql salary
          end

          it 'returns nil if no entity was removed' do
            expect(
              subject.delete(SalarySummary::Entities::Salary.new(id: BSON::ObjectId.new))
            ).to be_nil
          end
        end
      end
    end
  end
end
