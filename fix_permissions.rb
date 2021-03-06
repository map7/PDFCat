#!/usr/local/bin/ruby
#
# Fix up permissions on all the pdfs
#
# Connect to postgres database
require 'rubygems'
require 'postgres'
require 'fileutils'

# Define constants
#STORE_DIR = "/livedata/pdfcat_test_clt"
STORE_DIR = "/usr/tram/work/clt"

# Connect to postgres database
db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_production', 'pdfcat', 'pdfcat')

# Query the database
res = db.exec('select c.name,cat.name,filename from clients as c,categories as cat,pdfs as p where p.client_id = c.id and p.category_id = cat.id ')

# Display every path to every file in the database
res.each do |row|
  @filepath="#{STORE_DIR}/#{row[0].downcase}/#{row[1].downcase}/#{row[2]}"
  print 'file path = ',@filepath

  if File.exist?(@filepath)
    FileUtils.chmod "u=wrx,g=swrx", @filepath
    FileUtils.chown 'map7','tram', @filepath
  else
    print "FILE DOES NOT EXIST!!!"
  end

  #	row.each do |column|
  #		print column
  #		(20-column.length).times{print ' '}
  #	end

  puts
end
