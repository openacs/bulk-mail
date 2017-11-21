<?xml version="1.0"?>
<queryset>

    <fullquery name="bulk_mail::package_id_not_cached.select_bulk_mail_package_id">      
        <querytext>
            select min(apm_packages.package_id)
            from apm_packages
            where apm_packages.package_key = :package_key
        </querytext>
    </fullquery>

    <fullquery name="bulk_mail::sweep.mark_message_sent">      
        <querytext>
            update bulk_mail_messages
            set status = 'sent'
            where bulk_mail_id = :bulk_mail_id
        </querytext>
    </fullquery>

    <fullquery name="bulk_mail::new.select_current_date">
        <querytext>
            select to_char(current_timestamp, :date_format) from dual
        </querytext>
    </fullquery>

    <fullquery name="bulk_mail::sweep.select_bulk_mails_to_send">      
        <querytext>
            select bulk_mail_messages.*
            from bulk_mail_messages
            where bulk_mail_messages.status = 'pending'
            and bulk_mail_messages.send_date <= current_timestamp
            for update
        </querytext>
    </fullquery>    
    
</queryset>
