require 'rspec/matchers'

# @note Matchers defined with `RSpec::Matchers.define` should be defined in `spec/support/matchers`.
#
# Namespace for custom RSpec matchers that are classes instead of defined using the `RSpec::Matchers.define` DSL.
module Metasploit::Cache::Spec::Matcher
  # Matches that the given `expect { }` raises an exception that the record is not unique based on the current adapter.
  #
  # @return [RSpec::Matchers::Builtin::RaiseError]
  def raise_record_not_unique
    RSpec::Matchers::BuiltIn::RaiseError.new do |error|
      adapter = ActiveRecord::Base.connection_config[:adapter]

      case adapter
      when "postgresql"
        expect(error).to be_an ActiveRecord::RecordNotUnique
      when "sqlite3"
        expect(error).to be_an ActiveRecord::StatementInvalid

        cause = error.cause

        expect(cause).to be_a SQLite3::ConstraintException
        expect(cause.message).to start_with('UNIQUE constraint failed')
      else
        raise ArgumentError, "Expected error for #{adapter.inspect} adapter unknown"
      end
    end
  end
end