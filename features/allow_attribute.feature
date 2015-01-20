Feature: allow_attribute matcher

  The `allow_attribute` matcher is used to check that the given attribute is allowed for the
  `Metasploit::Cache::Module::Instance`.

  Scenario: Attribute is allowed when it is expected to be allowed
    Given a file named "module_instance_spec.rb" with:
      """ruby
      class ModuleInstance
        def allows?(attribute)
          true
        end

        def module_type
          'auxiliary'
        end
      end

      require '../../spec/support/matchers/allow_attribute'

      RSpec.describe ModuleInstance do
        it { is_expected.to allow_attribute(:actions) }
      end
      """
    When I run `rspec --format documentation module_instance_spec.rb`
    Then the output should contain:
      """
      ModuleInstance
        should allow zero or more items for actions
      """
    And the output should contain "1 example, 0 failures"

  Scenario: Attribute is not allowed when it is expected to be allowed
     Given a file named "module_instance_spec.rb" with:
      """ruby
      class ModuleInstance
        def allows?(attribute)
          false
        end

        def module_type
          'auxiliary'
        end
      end

      require '../../spec/support/matchers/allow_attribute'

      RSpec.describe ModuleInstance do
        it { is_expected.to allow_attribute(:actions) }
      end
      """
    When I run `rspec --format documentation module_instance_spec.rb`
    Then the output should contain:
      """
      ModuleInstance
        should allow zero or more items for actions (FAILED - 1)
      """
    And the output should contain:
      """
             expected that ModuleInstance with auxiliary #module_type would allow zero or more items for actions
      """
    And the output should contain "1 example, 1 failure"

  Scenario: Attribute is allowed when it is expected not to be allowed
     Given a file named "module_instance_spec.rb" with:
      """ruby
      class ModuleInstance
        def allows?(attribute)
          true
        end

        def module_type
          'auxiliary'
        end
      end

      require '../../spec/support/matchers/allow_attribute'

      RSpec.describe ModuleInstance do
        it { is_expected.not_to allow_attribute(:targets) }
      end
      """
    When I run `rspec --format documentation module_instance_spec.rb`
    Then the output should contain:
      """
      ModuleInstance
        should not allow zero or more items for targets (FAILED - 1)
      """
    And the output should contain:
      """
             expected that ModuleInstance with auxiliary #module_type would not allow any items for targets
      """
    And the output should contain "1 example, 1 failure"