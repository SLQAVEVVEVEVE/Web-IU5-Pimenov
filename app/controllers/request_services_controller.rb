# Контроллер для работы со связанными услугами в заявке
class RequestServicesController < ApplicationController
  # Установка родительской заявки и элемента для всех действий
  before_action :set_request
  before_action :set_item, only: [:update, :destroy]

  # POST /requests/:request_id/services
  # Создание новой связи между заявкой и услугой
  def create
    @item = @request.request_services.new(item_params)

    if @item.save
      respond_to do |format|
        format.html {
          redirect_back(
            fallback_location: services_path,
            notice: "Услуга успешно добавлена в заявку"
          )
        }
        format.json {
          render json: @item,
                 status: :created,
                 location: request_path(@request)
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_back(
            fallback_location: services_path,
            alert: "Не удалось добавить услугу: #{@item.errors.full_messages.to_sentence}"
          )
        }
        format.json {
          render json: {
            errors: @item.errors.full_messages
          },
          status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /requests/:request_id/services/:id
  # Обновление связи между заявкой и услугой
  def update
    if @item.update(item_params)
      respond_to do |format|
        format.html {
          redirect_back(
            fallback_location: services_path,
            notice: "Параметры услуги успешно обновлены"
          )
        }
        format.json { render json: @item }
      end
    else
      respond_to do |format|
        format.html {
          redirect_back(
            fallback_location: services_path,
            alert: "Не удалось обновить параметры: #{@item.errors.full_messages.to_sentence}"
          )
        }
        format.json {
          render json: {
            errors: @item.errors.full_messages
          },
          status: :unprocessable_entity
        }
      end
    end
  end

  # DELETE /requests/:request_id/services/:id
  # Удаление связи между заявкой и услугой
  def destroy
    @item.soft_delete
    respond_to do |format|
      format.html {
        redirect_back(fallback_location: services_path, notice: "Услуга успешно удалена из заявки")
      }
      format.json { head :no_content }
    end
  end

  private

  # Установка родительской заявки по ID
  # @raise [ActiveRecord::RecordNotFound] если заявка не найдена
  def set_request
    @request = Request.find(params[:request_id])
  end

  # Установка элемента по ID в контексте родительской заявки
  # @raise [ActiveRecord::RecordNotFound] если элемент не найден
  def set_item
    @item = @request.request_services.find(params[:id])
  end

  # Разрешение параметров для связи заявки и услуги
  # @return [ActionController::Parameters] разрешенные параметры
  def item_params
    params.require(:request_service).permit(
      :beam_type_id,  # ID услуги
      :length_m,      # Длина балки (метры)
      :load_kn_m,     # Нагрузка (кН/м)
      :quantity,      # Количество
      :position       # Позиция в списке (опционально, назначается автоматически)
    )
  end
end
