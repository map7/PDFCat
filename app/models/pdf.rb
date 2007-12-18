class Pdf < ActiveRecord::Base
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
		STORE_DIR+ "/" + client.name.downcase + "/" + category.name.downcase + "/" + filename
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
			File.rename(filename, @new_filename)

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

	# Validators
	def does_file_exist?
		errors.add(filename, " has gone missing!") if !File.exist?(fullpath)
	end
		
	
end
