require 'spec_helper'

module SalarySummary
  module Entities
    module Roles
      describe BaseDocument do
        let(:uow) { double(:uow) }
        let!(:id) { BSON::ObjectId.new }

        describe 'ClassMethods' do
          subject { Class.new { include BaseDocument } }

          it 'defines ID field' do
            expect(subject.new).to have_id_defined
          end

          describe '.repository' do
            it 'raises NotImplementedError' do
              expect {
                subject.repository
              }.to raise_error(NotImplementedError)
            end
          end

          context 'attributes' do
            let(:field) { double(:field) }

            describe '.define_field name, type:' do
              context 'when field is ID' do
                it 'defines getter and setter for field, converting field only' do
                  expect(subject).to receive(:attr_reader).once.with(:id)
                  expect(subject.fields_list).to receive(:push).once.with(:id)
                  expect(subject.fields).to receive(:[]=).once.with(:id, { type: BSON::ObjectId })

                  expect(subject).to receive(:instance_eval).once.and_yield

                  expect(subject).to receive(
                                       :define_method
                                     ).once.with("id=").and_yield id

                  expect(Persistence::UnitOfWork).not_to receive(:current)

                  expect(
                    Persistence::Entities::Field
                  ).to receive(:new).once.with(
                         type: BSON::ObjectId, value: id
                       ).and_return field

                  expect(field).to receive(:coerce).once.and_return id

                  expect(
                    subject
                  ).to receive(:instance_variable_set).once.with(:"@id", id)

                  subject.define_field(:id, type: BSON::ObjectId)
                end
              end

              context 'when field is any other than ID' do
                let(:value) { 123 }

                before do
                  expect(subject).to receive(:attr_reader).once.with(:foo)
                  expect(subject).to receive(:instance_eval).once.and_yield

                  expect(subject).to receive(
                                       :define_method
                                     ).once.with("foo=").and_yield value

                  expect(
                    Persistence::Entities::Field
                  ).to receive(:new).once.with(
                         type: Integer, value: value
                       ).and_return field

                  expect(field).to receive(:coerce).once.and_return value

                  expect(
                    subject
                  ).to receive(:instance_variable_set).once.with(:"@foo", value)

                  expect(subject.fields_list).to receive(:push).once.with(:foo)
                  expect(subject.fields).to receive(:[]=).once.with(:foo, { type: Integer })
                end

                it 'defines getter, setter, converting field and registering object into UnitOfWork' do
                  expect(
                    Persistence::UnitOfWork
                  ).to receive(:current).once.and_return uow

                  expect(uow).to receive(:register_changed).once

                  subject.define_field(:foo, type: Integer)
                end

                context 'when current UnitOfWork is not started' do
                  it 'defines getter, setter, converting field only' do
                    expect(
                      Persistence::UnitOfWork
                    ).to receive(:current).once.and_raise Persistence::UnitOfWorkNotStartedError

                    subject.define_field(:foo, type: Integer)
                  end
                end
              end
            end
          end
        end

        describe 'InstanceMethods' do
          class TestEntity
            include BaseDocument

            define_field :first_name, type: String
            define_field :dob,        type: Date
          end

          let(:described_class) { TestEntity }

          context 'can be initialized with any atributes' do
            it 'can be initialized without any attributes' do
              subject = described_class.new

              expect(subject.id).to be_nil
              expect(subject.first_name).to be_nil
              expect(subject.dob).to be_nil
            end

            context 'with symbol keys' do
              it 'initializes only with one attribute' do
                subject = described_class.new(first_name: "John")
                expect(subject.first_name).to eql 'John'
                expect(subject.id).to be_nil
                expect(subject.dob).to be_nil
              end

              it 'initializes without ID' do
                subject = described_class.new(first_name: 'John', dob: Date.parse('27/10/1990'))
                expect(subject.id).to be_nil
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as '_id'" do
                subject = described_class.new(id: id, first_name: 'John', dob: Date.parse('27/10/1990'))

                expect(subject.id).to eql id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as 'id'" do
                subject = described_class.new(_id: id, first_name: 'John', dob: Date.parse('27/10/1990'))

                expect(subject.id).to eql id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as 'id' and '_id'" do
                another_id = BSON::ObjectId.new
                subject = described_class.new(id: id, _id: another_id, first_name: 'John', dob: Date.parse('27/10/1990'))

                expect(subject.id).to eql another_id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end
            end

            context 'with string keys' do
              it 'initializes only with one attribute' do
                subject = described_class.new('first_name' => 'John')
                expect(subject.first_name).to eql 'John'
                expect(subject.id).to be_nil
                expect(subject.dob).to be_nil
              end

              it 'initializes only without ID' do
                subject = described_class.new('first_name' => 'John', 'dob' => Date.parse('27/10/1990'))
                expect(subject.id).to be_nil
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as '_id'" do
                subject = described_class.new('_id' => id, 'first_name' => 'John', 'dob' => Date.parse('27/10/1990'))

                expect(subject.id).to eql id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as 'id'" do
                subject = described_class.new('id' => id, 'first_name' => 'John', 'dob' => Date.parse('27/10/1990'))

                expect(subject.id).to eql id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end

              it "initializes with id key as 'id' and '_id'" do
                another_id = BSON::ObjectId.new
                subject = described_class.new('id' => id, '_id' => another_id, 'first_name' => 'John', 'dob' => Date.parse('27/10/1990'))

                expect(subject.id).to eql another_id
                expect(subject.first_name).to eql 'John'
                expect(subject.dob).to eql Date.parse('27/10/1990')
              end
            end
          end

          describe '#<=> other' do
            subject { described_class.new(id: id) }

            context 'when subject has no id' do
              before { allow(subject).to receive(:id).and_return nil }

              it 'raises comparison error on less than' do
                expect {
                  subject < described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016'))
                }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
              end

              it 'raises comparison error on greater than' do
                expect {
                  subject > described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016'))
                }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
              end

              it 'raises comparison error on less than or equal' do
                expect {
                  subject <= described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016'))
                }.to raise_error(ComparisonError, "Cannot compare with an entity that isn't persisted.")
              end

              it 'raises comparison error on greater than or equal' do
                expect {
                  subject >= described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016'))
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
              ).to be < described_class.new(id: BSON::ObjectId.new, amount: 200.0, period: Date.parse('January, 2016'))
            end

            it 'compares greater than with other salary by id' do
              another_salary = described_class.new(id: BSON::ObjectId.new, amount: 200.0, period: Date.parse('January, 2016'))
              expect(subject).to be > another_salary
            end

            it 'compares less than or equal to with other salary by id' do
              expect(
                subject
              ).to be <= described_class.new(id: BSON::ObjectId.new, amount: 200.0, period: Date.parse('January, 2016'))
            end

            it 'compares greater than or equal to with other salary by id' do
              another_salary = described_class.new(id: BSON::ObjectId.new, amount: 200.0, period: Date.parse('January, 2016'))
              expect(subject).to be >= another_salary
            end
          end
        end
      end
    end
  end
end
