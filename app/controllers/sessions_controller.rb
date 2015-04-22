class SessionsController < ApplicationController

  # GET /signin
  def new
  end

  # POST /sessions
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password]) && !user.is_flagged_for_password_reset?
      sessions_sign_in(user, request)
      redirect_to root_path
    else
      @page_title = 'Sign in'
      flash.now[:error] = 'Unrecognised email and password combination.'
      render 'new'
    end
  end

  # DELETE /signout
  def destroy
    sessions_sign_out
    redirect_to root_url
  end

end
