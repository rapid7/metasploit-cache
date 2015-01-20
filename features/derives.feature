Feature: 'derives' shared examples

  The 'derives' shared examples is used to check an attribute is derived using `Metasploit::Cache::Derivation`.

  Scenario: Without `:datetime`, `:string`, or `:text` for attribute_type
    Given a file named "host_spec.rb" with:
      """ruby
      class Host
        def derived_address
        end
      end

      require '../../spec/support/shared/examples/derives.rb'

      RSpec.describe Host do
        #
        # methods
        #

        def attribute_type(attribute)
          :unknown_type
        end

        #
        # lets
        #

        let(:base_class) {
          described_class
        }

        it_should_behave_like 'derives',
                              :address,
                              validates: true
      end
      """
    When I run `rspec --format documentation host_spec.rb`
    Then the output should contain:
      """
             Don't know how to make valid existing value for attribute type (:unknown_type)
      """
