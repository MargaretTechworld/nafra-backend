# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create basic reference data for testing
puts "Creating reference data..."

# Regions
eastern = Region.find_or_create_by!(name: "Eastern Region")
northern = Region.find_or_create_by!(name: "Northern Region")
north_western = Region.find_or_create_by!(name: "North Western Region")
southern = Region.find_or_create_by!(name: "Southern Region")
western_rural = Region.find_or_create_by!(name: "Western Area Rural")
western_urban = Region.find_or_create_by!(name: "Western Area Urban")

# Districts
District.find_or_initialize_by(name: "Bombali District").tap { |d| d.update!(region: northern) }
District.find_or_initialize_by(name: "Kambia District").tap { |d| d.update!(region: north_western) }
District.find_or_initialize_by(name: "Kenema District").tap { |d| d.update!(region: eastern) }
District.find_or_initialize_by(name: "Koinadugu District").tap { |d| d.update!(region: northern) }
District.find_or_initialize_by(name: "Moyamba District").tap { |d| d.update!(region: southern) }
District.find_or_initialize_by(name: "Freetown Urban").tap { |d| d.update!(region: western_urban) }
District.find_or_initialize_by(name: "Freetown Rural").tap { |d| d.update!(region: western_rural) }

# Chiefdoms
bombali = District.find_by(name: "Bombali District")
Chiefdom.find_or_create_by!(name: "Binkolo Chiefdom", district: bombali)
Chiefdom.find_or_create_by!(name: "Diang Chiefdom", district: bombali)

kambia = District.find_by(name: "Kambia District")
Chiefdom.find_or_create_by!(name: "Mambolo Chiefdom", district: kambia)
Chiefdom.find_or_create_by!(name: "Magbema Chiefdom", district: kambia)

# Fertilizers
Fertilizer.find_or_create_by!(name: "NPK 15-15-15")
Fertilizer.find_or_create_by!(name: "Urea 46-0-0")
Fertilizer.find_or_create_by!(name: "DAP 18-46-0")
Fertilizer.find_or_create_by!(name: "MOP 0-0-60")

# Dealers (Admin only)
Dealer.find_or_initialize_by(name: "Agro Input Suppliers Ltd").tap do |d|
  d.update!(license_number: "AGR001", status: "active", category: "Major Importer", licensing_status: "Active")
end
Dealer.find_or_initialize_by(name: "Farmers Choice Co.").tap do |d|
  d.update!(license_number: "AGR002", status: "active", category: "Local Distributor", licensing_status: "Active")
end

puts "Reference data created successfully!"
