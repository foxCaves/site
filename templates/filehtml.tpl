<% local escaped_name = file.name %>
<% local escaped_name_js = escaped_name:gsub("'", "\\'") %>
<li draggable="true" id="file_<%= file.fileid %>" data-file-id="<%= file.fileid %>" data-file-extension="<%= file.extension %>">
	<div style="background-image: url('<% if file.type == 1 then %>https://d3rith5u07eivj.cloudfront.net/_thumbs/<%= file.thumbnail %><% elseif G.lfs.attributes("static/img/thumbs/ext_"..file.extension..".png", "size") then %>/static/img/thumbs/ext_<%= file.extension %>.png<% else %>/static/img/thumbs/nothumb.png<% end %>')" class="image_manage_main">
		<div class="image_manage_top" title="<%= G.os.date("%d.%m.%Y %H:%M", file.time) %> [<%= escaped_name %>]"><span><%= escaped_name %></span></div>
		<div class="image_manage_bottom">
			<span style="position: relative; float: right;">
				<a title="View" href="/view/<%= file.fileid %>"><i class="icon-picture icon-white"></i> </a>
				<a title="Download" href="https://foxcav.es/f/<%= file.fileid %><%= file.extension %>"><i class="icon-download icon-white"></i> </a>
				<% if file.type == 1 and G.ngx.ctx.user.pro_expiry > G.ngx.time() then %>
				<div class="dropdown">
					<a title="Options" class="dropdown-toggle" data-toggle="dropdown" href=""><i class="icon-wrench icon-white"></i> </a>
					<ul class="dropdown-menu">
						<li><a class="rename" href="#">Get Base64</a></li>
						<li><a class="getbase64" href="#">Get Base64</a></li>
						<li class="dropdown-submenu">
							<a href="#">Convert to</a>
							<ul class="dropdown-menu">
								<li><a href="#">jpeg</a></li>
								<li><a href="#">png</a></li>
								<li><a href="#">gif</a></li>
								<li><a href="#">bmp</a></li>
							</ul>
						</li>
					</ul>
				</div>
				<% end %>
				<a title="Delete" onclick="return deleteFile('<%= file.fileid %>','<%= escaped_name_js %>');" href="/myfiles?delete=<%= file.fileid %>"><i class="icon-remove icon-white"></i> </a>
			</span>
			<%= G.ngx.ctx.format_size(file.size) %>
		</div>
		<a href="/view/<%= file.fileid %>"><span class="whole_div_link"></span></a>
	</div>
</li>	