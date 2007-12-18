class CreateDefaultCategory < ActiveRecord::Migration
  def self.up
	  Category.create :name => 'default'
  end

  def self.down
  end
end
