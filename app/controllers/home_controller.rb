class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # Listar Policies
  end
end
