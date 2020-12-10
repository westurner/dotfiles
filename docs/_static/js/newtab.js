
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

