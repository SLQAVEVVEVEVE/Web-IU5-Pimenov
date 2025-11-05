# frozen_string_literal: true

Rails.application.configure do
  config.x.minio = ActiveSupport::OrderedOptions.new
  
  # INTERNAL: used by aws-sdk-s3 within containers
  config.x.minio.internal_endpoint = ENV.fetch("MINIO_INTERNAL_ENDPOINT", "http://minio:9000")
  # EXTERNAL: used in HTML for the browser (host-facing)
  config.x.minio.external_endpoint = ENV.fetch("MINIO_EXTERNAL_ENDPOINT", "http://localhost:9000")

  config.x.minio.bucket      = ENV.fetch("MINIO_BUCKET", "beam-deflection")
  config.x.minio.region      = ENV.fetch("MINIO_REGION", "us-east-1")
  config.x.minio.access_key  = ENV.fetch("MINIO_ACCESS_KEY", "minioadmin")
  config.x.minio.secret_key  = ENV.fetch("MINIO_SECRET_KEY", "minioadmin")
  config.x.minio.signed_urls = ActiveModel::Type::Boolean.new.cast(ENV["MINIO_SIGNED_URLS"])
end
