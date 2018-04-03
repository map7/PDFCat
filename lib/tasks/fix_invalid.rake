namespace :pdfs do
  desc 'Go through all invalid pdfs and fix'
  task :fix_invalid => :environment do |t|
    limit = ENV['LIMIT'] || Pdf.count
    BACKUP_DIR = "/media/data/backup/pdfs"

    Pdf.find(:all, :conditions => {:missing_flag => false, :is_valid => false},:limit => limit).each do |pdf|
      if File.exists?(pdf.full_path)

        puts "Fixing #{pdf.full_path}"

        fixed_file="#{pdf.full_path}.fixed"
        backup_file="#{BACKUP_DIR}/#{pdf.id}-#{pdf.filename}"
        
        # Fix to a file called <filename>.fixed
        `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dSAFER -dNOPAUSE  -dBATCH -dBandBufferSpace=500000000 -dBufferSpace=1000000000 -sOutputFile="#{fixed_file}" "#{pdf.full_path}"`

        # Move original to backup area /media/data/backup/pdfs prefixed with the ID
        FileUtils.mv(pdf.full_path, backup_file)

        # Rename <filename>.fixed to <filename>
        FileUtils.mv(fixed_file, pdf.full_path)

        # Mark as valid
        pdf.update_attribute(:is_valid, true)

      end
    end
    
  end
end
