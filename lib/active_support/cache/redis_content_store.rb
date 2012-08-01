require 'redis-activesupport'

module ActiveSupport
  module Cache
    class RedisContentStore < RedisStore
      
      SET_PREFIX = "obj:"
      FSET_PREFIX = "sobj:"
      
      #----------
      
      def expire_obj(obj)
        key = obj.respond_to?(:obj_key) ? obj.obj_key : obj
        Rails.logger.debug("expire_obj on #{key}")
        objs = @data.smembers(SET_PREFIX+key)
        if objs && !objs.empty?
          @data.del(*objs)
        end
      end
      
      #----------
      
      def read_entry(key,options={})
        super(key,options)
      end
      
      #----------
      
      def write_entry(key,entry,options={})

        # expire this key from existing sets
        fkeys = @data.smembers(FSET_PREFIX+key)
        if fkeys && !fkeys.empty?
          fkeys.each do |fobj|
            @data.srem(fobj,key)            
          end
        end
        
        # now add it to any objects passed in
        if options && options[:objects]
          keys = []
          options[:objects].each do |obj|
            okey = obj.respond_to?(:obj_key) ? obj.obj_key : obj.to_s
            Rails.logger.debug("adding #{key} to cache set for #{okey}")
            @data.sadd(SET_PREFIX+okey,key)
            keys << SET_PREFIX+okey
          end
          
          rewrite_set(key, keys)
        end
        
        # write our cache
        super(key,entry,options)
      end
      
      #----------

      def rewrite_set(key, keys)
        @data.del(FSET_PREFIX+key)
        @data.sadd(FSET_PREFIX+key,keys)
      end
      
      #----------
      
      def delete_entry(key, options)
        super(key,options)
      end
      
    end
  end
end
