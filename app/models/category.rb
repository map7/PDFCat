class Category < ActiveRecord::Base
	has_many :pdfs
	validates_presence_of :name
	validates_uniqueness_of :name

    def move_dir(newname)
		@client = []	# Initialise an array


		# Search all pdfs for this id
		@pdf = Pdf.find(:all, :conditions => {:category_id => id})

		# Build an array of clients which this change will affect making sure each is unique.
		@pdf.each do|p|
			@clientname = p.client.name.downcase

			unless @client.include?(@clientname)	# If this is the first time we have come across this client then...
				@client << @clientname
				
				# Checking if the directory exists
				@newdir = STORE_DIR + "/" +  @clientname + "/" + newname.downcase
				puts "Checking '" + @newdir + "'..."

				# Move the directory, I require some error checking here, must check if the directory exists.
				if File.exists?(@newdir)
					errors.add(newname," dir already exists, please change the clients name")	# Throw an error here
					return name
				end
			end
		end

		# Now go through each and move the directory
		@client.each do|p|
			@clientname = p.downcase

			@olddir = STORE_DIR + "/" + @clientname + "/" + name.downcase
			@newdir = STORE_DIR + "/" +  @clientname + "/" + newname.downcase

			puts "Moving '" + @olddir + "' to '" + @newdir + "'..."
			File.rename(@olddir,@newdir)
		end

		# Return the new client name
		newname

    end
end
