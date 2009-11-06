// ==========================================================================
// Project:   BabaGalleryWeb - mainPage
// Copyright: ©2009 My Company, Inc.
// ==========================================================================
/*globals BabaGalleryWeb */

// This page describes the main user interface for your application.
BabaGalleryWeb.mainPage = SC.Page.design({

  // The main pane is made visible on screen as soon as your app is loaded.
  // Add childViews to this pane for views to display immediately on page
  // load.
  mainPane: SC.MainPane.design({
    childViews: 'middleView topView bottomView'.w(),

    topView: SC.ToolbarView.design({
      layout: { top: 0, left: 0, right: 0, height: 36 },
      childViews: 'labelView addButton'.w(),
      anchorLocation: SC.ANCHOR_TOP,

      labelView: SC.LabelView.design({
        layout: { centerY: 0, height: 24, left: 8, width: 200 },
        controlSize: SC.LARGE_CONTROL_SIZE,
        fontWeight: SC.BOLD_WEIGHT,
        value: 'Baba Gallery'
      }),

      addButton: SC.ButtonView.design({
        layout: { centerY: 0, height: 24, right: 12, width: 100 },
        title: 'About',
        target: 'BabaGalleryWeb.artworksController',
        action: 'about',
        icon: 'sc-icon-help-16',
      })
    }),

    middleView: SC.SplitView.design({
      layout: { top: 36, bottom: 32, left: 0, right: 0 },
      layoutDirection: SC.LAYOUT_HORIZONTAL,
      defaultThickness: 200,
      topLeftMinThickness: 100,

      //topLeftView: SC.ListView.design({
      //}),
      topLeftView: SC.View.design({
        childViews: 'dummyView'.w(),

        dummyView: SC.ButtonView.design({
          layout: {centerX: 0, top: 12, height: 24, width:80},
          title: "All",
        })
      }),

      bottomRightView: SC.ContainerView.design({
        nowShowingBinding: 'BabaGalleryWeb.artworksController.nowShowing',
      })
    }),

    bottomView: SC.ToolbarView.design({
      layout: { bottom: 0, left: 0, right: 0, height: 32 },
      childViews: 'summaryView'.w(),
      anchorLocation: SC.ANCHOR_BOTTOM,

      summaryView: SC.LabelView.design({
        layout: { centerY: 0, height: 18, left: 20, right: 20 },
        textAlign: SC.ALIGN_CENTER,

        valueBinding: "BabaGalleryWeb.artworksController.summary"
      })
    })
  }),

  thumbnailView: SC.ScrollView.design({
    hasHorizontalScroller: NO,
    backgroundColor: 'white',

    contentView: SC.GridView.design({
      contentBinding: 'BabaGalleryWeb.artworksController.arrangedObjects',
      selectionBinding: 'BabaGalleryWeb.artworksController.selection',
      exampleView: BabaGalleryWeb.ArtworkGridView,
      rowHeight: 216,
      columnWidth: 160
    })
  })

});
