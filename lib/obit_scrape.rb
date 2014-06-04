require 'rubygems'
require 'open-uri'
require_relative 'legacy_obitfinder'
require_relative 'html_file'
require 'sequel'


DB = Sequel.odbc('foundsql92', :user => ENV['ODBC_USER'].to_s, :password => ENV['ODBC_PASS'].to_s, :db_type => 'progress')
FundHolder = Struct.new(:first_name, :last_name)

def individual_signers
  fundholders = []
  id_codes = []
  DB.fetch(%q{SELECT IDCode as id from PUB."Fund-Rep" WHERE PUB."Fund-Rep"."Rep-Type"='Signer' Group By IDCode}) do |row| 
    id_codes << row 
  end    
  id_codes.each do |id| 
    DB.fetch(%q{SELECT fname as first_name, lname as last_name from PUB.Profile WHERE orgcode = 1 and IDCode = ?}, id[:id]) do |record| 
      fundholders << FundHolder.new(record[:first_name], record[:last_name])
    end      
  end
  fundholders    
end

puts "Getting Fundholders"
fundholders = individual_signers
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