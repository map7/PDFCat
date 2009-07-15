class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :login_required
  before_filter :has_permission?

  def index
    @users = User.find(:all)
  end

  # render new.rhtml
  def new
    @user = User.new
    @firms = Firm.find(:all)
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    firm_id = params[:firm][:firm_id]
    @user.firm_id = firm_id

    success = @user && @user.save

    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session

      self.current_user = @user # !! now logged in
      redirect_to(users_url)
      flash[:notice] = "User #{@user.login} added."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      @firms = Firm.find(:all)
      render :action => 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to(users_url)
  end
end
