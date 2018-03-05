
require 'csv'
require 'json'
# require 'HTTParty'
require 'typhoeus'

# global app variables
@status_message = ""
# end global app variables

class Docs2apiController < Sinatra::Base
  post "/docs2api" do
    puts Dir.pwd 
    tempfile = params['CSV_FILE'][:tempfile]
    @filename = params['CSV_FILE'][:filename]

    File.open("public/files/testdump/#{@filename}", "r+") do |f|
      f.write(tempfile.read)
    end

    # first we set a few global variables that will be the same for each API call
    # filename = params[:CSV_FILE]
    casetype_id = params[:casetype_id]
    API_Interface_ID = params[:API_Interface_ID_Target]
    API_KEY = params[:API_KEY_Target]
    Endpoint_URL2 = params[:Endpoint_URL2]

    # Now we read the CSV
    data = CSV.read("public/files/testdump/#{@filename}", { encoding: "UTF-8", headers: true, header_converters: :symbol }) # converters: :all

    # turn the CSV into a ruby hash
    hashed_data = data.map { |d| d.to_hash }

    # remove all nilclass values
    hashed_data.each { |e| e.compact! { |_key, value| value == NilClass } }

    # Transforms the individual values, so they're hashes:
    hashed_data.each { |f| f.transform_values! { |value| Array(value) } }
    
    puts hashed_data


    # Now we can define the request body as: casetype_id + requestor + values
    hashed_data.each_with_index do |valuesss, _index|
      pre_request_body = {}
      pre_request_body[:casetype_id] = casetype_id
      pre_request_body[:requestor] = valuesss[:clientnummer]
      pre_request_body[:source] = "behandelaar"
      pre_request_body[:values] = valuesss[:dossier_path]  # Figure out how to add filelocation here

      request_body = pre_request_body.to_json

      # Create cases
      # responsa = HTTParty.post(
      #   "#{Endpoint_URL2}/api/v1/case/create/",
      #   :body => request_body,
      #   :debug_output => $stdout,
      #   :headers => { 'Content-Type' => 'application/json', "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
      #   )

      # print "Here is your response: #{responsa['status_code']}"
      # print responsa['status_code']
      # print responsa['result']['instance']['message']
      # print "____End response___"
      
      # Now we need to prepare_file all the files + save them sexy file id's
      puts "_____Dossier path goes here:_____"      
      puts valuesss[:dossier_path][0]

      Dossier_Path = valuesss[:dossier_path][0]
      puts "_____Current path is:_____"  
      puts Dir.pwd
      
      puts "_____Change dir_____"       
      Dir.chdir "public/files/testdump/#{Dossier_Path}" do
        puts "_____Files in dir are:_____"  
        Dir.glob("*.pdf") {|filenamer|
          puts filenamer

          puts "Posting to api...."
          responsb = Typhoeus.post(
          "#{Endpoint_URL2}/api/v1/case/prepare_file/",
          #method: :post,
          verbose: true,
          body: {
            upload: File.open(filenamer)
            },
          headers: { 'Content-Type' => "multipart/form-data", "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
          ) 

          # p responsb.code
          # p responsb.headers
          # p responsb.body
          bla = JSON.parse(responsb.body)
          filecode_array = Array.new
          puts bla['result']['instance']['references'].keys
          filecode_array << bla['result']['instance']['references'].keys
          
          puts "00000000000000000000000000000000000000000000000"
          puts "__________ Puts the Filecode Array: ___________"
          puts filecode_array
          puts "00000000000000000000000000000000000000000000000"
       }

      # responsb = HTTParty.post(
      #   "#{Endpoint_URL2}/api/v1/case/create/",
      #   :body => request_body,
      #   :debug_output => $stdout,
      #   :headers => { 'Content-Type' => 'application/json', "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
      #   )

      # Now we need to update the case with all the id's 

      end
      # @status_message = "Tapir says: #{responsa['status_code']} - #{responsa['result']['instance']['message']}"
      # puts "Tapir says: #{response.code} - #{response.body}"
    end
    erb :docs2api
  end
end
