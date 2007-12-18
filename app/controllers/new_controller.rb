class NewController < ApplicationController
	# Create a upload variable to list files from the upload dir.
    def index
        @upload = Pdf.new
		@no = -1	# Used for shorcuts
    end

	def destroy

		# Delete the physical file.
		@pdf = Pdf.new
		@pdf.delete_file(params[:filename])

		# Display a message back to the user and update the listing
		flash[:notice] = 'File (', params[:filename], ') successfully deleted'
		redirect_to :action => 'index'
	end
end
