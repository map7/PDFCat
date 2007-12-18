class PdfsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def index
	# list all, sort by date (most recent at the top), 10 items per page.
    @pdf_pages, @pdfs = paginate(:pdfs, :order => 'pdfdate DESC', :per_page => 10)
	@no = -1	# Used for shorcuts
  end

  def search
	
	  # Search for the client first
	  # ILIKE is just for postgres insensitive searches, in mysql LIKE will do this
	#conditions = ["name LIKE ?", "%#{@params[:client]}%"] unless @params[:client].nil?
	conditions = ["name ILIKE ?", "%#{@params[:client]}%"] unless @params[:client].nil?

	@client = Client.find(:all, :conditions => conditions)
	
	if @client[0].nil? then

		# If there are no results from the search, then display all and an error message.
		@pdf_pages, @pdfs = paginate(:pdfs, :order => 'pdfdate DESC', :per_page => 10)
		flash[:notice] = 'No client found by the name "' + @params[:client] + '"'

	else

		# Initialise string
		conditionstr = ''
		
		# Go through a loop of results from client and build our conditions for the pdf search
		@client.each do|clt|
			if conditionstr.blank? then
				conditionstr = "client_id = " + clt.id.to_s
			else
				conditionstr = conditionstr + " or client_id = " + clt.id.to_s
			end
		end

		# Add search functionality to the pdfs page.
		#conditions = ["client_id = ?", "#{@client[0].id}"] 
		conditions = [conditionstr] 
		  
		# Query the database
		@pdf_pages, @pdfs = paginate(:pdfs, :conditions => conditions, :order => 'pdfdate DESC', :per_page => 10)

	end if
	
	@no = -1	# Used for shorcuts

	# Render the index with the search criteria
	render :action => 'index'
  end

  def show
    @pdf = Pdf.find(params[:id])
	@id = params[:id]	# Used for shortcuts
  end

  def new
    @pdf = Pdf.new
    @pdf.filename = File.basename(params[:filename]) if params[:filename]
  end

  def create
    @pdf = Pdf.new(params[:pdf])
	
	# Get the category selected from the drop down box and assign this to the foriegn key in pdf table.
	@pdf.category = Category.find(params[:category]) unless params[:category].blank?

	# Get the client select from the drop down..
	@pdf.client = Client.find(params[:client]) unless params[:client].blank?

	# Move the file and set the new filename to be saved
	@pdf.filename = @pdf.move_file(UPLOAD_DIR + "/" + @pdf.filename) #if @pdf.file_exist

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
	
	# Store the old category and client
	@oldcategory = @pdf.category.name.downcase
	@oldclient = @pdf.client.name.downcase

	# Get the category selected from the drop down box and assign this to the foriegn key in pdf table.
	@pdf.category = Category.find(params[:category]) unless params[:category].blank?
	
	# Get the client select from the drop down..
	@pdf.client = Client.find(params[:client]) unless params[:client].blank?

	# Save the form to the table
    #if @pdf.errors.size == 0 and @pdf.update_attributes(params[:pdf])
    if @pdf.does_file_exist?(@oldclient, @oldcategory) and @pdf.update_attributes(params[:pdf])
		flash[:notice] = 'Pdf was successfully updated.'
		redirect_to :action => 'show', :id => @pdf

		# Move the actual file
		@filename = @pdf.move_file(STORE_DIR + "/" + @oldclient + "/" + @oldcategory + "/" + @pdf.filename)

		# Write changes of the filename back to the pdf object.
		@pdf.update_attribute(:filename, @filename)
		
    else
		render :action => 'edit'
    end
  end

  def destroy
	# delete the physical file.
	File.delete(Pdf.find(params[:id]).fullpath)
	
	# delete the database record
    Pdf.find(params[:id]).destroy
	
    redirect_to :action => 'index'
  end


	# Allow user to open up new files
    def attachment_new
    	send_file(params[:filename],
			:type         =>  'application/pdf',
			:disposition  =>  'attachment'
		)
    end

	# Allow user to open up files already stored in the database
    def attachment
		@pdf = Pdf.find(params[:id])

    	send_file(@pdf.fullpath,
			:type         =>  'application/pdf',
			:disposition  =>  'attachment'
		)
    end


	# Email pdfs to clients
	def email_client
		pdf = Pdf.find(params[:id])

		PdfMailer.deliver_email_client(params[:email], params[:subject], params[:body],pdf)

		flash[:notice] = 'Your client has been sent this Pdf'

		redirect_to :action => 'show', :id => params[:id]
	end
end
