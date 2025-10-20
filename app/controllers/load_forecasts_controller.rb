class LoadForecastsController < ApplicationController
  # TODO: включить аутентификацию, как только она готова
  # before_action :authenticate_user!

  before_action :set_load_forecast, only: [:show, :update, :destroy]

  def index
    # фильтрация по статусу (число или символ), сортировка по убыванию
    @load_forecasts = LoadForecast.by_status(params[:status]).recent
    render json: @load_forecasts.as_json(include: {
      load_forecast_beam_types: {
        only: [:id, :beam_type_id, :length_m, :load_kn_m, :quantity, :position]
      }
    })
  end

  def show
    render json: @load_forecast.as_json(include: {
      load_forecast_beam_types: {
        only: [:id, :beam_type_id, :length_m, :load_kn_m, :quantity, :position]
      }
    })
  end

  def create
    @load_forecast = LoadForecast.new(load_forecast_params)
    # в демо-приложении requester — демо-пользователь
    @load_forecast.requester ||= User.find_by(email: "demo@local")

    if @load_forecast.save
      render json: @load_forecast, status: :created
    else
      render json: { errors: @load_forecast.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @load_forecast.update(load_forecast_params)
      render json: @load_forecast
    else
      render json: { errors: @load_forecast.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @load_forecast.destroy
    head :no_content
  end

  private

  def set_load_forecast
    @load_forecast = LoadForecast.find(params[:id])
  end

  # без enum — статус приходит числом (0..3) или можно пробросить символ и конвертировать в сервисе
  def load_forecast_params
    params.require(:load_forecast).permit(
      :status, :formed_at, :completed_at, :moderator_id,
      load_forecast_beam_types_attributes: [
        :id, :beam_type_id, :length_m, :load_kn_m, :quantity, :position, :_destroy
      ]
    )
  end
end
