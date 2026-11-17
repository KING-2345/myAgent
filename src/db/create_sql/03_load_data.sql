USE olist;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(customer_id, customer_unique_id, @zip, customer_city, customer_state)
SET customer_zip_code_prefix = LPAD(@zip, 5, '0');

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp,
 @approved, @carrier, @delivered, order_estimated_delivery_date)
SET order_approved_at             = NULLIF(@approved,  ''),
    order_delivered_carrier_date  = NULLIF(@carrier,   ''),
    order_delivered_customer_date = NULLIF(@delivered, '');

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(product_id, @category, @name_len, @desc_len, @photos,
 @weight, @length, @height, @width)
SET product_category_name      = NULLIF(@category, ''),
    product_name_lenght        = NULLIF(@name_len, ''),
    product_description_lenght = NULLIF(@desc_len, ''),
    product_photos_qty         = NULLIF(@photos,   ''),
    product_weight_g           = NULLIF(@weight,   ''),
    product_length_cm          = NULLIF(@length,   ''),
    product_height_cm          = NULLIF(@height,   ''),
    product_width_cm           = NULLIF(@width,    '');

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(seller_id, @zip, seller_city, seller_state)
SET seller_zip_code_prefix = LPAD(@zip, 5, '0');

-- 这个文件是 LF 换行
LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, order_item_id, product_id, seller_id,
 shipping_limit_date, price, freight_value);

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_order_payments_dataset.csv'
INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(order_id, payment_sequential, payment_type,
 payment_installments, payment_value);

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(review_id, order_id, review_score, @title, @message,
 review_creation_date, review_answer_timestamp)
SET review_comment_title   = NULLIF(@title,   ''),
    review_comment_message = NULLIF(@message, '');

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(product_category_name, product_category_name_english);

LOAD DATA LOCAL INFILE 'D:/VM_share/archive/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(@zip, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
SET geolocation_zip_code_prefix = LPAD(@zip, 5, '0');

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'customers' AS t, COUNT(*) n FROM customers
UNION ALL SELECT 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'products',       COUNT(*) FROM products
UNION ALL SELECT 'sellers',        COUNT(*) FROM sellers
UNION ALL SELECT 'order_items',    COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',  COUNT(*) FROM order_reviews
UNION ALL SELECT 'geolocation',    COUNT(*) FROM geolocation;

