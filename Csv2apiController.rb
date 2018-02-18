
require 'csv'
require 'json'
require 'HTTParty'

# global app variables
@status_message = ""
# end global app variables

class Csv2apiController < Sinatra::Base
  post "/csv2api" do

    tempfile = params['CSV_FILE'][:tempfile]
    @filename = params['CSV_FILE'][:filename]

    File.open("public/files/#{@filename}", "r+") do |f|
      f.write(tempfile.read)
    end

    # first we set a few global variables that will be the same for each API call
    # filename = params[:CSV_FILE]
    casetype_id = params[:casetype_id]
    API_Interface_ID = params[:API_Interface_ID_Target]
    API_KEY = params[:API_KEY_Target]
    requestor_id = params[:requestor_id]
    Endpoint_URL2 = params[:Endpoint_URL2]

    # Then we make a requestor hash that gets filed with the requestor ID + requestor type, so we can put a requestor-hash inside the body-hash
    requestor = {}
    requestor[:id] = "#{requestor_id}"
    requestor[:type] = "person"

    # Now we read the CSV
    data = CSV.read("public/files/#{@filename}", { encoding: "UTF-8", headers: true, header_converters: :symbol }) # converters: :all

    # turn the CSV into a ruby hash
    hashed_data = data.map { |d| d.to_hash }

    # remove all nilclass values
    hashed_data.each { |e| e.compact! { |_key, value| value == NilClass } }

    # Transforms the individual values, so they're hashes:
    hashed_data.each { |f| f.transform_values! { |value| Array(value) } }

    # Now we can define the request body as: casetype_id + requestor + values
    hashed_data.each_with_index do |valuesss, _index|
      pre_request_body = {}
      pre_request_body[:casetype_id] = casetype_id
      pre_request_body[:requestor] = requestor
      pre_request_body[:source] = "behandelaar"
      pre_request_body[:values] = valuesss

        # headers = {
        # "API-key"=> "#{API_KEY}"
        #  "API-Interface-ID" => "#{API_Interface_ID}"
        # }

      request_body = pre_request_body.to_json
        # puts data
        # puts hashed_data
        # puts request_body

      # Finally we can post this to the API
      responsa = HTTParty.post(
        "#{Endpoint_URL2}/api/v1/case/create/",
        :body => request_body,
        :debug_output => $stdout,
        :headers => { 'Content-Type' => 'application/json', "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
        )

      print "Here is your response: #{responsa['status_code']}"
      print responsa['status_code']
      print responsa['result']['instance']['message']
      print "____End response___"
      
      @status_message = "Tapir says: #{responsa['status_code']} - #{responsa['result']['instance']['message']}"
      # puts "Tapir says: #{response.code} - #{response.body}"
    end
    erb :csv2api
  end
end
