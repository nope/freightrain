
module Freightrain

  attr_accessor :toolkit
  attr_accessor :app_path

  def views_path
    base_path = File.join(@app_path, "views")
    toolkit_path = File.join(base_path, @toolkit.to_s)
    return toolkit_path if File.exist?(toolkit_path)
    return base_path
  end

  def load_extensions!()
    begin
      require File.dirname(__FILE__) + "/../extensions/#{@toolkit.to_s}/#{@toolkit.to_s}_bootstrapper.rb"
    rescue Exception => ex
      p "Could not load #{@toolkit}. Have you installed all the required libraries?"
      p "Exception : "
      p ex
    end
  end

  def start(viewmodel_name)
    @toolkit ||= :gtk
    load_extensions!
    auto_require!
    configure_container!
    yield if block_given?
    Toolkit.start_main_loop do
      Freightrain[(viewmodel_name.to_s + "_view_model").to_sym].show
    end
  end
  
end
