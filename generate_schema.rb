require 'net/http'
require 'json'

models = JSON.parse(Net::HTTP.get("agco-fuse-trackers-dev.herokuapp.com", "/api-docs/"))
definitions = {}

models["apis"].each do |model|
  endpoint = "/api-docs" + model["path"]
  model_definition = JSON.parse(Net::HTTP.get("agco-fuse-trackers-dev.herokuapp.com", endpoint))

  model_definition["apis"].each do |api|
    api["operations"].each do |operation|
      model = api["path"]
      method = operation["method"]
      key = "#{model}#{method}".gsub(/[^a-zA-Z0-9]/, '')
      puts key

      definitions[key] = <<-EOS
```js
{
    "method": #{operation["method"]},
    "produces": #{operation["produces"]},
    "parameters": #{operation["parameters"]},
    "responses": #{operation["responseMessages"]}
}
```
EOS
    end
  end
end
  
index = File.read("./index.html.md")
  
definitions.each do |key, value|
  definition = definitions[key]
  index.gsub!("[[#{key}]]", definition)
end

File.open("./index.html.md", "w") do |file|
  file.write(index)
end

#content = Net::HTTP.get("agco-fuse-trackers-dev.herokuapp.com", "/api-docs/brands")
#parsed_json = JSON.parse content
#
#filenames = []
#
#parsed_json["apis"].each do |api|
#  api["operations"].each do |operation|
#    filename = "#{api['path']}#{operation['method']}"
#    filename = "_#{filename.gsub(/[^a-zA-Z0-9]/, '')}.md"
#    filenames << filename
#    File.open(filename, 'w') do |file|
#      file.puts "```js"
#      file.puts "{"
#      file.puts "  'method': #{operation['method']},"
#      file.puts "  'produces': #{operation['produces']},"
#      file.puts "  'parameters': #{operation['parameters']},"
#      file.puts "  'responses': #{operation['responseMessages']}"
#      file.puts "}"
#      file.puts "```"
#    end
#  end
#end
#
#index = File.read("./index.html.md")
#
#filenames.each do |filename|
#  brands_get = File.read(filename)
#  index.gsub!("[[#{filename}]]", brands_get)
#end
#
#File.open("./index.html.md", "w") do |file|
#  file.write(index)
#end
