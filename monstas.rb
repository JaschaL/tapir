require "sinatra/base"
require "erb"

require "./Api2apiController"
require "./Csv2apiController"
require "./Docs2apiController"
require "./Api2csvController"


# global app variables
@status_message = ""
# end global app variables

class App < Sinatra::Base
  use Api2apiController
  use Api2csvController
  use Csv2apiController
  use Docs2apiController

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

  get "/api2csv" do
    erb :api2csv
  end

  get "/docs2api" do
    erb :docs2api
  end

end




