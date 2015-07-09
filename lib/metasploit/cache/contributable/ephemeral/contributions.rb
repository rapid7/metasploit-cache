# Synchronizes the persistent cache of `#contributions` with the in-memory authors of Metasploit Module instances.
module Metasploit::Cache::Contributable::Ephemeral::Contributions
  #
  # Module Methods
  #

  # Extracts the set of {Metasploit::Cache::Author#name}s from `added_attributes_set`.
  #
  # @param added_attributes_set [Set<Hash{:author => Hash{:name => String}}>] Attributes for contributions to be added.
  # @return [Set<String>]
  def self.added_author_name_set(added_attributes_set:)
    added_attributes_set.each_with_object(Set.new) do |added_attributes, set|
      set.add added_attributes[:author][:name]
    end
  end

  # Extracts the set of {Metasploit::Cache::EmailAddress#full}s from `added_attributes_set`.
  #
  # @param added_attributes_set [Set<Hash{:email_address => Hash{:full => String}}>] Attributes for contributions to be
  #   added.
  # @return [Set<String>]
  def self.added_email_address_full_set(added_attributes_set:)
    added_attributes_set.each_with_object(Set.new) do |added_attributes, set|
      email_address_attributes = added_attributes[:email_address]

      if email_address_attributes
        set.add email_address_attributes[:full]
      end
    end
  end

  # Builds new {Metasploit::Cache::Contribution} as `#contributions` on `destination`.
  #
  # @param destination [#contributions]
  # @param destination_attributes_set [Set<Hash{Symbol => Hash{Symbol => String}}>] Set of {Metasploit::Cache::Contribution} attributes
  #   of `destination`.
  # @param source_attributes_set [Set<Hash{Symbol => Hash{Symbol => String}}>]
  def self.build_added(destination:, destination_attributes_set:, source_attributes_set:)
    cached_added_attributes_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attributes_set,
        source: source_attributes_set
    )

    cached_added_author_name_set = added_author_name_set(added_attributes_set: cached_added_attributes_set)
    cached_author_by_name = Metasploit::Cache::Author::Ephemeral.by_name(
        existing_name_set: cached_added_author_name_set
    )

    cached_added_email_address_full_set = added_email_address_full_set(added_attributes_set: cached_added_attributes_set)
    cached_email_address_by_full = Metasploit::Cache::EmailAddress::Ephemeral.by_full(
        existing_full_set: cached_added_email_address_full_set
    )

    cached_added_attributes_set.each do |added_attributes|
      author_name = added_attributes[:author][:name]
      author = cached_author_by_name[author_name]

      email_address = nil
      email_address_attributes = added_attributes[:email_address]

      if email_address_attributes
        email_address_full = email_address_attributes[:full]
        email_address = cached_email_address_by_full[email_address_full]
      end

      destination.contributions.build(
          author: author,
          email_address: email_address
      )
    end

    destination
  end

  # The set of {Metasploit::Cache::Contribution} attributes currently persisted as `#contributions` on `destination`.
  #
  # @param destination [#contributions]
  # @return [Set<Hash{Symbol => Hash{Symbol => String}}>]
  def self.destination_attributes_set(destination)
    if destination.new_record?
      Set.new
    else
      destination.contributions.each_with_object(Set.new) do |contribution, set|
        attributes = {
            author: {
                name: contribution.author.name
            }
        }

        email_address = contribution.email_address

        if email_address
          attributes[:email_address] = {
              full: email_address.full
          }
        end

        set.add attributes
      end
    end
  end

  # Destroys {Metasploit::Cache::Contribution} `#contributions` of {Metasploit::Cache::Contribution#contributable}
  # `destination` that are persisted, but don't exist in `source`.
  #
  # @param destination [#contributions]
  # @param destination_attributes_set [Set<Hash{Symbol => Hash{Symbol => String}}>] Set of attributes from
  #   `#contributions` on `destination`.
  # @param source_attributes_set [Set<Hash{Symbol => Hash{Symbol => String}}>] Set of attributes from `source`
  #   `#authors`.
  # @return [#contributions] `destination`
  def self.destroy_removed(destination:, destination_attributes_set:, source_attributes_set:)
    cached_removed_attributes_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attributes_set,
        source: source_attributes_set
    )

    unless destination.new_record? || cached_removed_attributes_set.empty?
      attributes_conditions_list = cached_removed_attributes_set.collect { |removed_attributes|
        attributes_conditions = Metasploit::Cache::Author.arel_table[:name].eq(removed_attributes[:author][:name])

        email_address_attributes = removed_attributes[:email_address]

        if email_address_attributes
          attributes_conditions = attributes_conditions.and(
              Metasploit::Cache::EmailAddress.arel_table[:full].eq(email_address_attributes[:full])
          )
        else
          attributes_conditions = attributes_conditions.and(
              Metasploit::Cache::Contribution.arel_table[:email_address_id].eq(nil)
          )
        end

        attributes_conditions
      }

      removed_set_conditions = attributes_conditions_list.inject { |set_conditions, attributes_conditions|
        set_conditions.or(attributes_conditions)
      }

      destination.contributions.joins(
          :author
      ).references(
          :email_address
      ).where(
          removed_set_conditions
      ).readonly(
          false
      ).destroy_all
    end

    destination
  end

  # The set of attributes from the `source` Metasploit Module instance.
  #
  # @param source [#authors] Metasploit Module instance
  # @return [Set<Hash{Symbol => Hash{Symbol => String}}>] Set of author.names and email_address.full.
  def self.source_attributes_set(source)
    source.authors.each_with_object(Set.new) do |author, set|
      attributes = {
          author: {
              name: author.name
          }
      }

      email = author.email

      if email.present?
        attributes[:email_address] = {
            full: email
        }
      end

      set.add attributes
    end
  end

  # Synchronizes authors from Metasploit Module instance `source` to persisted `#contributions` on {#destination}.
  #
  # @param destination [#contributions] a {Metasploit::Cache::Contribution#contributable}.
  # @param source [#authors] a Metasploit Module instance
  # @return [#contributions] `destination`
  def self.synchronize(destination:, source:)
    transaction(destination: destination) {
      cached_destination_attributes_set = destination_attributes_set(destination)
      cached_source_attributes_set = source_attributes_set(source)

      reduced = destroy_removed(
          destination: destination,
          destination_attributes_set: cached_destination_attributes_set,
          source_attributes_set: cached_source_attributes_set
      )
      build_added(
          destination: reduced,
          destination_attributes_set: cached_destination_attributes_set,
          source_attributes_set: cached_source_attributes_set
      )
    }
  end

  # Runs transaction on destination using temporary from the connection pool that is returned at end of `block`.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @yield Block run in database transaction
  # @yieldreturn [Object] value to return
  # @return [Object] value returned from `block`.
  def self.transaction(destination:, &block)
    destination.class.connection_pool.with_connection do
      destination.transaction(&block)
    end
  end
end