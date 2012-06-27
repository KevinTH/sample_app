require 'spec_helper'

describe "Users" do
  
  describe "signup" do

    describe "failure" do
      it "does not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         with: ""
          fill_in "Email",        with: ""
          fill_in "Password",     with: ""
          fill_in "Confirmation",  with: ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end

    describe "success" do
      it "does not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         with: "Example User"
          fill_in "Email",        with: "user@example.com"
          fill_in "Password",     with: "foobar"
          fill_in "Confirmation",  with: "foobar"
          click_button
          response.should render_template('users/show')
          response.should have_selector("div.flash.success")
        end.should change(User, :count).by(1)
      end
    end
  end



  describe "sign in/out" do

    describe "failure" do
      it "does not sign a user in" do
        visit signin_path
        fill_in "Email", with: ""
        fill_in "Password", with: ""
        click_button
        response.should have_selector("div.flash.error", content: "Invalid")
      end
    end

    describe "success" do
      it "signs a user in" do
        @user = FactoryGirl.create(:user)
        visit root_path
        click_link "Sign in"
        fill_in "Email", with: @user.email
        fill_in "Password", with: @user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end
  end
  
end
