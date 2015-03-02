# Namespace for all models dealing with module caching.
#
# Metasploit module metadata is split between 3 classes:
#
# 1. {Metasploit::Cache::Module::Ancestor} which represents the ruby Module (in the case of payloads) or ruby Class (in the case
#    of non-paylods) loaded by Msf::Modules::Loader::Base#load_modules and so has file related metadata.
# 2. {Metasploit::Cache::Module::Class} which represents the Class<Msf::Module> derived from one or more
#    {Metasploit::Cache::Module::Ancestor ancestors}. {Metasploit::Cache::Module::Class} can have a different reference name in the case of
#    payloads.
# 3. {Metasploit::Cache::Module::Instance} which represents the instance of Msf::Module created from a {Metasploit::Cache::Module::Class}.  Metadata
#    that is only available after running #initialize is stored in this model.
#
# # Translation from metasploit_data_models <= 0.16.5
#
# If you're trying to convert your SQL queries from metasploit_data_models <= 0.16.5 and the Metasploit::Cache::Module::Details cache
# to the new Metasploit::Cache::Module::Instance cache available in metasploit_data_models >= 0.17.2, then see this
# {file:docs/mdm_module_sql_translation.md guide}.
#
# Entity-Relationship Diagram
# ===========================
# The below Entity-Relationship Diagram (ERD) shows all direct relationships between the models in the Metasploit::Cache::Module
# namespace.
# All columns are included for ease-of-use with manually written SQL.
#
# ![Metasploit::Cache::Module (Direct) Entity-Relationship Diagram](../images/metasploit-cache-module.erd.png)
module Metasploit::Cache::Module
  extend ActiveSupport::Autoload

  autoload :Action
  autoload :Ancestor
  autoload :Architecture
  autoload :Author
  autoload :Class
  autoload :Handler
  autoload :Instance
  autoload :Namespace
  autoload :Path
  autoload :Platform
  autoload :Relationship
  autoload :Rank
  autoload :Reference
  autoload :Stance
  autoload :Target
  autoload :Type

  #
  # Module Methods
  #

  def self.table_name_prefix
    "#{parent.table_name_prefix}module_"
  end
end
