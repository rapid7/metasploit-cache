# Synchronizes the `#passive?` of a Metasploit Module instance to {Metasploit::Cache::Auxiliary::Instance#stance}.
module Metasploit::Cache::Auxiliary::Instance::Persister::Stance
  # Synchronizes the `#passive?` of a Metasploit Module instance to {Metasploit::Cache::Auxiliary::Instance#stance}.
  #
  # @param destination [#stance]
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @param source [#passive?] Metasploit Module instance
  # @return [#stance] `destination`
  def self.synchronize(destination:, logger:, source:)
    if source.passive?
      destination.stance = Metasploit::Cache::Module::Stance::PASSIVE
    else
      destination.stance = Metasploit::Cache::Module::Stance::AGGRESSIVE
    end

    destination
  end
end