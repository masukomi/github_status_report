class GitHubsController < ApplicationController
  # GET /git_hubs
  # GET /git_hubs.json
  def index
    @git_hubs = GitHub.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @git_hubs }
    end
  end

  # GET /git_hubs/1
  # GET /git_hubs/1.json
  def show
    @git_hub = GitHub.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @git_hub }
    end
  end

  # GET /git_hubs/new
  # GET /git_hubs/new.json
  def new
    @git_hub = GitHub.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @git_hub }
    end
  end

  # GET /git_hubs/1/edit
  def edit
    @git_hub = GitHub.find(params[:id])
  end

  # POST /git_hubs
  # POST /git_hubs.json
  def create
    @git_hub = GitHub.new(params[:git_hub])

    respond_to do |format|
      if @git_hub.save
        format.html { redirect_to @git_hub, notice: 'Git hub was successfully created.' }
        format.json { render json: @git_hub, status: :created, location: @git_hub }
      else
        format.html { render action: "new" }
        format.json { render json: @git_hub.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /git_hubs/1
  # PUT /git_hubs/1.json
  def update
    @git_hub = GitHub.find(params[:id])

    respond_to do |format|
      if @git_hub.update_attributes(params[:git_hub])
        format.html { redirect_to @git_hub, notice: 'Git hub was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @git_hub.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /git_hubs/1
  # DELETE /git_hubs/1.json
  def destroy
    @git_hub = GitHub.find(params[:id])
    @git_hub.destroy

    respond_to do |format|
      format.html { redirect_to git_hubs_url }
      format.json { head :no_content }
    end
  end
end
