# UTF-8 Encoding

################################
## DATA SCRAPPER FOR OPENRICE ##
################################

# Scrapper for users

require 'rubygems'
require 'mechanize'


# Step 1: Initialize agent
agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'     # surrogate browser
}


# Step 2: Open input/output files
rest_file = File.open("rest.csv", "r")
user_file = File.open("user.csv", "w")
edge_file = File.open("edge.csv", "w")
 

# Step 3: Define target http
http = 'http://www.openrice.com/restaurant/reviews.htm?shopid='


# Step 4: Initialize ID hash
rest_hash = Hash.new
user_hash = Hash.new


# Step 5: Parse inut file
counter = 1
while line = rest_file.gets
  rest_hash[counter.to_s] = line.match(/\d+/).to_s
  counter += 1
end

# Step 6: Loop resturant
rest_hash.map do |key, value|
  # Indicator
  puts "-> Checking resturant " + value
  
  # Page counter
  k = 1
  # a user cache for each restaurant
  score_hash = Hash.new
  while true
    # get page of each resturant with user comment
    # "time to live"
    ttl = 5
    while true
      begin
        page = agent.get(http + value + "&mode=detail&page=" + k.to_s)
        break
      rescue
        puts "-> Alert: Loading failed, trying again"
        ttl += 1
        sleep(ttl)
      end
    end
    # increase counter
    k += 1
    # sleep a while
    sleep(0.01)
    # if nothing just break
    if page.search('div.restcommentNoBorder').to_s == ""
      break
    end
    # grab user comment and rating 
    page.search('div.restcommentNoBorder').each do |comment|
      # grab user information
      user_info = comment.search('div.menpic').search('a')[0].to_s.match(/<a href=\".+\">.+<\/a>/).to_s
      user_link = user_info.match(/href=\".+\"/).to_s.delete("href=").delete("\"")
      user_name = user_info.match(/>.+</).to_s.delete(">").delete("<")
      # if permanant user, store and build edge
      if user_name != ""
        # update user database
        if user_hash[user_link] == nil
          user_hash[user_link] = user_name
          user_file.puts user_link + "\t" + user_name 
        end
        # get rateing
        score = 0
        comment.search('div.recommend').search('b').each do |rate|
          item = rate.to_s.match(/>\d</)
          if item != nil
            score = score + item.to_s.match(/\d/).to_s.to_i
          end
        end
        score = score/5
        if score_hash[user_link] == nil
          score_hash[user_link] = score
          # output edge files
          for n in 1..score+0.5
            edge_file.puts value + ", " + user_link
          end
          # Indicator
          puts "  -> Comment from " + user_name + " with rate " + score.to_s
        end
      end
    end
  end
end





