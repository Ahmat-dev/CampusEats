-- =====================================================================
-- CampusEats Seed / Demo Data
-- Team Apex | SCSM2223 PR3
-- Run this AFTER schema.sql. Populates realistic data so the PR3 demo
-- never shows empty screens or hardcoded values, per the rubric.
--
-- All demo accounts share the password: Passw0rd!
-- (bcrypt hash generated locally — swap in your own before real deploy)
-- =====================================================================

USE campuseats;

SET @DEMO_HASH = '$2b$12$izmLfyS6NXDGoC5UPCbRcuqrjYZKygN5OzVQSD9bNrgvpah3FMT9i';

-- ---------------------------------------------------------------------
-- USERS: 1 admin, 3 vendor owners, 5 student customers
-- ---------------------------------------------------------------------
INSERT INTO `User` (`name`, `email`, `password_hash`, `role`, `phone`) VALUES
('Hishamuddin Asmuni', 'admin@campuseats.utm.my',      @DEMO_HASH, 'admin',    '011-1000001'),
('Kak Lah',             'kaklah@campuseats.utm.my',    @DEMO_HASH, 'vendor',   '011-2000001'),
('Sheikh Rahman',       'sheikh@campuseats.utm.my',    @DEMO_HASH, 'vendor',   '011-2000002'),
('Arked Lestari Mgmt',  'lestari@campuseats.utm.my',   @DEMO_HASH, 'vendor',   '011-2000003'),
('Muaz Ibne Ahmed',     'muaz@graduate.utm.my',        @DEMO_HASH, 'customer', '011-3000001'),
('Imtiaj Ahmed',        'imtiaj@graduate.utm.my',      @DEMO_HASH, 'customer', '011-3000002'),
('Anas Ahmed Hisham',   'anas@graduate.utm.my',        @DEMO_HASH, 'customer', '011-3000003'),
('Ahmat Mahamat',       'ahmat@graduate.utm.my',       @DEMO_HASH, 'customer', '011-3000004'),
('Siti Nurhaliza',      'siti.n@graduate.utm.my',      @DEMO_HASH, 'customer', '011-3000005');

-- ---------------------------------------------------------------------
-- VENDORS (owner_id references the vendor-role users above: ids 2,3,4)
-- ---------------------------------------------------------------------
INSERT INTO `Vendor` (`owner_id`, `name`, `location`, `opening_hours`, `avg_wait_mins`, `is_active`) VALUES
(2, 'Kak Lah Nasi Lemak',    'UTM Arkib Merdeka',     '7:00 AM - 4:00 PM',  15, 1),
(3, 'Sheikh Chicken Rice',   'UTM Hub Student Cafe',  '10:00 AM - 8:00 PM', 10, 1),
(4, 'Arked Lestari Noodles', 'UTM Arked Lestari',     '8:00 AM - 6:00 PM',  12, 1);

-- ---------------------------------------------------------------------
-- MENU ITEMS (10+ across Rice / Noodles / Drinks / Snacks)
-- ---------------------------------------------------------------------
INSERT INTO `MenuItem` (`vendor_id`, `name`, `description`, `price`, `category`, `in_stock`) VALUES
-- Kak Lah Nasi Lemak (vendor_id = 1)
(1, 'Nasi Lemak Ayam Regular', 'Crispy chicken, fragrant coconut rice, signature sambal.', 5.50, 'Rice',   1),
(1, 'Nasi Lemak Ayam Rendang', 'Coconut rice with slow-cooked beef rendang.',              7.50, 'Rice',   1),
(1, 'Teh Ais Kaw',             'Frothy, thick local iced pulled tea with condensed milk.', 2.00, 'Drinks', 1),
(1, 'Keropok Lekor Crispy',    'Authentic crispy fish crackers served with sweet chili.',  3.00, 'Snacks', 1),

-- Sheikh Chicken Rice (vendor_id = 2)
(2, 'Hainanese Chicken Rice',  'Poached chicken, fragrant rice, ginger-chili dip.',        6.50, 'Rice',   1),
(2, 'Roasted Chicken Rice',    'Crispy-skin roasted chicken over seasoned rice.',          7.00, 'Rice',   1),
(2, 'Barley Water',            'Chilled homemade barley drink with a hint of lime.',       2.50, 'Drinks', 1),
(2, 'Chicken Wonton Soup',     'Light broth with pork-free chicken wontons.',               4.50, 'Snacks', 1),

-- Arked Lestari Noodles (vendor_id = 3)
(3, 'Mee Goreng Mamak',        'Wok-fried local noodles spiced with sweet soy paste.',     4.50, 'Noodles',1),
(3, 'Maggi Goreng Telur',      'Instant noodles wok-fried with egg and vegetables.',        4.00, 'Noodles',1),
(3, 'Curry Laksa',             'Spicy coconut curry noodle soup with tofu puffs.',          6.00, 'Noodles',1),
(3, 'Iced Milo',               'Classic chilled chocolate malt drink.',                     2.20, 'Drinks', 1),
(3, 'Popiah Basah',            'Fresh spring rolls with turnip and peanut sauce.',          3.50, 'Snacks', 0); -- out of stock, for demo edge-case

