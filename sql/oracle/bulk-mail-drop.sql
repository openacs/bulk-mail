--
-- bulk_mail model drop
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @version $Id$
--

begin
    for row in (select bulk_mail_id from bulk_mail_messages) loop
        bulk_mail.delete(row.bulk_mail_id);
    end loop;
end;
/
show errors

begin
    acs_object_type.drop_type('bulk_mail_message', 'f');
end;
/
show errors

@@ bulk-mail-package-drop.sql
@@ bulk-mail-views-drop.sql

drop table bulk_mail_messages;
