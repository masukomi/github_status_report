require 'test_helper'

class GitHubTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "convert api url to web url" do
    api_url = 'https://api.github.com/users/robhurring'
    expected_web_url = 'https://github.com/robhurring'

    gh = GitHub.new({:api_endpoint => "https://api.github.com", 
      :domain=>"https://github.com"})
    assert_equal expected_web_url, gh.convert_api_url_to_web(api_url, :user)
    assert_raise(RuntimeError) {gh.convert_api_url_to_web(api_url, :bogus)}
  end 
end
