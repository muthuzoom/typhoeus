require 'dalli'
require 'typhoeus/dalli_cache'
require 'spec_helper'

describe Typhoeus::DalliCache do
  let(:dalli) { instance_double(Dalli::Client) }
  let(:cache) { Typhoeus::DalliCache.new(dalli) }

  let(:base_url) { "localhost:3001" }
  let(:request) { Typhoeus::Request.new(base_url, {:method => :get}) }
  let(:response) { Typhoeus::Response.new(:response_code => 0, :return_code => 0, :mock => true) }

  describe "#set" do
    it "sends the request to Dalli" do
      expect(dalli).to receive(:set).with(request.cache_key, response, nil)

      cache.set(request, response)
    end
  end

  describe "#get" do
    it "returns nil when the key is not in the cache" do
      expect(dalli).to receive(:get).with(request.cache_key).and_return(nil)

      expect(cache.get(request)).to be_nil
    end

    it "returns the cached response when the key is in cache" do
      expect(dalli).to receive(:get).with(request.cache_key).and_return(response)

      result = cache.get(request)
      expect(result).to_not be_nil
      expect(result.response_code).to eq(response.response_code)
      expect(result.return_code).to eq(response.return_code)
      expect(result.headers).to eq(response.headers)
      expect(result.body).to eq(response.body)
    end
  end
end
