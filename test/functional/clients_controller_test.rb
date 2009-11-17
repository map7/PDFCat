require File.dirname(__FILE__) + '/../test_helper'

class ClientsControllerTest < ActionController::TestCase

  def setup
    login_as(:aaron)
    @first_id = clients(:digitech).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:clients)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:client)
  end

  def test_create
    assert_difference('Client.count') do
      post :create, :client => {:name => "johnsmith", :email => "johnsmith@hotmail.com" }
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_nothing_raised {
      Client.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Client.find(@first_id)
    }
  end
end
