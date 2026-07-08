-- seed/003_remaining_mock_vendors.sql

INSERT IGNORE INTO users (name, email, password_hash, role) VALUES
    ('Mee Bandung Pak Man Mgmt', 'vendor4@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Al-Amin Grill Mgmt', 'vendor5@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Uncle Tan Mgmt', 'vendor6@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Vegetarian Delight Mgmt', 'vendor7@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('The Sip Spot Mgmt', 'vendor8@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Mamak Corner Mgmt', 'vendor9@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Sakura Bento Mgmt', 'vendor10@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor'),
    ('Sweet Treats Mgmt', 'vendor11@campuseats.test', '$argon2id$v=19$m=65536,t=4,p=1$eFJuYkRvLmZEZ1VhQTQwQQ$G6pPXcmk1caLvV5S0/ywR4SXt85YpG4MLe/RNV9IQWM', 'vendor');

-- Vendor 4
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Mee Bandung Pak Man', 'UTM Cafe Arked - Counter A, Stall 3', '7:30 AM - 5:00 PM', '/images/mee_bandung.jpg', 12, 1, 'approved'
FROM users u WHERE u.email = 'vendor4@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Mee Bandung Pak Man');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Mee Bandung', 'Spicy noodle soup with prawns, egg & vegetables', 6.00, 'Noodles', 1
FROM vendors v WHERE v.name = 'Mee Bandung Pak Man' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Mee Bandung');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Mee Goreng Mamak', 'Wok-fried yellow noodles with a tangy spicy kick', 5.50, 'Noodles', 1
FROM vendors v WHERE v.name = 'Mee Bandung Pak Man' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Mee Goreng Mamak');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Maggi Goreng', 'Stir-fried instant noodles with egg and vegetables', 5.00, 'Noodles', 1
FROM vendors v WHERE v.name = 'Mee Bandung Pak Man' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Maggi Goreng');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Fishball Soup', 'Light broth with fishballs and greens', 4.50, 'Noodles', 1
FROM vendors v WHERE v.name = 'Mee Bandung Pak Man' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Fishball Soup');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Iced Lemon Tea', 'Refreshing chilled lemon tea', 2.00, 'Drinks', 1
FROM vendors v WHERE v.name = 'Mee Bandung Pak Man' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Iced Lemon Tea');

-- Vendor 5
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Restoran Al-Amin Grill', 'UTM Cafe Arked - Counter A, Stall 5', '10:00 AM - 9:00 PM', '/images/al_amin_grill.jpg', 20, 1, 'approved'
FROM users u WHERE u.email = 'vendor5@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Restoran Al-Amin Grill');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Grilled Chicken Chop', 'Grilled chicken thigh with black pepper sauce, fries & coleslaw', 9.50, 'Western', 1
FROM vendors v WHERE v.name = 'Restoran Al-Amin Grill' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Grilled Chicken Chop');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Fried Chicken Set', 'Crispy fried chicken with rice and gravy', 7.50, 'Western', 1
FROM vendors v WHERE v.name = 'Restoran Al-Amin Grill' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Fried Chicken Set');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Fish & Chips', 'Battered fish fillet with fries and tartar sauce', 8.50, 'Western', 1
FROM vendors v WHERE v.name = 'Restoran Al-Amin Grill' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Fish & Chips');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Beef Burger', 'Grilled beef patty with cheese, lettuce & special sauce', 7.00, 'Western', 1
FROM vendors v WHERE v.name = 'Restoran Al-Amin Grill' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Beef Burger');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Iced Milo', 'Chocolate malt drink served cold', 2.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'Restoran Al-Amin Grill' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Iced Milo');

