class Pdf < ActiveRecord::Base
  require 'fileutils'
  require 'find'
  require 'digest/md5'

  belongs_to :firm
  belongs_to :category
  belongs_to :client

  validates_presence_of :pdfdate, :pdfname, :filename, :category_id, :client_id
  validates_uniqueness_of :pdfname, :scope => [:pdfdate, :category_id, :client_id, :firm_id]

  validates_format_of :pdfname, :with => /^[^\/\\\?\*:|"<>]+$/, :message => "cannot contain any of the following characters: / \\ ? * : | \" < >"

  # validate :does_file_exist?  # Must check if the original filename exists not the new one


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

        # Calculate no of pages for current file
        # Takes too long.
#        filehash["pages"] = get_no_pages2(file)

        if File.ctime(file) > Time.now - 1.day and File.ctime(file).day == Time.now.day
          filehash["date"] = File.ctime(file).strftime '%H:%M'
        else
          filehash["date"] = File.ctime(file).strftime '%d/%m/%Y'
        end

        files << filehash
      end

      # Return files back to call.
      files
    end

  # Delete the physical file from the upload dir.
  def delete_file(filename)
    File.delete(filename) if File.exist?(filename)
  end

  # Return the full path of the final filename.
  def fullpath(current_firm)
    if path
      # If there is a path return this
      path + "/" + filename
    else
      # Otherwise return our premade one.
      current_firm.store_dir + "/" + client.name.downcase + "/" + category.name.downcase + "/" + filename
    end
  end

  # Create a md5
  def md5calc(current_firm)
    Digest::MD5.hexdigest(File.read(fullpath(current_firm)))
  end


  def get_new_filename(current_firm,original_file)
    # Format date
    @filedate = pdfdate.to_formatted_s(:file_format)

    # Format the new filename.
    @new_filename =  current_firm.store_dir + "/" + client.name.downcase + "/" + category.name.downcase + "/" + @filedate + "-" + pdfname + File.extname(original_file)
  end


  # Move file from upload to the store_dir area under client & category.
  def move_file(current_firm,original_path)

    # If the original_path isn't where it should be get the files modified path.
    unless File.exist?(original_path)
      original_path = self.fullpath(current_firm)
      self.path = nil
      self.save
    end

    # Make directories
    client_dir = current_firm.store_dir + "/" + client.name.downcase
    logger.warn("Mkdir #{client_dir}")
    Dir.mkdir(client_dir, 0775) unless File.exists?(client_dir)

    cat_dir = client_dir + "/" + category.name.downcase
    logger.warn("Mkdir #{cat_dir}")
    Dir.mkdir(cat_dir, 0775) unless File.exists?(cat_dir)

    @new_filename = get_new_filename(current_firm,original_path)

    logger.warn("Original filename = #{original_path}")
    logger.warn("     New filename = #{@new_filename}")

    if File.exist?(@new_filename)
      # Throw an error here
      errors.add(original_path,"New file already exists, please change the title")
      File.basename(original_path)      # Return the original filename
    else
      # Move the file.
      logger.warn("Moving #{original_path} to #{@new_filename}")
      FileUtils.mv(original_path, @new_filename)

      # Set the permissions on the file to 660 (-rw-rw----)
      logger.warn("chmod 0660 for #{@new_filename}")
      begin
        FileUtils.chmod 0660, @new_filename
      rescue
        logger.warn "Could not chmod #{@new_filename}"
      end


      # Set the group for the file
      unless current_firm.file_group.nil?
        logger.warn("chgrp #{current_firm.file_group} for #{@new_filename}")

        begin
          FileUtils.chown nil, current_firm.file_group, @new_filename
        rescue
          logger.warn "Could not chown #{@new_filename}"
        end
      end

      # Check if the old directory is now empty
      logger.warn("Check if the old dir is empty.")
      dir = File.dirname(original_path)
      dircheck = dir + '/*'

      # Delete the directory if it's empty, as long as it's not the same as the upload directory.
      unless dir == current_firm.upload_dir
        Dir.rmdir(dir) if Dir[dircheck].empty?
      end

      # Return the new filename
      File.basename(@new_filename)
    end
  end


  # Go through every pdf in the system and relink
  # Should be done in a cron job.
  def self.relink_all
    firms = Firm.find(:all)

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

          puts "Missing '#{pdfname}' for firm '#{current_firm.name}', client '#{client.name}'"

          return false # The file couldn't be found
        end
      end

    end
  end

  def rotate_file(current_firm)

    #x = system("date")
    #print x,"\n"

    @rotatefile = File.basename(fullpath(current_firm),'.pdf') + "-rotated.pdf"

    # Rotate anti-clockwise 90 degrees
    status = system("pdf90 --outfile '" + @rotatefile + "' '" + fullpath(current_firm) + "'")

    if status
      # Copy the new file over to the old name.
      File.delete(fullpath(current_firm))
      FileUtils.mv(@rotatefile, fullpath(current_firm))
      return true
    else
      logger.warn("Error command 'pdf90' could not run.")
      return false
    end
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

          puts(counter) if counter % 50 == 0

          # calculate md5 and store.
          md5=Digest::MD5.hexdigest(File.read(path)) if File.exists?(path)

          # Add to the hash table.
          files[md5] = path
        end
      end
    end

    files       # Return the hash of md5 and path.
  end




# Validators
  # Validate the the current file exists before moving it.
  def does_file_exist?(current_firm, oldclient, oldcategory)
    # If the old path exists or the files modified path exists return true.
    # Otherwise return an error.
    if File.exist?(current_firm.store_dir + "/" + oldclient.downcase + "/" + oldcategory.downcase + "/" + filename) or File.exist?(self.fullpath(current_firm))
      return true
    else
      errors.add(filename, " has gone missing, please relink!")
      return false
    end
  end

  def file_exist?(current_firm)
    if !File.exist?(fullpath(current_firm))
      errors.add(filename, " has gone missing!")
      return false
    end

    return true
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
end
