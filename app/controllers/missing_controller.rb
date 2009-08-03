class MissingController < ApplicationController
  # This is to list and fixup the missing PDF's manually.
  #

  def index
    @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC', :conditions => { :firm_id => current_firm, :missing_flag => true })
  end

end
