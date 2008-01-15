#!/usr/local/bin/ruby

# Connect to postgres database
require 'rubygems'
require 'postgres'
require 'fileutils'

# Define constants
#STORE_DIR = "/livedata/pdfcat_test_clt"
STORE_DIR = "/usr/tram/work/clt"

# Connect to postgres database
db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_development', 'pdfcat', 'pdfcat')

# Query the database
res = db.exec('select c.name,cat.name,filename from clients as c,categories as cat,pdfs')

# Display every path to every file in the database
res.each do |row|
	@filepath=STORE_DIR + '/' +row[0].downcase+'/'+row[1].downcase+'/'+row[2]
	print 'file path = ',@filepath

	FileUtils.chmod 0664, @filepath if File.exist?(@filepath)
	
#	row.each do |column|
#		print column
#		(20-column.length).times{print ' '}
#	end
	
	puts
end



