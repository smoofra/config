

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


function fookey(keyCode, type) { 
	var doc = gBrowser.contentDocument; 
	var e = doc.createEvent("KeyEvents"); 
	e.initKeyEvent(type, true, true, doc.defaultView,
				   false, false, false, false,
				   keyCode, 0);
	doc.dispatchEvent(e); 
}

function fooup(event) {
	var utils = window.QueryInterface(Components.interfaces.nsIInterfaceRequestor).getInterface(Components.interfaces.nsIDOMWindowUtils);
// 	utils.sendKeyEvent("keydown",  KeyEvent["DOM_VK_UP"], 0, 0);
// 	utils.sendKeyEvent("keypress", KeyEvent["DOM_VK_UP"], 0, 0);
// 	utils.sendKeyEvent("keyup",    KeyEvent["DOM_VK_UP"], 0, 0);
// 	utils.sendKeyEvent("keydown",  38, 0, 0);
// 	utils.sendKeyEvent("keypress", 38, 0, 0);
// 	utils.sendKeyEvent("keyup",    38, 0, 0);
	fookey(KeyEvent["DOM_VK_UP"], "keyup"); 
	fookey(KeyEvent["DOM_VK_UP"], "keypress"); 
	fookey(KeyEvent["DOM_VK_UP"], "keyup"); 

}


function foodown(event) {
	var utils = window.QueryInterface(Components.interfaces.nsIInterfaceRequestor).getInterface(Components.interfaces.nsIDOMWindowUtils);
// 	utils.sendKeyEvent("keydown",  40, 0, 0);
// 	utils.sendKeyEvent("keypress", 40, 0, 0);
// 	utils.sendKeyEvent("keyup",    40, 0, 0);
// 	utils.sendKeyEvent("keydown",  KeyEvent["DOM_VK_DOWN"], 0, 0);
// 	utils.sendKeyEvent("keypress", KeyEvent["DOM_VK_DOWN"], 0, 0);
// 	utils.sendKeyEvent("keyup",    KeyEvent["DOM_VK_DOWN"], 0, 0);
	fookey(KeyEvent["DOM_VK_DOWN"], "keydown"); 
	fookey(KeyEvent["DOM_VK_DOWN"], "keypress"); 
	fookey(KeyEvent["DOM_VK_DOWN"], "keyup"); 
}

