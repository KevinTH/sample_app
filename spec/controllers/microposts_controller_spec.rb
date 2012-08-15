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



  describe "DELETE 'destroy'" do

    describe "for an unauthorized user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        wrong_user = FactoryGirl.create(:user)
        test_sign_in(wrong_user)
        @micropost = FactoryGirl.create(:micropost, user: @user)
      end

      it "denies access" do
        delete :destroy, id: @micropost
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do
      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        @micropost = FactoryGirl.create(:micropost, user: @user)
      end

      it "destroys the micropost" do
        lambda do
          delete :destroy, id: @micropost
        end.should change(Micropost, :count).by(-1)
      end
    end
  end



  describe "GET 'index'" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "returns http success" do
      get :index, user_id: @user
      response.should be_success
    end

    it "finds the right user" do
      get :index, user_id: @user
      assigns(:user).should == @user
    end

    it "has the right title" do
      get :index, user_id: @user
      response.should have_selector("title", content: @user.name)
    end

    it "includes the user's name" do
      get :index, user_id: @user
      response.should have_selector("h1", content: @user.name)
    end

    it "has a profile image" do
      get :index, user_id: @user
      response.should have_selector("h1>img", class: "gravatar")
    end


    it "shows the user's microposts" do
      mp1 = FactoryGirl.create(:micropost, user: @user, content: "Foo bar")
      mp2 = FactoryGirl.create(:micropost, user: @user, content: "Baz quux")
      get :index, user_id: @user
      response.should have_selector("span.content", content: mp1.content)
      response.should have_selector("span.content", content: mp2.content)
    end
  end
        
end
