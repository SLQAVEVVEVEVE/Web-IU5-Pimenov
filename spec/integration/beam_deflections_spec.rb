# frozen_string_literal: true

require 'swagger_helper'

describe 'BeamDeflections & Cart API', swagger_doc: 'v1/swagger.yaml' do
  let(:beam) do
    Beam.create!(
      name: 'Beam 50x150',
      material: 'wooden',
      elasticity_gpa: 12,
      inertia_cm4: 1500,
      allowed_deflection_ratio: 250
    )
  end

  let(:user) do
    User.find_or_create_by!(email: 'user@example.com') do |u|
      u.password = 'secret123'
      u.password_confirmation = 'secret123'
    end
  end

  let(:Authorization) do
    "Bearer #{JwtToken.encode(user_id: user.id, exp: 2.hours.from_now.to_i)}"
  end

  path '/api/beam_deflection_beams' do
    post 'Add beam to current draft beam deflection' do
      tags 'BeamDeflections'
      consumes 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :beam_deflection_beam, in: :body, schema: {
        type: :object,
        required: %i[beam_id quantity],
        properties: {
          beam_id: { type: :integer },
          quantity: { type: :integer, minimum: 1 }
        }
      }

      response '201', 'Beam added to cart' do
        let(:beam_deflection_beam) { { beam_id: beam.id, quantity: 2 } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:beam_deflection_beam) { { beam_id: beam.id, quantity: 1 } }
        run_test!
      end
    end
  end

  path '/api/beam_deflections/{id}/form' do
    put 'Validate draft and mark as formed (user only)' do
      tags 'BeamDeflections'
      security [{ bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer

      response '200', 'BeamDeflection formed' do
        let(:beam_deflection_record) do
          BeamDeflection.create!(
            creator: user,
            length_m: 5.5,
            udl_kn_m: 3.25
          ).tap do |bd|
            bd.beam_deflection_beams.create!(beam: beam, quantity: 1)
          end
        end

        let(:id) { beam_deflection_record.id }
        run_test!
      end

      response '403', 'Cannot form foreign beam deflection' do
        let(:other_user) do
          User.find_or_create_by!(email: 'other@example.com') do |u|
            u.password = 'secret123'
            u.password_confirmation = 'secret123'
          end
        end
        let(:beam_deflection_record) { BeamDeflection.create!(creator: other_user) }
        let(:id) { beam_deflection_record.id }
        run_test!
      end
    end
  end

  path '/api/beam_deflections/{id}/complete' do
    put 'Complete formed beam deflection (moderator only)' do
      tags 'BeamDeflections'
      security [{ bearerAuth: [] }]

      parameter name: :id, in: :path, type: :integer

      response '200', 'BeamDeflection completed' do
        let(:moderator) do
          User.find_or_create_by!(email: 'mod@example.com') do |u|
            u.password = 'secret123'
            u.password_confirmation = 'secret123'
            u.moderator = true
          end
        end
        let(:Authorization) do
          "Bearer #{JwtToken.encode(user_id: moderator.id, exp: 2.hours.from_now.to_i)}"
        end
        let(:beam_deflection_record) do
          BeamDeflection.create!(
            creator: user,
            status: BeamDeflectionScopes::STATUSES[:formed],
            formed_at: Time.current,
            length_m: 5.5,
            udl_kn_m: 3.25
          ).tap do |bd|
            bd.beam_deflection_beams.create!(beam: beam, quantity: 1)
          end
        end
        let(:id) { beam_deflection_record.id }
        run_test!
      end

      response '403', 'Requires moderator role' do
        let(:beam_deflection_record) do
          BeamDeflection.create!(
            creator: user,
            status: BeamDeflectionScopes::STATUSES[:formed],
            formed_at: Time.current
          )
        end
        let(:id) { beam_deflection_record.id }
        run_test!
      end
    end
  end
end
