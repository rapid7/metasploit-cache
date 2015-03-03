# Base class from loading payload Metasploit Modules.
class Metasploit::Cache::Payload::Ancestor < Metasploit::Cache::Module::Ancestor
  extend ActiveSupport::Autoload

  autoload :Type

  Metasploit::Cache::Module::Ancestor.restrict(self, to: 'payload')

  Metasploit::Concern.run(self)

  #
  # Validations
  #

  validates :payload_type,
            inclusion: {
                in: Metasploit::Cache::Payload::Ancestor::Type::ALL
            }

  #
  # Class Methods
  #

  # Ensure that only {#payload_type} matching `payload_type` is valid for `subclass`.
  #
  # @param subclass [Class<Metasploit::Cache::Payload::Ancestor>] a subclass of {Metasploit::Cache::Payload::Ancestor}.
  # @param to [String] an element of {Metasploit::Cache::Payload::Ancestor::Type::ALL}.
  # @return [void]
  def self.restrict(subclass, to:)
    subclass.validate :payload_type_matches
    error = "is not #{to}"

    subclass.send(:define_method, :payload_type_matches) do
      if payload_type != to
        errors.add(:payload_type, error)
      end
    end

    subclass.send(:private, :payload_type_matches)
  end

  #
  # Instance Methods
  #

  # The name used to forming the {Metasploit::Cache::Module::Class#reference_name} for payloads.
  #
  # @return [String] The {#reference_name} without the {#payload_type_directory}
  # @return [nil] if {#relative_path} is `nil`.
  def payload_name
    relative_file_names = self.relative_file_names

    if relative_file_names
      relative_file_names.drop(2).join(REFERENCE_NAME_SEPARATOR)
    end
  end

  # The type of the payload.
  #
  # @return [String] value in {Metasploit::Cache::Module::Payload::Type::ALL}.
  # @return [nil] if {#payload_type_directory} is `nil`.
  def payload_type
    payload_type_directory = self.payload_type_directory

    if payload_type_directory
      payload_type_directory.singularize
    end
  end

  # The directory for {#payload_type} under {Metasploit::Cache::Module::Ancestor#module_type_directory}.
  #
  # @return [String] first directory in {Metasploit::Cache::Module::Ancestor#reference_name}.
  # @return [nil] if {#reference_name} is `nil`.
  def payload_type_directory
    relative_file_names = self.relative_file_names

    if relative_file_names
      relative_file_names.take(2).second
    end
  end

end