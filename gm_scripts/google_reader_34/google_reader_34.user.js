// ==UserScript==
// @name          Google Reader new items / all items keys
// @namespace     tag://elder-gods.org/greasemonkey
// @description	  Keyboard shortcuts display new items / all items.
// @include       http://www.google.com/reader/view/*
// @include       https://www.google.com/reader/view/*
// ==/UserScript==


function keyHandler(event) {
  if (event.altKey || event.ctrlKey || event.metaKey) {
    return false;
  }
  if (event.target && event.target.nodeName) {
    var targetNodeName = event.target.nodeName.toLowerCase();
    if (targetNodeName == "textarea" ||
        (targetNodeName == "input" && event.target.type &&
         event.target.type.toLowerCase() == "text")) {
      return false;
    }
  }
  var k = event.keyCode;
  if (k == 51) {
	  var evt = document.createEvent("MouseEvents");
	  evt.initMouseEvent("click", true, true, window,
						 0, 0, 0, 0, 0, false, false, false, false, 0, null);
	  window.document.getElementById('show-new').dispatchEvent(evt); 
	  return true;
  }
  if (k == 52) {
	  var evt = document.createEvent("MouseEvents");
	  evt.initMouseEvent("click", true, true, window,
						 0, 0, 0, 0, 0, false, false, false, false, 0, null);
	  window.document.getElementById('show-all').dispatchEvent(evt); 
	  return true;
  }
  return false;
}
window.addEventListener('keydown', keyHandler, false);
