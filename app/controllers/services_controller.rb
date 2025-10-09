class ServicesController < ApplicationController
  include MinioHelper

  def index
    @q = (params[:search] || params[:q]).to_s.strip
    @order = Catalog.order

    all = Catalog.services

    if @q.blank?
      @services = all
    else
      q = @q.downcase
      # вытащим цифры, если в запросе есть число (например, "200" или "L/250")
      q_digits = q.gsub(/[^\d]/, '')

      @services = all.select do |s|
        hay = [
          s.name,
          s.material,
          s.norm,
          "#{s.e_gpa}",   # матч по числу ГПа
        ].compact.join(' ').downcase

        match_text = hay.include?(q)
        match_digits = q_digits.present? && hay.gsub(/[^\d]/, '').include?(q_digits)

        match_text || match_digits
      end
    end

    # бейдж — количество услуг (позиций)
    @basket_count = @order[:items].size
  end

  def show
    @service = Catalog.services.find { _1.id == params[:id].to_i }
    return render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @service
    @order = Catalog.order
  end
end
