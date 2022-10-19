# frozen_string_literal: true

require 'spec_helper'

module RSpec
  module GraphqlMatchers
    describe 'expect(a_type).to implement(interface_names)' do
      AnotherInterface = Module.new {
        include GraphQL::Schema::Interface
        graphql_name 'AnotherInterface'
      }

      a_class_based_interface = Module.new do
        include GraphQL::Schema::Interface
        graphql_name 'AClassBasedApiInterface'
      end

      RSpec.shared_examples 'implements interfaces' do
        it { is_expected.to implement('Node') }
        it { is_expected.to implement('AClassBasedApiInterface') }
        it { is_expected.to implement('Node', 'AClassBasedApiInterface') }
        it { is_expected.to implement(['Node']) }
        it { is_expected.to implement(%w[Node]) }
        it { is_expected.to implement(GraphQL::Relay::Node.interface) }
        it { is_expected.to implement([GraphQL::Relay::Node.interface]) }

        it { is_expected.not_to implement('AnotherInterface') }
        it { is_expected.not_to implement(['AnotherInterface']) }
        it { is_expected.not_to implement(AnotherInterface) }
        it { is_expected.not_to implement([AnotherInterface]) }

        it 'fails with a message when the type does include the interfaces' do
          expect { expect(a_type).to implement('AnotherInterface') }
            .to fail_with(
              "expected interfaces: AnotherInterface\n" \
              'actual interfaces:   Node, AClassBasedApiInterface'
            )
        end

        it 'provides a description' do
          matcher = implement('Node')
          matcher.matches?(a_type)

          expect(matcher.description).to eq('implement Node')
        end

        context 'when an invalid type is passed' do
          let(:a_type) { double(to_s: 'InvalidObject') }

          it 'fails with a Runtime error' do
            expect { expect(a_type).to have_a_field(:id) }
              .to raise_error(
                RuntimeError,
                'Invalid object InvalidObject provided to have_a_field matcher. ' \
                'It does not seem to be a valid GraphQL object type.'
              )
          end
        end
      end

      context 'the type is defined with the class-based api' do
        subject(:a_type) do
          Class.new(GraphQL::Schema::Object) do
            graphql_name 'TestObject'

            implements GraphQL::Relay::Node.interface
            implements a_class_based_interface
          end
        end

        include_examples 'implements interfaces'
      end
    end
  end
end
