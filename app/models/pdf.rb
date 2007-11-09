class Pdf < ActiveRecord::Base
	belongs_to :cat
	validates_presence_of :pdfdate, :pdfname, :filename
end
