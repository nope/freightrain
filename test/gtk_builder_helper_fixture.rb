# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'gtk_builder_helper.rb'
require 'mocha'

class TestView
  include GtkBuilderHelper

end

class GtkBuilderHelperFixture < Test::Unit::TestCase

  def test_loadFromFile_fileNotFound_DoNotThrow
    view = TestView.new
    view.load_from_file("nofile")
  end

  def test_loadFromFile_gtkbuilderfilepresent_addaClassMethodForeachWidget
    dirname = File.dirname(__FILE__)
    File.stubs(:dirname).returns(dirname)
    view = TestView.new
    view.load_from_file("testview.glade")
    assert(view.respond_to? :window)
  end


  
end
