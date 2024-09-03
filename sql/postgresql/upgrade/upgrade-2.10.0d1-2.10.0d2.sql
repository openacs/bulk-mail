begin;

alter table bulk_mail_messages drop constraint bm_messages_bulk_mail_id_fk;
alter table bulk_mail_messages add constraint bm_messages_bulk_mail_id_fk foreign key (bulk_mail_id) references acs_objects (object_id) on delete cascade;

alter table bulk_mail_messages drop constraint bm_messages_package_id_fk;
alter table bulk_mail_messages add constraint bm_messages_package_id_fk foreign key (package_id) references apm_packages (package_id) on delete cascade;

end;
