# Records that have unique indexes normally also have uniqueness validations that mirror these index, but when doing
# batch processing, such as in the creation of the module cache, the overhead of the `SELECT` performed by each
# uniqueness validations can become onerous.  {Metasploit::Cache::Batch::Descendant} can be used to add support for
# batch mode that validations can check for with {#batched?}.
module Metasploit::Cache::Batch::Descendant
  # Whether in batch mode.
  #
  # @return (see Metasploit::Cache::Batch.batched?)
  def batched?
    Metasploit::Cache::Batch.batched?
  end
end
