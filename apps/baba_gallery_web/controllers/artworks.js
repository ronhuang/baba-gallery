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

  summary: function() {
    var len = this.get('length'), ret ;

    if (len && len > 0) {
      ret = len === 1 ? "1 task" : "%@ tasks".fmt(len);
    } else ret = "No tasks";

    return ret;
  }.property('length').cacheable()

}) ;