-- ---------------------------------------------------------------------
-- ORDERS + ORDER ITEMS (mix of statuses so vendor dashboard is realistic)
-- ---------------------------------------------------------------------

-- Order 1: Muaz (user 5) orders from Kak Lah (vendor 1) -- COLLECTED
INSERT INTO `Order` (`user_id`, `vendor_id`, `status`, `total`, `pickup_at`, `created_at`) VALUES
(5, 1, 'collected', 8.50, '12:30 PM - 12:45 PM', NOW() - INTERVAL 2 DAY);
SET @order1 = LAST_INSERT_ID();
INSERT INTO `OrderItem` (`order_id`, `menu_item_id`, `qty`, `unit_price`) VALUES
(@order1, 1, 1, 5.50),   -- Nasi Lemak Ayam Regular
(@order1, 4, 1, 3.00);   -- Keropok Lekor Crispy

-- Order 2: Imtiaj (user 6) orders from Sheikh Chicken Rice (vendor 2) -- READY
INSERT INTO `Order` (`user_id`, `vendor_id`, `status`, `total`, `pickup_at`, `created_at`) VALUES
(6, 2, 'ready', 9.00, '1:00 PM - 1:15 PM', NOW() - INTERVAL 3 HOUR);
SET @order2 = LAST_INSERT_ID();
INSERT INTO `OrderItem` (`order_id`, `menu_item_id`, `qty`, `unit_price`) VALUES
(@order2, 5, 1, 6.50),   -- Hainanese Chicken Rice
(@order2, 7, 1, 2.50);   -- Barley Water

-- Order 3: Anas (user 7) orders from Arked Lestari (vendor 3) -- PREPARING
INSERT INTO `Order` (`user_id`, `vendor_id`, `status`, `total`, `pickup_at`, `created_at`) VALUES
(7, 3, 'preparing', 10.50, '12:45 PM - 1:00 PM', NOW() - INTERVAL 10 MINUTE);
SET @order3 = LAST_INSERT_ID();
INSERT INTO `OrderItem` (`order_id`, `menu_item_id`, `qty`, `unit_price`) VALUES
(@order3, 9, 1, 4.50),    -- Mee Goreng Mamak
(@order3, 11, 1, 6.00);   -- Curry Laksa

-- Order 4: Ahmat (user 8) just placed an order at Kak Lah -- PLACED
INSERT INTO `Order` (`user_id`, `vendor_id`, `status`, `total`, `pickup_at`, `created_at`) VALUES
(8, 1, 'placed', 7.50, '1:15 PM - 1:30 PM', NOW());
SET @order4 = LAST_INSERT_ID();
INSERT INTO `OrderItem` (`order_id`, `menu_item_id`, `qty`, `unit_price`) VALUES
(@order4, 2, 1, 7.50);    -- Nasi Lemak Ayam Rendang

-- Order 5: Siti (user 9) history order at Sheikh Chicken Rice -- COLLECTED
INSERT INTO `Order` (`user_id`, `vendor_id`, `status`, `total`, `pickup_at`, `created_at`) VALUES
(9, 2, 'collected', 7.00, '12:00 PM - 12:15 PM', NOW() - INTERVAL 5 DAY);
SET @order5 = LAST_INSERT_ID();
INSERT INTO `OrderItem` (`order_id`, `menu_item_id`, `qty`, `unit_price`) VALUES
(@order5, 6, 1, 7.00);    -- Roasted Chicken Rice

-- ---------------------------------------------------------------------
-- REVIEWS (only for collected orders — realistic behaviour)
-- The AFTER INSERT trigger on Review automatically recalculates
-- Vendor.rating_avg, so you don't need to update it manually.
-- ---------------------------------------------------------------------
INSERT INTO `Review` (`user_id`, `vendor_id`, `rating`, `comment`, `created_at`) VALUES
(5, 1, 5, 'Best nasi lemak on campus, sambal is perfect!', NOW() - INTERVAL 2 DAY),
(9, 2, 4, 'Chicken was juicy, rice could be a bit more fragrant.', NOW() - INTERVAL 5 DAY),
(7, 3, 5, 'Laksa broth is so rich, worth the walk to Arked Lestari.', NOW() - INTERVAL 1 DAY);

-- ---------------------------------------------------------------------
-- Sanity check queries (optional — run manually to verify seeding)
-- ---------------------------------------------------------------------
-- SELECT v.name, v.rating_avg, COUNT(r.id) AS review_count
-- FROM Vendor v LEFT JOIN Review r ON r.vendor_id = v.id
-- GROUP BY v.id;
--
-- SELECT o.id, u.name AS customer, v.name AS vendor, o.status, o.total
-- FROM `Order` o
-- JOIN User u ON u.id = o.user_id
-- JOIN Vendor v ON v.id = o.vendor_id
-- ORDER BY o.created_at DESC;
