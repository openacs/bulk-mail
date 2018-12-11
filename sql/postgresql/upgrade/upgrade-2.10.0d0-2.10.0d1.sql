---
--- reduce sequential reads by sweeper
---

DO $$
DECLARE
       v_found boolean;
BEGIN
       --
       -- Was the index already created?
       --
       -- In versions of PostgreSQL starting with 9.5, we could use
       -- "CREATE INDEX ... IF NOT EXISTS ..."

       SELECT exists(
          SELECT relname from pg_class
          WHERE relname ='bm_messages_status_idx'
       ) into v_found;

       if v_found IS FALSE then
          CREATE INDEX bm_messages_status_idx ON bulk_mail_messages(status);
       end if;

END$$;
