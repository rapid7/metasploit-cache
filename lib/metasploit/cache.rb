#
# Gems
#

require 'active_support'
require 'awesome_nested_set'
require 'metasploit/concern'
require 'metasploit/model'

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

    autoload :Actionable
    autoload :Architecture
    autoload :Architecturable
    autoload :Association
    autoload :Author
    autoload :Authority
    autoload :Auxiliary
    autoload :Base
    autoload :Batch
    autoload :Cacheable
    autoload :Constant
    autoload :Derivation
    autoload :Direct
    autoload :EmailAddress
    autoload :Encoder
    autoload :Error
    autoload :Exploit
    autoload :File
    autoload :Invalid
    autoload :Licensable
    autoload :License
    autoload :Login
    autoload :Module
    autoload :NilifyBlanks
    autoload :Nop
    autoload :NullProgressBar
    autoload :Payload
    autoload :Platform
    autoload :Post
    autoload :ProxiedValidation
    autoload :RealPathname
    autoload :Realm
    autoload :Reference
    autoload :ResurrectingAttribute
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
