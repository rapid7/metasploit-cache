# Acts as a stand-in for metasploit-framework's `Msf::Module`'s `Msf::Module::Ranking` behavior.
#
# @example A dummy Metasploit Classs
#   class Metasploit4
#     extend Metasploit::Cache::Direct::Class::Ranking
#   end
module Metasploit::Cache::Direct::Class::Ranking
  # The numerical ranking of this Metasploit Class
  #
  # @return [Integer] `Rank` constant for this Metasploit Class if it is defined, otherwise numerical value of
  #   `'Normal'` rank from {Metasploit::Cache::Module::Rank::NUMBER_BY_NAME}.
  def rank
    if const_defined? :Rank
      const_get :Rank
    else
      Metasploit::Cache::Module::Rank::NUMBER_BY_NAME['Normal']
    end
  end
end