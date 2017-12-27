require 'spec_helper'

module SalarySummary
  module Persistence
    module DocumentDefinitions
      describe Base do
        let(:uow) { double(:uow) }
        let!(:id) { BSON::ObjectId.new }

        describe 'ClassMethods' do
          subject { Class.new { include Base } }

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
                    Entities::Field
                  ).to receive(:new).once.with(
                         type: BSON::ObjectId, value: id
                       ).and_return field

                  expect(field).to receive(:coerce).once.and_return id

                  expect(
                    subject
                  ).to receive(:instance_variable_set).once.with(:"@id", id).and_return id

                  expect(subject.define_field(:id, type: BSON::ObjectId)).to eql id
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
                    Entities::Field
                  ).to receive(:new).once.with(
                         type: Integer, value: value
                       ).and_return field

                  expect(field).to receive(:coerce).once.and_return value

                  expect(
                    subject
                  ).to receive(:instance_variable_set).once.with(:"@foo", value).and_return value

                  expect(subject.fields_list).to receive(:push).once.with(:foo)
                  expect(subject.fields).to receive(:[]=).once.with(:foo, { type: Integer })
                end

                it 'defines getter, setter, converting field and registering object into UnitOfWork' do
                  expect(
                    subject
                  ).to receive(:instance_variable_get).once.with(:"@foo").and_return nil

                  expect(
                    Persistence::UnitOfWork
                  ).to receive(:current).once.and_return uow

                  expect(uow).to receive(:register_changed).once

                  expect(subject.define_field(:foo, type: Integer)).to eql value
                end

                context "when field value doesn't change" do
                  it 'defines getter and setter for field; setter does not register on UnitOfWork' do
                    expect(
                      subject
                    ).to receive(:instance_variable_get).once.with(:"@foo").and_return value

                    expect(Persistence::UnitOfWork).not_to receive(:current)

                    expect(subject.define_field(:foo, type: Integer)).to eql value
                  end
                end

                context 'when current UnitOfWork is not started' do
                  it 'defines getter, setter, converting field only' do
                    expect(
                      subject
                    ).to receive(:instance_variable_get).once.with(:"@foo").and_return nil

                    expect(
                      Persistence::UnitOfWork
                    ).to receive(:current).once.and_raise Persistence::UnitOfWorkNotStartedError

                    expect(subject.define_field(:foo, type: Integer)).to eql value
                  end
                end
              end
            end
          end
        end

        describe 'InstanceMethods' do
          class TestEntity
            include Base

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
                  subject < described_class.new(id: id, first_name: 'John', dob: Date.parse('1990/01/01'))
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on greater than' do
                expect {
                  subject > described_class.new(id: id, first_name: 'John', dob: Date.parse('1990/01/01'))
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on less than or equal' do
                expect {
                  subject <= described_class.new(id: id, first_name: 'John', dob: Date.parse('1990/01/01'))
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on greater than or equal' do
                expect {
                  subject >= described_class.new(id: id, first_name: 'John', dob: Date.parse('1990/01/01'))
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end
            end

            context 'when other object has no id' do
              before do
                @other_entity = described_class.new(
                  first_name: 'John', dob: Date.parse('1990/01/01')
                )
              end

              it 'raises comparison error on less than' do
                expect {
                  subject < @other_entity
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on greater than' do
                expect {
                  subject > @other_entity
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on less than or equal' do
                expect {
                  subject <= @other_entity
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end

              it 'raises comparison error on greater than or equal' do
                expect {
                  subject >= @other_entity
                }.to raise_error(
                       SalarySummary::Entities::ComparisonError, "Cannot compare with an entity that isn't persisted."
                     )
              end
            end

            it 'compares less than with other entity by id' do
              expect(
                subject
              ).to be < described_class.new(id: BSON::ObjectId.new, first_name: 'John', dob: Date.parse('1990/01/01'))
            end

            it 'compares greater than with other entity by id' do
              another_entity = described_class.new(id: BSON::ObjectId.new, first_name: 'John', dob: Date.parse('1990/01/01'))
              expect(subject).to be > another_entity
            end

            it 'compares less than or equal to with other entity by id' do
              expect(
                subject
              ).to be <= described_class.new(id: BSON::ObjectId.new, first_name: 'John', dob: Date.parse('1990/01/01'))
            end

            it 'compares greater than or equal to with other entity by id' do
              another_entity = described_class.new(id: BSON::ObjectId.new, first_name: 'John', dob: Date.parse('1990/01/01'))
              expect(subject).to be >= another_entity
            end
          end

          describe '#to_hash include_id_field: true' do
            subject { described_class.new(id: id, first_name: 'John', dob: Date.parse('1990/01/01')) }

            context 'when ID field is included' do
              it 'returns fields names and values mapped into a Hash' do
                expect(
                  subject.to_hash
                ).to eql(id: id, first_name: 'John', dob: Date.parse('1990/01/01'))
              end
            end

            context 'when ID field is not included' do
              it 'returns fields names and values mapped into a Hash, without ID' do
                expect(
                  subject.to_hash(include_id_field: false)
                ).to eql(first_name: 'John', dob: Date.parse('1990/01/01'))
              end
            end
          end

          describe '#to_mongo_document' do
            class EntityWithAllValues
              include Base

              define_field :field1, type: String
              define_field :field2, type: Integer
              define_field :field3, type: Float
              define_field :field4, type: BigDecimal
              define_field :field5, type: SalarySummary::Boolean
              define_field :field6, type: Array
              define_field :field7, type: Hash
              define_field :field8, type: BSON::ObjectId
              define_field :field9, type: Date
              define_field :field10, type: DateTime
              define_field :field11, type: Time
            end

            subject do
              EntityWithAllValues.new(
                id: id,
                field1: "Foo",
                field2: 123,
                field3: 123.0,
                field4: BigDecimal.new("123.0"),
                field5: true,
                field6: [123, BigDecimal.new("200")],
                field7: { foo: Date.parse("01/01/1990"), 'bazz' => BigDecimal.new(400) },
                field8: id,
                field9: Date.parse('01/01/1990'),
                field10: DateTime.new(2017, 11, 21),
                field11: Time.new(2017, 11, 21)
              )
            end

            it "maps fields names and values, with mongo permitted values and '_id' field" do
              expect(
                subject.to_mongo_document
              ).to eql(
                     _id: id,
                     field1: "Foo",
                     field2: 123,
                     field3: 123.0,
                     field4: "0.123E3",
                     field5: true,
                     field6: [123, "0.2E3"],
                     field7: { foo: Date.parse("01/01/1990"), 'bazz' => '0.4E3' },
                     field8: id,
                     field9: Date.parse('01/01/1990'),
                     field10: DateTime.new(2017, 11, 21),
                     field11: Time.new(2017, 11, 21)
                   )
            end

            it "maps fields names and values, with mongo permitted values, without '_id' field" do
              expect(
                subject.to_mongo_document(include_id_field: false)
              ).to eql(
                     field1: "Foo",
                     field2: 123,
                     field3: 123.0,
                     field4: "0.123E3",
                     field5: true,
                     field6: [123, "0.2E3"],
                     field7: { foo: Date.parse("01/01/1990"), 'bazz' => '0.4E3' },
                     field8: id,
                     field9: Date.parse('01/01/1990'),
                     field10: DateTime.new(2017, 11, 21),
                     field11: Time.new(2017, 11, 21)
                   )
            end
          end
        end
      end
    end
  end
end