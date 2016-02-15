class Category < ActiveRecord::Base
  acts_as_nested_set
  
  belongs_to :firm
  has_many :pdfs
  has_many :clients, :through => :pdfs

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :firm_id
  validates_format_of :name, :with => /^[(|)|A-Z|a-z|0-9][,|&|(|)|'| |.|\-|A-Z|a-z|0-9]+$/

  default_scope :order => "lft"
  
  after_save :sort_categories
  
  before_destroy :check_pdfs
  
  
  def sort_categories
    if self.child?
      next_cat=Category.find(:all,
                             :conditions=>["name > ? and firm_id = ? and parent_id = ?",
                                           self.name, self.firm_id, self.parent_id],
                             :order => :name,
                             :limit => 1)
    else
      next_cat=Category.find(:all,
                             :conditions=>["name > ? and firm_id = ? and parent_id is null",
                                           self.name, self.firm_id], :order => :name,
                             :limit => 1)
    end
    self.move_to_left_of(next_cat.first) unless next_cat.size == 0
  end
  
  def self.per_page
    10
  end
  
  def self.with_conditions(firm_id, page)
    Category.paginate(:page => page, :conditions => { :firm_id => firm_id })    
  end

  def level_name
    level == 0 ? name : "-- #{name}"
  end

  def category_dir
    if (level == 0 && parent_id == parent_id_was) || (level == 0 && parent_id == nil)
      name.downcase
    else
      "#{parent.name}/#{name}".downcase
    end
  end
  
  def prev_category_dir
    if level == 0 && parent_id_was == nil
      name_was.downcase
    else
      prev_parent = Category.find(parent_id_was)
      "#{prev_parent.name}/#{name_was}".downcase
    end
  end
  
  def move_dir
    pdfs.each do|pdf|
      new_dir = "#{pdf.client_dir}/#{category_dir}"
      new_path = "#{new_dir}/#{pdf.filename}"
      old_dir = "#{pdf.client_dir}/#{prev_category_dir}"
      old_path = "#{old_dir}/#{pdf.filename}"

      # Move the category directory to the new one.
      if File.exists?(new_dir) and File.exists?(old_path)
        File.rename(old_path, new_path)
      elsif File.exists?(old_dir)
        File.rename(old_dir,new_dir)
      end

      pdf.relink_file(pdf.firm) if pdf.path
    end
  end

  private
  def check_pdfs
    if pdfs.count == 0
      return true
    else
      # Add the raw error message (ie: don't add 'is invalid' on the end)
      errors.add_to_base "Cannot delete Category as there are #{pdfs.count} document(s) attached"
      return false
    end
  end
  
end
