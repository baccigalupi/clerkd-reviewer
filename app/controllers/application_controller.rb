class ApplicationController < ActionController::Base
  include AuthenticationHelper
  
  protect_from_forgery
end
