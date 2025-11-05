# frozen_string_literal: true

# This class provides a thread-safe way to access the current user
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  
  def user=(user)
    super
    # Add any additional setup when user is set
  end
  
  def self.moderator?
    user&.moderator?
  end
end
