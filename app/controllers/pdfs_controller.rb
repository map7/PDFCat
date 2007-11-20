class PdfsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def index
    @pdf_pages, @pdfs = paginate :pdfs, :per_page => 10
  end

  def show
    @pdf = Pdf.find(params[:id])
  end

  def new
    @pdf = Pdf.new
    @pdf.filename = params[:filename]
  end

  def create
    @pdf = Pdf.new(params[:pdf])
	
	# Get the category selected from the drop down box and assign this to the foriegn key in pdf table.
	@pdf.category = Category.find(params[:category]) unless params[:category].blank?

	# Get the client select from the drop down..
	@pdf.client = Client.find(params[:client]) unless params[:client].blank?

	# Move the file and set the new filename to be saved
	@pdf.filename = @pdf.move_file	if @pdf.file_exist

	# Check for any errors before the save
	if @pdf.errors.size == 0 and @pdf.save
	  flash[:notice] = 'Pdf was successfully created.'
	  redirect_to :action => 'index'
	else
	  render :action => 'new'
	end

  end

  def edit
    @pdf = Pdf.find(params[:id])
  end

  def update
    @pdf = Pdf.find(params[:id])

	# Get the category selected from the drop down box and assign this to the foriegn key in pdf table.
	@pdf.category = Category.find(params[:category]) unless params[:category].blank?
	
	# Get the client select from the drop down..
	@pdf.client = Client.find(params[:client]) unless params[:client].blank?

	# Save the form to the table
    if @pdf.errors.size == 0 and @pdf.update_attributes(params[:pdf])
		flash[:notice] = 'Pdf was successfully updated.'
		redirect_to :action => 'show', :id => @pdf

		# Move the actual file
		@filename = @pdf.move_file

		# Write changes of the filename back to the pdf object.
		@pdf.update_attribute(:filename, @filename)
		
    else
		render :action => 'edit'
    end
  end

  def destroy
	# delete the physical file.
	File.delete(Pdf.find(params[:id]).filename)
	
	# delete the database record
    Pdf.find(params[:id]).destroy
	
    redirect_to :action => 'index'
  end


	# Allow user to open up new files
    def attachment
    	send_file(params['filename'],
			:type         =>  'application/pdf',
			:disposition  =>  'attachment'
		)
    end
end
