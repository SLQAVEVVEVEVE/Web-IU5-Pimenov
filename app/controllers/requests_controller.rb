class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]

  # GET /requests/1
  # Просмотр заявки
  def show
  end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  def create
    @request = Request.new(request_params)

    if @request.save
      redirect_to @request, notice: 'Заявка была успешно создана.'
    else
      render :new
    end
  end

  # PATCH/PUT /requests/1
  def update
    if @request.update(request_params)
      render json: @request
    else
      render json: {
        errors: @request.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /requests/1
  # Логическое удаление заявки через SQL UPDATE
  def destroy
    # Используем прямой SQL UPDATE вместо ActiveRecord destroy
    @request.class.where(id: @request.id).update_all(status: 4) # 4 = deleted
    head :no_content
  end

  private

  # Установка заявки по ID
  # @raise [ActiveRecord::RecordNotFound] если заявка не найдена
  def set_request
    @request = Request.find(params[:id])
  end

  # Разрешение параметров для заявки
  # Поддерживает вложенные атрибуты для связанных услуг
  # @return [ActionController::Parameters] разрешенные параметры
  def request_params
    params.require(:request).permit(
      :status,           # Статус заявки (0-4)
      :formed_at,        # Дата формирования
      :completed_at,     # Дата завершения
      :moderator_id,     # ID модератора (опционально)
      request_services_attributes: [
        :id,             # ID (для обновления существующих)
        :service_id,     # ID услуги
        :length_m,       # Длина балки (метры)
        :load_kn_m,      # Нагрузка (кН/м)
        :quantity,       # Количество
        :position,       # Позиция в списке
        :_destroy        # Флаг для удаления (при обновлении)
      ]
    )
  end
end
