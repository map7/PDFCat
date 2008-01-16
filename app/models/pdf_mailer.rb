class PdfMailer < ActionMailer::Base

  def email_client(recipient,subject,body,pdf)
    @recipients = recipient
    @subject    = pdf.client.name.upcase + ' - ' + pdf.pdfname + ' ' + pdf.pdfdate.to_s
	@from       = 'mary@tramontana.com.au'
    @sent_on    = Time.now 
	@content_type='text/html'
    @body       = {:pdf => pdf, :body => body}
    @headers    = {}

	attachment "application/pdf" do |a|
		a.body = File.read(pdf.fullpath)
		a.filename = pdf.filename
	end
  end
end
