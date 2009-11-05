class Artwork
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String, :format => :email_address
  property :created_at, DateTime
  property :view_count, Integer
  property :vote_count, Integer

  def url
    "/artwork/#{self.id}"
  end

  def to_json(*a)
    {
      'guid' => self.url,
      'name' => self.name,
      'email' => self.email,
      'created_at' => self.created_at,
      'view_count' => self.view_count,
      'vote_count' => self.vote_count
    }.to_json(*a)
  end

  def self.parse_json(body)
    json = JSON.parse(body)

    {
      :guid => json['guid'],
      :name => json['name'],
      :email => json['email'],
      :created_at => json['created_at'],
      :view_count => json['view_count'],
      :vote_count => json['vote_count']
    }
  end
end
