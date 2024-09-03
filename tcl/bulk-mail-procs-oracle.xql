<?xml version="1.0"?>

<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="bulk_mail::new.create_object">
      <querytext>
        begin
        1: := acs_object.new(
           object_id     => null,
           object_type   => 'bulk_mail_message',
           creation_date => current_timestamp,
           creation_user => :creation_user,
           creation_ip   => :creation_ip,
           context_id    => :package_id
        );
        end;
      </querytext>
    </fullquery>
</queryset>

