class Category < ActiveRecord::Base
  acts_as_nested_set
  
  belongs_to :firm
  has_many :pdfs
  has_many :clients, :through => :pdfs

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :firm_id
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/

  default_scope :order => "lft,upper(name)"
  
  before_save :sort_categories
  
  def sort_categories
#    next_cat = Category.all(:conditions => ("name > ? and firm_id = ?", self.name, self.firm_id)
  end
  
  def self.per_page
    10
  end
  
  def self.with_conditions(firm_id, page)
    Category.paginate(:page => page, :conditions => { :firm_id => firm_id })    
  end
  
  def category_dir
    level == 0 ? name.downcase : "#{parent.name}/#{name}".downcase
  end
  
  def prev_category_dir
    if level == 0
      name_was.downcase
    else
      prev_parent = Category.find(parent_id_was)
      "#{prev_parent.name}/#{name_was}".downcase
    end
  end
  
  def move_dir
    pdfs.each do|pdf|
      old_dir = "#{pdf.client_dir}/#{prev_category_dir}"
      old_path = "#{old_dir}/#{pdf.filename}"

      # Move the category directory to the new one.
      if File.exists?(pdf.full_dir) and File.exists?(old_path)
        File.rename(old_path, pdf.full_path)
      elsif File.exists?(old_dir)
        File.rename(old_dir,pdf.full_dir)
      end
    end
  end
end
