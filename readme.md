#Zendesk Help Center Scripts

These scripts are meant to assist in making your Zendesk sandbox a more accurate clone of your main Zendesk instance (henceforth: "production").

##Installation

1. `$ git clone https://github.com/jpalmieri/zendesk_help_center_scripts.git`
2. `$ cd zendesk_help_center_scripts`
3. `$ git submodule init && git submodule update`
4. Follow the configuration instructions for the zd_wrapper tool: https://github.com/jpalmieri/zd_wrapper

##Usage

These Ruby scripts are meant to be run via the command line, e.g.,
`$ ruby hc_importer.rb`

##Scripts

- `hc_importer.rb` will copy all of the categories, sections and articles from your production Help Center into the sandbox
- `dc_importer.rb` will copy all of your dynamic content
- `fields_importer.rb` will copy all of your custom fields
- `ticket_forms.rb` will copy all of your ticket forms

Note: be sure to run `fields_importer.rb` before `ticket_forms.rb`, as the forms will need to already have the custom fields installed.
