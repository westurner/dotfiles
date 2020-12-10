

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

