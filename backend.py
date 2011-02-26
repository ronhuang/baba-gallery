from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
import dbx
from django.utils import simplejson as json
import re
import os
from google.appengine.api import images
from google.appengine.ext.webapp import template
import logging

# Utility
def increment_counter(key, amount):
    obj = db.get(key)
    obj.vote_count += amount
    obj.put()
    return obj

# Model
class Artwork(db.Model):
    name = db.StringProperty()
    email = db.EmailProperty()
    created_at = db.DateTimeProperty(auto_now_add=True)
    updated_at = db.DateTimeProperty(auto_now=True)
    view_count = db.IntegerProperty(default=0)
    vote_count = db.IntegerProperty(default=0)
    image = db.BlobProperty()
    thumbnail = db.BlobProperty()

    @dbx.DerivedProperty
    def url(self):
        if self.is_saved():
            return "/artwork/%d" % (self.key().id_or_name())

    @dbx.DerivedProperty
    def image_url(self):
        if self.is_saved():
            return "/artwork/%d/image" % (self.key().id_or_name())

    @dbx.DerivedProperty
    def thumbnail_url(self):
        if self.is_saved():
            return "/artwork/%d/thumbnail" % (self.key().id_or_name())

    def to_dict(self):
        ll = []
        for p in self.properties():
            if p != "image" and p != "thumbnail":
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
        artworks.order('-created_at')

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
        image_data = self.request.get("image")
        if image_data == "":
            self.error(400)
            return
        image = self.data_uri_scheme_decode(image_data)

        artwork = Artwork()
        #artwork.name = self.request.get("name")
        #artwork.email = self.request.get("email")
        artwork.image = db.Blob(image)
        artwork.thumbnail = db.Blob(images.resize(image, 200, 200))
        artwork.put()

        self.redirect('/artwork/%d' % (artwork.key().id_or_name()))

    def data_uri_scheme_decode(self, uri):
        """Decode from data URI scheme."""

        # syntax of data URLs:
        # dataurl   := "data:" [ mediatype ] [ ";base64" ] "," data
        # mediatype := [ type "/" subtype ] *( ";" parameter )
        # data      := *urlchar

        try:
            [type, data] = uri.split(',', 1)
        except ValueError:
            raise IOError, ('data error', 'bad data URL')

        if not type:
            type = 'text/plain;charset=US-ASCII'
        semi = type.rfind(';')
        if semi >= 0 and '=' not in type[semi:]:
            encoding = type[semi+1:]
            type = type[:semi]
        else:
            encoding = ''

        if encoding == 'base64':
            import base64
            data = base64.decodestring(data)
        else:
            data = unquote(data)

        return data


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

        artwork = db.run_in_transaction(increment_counter, artwork.key(), 1)

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

class ViewAction(webapp.RequestHandler):
    def get(self, artwork_id, artwork_format):
        """
        Return the artwork image.
        """
        artwork = Artwork.get_by_id(long(artwork_id))
        if artwork is None or artwork.image is None or artwork.thumbnail is None:
            self.error(404)
            return

        filename = "filename=baba-%s-%d.jpg" % (artwork_format, artwork.key().id_or_name())
        self.response.headers['Content-Disposition'] = filename
        self.response.headers['Content-Type'] = "image/jpeg"
        if artwork_format == "image":
            self.response.out.write(artwork.image)
        else:
            self.response.out.write(artwork.thumbnail)

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
        ('/artwork/([0-9]+)/(image|thumbnail)$', ViewAction),
        ('/artwork/([0-9]+)$', ArtworkAction),
        ('/artworks', ArtworksAction),
        ('/test', TestAction),
        ]
    application = webapp.WSGIApplication(actions, debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
