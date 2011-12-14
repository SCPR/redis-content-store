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
        Rails.logger.debug("RCS starting block capture")
        @COBJECTS = []
        fragment = capture(&block)
        Rails.logger.debug("RCS done block capture: #{@COBJECTS}")
        controller.write_fragment(name,fragment,(options||{}).merge({:objects => @COBJECTS}))
        fragment
      end
    end
  end
end