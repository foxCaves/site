<%+ head %>
<%+ account_type %>
<h2>Manage links (<a onclick="newLink();">Create</a>)</h2>
<table class="table">
	<thead>
		<tr>
			<th>Short link</th>
			<th>Target</th>
			<th>Actions</th>
		</tr>
	</thread>
	<tbody>
		<% for _, linkid in next, LINKS do
			local link = link_get(linkid) %>
			<%+ linkhtml %>
		<% end %>
	</tbody>
</table>
<script type="text/javascript" src="/static/js/mylinks.js"></script>
<%+ foot %>
