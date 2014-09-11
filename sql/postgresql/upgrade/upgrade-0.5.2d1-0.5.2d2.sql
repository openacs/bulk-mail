--
-- Upgrade for 0.5.2d2 
--



-- added

-- old define_function_args('bulk_mail__new','new__bulk_mail_id;null,new__package_id,new__send_date;null,new__date_format;to "YYYY MM DD HH24 MI SS",new__status;to "pending",new__from_addr,new__subject;null,new__reply_to;null,new__extra_headers;null,new__message,new__query,new__creation_date;to now(),new__creation_user;null,new__creation_ip;null,new__context_id;null')
-- new
select define_function_args('bulk_mail__new','new__bulk_mail_id;null,new__package_id,new__send_date;null,new__date_format;to "YYYY MM DD HH24 MI SS",new__status;pending,new__from_addr,new__subject;null,new__reply_to;null,new__extra_headers;null,new__message,new__query,new__creation_date;now(),new__creation_user;null,new__creation_ip;null,new__context_id;null');


--
-- procedure bulk_mail__new/15
--
CREATE OR REPLACE FUNCTION bulk_mail__new(
   bulk_mail__new__bulk_mail_id integer,      -- default to null
   bulk_mail__new__package_id integer,
   bulk_mail__new__send_date varchar,         -- default to null
   bulk_mail__new__date_format varchar,       -- default to "YYYY MM DD HH24 MI SS"
   bulk_mail__new__status varchar,            -- default to "pending"
   bulk_mail__new__from_addr varchar,
   bulk_mail__new__subject varchar,           -- default to null
   bulk_mail__new__reply_to varchar,          -- default to null
   bulk_mail__new__extra_headers varchar,     -- default to null
   bulk_mail__new__message text,
   bulk_mail__new__query varchar,
   bulk_mail__new__creation_date timestamptz, -- default to now()
   bulk_mail__new__creation_user integer,     -- default to null
   bulk_mail__new__creation_ip varchar,       -- default to null
   bulk_mail__new__context_id integer         -- default to null

) RETURNS integer AS $$
DECLARE
    v_bulk_mail_id integer;
    v_send_date varchar(4000);
    v_date_format varchar(4000);
    v_status varchar(100);
BEGIN

    v_bulk_mail_id := acs_object__new(
        bulk_mail__new__bulk_mail_id,
        'bulk_mail_message',
        bulk_mail__new__creation_date,
        bulk_mail__new__creation_user,
        bulk_mail__new__creation_ip,
        bulk_mail__new__context_id
    );

    v_date_format := bulk_mail__new__date_format;
    if v_date_format is null then
        v_date_format := 'YYYY MM DD HH24 MI SS';
    end if;

    v_send_date := bulk_mail__new__send_date;
    if v_send_date is null then
        select to_char(now(), bulk_mail__new__date_format)
        into v_send_date;
    end if;

    v_status := bulk_mail__new__status;
    if v_status is null then
        v_status := 'pending';
    end if;

    insert
    into bulk_mail_messages
    (bulk_mail_id, package_id,
     send_date, status,
     from_addr, subject, reply_to,
     extra_headers, message, query)
    values
    (v_bulk_mail_id, bulk_mail__new__package_id,
     to_timestamp(v_send_date, v_date_format), v_status,
     bulk_mail__new__from_addr, bulk_mail__new__subject, bulk_mail__new__reply_to,
     bulk_mail__new__extra_headers, bulk_mail__new__message, bulk_mail__new__query);

    return v_bulk_mail_id;

END;

$$ LANGUAGE plpgsql;
