class CreateDefaultCategory < ActiveRecord::Migration
  def self.up
    Category.create :name => 'default', :firm_id => 1
  end

  def self.down
  end
end
