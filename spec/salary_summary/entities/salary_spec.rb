require 'spec_helper'

module SalarySummary
  module Entities
    describe Salary do
      let(:uow) { double(:uow) }
      let!(:id) { BSON::ObjectId.new }

      it '.repository' do
        expect(described_class.repository).to eql Repositories::SalariesRepository
      end

      context 'can be initialized with any atributes' do
        it 'can be initialized without any attributes' do
          subject = described_class.new

          expect(subject.amount).to be_nil
          expect(subject.id).to be_nil
          expect(subject.period).to be_nil
        end

        context 'with symbol keys' do
          it 'initializes only with amount' do
            subject = described_class.new(amount: 200)
            expect(subject.amount).to eql BigDecimal.new(200)
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
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as '_id'" do
            subject = described_class.new(_id: id, amount: 200, period: Date.parse('27/10/2018'))
            expect(subject.id).to eql id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as 'id'" do
            subject = described_class.new(id: id, amount: 200, period: Date.parse('27/10/2018'))
            expect(subject.id).to eql id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as 'id' and '_id'" do
            another_id = BSON::ObjectId.new
            subject = described_class.new(id: id, _id: another_id, amount: 200, period: Date.parse('27/10/2018'))
            expect(subject.id).to eql another_id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end
        end

        context 'with string keys' do
          it 'initializes only with amount' do
            subject = described_class.new('amount' => 200)
            expect(subject.amount).to eql BigDecimal.new(200)
            expect(subject.id).to be_nil
            expect(subject.period).to be_nil
          end

          it 'initializes only with period' do
            subject = described_class.new('period' => Date.parse("29/09/2017"))
            expect(subject.period).to eql Date.parse("29/09/2017")
            expect(subject.id).to be_nil
            expect(subject.amount).to be_nil
          end

          it 'initializes only with amount and period' do
            subject = described_class.new('amount' => 200, 'period' => Date.parse('27/10/2018'))
            expect(subject.id).to be_nil
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as '_id'" do
            subject = described_class.new('_id' => id, 'amount' => 200, 'period' => Date.parse('27/10/2018'))
            expect(subject.id).to eql id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as 'id'" do
            subject = described_class.new('id' => id, 'amount' => 200, 'period' => Date.parse('27/10/2018'))
            expect(subject.id).to eql id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end

          it "initializes with id key as 'id' and '_id'" do
            another_id = BSON::ObjectId.new
            subject = described_class.new('id' => id, '_id' => another_id, 'amount' => 200, 'period' => Date.parse('27/10/2018'))
            expect(subject.id).to eql another_id
            expect(subject.period).to eql Date.parse('27/10/2018')
            expect(subject.amount).to eql BigDecimal.new(200)
          end
        end
      end

      subject { described_class.new(id: id, amount: 200.0, period: Date.parse('January, 2016')) }

      context 'attributes' do
        let(:field) { double(:field) }

        describe '.field name, type:' do
          context 'when field is ID' do
            it 'defines getter and setter for field, converting field only' do
              expect(described_class).to receive(:attr_reader).once.with(:id)
              expect(described_class.fields_list).to receive(:push).once.with(:id)
              expect(described_class.fields).to receive(:[]=).once.with(:id, { type: BSON::ObjectId })

              expect(described_class).to receive(:instance_eval).once.and_yield

              expect(described_class).to receive(
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
                described_class
              ).to receive(:instance_variable_set).once.with(:"@id", id)

              described_class.field(:id, type: BSON::ObjectId)
            end
          end

          context 'when field is any other than ID' do
            let(:value) { 123 }

            before do
              expect(described_class).to receive(:attr_reader).once.with(:foo)
              expect(described_class).to receive(:instance_eval).once.and_yield

              expect(described_class).to receive(
                                           :define_method
                                         ).once.with("foo=").and_yield value

              expect(
                Persistence::Entities::Field
              ).to receive(:new).once.with(
                     type: Integer, value: value
                   ).and_return field

              expect(field).to receive(:coerce).once.and_return value

              expect(
                described_class
              ).to receive(:instance_variable_set).once.with(:"@foo", value)

              expect(described_class.fields_list).to receive(:push).once.with(:foo)
              expect(described_class.fields).to receive(:[]=).once.with(:foo, { type: Integer })
            end

            it 'defines getter, setter, converting field and registering object into UnitOfWork' do
              expect(
                Persistence::UnitOfWork
              ).to receive(:current).once.and_return uow

              expect(uow).to receive(:register_changed).once

              described_class.field(:foo, type: Integer)
            end

            context 'when current UnitOfWork is not started' do
              it 'defines getter, setter, converting field only' do
                expect(
                  Persistence::UnitOfWork
                ).to receive(:current).once.and_raise Persistence::UnitOfWorkNotStartedError

                described_class.field(:foo, type: Integer)
              end
            end
          end
        end

        describe '.fields_list' do
          it 'returns attributes collection set for accessors' do
            expect(described_class.fields_list).to eql [:id, :amount, :period]
          end
        end

        describe '.fields' do
          it 'returns attributes specifications correctly' do
            expect(described_class.fields).to eql(
                                                id: { type: BSON::ObjectId },
                                                amount: { type: BigDecimal },
                                                period: { type: Date }
                                              )
          end
        end

        it { is_expected.to have_attributes(id: id, amount: BigDecimal.new("200.0"), period: Date.parse('January, 2016')) }

        describe '#id= id' do
          it 'just sets ID value on object' do
            expect(Persistence::UnitOfWork).not_to receive(:current)
            subject.id = id

            expect(subject.id).to eql id
          end
        end

        describe '#_id= id' do
          it 'just sets ID value on object' do
            expect(Persistence::UnitOfWork).not_to receive(:current)
            subject._id = id

            expect(subject._id).to eql id
            expect(subject.id).to eql id
          end
        end

        describe '#amount= value' do
          it 'sets attribute value and registers entity as changed on current UnitOfWork' do
            expect(Persistence::UnitOfWork).to receive(:current).once.and_return uow
            expect(uow).to receive(:register_changed).once.with(subject)

            subject.amount = 420

            expect(subject.amount).to eql BigDecimal.new('420')
          end

          it 'just sets attribute value when call to current UnitOfWork raises error' do
            expect(
              Persistence::UnitOfWork
            ).to receive(:current).once.and_raise(Persistence::UnitOfWorkNotStartedError)

            subject.amount = 420

            expect(subject.amount).to eql BigDecimal.new('420')
          end
        end

        describe '#period= value' do
          let(:period) { Date.parse('13/11/2017') }

          it 'sets attribute value and registers entity as changed on current UnitOfWork' do
            expect(Persistence::UnitOfWork).to receive(:current).once.and_return uow
            expect(uow).to receive(:register_changed).once.with(subject)

            subject.period = period

            expect(subject.period).to eql period
          end

          it 'just sets attribute value when call to current UnitOfWork raises error' do
            expect(
              Persistence::UnitOfWork
            ).to receive(:current).once.and_raise(Persistence::UnitOfWorkNotStartedError)

            subject.period = period

            expect(subject.period).to eql period
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
