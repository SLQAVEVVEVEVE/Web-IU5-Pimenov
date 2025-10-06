# app/helpers/minio_helper.rb
module MinioHelper
  # переключатель MinIO ↔ локальные ассеты
  def image_url_for(key)
    return "" if key.blank?

    if ENV["USE_MINIO"] == "1"
      base = ENV.fetch("MINIO_PUBLIC_BASE", "http://localhost:9000/beams")
      "#{base}/#{key}"
    else
      asset_path(key) # берёт из app/assets/images
    end
  end

  # на всякий случай оставим совместимость со старым именем
  alias_method :minio_url, :image_url_for
end
