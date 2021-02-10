<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>9.5</version></rdbms>

    <fullquery name="bulk_mail::new.create_object">
      <querytext>
        select acs_object__new(
           null,                -- object_id
           'bulk_mail_message', -- object_type
           current_timestamp,   -- creation_date
           :creation_user,      -- creation_user
           :creation_ip,        -- creation_ip
           :package_id          -- context_id
        );
      </querytext>
    </fullquery>
</queryset>

