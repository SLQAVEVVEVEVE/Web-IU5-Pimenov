module ServiceScopes
  extend ActiveSupport::Concern
  
  included do
    scope :available, -> { where(active: true) }
    
    scope :search, ->(q) {
      where('name ILIKE :q OR material ILIKE :q OR description ILIKE :q', q: "%#{q}%")
    }
    
    # For backward compatibility
    scope :by_query, ->(query) {
      search(query)
    }
    
    scope :by_active, ->(active) {
      active ? available : all
    }
  end
end
