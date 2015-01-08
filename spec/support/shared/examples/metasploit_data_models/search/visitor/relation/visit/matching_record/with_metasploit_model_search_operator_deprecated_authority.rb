shared_examples_for 'MetasploitDataModels::Search::Visitor::Relation#visit matching record with Metasploit::Model::Search::Operator::Deprecated::Authority' do |options={}|
  options.assert_valid_keys(:abbreviation)

  abbreviation = options.fetch(:abbreviation)

  context "with #{abbreviation}" do
    #
    # lets
    #

    let(:formatted) do
      "#{abbreviation}:#{value}"
    end

    let(:matching_authority) do
      FactoryGirl.create(
          :metasploit_cache_authority,
          :abbreviation => abbreviation
      )
    end

    let(:matching_record) do
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: matching_module_class,
          # disable factory making references automatically so Metasploit::Cache::Module::Reference#reference can be set to
          # matching_reference
          module_references_length: 0
      ).tap { |module_instance|
        module_instance.module_references << FactoryGirl.build(
            :metasploit_cache_module_reference,
            module_instance: module_instance,
            reference: matching_reference
        )
      }
    end

    let(:matching_reference) do
      FactoryGirl.create(
          :metasploit_cache_reference,
          :authority => matching_authority
      )
    end

    let(:non_matching_authority) do
      FactoryGirl.create(:metasploit_cache_authority)
    end

    let(:non_matching_record) do
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: non_matching_module_class,
          module_references_length: 0
      ).tap { |module_instance|
        module_instance.module_references << FactoryGirl.build(
            :metasploit_cache_module_reference,
            module_instance: module_instance,
            reference: non_matching_reference
        )
      }
    end

    let(:non_matching_reference) do
      FactoryGirl.create(
          :metasploit_cache_reference,
          :authority => non_matching_authority
      )
    end

    let(:value) do
      matching_reference.designation
    end

    it 'should find only matching record' do
      expect(visit).to match_array([matching_record])
    end
  end
end
