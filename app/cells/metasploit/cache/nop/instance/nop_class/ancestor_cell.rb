# Cell for rendering {Metasploit::Cache::Nop::Instance#nop_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Nop#architecturable_architectures}, `#authors` for
# {Metasploit::Cache::Nop::Instance#contributions}, `#default_action` for
# {Metasploit::Cache::Nop::Instance#default_action}, `#description` for
# {Metasploit::Cache::Nop::Instance#description}, `#license` for
# {Metasploit::Cache::Nop::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Nop::Instance#name}, and `#platform` for
# {Metasploit::Cache::Nop#platformable_platforms}.
class Metasploit::Cache::Nop::Instance::NopClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :architecturable_architectures
  property :contributions
  property :description
  property :licensable_licenses
  property :name
  property :nop_class
  property :platformable_platforms

  #
  # Instance Methods
  #

  def show(metasploit_class_relative_name:, superclass:)
    render locals: {
               metasploit_class_relative_name: metasploit_class_relative_name,
               superclass: superclass
           }
  end
end
