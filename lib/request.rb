require 'pry'

class Request
  attr_reader :verb,
              :path,
              :headers,
              :params

  def initialize(request_lines)
    request_line = request_lines.shift
    split_line = request_line.split
    @verb = split_line.first
    @params = {}
    @path = split_line[1]
    query_params = @path.split("?").last
    @path = @path.split("?").first
    parse_body(query_params)
    @headers = {}
    request_lines.each do |header|
      key = header.split(": ").first
      value = header.split(": ").last
      @headers[key] = value
    end
  end

  def parse_body(body)
    key = body.split("=").first
    value = body.split("=").last
    @params[key] = value
  end
end
