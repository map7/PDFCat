class Pdf < ActiveRecord::Base
	belongs_to :category
	belongs_to :client

	validates_presence_of :pdfdate, :pdfname, :filename

    def list_files
        require 'find'

        files = Array.new

        dir = "/livedata/pdfcat_test_upload"

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
end
