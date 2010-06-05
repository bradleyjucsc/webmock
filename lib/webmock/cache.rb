module WebMock
  class Cache
    require 'fileutils'

    include Singleton

    REGISTRY_FILE = "./test/mockweb/registered.rb"
    RESPONSE_DIR  = "./test/mockweb/mockweb_responses"

    def initialize
      FileUtils.mkdir_p RESPONSE_DIR rescue Errno::EEXIST
      FileUtils.touch REGISTRY_FILE
    end

    def clean
      FileUtils.rm_rf REGISTRY_FILE
      FileUtils.rm_rf File.join(RESPONSE_DIR, "/*")
    end

    def add(uri, response, options)
      response_file_name  = File.join RESPONSE_DIR, response.hash.to_s

      File.open response_file_name, "wb" do |response_file|
        response_file.write Marshal.dump(response)
      end

      File.open REGISTRY_FILE, "a" do |registry_file|
        registry_file.puts  "WebMock.stub_request(:#{options[:method]}, '#{uri}').
          with(:body => '#{options[:body]}').
          to_return(Marshal.load(File.read('#{response_file_name}')))
          "
      end
    end

    def load_responses
      require REGISTRY_FILE
    end
  end
end