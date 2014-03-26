class MissingController < ApplicationController
  before_filter :login_required

  # This is to list and fixup the missing PDF's manually.
  #

  def index
    @pdfs = Pdf.all(:order => 'pdfdate DESC', :conditions => { :firm_id => current_firm, :missing_flag => true })
    @total = @pdfs.count
    @pdfs = @pdfs.paginate(:page => params[:page], :per_page => 10)
  end

end
