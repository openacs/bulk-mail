<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<if @focus@ not nil><property name="focus">@focus@</property></if>

<h2>@title@</h2>
<%= [eval ad_context_bar $context] %>
<hr>

<slave>
