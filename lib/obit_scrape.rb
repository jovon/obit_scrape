require 'rubygems'
require 'open-uri'
require_relative 'legacy_obitfinder'
# url='http://www.legacy.com/ns/obitfinder/obituary-search.aspx?daterange=Last14Days&keyword=Durham&countryid=1&stateid=33&affiliateid=1878'
# open(url) { |file|
#   obit = false
#   file.each_line { |line|
#     if obit
#       p line
#       obit = false
#     end
#     obit = true if line.include?("class=\"obitName\"")
#   }
# }
durham = LegacyObitFinder.new(keyword: "Durham")
durham.obits