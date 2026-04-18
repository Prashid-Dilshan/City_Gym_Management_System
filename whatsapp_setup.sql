-- City Gym WhatsApp Integration Database Updates
-- Run this script to ensure all required columns exist

-- Step 1: Add whatsapp column to member_details if it doesn't exist
ALTER TABLE member_details ADD COLUMN IF NOT EXISTS whatsapp varchar(20);

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
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 4: Ensure membership_details has all columns
ALTER TABLE membership_details MODIFY COLUMN status VARCHAR(20) DEFAULT 'ACTIVE';

-- Step 5: Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_membership_end_date ON membership_details(end_date);
CREATE INDEX IF NOT EXISTS idx_membership_status ON membership_details(status);

-- Verification queries
SELECT 'Tables Created Successfully' as status;
SHOW TABLES LIKE 'payment_history';
SHOW TABLES LIKE 'whatsapp_notifications';
DESCRIBE member_details;

