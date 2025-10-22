class LegacyCartController < ApplicationController
  def show
    draft = Requests::EnsureDraft.new(user_id: current_user_id).call
    redirect_to request_path(draft) # HTML-страница заявки
  end
  # Добавляет балку в текущую "заявку" (черновик Request) и возвращает на список услуг
  def add
    service = Service.find(params[:service_id])

    # Гарантированно берём/создаём черновик для демо-пользователя (id=1)
    draft = Requests::EnsureDraft.new(user_id: current_user_id).call

    # Значения по умолчанию, если не передали из формы
    length_m = params[:length_m].presence&.to_f || 3.0
    load_kn_m = params[:load_kn_m].presence&.to_f || 5.0
    quantity = params[:quantity].presence&.to_i || 1

    item = draft.request_services.find_or_initialize_by(
      beam_type_id: service.id,
      length_m:     length_m,
      load_kn_m:    load_kn_m
    )
    item.quantity = quantity if item.new_record? || params[:quantity].present?
    item.save!

    redirect_back fallback_location: services_path, notice: "Добавлено в корзину"
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: services_path, alert: e.record.errors.full_messages.to_sentence
  end

  private

  # временно, пока нет аутентификации
  def current_user_id
    1
  end
end
