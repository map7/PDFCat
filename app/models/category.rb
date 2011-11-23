class Category < ActiveRecord::Base
  acts_as_nested_set
  
  belongs_to :firm
  has_many :pdfs
  has_many :clients, :through => :pdfs

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :firm_id
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/

  # Just use the directory if it exists, don't deny people the right to use an existing dir.
  # validate :new_dir_available?   
  
  def move_dir(current_firm,oldname)
    @client = []  # Initialise an array

    # Search all pdfs for this id
    @pdf = Pdf.find(:all, :conditions => {:category_id => id})

    # Build an array of clients which this change will affect making sure each is unique.
    @pdf.each do|p|
      unless p.client.nil?
        @clientname = p.client.name.downcase

        # If this is the first time we have come across this client then...
        unless @client.include?(@clientname)  
          @client << @clientname

          @olddir = current_firm.store_dir + "/" + @clientname + "/" + oldname.downcase
          @newdir = current_firm.store_dir + "/" +  @clientname + "/" + name.downcase

          # Move the category directory to the new one.
          if File.exists?(@newdir)
            system("mv \"#{@olddir}/\"*.pdf \"#{@newdir}\"")
          else
            File.rename(@olddir,@newdir) if File.exists?(@olddir)
          end
        end
      end
    end
  end

  # Check if new proposed directory exists under any client with the category.
  def new_dir_available?
    if self.name_changed?
      self.clients.each do|client|
        if File.exists?("#{client.firm.store_dir}/#{client.name}/#{self.name}".downcase)
          errors.add(:name, "Category directory exists for some clients")
        end
      end
    end
    return errors.count == 0
  end
end
