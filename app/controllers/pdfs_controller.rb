class PdfsController < ApplicationController
  before_filter :login_required

  # Display unallocated files to select from
  def assign
    @pdf = Pdf.find(params[:id])
    @unallocated = MissingFile.unallocated_files(@pdf.firm)
  end

  # Assign the selected file to the pdf path
  def assign_file
    @pdf = Pdf.find(params[:id])

    unless params[:path].nil?
      @pdf.path = File.dirname(params[:path])
      @pdf.filename = File.basename(params[:path])
      @pdf.md5 = Digest::MD5.hexdigest(IO.read(params[:path]))
      @pdf.missing_flag = false
    else
      redirect_to assign_pdf_path(@pdf)
    end

    if @pdf.save
      redirect_to pdf_path(@pdf)
    else
      redirect_to assign_pdf_path(@pdf)
    end
  end

  def index
    @pdfs = Pdf.with_conditions(search_conditions, params[:page])
  end
  
  def show
    @pdf = Pdf.find(params[:id])  
  end
  
  def new
    @pdf = Pdf.new(:filename => params[:filename], :firm_id => current_firm.id)
  end
  
  def create
    @pdf = Pdf.new(params[:pdf])
    @pdf.pdfname_format
    @pdf.filename = File.basename(params[:filename]) if params[:filename]
    
    if @pdf.valid?
      @pdf.move_uploaded_file
      @pdf.save unless @pdf.does_new_full_path_exist?
    end
    
    if @pdf.errors.count == 0

      begin
        # Change access time for the client dir.
        FileUtils.touch("#{@pdf.client_dir}") if File.exists?(@pdf.client_dir)
      rescue
        logger.warn "Could not set utime on #{@pdf.client_dir}"
      end

      PdfThumbnail.delay.make_thumbnail(@pdf)
      flash[:notice] = "Pdf successfully created."
      redirect_to new_pdfs_path
    else
      render :new
    end
  end
  
  def edit
    @pdf = Pdf.find(params[:id])
  end
  
  def update
    @pdf = Pdf.find(params[:id])
    @pdf.attributes = params[:pdf]
    @pdf.pdfname_format

    if @pdf.valid?
      @pdf.move_file2
      @pdf.save unless @pdf.errors.count > 0
    end

    if @pdf.errors.count == 0
      begin
        File.utime(0, Time.now, @pdf.client_dir) if File.exists?(@pdf.client_dir)
      rescue
        logger.warn "Could not set utime on #{@pdf.client_dir}"
      end
      flash[:notice] = "Pdf was successfully updated."
      redirect_to @pdf
    else
      render :edit
    end
  end

  def destroy
    pdf = Pdf.find(params[:id])
    pdf.delete_file(pdf.fullpath(current_firm))
    pdf.delete
    flash[:notice] = "Pdf successfully deleted."
    redirect_to pdfs_path
  end
  
  
  
  

  # Allow user to open up new files
  def attachment_new
    send_file(params[:filename], :type => 'application/pdf', :disposition => 'attachment')
  end

  # Allow user to open up files already stored in the database
  def attachment
    @pdf = Pdf.find(params[:id])

    if @pdf.file_exist?(current_firm)
      send_file(@pdf.full_path,
                :type         =>  'application/pdf',
                :disposition  =>  'attachment')
    else
      flash[:notice] = "File #{@pdf.full_path} cannot be found, Please try relinking"
      redirect_to :action => 'show', :id => params[:id]
    end
  end

  # Search for the file compare the md5 and match.
  # This is incase a file was moved or renamed.
  def relink
    @pdf = Pdf.find(params[:id])
    
    if @pdf.relink_file(current_firm)
      flash[:notice] = "Relinking - please wait 5minutes whilst I find your file."
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

  # Manually OCR a file
  def ocr
    @pdf = Pdf.find(params[:id])

    if @pdf.ocr == true
      flash[:notice] = "File already OCR'd"
    else
      flash[:notice] = "OCR - please wait 5minutes whilst we run optical character recognition."
      @pdf.delay.ocr_file
    end
    render :partial => "showitem"
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

    cond_strings = [].tap do |strings|
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
