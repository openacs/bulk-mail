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

-- Get rid of old table
drop table bulk_mail_messages;

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
    send_date                   date
                                default now()
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
