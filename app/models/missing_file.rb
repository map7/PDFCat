class MissingFile
  require 'fileutils'
  require 'find'

  # Get all the pdfs in the Firm's storage_dir
  def self.get_pdfs_in_storage_dir(firm)
    files = []

    Find.find(firm.store_dir) do |path|
      files << path if FileTest.file?(path) and File.extname(path) == ".pdf"
    end

    files
  end

  # Remove all ready allocated
  def self.remove_allocated(firm, files)
    # Get all full paths for all pdfs for the firm
    existing_files = firm.pdfs.map{ |x| x.fullpath(firm) }

    # Remove allocated files from our list and return.
    files.reject{ |x| existing_files.include?(x) }
  end

  # Convenience method to get unallocated files for a firm's directory
  # This will be used to present a list of possible unallocated files for
  # missing PDF's within the system.
  def self.unallocated_files(firm)
    # Get files in firms storage dir
    if Rails.cache.read('files_expires').nil? || Time.now > Rails.cache.read('files_expires')
      Rails.cache.write('files_expires', Time.now + 1.day)
      files = Rails.cache.write('files', MissingFile.get_pdfs_in_storage_dir(firm))
    else
      files = Rails.cache.read('files')
    end

    # remove allocated
    MissingFile.remove_allocated(firm, files)
  end
end
