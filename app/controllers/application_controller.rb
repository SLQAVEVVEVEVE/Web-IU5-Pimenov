class ApplicationController < ActionController::Base
  before_action :prepare_order_badge
  helper MinioHelper
  private
  def prepare_order_badge
    @order = Catalog.order
    mode = (ENV["BASKET_MODE"] || "items") # items | qty
    @basket_count = mode == "qty" ? @order[:items].sum { _1[:qty].to_i } : @order[:items].size
  end
end

