class PdfMailer < ActionMailer::Base

  def email_client(current_firm,current_user,recipient,subject,body,pdf)

    @recipients = recipient
    @subject    = pdf.client.name.upcase + ' - ' + pdf.pdfname + ' ' + pdf.pdfdate.to_s
    @from       = current_user.email
    @bcc        = current_user.email
    @content_type='text/html'
    @body       = {:pdf => pdf, :body => body}
    @headers    = {}

    attachment "application/pdf" do |a|
      a.body = File.read(pdf.fullpath(current_firm))
      a.filename = pdf.filename
    end
  end
end
