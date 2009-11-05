class Artwork
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :nullable => true
  property :email, String, :nullable => true, :format => :email_address
  property :created_at, DateTime
  property :updated_at, DateTime
  property :view_count, Integer, :default => 0
  property :vote_count, Integer, :default => 0

  def url
    "/artwork/#{self.id}"
  end

  def image_url
    "/a/#{self.id}.png"
  end

  def to_json(*a)
    {
      'guid' => self.url,
      'name' => self.name,
      'email' => self.email,
      'created_at' => self.created_at,
      'updated_at' => self.updated_at,
      'view_count' => self.view_count,
      'vote_count' => self.vote_count,
      'image_url' => self.image_url
    }.to_json(*a)
  end

  def parse_json(body)
    json = JSON.parse(body)

    {
      :vote_count => json['vote_count']
    }
  end
end
