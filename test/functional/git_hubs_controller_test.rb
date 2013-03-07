require 'test_helper'

class GitHubsControllerTest < ActionController::TestCase
  setup do
    @git_hub = git_hubs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:git_hubs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create git_hub" do
    assert_difference('GitHub.count') do
      post :create, git_hub: { api_endpoint: @git_hub.api_endpoint, client_id: @git_hub.client_id, client_secret: @git_hub.client_secret, domain: @git_hub.domain, name: @git_hub.name }
    end

    assert_redirected_to git_hub_path(assigns(:git_hub))
  end

  test "should show git_hub" do
    get :show, id: @git_hub
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @git_hub
    assert_response :success
  end

  test "should update git_hub" do
    put :update, id: @git_hub, git_hub: { api_endpoint: @git_hub.api_endpoint, client_id: @git_hub.client_id, client_secret: @git_hub.client_secret, domain: @git_hub.domain, name: @git_hub.name }
    assert_redirected_to git_hub_path(assigns(:git_hub))
  end

  test "should destroy git_hub" do
    assert_difference('GitHub.count', -1) do
      delete :destroy, id: @git_hub
    end

    assert_redirected_to git_hubs_path
  end
end
