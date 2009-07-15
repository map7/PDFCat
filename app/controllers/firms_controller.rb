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

    respond_to do |format|
      if @firm.save
        flash[:notice] = 'Firm was successfully created.'
        format.html { redirect_to(@firm) }
        format.xml  { render :xml => @firm, :status => :created, :location => @firm }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @firm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /firms/1
  # PUT /firms/1.xml
  def update
    @firm = Firm.find(params[:id])

    respond_to do |format|
      if @firm.update_attributes(params[:firm])
        flash[:notice] = 'Firm was successfully updated.'
        format.html { redirect_to(@firm) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @firm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /firms/1
  # DELETE /firms/1.xml
  def destroy
    @firm = Firm.find(params[:id])
    @firm.destroy

    respond_to do |format|
      format.html { redirect_to(firms_url) }
      format.xml  { head :ok }
    end
  end
end
