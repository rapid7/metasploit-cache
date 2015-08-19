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
      create(
          :metasploit_cache_payload_stage_instance,
          :metasploit_cache_contributable_contributions,
          :metasploit_cache_licensable_licensable_licenses,
          # Must be after all association building traits so assocations are populated for writing contents
          :metasploit_cache_payload_stage_instance_payload_stage_class_ancestor_contents,
          # Hash arguments are overrides and available to all traits
          architecturable_architectures: compatible_architectures.map { |compatible_architecture|
            Metasploit::Cache::Architecturable::Architecture.new(
                architecture: compatible_architecture
            )
          },
          platformable_platforms: compatible_platforms.map { |compatible_platform|
            Metasploit::Cache::Platformable::Platform.new(
                platform: compatible_platform
            )
          }
      )
    }

    payload_stager_instance {
      create(
          :metasploit_cache_payload_stager_instance,
          :metasploit_cache_contributable_contributions,
          :metasploit_cache_licensable_licensable_licenses,
          :metasploit_cache_payload_handable_handler,
          # Must be after all association building traits so assocations are populated for writing contents
          :metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents,
          # Hash arguments are overrides and available to all traits
          architecturable_architectures: compatible_architectures.map { |compatible_architecture|
            Metasploit::Cache::Architecturable::Architecture.new(
                architecture: compatible_architecture
            )
          },
          platformable_platforms: compatible_platforms.map { |compatible_platform|
            Metasploit::Cache::Platformable::Platform.new(
                platform: compatible_platform
            )
          }
      )
    }
  end
end