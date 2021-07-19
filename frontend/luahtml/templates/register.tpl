<%+ head %>
<h2>Register</h2>
<form method="post" id="register_form" class="form-horizontal">
	<legend>Please enter your requested user details</legend>
	<div class="control-group">
		<label class="control-label" for="username">Username</label>
		<div class="controls">
			<input type="text" name="username" id="username" value="" />
		</div>
	</div>
	<div class="control-group">
		<label class="control-label" for="password">Password</label>
		<div class="controls">
			<input type="password" name="password" id="password" value="" />
		</div>
	</div>
	<div class="control-group">
		<label class="control-label" for="passwordconf">Confirm password</label>
		<div class="controls">
			<input type="password" name="password_confirm" id="passwordconf" value="" />
		</div>
	</div>
	<div class="control-group">
		<label class="control-label" for="email">E-Mail</label>
		<div class="controls">
			<input type="text" name="email" id="email" value="" />
		</div>
	</div>
	<div class="control-group">
		<div class="controls">
			<input type="button" onclick="submitRegisterFormSimple();" class="btn" name="register" value="Register" id="postbut" />
		</div>
	</div>
</form>
<script type="text/javascript" src="/static/js/register.js"></script>
<%+ foot %>