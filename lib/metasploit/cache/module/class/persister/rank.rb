# Synchronizes the persistent cache of `Metasploit::Cache::**::Class#rank` with the in-memory `rank` on the Metasploit
# Module class.
module Metasploit::Cache::Module::Class::Persister::Rank
  #
  # Module Methods
  #

  # Synchronizes rank from Metasploit Module class `source` to peristed `#rank` on `destination`.
  #
  # @param destination [ActiveRecord::Base, #rank]
  # @param [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @param source [#rank] Metasploit Module class
  # @return [#rank] `destination`
  def self.synchronize(destination:, logger:, source:)
    destination.class.connection_pool.with_connection {
      # assume nil so that `destination.rank` is reset to `nil` if Metasploit Module changed and it lost its rank
      module_rank = nil

      if source.respond_to? :rank
        rank_number = source.rank

        # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
        module_rank = ActiveRecord::Base.connection_pool.with_connection {
          Metasploit::Cache::Module::Rank.where(number: rank_number).first
        }

        if module_rank.nil?
          name = Metasploit::Cache::Module::Rank::NAME_BY_NUMBER[rank_number]

          if name.nil?
            logger.error {
              "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not in list of allowed #numbers " \
              "(#{Metasploit::Cache::Module::Rank::NAME_BY_NUMBER.keys.sort.to_sentence})"
            }
          else
            logger.error {
              "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not seeded"
            }
          end
        else
          module_rank = module_rank
        end
      else
        logger.error {
          "#{source} does not respond to rank. " \
          'It should return the `Metasploit::Cache::Module::Rank#number`.'
        }
      end

      destination.rank = module_rank

      destination
    }
  end
end
