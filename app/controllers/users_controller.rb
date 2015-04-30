class UsersController < ApplicationController

  before_action :require_administrator_sign_in, only: [:index, :destroy]
  before_action :require_superuser_sign_in, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :validate_user_id_belongs_to_user_or_require_a_superuser, only: [:show, :edit, :update] 

  # GET /users
  def index
    @users = User.all
  end

  # GET /signup
  def new
    @user = User.new
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  # GET /users/:id/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User #{@user.email} successfully created."
      # TODO: Email the user their information.
      redirect_to root_path
    else
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
      render 'edit'
    end
  end

  # DELETE /users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'Account has been deleted.'
    redirect_to root_url
  end
  
  # GET /forgot_password
  def forgot_password

  end

  # POST /send_password_reset
  def send_password_reset
    if params[:email] 
      user = User.find_by_email(params[:email].downcase)
    end
    
    if user.nil? 
      redirect_to :forgot_password
    
      if params[:email].blank?
        flash[:notice] = 'No e-mail was given'
      else
        flash[:notice] = 'The supplied e-mail does not belong to a registered user'
      end
    else
      token = user.generate_password_reset_token
      $user_id = user.id
      user.save
      UserMailer.password_reset_email(user, token).deliver
    end
  end
  
  # GET /password_reset
  def password_reset
    @user = User.find_by_password_reset_token(RandomToken.digest(params[:token]))
    render 'invalid_token.html.erb' unless @user && @user.password_reset_token_date > 1.day.ago
  end
  
  # PATCH /set_password
  def set_password
    @user = User.find_by_password_reset_token!(RandomToken.digest(params[:token]))
    $user_id = @user.id
    @user.require_password_presence
    @user.password_reset_token = nil
    @user.is_flagged_for_password_reset = false
    if @user.update_attributes(params.require(:user).permit([:password, :password_confirmation]))
      flash[:success] = 'Password successfuly changed.'
      redirect_to root_path
    else
      render 'password_reset.html.erb'
    end
  end

  private

    def user_params
      # TODO: revisit authorization of specific field settings
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
      @recent_object = @user 
    end

    def validate_user_id_belongs_to_user_or_require_a_superuser
      (@user.id == sessions_current_user_id) || is_superuser?
    end

end
