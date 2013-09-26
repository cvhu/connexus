function buildStreams(data, wrapper) {
	for (var ind = 0; ind < data.length; ind++) {
        buildStream(data[ind], wrapper);
    }
}

function buildStream(data, wrapper) {
	var stream_div = $('<a class="stream"></a>').attr("href", "/stream.jsp?id=" + data.id).appendTo(wrapper);
    $("<img>").attr("src", data.coverUrl).appendTo(stream_div);
    $('<div class="stream-name"></div>').html(data.name).appendTo(stream_div);
}

function buildStreamResults(data, wrapper) {
	for (var ind = 0; ind < data.length; ind++) {
		var result = $('<div class="search-result"></div>').appendTo(wrapper);
		buildStream(data[ind], result);
		buildStreamDescription(data[ind], result);
	}
}

function buildStreamDescription(data, wrapper) {
	var description = $("<div class='description'></div>").appendTo(wrapper);
	$("<div class='tags'></div>").html(data.tags).appendTo(description);
	$("<div class='views'></div>").html(data.views + " views").appendTo(description);
	$("<div class='created-by'></div>").html("by <b>" + data.userNickname + "</b>").appendTo(description);
	$("<div class='created-on'></div>").html(data.createdOn).appendTo(description);
}