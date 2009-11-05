// ==========================================================================
// Project:   BabaGalleryWeb.ArtworkDataSource
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

sc_require('models/artwork');
BabaGalleryWeb.ARTWORKS_QUERY = SC.Query.local(BabaGalleryWeb.Artwork, {
  orderBy: 'created_at'
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

    if (query === BabaGalleryWeb.ARTWORKS_QUERY) {
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

    // TODO: Add handlers to retrieve an individual record's contents
    // call store.dataSourceDidComplete(storeKey) when done.

    return NO ; // return YES if you handled the storeKey
  },

  createRecord: function(store, storeKey) {

    // TODO: Add handlers to submit new records to the data source.
    // call store.dataSourceDidComplete(storeKey) when done.

    return NO ; // return YES if you handled the storeKey
  },

  updateRecord: function(store, storeKey) {

    // TODO: Add handlers to submit modified record to the data source
    // call store.dataSourceDidComplete(storeKey) when done.

    return NO ; // return YES if you handled the storeKey
  },

  destroyRecord: function(store, storeKey) {

    // TODO: Add handlers to destroy records on the data source.
    // call store.dataSourceDidDestroy(storeKey) when done

    return NO ; // return YES if you handled the storeKey
  }

}) ;
