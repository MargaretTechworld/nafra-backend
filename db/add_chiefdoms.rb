# Add missing chiefdoms for all districts
puts "Adding missing chiefdoms..."

# Kenema District (ID: 3)
Chiefdom.find_or_create_by(name: 'Koya Chiefdom', district_id: 3)
Chiefdom.find_or_create_by(name: 'Nongowa Chiefdom', district_id: 3)

# Koinadugu District (ID: 4)  
Chiefdom.find_or_create_by(name: 'Diang Chiefdom', district_id: 4)
Chiefdom.find_or_create_by(name: 'Falaba Chiefdom', district_id: 4)

# Moyamba District (ID: 5)
Chiefdom.find_or_create_by(name: 'Bagruwa Chiefdom', district_id: 5)
Chiefdom.find_or_create_by(name: 'Koya Chiefdom', district_id: 5)

puts "✅ All chiefdoms added successfully!"
