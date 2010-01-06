
module Gtk

  class Layout
    include Freightrain::LayoutWidget

    attr_writer :viewmodel
    attr_reader :elements

    def setup
      @signals ||= {}
      selected_callback   = @signals[:selected]
      @signals[:selected] = lambda do |value|
                              elements.each do |item|
                                item.set_selection(item.value == value)
                              end
                              selected_callback.call(value) if selected_callback
                            end
      @elements ||= []
      #TODO: clean this mess
      @display_logic = lambda do |widget, elements, enumerable|
        height = elements.length
        delta = enumerable.length - elements.length
        delta.abs.times do
          if delta > 0
            item = widget.get_new_item
            widget.put(item.control, 0, item.control.height_request * height)
            elements << item
            height += 1
          else
            item = self.children.last
            self.remove(item)
            elements.delete_if {|element| element.control == item }
          end
        end
        height_factor = self.get_new_item.control.height_request
        self.height = elements.length * height_factor
      end
      @ready = true
    end

    def display_logic(enumerable)
      @display_logic.call(self, @elements, enumerable)
    end

    def set_display_logic
      @display_logic = lambda do |widget, elements, enumerable|
        yield(widget, elements, enumerable)
      end
    end

    def elements=(enumerable)
      setup unless @ready      
      display_logic(enumerable)
      (0...@elements.length).each do |index|
        @elements[index].value = enumerable[index]
      end
    end

    def bind(options)
      if options[:property].to_s == "elements"
        @viewmodel          = (options[:element].to_s + "_element_view_model").to_sym
        options[:force]     = true
      end
      super(options)
    end

    def get_new_item
      item = Freightrain[@viewmodel]
      item.signals.each do |key, signal|
       signal.connect(@signals[key]) if @signals[key]
      end
      return item
    end
      
  end

end

