
require 'csv'
require 'json'
require 'HTTParty'

# global app variables
@status_message = ""
@casetype_list = {}
# end global app variables


class Api2csvController < Sinatra::Base

  post "/api2csv" do

    # first we set a few global variables that will be the same for each API call
    API_Interface_ID_SRC = params[:API_Interface_ID_SRC] 
    API_KEY_SRC = params[:API_KEY_SRC]
    casetype_id = params[:casetype_id]
    requestor_id = params[:requestor_id]
    Endpoint_URL1 = params[:Endpoint_URL]


    # Then we make a requestor hash that gets filed with the requestor ID + requestor type, so we can put a requestor-hash inside the body-hash
    requestor = {}
    requestor[:id] = "#{requestor_id}"
    requestor[:type] = "person"


    # erb :monstas
    # Thenwe can send a message with a get command to get a list of all cases:
    # We do the magic '?rows_per_page=n' URL-query to make sure we get all the rows we need
    response = HTTParty.get("#{Endpoint_URL1}/api/v1/casetype",
             
               #:body => valuesss ,  #fingers crossed that the json is correctly nested and whatnot 
               #:basic_auth => { :username => api_key },
               #:debug_output => $stdout ,
               :headers => { 'Content-Type' => 'application/json', "API-key" => "#{API_KEY_SRC}", "API-Interface-ID" => "#{API_Interface_ID_SRC}"}
              )

    # Here we parse the json response and add it to a variable named bla
    bla = JSON.parse(response.body)

    #now we store the actual content (which is an array named 'rows') inside its own variable, which we also name rows - how convenient:
    rows = bla['result']['instance']['rows']

    # puts rows
    # Whelp! Must go deeper! We need to get value of 'instance' inside the array, then get the value of 'attributes' inside of 'instance'!
    # This is crazy and we need to find a better way of doing this, but for now it works so whatevs
    instance = rows.map { |hash| hash['instance'] }
    titles = instance.map { |hash| hash['title'] }
    ids = instance.map { |hash| hash['id']  }

    # puts ids
    # puts titles
    # puts ids.class

    @casetype_list = Hash[titles.map(&:to_sym).zip(ids)]
    puts @casetype_list

    # puts titles , titles.class
    # We would like to remove all nilclass values --- nut that doesn't work because the nils are in arrays TT___TT
    # valuesss.each {|e| e.compact! { |key, value| value == NilClass } }

    # Let's bring all the seperate elements together, and JSON-ify what we intend to send:
    # valuesss.each_with_index do |valuesss , index|
    #   pre_request_body = {}
    #   pre_request_body[:casetype_id] = casetype_id
    #   pre_request_body[:requestor] = requestor
    #   pre_request_body[:source] = "behandelaar"
    #   pre_request_body[:values] = valuesss

    #   request_body = pre_request_body.to_json


    @status_message = "Tapir says: #{response.code}"
      erb :api2csv

  end
end