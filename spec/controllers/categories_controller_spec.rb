require 'spec_helper'

describe CategoriesController do
  context "As a logged in user" do
    before do
      login_user
    end

    describe "#index" do
      it "should render index" do
        current_firm = mock_model(Firm, :id => 1)
        controller.stub!(:current_firm).and_return(current_firm)
        get :index
        response.should render_template('index')
      end
    end

    describe "#new" do
      it "should display form" do
        get :new
        response.should render_template("new")
      end
    end
    
    describe "#create" do
      before do
        controller.stub!(:current_firm).and_return(mock_model(Firm, :id => 1))
        @category = Category.make
        Category.stub!(:new).and_return(@category)
      end
      
      it "creates new category" do
        Category.should_receive(:new).and_return(@category)
        post :create, :category => @category
      end

      it "should save category" do
        @category.should_receive(:save).and_return(true)
        post :create, :category => @category
      end
    end
    
    describe "#edit" do
      it "should edit a category" do
        category = Category.make
        get :edit, :id => category.id
        response.should be_success
      end
    end
    
    describe "#destroy" do
      before do
        @category = Category.make
      end
      
      it "should delete a category" do
        delete :destroy, :id => @category.id
      end
      
      it "redirects to listing categories" do
        delete :destroy, :id => @category.id
        response.should redirect_to(categories_path)
      end
    end
  end # Logged in
end
