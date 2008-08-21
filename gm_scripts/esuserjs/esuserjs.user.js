// ==UserScript==
// @name          es.user.js
// @namespace     http://elder-gods.org/wtf
// @description   navigation for errant story
// @include       http://www.errantstory.com/*
// ==/UserScript==

var elts  = document.getElementsByTagName("a");
var next = 0, prev = 0; 
for (var i = 0; i < elts.length; i++) { 
	var elt = elts[i]; 
	if (next==0 && elt.getAttribute("title") == "Next")
		next = elt; 
	if (prev==0 && elt.getAttribute("title") == "Back")
		prev = elt; 
}

function foo (e) { 
	if (String.fromCharCode(e.charCode) == "p") {
		window.location = prev; 
	}
	if (String.fromCharCode(e.charCode) == "n") {
		window.location = next;
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
	window.scroll(0,yoffset(next)); 
}

window.addEventListener("keypress", foo, false); 
window.addEventListener("load", bar, false); 








			  