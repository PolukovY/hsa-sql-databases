use test;

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

