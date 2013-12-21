module CanadaPost
	class Rating < Base
		attr_accessor :dimensions, :customer, :origin_postal_code

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
				hash = results[:price_quotes][:price_quote].deep_symbolize_keys!
				return hash
			rescue => e
				Rails.logger.info "ERROR :#{e}"
			end
			return hash
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
end