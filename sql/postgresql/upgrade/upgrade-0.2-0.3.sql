-- send_date needs to be of type timestampz

alter table bulk_mail_messages alter column send_date drop not null;
alter table bulk_mail_messages add column new_send_date timestamptz;
alter table bulk_mail_messages alter column new_send_date set default now();
update bulk_mail_messages set new_send_date = send_date;
alter table bulk_mail_messages alter column new_send_date set not null;
alter table bulk_mail_messages drop column send_date;
alter table bulk_mail_messages rename column new_send_date to send_date;

select define_function_args('bulk_mail__new','bulk_mail_id,package_id,send_date,date_format,status;pending,from_addr,subject,reply_to,extra_headers,message,query,creation_date;now(),creation_user,creation_ip,context_id');

