require 'simplecov'

require 'rspec'

# needs to be done before any app code is required
SimpleCov.start do
    add_filter 'spec/'
end

RSpec.configure do |config|
    config.mock_with :rspec
    config.filter_run_excluding :p4 => true
end

require 'thor-scmversion'
