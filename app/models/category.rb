class Category < ActiveRecord::Base
	has_many :pdfs
	validates_presence_of :name
	validates_uniqueness_of :name
end
