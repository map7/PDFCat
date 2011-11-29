class Firm < ActiveRecord::Base

  has_many :categories
  has_many :clients
  has_many :pdfs
  has_many :users

  validates_presence_of :name
  validate :upload_dir_does_not_exist
  validate :store_dir_does_not_exist

  # Validate that the directory exists.
  def upload_dir_exists?
    File.exists?(upload_dir)
  end

  def upload_dir_does_not_exist
    errors.add("upload_dir", "does not exist") unless upload_dir_exists?
  end

  def store_dir_exists?
    File.exists?(store_dir)
  end

  def store_dir_does_not_exist
    errors.add("store_dir", "does not exist") unless store_dir_exists?
  end

  # Permissions
  def is_updatable_by(user)
    user.is_admin?
  end

  def is_deletable_by(user)
    user.is_admin?
  end

  def self.is_readable_by(user, object = nil)
    user.is_admin?
  end

  def self.is_creatable_by(user)
    user.is_admin?
  end

  def self.is_indexable_by(user, parent = nil)
    user.is_admin?
  end

  def clients_sorted
    clients.sort{ |a,b| a.name.downcase <=> b.name.downcase}
  end
  
  def categories_sorted
#    categories.roots.sort{ |a,b| a.name.downcase <=> b.name.downcase}    
    categories
  end
  
end
