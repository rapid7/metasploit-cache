module Metasploit::Cache::Licensable
  extend ActiveSupport::Autoload

  autoload :License

  def self.table_name_prefix
    "#{parent.table_name_prefix}licensable_"
  end

end
