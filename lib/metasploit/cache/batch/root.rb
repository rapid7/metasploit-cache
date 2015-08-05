# Using {#batched_save}, `ActiveRecord::Base#save` will be attempted in a batch mode
# (using {Metasploit::Cache::Batch.batch} block), thereby disabling the uniqueness validations, but if a
# `ActiveRecord::RecordNotUnique` error is raised from the unique index, then the save is retried outside the batch
# mode, so that all validation errors are populated instead of just identifying the irst unique index check that failed
# as would be the case with if the exception were added as a validation error.
#
# @example Using batched save to optimistically avoid uniqueness overhead
#   class MyRecord < ActiveRecord::Base
#     include Metasploit::Cache::Batch::Root
#
#     #
#     # Attributes
#     #
#
#     # @!attribute [rw] unique_field
#     #   A field that is unique
#     #
#     #   @return [Object]
#
#     #
#     # Validations
#     #
#
#     validates :unique_field,
#               uniqueness: {
#                   unless: :batched?
#               }
#   end
#
#   my_record = MyRecord.new(...)
#   saved = my_record.batched_save
module Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Batch::Descendant

  # Attempts to save record while in {Metasploit::Cache::Batch.batch}, which disables costly uniqueness validations.
  # If `ActiveRecord::RecordNotUnique` error is raised because of the underlying unique index in the database, then the
  # validations are run outside of batch mode so uniqueness validation error can be gathered.
  #
  # @return [true] if save successful
  # @return [false] if save unsucessful
  def batched_save
    begin
      Metasploit::Cache::Batch.batch {
        recoverable_save
      }
    # Different rescue blocks will be used for different adapters, but having < 100% coverage was causing new code to be
    # left uncovered, so mark as nocov so coverage remains 100%.
    # :nocov:
    rescue ActiveRecord::RecordNotUnique => active_record_record_not_unique
      logger.error(active_record_record_not_unique)
      # rerun validations outside of batch mode
      valid?

      # save was not successful
      false
    rescue ActiveRecord::StatementInvalid => active_record_statement_invalid
      if defined? SQLite3::ConstraintException
        if active_record_statement_invalid.cause.is_a? SQLite3::ConstraintException
          logger.error(active_record_statement_invalid)

          # rerun validations outside of batch mode
          valid?

          false
        else
          # reraise
          raise
        end
      else
        # reraise
        raise
      end
    end
    # :nocov:
  end

  # `save` wrapped in a new transaction/savepoint so that exception raised by save can be rescued and the transaction
  # won't become unusable.
  #
  # @return [true] if save successful
  # @return [false] if save unsucessful
  def recoverable_save
    # do requires_new so that exception won't kill outer transaction
    ActiveRecord::Base.transaction(requires_new: true) {
      save
    }
  end
end
