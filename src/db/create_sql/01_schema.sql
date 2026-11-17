CREATE DATABASE IF NOT EXISTS olist
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE olist;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS order_reviews;
DROP TABLE IF EXISTS order_payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS geolocation;
DROP TABLE IF EXISTS product_category_translation;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. 客户
CREATE TABLE customers (
  customer_id              CHAR(32)     NOT NULL COMMENT '订单级客户ID，每个订单唯一',
  customer_unique_id       CHAR(32)     NOT NULL COMMENT '真实客户ID，跨订单唯一；复购/RFM 用这个',
  customer_zip_code_prefix CHAR(5)      NOT NULL COMMENT '邮编前5位',
  customer_city            VARCHAR(64)  NOT NULL COMMENT '城市',
  customer_state           CHAR(2)      NOT NULL COMMENT '州简称，如 SP / RJ',
  PRIMARY KEY (customer_id),
  KEY idx_customers_unique (customer_unique_id),
  KEY idx_customers_state  (customer_state),
  KEY idx_customers_zip    (customer_zip_code_prefix)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='客户维表';

-- 2. 订单
CREATE TABLE orders (
  order_id                      CHAR(32)    NOT NULL COMMENT '订单ID',
  customer_id                   CHAR(32)    NOT NULL COMMENT '订单级客户ID',
  order_status                  VARCHAR(20) NOT NULL COMMENT 'delivered/shipped/canceled/...',
  order_purchase_timestamp      DATETIME    NOT NULL COMMENT '下单时间',
  order_approved_at             DATETIME    NULL     COMMENT '支付审批时间',
  order_delivered_carrier_date  DATETIME    NULL     COMMENT '交承运商时间',
  order_delivered_customer_date DATETIME    NULL     COMMENT '客户签收时间',
  order_estimated_delivery_date DATETIME    NOT NULL COMMENT '预计送达时间',
  PRIMARY KEY (order_id),
  KEY idx_orders_customer  (customer_id),
  KEY idx_orders_purchase  (order_purchase_timestamp),
  KEY idx_orders_status    (order_status),
  KEY idx_orders_delivered (order_delivered_customer_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='订单主表';

-- 3. 商品（源字段 lenght 拼写有误，保持原样）
CREATE TABLE products (
  product_id                 CHAR(32)          NOT NULL COMMENT '商品ID',
  product_category_name      VARCHAR(64)       NULL     COMMENT '葡语类目名',
  product_name_lenght        SMALLINT UNSIGNED NULL     COMMENT '商品名长度',
  product_description_lenght SMALLINT UNSIGNED NULL     COMMENT '描述长度',
  product_photos_qty         TINYINT UNSIGNED  NULL     COMMENT '图片数量',
  product_weight_g           INT UNSIGNED      NULL     COMMENT '重量(克)',
  product_length_cm          SMALLINT UNSIGNED NULL     COMMENT '长度(cm)',
  product_height_cm          SMALLINT UNSIGNED NULL     COMMENT '高度(cm)',
  product_width_cm           SMALLINT UNSIGNED NULL     COMMENT '宽度(cm)',
  PRIMARY KEY (product_id),
  KEY idx_products_category (product_category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='商品维表';

-- 4. 卖家
CREATE TABLE sellers (
  seller_id              CHAR(32)    NOT NULL COMMENT '卖家ID',
  seller_zip_code_prefix CHAR(5)     NOT NULL COMMENT '邮编前5位',
  seller_city            VARCHAR(64) NOT NULL COMMENT '城市',
  seller_state           CHAR(2)     NOT NULL COMMENT '州简称',
  PRIMARY KEY (seller_id),
  KEY idx_sellers_state (seller_state),
  KEY idx_sellers_zip   (seller_zip_code_prefix)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='卖家维表';

-- 5. 订单商品明细
CREATE TABLE order_items (
  order_id            CHAR(32)         NOT NULL COMMENT '订单ID',
  order_item_id       SMALLINT UNSIGNED NOT NULL COMMENT '订单内行号，从 1 开始',
  product_id          CHAR(32)         NOT NULL COMMENT '商品ID',
  seller_id           CHAR(32)         NOT NULL COMMENT '卖家ID',
  shipping_limit_date DATETIME         NOT NULL COMMENT '发货截止时间',
  price               DECIMAL(10,2)    NOT NULL COMMENT '商品单价( BRL )',
  freight_value       DECIMAL(10,2)    NOT NULL DEFAULT 0.00 COMMENT '该行运费( BRL )',
  PRIMARY KEY (order_id, order_item_id),
  KEY idx_items_product (product_id),
  KEY idx_items_seller  (seller_id),
  KEY idx_items_shipping_limit (shipping_limit_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='订单商品明细';

-- 6. 支付流水
CREATE TABLE order_payments (
  order_id             CHAR(32)      NOT NULL COMMENT '订单ID',
  payment_sequential   SMALLINT UNSIGNED NOT NULL COMMENT '同一订单内的支付序号',
  payment_type         VARCHAR(20)   NOT NULL COMMENT 'credit_card/boleto/voucher/debit_card',
  payment_installments TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '分期数，0 表示未分期',
  payment_value        DECIMAL(10,2) NOT NULL COMMENT '本笔支付金额( BRL )',
  PRIMARY KEY (order_id, payment_sequential),
  KEY idx_payments_type (payment_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='订单支付流水';

-- 7. 评价（review_id 有重复，必须用联合主键）
CREATE TABLE order_reviews (
  review_id               CHAR(32)      NOT NULL COMMENT '评价ID（可重复）',
  order_id                CHAR(32)      NOT NULL COMMENT '订单ID',
  review_score            TINYINT UNSIGNED NOT NULL COMMENT '评分 1-5',
  review_comment_title    VARCHAR(255)  NULL     COMMENT '评价标题（葡语）',
  review_comment_message  TEXT          NULL     COMMENT '评价正文（葡语，可含换行）',
  review_creation_date    DATETIME      NOT NULL COMMENT '评价创建时间',
  review_answer_timestamp DATETIME      NOT NULL COMMENT '评价回复时间',
  PRIMARY KEY (review_id, order_id),
  KEY idx_reviews_order (order_id),
  KEY idx_reviews_score (review_score),
  KEY idx_reviews_creation (review_creation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='订单评价表';

-- 8. 类目翻译
CREATE TABLE product_category_translation (
  product_category_name         VARCHAR(64) NOT NULL COMMENT '葡语类目名',
  product_category_name_english VARCHAR(64) NOT NULL COMMENT '英文类目名',
  PRIMARY KEY (product_category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='商品类目葡->英翻译表';

-- 9. 邮编坐标（100 万行）
CREATE TABLE geolocation (
  geolocation_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增代理键',
  geolocation_zip_code_prefix CHAR(5)         NOT NULL COMMENT '邮编前5位',
  geolocation_lat             DECIMAL(10,8)   NOT NULL COMMENT '纬度',
  geolocation_lng             DECIMAL(11,8)   NOT NULL COMMENT '经度',
  geolocation_city            VARCHAR(64)     NOT NULL COMMENT '城市',
  geolocation_state           CHAR(2)         NOT NULL COMMENT '州简称',
  PRIMARY KEY (geolocation_id),
  KEY idx_geo_zip   (geolocation_zip_code_prefix),
  KEY idx_geo_state (geolocation_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='邮编前缀坐标表';