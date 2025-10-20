class LegacyCartController < ApplicationController
  # Добавляет балку в текущую "заявку" (черновик LoadForecast) и возвращает на список услуг
  def add
    beam_type = BeamType.find(params[:beam_type_id])

    # Гарантированно берём/создаём черновик для демо-пользователя (id=1)
    draft = LoadForecasts::EnsureDraft.new(user_id: current_user_id).call

    # Значения по умолчанию, если не передали из формы
    length_m = params[:length_m].presence&.to_f || 3.0
    load_kn_m = params[:load_kn_m].presence&.to_f || 5.0
    quantity = params[:quantity].presence&.to_i || 1

    item = draft.load_forecast_beam_types.find_or_initialize_by(
      beam_type_id: beam_type.id,
      length_m:     length_m,
      load_kn_m:    load_kn_m
    )
    item.quantity = quantity if item.new_record? || params[:quantity].present?
    item.save!

    redirect_back fallback_location: beam_types_path, notice: "Добавлено в корзину"
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: beam_types_path, alert: e.record.errors.full_messages.to_sentence
  end

  private

  # заменишь на current_user.id, когда будет авторизация
  def current_user_id
    1
  end
end
