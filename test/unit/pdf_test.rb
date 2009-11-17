require File.dirname(__FILE__) + '/../test_helper'

class PdfTest < ActiveSupport::TestCase

  def setup
    @firm = firms(:one)
  end

  # Create
  def test_should_create_pdf
    pdf = Pdf.new

    pdf.pdfdate   = Time.now
    pdf.pdfname     = "Test pdf"
    pdf.filename    = "/home/map7/pdfcat_test_upload/DOC070731002030(0001).pdf"
    pdf.pdfnote     = "Testing"
    pdf.category_id   = 1
    pdf.client_id   = 1

    assert pdf.save
  end

  # Read
  def test_should_find_pdf
    pdf = pdfs(:bas).id

    assert_nothing_raised { Pdf.find(pdf) }
  end

  # Update
  def test_should_update_pdf
    pdf = pdfs(:bas)

    # You have to submit a filename here for some reason
    assert pdf.update_attributes(:pdfname => 'Test2', :filename => "/livedata/pdfcat_test_upload/DOC070731002030(0001).pdf" )
  end

  # Destroy
  def test_should_destroy_pdf
    pdf = pdfs(:bas)
    pdf.destroy

    assert_raise(ActiveRecord::RecordNotFound) { Pdf.find(pdf.id) }
  end

  # Test validations
  def test_should_not_create_invalid_pdf
    pdf = Pdf.new

    assert !pdf.valid?
    assert pdf.errors.invalid?(:pdfdate)
    assert_equal "can't be blank", pdf.errors.on(:pdfdate)

    assert !pdf.valid?
    assert pdf.errors.invalid?(:pdfname)

    # Invalid characters which we are searching for complicate things.
    #    assert_equal ["can't be blank","cannot contain any of the following characters: / \\ ? * : | \" < >\"\]>.a"], pdf.errors.on(:pdfname)

    assert !pdf.valid?
    assert pdf.errors.invalid?(:filename)
    assert_equal "can't be blank", pdf.errors.on(:filename)

    assert !pdf.save
  end

  def test_should_not_create_duplicate_pdf_pdfname
    pdf = Pdf.new

    pdf.pdfname = 'Notice Of Assessment'
    pdf.pdfdate = "2007-11-20"
    pdf.firm_id = 1
    pdf.category_id = 2
    pdf.client_id = 3

    assert !pdf.valid?
    assert pdf.errors.invalid?(:pdfname)
    assert_equal "has already been taken", pdf.errors.on(:pdfname)
    assert !pdf.save
  end

  def test_should_move_file
    pdf = pdfs(:bas)

    client = pdf.client.name.downcase
    cat = pdf.category.name.downcase
    file = @firm.store_dir + "/" + client + "/" + cat + "/" + pdf.pdfname

    filename = "20071107-2007 Tax Assessment - adrian.pdf"

    assert_equal filename, pdf.move_file(@firm, file)
  end

  def test_should_relink_all
    assert Pdf.relink_all
  end

  def test_should_relink_file
    pdf = pdfs(:bas)

    pdf.relink_file(firms(:one))
  end

  def test_should_relink_one_file
    pdf = pdfs(:bas)
    files = Pdf.store_dir_files(@firm)

    system("touch '#{pdf.fullpath(@firm)}'")
    pdf.md5 = pdf.md5calc(@firm)
    File.delete(pdf.fullpath(@firm))

    assert pdf.relink_one_file(@firm, files)
    assert !pdf.missing_flag
  end

  def test_should_not_relink_one_file
    pdf = pdfs(:bas)
    files = Pdf.store_dir_files(@firm)

    system("echo 'hi' > '#{pdf.fullpath(@firm)}'")
    pdf.md5 = pdf.md5calc(@firm)
    File.delete(pdf.fullpath(@firm))

    assert !pdf.relink_one_file(@firm, files)
    assert pdf.missing_flag
  end


  def test_should_rotate_pdf
    pdf = pdfs(:rotate)
    assert pdf.rotate_file(@firm)
  end

  def test_should_not_rotate_pdf
    pdf = pdfs(:bas)
    assert !pdf.rotate_file(@firm)
  end

  def test_should_get_pages
    pdf = pdfs(:rotate)
    assert_equal 1, pdf.get_no_pages(@firm).to_i
  end

  def test_should_send_email
    pdf = pdfs(:rotate)

    assert pdf.send_email(firms(:one).id, users(:aaron).id,"michael@dtcorp.com.au", "test", "test body")
  end

  # 18 page pdf.
  def test_should_send_big_email
    pdf = pdfs(:big)

    assert pdf.send_email(firms(:one).id, users(:aaron).id,"michael@dtcorp.com.au", "test", "test body")
  end



  # validators
  def test_does_file_exist
    assert pdfs(:rotate).file_exist?(@firm)
  end

  def test_does_not_file_exist
    assert !pdfs(:bas).file_exist?(@firm)
  end



=begin
  # This test validation doesn't work!
  def test_filename_should_not_exist_pdf
    pdf = Pdf.new
    pdf.pdfname = 'Notice Of Assessment2'
    pdf.pdfdate = "2007-11-10"
    pdf.filename = "does_not_exist"
    pdf.category_id = 1
    pdf.client_id = 3

    assert !pdf.valid?
    assert pdf.errors.invalid?(:filename)
#   assert_equal "has already been taken", pdf.errors.on(:filename)
    assert !pdf.save
  end
=end
end
