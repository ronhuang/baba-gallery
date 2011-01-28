from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
import dbx
from django.utils import simplejson as json
import re
import os
from google.appengine.api import images
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp import template

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
    image = blobstore.BlobReferenceProperty()

    @dbx.DerivedProperty
    def url(self):
        if self.is_saved():
            return "/artwork/%d" % (self.key().id_or_name())

    @dbx.DerivedProperty
    def image_url(self):
        if self.is_saved():
            return images.get_serving_url(str(self.image.key()), size=800)

    @dbx.DerivedProperty
    def thumbnail_url(self):
        if self.is_saved():
            return images.get_serving_url(str(self.image.key()), size=200)

    def to_dict(self):
        ll = []
        for p in self.properties():
            if p != "image":
                ll.append((p, unicode(getattr(self, p))))
        return dict(ll)

# Action
class ArtworksAction(blobstore_handlers.BlobstoreUploadHandler):
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
        upload_files = self.get_uploads("img")
        blob_info = upload_files[0]
        if blob_info is None:
            self.error(400)
            return

        artwork = Artwork()
        artwork.name = self.request.get("name")
        artwork.email = self.request.get("email")
        artwork.image = blob_info
        artwork.put()

        self.redirect('/artwork/%d' % (artwork.key().id_or_name()))

class ArtworkAction(webapp.RequestHandler):
    def get(self, artwork_id):
        """
        Get an individual artwork.
        """
        artwork = Artwork.get_by_id(long(artwork_id))
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

    def put(self, artwork_id):
        """
        Vote an individual artwork.
        """
        artwork = Artwork.get_by_id(long(artwork_id))
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

    def delete(self, artwork_id):
        """
        Delete an invidual artwork.
        """
        artwork = Artwork.get_by_id(long(artwork_id))
        if artwork is None:
            self.error(404)
            return

        artwork.delete()

        jj = json.dumps({
            'status': 200,
            })
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(jj)

class TestAction(webapp.RequestHandler):
    def get(self):
        template_values = {
            'upload_url': blobstore.create_upload_url('/artworks'),
        }

        path = os.path.join(os.path.dirname(__file__), 'template', 'test.html')
        self.response.out.write(template.render(path, template_values))

# Boilerplate
def main():
    actions = [
        ('/artwork/([0-9]+)$', ArtworkAction),
        ('/artworks', ArtworksAction),
        ('/test', TestAction),
        ]
    application = webapp.WSGIApplication(actions, debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
