class Client < ActiveRecord::Base
	has_many :pdfs
	validates_presence_of :name
	validates_uniqueness_of :name
	validates_format_of :email, :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$|.*/i 

	def move_dir(newname)
		@olddir = STORE_DIR + "/" + name.downcase
		@newdir = STORE_DIR + "/" + newname.downcase

		puts "Moving '" + @olddir + "' to '" + @newdir + "'..."

		if File.exist?(@newdir)
            # Throw an error here
            errors.add(newname," dir already exists, please change the clients name")

            # Return the original name
            name

		else
			# Move the directory
			File.rename(@olddir,@newdir)

			# Return the new client name
			newname

		end
	end

	
end
