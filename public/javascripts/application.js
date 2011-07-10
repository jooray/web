//=require pjax

$(document.body).removeClass('no-js');

$(function() {
	if ($('#promo').length > 0) {
		var promo = $('#promo'),
			promo_nav = $('#promo-nav'),
			promo_items = promo.find('.promo-item'),
			promo_active_item = promo_items.get(0),
			promo_auto_animate = true,
			promo_timer = null,
			loc_hash = document.location.hash;
		
		// @todo
		if (promo.find(loc_hash).length === 0) {		
			function promoAnimate() {
				promo_items.each(function () {
					var elm = $(this), 
						elm_anchor = promo_nav.find('a[href|="#' + this.id + '"]');
					if (this.id != promo_active_item.id) {
						elm.removeClass('active');
						elm_anchor.removeClass('active');
						elm.fadeOut('normal');
					} else {
						elm.addClass('active');
						elm_anchor.addClass('active');
						elm.fadeIn('slow');
					}
				});
			}

			promo_nav.delegate('a', 'mouseover', function () {
				clearTimeout(promo_timer);
				promo_auto_animate = false;
				promo_active_item = $($(this).attr('href')).get(0);
				promoAnimate();
			});

			function promoAnimateTimer () {
				promo_timer = setTimeout(function () {
					if (promo_auto_animate && promo_active_item !== promo_items.last()) {
						var active_index = promo_items.index(promo_active_item);
						promo_active_item = promo_items.get(active_index + 1);

						if (promo_active_item) {
							promoAnimate();
							promoAnimateTimer();
						} else {
							clearTimeout(promo_timer);
							promo_auto_animate = false;
						}
					} else {
						clearTimeout(promo_timer);
						promo_auto_animate = false;
					}
				}, 4000);

				return false;
			}

			promoAnimateTimer();
		}
	}
	
	$('a.scroll').bind('click', function () {
		var a = $(this),
			scroll_to = $(a.attr('href'));
		if (scroll_to.length > 0) {
			$.scrollTo(scroll_to, 1000);
		}
		
		return false;
	});
	
	$('.tabs').tabs();
	
	$('a.lightbox').fancybox({'titlePosition': 'inside'});
	
//	$('#menu a').pjax('#content');

	
//	$.ajax('http://localhost:3000/oficiality/sponzori?_pjax=true', function (r) {
//		console.log(r);
//	})
});