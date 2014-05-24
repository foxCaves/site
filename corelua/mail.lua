function ses_mail(to_addr, subject, content, from_addr, from_name, headers)
	return _mail(to_addr, subject, content, from_addr, from_name, headers, "5.83.190.2", 25, "noreply@foxcav.es", "kpP6Ap81s5RX", true)
end

local IS_MAIL_DEVELOPMENT = false

local function smtp_recv_line(sock)
	local recv = sock:receive("*l")
	while recv and recv:sub(4,4) == "-" do
		if IS_MAIL_DEVELOPMENT then
			ngx.print("< "..(recv or "").."<br>")
		end
		recv = sock:receive("*l")
	end
	if IS_MAIL_DEVELOPMENT then
		ngx.print("< "..(recv or "").."<br>")
	end
end

local function smtp_send_line(sock, line)
	sock:send(line.."\r\n")
	if IS_MAIL_DEVELOPMENT then
		ngx.print("> "..line.."<br>")
	end
	smtp_recv_line(sock)
end

function _mail(to_addr, subject, content, from_addr, from_name, headers, mail_server, mail_port, mail_user, mail_password)
	--IS_MAIL_DEVELOPMENT = _G.IS_DEVELOPMENT

	local sock = ngx.socket.tcp()
	if not mail_server then
		sock:connect("5.83.190.2", 25)
		smtp_recv_line(sock)
		smtp_send_line(sock, "EHLO foxcav.es")
		mail_user = "noreply@foxcav.es"
		mail_password = "kpP6Ap81s5RX"
	else
		sock:connect(mail_server, mail_port)
		smtp_recv_line(sock)
		smtp_send_line(sock, "EHLO foxcav.es")
	end

	if not from_name then
		from_name = from_addr
	end

	if mail_user and mail_password then
		smtp_send_line(sock, "AUTH PLAIN "..ngx.encode_base64(string.format("%s\0%s\0%s", mail_user, mail_user, mail_password)))
	end

	if from_addr then
		smtp_send_line(sock, "MAIL FROM: "..from_addr)
	end

	smtp_send_line(sock, "RCPT TO: "..to_addr)

	smtp_send_line(sock, "DATA")

	if from_addr then
		sock:send("From: "..from_name.." <"..from_addr..">\r\n")
	end
	sock:send("To: "..to_addr.."\r\n")
	sock:send("Subject: "..subject.."\r\n")
	if headers then
		sock:send(headers)
	end
	sock:send("\r\n")
	sock:send(content)
	smtp_send_line(sock, "\r\n.")
	smtp_send_line(sock, "QUIT")
	sock:close()
end

mail = _mail