# By using ':user', we get Factory Girl to simulate User model
FactoryGirl.define do
  factory :user do
    name                   "Kay Tee"
    email                  "kaytee@example.com"
    password               "foobar"
    password_confirmation  "foobar"
  end
end
