# Acts as a stand-in for metasploit-framework's `Msf::Module`'s `Msf::Module::Ranking` behavior.  Used as the
# base subclass for `:metasploit_cache_direct_class_content` trait's `ancestor_superclass`
class Metasploit::Cache::Ranked
  # The numerical ranking of this Metasploit Module
  #
  # @return [Integer] `Rank` constant for this Metasploit Module if it is defined, otherwise numerical value of
  #   `'Normal'` rank from {Metasploit::Cache::Module::Rank::NUMBER_BY_NAME}.
  def self.rank
    if const_defined? :Rank
      const_get :Rank
    else
      Metasploit::Cache::Module::Rank::NUMBER_BY_NAME['Normal']
    end
  end
end