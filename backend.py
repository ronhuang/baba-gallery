from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
import dbx
from django.utils import simplejson as json
import re

# Utility
def increment_counter(key, amount):
    obj = db.get(key)
    obj.counter += amount
    obj.put()

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
            return "/artwork/%d/image" % (self.key().id_or_name())

    def to_dict(self):
        ll = []
        for p in self.properties():
            if p != "image":
                ll.append((p, unicode(getattr(self, p))))
        return dict(ll)

# Action
class ArtworksAction(webapp.RequestHandler):
    def get(self):
        """
        Return list of all installed artworks.
        Just get all artworks and return as JSON.
        """
        artworks = Artwork.all()

        jj = json.dumps({
            'status': 200,
            'count': artworks.count(),
            'content': [a.to_dict() for a in artworks],
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

    def post(self):
        """
        Create a new artwork. Request body to contain json.
        """

        # Image must exist.
        img = self.request.get("img")
        if img == "":
            self.error(400)
            return

        artwork = Artwork()
        artwork.name = self.request.get("name")
        artwork.email = self.request.get("email")
        artwork.image = db.Blob(img)
        artwork.put()

        jj = json.dumps({
            'status': 200,
            'count': 1,
            'content': [artwork.to_dict()],
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

class ArtworkAction(webapp.RequestHandler):
    def get(self):
        """
        Get an individual artwork.
        """
        artwork = self.__get_artwork_by_id()
        if artwork is None:
            self.error(404)
            return

        jj = json.dumps({
            'status': 200,
            'count': 1,
            'content': [artwork.to_dict()],
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

    def put(self):
        """
        Vote an individual artwork.
        """
        artwork = self.__get_artwork_by_id()
        if artwork is None:
            self.error(404)
            return

        db.run_in_transaction(increment_counter, artwork.key(), 1)

        jj = json.dumps({
            'status': 200,
            'count': 1,
            'content': [artwork.to_dict()],
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

    def delete(self):
        """
        Delete an invidual artwork.
        """
        artwork = self.__get_artwork_by_id()
        if artwork is None:
            self.error(404)
            return

        artwork.delete()

        jj = json.dumps({
            'status': 200,
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

    def __get_artwork_by_id(self):
        m = re.match("^/artwork/([0-9]+)$", self.request.path)
        id = m and m.group(1)
        if id is None:
            return

        id = long(id)

        return Artwork.get_by_id(id)

class ViewAction(webapp.RequestHandler):
    def get(self):
        """
        Return the artwork image.
        """
        artwork = self.__get_artwork_by_id()
        if artwork is None or artwork.image is None:
            self.error(404)
            return

        filename = "filename=baba-%d.png" % (artwork.key().id_or_name())
        self.response.headers['Content-Disposition'] = filename
        self.response.headers['Content-Type'] = "image/png"
        self.response.out.write(artwork.image)

    def __get_artwork_by_id(self):
        m = re.match("^/artwork/([0-9]+)/image$", self.request.path)
        id = m and m.group(1)
        if id is None:
            return

        id = long(id)

        return Artwork.get_by_id(id)

# Boilerplate
def main():
    actions = [
        ('/artwork/.*/image', ViewAction),
        ('/artwork/.*', ArtworkAction),
        ('/artworks', ArtworksAction),
        ]
    application = webapp.WSGIApplication(actions, debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
