class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :login_required
  before_filter :has_permission?

  def index
    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @firms = Firm.find(:all)
  end

  def edit
    @user = User.find(params[:id])
    @firms = Firm.find(:all)
  end

  def create
    @user = User.new(params[:user])
    @user.firm_id = params[:user][:firm_id]
    @user.is_admin = params[:user][:is_admin]

    success = @user && @user.save

    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session

      redirect_to(users_url)
      flash[:notice] = "User #{@user.login} added."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      @firms = Firm.find(:all)
      render :action => 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    @user.firm_id = params[:user][:firm_id]
    @user.is_admin = params[:user][:is_admin]

    if @user.update_attributes(params[:user])
      flash[:notice] = "User was sucessfully updated."
      redirect_to(users_url)
    else
      @firms = Firm.find(:all)
      render :action => "new"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to(users_url)
  end
end
