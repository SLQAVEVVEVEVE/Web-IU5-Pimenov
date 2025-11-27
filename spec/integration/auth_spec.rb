# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/auth/sign_in' do
    post 'Sign in and receive JWT' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        required: %i[email password],
        properties: {
          email: { type: :string, format: :email, example: 'user@example.com' },
          password: { type: :string, example: 'secret123' }
        }
      }

      response '200', 'Signed in' do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     moderator: { type: :boolean }
                   }
                 }
               }

        let(:user) { create(:user, password: 'secret123', password_confirmation: 'secret123') }
        let(:credentials) { { email: user.email, password: 'secret123' } }

        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:credentials) { { email: 'unknown@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/api/auth/sign_up' do
    post 'Register and receive JWT' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[email password password_confirmation],
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, minLength: 6 },
          password_confirmation: { type: :string }
        }
      }

      response '201', 'User created' do
        let(:payload) { { email: 'new@example.com', password: 'secret123', password_confirmation: 'secret123' } }
        run_test!
      end

      response '422', 'Validation error' do
        let(:payload) { { email: 'bad', password: 'short', password_confirmation: 'nope' } }
        run_test!
      end
    end
  end

  path '/api/auth/sign_out' do
    post 'Sign out (client should discard token)' do
      tags 'Auth'
      security [{ bearerAuth: [] }]

      response '204', 'Signed out' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtToken.encode(user_id: user.id, exp: 1.hour.from_now.to_i)}" }
        run_test!
      end
    end
  end

  path '/api/me' do
    get 'Current user profile' do
      tags 'Me'
      produces 'application/json'
      security [{ bearerAuth: [] }]

      response '200', 'Profile returned' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtToken.encode(user_id: user.id, exp: 1.hour.from_now.to_i)}" }
        run_test!
      end
    end

    put 'Update current user credentials' do
      tags 'Me'
      consumes 'application/json'
      security [{ bearerAuth: [] }]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, minLength: 6 },
          password_confirmation: { type: :string }
        }
      }

      response '200', 'Updated' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JwtToken.encode(user_id: user.id, exp: 1.hour.from_now.to_i)}" }
        let(:payload) { { email: 'updated@example.com' } }
        run_test!
      end
    end
  end
end
