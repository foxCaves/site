<%+ head %>
<% local RAWNAME = FILEID .. FILE.extension %>
	<h3>Viewing file: <%= FILE.name %></h3>
	<div class="well well-small" style="text-align: left;">
		<form class="form-horizontal">
			<div class="control-group">
				<label class="control-label">Uploaded by</label>
				<div class="controls" style="padding-top: 5px;"><%= FILEOWNER %></div>
			</div>
			<div class="control-group">
				<label class="control-label">Uploaded on</label>
				<div class="controls" style="padding-top: 5px;"><%= G.os.date("%d.%m.%Y %H:%M", FILE.time) %></div>
			</div>
			<div class="control-group">
				<label class="control-label">Size</label>
				<div class="controls" style="padding-top: 5px;"><%= G.ngx.ctx.format_size(FILE.size) %></div>
			</div>
			<div class="control-group">
				<label class="control-label" for="view-link">View link</label>
				<div class="controls">
					<input readonly="readonly" id="view-link" type="text" value="https://fox.gy/v<%= FILEID %>" />
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="direct-link">Direct link</label>
				<div class="controls">
					<input readonly="readonly" id="direct-link" type="text" value="https://fox.gy/f<%= FILEID %><%= FILE.extension %>" />
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="download-link">Download link</label>
				<div class="controls">
					<input readonly="readonly" id="download-link" type="text" value="https://fox.gy/d<%= FILEID %><%= FILE.extension %>" />
				</div>
			</div>
		</form>
	</div>
	<a href="https://fox.gy/d<%= RAWNAME %>" class="btn btn-large btn-block btn-primary">Download file</a>
	<div id="preview-wrapper">
	<% if FILE.type == FILE_TYPE_IMAGE then %>
		<a href="https://fox.gy/f<%= RAWNAME %>"><img src="https://fox.gy/f<%= RAWNAME %>"></a>
	<% elseif FILE.type == FILE_TYPE_TEXT then %>
		<noscript>JavaScript required to preview code/text</noscript>
		<pre class="prettyprint linenums" style="display: none;" data-thumbnail-source="<%= FILEID %><%= FILE.thumbnail %>"></pre>
	<% elseif FILE.type == FILE_TYPE_VIDEO then %>
		<video controls="controls">
			<source src="https://fox.gy/f<%= RAWNAME %>" type="<%= MIMETYPES[FILE.extension] %>" />
			Your browser is too old.
		</video>
	<% elseif FILE.type == FILE_TYPE_AUDIO then %>
		<audio id="audioplayer">
			<source src="https://fox.gy/f<%= RAWNAME %>" type="<%= MIMETYPES[FILE.extension] %>" />
			Your browser is too old.
		</audio>
		<a href="#" onclick="return dancer_play();">Play</a>
		<canvas style="position: fixed; z-index: 20000; top: 0; left: 0; pointer-events: none;" id="audiovis"></canvas>
		<script type="text/javascript" src="<%= STATIC_URL_PREFIX %>/js/dancer.js"></script>
		<script type="text/javascript" src="<%= STATIC_URL_PREFIX %>/js/audiovis.js"></script>
	<% elseif FILE.type == FILE_TYPE_IFRAME then %>
		<iframe id="pdf-view" src="https://fox.gy/f<%= RAWNAME %>" type="<%= MIMETYPES[FILE.extension] %>"></iframe>
	<% else %>
		<h5>File cannot be viewed. Download it.</h5>
	<% end %>
	</div>
	<script type="text/javascript" src="<%= STATIC_URL_PREFIX %>/js/view.js"></script>
<%+ foot %>