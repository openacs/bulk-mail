<master src="master">
<property name="title">@title@</property>
<property name="context_bar">@context_bar@</property>


<center>
  <table bgcolor="#ececec" border="1" width="95%" cellpadding="3" cellspacing="3">
    <tr>
      <td>Send Date</td>
      <td>@send_date@</td>
    </tr>
    <tr>
      <td>From</td>
      <td>@from_addr@</td>
    </tr>
    <tr>
      <td>Subject</td>
      <td>@subject@</td>
    </tr>
    <tr>
      <td>Reply To</td>
      <td>@reply_to@</td>
    </tr>
    <tr>
      <td>Extra Headers</td>
      <td>@extra_headers@</td>
    </tr>
    <tr>
      <td>Message</td>
      <td><pre>@message@</pre></td>
    </tr>
    <tr>
      <td>Query</td>
      <td><pre>@query@</pre></td>
    </tr>
    <tr>
      <td>Sent?</td>
      <td><if @sent_p@>Yes</if><else>No</else></td>
    </tr>
  </table>
</center>
