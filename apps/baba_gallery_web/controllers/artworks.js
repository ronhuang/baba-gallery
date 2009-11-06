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
  aboutPane: null,
  thickness: null,
  thumbnailWidth: 160,
  thumbnailHeight: 160 + 56,

  showThumbnailView: function() {
    this.set('nowShowing', 'thumbnailView');
  },

  showFullscreenView: function() {
    this.set('nowShowing', 'fullscreenView');
  },

  vote: function(view) {
    var artwork = view.get('artwork');
    var url = artwork.get('url');

    SC.Request.putUrl(url).json()
      .notify(this, this.didVoteArtwork, artwork)
      .send();
  },

  didVoteArtwork: function(response, artwork) {
    artwork.refresh();
  },

  about: function(view) {
    var pane = SC.PanelPane.create({
      layout: { width: 400, height: 215, centerX: 0, centerY: 0 },
      contentView: SC.View.extend({
        layout: { top: 0, left: 0, bottom: 0, right: 0 },
        childViews: 'labelView buttonView'.w(),

        labelView: SC.LabelView.extend({
          layout: { bottom: 64, top: 20, left: 20, right: 20 },
          textAlign: SC.ALIGN_CENTER,
          escapeHTML: NO,
          value: "<p><b>Baba Gallery</b></p> \
                  <p><i>Final project for NM5211 - Serious Games & Learning Media</i></p> \
                  <p>By: Dilrukshi Abeyrathne, Jeffrey Koh, Nimesha Ranasinghe \
                  Roshan Peiris, Xuan Wang, and Yih-Lun Huang</p> \
                  <p>Supervisor: Dr. Timothy Marsh</p>"
        }),

        buttonView: SC.ButtonView.extend({
          layout: { width: 80, bottom: 20, height: 24, centerX: 0 },
          title: "Close",
          action: "remove",
          target: "BabaGalleryWeb.artworksController.aboutPane"
        })
      })
    });
    pane.append();
    this.set('aboutPane', pane);
  },

  thumbnailObserver: function() {
  }.observes('thickness', 'thumbnailWidth', 'thumbnailHeight'),

  summary: function() {
    var len = this.get('length'), ret ;

    if (len && len > 0) {
      ret = len === 1 ? "1 artwork" : "%@ artworks".fmt(len);
    } else ret = "No artworks";

    return ret;
  }.property('length').cacheable()

}) ;
