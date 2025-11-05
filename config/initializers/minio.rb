# frozen_string_literal: true

require 'aws-sdk-s3'

# Configure MinIO settings
Rails.application.config.x.minio = {
  internal_endpoint: ENV.fetch('MINIO_INTERNAL_ENDPOINT', 'http://minio:9000'),
  external_endpoint: ENV.fetch('MINIO_EXTERNAL_ENDPOINT', 'http://localhost:9000'),
  bucket: ENV.fetch('MINIO_BUCKET', 'beam-deflection'),
  access_key: ENV.fetch('MINIO_ACCESS_KEY', 'minio'),
  secret_key: ENV.fetch('MINIO_SECRET_KEY', 'minio12345'),
  region: ENV.fetch('MINIO_REGION', 'us-east-1'),
  signed_urls: ENV.fetch('MINIO_SIGNED_URLS', 'false') == 'true'
}.with_indifferent_access

# Log MinIO configuration
Rails.logger.info("[MinIO] Configuration: " + 
  "internal=#{Rails.application.config.x.minio[:internal_endpoint]} " +
  "external=#{Rails.application.config.x.minio[:external_endpoint]} " +
  "bucket=#{Rails.application.config.x.minio[:bucket]}")

# Configure AWS SDK for S3 (used by MinIO)
Aws.config.update(
  endpoint: Rails.application.config.x.minio[:internal_endpoint],
  access_key_id: Rails.application.config.x.minio[:access_key],
  secret_access_key: Rails.application.config.x.minio[:secret_key],
  region: Rails.application.config.x.minio[:region],
  force_path_style: true,
  validate_params: false
)
