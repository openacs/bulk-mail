-- Change query column from varchar(4000) to text
--
-- NOTE: Since PG 7.2 doesn't support dropping of columns or
-- adding of not null constraints, we recreate the table.
-- 
-- @author Peter Marklund

-- Temp table. Don't use constraints to avoid naming conflicts
create table bulk_mail_messages_tmp (
    bulk_mail_id                integer,
    package_id                  integer,
    send_date                   timestamptz,
    sent_p                      boolean,
    from_addr                   varchar(4000),
    subject                     varchar(4000),
    reply_to                    varchar(4000),
    extra_headers               varchar(4000),
    message                     text,
    query                       text,
    status                      varchar(100)
);

-- Save data to temp table
insert into bulk_mail_messages_tmp select * from bulk_mail_messages;

update bulk_mail_messages_tmp set status = 'pending' where sent_p = 'f';
update bulk_mail_messages_tmp set status = 'sent' where sent_p = 't';

-- Get rid of old table
drop table bulk_mail_messages cascade;

-- Create new table with text datatype
create table bulk_mail_messages (
    bulk_mail_id                integer
                                constraint bm_messages_bulk_mail_id_fk
                                references acs_objects (object_id)
                                constraint bm_messages_bulk_mail_id_pk
                                primary key,
    package_id                  integer
                                constraint bm_messages_package_id_fk
                                references apm_packages (package_id)
                                constraint bm_messages_package_id_nn
                                not null,
    send_date                   timestamptz
                                default current_timestamp
                                constraint bm_messages_send_date_nn
                                not null,
    sent_p                      boolean
                                default 'f'
                                constraint bm_messages_sent_p_nn
                                not null,
    from_addr                   varchar(4000)
                                constraint bm_messages_from_addr_nn
                                not null,
    subject                     varchar(4000),
    reply_to                    varchar(4000),
    extra_headers               varchar(4000),
    message                     text
                                constraint bm_messages_message_nn
                                not null,
    query                       text
                                constraint bm_messages_query_nn
                                not null,
    status                      varchar(100)
                                default 'pending'
                                constraint bm_messages_status_nn
                                not null
                                
);

-- Copy the data back
insert into bulk_mail_messages select * from bulk_mail_messages_tmp;

-- Get rid of temp table
drop table bulk_mail_messages_tmp;


-- recreate the views
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


--
-- bulk_mail logic
--
-- @author <a href="mailto:yon@openforce.net">yon@openforce.net</a>
-- @version $Id$
--


-- old define_function_args('bulk_mail__new','bulk_mail_id,package_id,send_date,date_format,status;pending,from_addr,subject,reply_to,extra_headers,message,query,creation_date;now(),creation_user,creation_ip,context_id')
-- new
select define_function_args('bulk_mail__new','new__bulk_mail_id;to null,new__package_id,new__send_date;to null,new__date_format;to "YYYY MM DD HH24 MI SS",new__status;pending,new__from_addr,new__subject;to null,new__reply_to;to null,new__extra_headers;to null,new__message,new__query,new__creation_date;now(),new__creation_user;to null,new__creation_ip;to null,new__context_id;to null');




--
-- procedure bulk_mail__new/15
--
CREATE OR REPLACE FUNCTION bulk_mail__new(
   bulk_mail__new__bulk_mail_id integer,      -- default to null
   bulk_mail__new__package_id integer,
   bulk_mail__new__send_date varchar,         -- default to null
   bulk_mail__new__date_format varchar,       -- default to "YYYY MM DD HH24 MI SS"
   bulk_mail__new__status varchar,            -- default to "pending" -- default 'pending'
   bulk_mail__new__from_addr varchar,
   bulk_mail__new__subject varchar,           -- default to null
   bulk_mail__new__reply_to varchar,          -- default to null
   bulk_mail__new__extra_headers varchar,     -- default to null
   bulk_mail__new__message text,
   bulk_mail__new__query varchar,
   bulk_mail__new__creation_date timestamptz, -- default to now() -- default 'now()'
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
     to_date(v_send_date, v_date_format), v_status,
     bulk_mail__new__from_addr, bulk_mail__new__subject, bulk_mail__new__reply_to,
     bulk_mail__new__extra_headers, bulk_mail__new__message, bulk_mail__new__query);

    return v_bulk_mail_id;

END;

$$ LANGUAGE plpgsql;



-- added
select define_function_args('bulk_mail__delete','delete__bulk_mail_id');

--
-- procedure bulk_mail__delete/1
--
CREATE OR REPLACE FUNCTION bulk_mail__delete(
   bulk_mail__delete__bulk_mail_id integer
) RETURNS integer AS $$
DECLARE
BEGIN

    delete
    from bulk_mail_messages
    where bulk_mail_messages.bulk_mail_id = bulk_mail__delete__bulk_mail_id;

    perform acs_object__delete(bulk_mail__delete__bulk_mail_id);

END;

$$ LANGUAGE plpgsql;

