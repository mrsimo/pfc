require File.dirname(__FILE__) + '/../test_helper'
require 'configuration_controller'

# Re-raise errors caught by the controller.
class ConfigurationController; def rescue_action(e) raise e end; end

class ConfigurationControllerTest < Test::Unit::TestCase

  fixtures :configurations

  def setup
    @controller = ConfigurationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get "index"
    assert_response :success
    assert_template "edit"
    
  end
  
  
  def test_edit
    get "edit"
    assert_response :success
    assert_template "edit"
  end
  
  def test_update
    post "update", {:id=>1}
    assert_response :redirect
  end
  
  def test_create_new_configuration_when_none_exists
    Configuration.delete_all
    get "edit"
    assert_response :success
    assert_template "edit"
  end
  
end
