select
trunc(sysdate) + (date_time - trunc(date_time, 'dd')) t, 
value1, 
to_char(date_time, 'ddmm') ddmm
from ub_value
where date_time between date '2015-01-12' and date '2015-01-16' 
order by
ddmm  , t