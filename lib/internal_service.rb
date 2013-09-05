#encoding: utf-8
#author cway 2013-09-05

class InternalService
  attr_accessor :conn, :response

  def initialize( params = {} )
  	params['url']        =  "http://192.168.1.110:12581" unless params['url']
  	@conn = Faraday.new(:url => params['url'] ) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.adapter  :em_synchrony            # fiber aware http client
    end
    @response           = nil
  end

  def post( url, params = {}, headers = {'Content-Type' => 'application/json'} )
  	headers['Content-Type']            = 'application/json' unless headers['Content-Type']
    @response = @conn.post do |request|
      request.url                        url
      request.headers['Content-Type']  = headers['Content-Type']
      request.body                     = params.to_json
    end  
  end

  def put( url, params = {}, headers = {'Content-Type' => 'application/json'} )
  	headers['Content-Type']            = 'application/json' unless headers['Content-Type']
    @response = @conn.put do |request|
      request.url                        url
      request.headers['Content-Type']  = headers['Content-Type']
      request.body                     = params.to_json
    end
  end

  def get( url, params = {} )
    @response = @conn.get do |request|
      request.url                        url
      request.params                   = params
    end 
  end

  def delete( url, params = {} )
    @response = @conn.delete do |request|
      request.url                        url
      request.params                   = params
    end 
  end

end