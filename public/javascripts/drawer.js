/* MAIN VARIABLES NEEDED */
var mainElem; // Element that will contain child nodes
var container; // Div that wraps the elements
var svgns = "http://www.w3.org/2000/svg";
var svg = true; // True if NOT Internet Explorer

var reload = 0 // To force reloading :\

if (navigator.appName == "Microsoft Internet Explorer") svg = false;

/********************************/
/****** DRAWING MODULE **********/
/********************************/
/* HELPING VARIABLES */
var drawing, erasing, texting;
var x, y, tmpX, tmpY; // Save original coords in some tools
var refX, refY; 	// Help positioning the mouse in relation to the screen
var tool = "line"; 	// What tool is selected?
var current; // current element
var color = "blue";
var thick = "2";
var fill = "80";
var prohibed = new Array("top","tools","pages","fill-dialog","thick-dialog"); 
/* Three big events. From here everything's controlled. */
function mouseDown(e){
	if(!e) e = window.event;
	if(svg)	if(prohibed.indexOf(e.target.id) != -1) return;
 	if(!svg) if(e.target.id!="vmlElem") return;	
    drawing = true;
    refX = container.offsetLeft;
    refY = container.offsetTop;
    x = currPositionX(e);
    y = currPositionY(e);
    cPX = x;
    cPY = y;
    switch (tool) {
        case "line":
            current = new Line(mainElem,x, y, x, y, color, thick, fill);
            break;
        case "pencil":
			current = new Pencil(mainElem,"", color, thick, fill);
			current.addPoint(x,y);
            break;
        case "square":
			current = new Square(mainElem,x,y,1,1,color,thick,fill);
            break;
        case "circle":
			current = new Circle(mainElem,x,y,1,1,color,thick,fill);
            break;
        case "eraser":
            erasing=true;
            break;
        case "image":
            current = new Image(mainElem,x,y,"test.jpg",1);
            break;
    }
	if(svg) e.stopPropagation();
	//e.cancelBubble=true;
}

function mouseMove(e){
	if(!e) e = window.event;
	if(!svg && drawing && e.button != 1) // Means we mouseUp'd outside the window.
		mouseUp(e);	// We "force" the mouseUp.
    refX = container.offsetLeft;
    refY = container.offsetTop;
    cPX = currPositionX(e);
    cPY = currPositionY(e);
    // Only want to do stuff when we are pressing the mouse button.
    if (drawing) {
        switch (tool) {
            case "line":
				// We've got x and y saved from before
                current.edit(x, y, cPX, cPY);
                break;
			case "pencil":
                current.addPoint(cPX, cPY);
                break;
            case "square":
				var nX,nY;
			    if (x <= cPX) nX = x;
			    else if (x > cPX) nX = cPX;
			    if (y <= cPY) nY = y;
			    else if (y > cPY) nY = cPY;
				current.edit(nX,nY,Math.abs(cPX - x),Math.abs(cPY - y));
                break;
            case "circle":
				var nX,nY;
				if(cPX <= x) nX = (cPX + (x-cPX)/2);
				else if(cPX > x) nX = (x + (cPX-x)/2);
				if(cPY <= y) nY = (cPY + (y-cPY)/2);
				else if(cPY > y) nY = (y + (cPY-y)/2);
                current.edit(nX,nY,Math.abs(x-nX),Math.abs(y-nY));
				break;
			case "eraser":
				if(erasing){
					if (!svg && e.srcElement.parentElement.id == "vmlElem") {
						remove(e.srcElement.id);
						e.srcElement.parentElement.removeChild(e.srcElement);
					} else if (parseInt(e.target.id)) {
						remove(e.target.id);
						e.target.parentNode.removeChild(e.target);
					}
				}
        }
    }
	if (tool != "text" && e.target.id != "fill-dialog" && e.target.id != "thick-dialog") e.stopPropagation();

}

function mouseUp(e){
	if(!e) e = window.event;
	
    refX = container.offsetLeft;
    refY = container.offsetTop;
    cPX = currPositionX(e);
    cPY = currPositionY(e);
    drawing = false;
    switch (tool) {
        case "eraser":
            erasing=false;
            break;
        case "text":
            upText(e);
            break;
    }
	if(current != null) save(current);
	current = null;
}

/* When creating text a little more juice is needed, so there's an
 * auxiliary function.
 * We create a new input where we click, to whom we attach the event
 * onChange, that will pop when the user is done writing.
 */
