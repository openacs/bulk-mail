---
--- reduce sequential reads by sweeper
---
CREATE INDEX bm_messages_status_idx ON bulk_mail_messages(status);
