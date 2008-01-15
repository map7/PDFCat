#!/usr/local/bin/ruby
# Find all missing files

# Connect to postgres database
require 'rubygems'
require 'postgres'
require 'fileutils'
require 'find'
require 'digest/md5'


# Define constants
STORE_DIR = "/livedata/pdfcat_test_clt"
#STORE_DIR = "/usr/tram/work/clt"

def store_dir_files
	# Go through each file in the STORE_DIR recurisively
	#files = Array.new
	files = {}

	# Get the constant variable from the environment.rb file for each development/testing and production.
	dir = STORE_DIR

	Find.find(dir) do |path|
		if FileTest.directory?(path)
			next
		else
			if File.extname(path) == ".pdf"
				#files << path

				# calculate md5 and store.
				md5=Digest::MD5.hexdigest(File.read(path))

				files[md5] = path
			end
		end
	end

	files		# Return the hash of md5 and path.

#	files.each do |file|
#		print file
#		puts
#	end
	
	# Create a hash map md5 -> path
	
end

# Initialise hash variable
files = {}

# Connect to postgres database
db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_development', 'pdfcat', 'pdfcat')
#db = PGconn.connect('localhost', 5432, '', '', 'pdfcat_production', 'pdfcat', 'pdfcat')

# Query the database
res = db.exec('select c.name,cat.name,filename,p.md5 from clients as c,categories as cat,pdfs as p where p.client_id = c.id and p.category_id = cat.id ')

print "FILES WHICH DO NOT EXIST!!!\n\n"

# Place some headers for a table
print "Missing path"
(78).times{print ' '}	
print "Correct path"
puts

# Display every path to every file in the database
res.each do |row|
	@client = row[0].downcase
	@cat = row[1].downcase
	@filename = row[2]
	@md5 = row[3]

	@filepath=STORE_DIR + '/' + @client +'/'+ @cat +'/' + @filename


	unless File.exist?(@filepath)
#		print 'file path = ',@filepath
#		(100-@filepath.length).times{print ' '}		# put some spaces to build a table
#		print 'md5 = ', @md5, "\n"
#		puts

		# If the hash map of files and md5's available in the STORE_DIR is empty fill it, 
		# this saves time if we are not missing any files.
		files = store_dir_files if files.empty?

#		files.each do |key, value|
#			puts "#{key} equals #{value}"
#		end
#		puts
#		puts

		@missing_file = files[@md5]

		# Print a table of the old path compared to the correct path.
		print @filepath
		(90-@filepath.length).times{print ' '}

		if @missing_file
			print "= ",File.dirname(@missing_file), "/", File.basename(@missing_file), "\n"

			# Fix up the file

		else
			print "No file found which matches md5!\n"
		end
			

		
		# 
		# look up the hash map with the missing files md5 to get the path and fix it!

	end
	
#	row.each do |column|
#		print column
#		(20-column.length).times{print ' '}
#	end
	
end

