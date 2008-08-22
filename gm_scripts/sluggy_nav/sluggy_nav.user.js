// ==UserScript==
// @name           sluggy nav
// @namespace      http://elder-gods.org/wtf
// @description    navigation for sluggy freelance
// @include        http://sluggy.com/*
// ==/UserScript==

var elts  = document.getElementsByTagName("img");
var next = 0, prev = 0, comic = 0; 
for (var i = 0; i < elts.length; i++) { 
	var elt = elts[i]; 
	if (next==0 && elt.getAttribute("alt") == "Next Comic")
		next = elt.parentNode; 
	if (prev==0 && elt.getAttribute("alt") == "Previous Comic")
		prev = elt.parentNode; 
	if (comic==0 && 
		(elt.getAttribute("src").indexOf("http://sluggy.com/images/comics/") == 0  || 
		 elt.getAttribute("src").indexOf("http://www.sluggy.com/images/comics/") == 0))
		comic = elt;
}

function foo (e) { 
	if (String.fromCharCode(e.charCode) == "p") {
		window.location.href = prev; 
	}
	if (String.fromCharCode(e.charCode) == "n") {
		window.location.href = next;
	}
}

function yoffset (elt) { 
	var r = 0; 
	while (elt.offsetParent) {
		r += elt.offsetTop; 
		elt = elt.offsetParent; 
	}
	return r; 
}

function bar(e) { 
	window.scroll(0,yoffset(comic)); 
}

window.addEventListener("keypress", foo, false); 
window.addEventListener("load", bar, false); 









			  