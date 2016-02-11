namespace :pdfs do
  desc 'Clean/merge hardly used categories into one called unallocated (Tramontana Accountants only)'
  task :clean, [:firm,:threshold] => :environment do |t, args|

    if args.count == 0
      puts "Please include an argument\n\n"
      
      puts "rake pdfs:clean[<firm name>,<threshold>]"
      puts "rake pdfs:clean[\"Tramontana Accountants\",20]\n\n"
      
      puts "NOTE: The default threshold is 10"

    else

      # Set threshold for the number of pdfs in a category
      threshold = args[:threshold] || 10
      
      # Get the firm
      firm=Firm.find_by_name(args[:firm])

      # Create category unallocated
      newcat=firm.categories.find_or_create_by_name("unallocated")

      # Get all the categories
      firm.categories.each do |cat|
        if cat.pdfs.count <= threshold.to_i
          puts "#{cat.name} has #{cat.pdfs.count} pdfs"

          # Step through all pdfs and move them to category unallocated
          cat.pdfs.each do |pdf|
            puts "Move #{pdf.id}-#{pdf.pdfname} to #{newcat.name}"

            pdf.category = newcat
            pdf.move_file2     # Move the file in correspondence to the new category
            pdf.save
          end
        end
      end
    end
  end
end
