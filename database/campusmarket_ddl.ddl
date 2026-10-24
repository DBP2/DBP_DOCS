-- 생성자 Oracle SQL Developer Data Modeler 24.3.1.347.1153
--   위치:        2026-10-25 04:00:09 KST
--   사이트:      Oracle Database 12cR2
--   유형:      Oracle Database 12cR2



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE SEQUENCE seq_chat_message START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE seq_chat_room START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE seq_safe_zone START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE seq_safe_zone_record START WITH 1 INCREMENT BY 1;

CREATE TABLE chat_message (
    message_id   NUMBER(10) NOT NULL,
    message_type VARCHAR2(10) NOT NULL,
    content      VARCHAR2(1000),
    image_url    VARCHAR2(500),
    sent_at      DATE DEFAULT sysdate NOT NULL,
    is_read      CHAR(1) DEFAULT 'N' NOT NULL,
    chat_room_id NUMBER(10) NOT NULL,
    sender_id    VARCHAR2(20)
)
LOGGING;

ALTER TABLE chat_message
    ADD
        CHECK ( message_type IN ( 'IMAGE', 'SYSTEM', 'TEXT' ) );

ALTER TABLE chat_message
    ADD CHECK ( is_read IN ( 'N', 'Y' ) );

CREATE INDEX chat_message_room_idx ON
    chat_message (
        chat_room_id
    ASC,
        sent_at
    ASC )
        LOGGING;

ALTER TABLE chat_message
    ADD CONSTRAINT chat_message_ck
        CHECK ( ( message_type = 'SYSTEM'
                  AND sender_id IS NULL )
                OR ( message_type <> 'SYSTEM'
                     AND sender_id IS NOT NULL ) );

ALTER TABLE chat_message ADD CONSTRAINT chat_message_pk PRIMARY KEY ( message_id );

CREATE TABLE chat_room (
    chat_room_id    NUMBER(10) NOT NULL,
    created_at      DATE DEFAULT sysdate NOT NULL,
    last_message_at DATE,
    buyer_id        VARCHAR2(20) NOT NULL,
    trade_id        NUMBER(10),
    post_id         NUMBER(10) NOT NULL
)
LOGGING;

CREATE INDEX chat_room_buyer_idx ON
    chat_room (
        buyer_id
    ASC )
        LOGGING;

CREATE INDEX chat_room_trade_idx ON
    chat_room (
        trade_id
    ASC )
        LOGGING;

ALTER TABLE chat_room ADD CONSTRAINT chat_room_pk PRIMARY KEY ( chat_room_id );

ALTER TABLE chat_room ADD CONSTRAINT chat_room_buyer_uk UNIQUE ( post_id,
                                                                 buyer_id );

