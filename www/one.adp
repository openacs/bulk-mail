<master src="master">
<property name="title">@title@</property>
<property name="context">@context@</property>

  <table bgcolor="#ececec" border="1" width="95%" cellpadding="3" cellspacing="3">
    <tr>
      <td>Send Date</td>
      <td><if @send_date@ not nil>@send_date@</if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>From</td>
      <td><if @from_addr@ not nil>@from_addr@</if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Subject</td>
      <td><if @subject@ not nil><pre>@subject@</pre></if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Reply To</td>
      <td><if @reply_to@ not nil>@reply_to@</if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Extra Headers</td>
      <td><if @extra_headers@ not nil>@extra_headers@</if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Message</td>
      <td><if @message@ not nil><pre>@message@</pre></if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Query</td>
      <td><if @query@ not nil><pre>@query@</pre></if><else>&nbsp;</else></td>
    </tr>
    <tr>
      <td>Sent?</td>
      <td><if @sent_p@>Yes</if><else>No</else></td>
    </tr>
  </table>
