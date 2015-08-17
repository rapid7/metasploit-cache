FactoryGirl.define do
  factory :metasploit_cache_payload_staged_class,
          class: Metasploit::Cache::Payload::Staged::Class do
    transient do
      compatible_architecture_count 1
      compatible_platform_count 1

      compatible_architectures {
        Array.new(compatible_architecture_count) {
          generate :metasploit_cache_architecture
        }
      }

      compatible_platforms {
        Array.new(compatible_platform_count) {
          generate :metasploit_cache_platform
        }
      }
    end

    payload_stage_instance {
      build(
          :metasploit_cache_payload_stage_instance,
          :metasploit_cache_contributable_contributions,
          :metasploit_cache_licensable_licensable_licenses
      ).tap { |block_payload_stage_instance|
        block_payload_stage_instance.architecturable_architectures = compatible_architectures.map { |compatible_architecture|
          Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: block_payload_stage_instance,
              architecture: compatible_architecture
          )
        }

        block_payload_stage_instance.platformable_platforms = compatible_platforms.map { |compatible_platform|
          Metasploit::Cache::Platformable::Platform.new(
              platformable: block_payload_stage_instance,
              platform: compatible_platform
          )
        }

        block_payload_stage_instance.save!
      }
    }

    payload_stager_instance {
      build(
          :metasploit_cache_payload_stager_instance,
          :metasploit_cache_contributable_contributions,
          :metasploit_cache_licensable_licensable_licenses,
          :metasploit_cache_payload_handable_handler
      ).tap { |block_payload_stager_instance|
        block_payload_stager_instance.architecturable_architectures = compatible_architectures.map { |compatible_architecture|
          Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: block_payload_stager_instance,
              architecture: compatible_architecture
          )
        }

        block_payload_stager_instance.platformable_platforms = compatible_platforms.map { |compatible_platform|
          Metasploit::Cache::Platformable::Platform.new(
              platformable: block_payload_stager_instance,
              platform: compatible_platform
          )
        }

        block_payload_stager_instance.save!
      }
    }
  end
end