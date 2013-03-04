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
    @days = params[:days] || 7
    @login = params[:login]
    @type = params[:type]
    @state = params[:state] || 'closed'
    #END TODO

    # initally let's just deal with CLOSED
    # pull requests, because these represent completed work
    # assuming they're merged in.
    #@pull_requests = @repo.get_closed_pull_requests(false).sort_by(&:merged_at)
    @sorted_pull_requests = @repo.get_sorted_pull_requests(false)
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
    @repo = Repo.new(params[:repo])

    respond_to do |format|
      if @repo.save
        format.html { redirect_to @repo, notice: 'Repo was successfully created.' }
        format.json { render json: @repo, status: :created, location: @repo }
      else
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
end
