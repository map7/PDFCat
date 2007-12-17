class ClientsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def index
    @client_pages, @clients = paginate (:clients, :order => 'upper(name)', :per_page => 10)
	@no = -1	# Used for shorcuts
  end

  def search
	conditions = ["name ILIKE ?", "%#{@params[:client]}%"] unless @params[:client].nil?

    @client_pages, @clients = paginate (:clients, :conditions => conditions, :order => 'upper(name)', :per_page => 10)
	@no = -1	# Used for shorcuts

	render :action => 'index'

  end

  def show
    @client = Client.find(params[:id])
	@id = params[:id]	# Used for shortcuts
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = 'Client was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])

	# Move directory, if dir exists
	#@newclient = Client.new(params[:client])
	#@newclient.name = @client.move_dir(@newclient.name)
	@oldname = @client.name

	
	# Store the data
    #if @client.errors.size == 0 and @client.update_attributes(params[:client])
    if @client.update_attributes(params[:client])
		@client.move_dir(@oldname)
		flash[:notice] = 'Client was successfully updated.'
		redirect_to :action => 'show', :id => @client
    else
		render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
