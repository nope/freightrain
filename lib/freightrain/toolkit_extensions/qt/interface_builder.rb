
module Freightrain

  module QtExtensions

    class InterfaceBuilder

      attr_reader :toplevel

      def initialize
        @builder = Qt::UiLoader.new
      end

      def file_found?(file_path)
        return File.exists?(file_path + ".ui")       
      end

      def create_objects_from_file(file_path)
        file = Qt::File.new(file_path + ".ui")
        file.open(Qt::File::ReadOnly)
        @toplevel = @builder.load(file)
        file.close
        widgets = get_all_objects(@toplevel).select do |widget|
          widget.objectName && widget.objectName != ""
        end.map
        return widgets
      end

      def create_object_accessors(widgets, view)
        widgets.each do |widget|
          name = widget.objectName
          view.instance_eval "def #{name}; @widgets.select { |w| w.objectName == '#{name}'  }.first ;end;"
        end
      end

      def connect_signals()
        @lightning_rod = Class.new(Qt::Widget)
        actions = get_all_objects(@toplevel).select { |action| action.kind_of? Qt::Action}
        actions.each do |action|
          @lightning_rod.slots("1" + action.objectName + "()")
          @lightning_rod.send(:define_method, "1" + action.objectName) do
            callback = yield("on_" + action.objectName)
            callback.call if callback
          end
        end
        decoy = @lightning_rod.new
        actions.each do |action|
#          Qt::Object.connect(action, SIGNAL('activated()'), decoy, SLOT("action.objectName" + "()"))
          action.connect(SIGNAL('activated()'), decoy, SLOT(action.objectName))
        end
      end

      private
      def get_all_objects(parent, objects = [])
        objects << parent
        parent.children.each do |child|
          get_all_objects(child, objects)
        end
        return objects
      end

    end

  end
end