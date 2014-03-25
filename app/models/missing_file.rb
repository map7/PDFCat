class MissingFile


  def self.remove_allocated(firm, files)
    # Get all full paths for all pdfs for the firm
    existing_files = firm.pdfs.map{ |x| x.fullpath(firm) }

    # Remove allocated files from our list and return.
    files.reject{ |x| existing_files.include?(x) }
  end

end
