require File.dirname(__FILE__) + '/../test_helper'
require 'pdfs_controller'

# Re-raise errors caught by the controller.
class PdfsController; def rescue_action(e) raise e end; end

class PdfsControllerTest < Test::Unit::TestCase
  fixtures :pdfs

  def setup
    @controller = PdfsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = pdfs(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:pdfs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:pdf)
    assert assigns(:pdf).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:pdf)
  end

  def test_create
    num_pdfs = Pdf.count

    post :create, :pdf => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_pdfs + 1, Pdf.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:pdf)
    assert assigns(:pdf).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Pdf.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Pdf.find(@first_id)
    }
  end
end
