
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

var keymap = {
    "westurner.org": 'UA-46001060-1',
};

if (document.location.hostname in keymap) {
    var gajs_id = keymap[document.location.hostname];
    ga('create', gajs_id, 'auto');
    ga('require', 'displayfeatures');
    ga('send', 'pageview');
}

/*!
 * JavaScript Cookie v2.1.1
 * https://github.com/js-cookie/js-cookie
 *
 * Copyright 2006, 2015 Klaus Hartl & Fagner Brack
 * Released under the MIT license
 */
;(function (factory) {
	if (typeof define === 'function' && define.amd) {
		define(factory);
	} else if (typeof exports === 'object') {
		module.exports = factory();
	} else {
		var OldCookies = window.Cookies;
		var api = window.Cookies = factory();
		api.noConflict = function () {
			window.Cookies = OldCookies;
			return api;
		};
	}
}(function () {
	function extend () {
		var i = 0;
		var result = {};
		for (; i < arguments.length; i++) {
			var attributes = arguments[ i ];
			for (var key in attributes) {
				result[key] = attributes[key];
			}
		}
		return result;
	}

	function init (converter) {
		function api (key, value, attributes) {
			var result;
			if (typeof document === 'undefined') {
				return;
			}

			// Write

			if (arguments.length > 1) {
				attributes = extend({
					path: '/'
				}, api.defaults, attributes);

				if (typeof attributes.expires === 'number') {
					var expires = new Date();
					expires.setMilliseconds(expires.getMilliseconds() + attributes.expires * 864e+5);
					attributes.expires = expires;
				}

				try {
					result = JSON.stringify(value);
					if (/^[\{\[]/.test(result)) {
						value = result;
					}
				} catch (e) {}

				if (!converter.write) {
					value = encodeURIComponent(String(value))
						.replace(/%(23|24|26|2B|3A|3C|3E|3D|2F|3F|40|5B|5D|5E|60|7B|7D|7C)/g, decodeURIComponent);
				} else {
					value = converter.write(value, key);
				}

				key = encodeURIComponent(String(key));
				key = key.replace(/%(23|24|26|2B|5E|60|7C)/g, decodeURIComponent);
				key = key.replace(/[\(\)]/g, escape);

				return (document.cookie = [
					key, '=', value,
					attributes.expires && '; expires=' + attributes.expires.toUTCString(), // use expires attribute, max-age is not supported by IE
					attributes.path    && '; path=' + attributes.path,
					attributes.domain  && '; domain=' + attributes.domain,
					attributes.secure ? '; secure' : ''
				].join(''));
			}

			// Read

			if (!key) {
				result = {};
			}

			// To prevent the for loop in the first place assign an empty array
			// in case there are no cookies at all. Also prevents odd result when
			// calling "get()"
			var cookies = document.cookie ? document.cookie.split('; ') : [];
			var rdecode = /(%[0-9A-Z]{2})+/g;
			var i = 0;

			for (; i < cookies.length; i++) {
				var parts = cookies[i].split('=');
				var name = parts[0].replace(rdecode, decodeURIComponent);
				var cookie = parts.slice(1).join('=');

				if (cookie.charAt(0) === '"') {
					cookie = cookie.slice(1, -1);
				}

				try {
					cookie = converter.read ?
						converter.read(cookie, name) : converter(cookie, name) ||
						cookie.replace(rdecode, decodeURIComponent);

					if (this.json) {
						try {
							cookie = JSON.parse(cookie);
						} catch (e) {}
					}

					if (key === name) {
						result = cookie;
						break;
					}

					if (!key) {
						result[name] = cookie;
					}
				} catch (e) {}
			}

			return result;
		}

		api.set = api;
		api.get = function (key) {
			return api(key);
		};
		api.getJSON = function () {
			return api.apply({
				json: true
			}, [].slice.call(arguments));
		};
		api.defaults = {};

		api.remove = function (key, attributes) {
			api(key, '', extend(attributes, {
				expires: -1
			}));
		};

		api.withConverter = init;

		return api;
	}

	return init(function () {});
}));

// newtab.js
//
// Requires
// * jQuery: https://github.com/jquery/jquery
// * js-cookie: https://github.com/js-cookie/js-cookie
//
// References
// * https://mathiasbynens.github.io/rel-noopener/
//
// License: MIT LICENSE
$(document).ready(function() {


  var options;
  var options_cookie_json = Cookies.getJSON('options');
  if (options_cookie_json === undefined) {
    var options_defaults = {
      'open_in_new_tab': true,
      'show_visited_links': true,
    };
    options = options_defaults;
  } else {
    options = options_cookie_json;
  }
  console.log('options:');
  console.log(options);

  function match_external_url_elem(elem) {
    var elem = $(elem);
    if (elem === undefined) {
      return false;
    }
    var url = elem.attr('href');
    if (url === undefined) {
      return false;
    }
    var relstr = elem.attr('rel');
    var rels = [];
    if (relstr !== undefined) {
      rels = relstr.split(' ');
    }
    // skip rel="noreferrer" (because window.open)
    if (rels.indexOf('noreferrer') !== -1)
    {
      return false;
    }
    if (
      (   elem.attr('target') === '_blank')
      || (rels.indexOf('noopener') > -1)
      || (rels.indexOf('external') !== -1)
      || (elem.hasClass('external'))  // [sphinx,]
      || (url.substring(0,8) === 'http://')
      || (url.substring(0,9) === 'https://')
      || (url.substring(0,3) === '//')
      || (url.substring(0,7) === 'ftp://')
      || (url.substring(0,7) === 'svn://')
      || (url.substring(0,7) === 'git://')
    ) {
        return true;
    }
    return false;
  }
  $(document).on('click', 'a', function(e) {
    if (options['open_in_new_tab']) {
      if (match_external_url_elem(this)) {
        var url = $(this).attr('href');
        e.preventDefault();
        var otherWindow = window.open();
        otherWindow.opener = null;
        otherWindow.location = url;
      }
    }
  });

  var sidebar = $("#sidebar-wrapper").find("div.sidebar");
      var options_widget = $("\
  <div class='widget sidebar-options'> \
    <h3>Options</h3> \
    <ul> \
      <li> \
        <input id='chk_newtab' \
          type='checkbox' \
          aria-label='Open links in a new tab' \
          title='Open links in a new tab' \
        ></input> \
        <label for='chk_newtab'>Open links in a new tab</label> \
      </li> \
      <li> \
        <input id='chk_showvisited' \
          type='checkbox' \
          aria-label='Show visited links' \
          title='Show visited links' \
        ></input> \
        <label for='chk_showvisited'>Show visited links</label> \
      </li> \
    </ul> \
  </div>");
  sidebar.append(options_widget);

  var chk = $('input#chk_newtab');
  chk.prop('checked', options['open_in_new_tab']);
  chk.on('change', function(e) {
    options['open_in_new_tab'] = this.checked;
    Cookies.set('options', options);
  });

  function create_stylesheet() {
    var css = document.createElement('style');
    css.id = 'newtabcss';
    css.type = 'text/css';
    $('head').append(css);
    return css.sheet;
  }

  var stylesheet = create_stylesheet();

  // show_visited_links
  var localstate = { };
  function set_showvisitedcss() {
    if (options['show_visited_links'] === true) {
      localstate['show_visited_links/a:visited/color'] = (
        stylesheet.insertRule('a:visited { color: #551A8B !important; }',
                             stylesheet.cssRules.length)
      );
    } else {
      var ruleidx = localstate['show_visited_links/a:visited/color'];
      if (ruleidx !== undefined) {
        if (stylesheet.cssRules) {
          if (stylesheet.cssRules.length) {
            stylesheet.deleteRule(ruleidx);
          }
        } else { // IE < 9
          if (stylesheet.rules.length) {
            stylesheet.removeRule(ruleidx);
          }
        }
      }
      localstate['show_visited_links/a:visited/color'] = undefined;
    }
  }
  set_showvisitedcss();

  var chk = $('input#chk_showvisited');
  chk.prop('checked', options['show_visited_links']);
  chk.on('change', function(e) {
    options['show_visited_links'] = this.checked;
    Cookies.set('options', options);
    set_showvisitedcss();
  });
});


// <affix-sidenav>
$(document).ready(function() {
  $('#sidebar-wrapper').affix({
  });
})
// </affix-sidenav>
/*!
 * jQuery.scrollTo
 * Copyright (c) 2007-2015 Ariel Flesler - aflesler<a>gmail<d>com | http://flesler.blogspot.com
 * Licensed under MIT
 * http://flesler.blogspot.com/2007/10/jqueryscrollto.html
 * @projectDescription Lightweight, cross-browser and highly customizable animated scrolling with jQuery
 * @author Ariel Flesler
 * @version 2.1.1
 */
;(function(factory) {
	'use strict';
	if (typeof define === 'function' && define.amd) {
		// AMD
		define(['jquery'], factory);
	} else if (typeof module !== 'undefined' && module.exports) {
		// CommonJS
		module.exports = factory(require('jquery'));
	} else {
		// Global
		factory(jQuery);
	}
})(function($) {
	'use strict';

	var $scrollTo = $.scrollTo = function(target, duration, settings) {
		return $(window).scrollTo(target, duration, settings);
	};

	$scrollTo.defaults = {
		axis:'xy',
		duration: 0,
		limit:true
	};

	function isWin(elem) {
		return !elem.nodeName ||
			$.inArray(elem.nodeName.toLowerCase(), ['iframe','#document','html','body']) !== -1;
	}		

	$.fn.scrollTo = function(target, duration, settings) {
		if (typeof duration === 'object') {
			settings = duration;
			duration = 0;
		}
		if (typeof settings === 'function') {
			settings = { onAfter:settings };
		}
		if (target === 'max') {
			target = 9e9;
		}

		settings = $.extend({}, $scrollTo.defaults, settings);
		// Speed is still recognized for backwards compatibility
		duration = duration || settings.duration;
		// Make sure the settings are given right
		var queue = settings.queue && settings.axis.length > 1;
		if (queue) {
			// Let's keep the overall duration
			duration /= 2;
		}
		settings.offset = both(settings.offset);
		settings.over = both(settings.over);

		return this.each(function() {
			// Null target yields nothing, just like jQuery does
			if (target === null) return;

			var win = isWin(this),
				elem = win ? this.contentWindow || window : this,
				$elem = $(elem),
				targ = target, 
				attr = {},
				toff;

			switch (typeof targ) {
				// A number will pass the regex
				case 'number':
				case 'string':
					if (/^([+-]=?)?\d+(\.\d+)?(px|%)?$/.test(targ)) {
						targ = both(targ);
						// We are done
						break;
					}
					// Relative/Absolute selector
					targ = win ? $(targ) : $(targ, elem);
					if (!targ.length) return;
					/* falls through */
				case 'object':
					// DOMElement / jQuery
					if (targ.is || targ.style) {
						// Get the real position of the target
						toff = (targ = $(targ)).offset();
					}
			}

			var offset = $.isFunction(settings.offset) && settings.offset(elem, targ) || settings.offset;

			$.each(settings.axis.split(''), function(i, axis) {
				var Pos	= axis === 'x' ? 'Left' : 'Top',
					pos = Pos.toLowerCase(),
					key = 'scroll' + Pos,
					prev = $elem[key](),
					max = $scrollTo.max(elem, axis);

				if (toff) {// jQuery / DOMElement
					attr[key] = toff[pos] + (win ? 0 : prev - $elem.offset()[pos]);

					// If it's a dom element, reduce the margin
					if (settings.margin) {
						attr[key] -= parseInt(targ.css('margin'+Pos), 10) || 0;
						attr[key] -= parseInt(targ.css('border'+Pos+'Width'), 10) || 0;
					}

					attr[key] += offset[pos] || 0;

					if (settings.over[pos]) {
						// Scroll to a fraction of its width/height
						attr[key] += targ[axis === 'x'?'width':'height']() * settings.over[pos];
					}
				} else {
					var val = targ[pos];
					// Handle percentage values
					attr[key] = val.slice && val.slice(-1) === '%' ?
						parseFloat(val) / 100 * max
						: val;
				}

				// Number or 'number'
				if (settings.limit && /^\d+$/.test(attr[key])) {
					// Check the limits
					attr[key] = attr[key] <= 0 ? 0 : Math.min(attr[key], max);
				}

				// Don't waste time animating, if there's no need.
				if (!i && settings.axis.length > 1) {
					if (prev === attr[key]) {
						// No animation needed
						attr = {};
					} else if (queue) {
						// Intermediate animation
						animate(settings.onAfterFirst);
						// Don't animate this axis again in the next iteration.
						attr = {};
					}
				}
			});

			animate(settings.onAfter);

			function animate(callback) {
				var opts = $.extend({}, settings, {
					// The queue setting conflicts with animate()
					// Force it to always be true
					queue: true,
					duration: duration,
					complete: callback && function() {
						callback.call(elem, targ, settings);
					}
				});
				$elem.animate(attr, opts);
			}
		});
	};

	// Max scrolling position, works on quirks mode
	// It only fails (not too badly) on IE, quirks mode.
	$scrollTo.max = function(elem, axis) {
		var Dim = axis === 'x' ? 'Width' : 'Height',
			scroll = 'scroll'+Dim;

		if (!isWin(elem))
			return elem[scroll] - $(elem)[Dim.toLowerCase()]();

		var size = 'client' + Dim,
			doc = elem.ownerDocument || elem.document,
			html = doc.documentElement,
			body = doc.body;

		return Math.max(html[scroll], body[scroll]) - Math.min(html[size], body[size]);
	};

	function both(val) {
		return $.isFunction(val) || $.isPlainObject(val) ? val : { top:val, left:val };
	}

	// Add special hooks so that window scroll properties can be animated
	$.Tween.propHooks.scrollLeft = 
	$.Tween.propHooks.scrollTop = {
		get: function(t) {
			return $(t.elem)[t.prop]();
		},
		set: function(t) {
			var curr = this.get(t);
			// If interrupt is true and user scrolled, stop animating
			if (t.options.interrupt && t._last && t._last !== curr) {
				return $(t.elem).stop();
			}
			var next = Math.round(t.now);
			// Don't waste CPU
			// Browsers don't render floating point scroll
			if (curr !== next) {
				$(t.elem)[t.prop](next);
				t._last = this.get(t);
			}
		}
	};

	// AMD requirement
	return $scrollTo;
});
(function ($) {

    $.fn.isOnScreen = function(x, y){

        if(x == null || typeof x == 'undefined') x = 1;
        if(y == null || typeof y == 'undefined') y = 1;

        var win = $(window);

        var viewport = {
            top : win.scrollTop(),
            left : win.scrollLeft()
        };
        viewport.right = viewport.left + win.width();
        viewport.bottom = viewport.top + win.height();

        var height = this.outerHeight();
        var width = this.outerWidth();

        if(!width || !height){
            return false;
        }

        var bounds = this.offset();
        bounds.right = bounds.left + width;
        bounds.bottom = bounds.top + height;

        var visible = (!(viewport.right < bounds.left || viewport.left > bounds.right || viewport.bottom < bounds.top || viewport.top > bounds.bottom));

        if(!visible){
            return false;
        }

        var deltas = {
            top : Math.min( 1, ( bounds.bottom - viewport.top ) / height),
            bottom : Math.min(1, ( viewport.bottom - bounds.top ) / height),
            left : Math.min(1, ( bounds.right - viewport.left ) / width),
            right : Math.min(1, ( viewport.right - bounds.left ) / width)
        };

        return (deltas.left * deltas.right) >= x && (deltas.top * deltas.bottom) >= y;

    };

})(jQuery);


"use strict";

function navbar_scrollto(node) {
    var sidebar = $('#sidebar-wrapper').first()[0];
    var navbar = $(sidebar).find('div.sidebar').first()[0];

    if (sidebar && navbar) {
        var do_scroll = false;
        if ($(navbar).is(':visible')) {
            if ($.scrollTo) {
                do_scroll = true;
            } else {
                console.log('$.scrollTo not found');
            }
        }
        if (do_scroll) {
            // console.log("scrollTo", node);
            if (!($(node).isOnScreen())) {
                $(sidebar).scrollTo($(node), {
                    axis: 'y',
                    offset: { top: -100 }
                });
            }
        }
    } else {
        console.log('sidebar is', sidebar);
        console.log('navbar is', navbar);
    }
}
function navbar_update(nodeurl) {

    console.log('navbar_update', nodeurl);

    if (nodeurl.match('^#index-[0-9]+')) {
        return;
    }
    var __node = $(nodeurl).first();
    if (!(__node)) {
        console.log('navbar_update: nodeurl not found', nodeurl)
        return
    } else {
        console.log('node', __node);
    }
    var content = $('#content-wrapper');
    var navbar = $('#sidebar-wrapper').find('div.sidebar').first()[0];
    ($(content)
        .find('a.headerlink.youarehere')
        .removeClass('youarehere')
        .text('¶')
    );
    ($('#navbar-top')
        .find('a.youarehere')
        .removeClass('youarehere')
    );
    ($('#navbar-top')
        .find('li.youarehere')
        .removeClass('youarehere')
    );
    var selectedlink = $(navbar)
        .find('a.youarehere');
    selectedlink
        .removeClass('youarehere');
    selectedlink.parent()
        .removeClass('youarehere');

    if (nodeurl) {
        var headerlink = $(content)
            .find('a.headerlink[href="' + nodeurl + '"]');
        headerlink
            .addClass('youarehere')
            .text('⬅');
        headerlink.parent()
            .addClass('youarehere');

        var toplink = $('#navbar-top')
            .find('a.reference.internal[href="' + nodeurl + '"]');
        toplink
            .addClass('youarehere');
        toplink.parent()
            .addClass('youarehere');

        var navbarlink = $(navbar)
            .find('a[href="' + nodeurl + '"]');

        if (navbarlink) {
            navbarlink
                .addClass('youarehere');
            navbarlink.parent()
                .addClass('youarehere');
            console.log(navbarlink);
            try {
                navbar_scrollto(navbarlink.first()); // # navbar a.youarehere
            } catch(e) {
               
                console.log('navbar_scrollto(navbarlink.first()): err');
                console.log(e);
            }
        } else {
            console.log("nodeurl not found");
            console.log(nodeurl);
        }
    } else {
        console.log("nodeurl is false");
        console.log(nodeurl);
    }
}

function navbar__remap_sphinx_toc_links() {
    var content = $('#content-wrapper');
    ($(content)
        .find('a.headerlink')
        .map(function(i, node) {
            // console.log(i, node);
            $(node.previousSibling).attr('href', $(node).attr('href'));
        })
    );
}

function navbar__add_top_button() {
    ($('<button type="button" class="toplink navbar-toggle"><a href="#" title="Top"><span>^</span></a></button>')
     .appendTo('body'));
}

function navbar_init() {
    // require('jquery.scrollto')
    //var scriptstr = '<script src="https://cdn.jsdelivr.net/jquery.scrollto/2.1.0/jquery.scrollTo.min.js"></script>';
    //$(scriptstr).appendTo("head");
    navbar_update(window.location.hash);

    navbar__remap_sphinx_toc_links();
    navbar__add_top_button();

    window.onhashchange = function(e) {
        // console.log(e); // e.newURL , e.oldURL
        var loc_hash_url = window.location.hash;
        console.log(loc_hash_url);
        if (loc_hash_url != false) {
            navbar_update(loc_hash_url);
        };
    };
}


$(document).ready(navbar_init);

