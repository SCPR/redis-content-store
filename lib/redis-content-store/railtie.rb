module RedisContentStore
  class Railtie < Rails::Railtie
    initializer "redis-content-store" do |app|
      ActiveSupport.on_load :action_view do
        require "redis-content-store/action_view"
        include RedisContentStore::ActionView
      end
    end
  end
end
