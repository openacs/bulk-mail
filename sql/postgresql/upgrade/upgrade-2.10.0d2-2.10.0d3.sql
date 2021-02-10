begin;

alter table bulk_mail_messages add column to_display_name text;

drop view bulk_mail_messages_unsent;

drop view bulk_mail_messages_sent;

create view bulk_mail_messages_unsent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where status = 'pending';

create view bulk_mail_messages_sent
as
    select bulk_mail_messages.*
    from bulk_mail_messages
    where status = 'sent';


end;
