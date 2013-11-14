function partial(url) {
	$.ajax({
		url: url,
		success: function(data) { document.write(data); },
		async: false
	});
}

$(function() { $('script.partial').remove(); });
