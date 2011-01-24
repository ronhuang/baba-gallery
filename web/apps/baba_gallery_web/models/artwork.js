// ==========================================================================
// Project:   BabaGalleryWeb.Artwork
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

/** @class

  (Document your Model here)

  @extends SC.Record
  @version 0.1
*/
BabaGalleryWeb.Artwork = SC.Record.extend(
/** @scope BabaGalleryWeb.Artwork.prototype */ {

  name: SC.Record.attr(String),
  email: SC.Record.attr(String),
  created_at: SC.Record.attr(SC.DateTime),
  updated_at: SC.Record.attr(SC.DateTime),
  view_count: SC.Record.attr(Number, { defaultValue: 0 }),
  vote_count: SC.Record.attr(Number, { defaultValue: 0 }),
  image_url: SC.Record.attr(String),

  icon: function() {
    return "sc-icon-user-16";
  }.property().cacheable(),

  url: function() {
    return this.get('guid');
  }.property('guid').cacheable()

}) ;
