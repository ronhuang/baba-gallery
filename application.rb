require 'rubygems'
require 'sinatra'
require 'environment'
require 'json'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

# Return list of all installed artworks.
# Just get all artworks and return as JSON.
get '/artworks' do
  content_type 'application/json'
  { 'content' => Array(Artwork.all) }.to_json
end

# Create a new artwork. Request body to contain json
post '/artworks' do
  opts = {
    :name => params[:name] || "",
    :email => params[:email] || ""
  }

  # Save to database
  artwork = Artwork.new(opts)
  halt(500, 'Could not save artwork') unless artwork.save

  # Save uploaded file
  filename = "#{File.dirname(__FILE__)}/public/a/#{artwork.id}.png"
  File.open(filename, "wb") { |f| f.write(params[:artwork][:tempfile].read) }

  response['Location'] = artwork.url
  response.status = 201
end

# Get an individual artwork
get "/artwork/:id" do
  artwork = Artwork.get(params[:id]) rescue nil
  halt(404, 'Not Found') if artwork.nil?

  content_type 'application/json'
  { 'content' => artwork }.to_json
end

# Update an individual artwork
put "/artwork/:id" do
  artwork = Artwork.get(params[:id]) rescue nil
  halt(404, 'Not Found') if artwork.nil?

  artwork.vote_count += 1
  artwork.save

  response['Content-Type'] = 'application/json'
  { 'content' => artwork }.to_json
end

# Delete an invidual artwork
delete '/artwork/:id' do
  artwork = Artwork.get(params[:id]) rescue nil
  artwork.destroy unless artwork.nil?
end
