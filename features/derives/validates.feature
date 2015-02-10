Feature: 'derives' shared examples' :validates keyword argument

  The 'derives' shared examples require the caller to set the `:validates` keyword argument to indicate whether the
  attribute value is expected to match the derived attribute value.

  Scenario: Without `:validates` keyword argument
    Given a file named "missing_spec.rb" with:
      """ruby
      class Missing
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe Missing do
        it_should_behave_like 'derives',
                              :missing
      end
      """
    When I run `bundle exec rspec --format documentation missing_spec.rb`
    Then the output should contain "key not found: :validates"

  Scenario: With `validates: false`
    Given a file named "unvalidated_spec.rb" with:
      """ruby
      require 'metasploit/cache'

      class Unvalidated
        include Metasploit::Cache::Derivation

        #
        # Attributes
        #

        attr_accessor :unvalidated

        #
        # Derivations
        #

        derives :unvalidated,
                validate: false

        #
        # Instance Methods
        #

        def derived_unvalidated
          'derived_unvalidated'
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe Unvalidated do
        #
        # Methods
        #

        def attribute_type(attribute)
          :string
        end

        #
        # lets
        #

        let(:base_class) {
          described_class
        }

        it_should_behave_like 'derives',
                              :unvalidated,
                              validates: false
      end
      """
    When I run `bundle exec rspec --format documentation unvalidated_spec.rb`
    Then the output should contain:
      """
            should not validate unvalidated
      """
    And the output should not contain:
      """
            validation
      """

  Scenario: With `validates: true`
    Given a file named "validated_spec.rb" with:
      """ruby
      require 'metasploit/cache'

      class Validated
        include Metasploit::Cache::Derivation

        #
        # Attributes
        #

        attr_accessor :validated

        #
        # Derivations
        #

        derives :validated,
                validate: true

        #
        # Instance Methods
        #

        def derived_validated
          'derived_validated'
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe Validated do
        #
        # Methods
        #

        def attribute_type(attribute)
          :string
        end

        #
        # lets
        #

        let(:base_class) {
          described_class
        }

        it_should_behave_like 'derives',
                              :validated,
                              validates: true
      end
      """
    When I run `bundle exec rspec --format documentation validated_spec.rb`
    Then the output should contain:
      """
            should validate validated
            validation
              with validated matching derived_validated
                should be valid
              without validated matching derived_validated
                should not be valid
                should record error on validated
      """
