# Cell for rendering {Metasploit::Cache::Payload::Handler}.
class Metasploit::Cache::Payload::HandlerCell < Cell::ViewModel
  #
  # Properties
  #

  property :general_handler_type
  property :handler_type
  property :name

  #
  # Instance Methods
  #

  def show
    render
  end
end
