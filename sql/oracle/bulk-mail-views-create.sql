--
-- bulk_mail views
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @version $Id$
--

create or replace view bulk_mail_messages_unsent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where status = 'pending';

create or replace view bulk_mail_messages_sent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where status = 'sent';

