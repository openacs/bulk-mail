ad_page_contract {

    @author Caroline Meeks (caroline@meekshome.com)
    @creation-date 2002-11-27
    @cvs-id $Id$

} -query {
    bulk_mail_id:naturalnum,notnull
} -validate {
    message_pending -requires {bulk_mail_id:notnull} {
	if { [db_string bulk_mail_message_status "select status from bulk_mail_messages where bulk_mail_id=$bulk_mail_id"] ne "pending" } {
	    ad_complain {You may only cancel messages that have not yet been sent.}
	}
    }
}

permission::require_permission -object_id $bulk_mail_id -privilege admin

db_dml cancel_bulk_mail_message {}

ad_returnredirect "index"
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
