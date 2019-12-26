var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collection_object = TW.views.tasks.collection_object || {};
TW.views.tasks.collection_object.browse = TW.views.tasks.collection_object.browse || {};

Object.assign(TW.views.tasks.collection_object.browse, {
  init: function () {
    TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + "+t", "Open comprehensive specimen digitization", "Browse collection object", function () {
      if(document.querySelector('[data-collection-object-id]')) {
        window.open('/tasks/accessions/comprehensive?collection_object_id=' + document.querySelector('[data-collection-object-id]').getAttribute('data-collection-object-id'), '_self');
      } else {
        window.open('/tasks/accessions/comprehensive');
      }
    });
  }
})

$(document).on("turbolinks:load", function () {
  if ($("#browse-collection-object").length) {
    TW.views.tasks.collection_object.browse.init();
  }
});