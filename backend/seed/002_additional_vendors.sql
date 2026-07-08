-- seed/002_additional_vendors.sql
-- Adds 2 more demo vendors (Sheikh Chicken Rice & Arked Lestari Noodles)
-- with realistic menu items for the demo.
-- Password for new vendor accounts: password123

-- Vendor owner accounts (INSERT IGNORE is safe due to UNIQUE email constraint)
INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
    ('Sheikh Rahman',      'vendor2@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Arked Lestari Mgmt', 'vendor3@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor');

-- Sheikh Chicken Rice
INSERT INTO vendors (owner_id, name, location, opening_hours, prep_time_mins, is_active, status)
SELECT u.id, 'Sheikh Chicken Rice', 'UTM Hub Student Cafe', '10:00 AM - 8:00 PM', 10, 1, 'approved'
FROM users u
WHERE u.email = 'vendor2@campuseats.test'
  AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Sheikh Chicken Rice');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Hainanese Chicken Rice', 'Poached chicken, fragrant rice, ginger-chili dip.', 6.50, 'Rice', 1
FROM vendors v WHERE v.name = 'Sheikh Chicken Rice'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Hainanese Chicken Rice');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Roasted Chicken Rice', 'Crispy-skin roasted chicken over seasoned rice.', 7.00, 'Rice', 1
FROM vendors v WHERE v.name = 'Sheikh Chicken Rice'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Roasted Chicken Rice');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Barley Water', 'Chilled homemade barley drink with a hint of lime.', 2.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'Sheikh Chicken Rice'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Barley Water');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Chicken Wonton Soup', 'Light broth with pork-free chicken wontons.', 4.50, 'Soup', 1
FROM vendors v WHERE v.name = 'Sheikh Chicken Rice'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Chicken Wonton Soup');

-- Arked Lestari Noodles
INSERT INTO vendors (owner_id, name, location, opening_hours, prep_time_mins, is_active, status)
SELECT u.id, 'Arked Lestari Noodles', 'UTM Arked Lestari', '8:00 AM - 6:00 PM', 12, 1, 'approved'
FROM users u
WHERE u.email = 'vendor3@campuseats.test'
  AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Arked Lestari Noodles');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Mee Goreng Mamak', 'Wok-fried local noodles spiced with sweet soy paste.', 4.50, 'Noodles', 1
FROM vendors v WHERE v.name = 'Arked Lestari Noodles'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Mee Goreng Mamak');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Maggi Goreng Telur', 'Instant noodles wok-fried with egg and vegetables.', 4.00, 'Noodles', 1
FROM vendors v WHERE v.name = 'Arked Lestari Noodles'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Maggi Goreng Telur');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Curry Laksa', 'Spicy coconut curry noodle soup with tofu puffs.', 6.00, 'Noodles', 1
FROM vendors v WHERE v.name = 'Arked Lestari Noodles'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Curry Laksa');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Iced Milo', 'Classic chilled chocolate malt drink.', 2.20, 'Drinks', 1
FROM vendors v WHERE v.name = 'Arked Lestari Noodles'
  AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Iced Milo');
