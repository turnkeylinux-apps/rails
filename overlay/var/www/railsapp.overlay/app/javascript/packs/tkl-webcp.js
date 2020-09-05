require("packs/jquery")
require("packs/ui-core")
require("packs/ui-tabs")

require.context('../images', true)

require("stylesheets/base")
require("stylesheets/ui-tabs")

$(function() {
  $('#container-1 > ul').tabs({ fx: { opacity: 'toggle'} });
});
