class DeflectionRequestsController < ApplicationController
  def add
    bt = BeamType.find(params[:beam_type_id])
    draft_status = DeflectionRequest::STATUS_DRAFT 

    dr = DeflectionRequest.find_by(requester_id: current_requester_id, status: draft_status)
    unless dr
      begin
        dr = DeflectionRequest.create!(requester_id: current_requester_id, status: draft_status)
      rescue ActiveRecord::RecordNotUnique
        dr = DeflectionRequest.find_by!(requester_id: current_requester_id, status: draft_status)
      end
    end

    item = dr.items.find_or_initialize_by(beam_type_id: bt.id)
    item.quantity = item.quantity.to_i + 1
    item.length_m ||= 3.0
    item.load_kn_m ||= 10.0
    item.save!

    redirect_to deflection_request_path(dr)
  end

  def show
    @deflection_request = DeflectionRequest.find(params[:id])

    # коллекция карточек в корзине
    @items = @deflection_request
              .items                         
              .includes(:beam_type)          
              .order(:id)

    @basket_count = @items.sum(:quantity)
  end

  def submit
    @order = DeflectionRequest.find(params[:id]) # ORM
    @order.update!(status: DeflectionRequest::STATUS_FORMED, formed_at: Time.current) # ORM
    redirect_to deflection_request_path(@order), notice: "Заявка сформирована"
  end

  def delete
    draft_status   = DeflectionRequest::STATUS_DRAFT
    deleted_status = DeflectionRequest::STATUS_DELETED

    sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        # логическое удаление только своего черновика
        "UPDATE deflection_requests
          SET status = ?, completed_at = CURRENT_TIMESTAMP
        WHERE id = ? AND requester_id = ? AND status = ?",
        deleted_status, params[:id], current_requester_id, draft_status
      ]
    )

    updated = ActiveRecord::Base.connection.update(sql)

    if updated > 0
      redirect_to beam_types_path, notice: "Заявка удалена"
    else
      # если заявка не найдена — кидаем 404
      raise ActiveRecord::RecordNotFound
    end
  end
end
