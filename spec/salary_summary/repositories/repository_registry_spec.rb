require 'spec_helper'

module SalarySummary
  module Repositories
    describe RepositoryRegistry do
      let!(:repo) { ObjectRepository.new }

      describe '.[] class_name' do
        context 'when no registry is set yet on current Thread' do
          it 'calls new registry and returns the repository object set for class' do
            Thread.current.instance_variables.delete(:repositories)
            expect(described_class[Object]).to be_an_instance_of ObjectRepository
          end
        end

        it 'returns the repository object set for entity class' do
          expect(described_class[Object]).to be_an_instance_of ObjectRepository
        end

        it 'returns the repository object set for entity class string' do
          expect(described_class['Object']).to be_an_instance_of ObjectRepository
        end

        it 'returns the repository object set for class name' do
          expect(
            described_class[ObjectRepository]
          ).to be_an_instance_of ObjectRepository
        end

        it 'returns the repository object set for class name string' do
          expect(
            described_class['ObjectRepository']
          ).to be_an_instance_of ObjectRepository
        end

        it 'returns always the same repository object for class' do
          repository = described_class[Object]

          expect(described_class[Object]).to equal repository
          expect(described_class[ObjectRepository]).to equal repository
          expect(described_class['Object']).to equal repository
          expect(described_class['ObjectRepository']).to equal repository
        end
      end

      describe '.new_repositories' do
        it 'sets a new Registry object into current Thread as repositories variable' do
          described_class.new_repositories
          expect(
            Thread.current.thread_variable_get(:repositories)
          ).to be_an_instance_of(described_class)
        end
      end

      describe '.repositories' do
        it 'gets Registry object registered in current Thread' do
          registry = described_class.new

          Thread.current.thread_variable_set(:repositories, registry)

          expect(described_class.repositories).to equal registry
        end
      end

      describe '#[] class_name' do
        it 'returns the repository object set for entity class' do
          subject.instance_variable_get(
            :@repositories
          )[repo.class] = repo

          expect(subject[Object]).to equal repo
        end

        it 'returns the repository object set for entity class string' do
          subject.instance_variable_get(
            :@repositories
          )[repo.class] = repo

          expect(subject['Object']).to equal repo
        end


        it 'returns always the same repository object for class' do
          subject.instance_variable_get(
            :@repositories
          )[repo.class] = repo

          expect(subject[Object]).to equal repo
          expect(subject[ObjectRepository]).to equal repo
          expect(subject['Object']).to equal repo
          expect(subject['ObjectRepository']).to equal repo
        end

        context 'when no repository is yet set for class name' do
          before do
            expect(
              subject.instance_variable_get(:@repositories)[Object]
            ).to be_nil
          end

          it 'returns a new repository object' do
            expect(subject[Object]).to be_an_instance_of(ObjectRepository)
          end

          it 'returns the same repository object' do
            repo = subject[Object]

            expect(repo).to be_an_instance_of(ObjectRepository)

            expect(subject[Object]).to equal repo
            expect(subject[ObjectRepository]).to equal repo
            expect(subject['Object']).to equal repo
            expect(subject['ObjectRepository']).to equal repo
          end
        end

        it 'raises NameError when repository class does not exist' do
          expect { subject[String] }.to raise_error(NameError)
        end
      end
    end
  end
end
