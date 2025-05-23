require 'net/http'
require 'uri'
require 'json'
require 'httparty'
require 'zlib'
require 'stringio'

GET_RECORDS = 'GET'
CREATE_RECORD = 'POST'

class SupabaseClient
  def self.users
    response = supabase_response(GET_RECORDS, 'users')
    JSON.parse(response)
  end

  def self.create_user(user)
    response = supabase_response(CREATE_RECORD, 'users', user)

    if response.code == '201'
      "User created successfully"
    else
      "Error creating user: #{response.body}"
    end
  end

  private

  def self.supabase_response(operation, table, record = nil)
    url = URI("https://dgzxmivshyxkmridhggl.supabase.co/rest/v1/#{table}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    case operation
    when GET_RECORDS
      response = HTTParty.get("https://dgzxmivshyxkmridhggl.supabase.co/rest/v1/users", {
        headers: {
          "apikey" => ENV['SUPABASE_TOKEN'],
          "Accept" => "application/json"
        }
      })

      if response.headers["content-encoding"] == "gzip"
        # Decompress it manually
        decompressed_body = Zlib::GzipReader.new(StringIO.new(response.body)).read
      else
        decompressed_body = response.body
      end

      decompressed_body
    when CREATE_RECORD
      request = Net::HTTP::Post.new(url)
      request["apikey"] = ENV['SUPABASE_TOKEN']
      request["Content-Type"] = "application/json"
      request.body = record.to_json
      http.request(request)
    end
  end
end
