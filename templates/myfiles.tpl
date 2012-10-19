<%+ head %>
<%+ account_type %>
<% local format_size = G.ngx.ctx.format_size %>
<div id="uploader"></div>
<h2>Manage files</h2>
<table><tr><td><ul class="image_manage_ul" id="file_manage_div">
	<% for _,file in pairs(FILES) do %>
	<% local escaped_name = file.name %>
	<% local escaped_name_js = escaped_name:gsub("'", "\\'") %>
	<li id="file_<%= file.fileid %>">
		<div style="background-image: url('<% if file.type == 1 and file.thumbnail and file.thumbnail ~= "" then %>https://d3rith5u07eivj.cloudfront.net/_thumbs/<%= file.thumbnail %><% elseif G.lfs.attributes("static/img/thumbs/ext_"..file.extension..".png", "size") then %>/static/img/thumbs/ext_<%= file.extension %>.png<% else %>/static/img/thumbs/nothumb.png<% end %>')" class="image_manage_main">
			<div class="image_manage_top" title="<%= G.os.date("%d.%m.%Y %H:%M", file.time) %> [<%= escaped_name %>]"><%= escaped_name %></div>
			<div class="image_manage_bottom">
				<span style="position: relative; float: right;">
					<a title="View" href="/view/<%= file.fileid %>"><i class="icon-picture icon-white"></i> </a>
					<a title="Download" href="https://foxcav.es/f/<%= file.fileid %><%= file.extension %>"><i class="icon-download icon-white"></i> </a>
					<a title="Delete" onclick="return deleteFile('<%= file.fileid %>','<%= escaped_name_js %>');" href="/myfiles?delete=<%= file.fileid %>"><i class="icon-remove icon-white"></i> </a>
				</span>
				<%= format_size(file.size) %>
			</div>
			<a href="/view/<%= file.fileid %>"><span class="whole_div_link"></span></a>
		</div>
	</li>		
	<% end %>
</ul></td></tr></table>
<script type="text/javascript" src="/static/js/uploader.min.js?v=9"></script>
<%+ foot %>
