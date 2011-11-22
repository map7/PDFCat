class Category < ActiveRecord::Base
  acts_as_nested_set
  
  belongs_to :firm
  has_many :pdfs

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :firm_id
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/

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

  def new_dir_exists?
    @client = []    # Initialise an array
    
    # Build an array of clients which this change will affect making sure each is unique.
    self.pdfs.each do|pdf|
      @clientname = pdf.client.name.downcase

      # If this is the first time we have come across this client then...
      unless @client.include?(@clientname)    
        @client << @clientname
        return pdf.category_dir_exists?(name.downcase) 
      end                       
    end
  end
end
