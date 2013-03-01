require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  setup do
    @repo = repos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repo" do
    assert_difference('Repo.count') do
      post :create, repo: { api_endpoint: @repo.api_endpoint, branch_naming_convention: @repo.branch_naming_convention, github_name: @repo.github_name, host: @repo.host, oauth_token: @repo.oauth_token, ticket_url: @repo.ticket_url }
    end

    assert_redirected_to repo_path(assigns(:repo))
  end

  test "should show repo" do
    get :show, id: @repo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repo
    assert_response :success
  end

  test "should update repo" do
    put :update, id: @repo, repo: { api_endpoint: @repo.api_endpoint, branch_naming_convention: @repo.branch_naming_convention, github_name: @repo.github_name, host: @repo.host, oauth_token: @repo.oauth_token, ticket_url: @repo.ticket_url }
    assert_redirected_to repo_path(assigns(:repo))
  end

  test "should destroy repo" do
    assert_difference('Repo.count', -1) do
      delete :destroy, id: @repo
    end

    assert_redirected_to repos_path
  end
end
