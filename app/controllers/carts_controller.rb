class CartsController < ApplicationController
  before_action :require_user

  def show
    @draft = current_draft
    @items = @draft&.requests_services || []
  end

  def delete
    draft = current_draft
    unless draft
      redirect_to services_path, alert: "Текущая заявка не найдена."
      return
    end

    sql = <<~SQL
      UPDATE requests
         SET status = 'deleted',
             completed_at = NOW()
       WHERE id = ?
         AND creator_id = ?
         AND status = 'draft'
    SQL

    # Sanitize to a plain SQL string (no bind arrays => no "can't cast Array")
    sanitized = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [sql, draft.id, current_user.id]
    )

    affected = ActiveRecord::Base.connection.exec_update(sanitized, "soft_delete_request")

    if affected.to_i > 0
      redirect_to services_path, notice: "Заявка удалена."
    else
      redirect_to cart_path, alert: "Не удалось удалить заявку."
    end
  end

  private
  
  def require_user
    current_user || head(:unauthorized)
  end
end
