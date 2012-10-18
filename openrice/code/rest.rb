# UTF-8 Encoding

################################
## DATA SCRAPPER FOR OPENRICE ##
################################

# Scrapper for resturants

require 'rubygems'
require 'mechanize'


# Step 1: Initialize agent
agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'     # surrogate browser
}


# Step 2: Open output files
rest_file = File.open("rest.csv", "w")


# Step 3: Define target http
http = 'http://www.openrice.com/restaurant/sr1.htm?s=1&inputcategory=cname&ST=1&district_id=1999%2c2999%2c3999%2c4999&award=20&page='


# Step 4: Initialize ID hash
rest_hash = Hash.new


# Step 5: Loop through all pages
# Counters
n = 1
while true
  # PUTS progress information
  puts "-> Checking page " + n.to_s
  
  # get gateway page (list of resturants)
  ttl = 5
  while true
    begin
      gateway = agent.get(http + n.to_s)
      break
    rescue
      puts "-> Alert: Loading again in " + ttl.to_s
      ttl += 1
    end
  end
  # increase counter
  n += 1
  # sleep for a while
  sleep(0.01)
  
  # get all the resturant links on the page
  rest_list = gateway.links_with(:href => /\/restaurant\/sr2.htm\?shopid/)
  # if no results just break
  if rest_list.length == 0
    break
  end
  # loop through all the links
  rest_list.each do |rest|
    if rest.text != ""
      rest_id = rest.href.match(/\=\d+/).to_s.match(/\d+/).to_s
      if rest_hash[rest_id] == nil
        rest_name = rest.text
        rest_hash[rest_id] = rest_name
        # PUTS file
        rest_file.puts rest_id + "\t" + rest_name
        # PUTS resturant collection
        puts "  -> Added Resturant " + rest_id + " " + rest_name
      end
    end
  end   
end

# Step 6: Close files
rest_file.close




