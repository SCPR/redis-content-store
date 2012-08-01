module RedisContentStore
  module ActionView
    def content_cache(name,options=nil, &block)
      if controller.perform_caching
        safe_concat(fragment_for(name,options,&block))
      else
        yield
      end
      
      nil
    end
    
    def register_content(obj)
      if defined? @COBJECTS
        @COBJECTS << obj
      end
    end
    
    private
    def fragment_for(name,options=nil, &block)
      if fragment = controller.read_fragment(name, options)
        fragment
      else
        @COBJECTS = []
        fragment = capture(&block) || ''
        
        # If no content is registered, still write the fragment,
        # even though it won't expire.
        objects = @COBJECTS.empty? ? nil : @COBJECTS
        options = objects ? (options || {}).merge({:objects => objects}) : options
        
        controller.write_fragment(name,fragment,options)
        fragment
      end
    end
  end
end
