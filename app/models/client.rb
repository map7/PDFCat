class Client < ActiveRecord::Base
  has_many :pdfs
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/    # Validate correct for filenames
  validates_format_of :email, :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$|.*/i

  # On creating a new client this validation fails.
  validate :new_dir_exists?

  # Move the directory
  def move_dir(oldname)
    @olddir = STORE_DIR + "/" + oldname.downcase
    @newdir = STORE_DIR + "/" + name.downcase
    File.rename(@olddir,@newdir) if File.exists?(@olddir)
  end

  # Check if the new client directory already exists
  def new_dir_exists?

    if !id.nil?


      # Get the original client information
      client = Client.find(id)

      # Check if the name has changed.
      if name != client.name

        if File.exist?(STORE_DIR + "/" + name.downcase)
          # Check if the directory already exists.
          errors.add(name," dir already exists, please change the clients name")
        end

      end
    end
  end

end
