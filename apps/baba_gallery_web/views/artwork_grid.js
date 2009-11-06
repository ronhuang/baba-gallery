// ==========================================================================
// Project:   BabaGalleryWeb.ArtworkGridView
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

/** @class

  (Document Your View Here)

  @extends SC.View
*/
BabaGalleryWeb.ArtworkGridView = SC.View.extend(
/** @scope BabaGalleryWeb.ArtworkGridView.prototype */ {

  classNames: ['artwork-grid-view'],

  createChildViews: function() {
    var childViews = [], view;
    var frame = this.get('frame');
    var margin = 2;
    var line_height = 24
    var info_height = line_height * 2 + margin * 3;
    var image_size = Math.min(frame.width, frame.height - info_height) - margin * 2;

    // content display properties.
    var name, vote_count, image_url;
    var content = this.get('content');
    if (content) {
      name = content.get('name');
      vote_count = content.get('vote_count');
      image_url = content.get('image_url');
    }

    view = this.createChildView(
      SC.ImageView.design({
        layout: {centerX: 0, centerY: -(info_height / 2),
                 width: image_size, height: image_size},
        useImageCache: NO,
        value: image_url
      }),
      { rootElementPath: [0] }
    );
    childViews.push(view);

    view = this.createChildView(
      SC.ListItemView.design({
        layout: {left: margin, right: margin, height: line_height,
                 bottom: info_height - line_height - margin},
        content: content,
        contentValueKey: 'name',
        contentUnreadCountKey: 'vote_count',
        hasContentIcon: YES,
        contentIconKey: 'icon',
        outlineIndent: 0
      }),
      {rootElementPath: [1] }
    );
    childViews.push(view);

    view = this.createChildView(
      SC.ButtonView.design({
        theme: 'capsule',
        layout: {left: margin, right: margin, bottom: margin, height: line_height},
        title: 'Vote',
        target: "BabaGalleryWeb.artworksController",
        action: "vote"
      }),
      { rootElementPath: [2] }
    );
    childViews.push(view);

    this.set('childViews', childViews);
  }

});
