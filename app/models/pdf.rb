class Pdf < ActiveRecord::Base
  require 'fileutils'
  require 'find'
  require 'digest/md5'

  belongs_to :firm
  belongs_to :category
  belongs_to :client

  validates_presence_of :pdfdate, :filename, :category_id, :client_id, :description
  validates_uniqueness_of :pdfname, :scope => [:pdfdate, :category_id, :client_id, :firm_id]
  validates_format_of :description, :with => /^[^\/\\\?\*:|"<>]+$/, :message => "cannot contain any of the following characters: / \\ ? * : | \" < >"

  named_scope :joined, :joins => [:firm, :client, :category]
  default_scope :order => 'pdfdate DESC'

  def self.per_page
    10
  end

  # --------------------------------------------------------------------------------
  # Queries
  # --------------------------------------------------------------------------------
  
  # All PDFs for a given year
  def self.yearly_pdfs(year)
    Pdf.find(:all,
             :conditions => ["pdfdate >= ? AND pdfdate <= ?",
                             Date.parse("#{year}-01-01"),
                             Date.parse("#{year}-12-31")])
  end

  # --------------------------------------------------------------------------------
  # Display functions
  # --------------------------------------------------------------------------------
  def business_name_cap
    business_name.split.map(&:capitalize).join(' ')
  end
  
  def contact_cap
    contact.split.map(&:capitalize).join(' ')
  end

  def pdfdate_formatted
    pdfdate.strftime("#{pdfdate.day.ordinalize} %b %Y")
  end

  def pdfname_format
    self.pdfname = description.strip
  end

  def client_name
    client.name.downcase if client
  end

  def category_name
    if category.nil?
      self.update_attribute(:category, firm.categories.first)
    end
    category.try(:category_dir)
  end

  # --------------------------------------------------------------------------------
  # File functions
  # --------------------------------------------------------------------------------
  def get_new_filename2
    "#{pdfname}#{File.extname(full_path)}".gsub(/ /,"_")
  end
  
  # --------------------------------------------------------------------------------
  # Directory functions
  # --------------------------------------------------------------------------------
  def client_dir
    if client_name
      self.firm.store_dir + "/" +  client_name
    else
      self.firm.store_dir
    end
  end

  def prev_full_dir
    from_client = Client.find_by_id(client_id_was)
    from_cat = Category.find_by_id(category_id_was)

    if from_client && from_cat
      if from_cat.level == 0

        "#{firm.store_dir}/#{from_client.name}/#{from_cat.name}".downcase
      else
        "#{firm.store_dir}/#{from_client.name}/#{from_cat.parent.name}/#{from_cat.name}".downcase
      end
    else
      firm.store_dir.downcase
    end

  end
  
  def full_dir
    if category
      "#{client_dir}/#{category.category_dir}".downcase
    else
      client_dir.downcase      
    end
  end

  # Checking if the directory exists
  def category_dir_exists?(cat_name)
    File.exists?(client_dir + "/" + cat_name)
  end  

  def directory_empty?(dir)
    if File.exists?(dir)
      (Dir.entries(dir) - %w{ . .. }).empty?
    else
      return false
    end
  end
  
  def remove_prev_dir
    FileUtils.rmdir prev_full_dir if directory_empty?(prev_full_dir)
  end

  def thumbnail_full_dir
    "#{Rails.root}/public/images/thumbnails"
  end

  # --------------------------------------------------------------------------------
  # Path functions
  # --------------------------------------------------------------------------------
  def prev_full_path
    path_was ? "#{path_was}/#{filename}" : "#{prev_full_dir}/#{filename}"
  end
  
  def new_full_path
    "#{full_dir}/#{get_new_filename2}"
  end
  
  def full_path
    fullpath(firm)
  end
  
  # Return the full path of the final filename.
  # Keep this as it's referenced though out the app.
  def fullpath(current_firm)
    path ? "#{path}/#{filename}" : "#{full_dir}/#{filename}"
  end
  
  def prev_full_path_exists?
    File.exists?(prev_full_path)
  end

  def thumbnail_full_path
    "#{thumbnail_full_dir}/#{id}.png"
  end

  # --------------------------------------------------------------------------------
  # Move functions
  # --------------------------------------------------------------------------------
  
  # The new improved move_file routine, now with testing!
  def move_file2
    unless prev_full_path == new_full_path 
      if prev_full_path_exists?
        move_file_common(prev_full_path) 
        remove_prev_dir
      end
    end
  end
  
  def move_uploaded_file
    move_file_common(filename)
  end
  
  def move_file_common(from)
    unless does_new_full_path_exist?
      begin
        FileUtils.chown(nil,firm.file_group,from)
      rescue
        logger.warn "Could not set group #{firm.file_group} on #{from}"
      end
      
      FileUtils.mkdir_p(full_dir) unless File.exists?(full_dir)
      FileUtils.mv(from, new_full_path)

      self.filename = get_new_filename2
      self.path = nil
      self.md5 = Digest::MD5.hexdigest(File.read(new_full_path)) # md5 the file contents.
    end
  end
  
  # List uploaded files
  def self.list_files(current_firm)
    require 'find'

      files = Array.new

      # Get the constant variable from the environment.rb file
      # for each development/testing and production.
#      dir = UPLOAD_DIR
      dir = current_firm.upload_dir

      # Get a listing of all pdfs in the upload dir.
      allfiles = Dir.glob(dir + "/*.pdf")
      allfiles = allfiles.sort { | x,y | File.ctime(y) <=> File.ctime(x) }

      # Go through each file and make an array of hashes
      allfiles.each do |file|
        filehash = Hash.new
        filehash["name"] = file
        filehash["size"] = File.size(file)
        filehash["date"] = File.mtime(file).strftime '%H:%M %d/%m/%Y'
        # Calculate no of pages for current file-Takes too long.
        #filehash["pages"] = get_no_pages2(file)
        files << filehash
      end

      # Return files back to call.
      files
    end

  # Delete the physical file from the upload dir.
  def delete_file(filename)
    File.delete(filename) if File.exist?(filename)
  end

  # Create a md5
  def md5calc2(current_firm)
    md5 = Digest::MD5.hexdigest(File.read(fullpath(current_firm)))
  end

  def md5calc(current_firm)
    Digest::MD5.hexdigest(File.read(fullpath(current_firm)))
  end

  # --------------------------------------------------------------------------------
  # Relinking functions
  # --------------------------------------------------------------------------------
  # Go through every pdf in the system and relink
  # Should be done in a rake task and put in cron
  def self.relink_all
    firms = Firm.find(:all)

    # Go through each firm.
    firms.each do|firm|

      files = Pdf.store_dir_files(firm)
      puts("done!")

      pdfs = Pdf.find(:all, :conditions => {:firm_id => firm})
      pdfs.each do|pdf|
        logger.warn("Relinking #{pdf.pdfname}...")

        pdf.relink_one_file(firm, files)
      end
    end
  end

  # If the file is missing, then find the file and change the path and
  # filename in the database to suit.
  def relink_file(current_firm)
    # Get all the pdfs in the STORE_DIR and their md5
    files = Pdf.store_dir_files(current_firm)

    relink_one_file(current_firm, files)
  end

  def relink_one_file(current_firm, files)
    if client_name
      if File.exists?(fullpath(current_firm))
        update_attribute(:missing_flag, false)
      else

        # Don't bother unless there is a md5 tag.
        if md5

          # Match the missing file with it's new path
          @missing_file = files[md5]

          if @missing_file
            # Update database information
            update_attribute(:path, File.dirname(@missing_file))
            update_attribute(:filename, File.basename(@missing_file))
            update_attribute(:missing_flag, false)

            #        puts "Relinking '#{pdfname}' to #{@missing_file} for client #{client.name}"

            return true  # The file was found and fixed
          else
            update_attribute(:missing_flag, true)

            unless current_firm.nil? or client.nil?
              puts "Missing '#{pdfname}' for firm '#{current_firm.name}', client '#{client.name}'"
            end

            return false # The file couldn't be found
          end
        end
      end
    end
  end

  # --------------------------------------------------------------------------------
  # Pdf Utility functions
  # --------------------------------------------------------------------------------
  def rotate_file(current_firm)
    @rotatefile = File.basename(fullpath(current_firm),'.pdf') + "-rotated.pdf"

    # Rotate anti-clockwise 90 degrees
    status = system("pdf90 --outfile '" + @rotatefile + "' '" + fullpath(current_firm) + "'")

    if status
      # Copy the new file over to the old name.
      File.delete(fullpath(current_firm))
      FileUtils.mv(@rotatefile, fullpath(current_firm))
      PdfThumbnail.delay.update_thumbnail(self) # Take a new thumbnail
      return true
    else
      logger.warn("Error command 'pdf90' could not run.")
      return false
    end
  end

  # Find the total number of pages in a given set of PDFs
  def self.total_pages(pdfs)
    total = 0
    pdfs.each do |pdf|
      begin
        if File.exists?(pdf.full_path)
          r=PDF::Reader.new(pdf.full_path)
          total += r.page_count
        end
      rescue
        next
      end
    end
    return total
  end
  
  def get_no_pages(current_firm)
    get_no_pages2(fullpath(current_firm))
  end

  def get_no_pages2(the_fullpath)
    # Build the command
    @command = "pdftk '" + the_fullpath + "' dump_data | grep NumberOfPages | sed 's/.*: //'"

    # Execute the command and collect the data
    x = `#{@command}`

    # Return the number of pages
    x.chomp
  end

  # Split pdf into two parts 1-25, 25-end
  def split_pdf(current_firm)
    system("pdftk '" + fullpath(current_firm) + "' cat 1-" + SPLIT_NO + " output '" + File.dirname(fullpath(current_firm)) + "/" + File.basename(fullpath(current_firm), '.pdf') + "-part1.pdf'")
    system("pdftk '" + fullpath(current_firm) + "' cat " + (SPLIT_NO.to_i+1).to_s + "-end output '" + File.dirname(fullpath(current_firm)) + "/" + File.basename(fullpath(current_firm), '.pdf') + "-part2.pdf'")
  end


  # Go through each pdf in the STORE_DIR recurisively and store it's md5 and path in a hash
  def self.store_dir_files(current_firm)

    files = {}  # Initialise hash

    counter = 0

    # Find all files in the STORE_DIR
    Find.find(current_firm.store_dir) do |path|
      if FileTest.directory?(path)
        next  # Go to the next file if the current is a dir.
      else
        if File.extname(path) == ".pdf"

          counter += 1

          # Display some feedback to the relink_all script & flush the output to the console
          print(".")
          STDOUT.flush

          puts(counter) if counter % 200 == 0

          # calculate md5 and store.
          md5=Digest::MD5.hexdigest(File.read(path)) if File.exists?(path)

          # Add to the hash table.
          files[md5] = path
        end
      end
    end

    files       # Return the hash of md5 and path.
  end

  # Send email
  def send_email(current_firm_id, current_user_id, email, subject, body)
    current_firm = Firm.find(current_firm_id)
    current_user = User.find(current_user_id)

    # Detect how big the file is and split if pdf is over the SPLIT_NO contant value.
    # which is set in environments/production.rb
    if self.get_no_pages(current_firm).to_i > SPLIT_NO.to_i
      self.split_pdf(current_firm)      # split up into two parts

      # Send the email twice with a different attachement each time.
      @original_filename = self.filename
      self.filename = File.basename(@original_filename, '.pdf') + "-part1.pdf"
      PdfMailer.deliver_email_client(current_firm, current_user, email, subject, body,self)
      File.delete(self.fullpath(current_firm))

      self.filename = File.basename(@original_filename, '.pdf') + "-part2.pdf"
      PdfMailer.deliver_email_client(current_firm, current_user, email, subject, body,self)
      File.delete(self.fullpath(current_firm))

    else
      # Send one email as normal
      PdfMailer.deliver_email_client(current_firm, current_user, email, subject, body, self)    end
  end

  def ocr_file
    if self.ocr == true
      logger.info "#{full_path} already ocr'd"
    else
      logger.info "OCR #{full_path}"
      ocr_tmp="#{full_path}.tmp"
      cmd = "abbyyocr --multiProcessingMode Parallel --recognitionProcessesCount 32 --progressInformation --useNotOnlyPhysicalCPUCores -if \"#{full_path}\" -f PDF -of \"#{ocr_tmp}\""
      logger.info "#{cmd}"
      status = system(cmd)

      # Replace the old file with the OCR'd file.
      FileUtils.mv(full_path, "#{full_path}.bak")
      FileUtils.mv(ocr_tmp, full_path)
      File.delete("#{full_path}.bak")
      
      self.update_attribute(:ocr, true) if status
    end
  end
  
  # --------------------------------------------------------------------------------
  # Validators
  # --------------------------------------------------------------------------------
  # validate :does_file_exist?  # Must check if the original filename exists not the new one
  def self.with_conditions(query, page)
    @pdfs = Pdf.joined.paginate(:page => page, :conditions => query, :order => "pdfdate DESC, id")
  end

  def does_new_full_path_exist?
    if File.exists?(new_full_path) and full_path != new_full_path
      self.errors.add(:pdfname, " already exists, please change pdfname")
    end
    errors.count > 0
  end
  
  # Validate the the current file exists before moving it.
  def does_file_exist?(current_firm, oldclient, oldcategory)
    # If the old path exists or the files modified path exists return true.
    # Otherwise return an error.
    if File.exist?(current_firm.store_dir + "/" + oldclient.downcase + "/" + oldcategory.downcase + "/" + filename) or File.exist?(self.fullpath(current_firm))
      return true
    else
      errors.add(:filename, " has gone missing, please relink!")
      return false
    end
  end

  def file_exist?(current_firm)
    if !File.exist?(fullpath(current_firm))
      errors.add(:filename, " has gone missing!")
      return false
    end

    return true
  end

end
