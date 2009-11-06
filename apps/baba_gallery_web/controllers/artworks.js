// ==========================================================================
// Project:   BabaGalleryWeb.artworksController
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

/** @class

  (Document Your Controller Here)

  @extends SC.ArrayController
*/
BabaGalleryWeb.artworksController = SC.ArrayController.create(
/** @scope BabaGalleryWeb.artworksController.prototype */ {

  nowShowing: 'thumbnailView',

  showThumbnailView: function() {
    this.set('nowShowing', 'thumbnailView');
  },

  showFullscreenView: function() {
    this.set('nowShowing', 'fullscreenView');
  },

  vote: function(src) {
    var artwork = src.get('artwork');
    var url = artwork.get('url');

    SC.Request.putUrl(url).json()
      .notify(this, this.didVoteArtwork, artwork)
      .send();
  },

  didVoteArtwork: function(response, artwork) {
    artwork.refresh();
  },

  summary: function() {
    var len = this.get('length'), ret ;

    if (len && len > 0) {
      ret = len === 1 ? "1 artwork" : "%@ artworks".fmt(len);
    } else ret = "No artworks";

    return ret;
  }.property('length').cacheable()

}) ;
