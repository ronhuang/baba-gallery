require 'rubygems'
require 'sinatra'
require 'environment'

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
  opts = Artwork.parse_json(request.body.read) rescue nil
  halt(401, 'Invalid Format') if opts.nil?

  artwork = Artwork.new(opts)
  halt(500, 'Could not save artwork') unless artwork.save

  response['Location'] = artwork.url
  response.status = 201
end

# Get an individual artwork
get "/artworks/:id" do
  artwork = Artwork.get(params[:id]) rescue nil
  halt(404, 'Not Found') if artwork.nil?

  content_type 'application/json'
  { 'content' => artwork }.to_json
end

# Update an individual artwork
put "/artworks/:id" do
  artwork = Artwork.get(params[:id]) rescue nil
  halt(404, 'Not Found') if artwork.nil?

  opts = Artwork.parse_json(request.body.read) rescue nil
  halt(401, 'Invalid Format') if opts.nil?

  artwork.name = opts[:name]
  artwork.email = opts[:email]
  artwork.created_at = opts[:created_at]
  artwork.view_count = opts[:view_count]
  artwork.vote_count = opts[:vote_count]
  artwork.save

  response['Content-Type'] = 'application/json'
  { 'content' => artwork }.to_json
end

# Delete an invidual artwork
delete '/artworks/:id' do
  artwork = Artwork.get(params[:id]) rescue nil
  artwork.destroy unless artwork.nil?
end
