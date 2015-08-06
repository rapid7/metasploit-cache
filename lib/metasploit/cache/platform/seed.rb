# Seeds {Metasploit::Cache::Platform Metasploit::Cache::Platforms}.
module Metasploit::Cache::Platform::Seed
  #
  # CONSTANTS
  #

  # Platforms are seeded in a hierarchy with deeper levels refining higher levels, so 'Windows 98 SE' is a
  # refinement of 'Windows 98', which is a refinement of 'Windows'.
  RELATIVE_NAME_TREE = {
      'AIX' => nil,
      'Android' => nil,
      'BSD' => nil,
      'BSDi' => nil,
      'Cisco' => nil,
      'Firefox' => nil,
      'FreeBSD' => nil,
      'HPUX' => nil,
      'Irix' => nil,
      'Java' => nil,
      'Javascript' => nil,
      'Linux' => nil,
      'NetBSD' => nil,
      'Netware' => nil,
      'NodeJS' => nil,
      'OpenBSD' => nil,
      'OSX' => nil,
      'PHP' => nil,
      'Python' => nil,
      'Ruby' => nil,
      'Solaris' => {
          '4' => nil,
          '5' => nil,
          '6' => nil,
          '7' => nil,
          '8' => nil,
          '9' => nil,
          '10' => nil
      },
      'Windows' => {
          '95' => nil,
          '98' => {
              'FE' => nil,
              'SE' => nil
          },
          'ME' => nil,
          'NT' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil,
              'SP4' => nil,
              'SP5' => nil,
              'SP6' => nil,
              'SP6a' => nil
          },
          '2000' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil,
              'SP4' => nil
          },
          'XP' => {
              'SP0' => nil,
              'SP1' => nil,
              'SP2' => nil,
              'SP3' => nil
          },
          '2003' => {
              'SP0' => nil,
              'SP1' => nil
          },
          'Vista' => {
              'SP0' => nil,
              'SP1' => nil
          },
          '7' => nil
      },
      'Unix' => nil
  }

  #
  # Module Methods
  #

  # @param options [Hash{Symbol => Object, Hash}]
  # @option options [Object] :parent (nil) The parent object to which to attach the children.
  # @option options [Hash{String => nil,Hash}] :grandchildren_by_child_relative_name
  #   ({RELATIVE_NAME_TREE}) Maps {#relative_name} of children under :parent to their children
  #   (grandchildren of parent).  Grandchildren can be `nil` or another recursive `Hash` of names and their
  #   descendants.
  # @yield [attributes] Block should construct child object using attributes.
  # @yieldparam attributes [Hash{Symbol => Object,String}] Hash containing attributes for child object, include
  #   :parent for {#parent} and :relative_name for {#relative_name}.
  # @yieldreturn [Object] child derived from :parent and :relative_name to be used as the parent for
  #   grandchildren.
  # @return [void]
  def self.each_attributes(options={}, &block)
    options.assert_valid_keys(:parent, :grandchildren_by_child_relative_name)

    parent = options[:parent]
    grandchildren_by_child_relative_name = options.fetch(
        :grandchildren_by_child_relative_name,
        RELATIVE_NAME_TREE
    )

    grandchildren_by_child_relative_name.each do |child_relative_name, great_grandchildren_by_grandchild_relative_name|
      attributes = {
          parent: parent,
          relative_name: child_relative_name
      }
      child = block.call(attributes)

      if great_grandchildren_by_grandchild_relative_name
        each_attributes(
            grandchildren_by_child_relative_name: great_grandchildren_by_grandchild_relative_name,
            parent: child,
            &block
        )
      end
    end
  end

  # Seeds {Metasploit::Cache::Platform Metasploit::Cache::Platforms}.
  #
  # @return [void]
  def self.seed
    each_attributes do |attributes|
      parent = attributes.fetch(:parent)
      relative_name = attributes.fetch(:relative_name)
      parent_id = nil

      if parent
        parent_id = parent.id
      end

      child = self.parent.where(parent_id: parent_id, relative_name: relative_name).first

      unless child
        child = self.parent.new
        child.parent = parent
        child.relative_name = relative_name
        child.save!
      end

      # yieldreturn
      child
    end
  end
end