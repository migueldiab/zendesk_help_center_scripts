require_relative '../zd_wrapper/zd_http'

sandbox = ZDHttpAPI.new(:sandbox)
production = ZDHttpAPI.new(:production)

locales = production.get("/help_center/locales.json")
locales.delete("en-us")

prod_cats = production.get("/help_center/categories.json")

prod_cats.each do |category|
  cat_payload = {:category => category}.to_json

  puts "Importing category #{category[:name]}..."
  sandb_cat = sandbox.post("/help_center/categories.json", cat_payload)
  puts "Done.".green

  prod_cats_translations = production.get("/help_center/categories/#{category[:id]}/translations.json")

  prod_cats_translations.each do |cat_translation|

    if locales.include?(cat_translation[:locale])
      cat_translation_payload = {:translation => cat_translation}.to_json

      puts "Importing #{cat_translation[:locale].upcase.bold} translation for category #{category[:name]}..."
      sandb_cat_translation = sandbox.post("/help_center/categories/#{sandb_cat[:id]}/translations.json", cat_translation_payload)
      puts "Done.".green
    end
  end

  prod_sects = production.get("/help_center/categories/#{category[:id]}/sections.json")

  prod_sects.each do |section|
    sect_payload = {:section => section}.to_json

    puts "Importing section #{section[:name]}..."
    sandb_sect = sandbox.post("/help_center/categories/#{sandb_cat[:id]}/sections.json", sect_payload)
    puts "Done.".green

    prod_sects_translations = production.get("/help_center/sections/#{section[:id]}/translations.json")

    prod_sects_translations.each do |sect_translation|

      if locales.include?(sect_translation[:locale])
        sect_translation_payload = {:translation => sect_translation}.to_json

        puts "Importing #{sect_translation[:locale].upcase.bold} translation for #{section[:name]}..."
        sandb_sect_translation = sandbox.post("/help_center/sections/#{sandb_sect[:id]}/translations.json", sect_translation_payload)
        puts "Done.".green
      end
    end

    prod_arts = production.get("/help_center/sections/#{section[:id]}/articles.json")

    prod_arts.each do |article|
      art_payload = {:article => article}.to_json

      puts "Importing article #{article[:name]}..."
      sandb_art = sandbox.post("/help_center/sections/#{sandb_sect[:id]}/articles.json", art_payload)
      puts "Done.".green

      prod_arts_translations = production.get("/help_center/articles/#{article[:id]}/translations.json")

      prod_arts_translations.each do |art_translation|

        if locales.include?(art_translation[:locale])
          art_translation_payload = {:translation => art_translation}.to_json

          puts "Importing #{art_translation[:locale].upcase.bold} translation for #{article[:name]}..."
          sandb_art_translation = sandbox.post("/help_center/articles/#{sandb_art[:id]}/translations.json", art_translation_payload)
          puts "Done.".green
        end
      end
    end
  end
end