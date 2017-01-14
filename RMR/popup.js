

//
//
//	Windows-like Popup boxes
//	v0.1
//
//


// If you choose to copy this, please leave the following:
// Written S.Lee, 1999



// helpmsg constructor

function helpmsg(header, hstyle, message, mstyle) {
	this.DEFAULTHSTYLE = "plain";
	this.DEFAULTMSTYLE = "plain";

	this.header = header;
	if (hstyle)
		this.hstyle = hstyle;
	else
		this.hstyle = this.DEFAULTHSTYLE;
	this.message = message;
	if (mstyle)
		this.mstyle = mstyle;
	else
		this.mstyle = this.DEFAULTMSTYLE;
	return this;
}

new helpmsg();
helpmsg.prototype.show = show;

function show() {
	// Construct header
	var H = "<FONT FACE='arial'>" + this.header + "</FONT>";
	if (this.hstyle == "header1")
		H = "<H1>" + H + "</H1>";
	else if (this.hstyle == "header2")
		H = "<H2>" + H + "</H2>";
	else if (this.hstyle == "header3")
		H = "<H3>" + H + "</H3>";
	else if (this.hstyle == "header4")
		H = "<H4>" + H + "</H4>";
	if (this.hstyle == "fancyheader1")
		H = "<table width='75%'>" +
			"<tr><td bgcolor='#6060ff' align='center' valign='center'>" +
			"<H1><FONT COLOR='white'>" +
			H +
			"</FONT></H1>" +
			"</td></tr></table>";
	else if (this.hstyle == "italics")
		H = "<I>" + H + "</I>";

	var M = "<FONT FACE='arial'>" + this.message + "</FONT>";
	// Construct message
	if (this.mstyle == "plain") {
	}
	else if (this.mstyle == "bold")
		M = M.bold();

	var htmlpage = "";
	if (this.hstyle.indexOf("header")>=0)
		htmlpage = H + M;
	else
		htmlpage = H + "<BR>" + M;
	return htmlpage;
}


// helpbox constructor

function helpbox(name, hm, width, height, bgcolor) {

	this.name = name;
	this.helpmessage = hm;		// hm is an array of helpmsg

	// Implementation attributes

	this.timerHandle = null;
	this.windowHandle = null;

	this.DEFAULTWIDTH = 250;
	this.DEFAULTHEIGHT = 150;
	this.DEFAULTBGCOLOR = "#ffffcc";
	this.POPUPDELAY = 100;

	if (width)
		this.width = width;
	else
		this.width = this.DEFAULTWIDTH;
	if (height)
		this.height = height;
	else
		this.height = this.DEFAULTHEIGHT;
	if (bgcolor)
		this.bgcolor = bgcolor;
	else
		this.bgcolor = this.DEFAULTBGCOLOR;

	return this;
}


// define methods

function startHelp(msgindex) {
	    var cmdstr="top." + this.name + ".showHelp('" + msgindex + "')";
	    this.timerHandle = setTimeout(cmdstr, this.POPUPDELAY);
}

function showHelp(msgindex) {
	if (!this.windowHandle || !this.windowHandle.name || this.windowHandle.name=="")
		this.windowHandle = window.open(
			"", 
			"subWindow", 
			"toolbar=no," +
			"location=no," +
			"directories=no," +
			"status=no," +
			"menubar=no," +
			"scrollbars=auto," +
			"resizable=no," +
			"width=" + this.width + "," +
			"height=" + this.height
			);
	else
		this.windowHandle.focus();

	this.windowHandle.document.open();
	var to_page =
		"<HTML>\n" +
		"<BODY BGCOLOR='" + this.bgcolor + "'><P>" +
		this.helpmessage[msgindex].show() +
		"</BODY></HTML>\n";
	this.windowHandle.document.write(to_page);
	this.windowHandle.document.close();
}

function clearHelp() {
	clearTimeout(this.timerHandle);
	if (this.windowHandle && this.windowHandle.name) {
		this.windowHandle.close();
		this.windowHandle=null;
	}
}

new helpbox();
helpbox.prototype.startHelp = startHelp;
helpbox.prototype.showHelp = showHelp;
helpbox.prototype.clearHelp = clearHelp;


