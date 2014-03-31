class UsersController < ApplicationController

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
      sessions_sign_in @user
      flash[:success] = 'Thanks for signing up and welcome to TaxonWorks!'
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
    flash[:success] = "Your account has been deleted."
    redirect_to root_url
  end

  private

    def user_params
      params.require(:user).permit(:name,
                                   :email,
                                   :password,
                                   :password_confirmation)
    end

end
