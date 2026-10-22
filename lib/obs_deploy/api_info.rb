module ObsDeploy
  class ApiInfo
    def self.available?(url: ObsDeploy::DEFAULT_URL, ignore_certificate: false, **)
      if ignore_certificate
        OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
        OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
      end
      response = Net::HTTP.get_response(URI("#{url}/about"))

      response.kind_of? Net::HTTPSuccess
    rescue
      # No matter what error we get here, we assume the service is not available
      false
    end

    def initialize(url: ObsDeploy::DEFAULT_URL, product: ObsDeploy::DEFAULT_PRODUCT, project: ObsDeploy::DEFAULT_PROJECT, package: ObsDeploy::DEFAULT_PACKAGE, source_package: ObsDeploy::DEFAULT_SOURCE_PACKAGE, architecture: ObsDeploy::DEFAULT_ARCHITECTURE, ignore_certificate: false)
      if ignore_certificate
        OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
        OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
      end
      @url = url
      @product = product
      @project = project
      @package = package
      @source_package = source_package
      @architecture = architecture
    end

    def deployed_version
      doc = Nokogiri::XML(Net::HTTP.get(about_url))
      doc.xpath('//commit/text()').to_s
    end

    def available_version
      doc = Nokogiri::XML(Net::HTTP.get(package_url))
      filename = doc.xpath("//binary[starts-with(@filename, '#{@package}')]/@filename").to_s
      filename.match(/#{@package}-.*\..*\..*\.(.*)-.*\.rpm/).captures.first
    end

    private

    def package_url
      URI("#{@url}/public/build/#{@project}/#{@product}/#{@architecture}/#{@source_package}")
    end

    def about_url
      URI("#{@url}/about")
    end
  end
end
