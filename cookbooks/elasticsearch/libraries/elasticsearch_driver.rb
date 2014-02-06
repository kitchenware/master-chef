require 'net/http'

class ElasticsearchDriver

	def initialize host, port
		@http = Net::HTTP.new(host, port)
	end

	def wait_ready
		counter = 0
		while true do
      begin
        code, body = get '/'
        raise 'Wrong return code' unless code == 200
        break
      rescue
      	counter += 1
        raise "Too many try while waiting for Elasticsearch" if counter > 30
        sleep 2
      end
    end
	end

	def put path, json
		req = Net::HTTP::Put.new(path, {'Content-Type' => 'application/json'})
    req.body = JSON.dump(json)
    @http.start {|http| http.request(req)}.code.to_i
	end

	def get path
		resp = @http.start {|http| http.request(Net::HTTP::Get.new(path))}
		body = nil
		body = JSON.parse(resp.body) if resp['content-type'] == 'application/json'
		return resp.code.to_i, body
	end

end