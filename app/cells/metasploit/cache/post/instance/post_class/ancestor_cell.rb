# Cell for rendering {Metasploit::Cache::Post::Instance#post_class}
# {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#contents}.
#
# In addition to content from {Metasploit::Cache::Module::AncestorCell} and
# {Metasploit::Cache::Direct::Class::AncestorCell}, it also includes `#arch` for
# {Metasploit::Cache::Post#architecturable_architectures}, `#authors` for
# {Metasploit::Cache::Post::Instance#contributions}, `#default_action` for
# {Metasploit::Cache::Post::Instance#default_action}, `#description` for
# {Metasploit::Cache::Post::Instance#description}, `#license` for
# {Metasploit::Cache::Post::Instance#licensable_licenses} {Metasploit::Cache::Licensable::Licenses#license}s,
# `#name` for {Metasploit::Cache::Post::Instance#name}, and `#platform` for
# {Metasploit::Cache::Post#platformable_platforms}.
class Metasploit::Cache::Post::Instance::PostClass::AncestorCell < Cell::ViewModel
  include Metasploit::Cache::AncestorCell

  #
  # Properties
  #

  property :actions
  property :architecturable_architectures
  property :post_class
  property :contributions
  property :default_action
  property :description
  property :disclosed_on
  property :licensable_licenses
  property :name
  property :platformable_platforms
  property :privileged
  property :referencable_references

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
