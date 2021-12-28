ad_library {

    bulk_mail procedure library

    @author yon (yon@openforce.net)
    @creation-date 2002-05-07
    @cvs-id $Id$

}

namespace eval bulk_mail {

    ad_proc -public package_key {} {
        returns the package key of the bulk_mail package
    } {
        return "bulk-mail"
    }

    ad_proc -public pretty_name {
        {package_id ""}
    } {
        return the pretty name of this instance
    } {
        if {$package_id eq ""} {
            set package_id [ad_conn package_id]
        }

        return [parameter -localize -package_id $package_id -parameter pretty_name]
    }

    ad_proc -public parameter {
        -localize:boolean
        {-package_id ""}
        {-parameter:required}
        {-default ""}
    } {
        returns the bulk_mail parameter value for the given parameter
    } {
        if {$package_id eq ""} {
            set package_id [package_id]
        }

        return [parameter::get -localize=$localize_p -package_id $package_id -parameter $parameter -default $default]
    }

    ad_proc -public package_id {
    } {
        returns the top most bulk_mail package_id
    } {
        return [util_memoize {bulk_mail::package_id_not_cached}]
    }

    ad_proc -private package_id_not_cached {
    } {
        returns the top most bulk_mail package_id
    } {
        set package_key [package_key]

        return [db_string select_bulk_mail_package_id {}]
    }

    ad_proc -public url {
    } {
        returns the base url of the top most bulk_mail package
    } {
        return [util_memoize {bulk_mail::url_not_cached}]
    }

    ad_proc -private url_not_cached {
    } {
        returns the base url of the top most bulk_mail package
    } {
        set package_id [package_id]

        return [db_string select_bulk_mail_url {}]
    }

    ad_proc -public new {
        {-package_id ""}
        {-send_date ""}
        {-date_format "YYYY MM DD HH24 MI SS"}
        {-from_addr:required}
        {-subject ""}
        {-reply_to ""}
        {-extra_headers ""}
        {-message:required}
        {-message_type ""}
        {-query:required}
        {-to_display_name ""}
    } {
        create a new bulk_mail message

        @param package_id which instance does this bulk_mail belong to
        @param send_date expects a date in the date_format format. if no date
                         is passed it will use the current date and time
        @param date_format how to parse send_date, defaults to
                           "YYYY MM DD HH24 MI SS"
        @param from_addr from email address to bulk_mail from, can be
                         overridden by a value from the query
        @param subject subject of the bulk_mail message, can be overridden
                              by a value from the query. will be interpolated
                              with values from the query.
        @param reply_to reply_to email address for the bulk_mail, defaults to
                               the value of the from_addr parameter, can be
                               overridden by a value from the query.
        @param extra_headers a list of key, value pairs of extra headers to
                             stick in the email, such as 'X-Mailer' or
                             'Content-type'
        @param message the body of the email, can be overridden by a value
                       selected in the query. will be interpolated with values
                       from the query.
        @param message_type - "text" or "html" (added by mohan)
        @param query a query that must select the email address to send to as
                     'email' and can select any other values that will be
                     interpolated into the subject and message of the bulk_mail for
                     each recipient. if column 'foo' is selected its value
                     will be interpolated anywhere that '{foo}' appears in the
                     subject or message of the bulk_mail. if columns 'from_addr',
                     'reply_to', 'subject', or 'message' are selected, their
                     respective values will also become the 'from_addr',
                     'reply_to', 'subject', and 'message' on a per recipient
                     basis.
        @param to_display_name Display name set for the recipient in
                               the To: email header, useful to qualify
                               the individual recipient as e.g. member
                               of the group of people who have
                               received the bulk_mail message.

        @return bulk_mail_id the id of the newly created bulk_mail message
    } {
        # run the query here to make sure that the required columns are
        # present, if they are not all present then we error out.
        db_with_handle db {
            set selection [ns_db select $db $query]
            ns_db flush $db
        }

        # column email is required
        if {[ns_set find $selection email] == -1} {
            error "Invalid query, column \"email\" is required"
        }

        # default the package_id to the appropriate value
        if {$package_id eq ""} {
            set package_id [ad_conn package_id]
        }

        # set a reasonable default for the reply_to header
        if {$reply_to eq ""} {
            set reply_to $from_addr
        }

        # prepare the data
        if {[ns_conn isconnected]} {
            set creation_user [ad_conn user_id]
            set creation_ip   [ad_conn peeraddr]
        } else {
            set creation_user ""
            set creation_ip   ""
        }

        set object_id [db_exec_plsql create_object {}]

        set extra_headers "$extra_headers bulk-mail-type $message_type"

        db_dml insert_metadata {
            insert into bulk_mail_messages
            (
             bulk_mail_id,
             package_id,
             send_date,
             status,
             from_addr,
             subject,
             reply_to,
             extra_headers,
             message,
             query,
             to_display_name
             )
            values
            (
             :object_id,
             :package_id,
             to_timestamp(coalesce(cast(:send_date as text), cast(current_timestamp as text)),
                          coalesce(:date_format, 'YYYY MM DD HH24 MI SS')),
             'pending',
             :from_addr,
             :subject,
             :reply_to,
             :extra_headers,
             :message,
             :query,
             :to_display_name
             )
        }

        return $object_id
    }

