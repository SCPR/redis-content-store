$:.push File.expand_path("../lib", __FILE__)

require "redis-content-store/version"

Gem::Specification.new do |s|
  s.name        = "redis-content-store"
  s.version     = RedisContentStore::VERSION
  s.authors     = ["Eric Richardson", "Bryan Ricker"]
  s.email       = ["bricker@scpr.org"]
  s.homepage    = "https://github.com/scpr/secretary-rails"
  s.license     = "MIT"
  s.summary     = "Content-aware caching for Rails"
  s.description = "Content-aware caching for Rails"

  s.files = Dir["{lib}/**/*"] +
            ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_runtime_dependency "redis-activesupport", [">= 3.2.0", "< 5"]
end
