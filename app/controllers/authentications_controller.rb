class AuthenticationsController < ApplicationController
  
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to edit_user_registration_path
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to edit_user_registration_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    feed = current_user.feeds.find_by_provider(@authentication.provider)
    feed.destroy if feed
    current_user[@authentication.provider] = false
    #update for feeds creation
    current_user.save  
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to edit_user_registration_path
  end

end
  
