require "sinatra/base"
require "erb"

require "./Api2apiController"
require "./Csv2apiController"



# global app variables
@status_message = ""
# end global app variables

class App < Sinatra::Base
  use Api2apiController
  use Csv2apiController

  get "/" do
    erb :index
  end

  get "/manual" do
    erb :manual
  end

  get "/monstas" do
    erb :monstas
  end

    get "/csv2api" do
    erb :csv2api
  end

  get "/monstas/post" do
    @name = params["name"]
    erb :monstas_post
  end

end




