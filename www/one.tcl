ad_page_contract {

    @author yon (yon@openforce.net)
    @creation-date 2002-05-13
    @version $Id$

} -query {
    bulk_mail_id:integer,notnull
} -properties {
    bulk_mail_name:onevalue
    context_bar:onevalue
}

set package_id [ad_conn package_id]

db_1row select_message_info {}

set title $subject
set context_bar [list $subject]

ad_return_template
