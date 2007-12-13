class Client < ActiveRecord::Base
	has_many :pdfs
	validates_presence_of :name
	validates_uniqueness_of :name
	validates_format_of :email, :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$|.*/i 
end
