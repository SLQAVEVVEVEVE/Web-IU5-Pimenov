# frozen_string_literal: true

# Helper module for MinIO operations
module MinioHelper
  # Returns a public URL for a MinIO object
  # @param object_key [String] the object key in MinIO (e.g., 'images/example.jpg')
  # @return [String] a valid URL to the MinIO object or placeholder
  def minio_image_url(object_key, placeholder: 'placeholder.png')
    return inline_svg_placeholder if object_key.blank?

    # Use external endpoint for browser access
    public_host = ENV['MINIO_EXTERNAL_ENDPOINT'] || 'http://localhost:9000'
    bucket = ENV['MINIO_BUCKET'] || 'beam-deflection'
    
    # Clean up the object key
    object_key = object_key.to_s.sub(/^\//, '')
    
    # Build the URL
    url = "#{public_host}/#{bucket}/#{ERB::Util.url_encode(object_key)}"
    
    # Log for debugging
    Rails.logger.debug("[MinIO] Generated URL: #{url}")
    
    url
  rescue => e
    Rails.logger.error("[MinIO] Error generating URL for #{object_key}: #{e.message}")
    inline_svg_placeholder
  end
  
  # Returns an inline SVG placeholder as a data URI
  # @return [String] data URI containing a simple SVG placeholder
  def inline_svg_placeholder
    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
        <rect width="100%" height="100%" fill="#f3f4f6"/>
        <text x="50%" y="50%" font-size="14" text-anchor="middle" fill="#9ca3af" dy=".3em">no image</text>
      </svg>
    SVG
    "data:image/svg+xml;utf8,#{CGI.escape(svg.gsub(/\n\s*/, ''))}"
  end

  # Safe image tag helper for MinIO objects
  # @param object_key [String] the MinIO object key
  # @param options [Hash] options for image_tag
  # @return [String] HTML image tag with proper URL and fallback
  def image_url_for(object_key, **options)
    options = options.dup
    
    if object_key.present?
      url = minio_image_url(object_key)
      options[:onerror] = "this.onerror=null; this.src='#{inline_svg_placeholder}';"
    else
      url = inline_svg_placeholder
      options.reverse_merge!(alt: 'No image available')
    end
    
    image_tag(url, **options)
  end
  
  # Backward compatibility aliases
  alias_method :image_url, :minio_image_url
  
  # Original minio_url method for backward compatibility
  def minio_url(key)
    minio_image_url(key)
  end

  # Uploads a file to MinIO
  # @param io_or_path [IO, String] IO object or file path
  # @param key [String] the destination key in the bucket
  # @param content_type [String] MIME type of the file
  # @return [String] the object key if successful
  def minio_upload(io_or_path, key:, content_type: "application/octet-stream")
    obj = s3_object(key)

    body_io = if io_or_path.respond_to?(:read)
                io_or_path
              else
                File.open(io_or_path, "rb")
              end

    obj.put(body: body_io, content_type: content_type)
    key
  ensure
    body_io.close if body_io.is_a?(File) && !body_io.closed?
  end

  # Deletes an object from MinIO
  # @param key [String] the object key to delete
  # @return [void]
  def minio_delete(key)
    return if key.blank?
    s3_object(key).delete
  end

  # Checks if an object exists in MinIO
  # @param key [String] the object key to check
  # @return [Boolean] true if the object exists
  def minio_object_exists?(key)
    return false if key.blank?
    s3_object(key).exists?
  end

  # Generates a presigned URL for private bucket access
  # @param key [String] the object key
  # @param expires_in [Integer] expiration time in seconds
  # @return [String, nil] presigned URL or nil if key is blank
  def minio_presigned_url(key, expires_in: 3600)
    return nil if key.blank?
    s3_object(key).presigned_url(:get, expires_in: expires_in)
  end

  private

  # Returns an S3 resource instance
  # @return [Aws::S3::Resource] the S3 resource
  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new(client: s3_client)
  end

  # Returns an S3 client instance
  # @return [Aws::S3::Client] the S3 client
  def s3_client
    cfg = Rails.application.config.x.minio

    endpoint = cfg[:endpoint] || cfg[:internal_endpoint]

    @s3_client ||= Aws::S3::Client.new(
      access_key_id: cfg[:access_key],
      secret_access_key: cfg[:secret_key],
      region: cfg[:region],
      endpoint: endpoint,
      force_path_style: true
    )
  end

  # Returns the S3 bucket instance
  # @return [Aws::S3::Bucket] the bucket instance
  def s3_bucket
    cfg = Rails.application.config.x.minio
    @s3_bucket ||= s3_resource.bucket(cfg[:bucket])
  end

  # Returns an S3 object for the given key
  # @param key [String] the object key
  # @return [Aws::S3::Object] the S3 object
  def s3_object(key)
    s3_bucket.object(key)
  end
end
