-- City Gym WhatsApp Integration Database Updates
-- Run this script on the existing gym_system database

USE gym_system;

-- Step 1: Add whatsapp column only if it does not already exist
SET @has_whatsapp := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'member_details'
    AND COLUMN_NAME = 'whatsapp'
);
SET @sql := IF(
  @has_whatsapp = 0,
  'ALTER TABLE member_details ADD COLUMN whatsapp VARCHAR(20)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 1b: Add birthday column only if it does not already exist
SET @has_birthday := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'member_details'
    AND COLUMN_NAME = 'birthday_date'
);
SET @sql := IF(
  @has_birthday = 0,
  'ALTER TABLE member_details ADD COLUMN birthday_date DATE',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Add payment tracking table
CREATE TABLE IF NOT EXISTS payment_history (
  id INT NOT NULL AUTO_INCREMENT,
  member_id INT NOT NULL,
  amount DOUBLE NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  months INT,
  status VARCHAR(20) DEFAULT 'COMPLETED',
  PRIMARY KEY (id),
  KEY member_id (member_id),
  CONSTRAINT payment_history_ibfk_1 FOREIGN KEY (member_id) REFERENCES member_details (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 3: Add notification tracking
CREATE TABLE IF NOT EXISTS whatsapp_notifications (
  id INT NOT NULL AUTO_INCREMENT,
  member_id INT NOT NULL,
  notification_type VARCHAR(50),
  sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20),
  message_sid VARCHAR(100),
  PRIMARY KEY (id),
  KEY member_id (member_id),
  CONSTRAINT notif_ibfk_1 FOREIGN KEY (member_id) REFERENCES member_details (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 4: Ensure membership_details has the expected default status
ALTER TABLE membership_details MODIFY COLUMN status VARCHAR(20) DEFAULT 'ACTIVE';

-- Step 5: Create indexes only if they do not already exist
SET @idx_end_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'membership_details'
    AND INDEX_NAME = 'idx_membership_end_date'
);
SET @sql := IF(
  @idx_end_exists = 0,
  'CREATE INDEX idx_membership_end_date ON membership_details(end_date)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_status_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'membership_details'
    AND INDEX_NAME = 'idx_membership_status'
);
SET @sql := IF(
  @idx_status_exists = 0,
  'CREATE INDEX idx_membership_status ON membership_details(status)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Verification queries
SELECT 'Tables Created Successfully' AS status;
SHOW TABLES LIKE 'payment_history';
SHOW TABLES LIKE 'whatsapp_notifications';
DESCRIBE member_details;
