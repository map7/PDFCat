class Pdf < ActiveRecord::Base
	belongs_to :category
	belongs_to :client

	validates_presence_of :pdfdate, :pdfname, :filename
	validate :does_file_exist

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

	def delete_file(filename)
		File.delete(filename)
	end

	def move_file
		# Make directories
		Dir.mkdir(STORE_DIR + "/" + client.name.downcase) unless File.exists?(STORE_DIR + "/" + client.name.downcase)
		Dir.mkdir(STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase) unless File.exists?(STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase)

		# Format date
		@filedate = pdfdate.year.to_s + pdfdate.month.to_s + pdfdate.day.to_s
		
		# Format the new filename.
		#@new_filename =  STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase + "/" + File.basename(filename)	
		@new_filename =  STORE_DIR + "/" + client.name.downcase + "/" + category.name.downcase + "/" + @filedate + "-" + pdfname + File.extname(filename)

		if File.exist?(@new_filename)
			# Throw an error here
			errors.add(filename,"New file already exists, please change the title")

			# Return the original filename
			filename
		else
			# Move the file.
			File.rename(filename, @new_filename)
			
			# Return the new filename
			@new_filename
		end

	end

	# Validators
	def file_exist
		File.exist?(filename)
	end
	
	def does_file_exist
		errors.add("Filename") if !file_exist
	end
		
	
end
