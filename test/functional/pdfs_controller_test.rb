require File.dirname(__FILE__) + '/../test_helper'

class PdfsControllerTest < ActionController::TestCase

  def setup
    login_as(:aaron)
    @firm = firms(:one)
    @first_id = pdfs(:notice).id
  end

  def create_file
    @dir = "/home/map7/pdfcat_test_upload/"
    @filename = "testfunctional.pdf"
    @full_filename = @dir + @filename

    # Must create the file
    f = File.new(@full_filename,"w")
      f.puts "Test file created by functional pdf test"
    f.close
  end

  def create_store_file
    client = clients(:fastline).name.downcase
    category = categories(:tax).name.downcase
    store_file = @firm.store_dir + "/" + client + "/" + category + "/" + '20071121-Notice Of Assessment.pdf'

    # Must create the file
    f = File.new(store_file,"w")
      f.puts "Test file created by functional pdf test"
    f.close
  end

  def remove_file
    client = clients(:digitech).name.downcase
    category = categories(:bas).name.downcase
    store_dir = @firm.store_dir + "/" + client + "/" + category

    File.delete("#{store_dir}/20071121-testpdf.pdf")
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

    create_file()
    remove_file()

    # Note pdfname has to be unique, so for each test up the number on the end of the name
    post :create, :pdf => { :pdfdate => "2007-11-21",
      :pdfname => "testpdf",
      :filename => @filename,
      :category_id => 1,
      :client_id => 1 }

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
    create_store_file()

    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    create_file()

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
