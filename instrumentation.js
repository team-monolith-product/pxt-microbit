(function(){
  var origCreate = document.createElement;
  document.createElement = function(tag) {
    var el = origCreate.apply(document, arguments);
    if (tag === "iframe") {
      var desc = Object.getOwnPropertyDescriptor(HTMLIFrameElement.prototype, "src");
      Object.defineProperty(el, "src", {
        set: function(v) {
          if (v && /\/simulator(?:[?#]|$)/.test(v) && !/\.html/.test(v.split(/[?#]/)[0])) {
            Sentry.captureException(
              new Error("iframe src missing .html: " + v.substring(0, 200)),
              {
                extra: {
                  src: v.substring(0, 200),
                  pxtConfigSimUrl: (window.pxtConfig || {}).simUrl,
                  webConfigSimUrl: (window.pxt && window.pxt.webConfig || {}).simUrl
                }
              }
            );
          }
          desc.set.call(this, v);
        },
        get: function() {
          return desc.get.call(this);
        }
      });
    }
    return el;
  };
})();
