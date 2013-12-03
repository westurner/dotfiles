/* add a 'tweet' link */
var hdr = document.getElementById("content-main-heading");
var link = document.createElement("a");
link.setAttribute("href", "https://twitter.com/intent/tweet");
var text = document.createTextNode("tweet");
link.appendChild(text);
hdr.parentNode.appendChild(link);
