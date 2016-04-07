require 'net/http'
require 'json'
require 'middleman-gh-pages'

def prepare(api_url, swagger_endpoint, markdown_dir)
  templates = {}

  endpoints_json = swagger_json(api_url, swagger_endpoint)
  endpoints = available_endpoints(endpoints_json)

  endpoints.each do |endpoint|
    model_endpoint_json = swagger_json(api_url, swagger_endpoint, endpoint)

    operations = available_operations(model_endpoint_json)
    operations_templates = generate_operations_templates(operations)
    templates.merge!(operations_templates)

    models = available_models(model_endpoint_json)
    models_templates = generate_models_templates(models)
    templates.merge!(models_templates)
  end

  markdown_files = find_markdown_files(markdown_dir)

  document_transclusion(templates, markdown_files)
end

def swagger_json(api_url, *endpoints)
  normalized_endpoint = endpoints.join('/').gsub(/\/+/, '/')
  content = Net::HTTP.get(api_url, normalized_endpoint)
  JSON.parse(content)
end

def available_endpoints(json)
  json['apis'].map { |api| api['path'] }
end

def available_operations(json)
  json['apis'].map do |api|
    api['operations'].map do |operation|
      operation['path'] = api['path']
      operation
    end
  end.flatten()
end

def available_models(json)
  json['models']
end

def generate_operations_templates(operations)
  templates = {}

  operations.each do |operation|
    extracted_operation = extract_operation_info(operation)
    template = generate_template(extracted_operation)
    templates["operation:#{operation['nickname']}"] = template
  end

  templates
end

def extract_operation_info(operation)
  {
    path: operation['path'],
    method: operation['method'],
    produces: operation['produces'],
    parameters: operation['parameters'],
    responseMessages: operation['responseMessages']
  }
end

def generate_models_templates(models)
  templates = {}

  models.each do |key, model|
    template = generate_template(model)
    templates["model:#{key}"] = template
  end

  templates
end

def generate_template(json)
  pretty_json = JSON.pretty_generate(json)
  <<-EOS
```json
#{pretty_json}
```
EOS
end

def find_markdown_files(root)
  Dir.entries(root).select do |entry|
    entry =~ /^.*\.md$/
  end.map do |entry|
    "#{root}/#{entry}"
  end
end

def document_transclusion(templates, markdown_files)
  markdown_files.each do |filename|
    index = File.read(filename)

    templates.each do |key, value|
      index.gsub!("[[#{key}]]", value)
    end

    File.open(filename, "w") do |file|
      file.write(index)
    end
  end
end

task :prepare do
  api_url = ENV.fetch('API_URL', 'agco-fuse-trackers-dev.herokuapp.com')
  swagger_endpoint = ENV.fetch('SWAGGER_ENDPOINT', '/api-docs/')
  markdown_dir = ENV.fetch('MARDKDOWN_DIR', 'source')

  prepare(api_url, swagger_endpoint, markdown_dir)
end

task :deploy do
  ENV['ALLOW_DIRTY'] = 'true'
  ENV['BRANCH_NAME'] = 'master'
  Rake::Task['build'].execute
  Rake::Task['publish'].execute
end
  
