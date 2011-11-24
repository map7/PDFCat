class PdfsController < ApplicationController

  before_filter :login_required

  # make_resourceful do
  #   actions :all

  #   # list all, sort by date (most recent at the top), 10 items per page.
  #   before :index do

  #     @pdfs = Pdf.paginate(:all,
  #                          :order => 'pdfdate DESC',
  #                          :page => params[:page],
  #                          :per_page => 10,
  #                          :conditions => search_conditions,
  #                          :joins => [:firm, :client, :category])
  #   end

  #   before :new, :edit do
  #     @pdf.filename = File.basename(params[:filename]) if params[:filename]

  #     @clients = current_firm.clients.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #     @categories = current_firm.categories.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #   end

  #   before :create do
  #     # Get firm, category and client from drop downs.
  #     @pdf.firm_id = current_firm.id
  #     @pdf.category = Category.find(params[:category]) unless params[:category].blank?
  #     @pdf.client = Client.find(params[:client]) unless params[:client].blank?

  #     # Move the file and set the new filename to be saved
  #     if File.exist?(@pdf.get_new_filename(current_firm,current_firm.upload_dir + "/" + @pdf.filename))

  #       # Throwing an error, Return with an error (throw error)
  #       @pdf.errors.add :name, "'" + @pdf.pdfname + "' already taken for this client, category and date."

  #       @clients = current_firm.clients.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #       @categories = current_firm.categories.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #     end
  #   end

  #   after :create do
  #     # Now that the pdf has been validated we can move the pdf
  #     @pdf.filename = @pdf.move_file(current_firm,current_firm.upload_dir + "/" + @pdf.filename)
  #     # Create md5
  #     @pdf.md5 = @pdf.md5calc(current_firm)
  #     @pdf.save
  #   end

  #   response_for :create do
  #     redirect_to :action => 'index'
  #   end

  #   response_for :create_fail do
  #     @clients = current_firm.clients.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #     @categories = current_firm.categories.sort{ |a,b| a.name.upcase <=> b.name.upcase}
  #     render :action => 'new'
  #   end

  #   before :update do
  #     # Store the old category and client
  #     @oldcategory = @pdf.category.name.downcase
  #     @oldclient = @pdf.client.name.downcase

  #     # Get the category selected from the drop down box and assign this to the foriegn key in pdf table.
  #     @pdf.category = Category.find(params[:pdf][:category_id]) unless params[:pdf][:category_id].blank?

  #     # Get the client select from the drop down..
  #     @pdf.client = Client.find(params[:pdf][:client_id]) unless params[:client_id].blank?

  #     pdf_exist = @pdf.does_file_exist?(current_firm, @oldclient, @oldcategory)

  #     unless pdf_exist
  #       @pdf.errors.add :name, "'" + @pdf.pdfname + "' already taken for this client, category and date."
  #     end
  #   end

  #   response_for :update do
  #     flash[:notice] = 'Pdf was successfully updated.'
  #     redirect_to :action => 'show', :id => @pdf

  #     if @pdf.client_id_changed? and @pdf.category_id_changed? and @pdf.filename == @pdf.get_new_filename(current_firm,@pdf.filename)
  #       # Nothing has changed leave the filename the same.
  #       @filename = @pdf.filename
  #     else
  #       # Move the file
  #       @filename = @pdf.move_file(current_firm, current_firm.store_dir + "/" + @oldclient + "/" + @oldcategory + "/" + @pdf.filename)

  #       # Write changes of the filename back to the pdf object.
  #       @pdf.update_attribute(:filename, @filename)
  #     end

  #     @pdf.update_attribute(:md5, @pdf.md5calc(current_firm))
  #   end

  #   response_for :update_fail do
  #     @clients = current_firm.clients.sort{ |a,b| a.name.downcase <=> b.name.downcase}
  #     @categories = current_firm.categories.sort{ |a,b| a.name.downcase <=> b.name.downcase}
  #     render :action => 'edit'
  #   end

  #   before :destroy do
  #     @pdf.delete_file(@pdf.fullpath(current_firm))
  #   end

  # end # make_resourceful

  def index
      @pdfs = Pdf.paginate(:all,
                           :order => 'pdfdate DESC',
                           :page => params[:page],
                           :per_page => 10,
                           :conditions => search_conditions,
                           :joins => [:firm, :client, :category])
  end
  
  def show
    @pdf = Pdf.find(params[:id])    
  end
  
  def new
    @pdf = Pdf.new(:filename => params[:filename])
    @pdf.firm = current_firm
    @clients, @categories = current_firm.clients_sorted, current_firm.categories_sorted
  end
  
  def create
    @pdf = Pdf.new(:filename => params[:filename])
    @pdf.md5calc2
    redirect_to new_pdfs_path
  end
  
  def edit
    @pdf = Pdf.find(params[:id])
    @clients, @categories = current_firm.clients_sorted, current_firm.categories_sorted
  end
  
  def update
    @pdf = Pdf.find(params[:id])
    @pdf.attributes = params[:pdf]

    if @pdf.valid?
      @pdf.move_file2
      unless @pdf.does_new_full_path_exist?
        @pdf.save
        redirect_to @pdf
      end 
    end

    if @pdf.errors.count > 0
      @clients, @categories = current_firm.clients_sorted, current_firm.categories_sorted
      render :action => "edit"
    end
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

    if @pdf.file_exist?(current_firm)
      send_file(@pdf.fullpath(current_firm),
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

    if @pdf.relink_file(current_firm)
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
    @status = @pdf.rotate_file(current_firm)

    render :partial => "showitem"
    return @status
  end

  # Show the email form.
  def email
    @pdf = Pdf.find(params[:id])
  end

  # Email pdfs to clients
  def email_client
    @pdf = Pdf.find(params[:id])
    @pdf.send_later(:send_email,current_firm.id, current_user.id, params[:email], params[:subject], params[:body])

    flash[:notice] = "Sent #{@pdf.pdfname} to #{params[:email]} and #{current_user.email}"
    redirect_to :action => 'index'
  end

  
  
  protected

  # Do the search using RESTful technics
  def search_conditions

    pdfname = "%%#{params[:pdfname]}%%"
    client_name = "%%#{params[:client]}%%"
    category_name = "%%#{params[:category]}%%"

    cond_strings = returning([]) do |strings|
    strings << "firms.id = #{current_firm.id}"
      strings << "pdfs.pdfname ilike '#{pdfname}'" unless params[:pdfname].blank?
      strings << "clients.name ilike '#{client_name}'" unless client_name.blank?
      strings << "categories.name ilike '#{category_name}'" unless category_name.blank?
    end

    if cond_strings.any?
      [ cond_strings.join(' and '), cond_strings ]
    else
      nil
    end
  end
end
