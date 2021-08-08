<% MAINTITLE = "My links" %>
<%+ _includes/head %>
<h2><%= MAINTITLE %> (<a class="pointer" onclick="newLink();">Create</a>) (<a class="pointer" onclick="return refreshLinks();">Refresh</a>)</h2>
<table class="table">
	<thead>
		<tr>
			<th>Short link</th>
			<th>Target</th>
			<th>Actions</th>
		</tr>
	</thread>
	<tbody id="links_table"></tbody>
</table>
<script type="text/javascript" src="/static/js/mylinks.js"></script>
<%+ _includes/foot %>