-- Vendor 6
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Uncle Tan Chicken Rice', 'UTM Arkib - Counter B, Stall 2', '8:00 AM - 3:00 PM', '/images/uncle_tan.jpg', 15, 1, 'approved'
FROM users u WHERE u.email = 'vendor6@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Uncle Tan Chicken Rice');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Hainanese Chicken Rice', 'Steamed chicken with fragrant rice & chili sauce', 6.50, 'Rice', 1
FROM vendors v WHERE v.name = 'Uncle Tan Chicken Rice' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Hainanese Chicken Rice');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Roasted Chicken Rice', 'Roasted chicken with fragrant rice', 6.50, 'Rice', 1
FROM vendors v WHERE v.name = 'Uncle Tan Chicken Rice' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Roasted Chicken Rice');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Char Siew Rice', 'BBQ pork with rice', 7.00, 'Rice', 0
FROM vendors v WHERE v.name = 'Uncle Tan Chicken Rice' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Char Siew Rice');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Soy Sauce Egg', 'Braised egg in savory soy sauce', 1.50, 'Snacks', 1
FROM vendors v WHERE v.name = 'Uncle Tan Chicken Rice' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Soy Sauce Egg');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Chinese Tea', 'Traditional hot Chinese tea', 1.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'Uncle Tan Chicken Rice' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Chinese Tea');

-- Vendor 7
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Vegetarian Delight', 'UTM Arkib - Counter C, Stall 1', '7:00 AM - 4:00 PM', '/images/veg_delight.jpg', 10, 1, 'approved'
FROM users u WHERE u.email = 'vendor7@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Vegetarian Delight');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Vegetarian Fried Rice', 'Fried rice with mixed vegetables and mock meat', 5.00, 'Vegetarian', 1
FROM vendors v WHERE v.name = 'Vegetarian Delight' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Vegetarian Fried Rice');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Tofu & Vegetable Soup', 'Light soup with tofu and seasonal greens', 4.50, 'Vegetarian', 1
FROM vendors v WHERE v.name = 'Vegetarian Delight' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Tofu & Vegetable Soup');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Mock Meat Noodles', 'Stir-fried noodles with plant-based protein', 5.50, 'Vegetarian', 1
FROM vendors v WHERE v.name = 'Vegetarian Delight' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Mock Meat Noodles');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Herbal Tea', 'House-brewed herbal tea', 2.00, 'Drinks', 1
FROM vendors v WHERE v.name = 'Vegetarian Delight' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Herbal Tea');

-- Vendor 8
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'The Sip Spot', 'UTM Cafe Arked - Kiosk 2', '9:00 AM - 8:00 PM', '/images/sip_spot.jpg', 5, 1, 'approved'
FROM users u WHERE u.email = 'vendor8@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'The Sip Spot');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Brown Sugar Boba Milk', 'Fresh milk with brown sugar pearls', 6.00, 'Drinks', 1
FROM vendors v WHERE v.name = 'The Sip Spot' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Brown Sugar Boba Milk');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Taro Milk Tea', 'Creamy taro flavored milk tea', 5.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'The Sip Spot' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Taro Milk Tea');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Fresh Lime Juice', 'Freshly squeezed lime juice', 3.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'The Sip Spot' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Fresh Lime Juice');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Crispy Popcorn Chicken', 'Bite-sized fried chicken snack', 5.00, 'Snacks', 1
FROM vendors v WHERE v.name = 'The Sip Spot' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Crispy Popcorn Chicken');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'French Fries', 'Golden crispy fries with seasoning', 4.00, 'Snacks', 1
FROM vendors v WHERE v.name = 'The Sip Spot' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'French Fries');

