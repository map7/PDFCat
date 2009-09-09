class ClientsController < ApplicationController

  before_filter :login_required

  make_resourceful do
    actions :all

    before :index do
      @clients = Client.paginate(:all,
                                 :order => 'upper(clients.name)',
                                 :page => params[:page],
                                 :per_page => 10,
                                 :conditions => search_conditions,
                                 :joins => :firm)
    end

    before :create do
      @client.firm_id = current_firm.id
    end

    before :update do
      @oldname = @client.name
    end

    after :update do
      # Move the directory.
      @client.move_dir(current_firm, @oldname)
    end
  end

  def search_conditions
    name = "%%#{params[:client]}%%"

    cond_strings = returning([]) do |strings|
      strings << "firms.id = #{current_firm.id}"
      strings << "name ilike #{name}" unless params[:client].blank?
    end

    if cond_strings.any?
      [ cond_strings.join(' and '), cond_strings ]
    else
      nil
    end
  end

end
