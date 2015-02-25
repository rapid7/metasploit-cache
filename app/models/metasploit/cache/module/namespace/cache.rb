# Cache metadata stored on {Metasploit::Cache::Module::Namespace} for Metasploit Module
class Metasploit::Cache::Module::Namespace::Cache < Metasploit::Model::Base
  #
  # Attributes
  #
  
  # @!attribute [rw] module_type
  #   The {Metasploit::Cache::Module::Ancestor#module_type}.
  #
  #   @return [String] element of {Metasploit::Cache::Module::Type::ALL}.
  attr_accessor :module_type

  # @!attribute [rw] real_path_sha1_hex_digest
  #   The `Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest`.  Used to look up
  #   `Metasploit::Module::Module::Ancestor`.
  #
  #   @return [String]
  attr_accessor :real_path_sha1_hex_digest

  #
  # Validations
  #

  validates :module_type,
            inclusion: {
                in: Metasploit::Cache::Module::Type::ALL
            }
  validates :real_path_sha1_hex_digest,
            format: {
                with: Metasploit::Cache::Module::Ancestor::SHA1_HEX_DIGEST_REGEXP
            }

  #
  # Instance Methods
  #

  # Return whether this forms part of a payload (either a single, stage, or stager).
  #
  # @return [true] if {#module_type} is `Metasploit::Model::Module::Type::PAYLOAD`
  # @return [false] otherwise
  def payload?
    module_type == Metasploit::Cache::Module::Type::PAYLOAD
  end
end