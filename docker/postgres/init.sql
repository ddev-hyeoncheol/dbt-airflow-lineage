-- Marquez DB
CREATE USER marquez WITH PASSWORD 'marquez';
CREATE DATABASE marquez OWNER marquez;

-- Warehouse DB (DBT)
CREATE USER dbt WITH PASSWORD 'dbt';
CREATE DATABASE warehouse OWNER dbt;

-- 원본 테이블 및 샘플 데이터
\c warehouse dbt

-- 고객
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    region VARCHAR(50) NOT NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 상품
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 주문
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    ordered_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 주문 상세
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id),
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL
);

-- 고객 데이터
INSERT INTO customers (id, name, email, region, registered_at) VALUES
    (1,  '김민수', 'minsu.kim@example.com',    '서울', '2024-03-10 09:00:00'),
    (2,  '이지은', 'jieun.lee@example.com',    '부산', '2024-04-22 14:30:00'),
    (3,  '박정호', 'jungho.park@example.com',  '대전', '2024-05-15 11:00:00'),
    (4,  '최유진', 'yujin.choi@example.com',   '서울', '2024-06-01 16:45:00'),
    (5,  '정하늘', 'haneul.jung@example.com',  '인천', '2024-07-20 10:15:00'),
    (6,  '한소윤', 'soyun.han@example.com',    '대구', '2024-08-05 13:00:00'),
    (7,  '오태윤', 'taeyun.oh@example.com',    '서울', '2024-09-12 08:30:00'),
    (8,  '윤서현', 'seohyun.yun@example.com',  '광주', '2024-10-03 17:00:00'),
    (9,  '장민재', 'minjae.jang@example.com',  '부산', '2024-11-18 12:20:00'),
    (10, '송예린', 'yerin.song@example.com',   '서울', '2024-12-25 09:45:00');

-- 상품 데이터
INSERT INTO products (id, name, category, unit_price, is_active) VALUES
    (1,  '맥북 프로 14인치',  '전자기기',  2990000, TRUE),
    (2,  '맥북 에어 13인치',  '전자기기',  1790000, TRUE),
    (3,  '아이패드 프로',     '전자기기',  1499000, TRUE),
    (4,  '매직 키보드',       '주변기기',   399000, TRUE),
    (5,  '매직 마우스',       '주변기기',   129000, TRUE),
    (6,  '에어팟 프로',       '음향기기',   359000, TRUE),
    (7,  '스튜디오 디스플레이', '주변기기', 2299000, TRUE),
    (8,  'USB-C 허브',        '주변기기',    89000, TRUE),
    (9,  '아이폰 케이스',     '액세서리',    69000, TRUE),
    (10, '애플 펜슬',         '주변기기',   195000, TRUE),
    (11, '레트로 키보드',     '주변기기',   159000, FALSE),
    (12, '구형 마우스패드',   '액세서리',    25000, FALSE);

-- 주문 데이터
INSERT INTO orders (id, customer_id, status, ordered_at) VALUES
    (1,  1,  'completed',  '2025-01-05 10:30:00'),
    (2,  2,  'completed',  '2025-01-08 14:00:00'),
    (3,  1,  'completed',  '2025-01-12 09:15:00'),
    (4,  3,  'completed',  '2025-01-15 16:45:00'),
    (5,  4,  'completed',  '2025-01-20 11:00:00'),
    (6,  5,  'shipped',    '2025-02-01 08:30:00'),
    (7,  6,  'shipped',    '2025-02-05 13:20:00'),
    (8,  2,  'completed',  '2025-02-10 10:00:00'),
    (9,  7,  'shipped',    '2025-02-14 15:30:00'),
    (10, 8,  'pending',    '2025-02-18 09:45:00'),
    (11, 9,  'pending',    '2025-02-20 12:00:00'),
    (12, 10, 'completed',  '2025-02-22 17:30:00'),
    (13, 1,  'shipped',    '2025-03-01 10:15:00'),
    (14, 4,  'pending',    '2025-03-05 14:00:00'),
    (15, 3,  'cancelled',  '2025-03-08 11:30:00');

-- 주문 상세 데이터
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    -- 주문 1: 김민수 - 맥북 프로 + 매직 키보드
    (1,  1, 1, 2990000),
    (1,  4, 1,  399000),
    -- 주문 2: 이지은 - 아이패드 프로 + 애플 펜슬
    (2,  3, 1, 1499000),
    (2, 10, 1,  195000),
    -- 주문 3: 김민수 - 에어팟 프로
    (3,  6, 2,  359000),
    -- 주문 4: 박정호 - 맥북 에어 + USB-C 허브
    (4,  2, 1, 1790000),
    (4,  8, 2,   89000),
    -- 주문 5: 최유진 - 스튜디오 디스플레이
    (5,  7, 1, 2299000),
    -- 주문 6: 정하늘 - 매직 마우스 + 매직 키보드
    (6,  5, 1,  129000),
    (6,  4, 1,  399000),
    -- 주문 7: 한소윤 - 아이폰 케이스 3개
    (7,  9, 3,   69000),
    -- 주문 8: 이지은 - 맥북 프로
    (8,  1, 1, 2990000),
    -- 주문 9: 오태윤 - 아이패드 프로 + 매직 키보드 + 애플 펜슬
    (9,  3, 1, 1499000),
    (9,  4, 1,  399000),
    (9, 10, 1,  195000),
    -- 주문 10: 윤서현 - 에어팟 프로
    (10, 6, 1,  359000),
    -- 주문 11: 장민재 - 맥북 에어 + 매직 마우스
    (11, 2, 1, 1790000),
    (11, 5, 1,  129000),
    -- 주문 12: 송예린 - USB-C 허브 + 아이폰 케이스
    (12, 8, 1,   89000),
    (12, 9, 2,   69000),
    -- 주문 13: 김민수 - 스튜디오 디스플레이 + USB-C 허브
    (13, 7, 1, 2299000),
    (13, 8, 1,   89000),
    -- 주문 14: 최유진 - 에어팟 프로 + 매직 마우스
    (14, 6, 1,  359000),
    (14, 5, 1,  129000),
    -- 주문 15: 박정호 - 아이폰 케이스 (취소됨)
    (15, 9, 1,   69000);

-- DBT 결과 스키마 생성
CREATE SCHEMA staging;
CREATE SCHEMA mart;
