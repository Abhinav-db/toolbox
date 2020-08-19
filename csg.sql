--v$sql
--v$session

select s.username,s.event,s.inst_id,s.seconds_in_wait
,s.sql_id from gv$session s,gv$sql st where s.username
='TCZ87900177' and s.sql_id=st.sql_id and st.sql_text like
'%OHI_HIST_ITEM%';

select count(*),owner from gv$access where
object like '%OHI_HIST_ITEM' group by owner;

select distinct sql_id from v$sql where sql_text like '%OHI_HIST_ITEM';

select sid,machine,username,osuser,event,to_char(logon_time,'dd/mm/yy hh24:mi:ss') from gv$session
where sql_id in (select distinct sql_id from v$sql where sql_text like '%OHI_HIST_ITEM%');

col sql_text for a60 wrap
set verify off
set pagesize 999
set lines 155
col username format a13
col prog format a22
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col avg_pio format 9,999,999.99
col avg_lio format 999,999,999
col etime format 9,999,999.99

select sql_id, child_number, plan_hash_value plan_hash, executions execs,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s
where upper(sql_text) like upper(nvl('%&sql_text%',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
order by 1, 2, 3
/

--/*SEARCH THE SQL_ID BASED ON THE SQL_TEXT*/

col sql_text for a60 wrap
set verify off
set pagesize 999
set lines 155
col username format a13
col prog format a22
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col avg_pio format 9,999,999.99
col avg_lio format 999,999,999
col etime format 9,999,999.99

select sql_id, child_number, plan_hash_value plan_hash, executions execs,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio
from v$sql s
where upper(sql_text) like upper(nvl('%&sql_text%',sql_text))
and sql_text not like '%from v$sql where sql_text like OHI_HIST_ITEM%'
order by 5

--/*PLAN CHANGE*/

set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3
/
