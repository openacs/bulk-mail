--
-- bulk_mail views
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @version $Id$
--

create view bulk_mail_messages_unsent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where sent_p = 'f';

create view bulk_mail_messages_sent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where sent_p = 't';
