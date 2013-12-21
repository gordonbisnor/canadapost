# CanadaPost gem for use with Canada Post REST API 
module CanadaPost
	
	class Base

		attr_accessor :username, 
			:password, 
			:development, 
			:auth, 
			:customer_number, 
			:response,
			:content_type_header,
			:accept_header

	  # @param [Hash] options 
	  # @option options [String] :username your API key username
	  # @option options [String] :password your API key password
	  # @option options [Boolean] :development to specify development mode
	  # @option options [String] :customer_number your Canada Post customer account number
		def initialize(params = {})
			@username = params[:username]
		 	@password = params[:password]
		 	@development = params[:development]
		 	@customer_number = params[:customer_number]
		 	@auth = { username: username, password: password }
		end
			
		# @return [Hash] Hash with symbolized keys
		def results
			resp = if response.parsed_response.is_a? String
				Hash.from_xml(response.parsed_response.gsub("\n", ""))
			else
				response.parsed_response
			end
			hash = resp.deep_symbolize_keys!
		end
		private :results

		# @param xml [String] A string containing the XML data
		# @param url [String] The Canadda POST API endpoint
		def do_request(xml, url)
			self.response = HTTParty.post(url, 
				body: xml, 
				basic_auth: auth,
				headers: {
					'Content-type' => content_type_header,
					'Accept' => accept_header
					 }
				)
		end	
		private :do_request
		
		# @return String
		def base_url
			if development
				"https://ct.soa-gw.canadapost.ca"
			else
				"https://soa-gw.canadapost.ca"
			end	
		end
		private :base_url

	end
	
end