from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
import dbx
from django.utils import simplejson as json

# Model
class Artwork(db.Model):
    name = db.StringProperty()
    email = db.EmailProperty()
    created_at = db.DateTimeProperty(auto_now_add=True)
    updated_at = db.DateTimeProperty(auto_now=True)
    view_count = db.IntegerProperty(default=0)
    vote_count = db.IntegerProperty(default=0)
    image = db.BlobProperty()

    @dbx.DerivedProperty
    def url(self):
        if self.is_saved():
            return "/artwork/%d" % (self.key().id_or_name())

    @dbx.DerivedProperty
    def image_url(self):
        if self.is_saved():
            return "/artwork/%d/png" % (self.key().id_or_name())

    def to_dict(self):
        ll = []
        for p in self.properties():
            if p != "image":
                ll.append((p, unicode(getattr(self, p))))
        return dict(ll)
        #return dict([(p, unicode(getattr(self, p))) for p in self.properties()])

# Action
class ArtworksAction(webapp.RequestHandler):
    # Return list of all installed artworks.
    # Just get all artworks and return as JSON.
    def get(self):
        artworks = Artwork.all()

        jj = json.dumps({
            'status': 200,
            'content': [a.to_dict() for a in artworks],
            })

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

    # Create a new artwork. Request body to contain json
    def post(self):
        artwork = Artwork()
        artwork.name = self.request.get("name")
        artwork.email = self.request.get("email")
        artwork.image = db.Blob(self.request.get("img"))
        artwork.put()

        jj = json.dumps({
            'status': 200,
            'content': [artwork.to_dict()],
            })

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

class ArtworkAction(webapp.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('Artwork!')

class ViewAction(webapp.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('View!')

# Boilerplate
def main():
    actions = [
        ('/artwork/.*/png', ViewAction),
        ('/artwork/.*', ArtworkAction),
        ('/artworks', ArtworksAction),
        ]
    application = webapp.WSGIApplication(actions, debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
