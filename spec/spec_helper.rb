$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'email_finder'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

