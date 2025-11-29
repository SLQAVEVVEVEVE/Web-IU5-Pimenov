module Api
  class BeamDeflectionBeamsController < Api::BaseController
    before_action :require_auth!
    before_action :ensure_draft_beam_deflection
    before_action :set_beam_deflection_beam, only: [:update, :destroy]

    # POST /api/beam_deflection_beams
    def create
      @beam_deflection_beam = @beam_deflection.beam_deflection_beams.find_or_initialize_by(
        beam_id: beam_deflection_beam_params[:beam_id]
      )
      
      # If service already exists in cart, increment quantity
      if @beam_deflection_beam.persisted?
        @beam_deflection_beam.quantity += (beam_deflection_beam_params[:quantity] || 1).to_i
      else
        @beam_deflection_beam.quantity = (beam_deflection_beam_params[:quantity] || 1).to_i
      end
      
      if @beam_deflection_beam.save
        render json: @beam_deflection_beam, status: :created
      else
        render json: { errors: @beam_deflection_beam.errors.full_messages }, 
               status: :unprocessable_entity
      end
    end

    # PUT /api/beam_deflection_beams
    def update
      if @beam_deflection_beam.update(beam_deflection_beam_params)
        render json: @beam_deflection_beam
      else
        render json: { errors: @beam_deflection_beam.errors.full_messages }, 
               status: :unprocessable_entity
      end
    end

    # DELETE /api/beam_deflection_beams
    def destroy
      @beam_deflection_beam.destroy
      head :no_content
    end

    # POST /api/beam_deflection_beams/add_to_cart
    # Simplified endpoint for frontend to add/update service in cart
    def add_to_cart
      beam = Beam.find_by(id: params[:beam_id])
      return render json: { error: 'Beam not found' }, status: :not_found unless beam
      
      @beam_deflection_beam = @beam_deflection.beam_deflection_beams.find_or_initialize_by(beam_id: beam.id)
      
      if params[:quantity].to_i <= 0
        @beam_deflection_beam.destroy
        head :no_content
      else
        @beam_deflection_beam.quantity = params[:quantity].to_i
        
        if @beam_deflection_beam.save
          render json: @beam_deflection_beam
        else
          render json: { errors: @beam_deflection_beam.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end
    end

    private

    def ensure_draft_beam_deflection
      @beam_deflection = BeamDeflection.draft_for(Current.user).first_or_initialize(creator: Current.user)
      @beam_deflection.save! if @beam_deflection.new_record?
    end

    def set_beam_deflection_beam
      @beam_deflection_beam = @beam_deflection.beam_deflection_beams.find_by(beam_id: params[:id])
      return if @beam_deflection_beam
      
      render json: { error: 'Beam not found in beam deflection' }, status: :not_found
    end

    def beam_deflection_beam_params
      params.require(:beam_deflection_beam).permit(:beam_id, :quantity)
    end
  end
end
