# Only covered when run with content tag
# :nocov:
shared_examples_for 'Metasploit::Cache::*::Instance::Load from relative_path_prefix' do |module_path_real_pathname, relative_path_prefix, tag, pending_reason_by_display_path: {}|
  context relative_path_prefix, tag do
    real_prefix_pathname = module_path_real_pathname.join(relative_path_prefix)

    rule = File::Find.new(
        ftype: 'file',
        pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}",
        path: real_prefix_pathname.to_path
    )

    rule.find do |real_path|
      real_pathname = Pathname.new(real_path)
      display_path = real_pathname.relative_path_from(real_prefix_pathname).to_s
      relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

      context display_path do
        let(:metasploit_framework) {
          double(
              'Metasploit Framework',
              datastore: double('Metasploit Framework datastore').tap { |datastore|
                allow(datastore).to receive(:[]).with(anything).and_return(nil)
              },
              events: double(
                  'Metasploit Framework events',
                  add_exploit_subscriber: nil
              )
          )
        }

        let(:module_ancestor) {
          module_ancestors.build(
              relative_path: relative_pathname.to_path
          )
        }

        let(:module_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              logger: logger,
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: module_ancestor
          )
        }

        options = {}

        pending_reason = pending_reason_by_display_path[display_path]

        if pending_reason
          options[:pending] = pending_reason
        end

        it 'loads Metasploit Module instance', options do
          expect(module_ancestor_load).to load_metasploit_module

          expect(direct_class_load).to be_valid
          expect(direct_class).to be_persisted

          expect(module_instance_load).to be_valid(:loading)

          module_instance_load.valid?

          unless module_instance.valid?
            # Only covered on failure
            fail "Expected #{module_instance.class} to be valid, but got errors:\n" \
                 "#{module_instance.errors.full_messages.join("\n")}\n" \
                 "\n" \
                 "Log:\n" \
                 "#{log_string_io.string}\n" \
                 "Expected #{module_instance_load.class} to be valid, but got errors:\n" \
                 "#{module_instance_load.errors.full_messages.join("\n")}"
          end

          expect(module_instance_load).to be_valid
          expect(module_instance).to be_persisted
        end
      end
    end
  end
end
# :nocov: