class SessionsController < ApplicationController
  # POST /session
  def create
    @user = User.authenticate( params[:session] )
    if @user
      login @user
      redirect_back
    end
  end
  
  def destroy
    logout
    redirect_to( '/' )
  end
end
