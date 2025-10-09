class OrdersController < ApplicationController
  include MinioHelper

  def show
    @order = Catalog.order(params[:id].to_i)
    @services_by_id = Catalog.services.index_by(&:id)
  end
end
