require 'spec_helper'

RSpec.describe Metasploit::Model::Search::Group::Base do
  it { should ensure_length_of(:children).is_at_least(1) }
end