-- Vendor 9
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Mamak Corner', 'UTM Cafe Arked - Counter B, Stall 9', '24 hours', '/images/mamak_corner.jpg', 15, 1, 'approved'
FROM users u WHERE u.email = 'vendor9@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Mamak Corner');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Roti Canai', 'Flaky flatbread served with dhal & curry', 2.00, 'Snacks', 1
FROM vendors v WHERE v.name = 'Mamak Corner' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Roti Canai');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Roti Telur', 'Roti canai with egg', 2.50, 'Snacks', 1
FROM vendors v WHERE v.name = 'Mamak Corner' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Roti Telur');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Nasi Kandar', 'Steamed rice with mixed curries & sides', 7.00, 'Rice', 1
FROM vendors v WHERE v.name = 'Mamak Corner' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Nasi Kandar');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Teh Tarik', 'Frothy pulled milk tea', 2.20, 'Drinks', 1
FROM vendors v WHERE v.name = 'Mamak Corner' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Teh Tarik');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Mee Goreng Basah', 'Wet-style fried noodles with gravy', 5.50, 'Noodles', 1
FROM vendors v WHERE v.name = 'Mamak Corner' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Mee Goreng Basah');

-- Vendor 10
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Sakura Bento', 'UTM Arkib - Counter D, Stall 4', '11:00 AM - 8:00 PM', '/images/sakura_bento.jpg', 18, 1, 'approved'
FROM users u WHERE u.email = 'vendor10@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Sakura Bento');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Chicken Katsu Bento', 'Crispy chicken cutlet with rice & pickles', 10.00, 'Japanese', 1
FROM vendors v WHERE v.name = 'Sakura Bento' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Chicken Katsu Bento');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Salmon Teriyaki Bento', 'Grilled salmon glazed with teriyaki sauce', 12.50, 'Japanese', 1
FROM vendors v WHERE v.name = 'Sakura Bento' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Salmon Teriyaki Bento');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'California Roll (8pcs)', 'Crab stick, cucumber & avocado sushi roll', 8.00, 'Japanese', 1
FROM vendors v WHERE v.name = 'Sakura Bento' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'California Roll (8pcs)');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Miso Soup', 'Traditional Japanese soybean soup', 3.00, 'Japanese', 1
FROM vendors v WHERE v.name = 'Sakura Bento' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Miso Soup');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Green Tea', 'Hot or cold Japanese green tea', 2.50, 'Drinks', 1
FROM vendors v WHERE v.name = 'Sakura Bento' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Green Tea');

-- Vendor 11
INSERT INTO vendors (owner_id, name, location, opening_hours, image_url, prep_time_mins, is_active, status)
SELECT u.id, 'Sweet Treats Bakery', 'UTM Cafe Arked - Kiosk 5', '8:00 AM - 6:00 PM', '/images/sweet_treats.jpg', 8, 1, 'approved'
FROM users u WHERE u.email = 'vendor11@campuseats.test' AND NOT EXISTS (SELECT 1 FROM vendors WHERE name = 'Sweet Treats Bakery');

INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Chocolate Croissant', 'Buttery croissant filled with chocolate', 3.50, 'Dessert', 1
FROM vendors v WHERE v.name = 'Sweet Treats Bakery' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Chocolate Croissant');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Chocolate Chip Cookie', 'Freshly baked cookie', 2.00, 'Dessert', 1
FROM vendors v WHERE v.name = 'Sweet Treats Bakery' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Chocolate Chip Cookie');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Red Velvet Cupcake', 'Moist cupcake with cream cheese frosting', 4.00, 'Dessert', 1
FROM vendors v WHERE v.name = 'Sweet Treats Bakery' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Red Velvet Cupcake');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Iced Caramel Latte', 'Chilled espresso with caramel and milk', 5.00, 'Drinks', 1
FROM vendors v WHERE v.name = 'Sweet Treats Bakery' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Iced Caramel Latte');
INSERT INTO menu_items (vendor_id, name, description, price, category, in_stock)
SELECT v.id, 'Banana Bread Slice', 'Homemade moist banana bread', 3.00, 'Dessert', 0
FROM vendors v WHERE v.name = 'Sweet Treats Bakery' AND NOT EXISTS (SELECT 1 FROM menu_items WHERE vendor_id = v.id AND name = 'Banana Bread Slice');
