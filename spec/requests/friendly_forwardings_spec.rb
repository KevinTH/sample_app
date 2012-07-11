require 'spec_helper'

describe "FriendlyForwardings" do

  it "forwards to the requested page after signin" do
    user = FactoryGirl.create(:user)
    visit edit_user_path(user)
    # Test automatically follows the redirect to the signin page
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button
    # Test follows the redirect again, this time to users/edit
    response.should render_template('users/edit')
  end
end
