module AuthenticationHelper
  def current_user
    @current_user
  end
  
  def login(user)
    @current_user = user
    session[:user_id] = user.id.to_s
    remember
    flash[:notice] = 'You have been logged in.'
  end
  
  def logout
    if current_user
      session[:user_id] = nil
      forget
      @current_user = nil
      flash[:error] = 'You have been logged out.'
    end
  end
  
  def remember
    request.cookies[:remember] = current_user.remember! if params[:session][:remember]
  end
  
  def forget
    current_user.forget!
    cookies.delete(:remember)
  end
  
  def redirect_back
    location = params[:location] || cookies[:location] || '/'
    redirect_to(location)
  end
end
