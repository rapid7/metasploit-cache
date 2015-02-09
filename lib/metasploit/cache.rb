#
# Gems
#

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

    autoload :Architecture
    autoload :Association
    autoload :Author
    autoload :Authority
    autoload :Base
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
  end
end
