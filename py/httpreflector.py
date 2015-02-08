import os
import posixpath
import BaseHTTPServer
import urllib
import cgi
import sys
import shutil
import mimetypes
from StringIO import StringIO

__version__ = "0.1"

class ReflectRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):

  server_version = "HTTPReflector/" + __version__

  def do_GET(self):
    f = self.send_debug()
    if f:
      try:
        self.copyfile(f, self.wfile)
      finally:
        f.close()

  def send_debug(self):
    f = StringIO()
    f.write('client_address: %r\n' % (self.client_address,))
    f.write('command: %r\n' % (self.command,))
    f.write('path: %r\n' % (self.path,))
    f.write('request_version: %r\n' % (self.request_version,))
    f.write('raw_requestline: %r\n' % (self.raw_requestline,))
    for (name, val) in self.headers.items():
      f.write('%r: %r\n' % (name, val))
    length = f.tell()
    f.seek(0)
    #self.send_response(200)
    encoding = sys.getfilesystemencoding()
    #self.send_header("Content-type", "text/plain; charset=%s" % encoding)
    #self.send_header("Content-Length", str(length))
    #self.end_headers()
    return f

  def copyfile(self, source, outputfile):
    """Copy all data between two file objects.

    The SOURCE argument is a file object open for reading
    (or anything with a read() method) and the DESTINATION
    argument is a file object open for writing (or
    anything with a write() method).

    The only reason for overriding this would be to change
    the block size or perhaps to replace newlines by CRLF
    -- note however that this the default server uses this
    to copy binary data as well.

    """
    shutil.copyfileobj(source, outputfile)

def test(HandlerClass = ReflectRequestHandler,
     ServerClass = BaseHTTPServer.HTTPServer):
  BaseHTTPServer.test(HandlerClass, ServerClass)

if __name__ == '__main__':
  test()
