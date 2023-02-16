#!/usr/bin/env ruby

require 'json'
require 'rest-client'
require 'optparse'
require 'pathname'

OWNER = ENV["USER"]
FORCE_PRIVATE = ENV["PRIVATE_WORK"]
SIGNATURE_FILE = (Pathname.new ENV["HOME"]) + ".sasami_key"
DESTINATION = "http://127.0.0.1:3000/works"

options = {
  pictures: [],
  is_private: FORCE_PRIVATE || false,
  name: nil,
  path: nil,
  stage: nil,
  project: nil,
  design: nil,
  data: nil,
  signature: SIGNATURE_FILE
}
payload = {
  owner: OWNER
}
OptionParser.new do |args|
  args.banner = "Usage: #{__FILE__} [options]"

  {
    name:       "Specify work name",
    path:       "Specify work path",
    stage:      "Specify work stage",
    project:    "Specify project",
    design:     "Specify design",
    upstream:   "ID of upstream work",
    data:       "JSON file of work data"
  }.each do |opt, des|
    args.on(
      :REQUIRED,
      "--#{opt} #{opt.to_s.upcase}",
      des
    ) do |n|
      options[opt] = n
    end
  end

  args.on(
    "--[no-]private",
    "Upload as a private work"
  ) do |n|
    options[:is_private] = FORCE_PRIVATE || n
  end

  args.on(
    "--picture PICTURE", "Image files to upload"
  ) do |n|
    options[:pictures] << n
  end
end.parse!

# check arg
if options.value? nil
  raise "Required options unspecified: \n#{options.select { |k, v| v.nil? }.keys.join ("\n")}"
end

# check data
raise "Specified data JSON #{options[:data]} not readable" unless File.readable? options[:data]

begin
  JSON.load_file options[:data]
rescue
  raise "File #{options[:data]} specified by '--data' is not a valid JSON"
else
  payload[:data] = File.open(options.delete :data)
end

# check signature
if options[:signature].exist?
  raise "Signature file #{options[:signature]} existed but not readable" unless options[:signature].readable?
else
  # gen signature
  begin
    options[:signature].write (Time.now.to_i.to_s + Random.rand.to_s.split(".").last[0..15])
    options[:signature].chmod 0400
    puts "Info: Signature file #{options[:signature]} generated"
  rescue
    raise "Failed to generate signature file at #{options[:signature]}"
  end
end
payload[:signature] = options.delete(:signature).open

# path
payload[:path] = File.realpath(options.delete :path)

# pictures
pictures = options.delete :pictures
unless pictures.empty?
  payload[:pictures] = [nil] + pictures.map do |picture_file|
    picture = Pathname.new picture_file
    raise "Unreadable picture file #{picture_file}" unless picture.readable?
    picture.open
  end
end

# common
payload.merge! options

# test
puts "Uploading to #{DESTINATION}:"
payload.each do |k, v|
  if v.is_a? Array
    puts "  #{k}:"
    v.each do |n|
      puts "      #{n.inspect}"
    end
  else
    puts "  #{k}: #{v.inspect}"
  end
end
puts ""

# upload
begin
  respon = RestClient.post DESTINATION, {work: payload}, {accept: :json}
rescue RestClient::ExceptionWithResponse => e
  puts "RespCode: #{e.response.code}"
  puts "ServerError: #{e.response.body[0..49]}..."
else
  result = JSON.parse(respon.body)
  puts "RespCode: #{respon.code}"
  puts "Status: #{result["status"]}"
  puts "Message: #{result["message"]}"
end
