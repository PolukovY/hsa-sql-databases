## Init

```
use test;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP
) ENGINE=INNODB;

CREATE PROCEDURE populate_data()
BEGIN
    DECLARE i int DEFAULT 0;
    WHILE i <= 80000 DO
        if (MOD(i,2) >= 0) THEN
            INSERT INTO users (name, created_at) VALUES (CONCAT('name_', 1), NOW() - INTERVAL 1 MONTH);
            SET i = i + 1;
        END IF;
        if (MOD(i,2) < 0) THEN
            INSERT INTO users (name, created_at) VALUES (CONCAT('name_', 1), NOW());
            SET i = i + 1;
        END IF;
    END WHILE;
END;

call populate_data();
```

## Select without index

```
select * from users
where created_at BETWEEN '2006-09-28 00:00:00' AND '2006-09-28 23:59:59';
```

-- time 418 ms


## Select with index

```
ALTER TABLE users ADD INDEX (created_at);

select * from users
where created_at BETWEEN '2006-09-28 00:00:00' AND '2006-09-28 23:59:59';
```

-- time 258 ms

## Calc table size

```
SELECT
    TABLE_NAME AS `Table`,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
    information_schema.TABLES
WHERE
        TABLE_SCHEMA = "users"
ORDER BY
    (DATA_LENGTH + INDEX_LENGTH)
    DESC;
```

-- users table 4 MB

## Drop part of the data

```
select max(id) from users;

delete from users where id <= 40000;
```

-- users table 4 MB

## Execute OPTIMIZE

```
OPTIMIZE TABLE users;
```

-- https://dev.mysql.com/doc/refman/8.0/en/optimize-table.html
-- Result of optimization
-- test.users,optimize,note,"Table does not support optimize, doing recreate + analyze instead"
-- test.users,optimize,status,OK

## Try suggested recommendation

```
CREATE TABLE users_optimize LIKE users;
INSERT INTO users_optimize SELECT * FROM users;

SELECT TABLE_NAME AS "Table Name",
       table_rows AS "Quant of Rows", ROUND( (
                                                     data_length + index_length
                                                 ) /1024, 2 ) AS "Total Size Kb"
FROM information_schema.TABLES
WHERE information_schema.TABLES.table_schema = 'test'
LIMIT 0 , 30
```

-- 3104.00 kb


