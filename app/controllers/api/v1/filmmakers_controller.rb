class Api::V1::FilmmakersController < ApplicationController
  respond_to :json

  def index
    respond_with Filmmaker.all
  end

  private

  def filmmaker_params
    params.require(:filmmaker).permit(:name, :email)
  end
end