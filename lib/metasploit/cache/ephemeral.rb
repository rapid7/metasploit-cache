# Operations common to ephemeral caches
module Metasploit::Cache::Ephemeral
  extend ActiveSupport::Autoload

  autoload :AttributeSet

  # Runs transaction on `destination_class` using temporary from the connection pool that is checked in to the
  # connection pool at the end of `block`.
  #
  # @param destination [Class<ActiveRecord::Base>, #connection_pool, #transaction] an `ActiveRecord::Base` subclass
  # @yield Block run database transaction
  # @yieldreturn [Object] value to return
  # @return [Object] value returned from `block`
  def self.with_connection_transaction(destination_class:, &block)
    destination_class.connection_pool.with_connection do
      destination_class.transaction(&block)
    end
  end
end