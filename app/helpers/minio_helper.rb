# frozen_string_literal: true

module MinioHelper
  PLACEHOLDER_IMG = "data:image/svg+xml;utf8," \
    "<svg xmlns='http://www.w3.org/2000/svg' width='160' height='120'>" \
    "<rect width='100%' height='100%' fill='%23eee'/>" \
    "<text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='%23999' font-size='14'>Нет изображения</text>" \
    "</svg>"

  def minio_image_url(object_key)
    return PLACEHOLDER_IMG if object_key.blank?
    return object_key if object_key.to_s =~ %r{\Ahttps?://}i

    base   = Rails.configuration.x.minio.external_endpoint.to_s.sub(%r{/\z}, "")
    bucket = Rails.configuration.x.minio.bucket
    url    = "#{base}/#{bucket}/#{object_key.to_s.sub(%r{\A/+}, '')}"

    if Rails.configuration.x.minio.signed_urls
      begin
        require "aws-sdk-s3"
        creds = Aws::Credentials.new(
          Rails.configuration.x.minio.access_key,
          Rails.configuration.x.minio.secret_key
        )
        s3 = Aws::S3::Resource.new(
          region: Rails.configuration.x.minio.region,
          credentials: creds,
          endpoint: Rails.configuration.x.minio.internal_endpoint,
          force_path_style: true
        )
        obj = s3.bucket(bucket).object(object_key)
        return obj.presigned_url(:get, expires_in: 3600)
      rescue => _
        return url
      end
    end

    url
  end

  # Backward-compat shims
  def minio_url(object_key)     = minio_image_url(object_key)
  def image_url_for(object_key) = minio_image_url(object_key)
end
