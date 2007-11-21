require File.dirname(__FILE__) + '/../test_helper'

class PdfTest < Test::Unit::TestCase
  fixtures :pdfs

  # Create
  def test_should_create_pdf
	  pdf = Pdf.new

	  pdf.pdfdate	 	= Time.now
	  pdf.pdfname 		= "Test pdf"
	  pdf.filename 		= "/livedata/pdfcat_test_upload/DOC070731002030(0001).pdf"
	  pdf.pdfnote 		= "Testing"
	  pdf.category_id 	= 1
	  pdf.client_id 	= 1

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
	  assert_equal "can't be blank", pdf.errors.on(:pdfname)

	  assert !pdf.valid?
	  assert pdf.errors.invalid?(:filename)
	  assert_equal "can't be blank", pdf.errors.on(:filename)
	  
	  assert !pdf.save
  end

  def test_should_not_create_duplicate_pdf_pdfname
	  pdf = Pdf.new

	  pdf.pdfname = 'Notice Of Assessment'
	  pdf.pdfdate = "2007-11-20"
	  pdf.category_id = 2
	  pdf.client_id = 3

	  assert !pdf.valid?
	  assert pdf.errors.invalid?(:pdfname)
	  assert_equal "has already been taken", pdf.errors.on(:pdfname)
	  assert !pdf.save
  end

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
#	  assert_equal "has already been taken", pdf.errors.on(:filename)
	  assert !pdf.save
  end

end
