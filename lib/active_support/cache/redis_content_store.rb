require 'redis-activesupport'

module ActiveSupport
  module Cache
    class RedisContentStore < RedisStore

      SET_PREFIX    = "obj:"
      FSET_PREFIX   = "sobj:"

      #----------

      def expire_obj(obj)
        key = obj.respond_to?(:obj_key) ? obj.obj_key : obj

        owners = @data.smembers(SET_PREFIX + key)

        if owners.present?
          @data.del(*owners)
        end
      end

      #----------

      def write_entry(key, entry, options={})
        # expire this key from existing sets
        fragment_keys = @data.smembers(FSET_PREFIX + key)

        if fragment_keys.present?
          fragment_keys.each { |fragment_key| @data.srem(fragment_key, key) }
        end

        # now add it to any objects passed in
        if options[:objects]
          keys = []

          Array(options[:objects]).each do |obj|
            obj_key = obj.respond_to?(:obj_key) ? obj.obj_key : obj.to_s

            @data.sadd(SET_PREFIX + obj_key, key)
            keys << SET_PREFIX + obj_key
          end

          rewrite_set(key, keys)
        end

        # write our cache
        super
      end

      #----------

      def rewrite_set(key, keys)
        @data.del(FSET_PREFIX + key)
        @data.sadd(FSET_PREFIX + key, keys)
      end
    end
  end
end
