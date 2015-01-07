#
# Gems
#

require 'awesome_nested_set'
require 'metasploit/concern'
require 'metasploit/model'
require 'metasploit_data_models'

#
# Project
#

require "metasploit/cache/version"

autoload :DerivationValidator, 'derivation_validator'
autoload :DynamicLengthValidator, 'dynamic_length_validator'

# Namespace shared between gems in the Metasploit ecosystem.
module Metasploit
  # The metasploit cache holds metadata about Metasploit module files and the Ruby `Module`s, Ruby `Class`es and their
  # Ruby `Object` instances derived from those files.
  module Cache
    extend ActiveSupport::Autoload

    autoload :Architecture
    autoload :Association
    autoload :Author
    autoload :Authority
    autoload :Base
    autoload :Batch
    autoload :Derivation
    autoload :EmailAddress
    autoload :Error
    autoload :File
    autoload :Invalid
    autoload :Login
    autoload :Module
    autoload :NilifyBlanks
    autoload :Platform
    autoload :RealPathname
    autoload :Realm
    autoload :Reference
    autoload :Search
    autoload :Spec
    autoload :Translation
    autoload :Visitation

    #
    # Module Methods
    #

    # @note Can't use the proper `'metasploit_cache_'` because table names are too long for PostgreSQL.
    #
    # @return ['cache_']
    def self.table_name_prefix
      'mc_'
    end
  end
end
