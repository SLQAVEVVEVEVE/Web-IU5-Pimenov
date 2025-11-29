# frozen_string_literal: true

require 'swagger_helper'

describe 'Beams API', swagger_doc: 'v1/swagger.yaml' do
  let(:moderator) do
    User.find_or_create_by!(email: 'mod@example.com') do |u|
      u.password = 'secret123'
      u.password_confirmation = 'secret123'
      u.moderator = true
    end
  end

  let(:moderator_token) do
    "Bearer #{JwtToken.encode(user_id: moderator.id, exp: 2.hours.from_now.to_i)}"
  end

  path '/api/beams' do
    get 'List beams (public)' do
      tags 'Beams'
      produces 'application/json'

      response '200', 'Beams returned' do
        run_test!
      end
    end

    post 'Create beam (moderator only)' do
      tags 'Beams'
      consumes 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :beam, in: :body, schema: {
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

      response '201', 'Beam created' do
        let(:Authorization) { moderator_token }
        let(:beam) do
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
        let(:beam) { {} }
        run_test!
      end
    end
  end

  path '/api/beams/{id}' do
    get 'Fetch beam details (public)' do
      tags 'Beams'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'Beam found' do
        let(:record) do
          Beam.create!(
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

    put 'Update beam (moderator only)' do
      tags 'Beams'
      consumes 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :id, in: :path, type: :integer
      parameter name: :beam, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          material: { type: :string },
          allowed_deflection_ratio: { type: :integer }
        }
      }

      response '200', 'Beam updated' do
        let(:Authorization) { moderator_token }
        let(:record) do
          Beam.create!(
            name: 'Wood beam',
            material: 'wooden',
            elasticity_gpa: 12,
            inertia_cm4: 1500,
            allowed_deflection_ratio: 250
          )
        end
        let(:id) { record.id }
        let(:beam) { { allowed_deflection_ratio: 150 } }
        run_test!
      end
    end

    delete 'Delete beam (moderator only)' do
      tags 'Beams'
      security [{ bearerAuth: [] }]
      parameter name: :id, in: :path, type: :integer

      response '204', 'Beam deleted' do
        let(:Authorization) { moderator_token }
        let(:record) do
          Beam.create!(
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
