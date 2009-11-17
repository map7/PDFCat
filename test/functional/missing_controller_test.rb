require File.dirname(__FILE__) + '/../test_helper'

class MissingControllerTest < ActionController::TestCase
  def setup
    login_as(:aaron)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pdfs)
  end
end
