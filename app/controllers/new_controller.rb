class NewController < ApplicationController

	# Create a upload variable to list files from the upload dir.
    def index
        @upload = Pdf.new
    end

	# Allow user to open up new files
    def attachment
      send_file(params['filename'],
                :type             =>  'application/pdf',
                :disposition  =>  'attachment'
                )
    end

end
