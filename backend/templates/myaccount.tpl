<%+ head %>
<%+ account_type %>
<h2>Manage account</h2>
<form action="" method="post" class="form-horizontal">
	<div class="control-group">
		<label class="control-label">Current password</label>
		<div class="controls">
			<input type="password" name="old_password" placeholder="Current password" value="" /> (Required to change your E-Mail or password)
		</div>
	</div>
	<legend>Change password</legend>
	<div class="control-group">
		<label class="control-label" for="newpass">New password</label>
		<div class="controls">
			<input type="password" name="password" id="newpass" pattern=".{5,}" placeholder="New password" value="" />
		</div>
	</div>
	<div class="control-group">
		<label class="control-label" for="newpassconf">Confirm new password</label>
		<div class="controls">
			<input type="password" name="password_confirm" id="newpassconf" pattern=".{5,}" placeholder="New password confirm" value="" />
		</div>
	</div>
	<div class="control-group">
		<div class="controls">
			<input type="submit" name="change_password" class="btn" value="Change password" />
		</div>
	</div>
	<legend>Change E-Mail</legend>
	<div class="control-group">
		<label class="control-label" for="newemail">New E-Mail</label>
		<div class="controls">
			<input type="email" name="email" id="newemail" placeholder="New email" value="<%= G.ngx.ctx.escape_html(G.ngx.ctx.user.email) %>" />
		</div>
	</div>
	<div class="control-group">
		<div class="controls">
			<input type="submit" name="change_email" class="btn" value="Change E-Mail" />
		</div>
	</div>
	<legend>Kill all other sessions</legend>
	<div class="control-group">
		<div class="controls">
			<input type="submit" name="kill_sessions" class="btn" value="Kill all other sessions" />
		</div>
	</div>
	<legend>Delete Account</legend>
	<div class="control-group">
		<div class="controls">
			<input type="submit" name="delete_account" class="btn" value="Delete Account">
		</div>
	</div>
</form>
<%+ foot %>