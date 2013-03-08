require 'mustache'
class ReposController < ApplicationController

  # public reports
  # 
  # params - the params hash
  #          :days - days back to report on. Defaults to 7
  #          :login - the login of the user to report on. Defaults to all
  #          :assigned - assigned to :login or not. defaults to pull 
  #                       requests created by, but not assigned to :login
  #                       Only applicable if :login is specified
  #          :type - the type of pull requests to report on.
  #               Can be bug, add, or '' where '' is all types.
  #          :project - the project to report on. Defaults to all
  #          :state - 'open' or 'closed'
  # GET /repos/:id/report
  def report
    @repo = Repo.find(params[:id])

    #TODO - actually support these params
    @days = params[:days].nil? ? 7 : params[:days].to_i
    @login = params[:login]
    @type = params[:type].blank? ? nil : params[:type] # nil gets us all types
    @state = params[:state] || 'closed'
    #END TODO

    # initally let's just deal with CLOSED
    # pull requests, because these represent completed work
    # assuming they're merged in.
    #@pull_requests = @repo.get_closed_pull_requests(false).sort_by(&:merged_at)
    options = {
      :include_unmerged=>false, #TODO handle this later
      :days=>@days,
      :type=>@type
    }
    @sorted_pull_requests = @repo.get_sorted_pull_requests(options)
                                          # false: don't include unmerged
                                          # comes pre-sorted

  end

  # GET /repos
  # GET /repos.json
  def index
    @repos = Repo.all.sort_by(&:github_name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repos }
    end
  end

  # GET /repos/1
  # GET /repos/1.json
  def show
    @repo = Repo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @repo }
    end
  end

  # GET /repos/new
  # GET /repos/new.json
  def new
    @repo = Repo.new
    @git_hubs = GitHub.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @repo }
    end
  end

  # GET /repos/1/edit
  def edit
    @repo = Repo.find(params[:id])
  end

  # POST /repos
  # POST /repos.json
  def create
    git_hub_id = params[:repo].delete(:git_hub_id).to_i
    @repo = Repo.new(params[:repo])
    @repo.git_hub_id = git_hub_id

    respond_to do |format|
      if @repo.save
        format.html { redirect_to @repo, notice: 'Repo was successfully created.' }
        format.json { render json: @repo, status: :created, location: @repo }
      else
        @git_hubs = GitHub.all
        format.html { render action: "new" }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /repos/1
  # PUT /repos/1.json
  def update
    @repo = Repo.find(params[:id])

    respond_to do |format|
      if @repo.update_attributes(params[:repo])
        format.html { redirect_to @repo, notice: 'Repo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @repo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repos/1
  # DELETE /repos/1.json
  def destroy
    @repo = Repo.find(params[:id])
    @repo.destroy

    respond_to do |format|
      format.html { redirect_to repos_url }
      format.json { head :no_content }
    end
  end

  def send_oauth
    @repo = Repo.includes(:git_hub).find(params[:id])
    # cookie the user
    # send them to oauth page

    oauth_url = "#{@repo.git_hub.domain}/login/oauth/authorize?client_id=#{
      @repo.git_hub.client_id}&scope=repo&redirect_uri=#{
      request.protocol}#{
      request.host_with_port}/repos/oauth_callback"
      #TODO add state param here. See docs:
      # http://developer.github.com/v3/oauth/#redirect-urls
    cookies[:repo_oauth_id] = { 
      :value => @repo.id, 
      :expires => 10.minutes.from_now,
      :httponly => true
    }
    redirect_to oauth_url
  end
  def oauth_callback
    #http://localhost:3000/repos/oauth_callback?code=6d1bb0ea6c5d95b8e506
    # check for the cookie
    if cookies[:repo_oauth_id]
      # if cookie extract git_hub id to add oauth to.
      # TODO confirm state param matches
      begin
        @repo = Repo.includes(:git_hub).find(cookies[:repo_oauth_id])
        code = params[:code]
        # we now exchange the code for an access_token
        oauth_token = exchange_code_for_access_token(@repo.git_hub, code)
        @repo.oauth_token = oauth_token
        @repo.save!()
        redirect_to :controller=>:repos, :action=>:report, :id=>@repo.id
      rescue Exception => e
        flash[:error] ="A problem was encountered setting up that OAuth: #{e}"
        redirect_to :controller=>:repos, :action=>:index
      end
    else
        flash[:error] ="Your OAuth session has expired. Please try again"
        redirect_to :controller=>:repos, :action=>:index
    end

    # if no cookie redirect to #show with error
  end

  private

  def exchange_code_for_access_token(git_hub, code)
    require "net/http"

    #https://github.com/login/oauth/access_token
    uri = URI.parse("#{git_hub.domain}/login/oauth/access_token")
    args = {
      client_id: git_hub.client_id, 
      client_secret: git_hub.client_secret,
      code: code
      # optionally can supply redirect_uri
    }
    uri.query = URI.encode_www_form(args)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # Verify None because GitHub enterprise 
      # installs will frequently have a self-signed cert

    request = Net::HTTP::Get.new(uri.request_uri)
    # We should actually be sending a POST

    response = http.request(request)

    data = response.body
    # By default, the response will take the following form
    # access_token=e72e16c7e42f292c6912e7710c838347ae178b4a&token_type=bearer
    
    matcher = data.match(/.*?access_token=(.*?)&token_type.*?/)
    if matcher 
      return matcher[1]
    else
      raise "Data from GitHub didn't match expectations:\n#{data}"
    end
  end
end
