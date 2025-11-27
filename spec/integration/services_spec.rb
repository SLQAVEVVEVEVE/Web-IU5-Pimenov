# frozen_string_literal: true

require 'swagger_helper'

describe 'Services API', swagger_doc: 'v1/swagger.yaml' do
  let(:moderator) do
    User.create!(email: 'mod@example.com', password: 'secret123', password_confirmation: 'secret123', moderator: true)
  end

  let(:moderator_token) do
    "Bearer #{JwtToken.encode(user_id: moderator.id, exp: 2.hours.from_now.to_i)}"
  end

  path '/api/services' do
    get 'List services (public)' do
      tags 'Services'
      produces 'application/json'

      response '200', 'Services returned' do
        run_test!
      end
    end

    post 'Create service (moderator only)' do
      tags 'Services'
      consumes 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :service, in: :body, schema: {
        type: :object,
        required: %i[name material elasticity_gpa inertia_cm4 allowed_deflection_ratio],
        properties: {
          name: { type: :string },
          material: { type: :string, enum: %w[wooden steel reinforced_concrete] },
          elasticity_gpa: { type: :number },
          inertia_cm4: { type: :number },
          allowed_deflection_ratio: { type: :integer }
        }
      }

      response '201', 'Service created' do
        let(:Authorization) { moderator_token }
        let(:service) do
          {
            name: 'Steel beam 200x300',
            material: 'steel',
            elasticity_gpa: 210,
            inertia_cm4: 6000,
            allowed_deflection_ratio: 300
          }
        end
        run_test!
      end

      response '403', 'Forbidden for non-moderators' do
        let(:Authorization) { nil }
        let(:service) { {} }
        run_test!
      end
    end
  end

  path '/api/services/{id}' do
    get 'Fetch service details (public)' do
      tags 'Services'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'Service found' do
        let(:record) do
          Service.create!(
            name: 'Wood beam',
            material: 'wooden',
            elasticity_gpa: 12,
            inertia_cm4: 1500,
            allowed_deflection_ratio: 250
          )
        end
        let(:id) { record.id }
        run_test!
      end
    end

    put 'Update service (moderator only)' do
      tags 'Services'
      consumes 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :id, in: :path, type: :integer
      parameter name: :service, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          material: { type: :string },
          allowed_deflection_ratio: { type: :integer }
        }
      }

      response '200', 'Service updated' do
        let(:Authorization) { moderator_token }
        let(:record) do
          Service.create!(
            name: 'Wood beam',
            material: 'wooden',
            elasticity_gpa: 12,
            inertia_cm4: 1500,
            allowed_deflection_ratio: 250
          )
        end
        let(:id) { record.id }
        let(:service) { { allowed_deflection_ratio: 150 } }
        run_test!
      end
    end

    delete 'Delete service (moderator only)' do
      tags 'Services'
      security [{ bearerAuth: [] }]
      parameter name: :id, in: :path, type: :integer

      response '204', 'Service deleted' do
        let(:Authorization) { moderator_token }
        let(:record) do
          Service.create!(
            name: 'Wood beam',
            material: 'wooden',
            elasticity_gpa: 12,
            inertia_cm4: 1500,
            allowed_deflection_ratio: 250
          )
        end
        let(:id) { record.id }
        run_test!
      end
    end
  end
end
