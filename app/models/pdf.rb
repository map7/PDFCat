class Pdf < ActiveRecord::Base
	belongs_to :category
	validates_presence_of :pdfdate, :pdfname, :filename
end