function upText(e){
    if (texting) {
		texting = false;
        var txt = document.createElement("textarea");
        txt.setAttribute("rows", "6");
		txt.setAttribute("cols", "20");
        txt.setAttribute("class", "drawingText");
        txt.style.position = "absolute";
        txt.style.top = currPositionY(e) + "px";
        txt.style.left = currPositionX(e) + "px";
        tmpX = currPositionX(e);
        tmpY = currPositionY(e);
        container.appendChild(txt);
		if (!$.browser.safari) $(txt).resizable();
		$(txt).focus();
		
		// Auxiliary function that will pop whenever the input thinks
		// the user has finished. It controls if something is written,
		// and acts accordingly.
		var tf = function(e){
			if(txt.value != ""){
				var tmp = txt.value.replace(/(\r\n)|(\n)/g,"<br />");
				tx = new Text(container,tmpX,tmpY,tmp,color,"30","","0");
				save(tx);
			} 
			$(txt).remove();
		}
		// Attach the function to proper events
		$(txt).bind("change",tf);
		// This helps for explorer since it doesn't pop the onChange
		// even when we press intro.
		if(!svg) $(txt).bind("keydown",function(e){
			if (window.event.keyCode == 13) tf(e);
			});
    }
}

/********************************/
/****** RENDERING MODULE ********/
/********************************/


