from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

# Action
class MainAction(webapp.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write('Main!')

class TestAction(webapp.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/html'
        self.response.out.write("""<html>
        <body>
          <form action="/artworks" enctype="multipart/form-data" method="post">
            <div><label>Name:</label></div>
            <div><input type="text" name="name"/></div>
            <div><label>Email:</label></div>
            <div><input type="text" name="email"/></div>
            <div><label>Artwork:</label></div>
            <div><input type="file" name="img"/></div>
            <div><input type="submit" value="Upload"></div>
          </form>
        </body>
      </html>""")

# Boilerplate
def main():
    actions = [
        ('/', MainAction),
        ('/test', TestAction),
        ]
    application = webapp.WSGIApplication(actions, debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
