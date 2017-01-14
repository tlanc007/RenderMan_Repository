//
// iWeb - BlogSummary.js
// Copyright 2006-2007 Apple Inc.
// All rights reserved.
//

function BlogSummaryWidget(instanceID)
{if(instanceID)
{detectBrowser();Widget.apply(this,arguments);this.contentID="summary-content";this.itemTemplateID="item-template";this.itemID="item";this.separatorTemplateID="separator-template";this.selectState=null;this.sfrShadow=null;this.disableShadows=isEarlyWebKitVersion;this.styleThreeMaximumWidth=0.65;this.debugBorders=(location.href.indexOf("summaryBorders")!=-1);this.debugCompiledHtml=(location.href.indexOf("summaryCompiledHtml")!=-1);this.debugFinalHtml=(location.href.indexOf("summaryFinalHtml")!=-1);this.debugTrace=(location.href.indexOf("summaryTrace")!=-1);if(this.debugTrace)trace=print;if(this.privateInitialize)
{this.privateInitialize();}
document.blogSummaryWidget=this;this.initializingPreferences=true;this.initializeDefaultPreferences({"htmlTemplate":"","excerpt-length":"100","extraSpace":0,"headerOnTop":false,"imageSize":"25","imageSizeOverride":"","imagePosition":"Left","imageOutside":false,"imageVisibility":true,"rss-for-archive":false,"photoProportions":"Landscape"});delete this.initializingPreferences;this.dotMacFeedType=this.preferenceForKey("dotMacFeedType");this.feedType=this.dotMacFeedType||"static";this.dotMacAccount=this.preferenceForKey("dotMacAccount")||"";this.updateTemplate();this.applyUpgrades();this.fetchAndRenderRSS();}}
BlogSummaryWidget.prototype=new Widget();BlogSummaryWidget.prototype.constructor=BlogSummaryWidget;BlogSummaryWidget.prototype.widgetIdentifier="com-apple-iweb-widget-blogSummary";BlogSummaryWidget.prototype.sizeDidChange=function()
{this.invalidateSummaryItems("sizeDidChange");};BlogSummaryWidget.prototype.onload=function()
{Widget.prototype.onload.apply(this,arguments);this.changedPreferenceForKey("htmlTemplate");this.changedPreferenceForKey("sfr-stroke");this.changedPreferenceForKey("sfr-reflection");this.changedPreferenceForKey("sfr-shadow");};BlogSummaryWidget.prototype.changedPreferenceForKey=function(key)
{try
{if(this.initializingPreferences)
{return;}
if(this.privateChangedPreferenceForKey)
{this.privateChangedPreferenceForKey(key);}
if(key=="htmlTemplate")
{this.updateTemplate();}
if(key=="rss-for-archive")
{this.fetchAndRenderRSS();}
var value=this.preferenceForKey(key);if(key=="sfr-shadow")
{if(value!=null)
{this.sfrShadow=eval(value);}
else
{this.sfrShadow=null;}
this.renderSummaryItems("sfr-shadow");}
if(key=="sfr-stroke")
{if(value!==null)
this.sfrStroke=eval(value);else
this.sfrStroke=null;this.invalidateSummaryItems("sfr-stroke");}
if(key=="sfr-reflection")
{if(value!==null)
{this.sfrReflection=eval(value);}
else
{this.sfrReflection=null;}
this.invalidateSummaryItems("sfr-reflection");}
if(key=="photoProportions")
{this.invalidateSummaryItems(key);}}
catch(e)
{debugPrintException(e);}}
BlogSummaryWidget.prototype.applyUpgrades=function()
{var upgrades=this.preferenceForKey("upgrades");if(upgrades===undefined)
{upgrades={};}
if((!upgrades["styleThreeWidthScale"]))
{if(this.imagePlacementStyle()==3)
{var oldImageSize=this.preferenceForKey("imageSize");var newImageSize=Math.floor(oldImageSize/this.styleThreeMaximumWidth);this.setPreferenceForKey(newImageSize,"imageSize",false);trace("Upgrading image size from %s to %s",oldImageSize,newImageSize);}
upgrades["styleThreeWidthScale"]=true;this.setPreferenceForKey(upgrades,"upgrades",false);}}
BlogSummaryWidget.prototype.updateTemplate=function()
{var html=this.preferenceForKey("htmlTemplate");html=html.replace(/<div class=["']clear:[ ]*both;?['"] ?\/>/g,"<div style='clear:both'></div>");html=html.replace(/<div style=["']clear:[ ]*both;?['"] ?\/>/g,"<div style='clear:both'></div>");if(html=="")
{var markup;if(this.preferenceForKey("rss-for-archive"))
markup=BlogSummaryShared.defaultArchiveMarkup;else
markup=BlogSummaryShared.defaultSummaryMarkup;trace("** brand-new widget html being compiled from source markup");if(markup)
{html=BlogSummaryShared.compileMarkup(markup);}}
if(html)
{if(html.indexOf("<span class='bl-localized'>")==-1)
{if(html.indexOf("Read more...")!=-1)
html=html.replace(/Read more\.\.\./g,"<span class='bl-localized'>Read more...</span>");else if(html.indexOf("More...")!=-1)
html=html.replace(/More\.\.\./g,"<span class='bl-localized'>More...</span>");}
var contentDiv=this.getElementById(this.contentID);if(contentDiv)
{if(this.debugCompiledHtml)print("\n\n%s\n\n",html);html=html.replace(/\$WIDGET_ID/g,this.instanceID);contentDiv.innerHTML=html;this.resetRenderingState=true;this.invalidateSummaryItems("updateTemplate");optOutOfCSSBackgroundPNGFix(contentDiv);}}};function isWordBreakCharacter(oneCharString)
{if(oneCharString==null)
{return false;}
var ch=oneCharString.charCodeAt(0);return(ch==0x0020)||(ch==0x000a)||(ch==0x000d)||(ch==0x00a0)||(ch==0x1680)||(ch>=0x2000&&ch<=0x200b)||(ch==0x202f)||(ch==0x205f)||(ch==0x3000)||(ch==0x2014);}
function HTMLTextModel(node)
{this.indexArray=[];this.nodeArray=[];this.cachedNode=null;this.cachedNodeStart=null;this.cachedNodeEnd=null;this.rootNode=node;this.buildTextModel(node);}
HTMLTextModel.prototype=new Object;HTMLTextModel.prototype.buildTextModel=function(node)
{for(var i=0;i<node.childNodes.length;++i)
{var childNode=node.childNodes[i];if(childNode.nodeType==Node.TEXT_NODE)
{this.nodeArray.push(childNode);this.indexArray.push((this.indexArray.length===0?0:this.indexArray[this.indexArray.length-1])+childNode.nodeValue.length);this.length=this.indexArray[this.indexArray.length-1];}
else if(childNode.nodeType==Node.ELEMENT_NODE)
{this.buildTextModel(childNode);}}}
HTMLTextModel.prototype.nodeIndexForCharacterIndex=function(index)
{var nodeIndex;for(var i=0;i<this.nodeArray.length;++i)
{if(index<this.indexArray[i])
{nodeIndex=i;break;}}
return nodeIndex;}
HTMLTextModel.prototype.characterAtIndex=function(index)
{if((this.cachedNode==null)||(index<this.cachedNodeStart)||(index>=this.cachedNodeEnd))
{this.cachedNode=null;var nodeIndex=this.nodeIndexForCharacterIndex(index);if(nodeIndex!==undefined)
{this.cachedNode=this.nodeArray[nodeIndex];this.cachedNodeStart=nodeIndex===0?0:this.indexArray[nodeIndex-1];this.cachedNodeEnd=this.cachedNodeStart+this.cachedNode.nodeValue.length;}}
if(this.cachedNode)
{return this.cachedNode.nodeValue.charAt(index-this.cachedNodeStart);}
return"";}
HTMLTextModel.prototype.truncateAtIndex=function(index,suffix)
{var nodeIndex=this.nodeIndexForCharacterIndex(index);if(nodeIndex!==undefined)
{var node=this.nodeArray[nodeIndex];var subIndex=index-(nodeIndex===0?0:this.indexArray[nodeIndex-1]);node.nodeValue=node.nodeValue.substr(0,subIndex);if(suffix)
{node.nodeValue=node.nodeValue+suffix;}
while(node!=this.rootNode)
{while(node.nextSibling!=null)
{node.parentNode.removeChild(node.nextSibling);}
node=node.parentNode;}}}
HTMLTextModel.prototype.truncateAroundPosition=function(index,suffix)
{var pos=index;if(pos>=this.length)
{return;}
while(pos>=0)
{if(isWordBreakCharacter(this.characterAtIndex(pos)))
{while(pos>0&&isWordBreakCharacter(this.characterAtIndex(pos)))
{pos--;}
pos++;this.truncateAtIndex(pos,suffix);return;}
pos--;}
this.truncateAtIndex(index,suffix);}
BlogSummaryWidget.prototype.summaryExcerpt=function(descriptionHTML,maxSummaryLength)
{var div=document.createElement("div");div.innerHTML=descriptionHTML;if(maxSummaryLength>0)
{var model=new HTMLTextModel(div);model.truncateAroundPosition(maxSummaryLength,"...");}
else if(maxSummaryLength===0)
{div.innerHTML="";}
return div.innerHTML;};BlogSummaryWidget.prototype.commentCountText=function(count,enabled)
{if(count==0)
{if(enabled)
{return this.localizedString("No Comments");}
else
{return"";}}
else if(count==1)
{return this.localizedString("1 Comment");}
else
{return String.stringWithFormat(this.localizedString("%s Comments"),count);}}
function byteToPercentEscapeValue(ch)
{ch=ch&0xFF;var hiChar="0123456789ABCDEF".charAt(ch/16);var loChar="0123456789ABCDEF".charAt(ch%16);return"%"+hiChar+loChar;}
function sanitizeUrlStringForIE6(s)
{var result="";for(var i=0;i<s.length;++i)
{var ch=s.charCodeAt(i);if(ch<128)
result+=s.charAt(i);else
result+=byteToPercentEscapeValue(ch);}
return result;}
BlogSummaryWidget.prototype.replaceLinkTargets=function(node,replaceArray)
{var links=node.getElementsByTagName("a");for(var j=0;j<links.length;++j)
{var linkTarget=links[j].getAttribute("href");if(linkTarget&&linkTarget.length>0)
{for(var i=0;i<replaceArray.length;++i)
{linkTarget=linkTarget.replace(replaceArray[i][0],replaceArray[i][1]);}
if(linkTarget)
{if(windowsInternetExplorer&&browserVersion<7)
{linkTarget=sanitizeUrlStringForIE6(linkTarget);}
links[j].setAttribute("href",linkTarget);}}}}
BlogSummaryWidget.prototype.invalidateSummaryItems=function(reason)
{trace('invalidateSummaryItems(%s)',reason);if(this.pendingRender!==null)
{clearTimeout(this.pendingRender);}
this.pendingRender=setTimeout(function()
{this.pendingRender=null;this.renderSummaryItems(reason);}.bind(this),50);}
BlogSummaryWidget.prototype.renderCommentCount=function(itemNode,index,enabled,count)
{var commentCountText=this.commentCountText(count,enabled);var spans=$(itemNode).select('.bl-value-comment-count');spans.forEach(function(node)
{removeAllChildNodes(node);node.appendChild(document.createTextNode(commentCountText));});var commentFieldNode=this.getElementById("comment-field",index);if(commentFieldNode)
{commentFieldNode.style.display=(commentCountText.length===0)?"none":"";}}
BlogSummaryWidget.prototype.applyLocalization=function(parent)
{var localizedSpans=$(parent).select('.bl-localized');localizedSpans.each(function(span)
{var key=getTextFromNode(span);removeAllChildNodes(span);span.appendChild(document.createTextNode(this.localizedString(key)));}.bind(this));}
function croppedSize(originalSize,cropKind,width)
{if(cropKind=="Square")
{return new IWSize(width,width);}
else if(cropKind=="Landscape")
{return new IWSize(width,width*(3/4));}
else if(cropKind=="Portrait")
{return new IWSize(width,width*(4/3));}
else
{var scaleFactor=width/originalSize.width;return originalSize.scale(scaleFactor,scaleFactor,true);}}
BlogSummaryWidget.prototype.croppingDivForImage=function(image,kind,width)
{var cropDiv=null;if(image.loaded())
{var img=document.createElement('img');img.src=image.sourceURL();var natural=image.naturalSize();cropDiv=document.createElement("div");cropDiv.appendChild(img);var croppingDivForImage_helper=function(loadedImage)
{if(loadedImage)
{natural=new IWSize(loadedImage.width,loadedImage.height);}
var cropped=croppedSize(natural,kind,width);var scaleFactor=cropped.width/natural.width;if(natural.aspectRatio()>cropped.aspectRatio())
{scaleFactor=cropped.height/natural.height;}
var scaled=natural.scale(scaleFactor);var offset=new IWPoint(Math.abs(scaled.width-cropped.width)/2,Math.abs(scaled.height-cropped.height)/2);img.style.width=px(scaled.width);img.style.height=px(scaled.height);img.style.marginLeft=px(-offset.x);img.style.marginTop=px(-offset.y);img.style.position='relative';cropDiv.style.width=px(cropped.width);cropDiv.style.height=px(cropped.height);cropDiv.style.overflow="hidden";cropDiv.style.position='relative';cropDiv.className="crop";}
detectBrowser();if(windowsInternetExplorer&&browserVersion<7&&img.src.indexOf(transparentGifURL())!=-1)
{var originalImage=new Image();originalImage.src=img.originalSrc;if(originalImage.complete)
{croppingDivForImage_helper(originalImage);}
else
{originalImage.onload=croppingDivForImage_helper.bind(null,originalImage);}}
else
{croppingDivForImage_helper(null);}}
return cropDiv;}
function isEquivalentToEmpty(s)
{return(s===undefined)||(s===null)||(s==="");}
BlogSummaryWidget.prototype.imagePlacementStyle=function()
{var result;var headerOnTop=this.preferenceForKey("headerOnTop");var imageOutside=this.preferenceForKey("imageOutside");var imagePosition=this.preferenceForKey("imagePosition");var imageSizeOverride=this.preferenceForKey("imageSizeOverride");var settings=[imagePosition,imageOutside,headerOnTop,imageSizeOverride!=''];if(settings.isEqual(['Left',false,true,false]))
result=1;else if(settings.isEqual(['Left',false,false,false]))
result=2;else if(settings.isEqual(['Left',true,false,false]))
result=3;else if(settings.isEqual(['Right',false,false,false]))
result=4;else if(settings.isEqual(['Left',false,true,true]))
result=5;return result;}
BlogSummaryWidget.prototype.applyEffects=function(div)
{if(this.sfrShadow||this.sfrReflection||this.sfrStroke)
{if((div.offsetWidth===undefined)||(div.offsetHeight===undefined)||(div.offsetWidth===0)||(div.offsetHeight===0))
{setTimeout(BlogSummaryWidget.prototype.applyEffects.bind(this,div),0)
return;}
if(this.sfrStroke&&(div.strokeApplied==false))
{this.sfrStroke.applyToElement(div);div.strokeApplied=true;}
if(this.sfrReflection&&(div.reflectionApplied==false))
{this.sfrReflection.applyToElement(div);div.reflectionApplied=true;}
if(this.sfrShadow&&(!this.disableShadows)&&(div.shadowApplied==false))
{this.sfrShadow.applyToElement(div);div.shadowApplied=true;}
if(this.runningInApp&&(window.webKitVersion<=419)&&this.preferences.setNeedsDisplay)
{this.preferences.setNeedsDisplay();}}
if(windowsInternetExplorer)
{var cropDivs=div.select('.crop');var cropDiv=cropDivs[cropDivs.length-1];if(cropDiv)
{cropDiv.onclick=function()
{var anchorNode=div.parentNode;var targetHref=window.location.href;while(anchorNode&&(anchorNode.tagName!="A"))
{anchorNode=anchorNode.parentNode}
if(anchorNode)
{targetHref=anchorNode.href;}
window.location=targetHref;};cropDiv.onmouseover=function()
{this.style.cursor='pointer';}}}}
BlogSummaryWidget.prototype.renderSummaryItems=function()
{trace('renderSummaryItems(%s)',arguments[0]);if(this.pendingRender)
{clearTimeout(this.pendingRender);this.pendingRender=null;}
if(this.onloadReceived==false)
{this.invalidateSummaryItems();return;}
if(this.blogFeed.itemCount()===0)
{trace(' exit: no items');return;}
if(this.resetRenderingState)
{this.lastRerenderImageSettings=[];this.lastRedoLayoutSettings=[];this.resetRenderingState=false;}
var itemTemplateNode=this.getElementById(this.itemTemplateID);var separatorTemplateNode=this.getElementById(this.separatorTemplateID);if(itemTemplateNode===null)
{trace(' exit: no template');return;}
var parentNode=itemTemplateNode.parentNode;var shouldDisableLinks=this.enableSubSelection;var excerptLength=this.preferenceForKey("excerpt-length");var imageSize=this.preferenceForKey("imageSize");var imageSizeOverride=this.preferenceForKey("imageSizeOverride");var imagePosition=this.preferenceForKey("imagePosition");var showPhotosOption=this.preferenceForKey("imageVisibility");var extraSpace=this.preferenceForKey("extraSpace");var imageOutside=this.preferenceForKey("imageOutside");var headerOnTop=this.preferenceForKey("headerOnTop");var photoProportions=this.preferenceForKey("photoProportions");var isArchive=this.preferenceForKey("rss-for-archive");var sfrShadowText=this.preferenceForKey("sfr-shadow");var sfrReflectionText=this.preferenceForKey("sfr-reflection");var sfrStrokeText=this.preferenceForKey("sfr-stroke");var showImages=showPhotosOption&&(excerptLength!==0);var imagePlacementStyle=this.imagePlacementStyle();if(this.runningInApp&&((this.lastImagePlacementStyle!==undefined)&&(this.lastImagePlacementStyle!=imagePlacementStyle)))
{var tempLastImagePlacementStyle=this.lastImagePlacementStyle;this.lastImagePlacementStyle=imagePlacementStyle;if(imagePlacementStyle==3)
{imageSize=Math.min(Math.ceil(imageSize/this.styleThreeMaximumWidth),100);this.setPreferenceForKey(imageSize,"imageSize",false);return;}
else if(tempLastImagePlacementStyle==3)
{imageSize=Math.max(10,Math.ceil(imageSize*this.styleThreeMaximumWidth));this.setPreferenceForKey(imageSize,"imageSize",false);return;}}
this.lastImagePlacementStyle=imagePlacementStyle;if((imagePlacementStyle==3)&&!showImages)
{imageOutside=false;imagePlacementStyle=2;}
if(this.imagePlacementStyle()==3)
{var oldImageSize=imageSize;imageSize=Math.min(Math.max(10,Math.ceil(imageSize*this.styleThreeMaximumWidth)),100);trace("imageSize is %s but using %s because this is style 3",oldImageSize,imageSize);}
if(imageSizeOverride!=="")
{imageSize=Number(imageSizeOverride);}
var paddingLeft=0;var paddingRight=0;var contentDiv=this.getElementById(this.contentID);if(this.debugBorders)contentDiv.style.border="1px solid orange";var node=this.getElementById("image");if(node)
{while((node!==null)&&(node!==contentDiv))
{if(node.style)
{paddingLeft+=parseFloat(node.style.paddingLeft||0);paddingRight+=parseFloat(node.style.paddingRight||0);}
node=node.parentNode;}}
var imageWidth=imageSize/100.0*($(parentNode).getWidth()-(paddingLeft+paddingRight));if(imageSizeOverride!==""&&this.sfrStroke)
{var strokeExtra=this.sfrStroke.strokeExtra();imageWidth-=(strokeExtra.left+strokeExtra.right);}
if(this.preferences&&this.preferences.postNotification)
{this.preferences.postNotification("BLBlogSummaryWidgetThumbnailWidthNotification",imageWidth);}
var rerenderImageSettings=[extraSpace,showImages,imageWidth,imagePosition,imageOutside,headerOnTop,sfrShadowText,sfrReflectionText,sfrStrokeText,photoProportions];var redoLayoutSettings=[imagePosition,extraSpace,imageOutside,imageWidth,headerOnTop,sfrStrokeText,showImages];var rerenderImage=(this.lastRerenderImageSettings===undefined||(rerenderImageSettings.isEqual(this.lastRerenderImageSettings)==false));var redoLayout=(this.lastRedoLayoutSettings===undefined||(redoLayoutSettings.isEqual(this.lastRedoLayoutSettings)==false));this.lastRerenderImageSettings=rerenderImageSettings;this.lastRedoLayoutSettings=redoLayoutSettings;var maxItems=this.blogFeed.maximumItemsToDisplay();for(var i=0;i<maxItems;++i)
{var item=this.blogFeed.itemAtIndex(i);var itemNode=this.getElementById(this.itemID,i);if(itemNode===null)
{itemNode=itemTemplateNode.cloneNode(true);itemNode.id=this.getInstanceId(this.itemID);adjustNodeIds(itemNode,i);var divClearBoth=document.createElement("div");divClearBoth.style.clear="both";parentNode.insertBefore(divClearBoth,itemTemplateNode);parentNode.insertBefore(itemNode,itemTemplateNode);}
if(shouldDisableLinks)
{disableLinks(itemNode);}
if(!item.dateString)
{if(item.date)
{item.dateString=item.date.stringWithICUDateFormat(this.blogFeed.dateFormat(),this);}}
substituteSpans(itemNode,{"bl-value-title":["html",item.title||""],"bl-value-date":["text",item.dateString],"bl-value-excerpt":["html",this.summaryExcerpt(item.description||"",excerptLength)]});if(this.runningInApp)
{this.renderCommentCount(itemNode,i,item.commentingEnabled,item.commentCount);this.replaceLinkTargets(itemNode,[[/\$link\$/g,item.relativeURL.toURLString()],[/\$comment-link\$/g,item.relativeCommentURL.toURLString()]]);}
else
{var linkReplacer=function(item,itemNode)
{var itemCommentLink=item.relativeURL.toURLString()+"#comment_layer";this.replaceLinkTargets(itemNode,[[/\$link\$/g,item.relativeURL.toURLString()],[/\$comment-link\$/g,itemCommentLink]]);}.bind(this,item,itemNode);if(this.dotMacAccount!="")
{this.fetchCommentCountInfoForItem(item,i,itemNode,linkReplacer);}
else
{linkReplacer();}}
var entryHasImage=(!isEquivalentToEmpty(item.imageUrlString));var imgDiv=this.getElementById("image",i);var imgGroupDiv=this.getElementById("image-group",i);var headerNode=this.getElementById("header",i);if(headerNode)
{if(headerOnTop)
{imgDiv.parentNode.insertBefore(headerNode,imgDiv);}
else
{imgDiv.parentNode.insertBefore(headerNode,imgDiv.nextSibling);}}
if(imgDiv)
{if(showImages)
{if(rerenderImage)
{removeAllChildNodes(imgGroupDiv);if(entryHasImage)
{imgGroupDiv.strokeApplied=false;imgGroupDiv.reflectionApplied=false;imgGroupDiv.shadowApplied=false;imgGroupDiv.style.marginLeft="0px";imgGroupDiv.style.marginTop="0px";imgGroupDiv.style.marginRight="0px";imgGroupDiv.style.marginBottom="0px";imgGroupDiv.style.position='relative';imgDiv.style.position='relative';var imageUrl=(item.imageUrlString)||transparentGifURL();var image=IWCreateImage(imageUrl);image.load(function(image,imgDiv,imgGroupDiv)
{var cropDiv=this.croppingDivForImage(image,photoProportions,imageWidth);imgGroupDiv.appendChild(cropDiv);if(image.sourceURL()!==transparentGifURL())
{this.applyEffects(imgGroupDiv);}}.bind(this,image,imgDiv,imgGroupDiv));}}}
if(redoLayout)
{$(imgDiv).setStyle({cssFloat:imagePosition});$(itemNode).setStyle({cssFloat:"none"});var strokeWidth=0;var strokeHeight=0;if(this.sfrStroke)
{var strokeExtra=null;if(this.sfrStroke.strokeExtra)
{strokeExtra=this.sfrStroke.strokeExtra();}
if(strokeExtra)
{strokeWidth=(strokeExtra.left+strokeExtra.right);strokeHeight=(strokeExtra.top+strokeExtra.bottom);}}
if(imageOutside)
{if(imagePosition=="Left")
{var leftInset=(imageWidth+extraSpace+strokeWidth);if((windowsInternetExplorer&&browserVersion<7)||isFirefox)
leftInset+=paddingLeft;var marginLeft=-1*leftInset;imgDiv.style.marginLeft=px(marginLeft);imgDiv.style.marginRight=px(0);imgDiv.style.paddingBottom=px(0);imgDiv.style.paddingLeft=px(0);imgDiv.style.paddingRight=px(0);if(this.debugBorders)imgDiv.style.border="1px solid blue";if(windowsInternetExplorer&&browserVersion<7)
itemNode.style.paddingLeft=px(0);else
itemNode.style.paddingLeft=px(imageWidth+extraSpace+strokeWidth+paddingLeft);itemNode.style.paddingRight=px(0);if(this.debugBorders)itemNode.style.border="1px solid red";itemNode.style.width=px(depx(this.div().style.width)-leftInset-paddingLeft-paddingRight);$(itemNode).setStyle({cssFloat:"right"});}
else if(imagePosition=="Right")
{imgDiv.style.marginLeft=px(0);imgDiv.style.marginRight=px(-1*(imageWidth+extraSpace));imgDiv.style.paddingBottom=px(0);imgDiv.style.paddingLeft=px(0);imgDiv.style.paddingRight=px(0);itemNode.style.paddingLeft=px(0);itemNode.style.paddingRight=px(imageWidth+extraSpace);itemNode.style.width="";}}
else
{if(imagePosition=="Left")
{imgDiv.style.marginLeft=px(0);imgDiv.style.marginRight=px(0);imgDiv.style.paddingBottom=px(extraSpace+strokeHeight);imgDiv.style.paddingLeft=px(0);imgDiv.style.paddingRight=px(extraSpace+strokeWidth);itemNode.style.paddingLeft=px(0);itemNode.style.paddingRight=px(0);itemNode.style.width="";}
else if(imagePosition=="Right")
{imgDiv.style.marginLeft=px(0);imgDiv.style.marginRight=px(0);imgDiv.style.paddingBottom=px(extraSpace+strokeHeight);imgDiv.style.paddingLeft=px(extraSpace);imgDiv.style.paddingRight=px(strokeWidth);itemNode.style.paddingLeft=px(0);itemNode.style.paddingRight=px(0);itemNode.style.width="";}}}
if(showImages&&entryHasImage)
{if(imgDiv.style.display!="")
{imgDiv.style.display="";}}
else
{if(imgDiv.style.display!="none")
imgDiv.style.display="none";itemNode.style.paddingLeft=px(0);itemNode.style.paddingRight=px(0);}}
var newSep=null;if(separatorTemplateNode&&(i<this.blogFeed.itemCount()-1))
{newSep=this.getElementById(this.separatorTemplateID,i);if(newSep==null)
{newSep=separatorTemplateNode.cloneNode(true);adjustNodeIds(newSep,i);parentNode.insertBefore(newSep,itemTemplateNode);}}
this.applyLocalization(itemNode);itemNode.style.display="";if(newSep)
{newSep.style.display="";}}
var index=maxItems;while(true)
{if(index>0)
{var sep=this.getElementById(this.separatorTemplateID,index-1);if(sep)
{sep.parentNode.removeChild(sep);}}
var node=this.getElementById(this.itemID,index);if(node===null)
{break;}
node.parentNode.removeChild(node);index++;}
var pusherSpan=document.getElementById("pusher");if(pusherSpan==null)
{pusherSpan=document.createElement("span");pusherSpan.innerHTML="&nbsp;";pusherSpan.id="pusher";itemTemplateNode.parentNode.insertBefore(pusherSpan,null);}
pusherSpan.style.display=(imagePlacementStyle==3)?"":"none";if(windowsInternetExplorer)
{fixAllIEPNGs(transparentGifURL());setTimeout(fixupIEPNGBGsInTree.bind(null,contentDiv,true),1);}
if(this.privateSummaryDidRender)
{this.privateSummaryDidRender();}
if(this.debugFinalHtml)
{setTimeout(function()
{print(contentDiv.outerHTML);},5000);this.debugFinalHtml=false;}
trace(" exit: done",this.blogFeed.itemCount(),"items");};BlogSummaryWidget.prototype.fetchAndRenderRSS=function()
{var isArchiveWidget=this.preferenceForKey("rss-for-archive");this.blogFeed=new BlogFeed(BlogRootURLString(location.href),this.feedType,isArchiveWidget,function()
{this.invalidateSummaryItems("renderSummaryFromRSS");}.bind(this));};BlogSummaryWidget.prototype.fetchCommentCountInfoForItem=function(item,index,itemNode,postRenderCallback)
{var commentSummaryURL=item.absoluteURL.toURLString()+"?wsc=summary.js&ts="+new Date().getTime();var renderItemCommentSummary=function(request,successful)
{if(successful)
{if(request.responseText)
{var r=request.responseText.match(/.*= ((true)|(false));.*\n.*= (\d+)/);if(r)
{var enabled=(r[1]=="true");var count=Number(r[4]);this.renderCommentCount(itemNode,index,enabled,count);}}}
postRenderCallback();}.bind(this);makeXmlHttpRequest(commentSummaryURL,makeAjaxHandler(renderItemCommentSummary));}
Date.prototype.ampmHour=function()
{var hour=this.getHours();if(hour>=12)hour-=12;if(hour==0)hour=12;return hour;}
Date.abbreviatedMonthNameKeys=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];Date.abbreviatedWeekdayNameKeys=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];Date.ampmKeys=["AM","PM"];Date.fullMonthNameKeys=["January","February","March","April","May","June","July","August","September","October","November","December"];Date.fullWeekdayNameKeys=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];Date.localizedTableLookup=function(table,index,localizer)
{var string=table[index];if(localizer)
{string=localizer.localizedString(string);}
return string;}
Date.abbreviatedMonthName=function(index,localizer)
{return Date.localizedTableLookup(Date.abbreviatedMonthNameKeys,index,localizer);}
Date.abbreviatedWeekdayName=function(index,localizer)
{return Date.localizedTableLookup(Date.abbreviatedWeekdayNameKeys,index,localizer);}
Date.ampmName=function(index,localizer)
{return Date.localizedTableLookup(Date.ampmKeys,index,localizer);}
Date.fullWeekdayName=function(index,localizer)
{return Date.localizedTableLookup(Date.fullWeekdayNameKeys,index,localizer);}
Date.fullMonthName=function(index,localizer)
{return Date.localizedTableLookup(Date.fullMonthNameKeys,index,localizer);}
var formatConversion={"y2":function(d,localizer){return("0"+d.getFullYear()).slice(-2);},"y4":function(d,localizer){return("0000"+d.getFullYear()).slice(-4);},"M4":function(d,localizer){return Date.fullMonthName(d.getMonth(),localizer);},"M3":function(d,localizer){return Date.abbreviatedMonthName(d.getMonth(),localizer);},"M2":function(d,localizer){return("0"+(d.getMonth()+1)).slice(-2);},"M1":function(d,localizer){return String(d.getMonth()+1);},"d2":function(d,localizer){return("0"+d.getDate()).slice(-2);},"d1":function(d,localizer){return d.getDate();},"h2":function(d,localizer){return("0"+d.ampmHour()).slice(-2);},"h1":function(d,localizer){return d.ampmHour();},"H2":function(d,localizer){return("0"+d.getHours()).slice(-2);},"H1":function(d,localizer){return d.getHours();},"m2":function(d,localizer){return("0"+d.getMinutes()).slice(-2);},"m1":function(d,localizer){return d.getMinutes();},"s2":function(d,localizer){return("0"+d.getSeconds()).slice(-2);},"s1":function(d,localizer){return d.getSeconds();},"E4":function(d,localizer){return Date.fullWeekdayName(d.getDay(),localizer);},"E3":function(d,localizer){return Date.abbreviatedWeekdayName(d.getDay(),localizer);},"a1":function(d,localizer){return(d.getHours()<12)?Date.ampmName(0,localizer):Date.ampmName(1,localizer);}};Date.prototype.stringWithICUDateFormat=function(format,localizer)
{var index=0;var outFormat="";var formatCode="";var formatCount=0;var processingText=false;while(true)
{var ch;if(index>=format.length)
{ch="";}
else
{ch=format.charAt(index++);}
if(ch!=""&&ch==formatCode)
{formatCount++;}
else
{if(formatCode.length>0)
{var formatKey=formatCode+String(formatCount);try
{outFormat+=formatConversion[formatKey](this,localizer);}
catch(e)
{print(e);return"";}
formatCode="";formatCount=0;}
if(ch=="")break;if(processingText)
{if(ch=="'")
{processingText=false;}
else
{if(ch=="\"")
{ch=="'"}
outFormat+=ch;}
continue;}
if("GyMdhHmsSEDFwWakKZ".indexOf(ch)>=0)
{formatCode=ch;formatCount=1;}
else if(ch=="'")
{processingText=true;}
else
{outFormat+=ch;}}}
return outFormat;}
