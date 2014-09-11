<?xml version="1.0"?>

<queryset>

    <fullquery name="get_mail_messages">
        <querytext>
	    select bulk_mail_messages.*
    	    from  bulk_mail_messages
    	    where bulk_mail_messages.package_id = :package_id
    	    [template::list::orderby_clause -orderby -name messages]
        </querytext>
    </fullquery>

</queryset>
