class CreateDefaultClient < ActiveRecord::Migration
  def self.up
	  Client.create :name => 'default'
  end

  def self.down
  end
end
