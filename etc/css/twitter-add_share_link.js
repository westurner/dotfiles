/* add a 'share' link */
var hdr = document.getElementById('content-main-heading');
var link = document.createElement('a');
link.setAttribute('href', 'https://twitter.com/share');
var text = document.createTextNode('share');
link.appendChild(text);
hdr.parentNode.appendChild(link);
