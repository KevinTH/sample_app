# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  remember_token     :string(255)
#  admin              :boolean         default(FALSE)
#

require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      name: "Example User",
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    }
  end



  it "creates a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "requires a name" do
    no_name_user = User.new(@attr.merge(name: ""))
    no_name_user.should_not be_valid
  end

  it "requires an email address" do
    no_name_user = User.new(@attr.merge(email: ""))
    no_name_user.should_not be_valid
  end

  it "rejects names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(name: long_name))
    long_name_user.should_not be_valid
  end


  it "accepts valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(email: address))
      valid_email_user.should be_valid
    end
  end

  it "rejects invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(email: address))
      invalid_email_user.should_not be_valid
    end
  end

  it "rejects duplicate email addresses" do
    # Put a user with given email address into the database
    User.create!(@attr)
    
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "rejects email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(email: upcased_email))

    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end



  describe "password validations" do

    it "requires a password" do
      User.new(@attr.merge(password: "", password_confirmation: "")).should_not be_valid
    end

    it "requires a matching password confirmation" do
      User.new(@attr.merge(password_confirmation: "invalidstuff")).should_not be_valid
    end

    it "rejects short passwords" do
      short = "a" * 5
      User.new(@attr.merge(password: short, password_confirmation: short)).should_not be_valid
    end

    it "rejects long passwords" do
      long = "a" * 41
      User.new(@attr.merge(password: long, password_confirmation: long)).should_not be_valid
    end
    
  end



  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "has an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "sets the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end


    describe "has_password? method" do
      it "is true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "is false if the passwords don't match" do
        @user.has_password?("invalidstuff").should be_false
      end
    end


    describe "authenticate method" do
      it "returns nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "returns nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "returns the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end

  end


  describe "remember_token" do
    before do
      @user = User.new(@attr)
      @user.save
    end

    it "has a remember token" do
      @user.remember_token.should_not be_blank
    end
  end



  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "responds to admin" do
      @user.should respond_to(:admin)
    end

    it "is not an admin by default" do
      @user.should_not be_admin
    end

    it "is convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end



  describe "micropost associations" do
    before(:each) do
      @user = User.create(@attr)
      @mp1 = FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
      @mp2 = FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "has a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "has the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "destroys associated microposts upon deletion" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end


    describe "status feed" do
      it "has a feed" do
        @user.should respond_to(:feed)
      end

      it "includes the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "does not include a different user's microposts" do
        @mp2 = FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
        @user.feed.include?(@mp3).should be_false
      end
    end
  end
  
end

