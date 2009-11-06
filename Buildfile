# -*- coding: utf-8 -*-
# ===========================================================================
# Project:   BabaGalleryWeb
# Copyright: ©2009 My Company, Inc.
# ===========================================================================

# Add initial buildfile information here
config :all,
  :required => :sproutcore,
  :url_prefix => 'baba-gallery'

proxy '/baba-gallery/artworks', :to => 'li91-73.members.linode.com'
proxy '/baba-gallery/a', :to => 'li91-73.members.linode.com'
