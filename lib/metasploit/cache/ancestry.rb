# Adds {#ancestor_by_source} to staged payload Metasploit Module class.
module Metasploit::Cache::Ancestry
  # Ancestor ruby Module by symbolic source name.
  #
  # @return [Hash{stage: Module, stager: Module}]
  def ancestor_by_source
    @ancestor_by_source ||= {}
  end
end