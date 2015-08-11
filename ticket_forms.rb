# This script will import all of the ticket forms from
# production into the sandbox.
# Be sure to run the ticket field importer before this.
require_relative '../zd_wrapper/zd_http'

# Instantiatiate the warapper for the sandbox and production
sandbox = ZDHttpAPI.new(:sandbox)
production = ZDHttpAPI.new(:production)

# Items that we ignore when importing from production
excl_items = [:id, :url, :updated_at, :created_at, :ticket_field_ids]

forms_payload = {:ticket_form=>{:ticket_field_ids=>[]}}

forms = production.get("/ticket_forms.json")
sandbox_fields = sandbox.get("/ticket_fields.json")

# Get all forms before new ones are created.
# We'll be setting them to "inactive" later.
del_forms = sandbox.get("/ticket_forms.json")

forms.each do |form|

  # The ticket field ids are currently production ids,
  # so we need to get the associated sandbox field ids
  form[:ticket_field_ids].each do |field_id|
    prod_field = production.get("/ticket_fields/#{field_id}.json", :verbose => true)
    # Add all but mandatory system fields
    if prod_field[:removable]
      sandbox_fields.each do |sb_field|
        if sb_field[:title] == prod_field[:title]
          forms_payload[:ticket_form][:ticket_field_ids].push(sb_field[:id])
        end
      end
    end
  end

  form.each { |k, v| forms_payload[:ticket_form].store(k, v) unless excl_items.include?(k) }
  new_form = sandbox.post("/ticket_forms.json", forms_payload.to_json, :verbose => true)
  puts new_form
  new_form.clear
  forms_payload = {:ticket_form=>{:ticket_field_ids=>[]}}
end

# Delete original forms
del_forms.each { |del_form| sandbox.delete("/ticket_forms/#{del_form[:id]}.json", {:verbose => true, :override_warning => true}) }

