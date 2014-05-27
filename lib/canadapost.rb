# CanadaPost gem for use with Canada Post REST API 
class Canadapost
	attr_accessor :username, 
		:password, 
		:development, 
		:auth, 
		:customer_number, 
		:response,
		:content_type_header,
		:accept_header,
		
		# Get Rates
		:dimensions, 
		:customer, 
		:origin_postal_code

  # @param [Hash] params
  # @option params [String] :username your API key username
  # @option params [String] :password your API key password
  # @option params [Boolean] :development to specify development mode
  # @option params [String] :customer_number your Canada Post customer account number
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


	#
	# Get Rates
	#

	# Get Rates from Canada POST REST API
 	# @param [Hash] options 
  # @option options [String] :original_postal_code the postal code the parcel is being sent from
  # @option options [Hash] :customer a hash of customer details either { :'united-states' => { :'zip-code' => '' } };  { domestic: { :'postal-code' => '' } }; or { international: { :'country-code' => '' } }
	# @option options [Hash] :dimensions a hash of parcel dimensions, containing height, width and length in CM and weight in KG
	# @return Hash a hash of services
	#
	def get_rates(params = {})
 		self.origin_postal_code = params[:origin_postal_code].gsub(/\s+/, "") if params[:origin_postal_code].present?
	 	self.customer = params[:customer] if params[:customer].present?
	 	self.dimensions = params[:dimensions] if params[:dimensions].present?

	 	self.content_type_header = self.accept_header = 'application/vnd.cpc.ship.rate-v2+xml'

		begin
			do_request(get_rates_xml, get_rates_url)
			services = results[:price_quotes][:price_quote]
			services = services.map(&:deep_symbolize_keys!)
			return services
		rescue => e
			Rails.logger.info "Canada Post Gem Error get_rates: #{e}"
		end
		return services
	end

	#
	# @return String
	#
	def get_rates_url
		"#{base_url}/rs/ship/price"
	end
	private :get_rates_url

	#
	# @return String
	#
	def get_rates_xml
		Nokogiri::XML::Builder.new { |xml| 
			xml.send(:"mailing-scenario", xmlns: "http://www.canadapost.ca/ws/ship/rate-v2") {
				xml.send(:"customer-number", customer_number)
				xml.send(:"origin-postal-code", origin_postal_code)
				xml.send(:"parcel-characteristics") {
					xml.weight dimensions[:weight]
					xml.dimensions {
						xml.height dimensions[:height].round(1)
						xml.width dimensions[:width].round(1)
						xml.length dimensions[:length].round(1)
					}
				}
				xml.destination {
					customer.each_pair do |key, value|
						xml.send(key) {
						 value.each_pair { |key,value| 
						 	xml.send(key, value) 
						 	}
						} 
					end
				}
			}
		}.to_xml
	end	
	private :get_rates_xml
	
end
