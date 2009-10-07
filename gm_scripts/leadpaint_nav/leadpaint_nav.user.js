// ==UserScript==
// @name           leadpaint_nav
// @namespace      http://elder-gods.org/wtf
// @include        http://www.leadpaintcomics.com/*
// ==/UserScript==


var elts  = document.getElementsByTagName("li");
var next = 0, prev = 0; 
for (var i = 0; i < elts.length; i++) { 
	var elt = elts[i]; 
	if (next==0 && elt.getAttribute("class") == "next") { 
		next = elt.childNodes[0];
	}
	if (prev==0 && elt.getAttribute("class") == "previous") {
		prev = elt.childNodes[0];
	}
}


function foo (e) { 
	if (String.fromCharCode(e.charCode) == "p") {
		window.location = prev; 
	}
	if (String.fromCharCode(e.charCode) == "n") {
		window.location = next;
	}
}

window.addEventListener("keypress", foo, false); 


