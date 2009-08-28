class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :login_required
  before_filter :has_permission?

  make_resourceful do
    actions :all

    before :index do
      @users = User.paginate(:page => params[:page], :per_page => 10, :order => 'upper(login)')
    end

    before :new, :edit do
      @firms = Firm.find(:all)
    end

    before :create, :update do
      @user.firm_id = params[:user][:firm_id]
      @user.is_admin = params[:user][:is_admin]
    end
  end
end
