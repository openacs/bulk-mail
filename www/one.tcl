ad_page_contract {

    @author yon (yon@openforce.net)
    @creation-date 2002-05-13
    @version $Id$

} -query {
    bulk_mail_id:integer,notnull
} -properties {
    title:onevalue
    context_bar:onevalue
}

permission::require_permission -object_id $bulk_mail_id -privilege admin

set package_id [ad_conn package_id]

db_1row select_message_info {}

set title $subject
set context_bar [list $subject]

ad_return_template
