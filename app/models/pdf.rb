class Pdf < ActiveRecord::Base
	require 'fileutils'
	require 'find'
	require 'digest/md5'
	
	belongs_to :category
	belongs_to :client

	validates_presence_of :pdfdate, :pdfname, :filename, :category_id, :client_id
	validates_uniqueness_of :pdfname, :scope => [:pdfdate, :category_id, :client_id]
	validates_format_of :pdfname, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/
#	validate :does_file_exist?	# Must check if the original filename exists not the new one


	# List uploaded files
    def list_files
        require 'find'

        files = Array.new

		# Get the constant variable from the environment.rb file for each development/testing and production.
		dir = UPLOAD_DIR

        Find.find(dir) do |path|
            if FileTest.directory?(path)
                next
            else
                files << path
            end
        end

		# Return files back to call.
        files
    end

	# Delete the physical file from the upload dir.
	def delete_file(filename)
		File.delete(filename)
	end

	# Return the full path of the final filename.
	def fullpath
		if path
			# If there is a path return this
			path + "/" + filename		
		else
			# Otherwise return our premade one.
			STORE_DIR+ "/" + client.name.downcase + "/" + category.name.downcase + "/" + filename	
		end
	end

	# Create a md5
	def md5calc
		Digest::MD5.hexdigest(File.read(fullpath))
	end

	def move_file(original)

		# Make directories
		Dir.mkdir(STORE_DIR + "/" + client.name.downcase, 0775) unless File.exists?(STORE_DIR + "/" + client.name.downcase)
		Dir.mkdir(STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase, 0755) unless File.exists?(STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase)

		# Format date
		@filedate = pdfdate.to_formatted_s(:file_format)
		
		filename = original
		
		# Format the new filename.
		@new_filename =  STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase + "/" + @filedate + "-" + pdfname + File.extname(filename)

		if File.exist?(@new_filename)
			# Throw an error here
			errors.add(filename,"New file already exists, please change the title")

			# Return the original filename
			File.basename(filename)
		else
			# Move the file.
			FileUtils.mv(filename, @new_filename)

			# Set the permissions on the file to 664 (-rw-rw-r--)
			FileUtils.chmod 0664, @new_filename
			
			# Check if the old directory is now empty
			dir = File.dirname(filename) 
			dircheck = dir + '/*'

			# Delete the directory if it's empty, as long as it's not the same as the upload directory.
			unless dir == UPLOAD_DIR
				Dir.rmdir(dir) if Dir[dircheck].empty?
			end
			
			# Return the new filename
			File.basename(@new_filename)
		end
	end

	# If the file is missing, then find the file and change the path and filename in the database to suit.
	def relink_file
		# Get all the pdfs in the STORE_DIR and their md5
		files = store_dir_files		

		# Match the missing file with it's new path
        @missing_file = files[md5]	

		if @missing_file
			# Update database information
			update_attribute(:path, File.dirname(@missing_file))
			update_attribute(:filename, File.basename(@missing_file))

			return true  # The file was found and fixed
		else
			return false # The file couldn't be found
		end

	end

	def rotate_file

		#x = system("date")
		#print x,"\n"

		@rotatefile = File.basename(fullpath,'.pdf') + "-rotated.pdf"

		# Rotate anti-clockwise 90 degrees
		x = system("pdf90 --outfile '" + @rotatefile + "' '" + fullpath + "'")

		# Copy the new file over to the old name.
		File.delete(fullpath)
		FileUtils.mv(@rotatefile, fullpath)

	end

	# Go through each pdf in the STORE_DIR recurisively and store it's md5 and path in a hash
	def store_dir_files
		files = {}	# Initialise hash

		# Find all files in the STORE_DIR
		Find.find(STORE_DIR) do |path|
			if FileTest.directory?(path)
				next	# Go to the next file if the current is a dir.
			else
				if File.extname(path) == ".pdf"
					# calculate md5 and store.
					md5=Digest::MD5.hexdigest(File.read(path))
				
					# Add to the hash table.
					files[md5] = path
				end
			end
		end

		files       # Return the hash of md5 and path.
	end




# Validators
	# Validate the the current file exists before moving it.
	def does_file_exist?(oldclient, oldcategory)
		if !File.exist?(STORE_DIR + "/" + oldclient.downcase + "/" + oldcategory.downcase + "/" + filename)
			errors.add(filename, " has gone missing!") 
			return false
		end

		return true
	end

	def file_exist?
		if !File.exist?(fullpath)
			errors.add(filename, " has gone missing!") 
			return false
		end

		return true
	end
		
	
end
