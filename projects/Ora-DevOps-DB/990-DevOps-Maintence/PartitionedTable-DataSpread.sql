-- --------------------------------------------------------------------------------
-- Check the spread of data created by the partitions is even for best performance.
-- --------------------------------------------------------------------------------
SELECT
    tp.table_name,
    tp.partition_name,
    tp.high_value,
    tp.num_rows,
    tp.blocks,
    tp.empty_blocks,
    tp.avg_row_len
FROM
    user_tab_partitions tp
;