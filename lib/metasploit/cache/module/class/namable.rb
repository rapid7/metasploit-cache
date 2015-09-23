# Add `#name` association to an `ActiveRecord::Base` subclass.
module Metasploit::Cache::Module::Class::Namable
  extend ActiveSupport::Concern

  #
  # CONSTANTS
  #

  # Separator used to join names in {#reference_name}.  It is always '/', even on Windows, where '\' is a valid
  # file separator.
  REFERENCE_NAME_SEPARATOR = '/'

  included do
    #
    # Associations
    #

    has_one :name,
            as: :module_class,
            class_name: 'Metasploit::Cache::Module::Class::Name',
            dependent: :destroy,
            foreign_key: :module_class_id,
            inverse_of: :module_class

    #
    # Validations
    #

    validates :name,
              presence: true
  end

  #
  # Module Methods
  #

  # The reference name of the Metasploit Module.   The name of the Metasploit Module under `scoping_levels` of
  # directories.
  #
  # @param relative_file_names [Array<String>] {#relative_path} broken into Array of directory and file names.
  # @param scoping_levels [Integer] number of levels scoping the reference name.
  # @return [nil] if `relative_file_names` doesn't end in a file name with
  #   {Metasploit::Cache::Module::AncestorEXTENSION}.
  # @return [String] otherwise
  def self.reference_name(relative_file_names:, scoping_levels:)
    derived = nil
    reference_name_file_names = relative_file_names.drop(scoping_levels)
    reference_name_base_name = reference_name_file_names[-1]

    if reference_name_base_name
      if File.extname(reference_name_base_name) == Metasploit::Cache::Module::Ancestor::EXTENSION
        reference_name_file_names[-1] = File.basename(reference_name_base_name, Metasploit::Cache::Module::Ancestor::EXTENSION)
        derived = reference_name_file_names.join(REFERENCE_NAME_SEPARATOR)
      end
    end

    derived
  end
end