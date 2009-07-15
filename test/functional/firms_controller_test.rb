require 'test_helper'

class FirmsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:firms)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_firm
    assert_difference('Firm.count') do
      post :create, :firm => { }
    end

    assert_redirected_to firm_path(assigns(:firm))
  end

  def test_should_show_firm
    get :show, :id => firms(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => firms(:one).id
    assert_response :success
  end

  def test_should_update_firm
    put :update, :id => firms(:one).id, :firm => { }
    assert_redirected_to firm_path(assigns(:firm))
  end

  def test_should_destroy_firm
    assert_difference('Firm.count', -1) do
      delete :destroy, :id => firms(:one).id
    end

    assert_redirected_to firms_path
  end
end
