# Namespace for post Metasploit Module cache metadata, including from
# {Metasploit::Cache::Post::Ancestor ancestors} and {Metasploit::Cache::Post::Class classes}.
module Metasploit::Cache::Post
  extend ActiveSupport::Autoload

  autoload :Ancestor
  autoload :Class
end