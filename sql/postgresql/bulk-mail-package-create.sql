--
-- bulk_mail logic
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @version $Id$
--

create function bulk_mail__new (integer, integer, varchar, varchar, varchar, varchar, varchar, varchar, varchar, text, varchar, timestamp, integer, varchar, integer)
returns integer as '
declare
    bulk_mail__new__bulk_mail_id alias for $1; -- default to null
    bulk_mail__new__package_id alias for $2;
    bulk_mail__new__send_date alias for $3; -- default to null
    bulk_mail__new__date_format alias for $4; -- default to "YYYY MM DD HH24 MI SS"
    bulk_mail__new__sent_p alias for $5; -- default to "f"
    bulk_mail__new__from_addr alias for $6;
    bulk_mail__new__subject alias for $7; -- default to null
    bulk_mail__new__reply_to alias for $8; -- default to null
    bulk_mail__new__extra_headers alias for $9; -- default to null
    bulk_mail__new__message alias for $10;
    bulk_mail__new__query alias for $11;
    bulk_mail__new__creation_date alias for $12; -- default to now()
    bulk_mail__new__creation_user alias for $13; -- default to null
    bulk_mail__new__creation_ip alias for $14; -- default to null
    bulk_mail__new__context_id alias for $15; -- default to null
    v_bulk_mail_id integer;
    v_send_date varchar(4000);
begin

    v_bulk_mail_id := acs_object__new(
        bulk_mail__new__bulk_mail_id,
        ''bulk_mail_message'',
        bulk_mail__new__creation_date,
        bulk_mail__new__creation_user,
        bulk_mail__new__creation_ip,
        bulk_mail__new__context_id
    );

    if bulk_mail__new__date_format is null then
        bulk_mail__new__date_format := ''YYYY MM DD HH24 MI SS'';
    end if;

    v_send_date := bulk_mail__new__send_date;
    if v_send_date is null then
        select to_char(now(), bulk_mail__new__date_format)
        into v_send_date;
    end if;

    if bulk_mail__new__sent_p is null then
        bulk_mail__new__sent_p := ''f'';
    end if;

    insert
    into bulk_mail_messages
    (bulk_mail_id, package_id,
     send_date, sent_p,
     from_addr, subject, reply_to,
     extra_headers, message, query)
    values
    (v_bulk_mail_id, bulk_mail__new__package_id,
     to_date(bulk_mail__new__send_date, bulk_mail__new__date_format), bulk_mail__new__sent_p,
     bulk_mail__new__from_addr, bulk_mail__new__subject, bulk_mail__new__reply_to,
     bulk_mail__new__extra_headers, bulk_mail__new__message, bulk_mail__new__query);

    return v_bulk_mail_id;

end;
' language 'plpgsql';

create function bulk_mail__delete (integer)
returns integer as '
declare
    bulk_mail__delete__bulk_mail_id alias for $1;
begin

    delete
    from bulk_mail_messages
    where bulk_mail_messages.bulk_mail_id = bulk_mail__delete__bulk_mail_id;

    perform acs_object__delete(bulk_mail__delete__bulk_mail_id);

end;
' language 'plpgsql';
