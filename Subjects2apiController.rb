
require 'csv'
require 'json'
require 'typhoeus'
require 'logger'

# global app variables
@status_message = ""

# end global app variables

def assert_response(response)
          if response.success?
            return JSON.parse(response.body)
          elsif response.timed_out?
            @log.error "got a time out"
          elsif response.code == 0
            @log.error response.return_message
          else
            @log.error "HTTP request failed: " + response.code.to_s + response.return_message
            # abort("==================== \n EXIT DUE TO ERROR CODE! \n ====================")
          end
end

class Subjects2apiController < Sinatra::Base
  post "/subjects2api" do
    @log = Logger.new('log.txt')
    @log.debug "Log file created"

    # first we set a few global variables that will be the same for each API call
    tempfile = params['CSV_FILE'][:tempfile]
    @filename = params['CSV_FILE'][:filename]
    File.open("public/files/testdump/WMO/#{@filename}", "r+") do |f|
        #~/../../Volumes/My\ Passport/Gemeente\ Schouwen-Duiveland/WWB/#{@filename}
        #cd ~/../../Volumes/My Passport
      f.write(tempfile.read)
    end

    # filename = params[:CSV_FILE]
    casetype_id = params[:casetype_id]
    API_Interface_ID = params[:API_Interface_ID_Target]
    API_KEY = params[:API_KEY_Target]
    Endpoint_URL2 = params[:Endpoint_URL2]


    # Now we read the CSV
    data = CSV.read("public/files/testdump/WMO/#{@filename}", { encoding: "UTF-8", headers: true, header_converters: :symbol }) # converters: :all

    # all the hash functions are probably a method?
    # turn the CSV into a ruby hash
    hashed_data = data.map { |d| d.to_hash }

    # remove all nilclass values
    hashed_data.each { |e| e.compact! { |_key, value| value == NilClass } }

    # Transforms the individual values, so they're hashes:
    hashed_data.each { |f| f.transform_values! { |value| Array(value) } }

   


    # Now we can define the request body as: casetype_id + requestor + values
    hashed_data.each_with_index do |csvvalues, _index|
    
    # Dossier_Path = csvvalues[:dossier_path][0]

          # dit is een method
          query = Hash.new

          zoek = Hash.new
          zoek[:subject_type] = "person"
          zoek['subject.personal_number'] = csvvalues[:bsnummer][0]

          query[:match] = zoek

          # this prerequest stuff should be a method that works with params, probably?
          pre_request_body = {}
          pre_request_body[:query] = query
          # request_body = pre_request_body.to_json

          # pre_request_body[:values]['ztc_documentkenmerk'] = "#{filecode_array}"
          request_body = pre_request_body.to_json
          # puts request_body

          # this should be a generic method for case creation, where we define the body before we run the method
          responsc = Typhoeus.post(
          "#{Endpoint_URL2}/api/v1/subject/import",
          verbose: true,
          body: request_body,
          headers: { 'Content-Type' => "application/json", "API-key" => "#{API_KEY}", "API-Interface-ID" => "#{API_Interface_ID}" }
          ) 

          # @log.info  "New post: #{responsc.body[instance][number]} #{responsc.body[instance][number_master]} " 
           @log.info csvvalues[:bsnummer][0].to_s 

          response_data = assert_response(responsc)
          #@log.info response_data csvvalues[:bsnummer][0].to_s #["status_code"]

          #this is bullshit but fun
          #{}`say -v Yuna -r 140 Hey 야샤 your program is complete. The result was "#{response_data}"  --interactive`
          puts "==================== \n PROGRAM COMPLETED! \n ===================="
      end


    @status_message = "Tapir says: Program succesfully completed <3 ."
    erb :subjects2api
  end
end
