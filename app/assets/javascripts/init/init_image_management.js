$(function() {
  var rails_csrf = {};
  rails_csrf[$('meta[name=csrf-param]').attr('content')] = $('meta[name=csrf-token]').attr('content');

  $('.image-management').elfinder({
    lang: 'zh_CN',
    height: '600',
    width: '1200',
    url: '/media-folder',
    transport : new elFinderSupportVer1(),
    customData: rails_csrf,
    getFileCallback: function(filepath, elfinderInstance)
                     {
                       window.opener.window.productObj.AddImage(filepath);
                       window.opener.window.RefreshImageTable();
                       window.close();
                     },
  });
});
