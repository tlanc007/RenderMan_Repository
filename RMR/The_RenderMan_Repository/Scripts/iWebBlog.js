//
// iWeb - iWebBlog.js
// Copyright 2007 Apple Inc.
// All rights reserved.
//

function BlogRootURLString(inUrlString)
{var urlString=inUrlString.urlStringByDeletingQueryAndFragment();var index=urlString.search(/\/\d{4}\/\d{1,2}\//);if(index!=-1)
{return urlString.substr(0,index).stringByDeletingLastPathComponent();}
return urlString.substr(0,urlString.lastIndexOf("/"));}
function BlogRootURL(inUrlString)
{return new IWURL(BlogRootURLString(inUrlString));}
function BlogFixupPreviousNext()
{var currentUrl=locationHRef().urlStringByDeletingQueryAndFragment();window.blogFeed=new BlogFeed(BlogRootURLString(locationHRef()),window.iWebBlogFeedType,true,function()
{var prevNextLinks=$$(".iWebBlogPrev",".iWebBlogNext");prevNextLinks.each(function(anchor)
{var targetItem=null;if(anchor.className.indexOf("iWebBlogPrev")!=-1)
{targetItem=window.blogFeed.itemBefore(currentUrl);}
else if(anchor.className.indexOf("iWebBlogNext")!=-1)
{targetItem=window.blogFeed.itemAfter(currentUrl);}
if(targetItem)
{anchor.href=targetItem.absoluteURL.toURLString();anchor.title=targetItem.title;}});});}
function BlogPreviousPage()
{var currentUrlString=locationHRef().urlStringByDeletingQueryAndFragment();var targetUrlString=window.blogFeed.itemBefore(currentUrlString);location.href=targetUrlString;}
function BlogNextPage()
{var currentUrlString=locationHRef().urlStringByDeletingQueryAndFragment();var targetUrlString=window.blogFeed.itemAfter(currentUrlString);location.href=targetUrlString;}
function BlogMainPageItem()
{var blogURLString=BlogRootURLString(locationHRef());if(window.iWebBlogMainPageName===undefined)
{window.iWebBlogMainPageTitle=blogURLString.lastPathComponent();window.iWebBlogMainPageName=window.iWebBlogMainPageTitle+".html";}
blogURLString=blogURLString.stringByAppendingPathComponent(window.iWebBlogMainPageName);return{absoluteURL:new IWURL(blogURLString),title:window.iWebBlogMainPageTitle};}
function BlogArchivePageItem()
{var blogURLString=BlogRootURLString(locationHRef());if(window.iWebBlogArchivePageName===undefined)
{window.iWebBlogArchivePageTitle="Archive";window.iWebBlogArchivePageName=window.iWebBlogArchivePageTitle+".html";}
blogURLString=blogURLString.stringByAppendingPathComponent(window.iWebBlogArchivePageName);return{absoluteURL:new IWURL(blogURLString),title:window.iWebBlogArchivePageTitle};}
function BlogFeed(inBlogUrlString,inFeedType,inIsArchive,inCallback)
{this.mBlogURL=new IWURL(inBlogUrlString);this.mFeedType=inFeedType;this.mIsArchive=inIsArchive;var feedUrlString=inIsArchive?"blog-archive.xml":"blog-main.xml";if(this.mFeedType=="dynamic")
{feedUrlString=inBlogUrlString+"?webdav-method=truthget&feedfmt="+(inIsArchive?"blogarchive":"blogsummary");}
else
{feedUrlString=inBlogUrlString.stringByAppendingPathComponent(feedUrlString);}
delete this.mItems;makeXmlHttpRequest(feedUrlString,makeAjaxHandler(function(request,successful)
{if(successful)
{this.p_parseFeed(ajaxGetDocumentElement(request));}
if(inCallback)
{inCallback();}}.bind(this)));}
Object.extend(BlogFeed,{iwebNS:"http://www.apple.com/iweb",getiWebElement:function(itemNode,propertyName)
{return getFirstChildElementByTagNameNS(itemNode,BlogFeed.iwebNS,"iweb",propertyName);},getiWebElementText:function(itemNode,propertyName)
{return getChildElementTextByTagNameNS(itemNode,BlogFeed.iwebNS,"iweb",propertyName);},fixupURL:function(url)
{return url.replace("file://localhost/","file:///");},FeedItem:function(itemNode)
{var child=itemNode.firstChild;while(child)
{if(child.nodeType==Node.ELEMENT_NODE)
{if(child.tagName=='title')
{this.title=getTextFromNode(child);}
else if(child.tagName=='link')
{this.p_linkText=getTextFromNode(child);this.absoluteURL=new IWURL(this.p_linkText);}
else if(child.tagName=='description')
{this.description=getTextFromNode(child);}
else if(child.tagName=='pubDate')
{var dateText=getTextFromNode(child);if(dateText&&dateText.length>0)
this.date=new Date(dateText);}
else if(child.tagName=='iweb:image')
{this.imageUrlString=child.getAttribute("href");this.imageURL=new IWURL(this.imageUrlString);}
else if(child.tagName=='iweb:comment')
{this.commentCount=child.getAttribute("count");this.commentingEnabled=(child.getAttribute("enabled")==1);this.commentURL=new IWURL(child.getAttribute("link"));}}
child=child.nextSibling;}
this.title=this.title||"";this.absoluteURL=this.absoluteURL||new IWURL();this.date=this.date||new Date();this.commentingEnabled=this.commentingEnabled||false;this.commentCount=this.commentCount||0;}});Object.extend(BlogFeed.prototype,{p_parseFeed:function(rssDoc)
{this.mDateFormat="EEEE, MMMM d, yyyy";this.mBaseURL=new IWURL();this.mMaximumSummaryItems=10;this.mItems=[];var channel=rssDoc.getElementsByTagName("channel")[0];var dateFormat=BlogFeed.getiWebElementText(channel,"dateFormat");var maximumSummaryItems=BlogFeed.getiWebElementText(channel,"maximumSummaryItems");var baseURLString=BlogFeed.getiWebElementText(channel,"baseURL");if(dateFormat)
this.mDateFormat=dateFormat;if(maximumSummaryItems)
this.mMaximumSummaryItems=maximumSummaryItems;if(baseURLString)
{this.mBaseURL=new IWURL(baseURLString);}
var itemNodes=rssDoc.getElementsByTagName("item");for(var i=0;i<itemNodes.length;++i)
{var itemNode=itemNodes[i];var item;try
{item=new BlogFeed.FeedItem(itemNode);if(this.mBaseURL)
{item.relativeURL=item.absoluteURL.relativize(this.mBaseURL);item.absoluteURL=item.relativeURL.resolve(this.mBlogURL);if(item.commentURL)
{item.relativeCommentURL=item.commentURL.relativize(this.mBaseURL);}}
this.mItems.push(item);}
catch(e)
{debugPrintException(e);}}},itemCount:function()
{if(this.mItems===undefined)
return 0;return this.mItems.length;},itemAtIndex:function(index)
{return this.mItems[index];},dateFormat:function()
{return this.mDateFormat;},maximumItemsToDisplay:function()
{var result=this.itemCount();if(!this.mIsArchive&&(this.mMaximumSummaryItems>0)&&(this.mMaximumSummaryItems<result))
{result=this.mMaximumSummaryItems;}
return result;},dumpFeed:function()
{print("dumping a %s feed with %s items",this.mFeedType,this.itemCount());for(var i=0;i<this.itemCount();++i)
{printObject(this.itemAtIndex(i));}},itemAfter:function(urlString)
{var afterIndex=null;var url=new IWURL(urlString);for(var i=0;i<this.mItems.length;++i)
{if(url.isEqual(this.mItems[i].absoluteURL))
{afterIndex=i-1;break;}}
if(afterIndex<0)
return BlogArchivePageItem();else
return this.mItems[afterIndex];},itemBefore:function(urlString)
{var beforeIndex=null;var url=new IWURL(urlString);for(var i=0;i<this.mItems.length;++i)
{if(url.isEqual(this.mItems[i].absoluteURL))
{beforeIndex=i+1;break;}}
if(beforeIndex<this.mItems.length)
return this.mItems[beforeIndex];else
return BlogMainPageItem();}});function iWebInitSearch()
{try
{setLocale();initSearch();}
catch(e)
{}}
function dynamicallyPopulate()
{var contentXml=getContentXmlURL();if(contentXml==null)
{var baseUrl=String(this.location).urlStringByDeletingQueryAndFragment();contentXml=String(baseUrl).replace(/\.html$/,'.xml');}
var populateDomWithContentFromXML=function(request,successful)
{if(successful)
{var contentDoc=ajaxGetDocumentElement(request);var textBoxes=contentDoc.getElementsByTagName('textBox');for(var i=0;i<textBoxes.length;i++)
{dynamicallyPopulateTextBox(textBoxes[i]);}
var images=contentDoc.getElementsByTagName('image');for(var i=0;i<images.length;i++)
{dynamicallyPopulateImage(images[i]);}}};makeXmlHttpRequest(contentXml,makeAjaxHandler(populateDomWithContentFromXML));}
function dynamicallyPopulateTextBox(textBoxElement)
{if(textBoxElement)
{var id=textBoxElement.getAttribute('id');var htmlElement=document.getElementById(id);if(htmlElement)
{var htmlParent=htmlElement.parentNode;if(textBoxElement.getAttribute('visible')=='yes')
{if(textBoxElement.getAttribute('dynamic')=='yes')
{var content=String(getChildElementTextByTagName(textBoxElement,'richText'));htmlElement.innerHTML=content;htmlParent.innerHTML=htmlElement.outerHTML;}
htmlParent.style.visibility='visible';}}}}
function dynamicallyPopulateImage(imageElement)
{if(imageElement)
{var id=imageElement.getAttribute('id');var htmlElement=document.getElementById(id);if(htmlElement)
{if(imageElement.getAttribute('visible')=='yes')
{if(imageElement.getAttribute('dynamic')=='yes')
{htmlElement.src=imageElement.getAttribute('src');htmlElement.style.left=imageElement.getAttribute('left');htmlElement.style.top=imageElement.getAttribute('top');htmlElement.style.width=imageElement.getAttribute('width');htmlElement.style.height=imageElement.getAttribute('height');}
htmlElement.style.visibility='visible';}}}}
function getContentXmlURL()
{var url=null;var query=window.location.search;if(query)
{if(query.match(/[&\+\?]content=([^&\+]*)/))
{url=RegExp.$1;}}
return url;}
