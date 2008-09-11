class PdfsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ], :redirect_to => { :action => :index }

  # list all, sort by date (most recent at the top), 10 items per page.
  def index
    @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC')
  end

  def search

    session[:pdf_search] = params[:pdf] unless params[:pdf].nil?
    session[:client_search] = params[:client] unless params[:client].nil?

    @searchpdf = session[:pdf_search]
    @searchclient = session[:client_search]

    if @searchclient == "" or @searchclient.nil?
      # search just the pdfnames
      # @pdf_pages, @pdfs = paginate(:pdfs, :conditions => ["pdfname ILIKE ?", "%" + @searchpdf + "%"], :order => 'pdfdate DESC', :per_page => 10)
      @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC', :conditions => ["pdfname ILIKE ?", "%" + @searchpdf + "%"])

    else
      # search pdfnames linked to a client.
      logger.warn("client search:")
      logger.warn(@searchclient)

      @client = Client.find(:all, :conditions => ["name ILIKE ?", "%" + @searchclient + "%"])

      if @client.size == 0

        @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC', :conditions => ["pdfname ILIKE ?", "%" + @searchpdf + "%"])
      else

        # @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC', :conditions => ["pdfname ILIKE ? and client_id = ?", "%" + @searchpdf + "%", @client[0].id])

        @client.each do |client|
          logger.warn(client.name)
        end

        @pdfs = Pdf.paginate(:page => params[:page], :per_page => 10, :order => 'pdfdate DESC', :conditions => ["pdfname ILIKE ? and client_id = ?", "%" + @searchpdf + "%", @client[0].id])

      end


    end

    # Search for the client first
    # ILIKE is just for postgres insensitive searches, in mysql LIKE will do this
    #conditions = ["name LIKE ?", "%#{@params[:client]}%"] unless @params[:client].nil?
#    conditions = ["name ILIKE ?", "%#{@searchclient}%"]


#    @client = Client.find(:all, :conditions => conditions)

#    if @client.nil? then

      # If there are no results from the search, then display all and an error message.
#      @pdf_pages, @pdfs = paginate(:pdfs, :order => 'pdfdate DESC', :per_page => 10)
#      flash[:notice] = 'No client found by the name "' + @searchclient + '"'

#    else

      # Initialise string
#      conditionstr = ''

      # Go through a loop of results from client and build our conditions for the pdf search
#      @client.each do|clt|
#        if conditionstr.blank? then
#          conditionstr = "client_id = " + clt.id.to_s
#        else
#          conditionstr = conditionstr + " or client_id = " + clt.id.to_s
#        end
#      end

      # Add search functionality to the pdfs page.
      #conditions = ["client_id = ?", "#{@client[0].id}"]
#      conditions = [conditionstr]

      # Query the database
#      @pdf_pages, @pdfs = paginate(:pdfs, :conditions => conditions, :order => 'pdfdate DESC', :per_page => 10)


#    end if

      @no == -1  # Used for shorcuts

    # Render the index with the search criteria
    render :action => 'index'
  end

  def show
    @pdf = Pdf.find(params[:id])
    @id = params[:id] # Used for shortcuts
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
    if File.exist?(@pdf.get_new_filename(UPLOAD_DIR + "/" + @pdf.filename))

      # Throwing an error, Return with an error (throw error)
      @pdf.errors.add :name, "'" + @pdf.pdfname + "' already taken for this client, category and date."
      render :action => 'new'

    else
      # All is good, continue with cataloging pdf.
      @pdf.filename = @pdf.move_file(UPLOAD_DIR + "/" + @pdf.filename) #if @pdf.file_exist?

      # Create md5
      @pdf.md5 = @pdf.md5calc

      # Check for any errors before the save
      if @pdf.errors.size == 0 and @pdf.save
        flash[:notice] = 'Pdf was successfully created.'
        redirect_to :action => 'index'
      else
        render :action => 'new'
      end

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

      @pdf.update_attribute(:md5, @pdf.md5calc)

    else
      render :action => 'edit'
    end
  end

  def destroy
    # delete the physical file.
    @pdf = Pdf.find(params[:id])
    @pdf.delete_file(@pdf.fullpath)

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

    #if !@pdf.file_exist?
    # if !@pdf.relink_file
    #   flash[:notice] = 'File cannot be found, failed relinking!'
    #   redirect_to :action => 'index'
    # end
    #end

    if @pdf.file_exist?
      send_file(@pdf.fullpath,
                :type         =>  'application/pdf',
                :disposition  =>  'attachment'
                )
    else
      flash[:notice] = 'File cannot be found, Please try relinking'
      redirect_to :action => 'show', :id => params[:id]
    end
  end

  # Search for the file compare the md5 and match.
  # This is incase a file was moved or renamed.
  def relink
    @pdf = Pdf.find(params[:id])

    if @pdf.relink_file
      render :partial => "showitem"
      return true
    else
      render :partial => "showitem"
      return false
    end
  end

  # Rotate pdf 90 degrees clockwise
  def rotate
    @pdf = Pdf.find(params[:id])
    @status = @pdf.rotate_file

    render :text => "test"
    return @status

  end


  # Email pdfs to clients
  def email_client
    render :text => "Sending email, please wait..."

    @pdf = Pdf.find(params[:id])

    # Detect how big the file is and split if over 25pages.
    if @pdf.get_no_pages.to_i > SPLIT_NO.to_i
      # split up into two parts
      @pdf.split_pdf

      # Send the email twice with a different attachement each time.
      @original_filename = @pdf.filename
      @pdf.filename = File.basename(@original_filename, '.pdf') + "-part1.pdf"
      PdfMailer.deliver_email_client(params[:email], params[:subject], params[:body],@pdf)

      @pdf.filename = File.basename(@original_filename, '.pdf') + "-part2.pdf"
      PdfMailer.deliver_email_client(params[:email], params[:subject], params[:body],@pdf)

    else
      # Send one email as normal
      PdfMailer.deliver_email_client(params[:email], params[:subject], params[:body],@pdf)
    end

    return true
  end
end
