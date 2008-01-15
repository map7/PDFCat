#!/usr/local/bin/ruby
# Find all missing files

# Connect to postgres database
require 'rubygems'
require 'postgres'
require 'fileutils'
require 'digest/md5'

# Define constants
STORE_DIR = "/livedata/pdfcat_test_clt"
#STORE_DIR = "/usr/tram/work/clt"

# Connect to postgres database
db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_development', 'pdfcat', 'pdfcat')
#db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_production', 'pdfcat', 'pdfcat')

# Query the database
res = db.exec('select c.name,cat.name,filename,p.id from clients as c,categories as cat,pdfs as p where p.client_id = c.id and p.category_id = cat.id ')

print "Calculating md5 for all files which exist and are in the database\n\n"

# Display every path to every file in the database
res.each do |row|
	@filepath=STORE_DIR + '/' + row[0].downcase + '/' + row[1].downcase + '/' + row[2]

	if File.exist?(@filepath)
		md5=Digest::MD5.hexdigest(File.read(@filepath))		# Create md5
		print @filepath, ",\t", md5

		id=row[3]	# pdfs id

		print "\tUpdating database..."
		db.exec("UPDATE pdfs SET md5 = '" + md5 + "' WHERE id=" + id)

		puts
	else
		print 'file path = ',@filepath,' DOES NOT EXIST!!!'
		puts
	end
	
#	row.each do |column|
#		print column
#		(20-column.length).times{print ' '}
#	end
	
end