/* LINE CLASS
 * x1,y1: Coords of the start of the line
 * x2,y2: Coords of the end of the line
 * color: of the stroke
 * thick: ness of the stroke
 * fill: transparency of the stroke
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Line(here,x1, y1, x2, y2, color, thick, fill){
	this.x1=x1;this.y1=y1;this.x2=x2;this.y2=y2;
	this.color=color;this.thick=thick;this.fill=fill;
	this.type="line";
    if (svg) {
        
		this.element = document.createElementNS(svgns, "line");
		//Define attributes needed.
        $(this.element).attr("style", "fill: none;stroke: " + color +
        ";stroke-width: " + thick + ";stroke-opacity: " + fill + ";" + 
		"width:100%;height:100%;");
        //$(this.element).attr({"x1": x1,"x2": x2,"y1": y1, "y2": y2});
		this.element.setAttribute("x1",x1);
		this.element.setAttribute("y1",y1);
		this.element.setAttribute("x2",x2);
		this.element.setAttribute("y2",y2);
		//And finally append
		here.appendChild(this.element);
		
		//Move function to change the line.
		this.edit = function(x1,y1,x2,y2){
			this.element.setAttribute("x1",x1);
			this.element.setAttribute("y1",y1);
			this.element.setAttribute("x2",x2);
			this.element.setAttribute("y2",y2);
			this.x1=x1;this.y1=y1;this.x2=x2;this.y2=y2;
		}
		
    } else {
		
        this.element = document.createElement("v:line");
        //Define attributes
		$(this.element).attr({
            from: x1 + "," + y1,
            to: x2 + "," + y2
        });
		this.st = document.createElement("v:stroke");
        $(this.st).attr({
            color: color,
            weight: thick,
            opacity: fill
        });
		
		//Append where necessary
		here.appendChild(this.element);
		this.element.appendChild(this.st);
        
		//Move function to change the line.
		this.edit = function(x1,y1,x2,y2){
			$(this.element).attr({
            from: "" + x1 + "," + y1,
            to: "" + x2 + "," + y2
        	});
			this.x1=x1;this.y1=y1;this.x2=x2;this.y2=y2;
		}
		
    }
}

/* PENCIL CLASS
 * points: string with the list of coords.
 * color: of the stroke
 * thick: ness of the stroke
 * fill: transparency of the stroke
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Pencil(here,points, color, thick, fill){
	this.points=points;
	this.color=color;this.thick=thick;this.fill=fill;
	this.type = "pencil";
    if (svg) {
		
        this.element = document.createElementNS(svgns, "polyline");
		//Define attributes
        this.element.setAttribute("points", points);
        this.element.setAttribute("style", "fill:none; stroke:" + color +
        "; stroke-width:" + thick + ";stroke-opacity:" + fill + ";");
		//And append
		here.appendChild(this.element);
		
		//Function to add a new point to the polyline
		this.addPoint = function(x,y){
			this.points=this.points + " " + x + "," + y;
			this.element.setAttribute("points",this.points);
		}
		
    } else {
		
        this.element = document.createElement("v:polyline");
		//Define attributes
        $(this.element).attr("filled", "False");
        this.element.setAttribute("points",points);
		//And the stroke
        this.st = document.createElement("v:stroke");
        $(this.st).attr({
            color: color,
            weight: thick,
            opacity: fill
        });
		//Append both
		here.appendChild(this.element);
		this.element.appendChild(this.st);
		
		//Function to add a new point to the polyline
		this.addPoint = function(x,y) {
			this.points = this.points + " " + x + "," + y;
			this.element.points.value = this.points;
		}
    }
}


/* SQUARE CLASS
 * x,y: Coords of the start of the square
 * width,height: Width and height of the square
 * color: of the stroke
 * thick: ness of the stroke
 * fill: transparency of the filling
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Square(here,x, y, w, h, color, thick, fill){
	this.x = x;this.y = y;
	this.width = w;this.height = h;
	this.color = color;this.thick = thick;this.fill = fill;
	this.type = "square";
	
	if (svg) {
		
		this.element = document.createElementNS(svgns, "rect");
		//Define attributes
		this.element.setAttribute("x", x);
		this.element.setAttribute("y", y);
		this.element.setAttribute("height", h);
		this.element.setAttribute("width", w);
		this.element.setAttribute("style", "stroke:" + color +
		"; stroke-width:" +	thick + ";stroke-opacity:" + fill + ";fill:white;fill-opacity:0.4;");
		//Append
		here.appendChild(this.element);
		
		//Function to edit the square
		this.edit = function(x,y,w,h){
			this.x=x;this.y=y;this.width=w;this.height=h;
			this.element.setAttribute("x", x);
	        this.element.setAttribute("y", y);
	        this.element.setAttribute("height", h);
	        this.element.setAttribute("width", w);
		}
	} else {
		
		this.element = document.createElement("v:rect");
		//Define attributes
		this.element.style.left = x;
		this.element.style.top = y;
		this.element.style.height = h;
		this.element.style.width = w;
		this.element.style.position = "absolute";
		
		this.st = document.createElement("v:stroke");
        $(this.st).attr({
            color: color,
            weight: thick,
            opacity: fill
        });
		
		//Fill element needed
		this.fl = document.createElement("v:fill");
		this.fl.color = "white";
		this.fl.opacity = 0.4;
		
		//Append everything
		here.appendChild(this.element);
		this.element.appendChild(this.st);
		this.element.appendChild(this.fl);
		
		//Edit function 
		this.edit = function(x,y,w,h){
			this.x=x;this.y=y;this.width=w;this.height=h;
			this.element.style.left = x;
	        this.element.style.top = y;
	        this.element.style.height = h;
	        this.element.style.width = w;
		}
	}
}


/* CIRCLE CLASS
 * x,y: Coords of the center of the square
 * rx,ry: Vertican and horizontal radius
 * color: of the stroke
 * thick: ness of the stroke
 * fill: transparency of the filling
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Circle(here,cx,cy,rx,ry,color,thick,fill){
	this.x=cx,this.y=cy;this.rx=rx;this.ry=ry;
	this.color=color;this.thick=thick;this.fill=fill;
	this.type = "circle";
	if(svg){
	
        this.element = document.createElementNS(svgns, "ellipse");
		//Set attributes
        this.element.setAttribute("rx", rx);
        this.element.setAttribute("ry", ry);
        this.element.setAttribute("cx", cx);
        this.element.setAttribute("cy", cy);
        this.element.setAttribute("style", "stroke:" + color + 
		"; stroke-width:" + thick + ";stroke-opacity:" + fill + ";fill:white;fill-opacity:0.4;");
		//append
		here.appendChild(this.element);
		
		//Edit function
		this.edit = function(cx,cy,rx,ry) {
			this.x=cx,this.y=cy;this.rx=rx;this.ry=ry;
			this.element.setAttribute("rx", rx);
	        this.element.setAttribute("ry", ry);
	        this.element.setAttribute("cx", cx);
	        this.element.setAttribute("cy", cy);
		}
	} else {
		
		this.element = document.createElement("v:oval");
		//Set attributes
		//In VML we need height and width, not radius
        this.element.style.width = rx*2;
        this.element.style.height = ry*2;
        this.element.style.position = "absolute";
        this.element.style.left = cx-rx;
        this.element.style.top = cy-ry;
        this.element.setAttribute("shape", "circle");
        
		this.st = document.createElement("v:stroke");
        $(this.st).attr({
            color: color,
            weight: thick,
            opacity: fill
        });

		//Fill element is needed
        this.fl = document.createElement("v:fill");
		this.fl.color = "white";
        this.fl.opacity = 0.4; 
		
		//Append
		here.appendChild(this.element);
		this.element.appendChild(this.st);
		this.element.appendChild(this.fl);
		
		//Edit function
		this.edit = function(cx,cy,rx,ry){
			this.x=cx,this.y=cy;this.rx=rx;this.ry=ry;
			this.element.style.width = rx*2;
	        this.element.style.height = ry*2;
	        this.element.style.left = cx-rx;
	        this.element.style.top = cy-ry;
		}
	}
}

/* TEXT CLASS
 * x,y: Coords of origin of the textbox
 * text: string of text represented
 * color: of the text
 * size: font size of the text
 * font: font of the text
 * fill: transparency of the filling
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Text(here,x,y,text,color,size,font,fill){
	this.x=x;this.y=y;this.text=text;
	this.color=color;this.size=size;this.fill=fill;
	this.type="text";
	if(font=="") this.font=font;
	else this.font="Courier";
	
	this.element = document.createElement("div");
	$(this.element).html(text);
	this.element.style.top = y + "px";
	this.element.style.left = x + "px";
	this.element.style.fontFamily = "Verdana";
	this.element.style.fontSize  ="1.3em";
	this.element.style.zIndex = 200;
	this.element.style.position = "absolute";
	
	this.element.style.border="1px solid black";
	this.element.style.margin="0px";
	this.element.style.padding="0px";
	
	container.appendChild(this.element);
}

/* IMAGE CLASS
 * x,y: Coords of origin of the image
 * img: path to the image
 * scale: scalation that should be applied to the image
 * element: javascript node element
 * * * * * * * * * * * * * * * * * * * * * */
