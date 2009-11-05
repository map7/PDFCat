class NewController < ApplicationController
  before_filter :login_required

  # Create a upload variable to list files from the upload dir.
  def index
    @files = Pdf.list_files(current_firm)
    @files = @files.paginate :page => params[:page], :per_page => 10
    @no = -1  # Used for shorcuts
  end

  def destroy
    # Delete the physical file.
    @pdf = Pdf.new
    @pdf.delete_file(params[:filename])

    # Display a message back to the user and update the listing
    flash[:notice] = 'File (', params[:filename], ') successfully deleted'
    redirect_to :action => 'index'
  end
end
