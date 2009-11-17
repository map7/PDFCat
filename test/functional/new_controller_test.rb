require File.dirname(__FILE__) + '/../test_helper'

class NewControllerTest < ActionController::TestCase
  def setup
    login_as(:aaron)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:files)
  end

  def test_should_destroy_file
    firm = firms(:one)
    filename = "#{firm.upload_dir}/temp.pdf"
    system("touch #{filename}")

    get :destroy, :filename => filename
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end
end
