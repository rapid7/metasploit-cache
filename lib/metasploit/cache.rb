#
# Gems
#

require 'active_support'
# required by awesome_nested_set/move, but not explicitly required by it
require 'active_support/core_ext/module/delegation'
require 'awesome_nested_set'
require 'metasploit/concern'
require 'metasploit/model'
require 'thor'

#
# Project
#

require 'metasploit/cache/version'

autoload :DerivationValidator, 'derivation_validator'

# Namespace shared between gems in the Metasploit ecosystem.
module Metasploit
  # The metasploit cache holds metadata about Metasploit module files and the Ruby `Module`s, Ruby `Class`es and their
  # Ruby `Object` instances derived from those files.
  module Cache
    extend ActiveSupport::Autoload

    autoload :Actionable
    autoload :AncestorCell
    autoload :Ancestry
    autoload :Architecture
    autoload :Architecturable
    autoload :Author
    autoload :Authority
    autoload :Auxiliary
    autoload :Batch
    autoload :Cacheable
    autoload :CLI
    autoload :Constant
    autoload :Contributable
    autoload :Contribution
    autoload :Derivation
    autoload :Direct
    autoload :EmailAddress
    autoload :Encoder
    autoload :Persister
    autoload :Error
    autoload :Exploit
    autoload :Licensable
    autoload :License
    autoload :Logged
    autoload :Login
    autoload :Module
    autoload :NilifyBlanks
    autoload :Nop
    autoload :NullProgressBar
    autoload :Payload
    autoload :Platform
    autoload :Platformable
    autoload :Post
    autoload :RealPathname
    autoload :Realm
    autoload :Referencable
    autoload :Reference
    autoload :ResurrectingAttribute
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
