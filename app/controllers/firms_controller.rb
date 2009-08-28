class FirmsController < ApplicationController

  before_filter :login_required
  before_filter :has_permission?

  make_resourceful do
    actions :all

    before :index do
      @firms = Firm.paginate(:page => params[:page], :per_page => 10, :order => 'upper(name)')
    end
  end
end
