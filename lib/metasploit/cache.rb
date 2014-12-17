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
  end
end
