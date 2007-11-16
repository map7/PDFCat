class Pdf < ActiveRecord::Base
	belongs_to :category
	belongs_to :client

	validates_presence_of :pdfdate, :pdfname, :filename

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
	
end
