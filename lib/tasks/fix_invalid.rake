# Fix to a file called <filename>.fixed
def fix_pdf(fixed_file, pdf)
  puts "Fixing #{pdf.full_path}"
  `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dSAFER -dNOPAUSE  -dBATCH -dBandBufferSpace=500000000 -dBufferSpace=1000000000 -sOutputFile="#{fixed_file}" "#{pdf.full_path}"`
end

# Make a backup and replace original with fixed file
def replace_original_with_fixed(backup_dir, fixed_file, pdf)
  backup_file="#{backup_dir}/#{pdf.id}-#{pdf.filename}"
  FileUtils.mv(pdf.full_path, backup_file)
  FileUtils.mv(fixed_file, pdf.full_path)
end

def mark_as_valid(pdf)
  pdf.update_attribute(:is_valid, true)
end

namespace :pdfs do
  desc 'Go through all invalid pdfs and fix'
  task :fix_invalid => :environment do |t|
    LIMIT = ENV['LIMIT'] || Pdf.count
    BACKUP_DIR = "/media/data/backup/pdfs"

    Pdf.find(:all, :conditions => {:missing_flag => false, :is_valid => false},:limit => LIMIT).each do |pdf|
      if File.exists?(pdf.full_path)
        fixed_file="#{pdf.full_path}.fixed"

        fix_pdf(fixed_file, pdf)
        replace_original_with_fixed(BACKUP_DIR, fixed_file, pdf)
        mark_as_valid(pdf)

      end
    end
    
  end
end
