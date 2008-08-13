

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
