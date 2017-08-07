ad_page_contract {

    @author yon (yon@openforce.net)
    @creation-date 2002-05-13
    @cvs-id $Id$

} -query {
    {orderby:token "send_date"}
} -properties {
    title:onevalue
    context:onevalue
    table:onevalue
}

set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege admin

set title [string totitle [bulk_mail::pretty_name]]

template::list::create -name messages \
    -multirow message_list \
    -no_data "[_ bulk-mail.lt_No_bulk_mail_messages]" \
    -html {width "95%"} \
    -elements {
	send_date {
	    label "#bulk-mail.Send_Date#"
	    display_col send_date_pretty
	    orderby send_date
	    html {style "width:10%"}
	}
	from_addr {
	    label "#bulk-mail.From#"
	    orderby from_addr
	    html {style "width:15%"}
	}
	subject {
	    label "#bulk-mail.Subject#"
	    link_url_col message_url
	    orderby subject
	}
	status_pretty {
	    label "#bulk-mail.Status#"
	    html {style "width:10%" align "center"}
	    orderby status
	}
    }

db_multirow -extend {send_date_pretty message_url status_pretty} message_list get_mail_messages {} {
    set send_date_pretty [lc_time_fmt $send_date %q]
    set message_url "[lindex [site_node::get_url_from_object_id -object_id $package_id] 0]one?bulk_mail_id=$bulk_mail_id"
    set status_pretty [ad_decode $status sent [_ bulk-mail.Sent] pending [_ bulk-mail.Pending] [_ bulk-mail.Cancelled]]
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
