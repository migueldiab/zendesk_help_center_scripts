require_relative '../zd_wrapper/zd_http'

# Sloppy logging
def self.write_to_log(line)
  open('log.txt', 'a') { |f| f << "#{line}\n\n" }
end

# Instantiatiate the warapper for the sandbox and production
sandbox = ZDHttpAPI.new(:sandbox)
production = ZDHttpAPI.new(:production)

# Items that we ignore when importing from production
excl_items = [:id, :url, :updated_at, :created_at]

# Create the payload structure for items and variants
item_payload = {:item=>{}}
vari_payload = {:variant=>{}}

# Get all dynamic content items from production
items = production.get("/dynamic_content/items.json")

# First delete all existing dynamic content in the sandbox
del_items = sandbox.get("/dynamic_content/items.json")
del_items.each { |del_item| sandbox.delete("/dynamic_content/items/#{del_item[:id]}.json", {:verbose => true, :override_warning => true}) }

items.each do |item|

  item.each { |k, v| item_payload[:item].store(k, v) unless excl_items.include?(k) }
  variants = production.get("/dynamic_content/items/#{item[:id]}/variants.json")


  item_payload[:item].store(:content, variants[0][:content])

  # Silly hack for one particular item that was using a long dash instead of a regular dash
  # Long dashes are considered a special character and not permitted in titles by the ZD API
  item_name = item_payload[:item][:name].gsub(/[–]/,"-")
  # hack to make the placeholders the same in the sandbox
  item_payload[:item][:name] = item_payload[:item][:placeholder].delete('{{}}.').tr('_', ' ').gsub('dc', '')


  # Output results to a log file
  puts production_title = "Production DC title: #{item[:name].bold}"
  puts sandbox_title = "Imported DC title: #{item_payload[:item][:name].bold}"
  write_to_log(production_title + "\n" + sandbox_title)


  new_item = sandbox.post("/dynamic_content/items.json", item_payload.to_json, :verbose => true)

  # Change item name back to the correct one (at this point it has one based on the placeholder)
  item_payload = {:item=>{}}
  item_payload[:item][:name] = "a name that will never be taken"
  sandbox.put("/dynamic_content/items/#{new_item[:id]}.json", item_payload.to_json, :verbose => true)
  item_payload[:item][:name] = item_name
  sandbox.put("/dynamic_content/items/#{new_item[:id]}.json", item_payload.to_json, :verbose => true)


  # Just gonna list the rest of the variants now.
  puts "Variants:".bold

  # Iterate through all variants except the first one (used that as the default value)
  variants[1..-1].each do |vari|

    #  Transfer variants into vari_payload and import
    vari.each { |k,v| vari_payload[:variant].store(k, v) unless excl_items.include?(k) }
    sandbox.post("/dynamic_content/items/#{new_item[:id]}/variants.json", vari_payload.to_json, :verbose => true)
    vari_payload[:variant].clear

  end

  # (not so) arbitrary divider
  puts "--------------"
  # Clear the item_payload variable, just in case.
  new_item.clear
  item_payload[:item].clear
end
