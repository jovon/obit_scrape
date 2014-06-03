require 'rubygems'
require 'open-uri'
require_relative 'legacy_obitfinder'
require_relative 'html_file'
require 'odbc_utf8'


DB = ODBC.connect('foundsql92', ENV['ODBC_USER'].to_s, ENV['ODBC_PASS'].to_s)
FundHolder = Struct.new(:first_name, :last_name)

def all_fundholders
  fundholders = []
  id_codes = []
  begin
    if DB.connected?
      stmt = DB.run(%q{SELECT IDCode from PUB."Fund-Rep" WHERE PUB."Fund-Rep"."Rep-Type"='Signer' Group By IDCode})
      stmt.each_hash { |row| id_codes << row }
      stmt.drop
      id_codes.each do |id| 
        stmt = DB.run(%q{SELECT fname as first_name, lname as last_name from PUB.Profile WHERE orgcode = 1 and IDCode = ?}, id['IDCode'])
        stmt.fetch_hash { |record| fundholders << FundHolder.new(record["first_name"], record["last_name"]) }
        stmt.drop
      end
      fundholders
    else
      puts "not connected"
    end
   rescue
    puts "Database error" 
  end
end

puts "Getting Fundholders"
fundholders = all_fundholders
legacy_find = LegacyObitFinder.new(state_id: 33, date_range: 'Last14Days', affiliate_id: 1878)
puts "Getting Obituaries..."
nc_obits = legacy_find.all_obits  
matches = []
puts "Searching Obituaries..."
nc_obits.each do |obit|
  fundholders.each do |fh| 
    if fh.first_name && fh.last_name
      matches << obit if obit.name.downcase.include?(fh.first_name.downcase) && obit.name.downcase.include?(fh.last_name.downcase) 
    end
  end
  print "."
end
  

HtmlFile.new(matches).create