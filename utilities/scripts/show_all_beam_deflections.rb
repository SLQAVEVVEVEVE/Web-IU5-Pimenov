# Show all beam_deflections grouped by status
puts "=" * 60
puts "All beam_deflections in system:"
puts "=" * 60
puts ""

# Count by status
puts "📊 Count by status:"
BeamDeflection.group(:status).count.each do |status, count|
  puts "  #{status}: #{count}"
end

puts ""
puts "=" * 60
puts "Detailed list (non-deleted):"
puts "=" * 60

BeamDeflection.not_deleted.order(:status, :id).each do |bd|
  puts ""
  puts "ID: #{bd.id}"
  puts "  Status: #{bd.status}"
  puts "  Creator: #{bd.creator&.email}"
  puts "  Moderator: #{bd.moderator&.email || 'N/A'}"
  puts "  Created: #{bd.created_at.strftime('%Y-%m-%d %H:%M')}"
  puts "  Length: #{bd.length_m || 'N/A'} m"
  puts "  UDL: #{bd.udl_kn_m || 'N/A'} kN/m"
end

puts ""
puts "=" * 60
puts "Test scenarios:"
puts "=" * 60
puts ""

# Count what moderator will see
moderator_count = BeamDeflection.not_deleted.count
puts "Moderator will see: #{moderator_count} beam_deflections (all non-deleted)"

# Count what regular user will see (example with demo@local)
demo_user = User.find_by(email: 'demo@local')
if demo_user
  user_count = demo_user.beam_deflections.not_deleted.not_draft.count
  user_drafts = demo_user.beam_deflections.draft.count
  puts "demo@local will see: #{user_count} beam_deflections (their own, non-draft)"
  puts "demo@local has drafts: #{user_drafts} (not visible in GET /api/beam_deflections)"
end

puts ""
puts "=" * 60
puts "Swagger test:"
puts "=" * 60
puts ""
puts "1. Sign in as moderator:"
puts "   POST /api/auth/sign_in"
puts "   {\"email\": \"moderator@example.com\", \"password\": \"password123\"}"
puts ""
puts "2. GET /api/beam_deflections - should return #{moderator_count} items"
puts ""
puts "3. Filter by draft status:"
puts "   GET /api/beam_deflections?status=draft"
puts ""
