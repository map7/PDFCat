require 'spec_helper'

describe PdfsController do
  context "As a logged in user" do
    before do
      login_user
    end

    let(:pdf) {Pdf.make}

    describe "#index" do
      before do
        controller.stub!(:current_firm).and_return(pdf.firm)
      end
      
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

        it "assigns @pdf" do
          put :update, :id => pdf.id
          assigns(:pdf).should == pdf
        end
      end
      


    end
  end
end
