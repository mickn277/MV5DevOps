-- LV_ARCHIVE
SELECT csv2column(column_value,1,';') d, csv2column(column_value,2,';') r
FROM TABLE(csv2Table('Yes;-1,No;0'));
