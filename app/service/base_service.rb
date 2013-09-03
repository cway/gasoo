#encoding: utf-8
#author cway 2013-07-09

class BaseService
  attr_accessor :conn

  def initialize( params  = {} )
  	params['url']                      =  "http://api.easycook.cn" unless params['url']
  	@conn                              =  Faraday.new(:url => params['url'] ) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      # faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.adapter  :em_synchrony            # fiber aware http client
    end
  end

  def post( url, params  = {}, headers =  {'Content-Type' => 'application/json'} )
  	headers['Content-Type']            = 'application/json' unless headers['Content-Type']
    response                           = @conn.post do |request|
									       request.url                        url
									       request.headers['Content-Type']  = headers['Content-Type']
									       request.body                     = params.to_json
									     end
    response
  end

  def get( url )
    response = @conn.get do |request|
			     request.url     url
		       end
	response
  end
end