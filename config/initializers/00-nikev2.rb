# config/initializers/nike_v2.rb
NikeV2.configure do |config|
  config.cache = {
    :cache =>   3600,
    :period =>  60,    # max frequency to call API
    :timeout => 120    # API response timeout
  }
end


