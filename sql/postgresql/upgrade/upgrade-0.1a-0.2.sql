-- create the new query column as type 'text'
alter table bulk_mail_messages add column query2 text;

alter table bulk_mail_messages alter column query2 set not null;

-- update the rows
update bulk_mail_messages set query2 = query;

-- drop the old column
alter table bulk_mail_messages drop column query cascade;

-- rename the new column ot the correct name
alter table bulk_mail_messages rename column query2 to query;
