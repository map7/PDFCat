# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_pdfcat_session_id' # Depreciated

  # RESTful Authentication
  include AuthenticatedSystem

  # If the request is ajax then don't include a layout
  layout :no_xhr_layout
  
  def no_xhr_layout
    request.xhr? ? false : 'application'
  end

  def current_firm
    unless current_user.nil?
      current_user.firm unless current_user.firm.nil?
    end
  end

  helper_method :current_firm

end
