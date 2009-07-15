class Firm < ActiveRecord::Base

  has_many :users



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

end
