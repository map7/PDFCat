require File.dirname(__FILE__) + '/../test_helper'

class PdfMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_email_client
    @expected.from = users(:aaron).email
    @expected.to = "michael@dtcorp.com.au"
    @expected.subject = 'FASTLINE - Notice Of Assessment 2007-11-20'
    @expected.body    = 'test body'
    @expected.date    = Time.now

    assert PdfMailer.create_email_client(firms(:one), users(:aaron),"michael@dtcorp.com.au", "test", "test body", pdfs(:notice))

#    assert_equal @expected.encoded, PdfMailer.create_email_client(@expected.date).encoded
    #    assert_equal @expected.encoded, PdfMailer.create_email_client(firms(:one), users(:aaron),"michael@dtcorp.com.au", "test", "test body", pdfs(:notice)).encoded

  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/pdf_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
