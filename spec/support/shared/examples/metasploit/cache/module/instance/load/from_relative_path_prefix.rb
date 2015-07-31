shared_examples_for 'Metasploit::Cache::*::Instance::Load from relative_path_prefix' do |module_path_real_pathname, relative_path_prefix|
  context relative_path_prefix do
    real_prefix_pathname = module_path_real_pathname.join(relative_path_prefix)

    rule = File::Find.new(
        ftype: 'file',
        pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}",
        path: real_prefix_pathname.to_path
    )

    rule.find do |real_path|
      real_pathname = Pathname.new(real_path)
      display_pathname = real_pathname.relative_path_from(real_prefix_pathname)
      relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

      context display_pathname.to_s do
        let(:direct_class_load) {
          Metasploit::Cache::Direct::Class::Load.new(
              direct_class: direct_class,
              logger: logger,
              metasploit_module: module_ancestor_load.metasploit_module
          )
        }

        let(:module_ancestor) {
          module_ancestors.build(
              relative_path: relative_pathname.to_path
          )
        }

        let(:module_ancestor_load) {
          Metasploit::Cache::Module::Ancestor::Load.new(
              # This should match the major version number of metasploit-framework
              maximum_version: 4,
              module_ancestor: module_ancestor,
              logger: logger
          )
        }

        it 'loads Metasploit Module instance' do
          expect(module_ancestor_load).to load_metasploit_module

          expect(direct_class_load).to be_valid
          expect(direct_class).to be_persisted

          expect(module_instance_load).to be_valid(:loading)

          module_instance_load.valid?

          expect(module_instance).to be_valid
          expect(module_instance_load).to be_valid
          expect(module_instance).to be_persisted
        end
      end
    end
  end
end