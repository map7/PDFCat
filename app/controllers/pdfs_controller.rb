class PdfsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @pdf_pages, @pdfs = paginate :pdfs, :per_page => 10
  end

  def show
    @pdf = Pdf.find(params[:id])
  end

  def new
    @pdf = Pdf.new
  end

  def create
    @pdf = Pdf.new(params[:pdf])
    if @pdf.save
      flash[:notice] = 'Pdf was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @pdf = Pdf.find(params[:id])
  end

  def update
    @pdf = Pdf.find(params[:id])
    if @pdf.update_attributes(params[:pdf])
      flash[:notice] = 'Pdf was successfully updated.'
      redirect_to :action => 'show', :id => @pdf
    else
      render :action => 'edit'
    end
  end

  def destroy
    Pdf.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
