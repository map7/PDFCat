require File.dirname(__FILE__) + '/../test_helper'

class CategoriesControllerTest < ActionController::TestCase

  def setup
    login_as(:aaron)
    @first_id = categories(:bas).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:categories)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:category)
    assert assigns(:category).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:category)
  end

  def test_create
    assert_difference('Category.count') do
      # had to edit this
      post :create, :category => {:name => "ASIC",
        :description => "Australia Securities and Investments Commission"}
    end

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:category)
    assert assigns(:category).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_nothing_raised {
      Category.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Category.find(@first_id)
    }
  end
end
