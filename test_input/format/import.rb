%w(project design owner work).each do |type|
  fmt = Format.find_by(name: type)
  if fmt.nil?
    fmt = Format.new(name: type)
  end
  fmt.format = File.read("test_input/format/#{type}.json")
  fmt.save
end