    ad_proc -private sweep {
    } {
        process any bulk_mails that are ready to send
    } {
        if {[nsv_get bulk_mail_sweep bulk_mail_sweep] == 1} {
            return
        }
        nsv_set bulk_mail_sweep bulk_mail_sweep 1
        ns_log Debug "bulk_mail::sweep starting"

        foreach bulk_mail [db_list_of_ns_sets select_bulk_mails_to_send {}] {
            #Although the message may change for each recipient, it
            # usually doesn't.
            # We check by looking to see if message_old = the current message.
            # This is initialized here for each bulk_mail.
            set message_old ""

            # NOTE: JCD: the query issued here is actually stored in the
            # database in column bulk_mail_messages.query
            # I am horrified by this.
            foreach recipient [db_list_of_ns_sets select_bulk_mail_recipients [ns_set get $bulk_mail query]] {

                # create a list of key, value pairs that will be used to
                # interpolate the subject and the message. we will search
                # for strings of the format {column_name} in the subject
                # and message and replace them with the value of that
                # column as returned by the query
                set pairs [list]
                for {set i 0} {$i < [ns_set size $recipient]} {incr i} {
                    lappend pairs "\{[ns_set key $recipient $i]\}" "[ns_set value $recipient $i]"
                }

                # it's possible that someone may want to override the from
                # address on a per recipient basis
                set from_addr [ns_set get $bulk_mail from_addr]
                if {[ns_set find $recipient from_addr] > -1} {
                    set from_addr [ns_set get $recipient from_addr]
                }

                # it's possible that someone may want to override the
                # reply_to address on a per recipient basis
                set reply_to [ns_set get $bulk_mail reply_to]
                if {[ns_set find $recipient reply_to] > -1} {
                    set reply_to [ns_set get $recipient reply_to]
                }

                # it's possible that someone may want to override the
                # subject on a per recipient basis
                # create the new bulk_mail message
                set subject [ns_set get $bulk_mail subject]
                if {[ns_set find $recipient subject] > -1} {
                    set subject [ns_set get $recipient subject]
                }

                # interpolate the key, value pairs (as described above)
                # into the subject
                set subject [string map $pairs $subject]

                # it's possible that someone may want to override the
                # message on a per recipient basis
                set message [ns_set get $bulk_mail message]
                if {[ns_set find $recipient message] > -1} {
                    set message [ns_set get $recipient message]
                }

                # mohan's hack to fix the passing of message type for the
                # mail.
                # Comment: I have to ask Caroline or Andrew if itis ok to
                # change bulk-mail datamodel to accommodate message_type.

                set extra_headers [ns_set create s {*}[ns_set get $bulk_mail extra_headers]]
                set message_type  [ns_set get $extra_headers bulk-mail-type]

                # don't need this anymore and don't want to send it along
                ns_set delkey $extra_headers bulk-mail-type

                # interpolate the key, value pairs (as described above)
                # into the message body
                set message [string map $pairs $message]

                if {$message_type eq "html"} {
                    set mime_type "text/html"
                    if {$message_old ne $message } {
                        # If this message is different then the last loop
                        # we set up the html and text messages. Note that
                        # ad_html_text_convert can get quite expensive,
                        # if you start sending different long html
                        # messages created by microsoft word to each of
                        # over 100 users, expect performance problems.

                        set message_old $message
                        # the from to html closes any open tags.
                        set message [ad_html_text_convert -from html -to html $message]
                        # some mailers are chopping off the last few characters.
                        append message "   "
                    }
                } else {
                    set mime_type "text/plain"
                }

                set to_addr [ns_set get $recipient email]
                set to_display_name [ns_set get $bulk_mail to_display_name]
                if {$to_display_name ne ""} {
                    # If a display name has been specified, include it in
                    # the recipient address.
                    regsub -all "\"" $to_display_name "\\\"" to_display_name
                    set to_addr [subst -nocommands {"${to_display_name}" <${to_addr}>}]
                }

                # both html and plain messages can now be sent the same way
                acs_mail_lite::send \
                    -to_addr [list $to_addr] \
                    -from_addr $from_addr \
                    -subject $subject \
                    -body $message \
                    -mime_type $mime_type \
                    -reply_to $reply_to \
                    -extraheaders $extra_headers \
                    -use_sender \
                    -package_id [ns_set get $bulk_mail package_id] \
                    -object_id [ns_set get $bulk_mail bulk_mail_id]
            }

            # mark the bulk_mail as sent so that we don't process it again
            set bulk_mail_id [ns_set get $bulk_mail bulk_mail_id]
            db_dml mark_message_sent {}
        }
        nsv_set bulk_mail_sweep bulk_mail_sweep 0
        ns_log Debug "bulk_mail::sweep ending"
    }

    ad_proc -deprecated -private interpolate {
        {-values:required}
        {-text:required}
    } {
        Interpolates a set of values into a string.

        DEPRECATED: can be replaced by "string map"

        @see "string map"

        @param values a list of key, value pairs, each one consisting of a
                      target string and the value it is to be replaced with.
        @param text the string that is to be interpolated

        @return the interpolated string
    } {
        foreach pair $values {
            regsub -all [lindex $pair 0] $text [lindex $pair 1] text
        }

        return $text
    }

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
