require File.dirname(__FILE__) + '/../test_helper'
require 'new_controller'

# Re-raise errors caught by the controller.
class NewController; def rescue_action(e) raise e end; end

class NewControllerTest < Test::Unit::TestCase
  def setup
    @controller = NewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
