class Category < ActiveRecord::Base
  has_many :pdfs
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/
  validate :new_dir_exists?

    def move_dir(oldname)
    @client = []  # Initialise an array


    # Search all pdfs for this id
    @pdf = Pdf.find(:all, :conditions => {:category_id => id})

    # Build an array of clients which this change will affect making sure each is unique.
    @pdf.each do|p|
      @clientname = p.client.name.downcase

      unless @client.include?(@clientname)  # If this is the first time we have come across this client then...
        @client << @clientname

        @olddir = STORE_DIR + "/" + @clientname + "/" + oldname.downcase
        @newdir = STORE_DIR + "/" +  @clientname + "/" + name.downcase

        # Move the category directory to the new one.
        File.rename(@olddir,@newdir) if File.exists?(@olddir)
      end
    end
    end

  def new_dir_exists?
        @client = []    # Initialise an array

        # Search all pdfs for this id
        @pdf = Pdf.find(:all, :conditions => {:category_id => id})

        # Build an array of clients which this change will affect making sure each is unique.
        @pdf.each do|p|
            @clientname = p.client.name.downcase

            unless @client.include?(@clientname)    # If this is the first time we have come across this client then...
                @client << @clientname

                # Checking if the directory exists
                @newdir = STORE_DIR + "/" +  @clientname + "/" + name.downcase
                puts "Checking '" + @newdir + "'..."

                # Move the directory, I require some error checking here, must check if the directory exists.
                if File.exists?(@newdir)
                    errors.add(name," dir already exists, please change the clients name")   # Throw an error here
                    return
                end
            end
        end
  end

end
