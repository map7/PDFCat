require 'spec_helper'

describe CategoriesController do
  context "As a logged in user" do
    before do
      login_user
      current_firm = mock_model(Firm, :id => 1)
      controller.stub!(:current_firm).and_return(current_firm)
    end

    describe "#index" do
      it "should render index" do
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
        @category.stub!(:save).and_return(true)
      end
      
      it "creates new category" do
        Category.should_receive(:new).and_return(@category)
        post :create, :category => @category
      end

      it "should save category" do
        @category.should_receive(:save).and_return(true)
        post :create, :category => @category
      end
      
      it "should redirect to categories listing" do
        post :create, :category => @category
        response.should redirect_to(categories_path)
      end

      it "should display a flash message" do
        post :create, :category => @category
        flash[:notice].should == "Category created successfully!"
      end
    end

    describe "#edit" do
      it "should edit a category" do
        category = Category.make
        get :edit, :id => category.id
        response.should be_success
      end
    end

    describe "#update" do
      before do
        @category = Category.make
      end

      it "should update category" do
        Category.stub(:find).and_return(@category)
        @category.stub!(:pdfs_total).and_return(0)
        @category.should_receive(:update_attributes)
        put :update, :id => @category.id, category: {name: "test"}
      end

      context "with pdfs attached" do

        context "as admin user" do 
          context "main category" do
            before do
              login_admin
              @pdf = Pdf.make
            end
            
            it "accepts admin user updating" do
              @category.pdfs << @pdf
              put :update, :id => @category.id
              response.should redirect_to(categories_path)
            end

            context "where sub category has pdfs but main doesn't" do
              before do 
                @sub = Category.make(:sub)
                @sub.move_to_child_of @category
                @sub.update_attribute(:firm, @category.firm)
                @sub.pdfs << @pdf
              end
              
              it "accepts admin user updating" do
                put :update, :id => @category.id
                response.should redirect_to(categories_path)
              end
            end
          end
        end # admin user

        context "as regular user" do
          context "main category" do
            before do 
              @pdf = Pdf.make
            end
            
            it "denies user updating" do
              @category.pdfs << @pdf
              put :update, :id => @category.id
              response.should render_template(:edit)
            end

            context "where sub category has pdfs but main doesn't" do
              before do 
                @sub = Category.make(:sub)
                @sub.move_to_child_of @category
                @sub.update_attribute(:firm, @category.firm)
                @sub.pdfs << @pdf
              end
              
              it "denies user updating" do
                put :update, :id => @category.id
                response.should render_template(:edit)
              end
            end
          end
        end                     # reg user
      end

      context "with valid data" do
        before do 
          Category.stub!(:find).and_return(@category)
          @category.stub!(:pdfs_total).and_return(0)
          @category.stub!(:size).and_return(0)
          @category.stub!(:valid?).and_return(true)
          @category.stub_chain(:errors, :count).and_return(0)
        end

        it "should redirect to categories" do
          put :update, :id => @category.id
          response.should redirect_to(categories_path)
        end

        it "should display flash message" do 
          put :update, :id => @category.id
          flash[:notice].should == "Category updated successfully!"
        end
      end

      context "with invalid data" do
        before do 
          Category.stub!(:find).and_return(@category)
          @category.stub!(:pdfs_total).and_return(0)
          @category.stub!(:valid?).and_return(false)
          @category.stub_chain(:errors, :count).and_return(1)
        end

        it "should render edit" do
          put :update, :id => @category.id
          response.should render_template(:edit)
        end

        it "assigns category" do
          put :update, :id => @category.id
          assigns[:category].should == @category
        end
      end
    end
    
    describe "#destroy" do
      before do
        @category = Category.make
      end
      
      context "no pdfs attached" do 
        it "deletes a category" do
          lambda do 
            delete :destroy, :id => @category.id
          end.should change(Category, :count).from(1).to(0)
        end
        
        it "redirects to listing categories" do
          delete :destroy, :id => @category.id
          response.should redirect_to(categories_path)
        end

        it "displays flash message" do
          delete :destroy, :id => @category.id
          flash[:notice].should == "Category deleted successfully!"
        end
      end

      context "pdfs attached" do 
        it "displays error message" do
          @category.pdfs << Pdf.make
          delete :destroy, :id => @category.id
          flash[:error].should == "Cannot delete Category as there are 1 document(s) attached"
        end
      end
    end
  end # Logged in
end
