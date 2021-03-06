
module Freightrain

  def get_interface_builder
    return Toolkit::InterfaceBuilder.new    
  end
  
  module InterfaceBuilder

    def load_from_file(file_name, builder)
      if builder.file_found?(file_name)
        @widgets = builder.create_objects_from_file(file_name)
        builder.create_object_accessors(@widgets, self)
        builder.connect_signals do |signal|
          if self.respond_to? signal
            method(signal)
          end
        end
      end
    end

  end
end