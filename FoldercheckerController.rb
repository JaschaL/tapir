
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
            #abort("==================== \n EXIT DUE TO ERROR CODE! \n ====================")
          end
end

class FoldercheckerController < Sinatra::Base
  post "/folderchecker" do
    @log = Logger.new('log.txt')
    @log.debug "Log file created"

    # first we set a few global variables that will be the same for each API call
    tempfile = params['CSV_FILE'][:tempfile]
    @filename = params['CSV_FILE'][:filename]
    File.open("public/files/testdump/Jeugd/#{@filename}", "r+") do |f|
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
    data = CSV.read("public/files/testdump/Jeugd/#{@filename}", { encoding: "UTF-8", headers: true, header_converters: :symbol }) # converters: :all

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
      # puts "#{Dir.home}"
      Dir.chdir "#{Dir.home}/../../Volumes/My\ Passport/Gemeente\ Schouwen-Duiveland/Jeug\ dossiers/#{Dossier_Path}" do
        # ~/../../Volumes/My\ Passport/Gemeente\ Schouwen-Duiveland/WWB/#{@filename}

      @log.info "Dossier path: #{Dossier_Path}"

        # dit is een method
        filecode_array = Array.new
        
        Dir.glob("*.pdf") {|filenamer|
            @log.info filenamer
            }
      end
    end

    @status_message = "Tapir says: Program succesfully completed <3 ."
    erb :docs2api
  end
end
