/*
 * Tooltip - jQuery plugin for simple tooltip showing over HTML elements
 * Revision 0.7b
 *
 * Copyright (c) 2008 Berny Cantos a.k.a. xPheRe
 *
 * Licensed under the GPL license:
 *   http://www.gnu.org/licenses/gpl.html
 */

;(function($){

	$.tooltip = {
		/* Default tooltip settings */
		defaults: {
			'class': 'tooltip',			// Tooltip class added to destiny HTML element
			css: {},					// CSS applied to destiny HTML element
			event: 'mouseover',			// Event the tooltip must respond to
			smart: false,				// If the tooltip content is generated in a 'smart' way
			track: true,				// If the tooltip must follow mouse position
			offset: {x: 12, y: 18}		// Offset from current mouse position, only applied if track set to true
		},

		/* 
		 * Shortcut to setup default settings
		 * Example:
		 *		$.tooltip.setup({event: 'click', track: 'false'});
		 */
		setup: function(opt){ $.extend($.tooltip.defaults, opt) }
	}

	/* The TIP object */
	var tip = function(src, opt) {
		var self = this;
		var html = '';
		src = $(src);
		/* Use metadata plugin (if loaded) to modify local options */
		if($.metadata) { opt = $.extend({}, opt, src.metadata().tooltip) }

		/* Tries to generate the content from the HTML element attributes */
		if(opt.smart) {
			/* Tooltip title from 'title' attribute */
			if(!opt.title){ opt.title = src.attr('title') }
			/* Tooltip text from 'alt' attribute */
			if(!opt.text){ opt.text = src.attr('alt') }
			/* url from 'href' attributes. Great for link tags */
			if(!opt.href){ opt.href = src.attr('href') }
		}

		/* Generates HTML content */
		var html = '';
		if(opt.title) { html += '<div class="title">'+opt.title+'</div>' }
		if(opt.text) { html += '<div class="text">'+opt.text+'</div>' }
		if(opt.href) { html += '<div class="url">'+opt.href+'</div>' }
		/* If no content where generated, no tooltip is created */
		if(html == ''){ delete this; return }
		
		/* Removes attributes disabling default tooltips from the browser */
		src
			.removeAttr('title')
			.removeAttr('alt')

		$.data(src, 'tooltip', self)
		self.dst = opt.dst;

		src
			.bind(opt.event+'.tooltip', over)
			.bind('mouseout.tooltip', out)
			.bind('focus.tooltip', over)
			.bind('blur.tooltip', out)
			.bind('click.tooltip', hide)

		/* Destroy existent timers */
		function destroy_timers() {
			if(self.timein){
				clearTimeout(self.timein);
				delete self.timein
			}
			if(self.timeout){
				clearTimeout(self.timeout);
				delete self.timeout
			}
		}

		
		/* Called when the 'show tooltip' event is raised */
		function over(ev){
			destroy_timers();
			if(self.st == out){ return }
			self.st = over;
			/* No destiny defined, must create a new HTML element */
			if(!self.dst) {
				self.dst = document.createElement("div");
				document.body.appendChild(self.dst);
				self.dst.style.visibility = "hidden";
			/*	self.dst = $('<div>')
					.appendTo(document.body)
					.css({visibility:'hidden'}) */
			}
			self.ev = ev;
			/* Wait some time and show the tooltip */
			self.timein = setTimeout(show, opt['in'] || 0)
		}

		/* Shows the tooltip */
		function show(){
			destroy_timers();
			/* No destiny, no showing */
			if(!self.dst) { return }
			/* Modifies tooltip CSS and content */
			$(self.dst)
				.addClass(opt['class'])
				.css(opt.css)
				.html(html);
			/* If a duration is defined */
			if(opt.duration > 0) {
				self.timein = setTimeout(hide, opt.duration)
			}
			/* Keep track of mouse position if 'track' is activated */
			if(opt.track) {
				$(self.dst)
					.css({
						position:'absolute',
						visibility:'visible'
					})
				src
					.bind('mousemove.tooltip', move);
				$('body')
					.bind('click.tooltip', hide)
			}
			/* Calculates width and height */
			self.w = $(self.dst).width();
			self.h = $(self.dst).height();
			/* 'on show' callback */
			if(opt.onshow){ opt.onshow.apply(self.dst) }
			if(opt.track){ move() }
		}

		/* Called when the tooltip must hide */
		function out(){
			destroy_timers();
			if(self.st != over){ return }
			/* Wait some time and hides the tooltip */
			self.timeout = setTimeout(hide, opt['out'] || 0)
		}

		/* Hides the tooltip */
		function hide() {
			destroy_timers();
			/* Unbind all events in body from the tooltip namespace */
			$('body').unbind('.tooltip');
			/* Unbind mousemove events */
			$('src').unbind('mousemove.tooltip');
			/* No destiny, no hiding */
			if(!self.dst) { return }
			/* Clear destiny contents */
			$(self.dst).empty();
			/* 'on hide' callback */
			if(opt.onhide){ opt.onhide.apply(self.dst) }
			/* If destiny was dinamicly created, destroy it */
			if(self.dst != opt.dst) {
				$(self.dst).remove();
				delete self.dst
			}
		}

		/* Moves the tooltip to follow the cursor */
		function move(ev){
			if(!ev){ ev = self.ev } else { self.ev = ev}
			if(!self.dst) { return }
			var p = {
				x: ev.pageX + opt.offset.x, y: ev.pageY + opt.offset.y,
				w: self.w, h: self.h
			}
			w = window;
			var v = {
				x: w.scrollX, y: w.scrollY,
				w: w.innerWidth - 20/*(w.scrollMaxY > 0 ? 30 : 20)*/,
				h: w.innerHeight - 20/*(w.scrollMaxX > 0 ? 20 : 10)*/
			};
			/* Better not to go offscreen */
			if(p.x + p.w > v.x + v.w) { p.x = v.x + v.w - p.w }
			if(p.y + p.h > v.y + v.h) { p.y = ev.pageY - p.h - opt.offset.y }
			if(p.x < v.x){ p.x = v.x }
			if(p.y < v.y){ p.y = v.y }
			$(self.dst).css({top:p.y, left:p.x})
		}
	}

	/* 
	 * Change tooltip local settings
	 * Example:
	 * 		$('a').tooltip('setup', {event: 'click'})
	 */
	function	setup(){
		return this.each(function(){
			t = $.data(this, 'tooltip');
			if(t){$.extend(t.opt, opt)}
			return this
		})
	}

	/* 
	 * Removes tooltip
	 * Example:
	 * 		$('div').tooltip('remove')
	 */
	function	remove(){
		return
			this
				.unbind('.tooltip')
				.removeData('tooltip')
	}

	/* 
	 * Creates a tooltip
	 * Example:
	 * 		$('div').tooltip('create')
	 */
	function	create(opt){
		remove.apply(this);
		opt = $.extend({}, $.tooltip.defaults, opt);
		return this.each(function(){
			new tip(this, opt);
		});
	}

	/*
	 * Extends jQuery functions
	 */
	$.fn.tooltip = function(a, o) {
		/* If called with only one non-string parameter (or none), it assumes 'create' by default */
		if(!o && (typeof a != 'string')) {
			o = a;
			a = 'create'
		}
		/* Call the selected function */
		return (f = ({
			setup: setup,
			remove: remove,
			create: create
		})[a]) && f.apply(this, [o])
	}

})(jQuery);