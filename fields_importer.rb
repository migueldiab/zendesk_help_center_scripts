require_relative '../zd_wrapper/zd_http'

# Sloppy logging
def self.write_to_log(line)
  open('fields_log.txt', 'a') { |f| f << "#{line}\n\n" }
end

# Instantiatiate the wrapper for the sandbox and production
sandbox = ZDHttpAPI.new(:sandbox)
production = ZDHttpAPI.new(:production)

#Get all the fields from production
items = production.get("/ticket_fields.json")

# Items that we ignore when importing from production
excl_items = [:id, :url, :updated_at, :created_at, :removable]

#Create payload
item_payload = {:ticket_field=>{}}

#Delete Sandbox Fields
del_items = sandbox.get("/ticket_fields.json")
del_items.each do |del_item| 
	if del_item[:removable] == true
		sandbox.delete("/ticket_fields/#{del_item[:id]}.json", {:verbose => true, :override_warning => true})
	end
end


items.each do |item|

	if item[:removable] == true && !item.has_key?("system_field_options".to_sym)

		item.each do |key, value|
			item_payload[:ticket_field].store(key, value) unless excl_items.include?(key)
		end
 
 		puts "********************"
		puts item
		puts "---------------------"
		puts item_payload

		sandbox.post("/ticket_fields.json", item_payload.to_json, :verbose=>true)

		#Writes in log file
		puts production_title = "Production field name: #{item[:title].bold}"
		puts sandbox_title = "Imported field title: #{item_payload[:ticket_field][:title].bold}"
		write_to_log(production_title + "\n" + sandbox_title)

		item_payload[:ticket_field].clear
		field_payload[:ticket_field].clear

	end


end