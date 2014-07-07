class UsersController < ApplicationController

  before_action :require_administrator_sign_in, only: [:index, :destroy]
  before_action :require_superuser_sign_in, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :validate_user_id_belongs_to_user_or_require_a_superuser, only: [:show, :edit, :update] 


  # GET /users
  def index
    @users = User.all
    @page_title = 'Users'
  end

  # GET /signup
  def new
    @user = User.new
    @page_title = 'Create account'
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
    @page_title = "User #{@user.id}"
  end

  # GET /users/:id/edit
  def edit
    @user = User.find(params[:id])
    @page_title = "Edit user #{@user.id}"
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User #{@user.email} successfully created."
      # TODO: Email the user their information.
      redirect_to root_path
    else
      @page_title = 'Create account'
      render 'new'
    end
  end

  # PATCH or PUT /users/:id
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Changes to your account information have been saved.'
      redirect_to @user
    else
      @page_title = "Edit user #{@user.id}"
      render 'edit'
    end
  end

  # DELETE /users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Account has been deleted."
    redirect_to root_url
  end

  private

    def user_params
      # TODO: revist authorization of specific field settings
      basic = [:name,
      :email,
      :password,
      :password_confirmation]

      basic.push [:is_project_administrator] if @sessions_current_user.is_superuser?
      basic.push [:is_administrator] if @sessions_current_user.is_administrator

      params.require(:user).permit(basic)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def validate_user_id_belongs_to_user_or_require_a_superuser
      (@user.id == sessions_current_user_id) || is_superuser?
    end

end