function Image(here,x,y,img,scale){
	this.x=x;this.y=y;this.img=img;this.scale=scale;
	this.type = "image";
	if(svg){
		this.element = document.createElementNS(svgns, "image");
        this.element.setAttribute("x", x);
        this.element.setAttribute("y", y);
        // FALTA ESTO
		this.element.setAttribute("width", 400 + "px");
        this.element.setAttribute("height", 500 + "px");
        this.element.setAttribute("xlink:href", img);
		here.appendChild(this.element);
	} else {
		this.element = document.createElement("v:image");
        this.element.src = img;
        this.element.style.position = "absolute";
        this.element.style.top = y;
        this.element.style.left = x;
		// CAMBIAR ESTO POR LO QUE TOQUE
        this.element.style.width = 400;
        this.element.style.height = 500;
	}
}


/********************************/
/***** COMMUNICATION MODULE *****/
/********************************/
var delay = 2500;	// Delay between update requests.
var reloads = 0;	// Counter to ask for everything every number of times

/* We will save the newly created element through ajax.
 * The parameter 'it' is an object we'll convert into
 * a JSON compatible string.
 * The url that we visit to add a new element is:
 * /doc/:documentID/:pageNumber/add
 * The JSON'd string is passed through GET typical way.
 */
function save(it){
	var text = toJSON(it);
	$.ajaxQueue({
		type: "GET",
		url: "/document/add_element/" + docId,
		data: {attr: text},
		success: function(ret){
			it.element.id=ret;
		}
	});
}

/* This function will be executed constantly, with a delay of "delay"
 * miliseconds between when a request finishes and the next is done.
 * TODO: Who takes care of discarding already-known stuff
 * The url to  request new data is:
 * /doc/:documentID/:pageNumber/list
 */
function consult(repeat){
	$.ajaxQueue({
		type: "GET",
		url: "/document/list_elements/" + docId + "?reload=" + (reload++),
		success: load,
		complete: function(){
			if(repeat) setTimeout("consult(true);",delay);
		}
	});
}

/* This function receives the JSON compatible data
 * provided after consulting the server. It iterates
 * through it and adds the new elements.
 */
