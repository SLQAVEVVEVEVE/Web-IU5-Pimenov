module Api
  module BeamDeflections
    class ItemsController < BaseController
      before_action :find_beam_deflection
      before_action :validate_beam_deflection_ownership
      
      def update
        # Get or create the beam deflection item
        beam_deflection_beam = @beam_deflection.beam_deflection_beams
                              .find_or_initialize_by(beam_id: item_params[:beam_id])
        
        # Update attributes
        beam_deflection_beam.quantity = item_params[:quantity].to_i if item_params.key?(:quantity)
        beam_deflection_beam.position = item_params[:position].to_i if item_params.key?(:position)
        
        # Validate quantity
        if beam_deflection_beam.quantity.present? && beam_deflection_beam.quantity <= 0
          return render_error('Quantity must be greater than 0', :unprocessable_entity)
        end
        
        if beam_deflection_beam.save
          render json: {
            id: beam_deflection_beam.id,
            beam_id: beam_deflection_beam.beam_id,
            quantity: beam_deflection_beam.quantity,
            position: beam_deflection_beam.position
          }
        else
          render_error(beam_deflection_beam.errors.full_messages, :unprocessable_entity)
        end
      end
      
      def destroy
        # Find the beam deflection beam by beam_id
        beam_deflection_beam = @beam_deflection.beam_deflection_beams.find_by(beam_id: params[:beam_id])
        
        if beam_deflection_beam.nil?
          return render_error('Item not found in this beam deflection', :not_found)
        end
        
        if beam_deflection_beam.destroy
          head :no_content
        else
          render_error('Failed to remove item from beam deflection', :unprocessable_entity)
        end
      end
      
      private
      
      def find_beam_deflection
        @beam_deflection = BeamDeflection.not_deleted.find(params[:beam_deflection_id])
      rescue ActiveRecord::RecordNotFound
        render_error('BeamDeflection not found', :not_found)
      end
      
      def validate_beam_deflection_ownership
        # Only allow updates to draft beam deflections owned by the current user
        unless @beam_deflection.draft? && @beam_deflection.creator == Current.user
          render_error('You can only modify your own draft beam deflections', :forbidden)
        end
      end
      
      def item_params
        params.require(:item).permit(:beam_id, :quantity, :position)
      end
    end
  end
end
