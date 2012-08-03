require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do
    it "denies access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "denies access to 'destroy'" do
      delete :destroy, id: 1
      response.should redirect_to(signin_path)
    end
  end


  describe "POST 'create'" do
    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user))
    end

    describe "failure" do
      before(:each) do
        @attr = { content: "" }
      end

      it "does not create a micropost" do
        lambda do
          post :create, micropost: @attr
        end.should_not change(Micropost, :count)
      end

      it "renders the home page" do
        post :create, micropost: @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do
      before(:each) do
        @attr = { content: "Lorem ipsum" }
      end

      it "creates a micropost" do
        lambda do
          post :create, micropost: @attr
        end.should change(Micropost, :count).by(1)
      end

      it "redirects to the home page" do
        post :create, micropost: @attr
        response.should redirect_to(root_path)
      end

      it "has a flash message" do
        post :create, micropost: @attr
        flash[:success].should =~ /micropost created/i
      end
    end
  end
        
end
