
require 'csv'
require 'json'
# require 'HTTParty'
require 'typhoeus'
require 'logger'

# global app variables
@status_message = ""
# end global app variables




log = Logger.new('log.txt')
log.debug "Log file created"



class Docs2apiController < Sinatra::Base
  post "/docs2api" do
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

    # all the hash functions are probably a method?
    # turn the CSV into a ruby hash
    hashed_data = data.map { |d| d.to_hash }

    # remove all nilclass values
    hashed_data.each { |e| e.compact! { |_key, value| value == NilClass } }

    # Transforms the individual values, so they're hashes:
    hashed_data.each { |f| f.transform_values! { |value| Array(value) } }

   


    # Now we can define the request body as: casetype_id + requestor + values
    hashed_data.each_with_index do |csvvalues, _index|
    
    Dossier_Path = csvvalues[:dossier_path][0]

      # Now we need to prepare_file all the files + save them sexy file id's     
      Dir.chdir "public/files/testdump/#{Dossier_Path}" do
        
        # dit is een method
        filecode_array = Array.new
        Dir.glob("*.pdf") {|filenamer|
            # this should be a generic method for file prep, where we define the body before we run the method
            responsb = Typhoeus.post(
            "#{Endpoint_URL2}/api/v1/case/prepare_file/",
            #method: :post,
            verbose: true,
            body: {
              upload: File.open(filenamer)
            },
            headers: { 'Content-Type' => "multipart/form-data", "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
            ) 

          bla = JSON.parse(responsb.body)
          
          # puts bla['result']['instance']['references'].keys
          filecode_array << bla['result']['instance']['references'].keys[0]
          
          # puts filecode_array

          # dit is een method
          values = Hash.new
          values[:bto_clientnummer] = csvvalues[:clientnummer]
          values[:ztc_brondocument] = filecode_array
          # puts "=====Values:====="
          # puts values
          # puts csvvalues[:clientnummer]
          # puts values[:bto_clientnummer]
          # puts "================="

          # bloop = values[:bto_clientnummer]
          requestor = Hash.new
          requestor[:id] = csvvalues[:clientnummer]
          requestor[:type] = "person"

          puts requestor

          #this prerequest stuff should be a method that works with params, probably?
          pre_request_body = {}
          pre_request_body[:casetype_id] = casetype_id
          pre_request_body[:requestor] = requestor
          pre_request_body[:source] = "behandelaar"
          pre_request_body[:values] = values
          # request_body = pre_request_body.to_json


          # pre_request_body[:values]['ztc_documentkenmerk'] = "#{filecode_array}"
          request_body = pre_request_body.to_json
          # puts request_body

          # this should be a generic method for case creation, where we define the body before we run the method
          responsc = Typhoeus.post(
          "#{Endpoint_URL2}/api/v1/case/create/",
          #method: :post,
          verbose: true,
          body: request_body,
          headers: { 'Content-Type' => "application/json", "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
          ) 


          # bla = JSON.parse(responsc)
          puts "==== RESPONSE HERE: ===="
          # puts bla
          puts responsc.code
          puts responsc.headers
          puts "========================"

          # responsb = HTTParty.post(
          # "#{Endpoint_URL2}/api/v1/case/create/",
          # :body => request_body,
          # :debug_output => $stdout,
          # :headers => { 'Content-Type' => 'application/json', "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
          # )
      }
          

      end
      # @status_message = "Tapir says: #{responsa['status_code']} - #{responsa['result']['instance']['message']}"
      # puts "Tapir says: #{response.code} - #{response.body}"
    end
    erb :docs2api
  end
end
