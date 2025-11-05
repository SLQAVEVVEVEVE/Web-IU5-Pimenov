# frozen_string_literal: true

require "aws-sdk-s3"
require "marcel"

namespace :minio do
  def s3_client
    Aws::S3::Client.new(
      region: Rails.configuration.x.minio.region,
      access_key_id: Rails.configuration.x.minio.access_key,
      secret_access_key: Rails.configuration.x.minio.secret_key,
      endpoint: Rails.configuration.x.minio.internal_endpoint, # Use internal endpoint for SDK
      force_path_style: true
    )
  end

  def bucket_name = Rails.configuration.x.minio.bucket

  desc "Create bucket if missing and apply public-read policy"
  task bucket_public: :environment do
    s3 = s3_client
    begin
      s3.create_bucket(bucket: bucket_name)
      puts "Bucket created: #{bucket_name}"
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
      puts "Bucket exists: #{bucket_name}"
    end

    policy = {
      Version: "2012-10-17",
      Statement: [
        {
          Sid: "AllowPublicRead",
          Effect: "Allow",
          Principal: "*",
          Action: ["s3:GetObject"],
          Resource: ["arn:aws:s3:::#{bucket_name}/*"]
        }
      ]
    }.to_json

    s3.put_bucket_policy(bucket: bucket_name, policy: policy)
    puts "Public-read policy applied to #{bucket_name}"
  end

  IMAGE_GLOB = "{jpg,jpeg,png,webp,gif}"

  desc "Upload local images from app/assets/images/* into s3://<bucket>/beams/<filename>"
  task upload_images: :environment do
    base  = Rails.root.join("app", "assets", "images")
    files = Dir.glob(base.join("*.#{IMAGE_GLOB}"))
    if files.empty?
      puts "No local images found under #{base}"; next
    end

    s3 = s3_client
    files.each do |path|
      fname = File.basename(path)                     # e.g. wood.jpg
      key   = "beams/#{fname}"                        # e.g. beams/wood.jpg
      mime  = Marcel::MimeType.for(Pathname.new(path), name: fname)
      s3.put_object(bucket: bucket_name, key: key, body: File.open(path, "rb"), content_type: mime)
      puts "Uploaded: #{key}"
    end
  end

  desc "Set Service.image_url to beams/<mapped-filename> if empty"
  task sync_services: :environment do
    map = {
      /деревян/i            => "beams/wood.jpg",
      /сталь|стальная/i     => "beams/steel.jpg",
      /жб|железобетон/i     => "beams/rc.jpg"
    }
    Service.find_each do |s|
      next if s.image_url.present?
      if (pair = map.find { |rx, _| s.name =~ rx })
        s.update!(image_url: pair.last)
        puts "Service #{s.id} (#{s.name}) -> #{pair.last}"
      else
        puts "Service #{s.id} (#{s.name}) no mapping; leave image_url nil"
      end
    end
  end

  desc "Create public bucket, upload images, and sync Service.image_url"
  task bootstrap: [:bucket_public, :upload_images, :sync_services]
end
