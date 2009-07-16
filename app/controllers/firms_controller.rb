class FirmsController < ApplicationController

  before_filter :login_required
  before_filter :has_permission?

  def index
    @firms = Firm.find(:all)
  end

  def show
    @firm = Firm.find(params[:id])
  end

  def new
    @firm = Firm.new
  end

  def edit
    @firm = Firm.find(params[:id])
  end

  def create
    @firm = Firm.new(params[:firm])

    if @firm.save
      flash[:notice] = 'Firm was successfully created.'
      redirect_to(firms_url)
    else
      render :action => "new"
    end
  end

  def update
    @firm = Firm.find(params[:id])

    if @firm.update_attributes(params[:firm])
      flash[:notice] = 'Firm was successfully updated.'
      redirect_to(firms_url)
    else
      render :action => "new"
    end
  end

  def destroy
    @firm = Firm.find(params[:id])
    @firm.destroy

    redirect_to(firms_url)
  end
end
