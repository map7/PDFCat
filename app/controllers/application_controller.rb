# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_pdfcat_session_id'

  # RESTful Authentication
  include AuthenticatedSystem


  def current_firm
    current_user.firm unless current_user.firm.nil?
  end

  helper_method :current_firm

end