CREATE TABLE member (
    user_id VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE member ADD CONSTRAINT member_pk PRIMARY KEY ( user_id );

CREATE TABLE post (
    post_id      NUMBER(10) NOT NULL,
    safe_zone_id NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE post ADD CONSTRAINT post_pk PRIMARY KEY ( post_id );

CREATE TABLE safe_zone (
    safe_zone_id    NUMBER(10) NOT NULL,
    zone_name       VARCHAR2(100) NOT NULL,
    location_detail VARCHAR2(200) NOT NULL,
    open_time       VARCHAR2(5),
    close_time      VARCHAR2(5),
    qr_token        VARCHAR2(100) NOT NULL,
    manual_code     CHAR(6) NOT NULL
)
LOGGING;

CREATE UNIQUE INDEX safe_zone_code_uk ON
    safe_zone (
        manual_code
    ASC )
        LOGGING;

CREATE UNIQUE INDEX safe_zone_qr_uk ON
    safe_zone (
        qr_token
    ASC )
        LOGGING;

ALTER TABLE safe_zone ADD CONSTRAINT safe_zone_pk PRIMARY KEY ( safe_zone_id );

CREATE TABLE safe_zone_record (
    record_id      NUMBER(10) NOT NULL,
    record_action  VARCHAR2(10) NOT NULL,
    photo_url      VARCHAR2(500) NOT NULL,
    photo_taken_at DATE NOT NULL,
    recorded_at    DATE DEFAULT sysdate NOT NULL,
    trade_id       NUMBER(10) NOT NULL,
    recorder_id    VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE safe_zone_record
    ADD CHECK ( record_action IN ( 'DROP_OFF', 'PICK_UP' ) );

CREATE UNIQUE INDEX sz_record_trade_action_uk ON
    safe_zone_record (
        trade_id
    ASC,
        record_action
    ASC )
        LOGGING;

ALTER TABLE safe_zone_record ADD CONSTRAINT safe_zone_record_pk PRIMARY KEY ( record_id );

CREATE TABLE trade (
    trade_id     NUMBER(10) NOT NULL,
    safe_zone_id NUMBER(10) NOT NULL
)
LOGGING;

ALTER TABLE trade ADD CONSTRAINT trade_pk PRIMARY KEY ( trade_id );

ALTER TABLE chat_message
    ADD CONSTRAINT chat_message_chat_room_fk
        FOREIGN KEY ( chat_room_id )
            REFERENCES chat_room ( chat_room_id )
            NOT DEFERRABLE;

ALTER TABLE chat_message
    ADD CONSTRAINT chat_message_sender_fk
        FOREIGN KEY ( sender_id )
            REFERENCES member ( user_id )
            NOT DEFERRABLE;

ALTER TABLE chat_room
    ADD CONSTRAINT chat_room_buyer_fk
        FOREIGN KEY ( buyer_id )
            REFERENCES member ( user_id )
            NOT DEFERRABLE;

ALTER TABLE chat_room
    ADD CONSTRAINT chat_room_post_fk
        FOREIGN KEY ( post_id )
            REFERENCES post ( post_id )
            NOT DEFERRABLE;

ALTER TABLE chat_room
    ADD CONSTRAINT chat_room_trade_fk
        FOREIGN KEY ( trade_id )
            REFERENCES trade ( trade_id )
            NOT DEFERRABLE;

ALTER TABLE post
    ADD CONSTRAINT post_safe_zone_fk
        FOREIGN KEY ( safe_zone_id )
            REFERENCES safe_zone ( safe_zone_id )
            NOT DEFERRABLE;

ALTER TABLE safe_zone_record
    ADD CONSTRAINT safe_zone_record_recorder_fk
        FOREIGN KEY ( recorder_id )
            REFERENCES member ( user_id )
            NOT DEFERRABLE;

ALTER TABLE safe_zone_record
    ADD CONSTRAINT safe_zone_record_trade_fk
        FOREIGN KEY ( trade_id )
            REFERENCES trade ( trade_id )
            NOT DEFERRABLE;

ALTER TABLE trade
    ADD CONSTRAINT trade_safe_zone_fk
        FOREIGN KEY ( safe_zone_id )
            REFERENCES safe_zone ( safe_zone_id )
            NOT DEFERRABLE;

CREATE OR REPLACE VIEW TRADE_SZ_STATUS_V ( TRADE_ID, SAFE_ZONE_ID, DROP_OFF_AT, PICK_UP_AT, SZ_STATUS ) AS
SELECT t.TRADE_ID,
       t.SAFE_ZONE_ID,
       MAX(CASE WHEN r.RECORD_ACTION = 'DROP_OFF' THEN r.RECORDED_AT END) AS DROP_OFF_AT,
       MAX(CASE WHEN r.RECORD_ACTION = 'PICK_UP'  THEN r.RECORDED_AT END) AS PICK_UP_AT,
       CASE
         WHEN COUNT(CASE WHEN r.RECORD_ACTION = 'PICK_UP'  THEN 1 END) > 0 THEN 'COMPLETED'
         WHEN COUNT(CASE WHEN r.RECORD_ACTION = 'DROP_OFF' THEN 1 END) > 0 THEN 'STORED'
         ELSE 'WAITING'
       END AS SZ_STATUS
FROM TRADE t
LEFT JOIN SAFE_ZONE_RECORD r ON r.TRADE_ID = t.TRADE_ID
GROUP BY t.TRADE_ID, t.SAFE_ZONE_ID 
;



-- Oracle SQL Developer Data Modeler 요약 보고서: 
-- 
-- CREATE TABLE                             7
-- CREATE INDEX                             6
-- ALTER TABLE                             21
-- CREATE VIEW                              1
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          4
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
