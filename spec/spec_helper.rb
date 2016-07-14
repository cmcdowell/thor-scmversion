require 'simplecov'

require 'rspec'

# needs to be done before any app code is required
SimpleCov.start do
    add_filter 'spec/'
end

RSpec.configure do |config|
    config.mock_with :rspec
end

require 'thor-scmversion'
