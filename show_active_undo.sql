-- show per active transaction the size of the undo and some session information
-- more session information can be retrieved by sessinfo2.sql

set linesize 250
set pages 50000

column username format a30
column osuser format a30
column machine format a30
column program format a50
column used_undo_mb format 9G999G999D99
column start_date_str format a14

select
  ses.inst_id,
  ses.sid,
  ses.serial#,
  ses.username,
  ses.osuser,
  ses.machine,
  ses.program,
  to_char(tra.start_date, 'DD/MM HH24:MI:SS') as start_date_str,
  tra.used_ublk * 8 / 1024 as used_undo_mb,
  tra.status
from
  gv$session ses
    join gv$transaction tra
      on ( ses.inst_id = tra.inst_id
           and ses.taddr = tra.addr
         )
;