require 'spec_helper'

describe PagesController do
	render_views

  before(:each) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end
	
  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end

    it "has the right title" do
    	get 'home'
    	response.should have_selector("title", :content => @base_title + " | Home")
    end

    it "paginates the micropost feed" do
      user = FactoryGirl.create(:user)
      test_sign_in(user)
      
      microposts = []
      31.times do
        microposts << FactoryGirl.create(:micropost, user: user)
      end
      get :home, id: @user
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", content: "Previous")
      response.should have_selector("a", href: "/?page=2", content: "2")
      response.should have_selector("a", href: "/?page=2", content: "Next")
    end
  end


  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success
    end

    it "has the right title" do
    	get 'contact'
    	response.should have_selector("title", :content => @base_title + " | Contact")
    end
  end


  describe "GET 'about'" do
    it "returns http success" do
  		get 'about'
  		response.should be_success
    end

    it "has the right title" do
    	get 'about'
    	response.should have_selector("title", :content => @base_title + " | About")
    end
  end


  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end

    it "has the right title" do
      get 'help'
      response.should have_selector("title", :content => @base_title + " | Help")
    end
  end



  describe "sidebar micropost count" do

    describe "absence" do
      it "does not display a micropost count to not signed in users" do
        get 'home'
        response.should_not have_selector("span", class: "microposts")
      end
    end

    describe "showing and pluralization" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        test_sign_in(@user)
      end

      it "displays a micropost count" do
        get 'home'
        response.should have_selector("span", class: "microposts")
      end

      it "has the correct plural for no microposts" do
        get 'home'
        response.should have_selector("span", class: "microposts", content: "0 microposts")
      end

      it "has the correct plural for one microposts" do
        FactoryGirl.create(:micropost, user: @user)
        get 'home'
        response.should have_selector("span", class: "microposts", content: "1 micropost")
        response.should_not have_selector("span", class: "microposts", content: "microposts")
      end

      it "has the correct plural for more than one microposts" do
        FactoryGirl.create(:micropost, user: @user)
        FactoryGirl.create(:micropost, user: @user)
        get 'home'
        response.should have_selector("span", class: "microposts", content: "2 microposts")
      end
    end
  end
  	

end
