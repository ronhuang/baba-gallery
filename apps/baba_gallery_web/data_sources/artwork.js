// ==========================================================================
// Project:   BabaGalleryWeb.ArtworkDataSource
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

sc_require('models/artwork');
BabaGalleryWeb.ARTWORKS_DATE_QUERY = SC.Query.local(BabaGalleryWeb.Artwork, {
  orderBy: 'created_at DESC, vote_count DESC'
});
BabaGalleryWeb.ARTWORKS_VOTE_QUERY = SC.Query.local(BabaGalleryWeb.Artwork, {
  orderBy: 'vote_count DESC, created_at DESC'
});

/** @class

  (Document Your Data Source Here)

  @extends SC.DataSource
*/

BabaGalleryWeb.ArtworkDataSource = SC.DataSource.extend(
/** @scope BabaGalleryWeb.ArtworkDataSource.prototype */ {

  // ..........................................................
  // QUERY SUPPORT
  //

  fetch: function(store, query) {
    if (query === BabaGalleryWeb.ARTWORKS_DATE_QUERY ||
        query === BabaGalleryWeb.ARTWORKS_VOTE_QUERY) {
      SC.Request.getUrl('/baba-gallery/artworks').json()
        .notify(this, 'didFetchArtworks', store, query)
        .send();
      return YES;
    }

    return NO;
  },

  didFetchArtworks: function(response, store, query) {
    if (SC.ok(response)) {
      store.loadRecords(BabaGalleryWeb.Artwork, response.get('body').content);
      store.dataSourceDidFetchQuery(query);
    } else store.dataSourceDidErrorQuery(query, response);
  },

  // ..........................................................
  // RECORD SUPPORT
  //

  retrieveRecord: function(store, storeKey) {
    if (SC.kindOf(store.recordTypeFor(storeKey), BabaGalleryWeb.Artwork)) {
      SC.Request.getUrl(store.idFor(storeKey)).json()
        .notify(this, 'didRetrieveArtwork', store, storeKey)
        .send();
      return YES;
    } else return NO;

    return NO ; // return YES if you handled the storeKey
  },

  didRetrieveArtwork: function(response, store, storeKey) {
    if (SC.ok(response)) {
      var dataHash = response.get('body').content;
      store.dataSourceDidComplete(storeKey, dataHash);
    } else store.dataSourceDidError(storeKey, response);
  },

  createRecord: function(store, storeKey) {
    // Don't support creating new artwork through web interface yet.
    return NO ; // return YES if you handled the storeKey
  },

  updateRecord: function(store, storeKey) {
    // Only support updating vote count.
    if (SC.kindOf(store.recordTypeFor(storeKey), BabaGalleryWeb.Artwork)) {
      SC.Request.putUrl(store.idFor(storeKey)).json()
        .notify(this, this.didUpdateArtwork, store, storeKey)
        .send(store.readDataHash(storeKey));
      return YES;
    } else return NO ;
  },

  didUpdateArtwork: function(response, store, storeKey) {
    if (SC.ok(response)) {
      var data = response.get('body');
      if (data) data = data.content; // if hash is returned; use it.
      store.dataSourceDidComplete(storeKey, data) ;
    } else store.dataSourceDidError(storeKey);
  },

  destroyRecord: function(store, storeKey) {
    if (SC.kindOf(store.recordTypeFor(storeKey), BabaGalleryWeb.Artwork)) {
      SC.Request.deleteUrl(store.idFor(storeKey)).json()
        .notify(this, this.didDestroyArtwork, store, storeKey)
        .send();
      return YES;
    } else return NO;
  },

  didDestroyArtwork: function(response, store, storeKey) {
    if (SC.ok(response)) {
      store.dataSourceDidDestroy(storeKey);
    } else store.dataSourceDidError(response);
  }

}) ;
