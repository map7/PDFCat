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

  default_scope :order => "upper(name)"
  
  def self.per_page
    10
  end
  
  def self.with_conditions(firm_id, page)
    Category.paginate(:page => page, :conditions => { :firm_id => firm_id })    
  end
  
  def category_dir 
    if level == 0
      name.downcase
    else
      "#{parent.name}/#{name}".downcase
    end
  end
  
  def move_dir(current_firm,oldname)
    pdfs.each do|pdf|
      @old_dir = "#{pdf.client_dir}/#{oldname.downcase}"
      @old_path = "#{@old_dir}/#{pdf.filename}"

      # Move the category directory to the new one.
      if File.exists?(pdf.full_dir)
        File.rename(@old_path, pdf.full_path)
      elsif File.exists?(@old_dir)
        File.rename(@old_dir,pdf.full_dir)
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
