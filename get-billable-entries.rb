# Hey there!
#
# This is a basic script that shows how to get all the billable entries you can
# view in your Noko account using API v2. It parses the JSON response and
# stores it as an array of hashes.
#
# This script also shows you how to parse the Pagination header so that you can
# get the next page of results without having to write a new query URL
#
# You can learn about querying for entries here:
# http://developer.nokotime.com/v2/entries/#list-entries
#
# You can learn more about API v2 here:
# http://developer.nokotime.com/v2/
#
# The API key provided is for our API test account, to run the command with your
# own account you will have to create a personal access token and replace the
# test account token.
#
# Cheers,
# Your Noko Team
require 'net/http'
require 'json'
require 'pp' # to make the printed results look nicer

def parse_pagination_header(header)
  pagination_header = header.to_s.strip
  pages = {}
  unless pagination_header.empty?
    pagination_links = pagination_header.split(",").map do |link|
      link_parts = link.split(";")
      # the actual URL of the pagination link
      page_url = link_parts[0]
      # where the Page URL will point to: first, last, next, prev, etc.
      page_destination = link_parts[1].gsub("rel=",'').gsub('"','').strip
      pages[page_destination] = page_url
    end
  end
  return pages
end


# This Personal Access Token is for our API test account. To run the script on your own
# account, replace this token with a personal access token you have created from the
# "API v2" tab in your settings
PERSONAL_ACCESS_TOKEN = "scbp72wdc528hm8n52fowkma321tn58-jc1l2dkil0pnb75xjni48ad2wwsgr1d"

uri = URI('https://api.nokotime.com/v2/entries')

# add a query parameter to only return billable entries
uri.query = "billable=true"

# Create the Net::HTTP Client
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

# Create the request.
request =  Net::HTTP::Get.new(uri)

# Add your Personal Access Token to the Header of the request,
# which authenticates you to access the Noko API
request.add_field "X-NokoToken", PERSONAL_ACCESS_TOKEN

# Make the request and Parse the Response:
response = http.request(request)
entries = JSON.parse(response.body)

# Check if there was an error with the API call
if response.code == "200"
  # parse the pagination header from the response
  pages = parse_pagination_header(response["Link"])

  puts "Pagination Links:"
  pp pages

  puts "-"*50
  puts "Entries:"

  pp entries
else
  puts "API returned Error: #{response.code}"
  pp entries
end