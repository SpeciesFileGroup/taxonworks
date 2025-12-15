class UsersController < ApplicationController

  before_action :require_sign_in, only: [:data, :recently_created]

  before_action :require_administrator_sign_in, only: [:index, :destroy, :batch_create]
  before_action :require_superuser_sign_in, only: [:new, :create, :autocomplete]

  before_action :set_user, only: [:show, :edit, :update, :destroy, :data]

  # GET /users
  def index
    @users = User.all.order(:name, :email)
  end

  # GET /signup
  def new
    @user = User.new
    set_available_projects
  end

  # GET /users/:id
  def show
  end

  # GET /users/:id/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.is_flagged_for_password_reset = is_superuser?

    if @user.save
      # Handle project memberships
      allowed_projects = is_administrator? ?
        Project.all.pluck(:id).map(&:to_s) :
        sessions_current_user&.administered_projects&.pluck(:id)&.map(&:to_s) || []
      project_member_errors = []
      if params[:user][:project_ids].present?
        params[:user][:project_ids].each do |project_id|
          next unless allowed_projects.include?(project_id)

          project_member = @user.project_members.create(
            project_id:,
            is_project_administrator: params[:user][:project_admin_ids]&.include?(project_id)
          )

          unless project_member.persisted?
            project_name = Project.find_by(id: project_id)&.name || "Project #{project_id}"
            project_member_errors << "#{project_name}: #{project_member.errors.full_messages.join(', ')}"
          end
        end
      end

      if project_member_errors.empty?
        flash[:success] = "User #{@user.email} successfully created."
        # TODO: Email the user their information.
      else
        flash[:alert] = "User #{@user.email} created, but some project memberships failed: #{project_member_errors.join('; ')}"
      end

      if is_administrator?
        redirect_to user_path(@user)
      else
        redirect_back fallback_location: root_path
      end
    else
      set_available_projects
      render 'new'
    end
  end

  # PATCH or PUT /users/:id
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html do
          flash[:success] = 'Changes to your account information have been saved.'
          redirect_to @user
        end
        format.json { render :show, location: @user }
      else
        format.html { render 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
        flash[:alert] = 'No e-mail was given'
      else
        flash[:alert] = 'The supplied e-mail does not belong to a registered user'
      end
    else
      token = user.generate_password_reset_token
      Current.user_id = user.id
      user.save
      begin
        UserMailer.password_reset_email(user, token).deliver_now
      rescue
        redirect_to :forgot_password
        flash[:alert] = 'Failed to send e-mail. Please try again in a few minutes.'
      end
    end
  end

  # GET /password_reset
  def password_reset
    @user = User.find_by_password_reset_token(Utilities::RandomToken.digest(params[:token]))
    render 'invalid_token' unless @user && @user.password_reset_token_date > 1.day.ago
  end

  # PATCH /set_password
  def set_password
    @user = User.find_by_password_reset_token!(Utilities::RandomToken.digest(params[:token]))

    Current.user_id = @user.id #  WHY?

    @user.require_password_presence

    @user.password_reset_token = nil
    @user.is_flagged_for_password_reset = false

    if @user.update(params.require(:user).permit([:password, :password_confirmation]))
      flash[:notice] = 'Password successfuly changed.'
      redirect_to root_path
    else
      render 'password_reset'
    end
  end

  def recently_created
  end



  def preferences
    @user = sessions_current_user
    redirect_to hub_path and return if @user.nil?
  end

  def reset_preferences
    @user = sessions_current_user
    redirect_to hub_path and return if @user.nil?
    @user.reset_preferences
    @user.save!
    redirect_to user_path(@user)
  end

  def reset_hub_favorites
    @user = sessions_current_user
    redirect_to hub_path and return if @user.nil?
    @user.reset_hub_favorites(sessions_current_project_id)
    @user.save!
    redirect_to user_path(@user)
  end

  def autocomplete
    @users = Queries::User::Autocomplete.new(params.require(:term)).autocomplete
  end

  def batch_create
    @users = User.batch_create(
      users: params[:users],
      create_api_token: params[:create_api_token],
      is_administrator: params[:is_administrator],
      project_id: params[:project_id],
      created_by: sessions_current_user_id
    )

    render '/tasks/administrator/batch_add_users/index'
  end

  def data
    weeks_ago = params[:weeks_ago]
    @weeks_ago = weeks_ago =~ (/\A\d+\z/) ? weeks_ago : nil
    @target = params[:target]&.to_sym || :created
  end

  private

  def set_available_projects
    # Administrators can add users to ANY project
    # Project administrators can only add users to projects they administer
    @available_projects = if is_administrator?
      Project.order(:name)
    else
      sessions_current_user&.administered_projects&.order(:name) || []
    end
  end

  def user_params
    # TODO: revisit authorization of specific field settings
    basic = [
      :name,
      :email,
      :person_id,
      :password,
      :password_confirmation,
      :set_new_api_access_token]

    basic += [:is_project_administrator, :is_flagged_for_password_reset] if is_superuser?
    basic += [:is_administrator] if is_administrator?

    params.require(:user).permit(basic, User.key_value_preferences, User.array_preferences, User.hash_preferences)
  end

  def set_user
    own_id = (params[:id].to_i == sessions_current_user_id)

    # The RecordNotFound error raised in the nil case is tranformed into a
    # 404 by the rescue_from handlers.
    @user = User.find((is_administrator? || own_id) ? params[:id] : nil)
    @recent_object = @user
  end

end