function load(content){
	var t = eval("(" + content + ")");	// Convert JSON compatible data into actual data.
	// Load the good background
	bg = t.background;
		$(container).css("background","white url(\"/image/" + pageId + "\") no-repeat 100px 100px");
		if(svg) $(mainElem).css("background-color","transparent");
	
	// Change page number if needed
	change_page_to(t);

	// Change users list
	var users = "";
	for (u in t.users) users = users + t.users[u] + " ";
	for (u in t.anonymous) users = users + t.anonymous[u] + " ";
	$("#users").text(users);
	
	if(t.elements.length>0){	// It's a way to see if some data has been returned.
		var i;
		
		// First loop. Check if the elements are already loaded.
		for (i in t.elements){
			var tmp = document.getElementById(t.elements[i].id);
			if(tmp) tmp.id += " ok";
			else {
				//console.log("Voy a cagar un algo: " + t.elements[i].id )
				var e = eval("(" + t.elements[i].attr + ")");
				//console.log(e)
				var tp;
				switch (e.type) {
			        case "line":   
						tp = new Line(mainElem,e.x1, e.y1, e.x2, e.y2, e.color, e.thick, e.fill);
						break;
			        case "pencil":
						tp = new Pencil(mainElem,e.points, e.color, e.thick, e.fill);
			            break;
			        case "square":
						tp = new Square(mainElem,e.x,e.y,e.width,e.height, e.color, e.thick, e.fill);
			            break;
			        case "circle":
						tp = new Circle(mainElem,e.x,e.y,e.rx,e.ry, e.color, e.thick, e.fill);
			            break;
					case "text":
						tp = new Text(mainElem,e.x,e.y,e.text,e.color,e.size,e.font,e.fill);
			    }
				tp.element.id = t.elements[i].id + " ok";
			}
		}
	}
	// Second Loop. Remove the ones that are no longer needed.
	var nodes = mainElem.childNodes;
	var i = 0;
	for(i=nodes.length;i--;i<0) check(nodes[i],mainElem);
	if(svg) {
		nodes = container.childNodes;
		for(i=nodes.length;i--;i<0) check(nodes[i],container);
	}
			
}

function check(node,parent){
	if (node.id && node.id != "svgElem") {
		var tmpId = node.id.split(' ');
		if (tmpId[1] == "ok") node.id = tmpId[0];
		else parent.removeChild(node);
	}
}

/* Function to tell the system to remove the elemtn from
 * the DB. It's done through ajax:
 * URL: /element/remove/:id
 */
function remove(id){
	$.ajax({
		type: "GET",
		url: "/document/remove_element/" + id
		});
}


/* Functions to change pages
 * previousPage
 * nextPage
 * reloadStuff
 */
function change_page_to(t){
	if(t.page_num != pageNum) $("#pages input").val(t.page_num);
	pageNum = t.page_num;
	pageId = t.page_id;
	if(t.page_num == 1){ $("#prev").hide();$("#next").show(); }
	else if(t.page_num == pages) { $("#prev").show();$("#next").hide(); }
	else { $("#prev").show();$("#next").show(); }
}
function previousPage() { 	changePage(--pageNum); }
function nextPage(){ 		changePage(++pageNum); }
function changePage(num){
	// Tell the server
	$.ajaxQueue({
		type: "GET",
		data: {page: num},
		url: "/document/change_page/" + docId,
		success: function(ret){
			if(ret == "0") $("#pages input").val(pageNum);
			else {
				pageId = ret;	
				consult(false);
				$("#pages input").val(num + "");
			}
		}
	});
	
}

function toJSON(element){
	var out = "{";
	out += jsonSimple(element,["type","color","fill"]);
	
	//Now the type-dependant
	switch(element.type){
		case "line":
			out += jsonSimple(element,["thick","x1","x2","y1","y2"]);break;
		case "pencil":
			out += jsonSimple(element,["thick","points"]);break;
		case "square":
			out += jsonSimple(element,["thick","x","y","width","height"]);break;
		case "circle":
			out += jsonSimple(element,["thick","x","y","rx","ry"]);break;
		case "text":
			out += jsonSimple(element,["font","size","text","x","y"]);sbreak;
	}
	//Remove the last comma
	out = out.substring(0,out.length-1);
	out += "}";
	return out;
}

function jsonSimple(obj,atts){
	var out = "";
	for (i in atts) {
		out += '"' + atts[i] + '":"' + obj[atts[i]] + '",';
	}
	return out
}

