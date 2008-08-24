

/* a place for me to put stuff */ 

function bleh() {
	alert ("bleh"); 
};

// from mozless
function tabRelativeSelect(delta)
{
  var oldTab = gBrowser.selectedTab;
  var newTab = null;
  var length = gBrowser.tabContainer.childNodes.length;
  var index;
  for (index=0; index<length; index++) {
    if (gBrowser.tabContainer.childNodes[index] == oldTab) {
      var new_index = index + delta;
      if (new_index < 0) new_index += length;
      else if (new_index >= length) new_index -= length;
      newTab = gBrowser.tabContainer.childNodes[new_index];
      break;
    }
  }
  if (newTab && newTab != oldTab)
    gBrowser.selectedTab = newTab;
}


function fookey(keyCode, charCode, type) { 
	var doc = gBrowser.contentDocument.wrappedJSObject; 
	//var elt = doc.getElementById("main"); 
	var elt = doc; 
	var e = doc.createEvent("KeyEvents"); 
	e.initKeyEvent(type, true, false, null, 
				   false, false, false, false,
				   keyCode, charCode);
	var cancelled = !elt.dispatchEvent(e); 
	if (cancelled) 
		alert("cancelled"); 
}


function fooup(event) {
	event.stopPropagation(); 
	//event.preventDefault(); 
	fookey(KeyEvent["DOM_VK_UP"], 0,  "keyup"); 
	fookey(KeyEvent["DOM_VK_UP"], 0,  "keypress"); 
	fookey(KeyEvent["DOM_VK_UP"], 0,  "keyup"); 
}


function foodown(event) {
	event.stopPropagation() ;
	fookey(KeyEvent["DOM_VK_DOWN"], 0,  "keydown"); 
	fookey(KeyEvent["DOM_VK_DOWN"], 0,  "keypress"); 
	fookey(KeyEvent["DOM_VK_DOWN"], 0,  "keyup"); 
}


function fook(event) {
	fookey(KeyEvent["DOM_VK_K"], 0,  "keydown"); 
	fookey(KeyEvent["DOM_VK_K"], 0,  "keypress"); 
	fookey(KeyEvent["DOM_VK_K"], 0,  "keyup"); 
}


function fooj(event) {
	fookey(KeyEvent["DOM_VK_J"], 0,  "keydown"); 
	fookey(KeyEvent["DOM_VK_J"], 0,  "keypress"); 
	fookey(KeyEvent["DOM_VK_J"], 0,  "keyup"); 
}

function foolistener(event) { 
	if (gBrowser.contentDocument.location.toString().indexOf("http://www.google.com/reader") == 0) {
		if (event.altKey) {
			if (String.fromCharCode(event.charCode) == "j")
				fooj(event); 
			else if (String.fromCharCode(event.charCode) == "k")
				fook(event); 
		} else {
			if (String.fromCharCode(event.charCode) == "j")
				foodown(event); 
			else if (String.fromCharCode(event.charCode) == "k")
				fooup(event); 
		}
	}
}

function normalj () { 
	if (gBrowser.contentDocument.location.toString().indexOf("http://www.google.com/reader") != 0) 
		goDoCommand('cmd_scrollLineDown');
}

function normalk () { 
	if (gBrowser.contentDocument.location.toString().indexOf("http://www.google.com/reader") != 0) 
		goDoCommand('cmd_scrollLineUp');
}


window.addEventListener("keypress", foolistener, true); 


