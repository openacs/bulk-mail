ad_library {

    Automated tests for bulk-mail-procs

}

aa_register_case \
    -cats { api } \
    -procs {
        bulk_mail::new
    } \
    bulk_mail_new {
        Basic check that Bulk Mail scheduling works
    } {
        aa_run_with_teardown \
            -rollback \
            -test_code {

                set user_id [ad_conn user_id]
                set from_addr [party::email -party_id $user_id]
                set subject [ad_generate_random_string 8]
                set reply_to [ad_generate_random_string 8]@[ad_generate_random_string 8].com
                set message [ad_generate_random_string 8]
                set send_date [db_string date {select current_timestamp from dual}]
                set date_format {YYYY MM DD HH24 MI SS}
                set query [subst -nocommands {
                    select email from parties
                    where party_id = $user_id
                }]

                set bm_id [bulk_mail::new \
                               -send_date $send_date \
                               -date_format $date_format \
                               -from_addr $from_addr \
                               -subject $subject \
                               -reply_to $reply_to \
                               -message $message \
                               -query $query]

                aa_true "Bulk mail is an object" [db_0or1row get_object {
                    select 1 from acs_objects
                    where object_id = :bm_id
                      and object_type = 'bulk_mail_message'
                }]

                aa_true "Date was stored correctly" \
                    [db_0or1row check_date {
                        select send_date from bulk_mail_messages
                        where bulk_mail_id = :bm_id
                        and send_date = to_timestamp(:send_date, :date_format)
                    }]

                aa_true "Addresses were stored correctly" \
                    [db_0or1row check_addr {
                        select send_date from bulk_mail_messages
                        where bulk_mail_id = :bm_id
                        and from_addr = :from_addr
                        and reply_to = :reply_to
                    }]

                aa_true "Message was stored correctly" \
                    [db_0or1row check_msg {
                        select send_date from bulk_mail_messages
                        where bulk_mail_id = :bm_id
                        and message = :message
                        and subject = :subject
                    }]

                aa_true "Query was stored correctly" \
                    [db_0or1row check_msg {
                        select send_date from bulk_mail_messages
                        where bulk_mail_id = :bm_id
                        and query = :query
                    }]
        }
}

aa_register_case -cats {
        api
        smoke
        production_safe
    } -procs {
        bulk_mail::package_key
    } bulk_mail__keys {
        Trivial test for the package_key proc.
} {
        aa_equals "Package key" "[bulk_mail::package_key]" "bulk-mail"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
