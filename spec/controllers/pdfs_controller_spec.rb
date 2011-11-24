require 'spec_helper'

describe PdfsController do
  context "As a logged in user" do
    before do
      login_user
    end

    let(:pdf) {Pdf.make}

    before do
      controller.stub!(:current_firm).and_return(pdf.firm)
    end
    
    describe "#index" do
      it "should show index" do
        get :index
        response.should be_success
      end

      it "should assign @pdfs" do
        get :index
        assigns(:pdfs).should == Pdf.all
      end
    end
    
    describe "#show" do
      it "should assign @pdf" do
        get :show, :id => pdf.id
        assigns(:pdf).should == pdf
      end
    end

    describe "#new" do

      before do 
        @new_pdf = Pdf.new
        controller.stub!(:current_firm).and_return(pdf.firm)
        Pdf.stub!(:new).and_return(@new_pdf)
      end
      
      it "should assign @pdf" do
        get :new, :filename => "test.pdf"
        assigns(:pdf).should == @new_pdf
      end

      it "should set the firm to current firm" do
        get :new, :filename => "test.pdf"
        @new_pdf.firm.should == pdf.firm
      end
    end

    describe "#create" do
      before do
        Pdf.stub!(:new).and_return(pdf)
        pdf.stub!(:md5calc2)
      end
      
      it "should create new pdf" do
        Pdf.should_receive(:new)
        post :create, :filename => "test.pdf"
      end

      it "should call valid?" do
        pdf.should_receive(:valid?)
        post :create, :filename => "test.pdf"
      end
      
      context "if data is valid" do
        before do
          pdf.stub!(:move_uploaded_file).and_return(true)
        end
        
        it "should create a md5" do 
          pdf.should_receive(:md5calc2)
          post :create, :filename => "test.pdf"
        end
        
        it "should move the file" do
          pdf.should_receive(:move_uploaded_file).and_return(true)
          post :create, :filename => "test.pdf"
        end
        
        it "should redirect to new" do
          post :create, :filename => "test.pdf"
          response.should redirect_to(new_pdfs_path)
        end
      end

      context "if data is invalid" do
        before do
          pdf.stub!(:valid?).and_return(false)
        end

        it "should render new" do
          post :create, :filename => "test.pdf"
          response.should render_template("new")
        end

        it "should assign @pdf" do
          post :create, :filename => "test.pdf"
          assigns(:pdf).should == pdf
        end
      end
    end
    
    describe "#edit" do
      it "should assign @pdf" do
        get :edit, :id => pdf.id
        assigns(:pdf).should == pdf
      end

      it "should assign @clients" do
        get :edit, :id => pdf.id
        assigns(:clients).should == pdf.firm.clients
      end

      it "should assign @categories" do
        get :edit, :id => pdf.id
        assigns(:categories).should == pdf.firm.categories
      end
    end
    
    describe "#update" do

      before do
        pdf.stub!(:move_file2).and_return(true)
      end
      
      context "with valid attributes" do
        before do
          pdf.stub!(:attributes).and_return(true)
          pdf.stub!(:save).and_return(true)
          Pdf.stub!(:find).and_return(pdf)
        end

        it "should find the pdf" do
          Pdf.should_receive(:find).and_return(pdf)
          put :update, :id => pdf.id
        end
        
        it "should update pdf" do
          pdf.should_receive(:attributes=).and_return(true)
          put :update, :id => pdf.id
        end
        
        it "moves the file" do
          pdf.should_receive(:move_file2).and_return(true)
          put :update, :id => pdf.id
        end
        
        it "should redirect to pdfs path" do
          put :update, :id => pdf.id
          response.should redirect_to pdf_path(pdf.id)
        end
      end
      
      context "with invalid attributes" do
        before do
          pdf.pdfname = ""
          Pdf.stub!(:find).and_return(pdf)
        end

        it "should render edit template" do
          put :update, :id => pdf.id
          response.should render_template("edit")
        end

        it "should assign @pdf" do
          get :edit, :id => pdf.id
          assigns(:pdf).should == pdf
        end

        it "should assign @clients" do
          get :edit, :id => pdf.id
          assigns(:clients).should == pdf.firm.clients
        end

        it "should assign @categories" do
          get :edit, :id => pdf.id
          assigns(:categories).should == pdf.firm.categories
        end        
      end
      


    end
  end
end