/* INITIAL FUNCTION */
$(document).ready(function(){
    texting = true;

	// Attach events where needed
	if (svg) {
		$("#protectiveLayer").bind("mousedown", mouseDown);
		$("#protectiveLayer").bind("mousemove", mouseMove);
		$("#protectiveLayer").bind("mouseup",   mouseUp);
	} else {
		$("#vmlElem").bind("mousedown", mouseDown);
		$("#vmlElem").bind("mousemove", mouseMove);
		$("#vmlElem").bind("mouseup",   mouseUp);
	}
	
	// Set the appropiate variables
    if (svg) {
        mainElem = document.getElementById("svgElem");
        container = document.getElementById("protectiveLayer");
    }
    else {
        mainElem = document.getElementById("vmlElem");
        container = mainElem;
    }
	
	// Define the add function
	mainElem.add = function(something) {
		var temp = something.element;
		this.appendChild(temp);
	}
	
	// To start the endless requests for new info
	consult(true);
	
	// Adding tooltips
	$('#pencil').tooltip({text: 'Use this to draw freely like a <strong>pencil</strong>'});
	$('#line').tooltip(  {text: 'Draw straight <strong>line</strong>s'});
	$('#square').tooltip({text: 'Draw <strong>rectangle</strong>s'});
	$('#circle').tooltip({text: 'Draw <strong>circle</strong>s'});
	$('#eraser').tooltip({text: 'This is the <strong>eraser</strong> tool.<br />Click over elements to remove them.'});
	$('#text').tooltip(  {text: 'Click somwhere to start writing.<br /><span>Tip: press tab once you\'re done.</span>'});
	
	$('#color').tooltip( {text: 'Select the <strong>color</strong> to draw with.<br /><span>Tip. click here to spawn the dialog</span>'});
	$('#fill').tooltip(  {text: 'Select the <strong>transparency</strong> of your drawings.<br /><span>Tip. click here to spawn the dialog</span>'});
	$('#thick').tooltip( {text: 'Select the <strong>thickness</strong> of your lines.<br /><span>Tip. click here to spawn the dialog</span>'});
	
	//Creating sliders
	$("#fill-dialog").slider({min: 0, max:100, startValue: 80, change: function(e,ui){
		fill = (ui.value/100);
		$("#fill").html(ui.value);
	}, stop: function(e,ui){
		toggle("fill");
	}});
	
	$("#thick-dialog").slider({min:1, max:15,  startValue: 3, change: function(e,ui){
		thick= ui.value;
		$("#thick").html(ui.value);
	}, stop: function(e,ui){
		toggle("thick");
	}});
	
	$("#pages input").bind("change blur",function(e){
		var v = parseInt(this.value);
		if(v) changePage(v);
		else $("#pages input").val(pageNum + "");
	});
	
});

/* AUXILIARY FUNCTIONS*/
function selectTool(inputTool){
    tool = inputTool;
    if (tool == "text") texting = true;
	$("#tools div").removeClass("selected");
	$("#tools div#" + inputTool).addClass("selected");	
}

function currPositionX(e){
    if(svg) return e.clientX - refX + window.pageXOffset;
	else return e.clientX - refX + document.body.scrollLeft;
}

function currPositionY(e){
	if(svg) return e.clientY - refY + window.pageYOffset;
	else return e.clientY - refY + document.body.scrollTop;
}

function chivato(Text){
    var cv = document.getElementById("chivato");
    cv.innerHTML = cv.innerHTML + Text;
}

function toggle(what){
	pck = document.getElementById(what + "-dialog");
	if (pck.style.display=="none") pck.style.display="block";
	else pck.style.display="none";
}

function selectColor(value){
	color = value;
	toggle("color");
}


/* jQuery Plugin for ajax requests queues.
 * Homepage: http://jquery.com/plugins/project/ajaxqueue
 * Documentation: http://docs.jquery.com/AjaxQueue
 * A new Ajax request won't be started until the previous queued 
 * request has finished.
 * * * * * * * * * * * * * * * * * */
jQuery.ajaxQueue = function(o){
	var _old = o.complete;
	o.complete = function(){
		if ( _old ) _old.apply( this, arguments );
		jQuery([ jQuery.ajaxQueue ]).dequeue( "ajax" );
	};
	jQuery([ jQuery.ajaxQueue ]).queue("ajax", function(){
		jQuery.ajax( o );
	});
};
