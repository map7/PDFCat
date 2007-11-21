require File.dirname(__FILE__) + '/../test_helper'
require 'pdfs_controller'

# Re-raise errors caught by the controller.
class PdfsController; def rescue_action(e) raise e end; end

class PdfsControllerTest < Test::Unit::TestCase
  fixtures :pdfs, :categories, :clients

  def setup
    @controller = PdfsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = pdfs(:notice).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:pdfs)
  end

  # correct if it can find the file.
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
	
	# Must create the file
	f = File.new("/livedata/pdfcat_test_upload/testfunctional.pdf","w")
		f.puts "Test file created by functional pdf test"
	f.close

	# Note pdfname has to be unique, so for each test up the number on the end of the name
    post :create, :pdf => {	:pdfdate => "2007-11-21",
							:pdfname => "testpdf8",
							:filename => "/livedata/pdfcat_test_upload/testfunctional.pdf",
   							:category_id => 1, 
							:client_id => 1	}

    assert_response :redirect
    assert_redirected_to :action => 'index'

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
	
	# create '/livedata/pdfcat_test_clt/fastline/tax/20071121-Notice Of Assessment.pdf'
	f = File.new("/livedata/pdfcat_test_clt/fastline/tax/20071121-Notice Of Assessment.pdf","w")
		f.puts "Test file created by functional pdf test"
	f.close
	
    assert_nothing_raised {
      Pdf.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Pdf.find(@first_id)
    }
  end
end
