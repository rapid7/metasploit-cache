Feature: 'derives' shared examples' attribute_type method

  The 'derives' shared examples require the caller to supply an `attribute_type(attibute)` method which returns
  `:datetime`, `:string`, or `:text` so that 'derives' can generate a default value for the `attribute`.  If an unknown
  type is returned from `attribute_type(attribute)`, then 'derives' will raise an `ArgumentError`.

  Scenario: With `:datetime` for attribute_type
    Given a file named "date_timed_spec.rb" with:
      """ruby
      require 'metasploit/cache'

      class DateTimed
        include Metasploit::Cache::Derivation

        #
        # Attributes
        #

        attr_accessor :datetimish

        #
        # Derivations
        #

        derives :datetimish,
                validate: true

        #
        # Instance Methods
        #

        def derived_datetimish
          DateTime.new(2015, 1, 1)
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe DateTimed do
        #
        # methods
        #

        def attribute_type(attribute)
          :datetime
        end

        #
        # lets
        #

        let(:base_class) {
          described_class
        }

        it_should_behave_like 'derives',
                              :datetimish,
                              validates: true
      end
      """
    When I run `bundle exec rspec --format documentation date_timed_spec.rb`
    Then the output should contain:
      """
            callbacks
              before validation
                with datetimish
                  should not change datetimish
      """

  Scenario: With `:string` for attribute_type
    Given a file named "stringed_spec.rb" with:
      """ruby
      require 'metasploit/cache'

      class Stringed
        include Metasploit::Cache::Derivation

        #
        # Attributes
        #

        attr_accessor :stringish

        #
        # Derivations
        #

        derives :stringish,
                validate: true

        #
        # Instance Methods
        #

        def derived_stringish
          'Stringish'
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe Stringed do
        #
        # methods
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
                              :stringish,
                              validates: true
      end
      """
    When I run `bundle exec rspec --format documentation stringed_spec.rb`
    Then the output should contain:
      """
            callbacks
              before validation
                with stringish
                  should not change stringish
      """

  Scenario: With `:text` for attribute_type
    Given a file named "texted_spec.rb" with:
      """ruby
      require 'metasploit/cache'

      class Texted
        include Metasploit::Cache::Derivation

        #
        # Attributes
        #

        attr_accessor :textish

        #
        # Derivations
        #

        derives :textish,
                validate: true

        #
        # Instance Methods
        #

        def derived_textish
          'Textish'
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

      RSpec.describe Texted do
        #
        # methods
        #

        def attribute_type(attribute)
          :text
        end

        #
        # lets
        #

        let(:base_class) {
          described_class
        }

        it_should_behave_like 'derives',
                              :textish,
                              validates: true
      end
      """
    When I run `bundle exec rspec --format documentation texted_spec.rb`
    Then the output should contain:
      """
            callbacks
              before validation
                with textish
                  should not change textish
      """

  Scenario: Without `:datetime`, `:string`, or `:text` for attribute_type
    Given a file named "host_spec.rb" with:
      """ruby
      class Host
        def derived_address
        end
      end

      require File.expand_path('../../spec/support/shared/examples/derives.rb')

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
