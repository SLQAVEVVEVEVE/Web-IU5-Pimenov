class LoadForecastBeamTypesController < ApplicationController
  before_action :set_load_forecast
  before_action :set_item, only: [:update, :destroy]

  def create
    @item = @load_forecast.load_forecast_beam_types.new(item_params)

    if @item.save
      render json: @item, status: :created
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      render json: @item
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    head :no_content
  end

  private

  def set_load_forecast
    @load_forecast = LoadForecast.find(params[:load_forecast_id])
  end

  def set_item
    @item = @load_forecast.load_forecast_beam_types.find(params[:id])
  end

  def item_params
    params.require(:load_forecast_beam_type).permit(
      :beam_type_id, :length_m, :load_kn_m, :quantity, :position
    )
  end
end
