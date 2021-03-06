
module Freightrain

  class FreightBinding

    attr_accessor :data_source

    def initialize(widget, options)
      @cache          = :__NOVALUE
      @widget         = widget
      @property       = options[:property].to_s.split('.')
      @path           = options[:path].to_s.split('.')
      @converter      = ConverterFactory.create(options[:converter]) || DefaultConverter.new
      @force          = options[:force]
    end

    def update()
      begin
        value = get(data_source, @path)
        if @force || value != @cache
          set(@property, @converter.from(value), @widget)
          @cache = value
        end
      rescue Exception => ex
#        p "#{@widget.name} - update"
#        p ex.message
#        p @path
      end
    end

    def commit()
      begin
        value = get(@widget, @property)
        set(@path, @converter.to(value), data_source)
      rescue Exception => ex
#        p "#{@widget.name} - commit"
#        p ex.message
#        p @path
      end
    end

    private
    def get(source, path)
      my_path = path.clone
      return source.send(my_path[0]) if my_path.length == 1
      target = my_path.shift
      get(source.send(target), my_path)
    end

    def set(path, value, source)
      my_path = path.clone
      return source.send(my_path[0].to_s + "=",value) if my_path.length == 1
      target = my_path.shift
      set(my_path, value, source.send(target))
    end 
    
  end

end
