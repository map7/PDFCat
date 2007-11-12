class Pdf < ActiveRecord::Base
	belongs_to :category
	belongs_to :client

	validates_presence_of :pdfdate, :pdfname, :filename
end
