# frozen_string_literal: true

require 'swagger_helper'

describe 'Requests & Cart API', swagger_doc: 'v1/swagger.yaml' do
  let(:service) do
    Service.create!(
      name: 'Beam 50x150',
      material: 'wooden',
      elasticity_gpa: 12,
      inertia_cm4: 1500,
      allowed_deflection_ratio: 250
    )
  end

  let(:user) do
    User.create!(email: 'user@example.com', password: 'secret123', password_confirmation: 'secret123')
  end

  let(:Authorization) do
    "Bearer #{JwtToken.encode(user_id: user.id, exp: 2.hours.from_now.to_i)}"
  end

  path '/api/request_services' do
    post 'Add service to current draft request' do
      tags 'Requests'
      consumes 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :request_service, in: :body, schema: {
        type: :object,
        required: %i[service_id quantity],
        properties: {
          service_id: { type: :integer },
          quantity: { type: :integer, minimum: 1 }
        }
      }

      response '201', 'Service added to cart' do
        let(:request_service) { { service_id: service.id, quantity: 2 } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:request_service) { { service_id: service.id, quantity: 1 } }
        run_test!
      end
    end
  end

  path '/api/requests/{id}/form' do
    put 'Validate draft and mark as formed (user only)' do
      tags 'Requests'
      security [{ bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer

      response '200', 'Request formed' do
        let(:request_record) do
          Request.create!(
            creator: user,
            length_m: 5.5,
            udl_kn_m: 3.25
          ).tap do |req|
            req.requests_services.create!(service: service, quantity: 1)
          end
        end

        let(:id) { request_record.id }
        run_test!
      end

      response '403', 'Cannot form foreign request' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'secret123', password_confirmation: 'secret123') }
        let(:request_record) { Request.create!(creator: other_user) }
        let(:id) { request_record.id }
        run_test!
      end
    end
  end

  path '/api/requests/{id}/complete' do
    put 'Complete formed request (moderator only)' do
      tags 'Requests'
      security [{ bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer

      response '200', 'Request completed' do
        let(:moderator) do
          User.create!(email: 'mod@example.com', password: 'secret123', password_confirmation: 'secret123', moderator: true)
        end
        let(:Authorization) do
          "Bearer #{JwtToken.encode(user_id: moderator.id, exp: 2.hours.from_now.to_i)}"
        end
        let(:request_record) do
          Request.create!(
            creator: user,
            status: RequestScopes::STATUSES[:formed],
            formed_at: Time.current,
            length_m: 5.5,
            udl_kn_m: 3.25
          ).tap do |req|
            req.requests_services.create!(service: service, quantity: 1)
          end
        end
        let(:id) { request_record.id }
        run_test!
      end

      response '403', 'Requires moderator role' do
        let(:request_record) do
          Request.create!(
            creator: user,
            status: RequestScopes::STATUSES[:formed],
            formed_at: Time.current
          )
        end
        let(:id) { request_record.id }
        run_test!
      end
    end
  end
end
