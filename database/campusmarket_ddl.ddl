-- =====================================================================
-- CAMPUSMARKET 전체 DDL (파트별로 이어 붙임 — 덮어쓰지 말고 자기 파트 섹션만 추가/수정할 것)
--   PART 1. Safe Zone · 채팅      (전채연)  Data Modeler 생성본
--   PART 2. 게시글 · 카테고리 · 리뷰 (게시글 파트) 추가형 DDL
--   PART 3. 회원 · 학적 · 제재      (이연우)  추가형 DDL
-- 팀 계정에는 각 파트를 순서대로 한 번씩만 실행한다. 이미 실행한 파트는 다시 실행하지 않는다.
-- (자기 파트만 실행하려면 해당 섹션만 선택해서 F5)
-- =====================================================================


-- #####################################################################
-- PART 1. Safe Zone · 채팅 (전채연)
-- #####################################################################
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


-- #####################################################################
-- PART 2. 게시글 · 카테고리 · 리뷰 (게시글 파트)
-- #####################################################################
-- CAMPUSMARKET: POST / CATEGORY / POST_IMAGE / REVIEW
-- Oracle 12cR2. Additive DDL; does NOT drop or recreate teammates' tables.
-- IMPORTANT: Check existing schema first. Run with F5 on the team connection.
SELECT table_name FROM user_tables ORDER BY table_name;

-- 1. CATEGORY (department/grade/classification metadata)
CREATE TABLE CATEGORY (
 CATEGORY_ID NUMBER(10) NOT NULL,
 NAME VARCHAR2(100) NOT NULL,
 COLLEGE VARCHAR2(100),
 GRADE NUMBER(2),
 CLASSIFICATION VARCHAR2(50),
 CONSTRAINT CATEGORY_PK PRIMARY KEY (CATEGORY_ID)
);

-- 2. Extend the pre-existing POST table. Do NOT recreate POST.
ALTER TABLE POST ADD (
 WRITER_ID VARCHAR2(20),
 CATEGORY_ID NUMBER(10),
 TITLE VARCHAR2(200),
 SUBJECT VARCHAR2(100),
 DESCRIPTION VARCHAR2(4000),
 PRICE NUMBER(10),
 AVAILABLE CHAR(1) DEFAULT 'Y',
 AVAILABLE_TIME VARCHAR2(100),
 STATUS VARCHAR2(30) DEFAULT 'ON_SALE',
 VIEW_COUNT NUMBER(10) DEFAULT 0,
 FAVORITE_COUNT NUMBER(10) DEFAULT 0,
 CREATED_AT DATE DEFAULT SYSDATE
);

-- 3. POST_IMAGE (image order 0 is cover)
CREATE TABLE POST_IMAGE (
 IMAGE_ID NUMBER(10) NOT NULL,
 POST_ID NUMBER(10) NOT NULL,
 URL VARCHAR2(1000) NOT NULL,
 IMAGE_ORDER NUMBER(2) NOT NULL,
 CONSTRAINT POST_IMAGE_PK PRIMARY KEY (IMAGE_ID),
 CONSTRAINT POST_IMAGE_ORDER_CK CHECK (IMAGE_ORDER BETWEEN 0 AND 4),
 CONSTRAINT POST_IMAGE_POST_ORDER_UK UNIQUE (POST_ID, IMAGE_ORDER)
);

-- 4. REVIEW (trade-completion rules enforced in application logic)
CREATE TABLE REVIEW (
 REVIEW_ID NUMBER(10) NOT NULL,
 TRADE_ID NUMBER(10) NOT NULL,
 WRITER_ID VARCHAR2(20) NOT NULL,
 TARGET_ID VARCHAR2(20) NOT NULL,
 RATING NUMBER(1) NOT NULL,
 KEYWORDS VARCHAR2(500),
 CONTENT VARCHAR2(2000),
 CREATED_AT DATE DEFAULT SYSDATE NOT NULL,
 CONSTRAINT REVIEW_PK PRIMARY KEY (REVIEW_ID),
 CONSTRAINT REVIEW_RATING_CK CHECK (RATING BETWEEN 1 AND 5),
 CONSTRAINT REVIEW_TRADE_UK UNIQUE (TRADE_ID)
);

-- 5. FK constraints (refer to the existing team entities)
ALTER TABLE POST ADD CONSTRAINT POST_WRITER_FK FOREIGN KEY (WRITER_ID) REFERENCES MEMBER(USER_ID);
ALTER TABLE POST ADD CONSTRAINT POST_CATEGORY_FK FOREIGN KEY (CATEGORY_ID) REFERENCES CATEGORY(CATEGORY_ID);
ALTER TABLE POST_IMAGE ADD CONSTRAINT POST_IMAGE_POST_FK FOREIGN KEY (POST_ID) REFERENCES POST(POST_ID);
ALTER TABLE REVIEW ADD CONSTRAINT REVIEW_TRADE_FK FOREIGN KEY (TRADE_ID) REFERENCES TRADE(TRADE_ID);
ALTER TABLE REVIEW ADD CONSTRAINT REVIEW_WRITER_FK FOREIGN KEY (WRITER_ID) REFERENCES MEMBER(USER_ID);
ALTER TABLE REVIEW ADD CONSTRAINT REVIEW_TARGET_FK FOREIGN KEY (TARGET_ID) REFERENCES MEMBER(USER_ID);

-- 6. Sequences for new entities (POST sequence should be coordinated with teammate)
CREATE SEQUENCE CATEGORY_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE POST_IMAGE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE REVIEW_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 7. Verify results
SELECT table_name FROM user_tables WHERE table_name IN ('POST','POST_IMAGE','CATEGORY','REVIEW') ORDER BY table_name;
SELECT table_name, column_name, data_type, data_length FROM user_tab_columns
 WHERE table_name IN ('POST','POST_IMAGE','CATEGORY','REVIEW') ORDER BY table_name, column_id;
SELECT constraint_name, table_name, constraint_type FROM user_constraints
 WHERE table_name IN ('POST','POST_IMAGE','CATEGORY','REVIEW') ORDER BY table_name, constraint_name;

-- Business rules requiring application/trigger logic, NOT guaranteed by these constraints:
-- 1..5 images per POST (a single-table CHECK cannot enforce a minimum count).
-- REVIEW only after completed trade; only buyer -> seller; no edits.
-- POST mandatory image, trade completion and reviewer role must be enforced separately.
-- If any table/column/sequence already exists, do not rerun this script unchanged.


-- #####################################################################
-- PART 3. 회원 · 학적 · 제재 (이연우)
-- #####################################################################
-- =====================================================================
-- CAMPUSMARKET: MEMBER / SCHOOL / STUDENT / SANCTION  (회원 · 학적 · 제재 파트, 이연우)
-- Oracle 12cR2. Additive DDL: 다른 팀원 테이블은 DROP / 재생성하지 않음.
-- 팀 계정(dbp260102)에서 F5(스크립트 실행)로 실행할 것.
-- MEMBER는 다른 팀원 테이블의 FK가 이미 참조하고 있으므로 다시 만들지 않고 컬럼만 추가함.
-- =====================================================================

-- 0. 현재 테이블 확인
SELECT table_name FROM user_tables ORDER BY table_name;

-- MEMBER가 아직 없으면 PK만 있는 형태로 먼저 만든다 (이미 있으면 건너뜀)
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'MEMBER';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE MEMBER (USER_ID VARCHAR2(20) NOT NULL, CONSTRAINT MEMBER_PK PRIMARY KEY (USER_ID))';
  END IF;
END;
/

-- 1. SCHOOL (더미 학교, 조회 전용)
CREATE TABLE SCHOOL (
 SCHOOL_ID NUMBER(5) NOT NULL,
 SCHOOL_NAME VARCHAR2(50) NOT NULL,
 EMAIL_DOMAIN VARCHAR2(50) NOT NULL,
 CONSTRAINT SCHOOL_PK PRIMARY KEY (SCHOOL_ID),
 CONSTRAINT SCHOOL_NAME_UK UNIQUE (SCHOOL_NAME),
 CONSTRAINT SCHOOL_DOMAIN_UK UNIQUE (EMAIL_DOMAIN)
);

-- 2. STUDENT (더미 학적, 조회 전용. 가입 요청과 대조)
CREATE TABLE STUDENT (
 STUDENT_ID NUMBER(10) NOT NULL,
 SCHOOL_ID NUMBER(5) NOT NULL,
 STUDENT_NO VARCHAR2(20) NOT NULL,
 STUDENT_NAME VARCHAR2(30) NOT NULL,
 DEPARTMENT VARCHAR2(50) NOT NULL,
 EMAIL VARCHAR2(100) NOT NULL,
 ENROLL_STATUS VARCHAR2(10) DEFAULT 'ENROLLED' NOT NULL,
 CONSTRAINT STUDENT_PK PRIMARY KEY (STUDENT_ID),
 CONSTRAINT STUDENT_SCHOOL_NO_UK UNIQUE (SCHOOL_ID, STUDENT_NO),
 CONSTRAINT STUDENT_EMAIL_UK UNIQUE (EMAIL),
 CONSTRAINT STUDENT_ENROLL_CK CHECK (ENROLL_STATUS IN ('ENROLLED', 'LEAVE', 'GRADUATED'))
);
ALTER TABLE STUDENT ADD CONSTRAINT STUDENT_SCHOOL_FK FOREIGN KEY (SCHOOL_ID) REFERENCES SCHOOL(SCHOOL_ID);

-- 3. MEMBER 컬럼 추가 (기존 행이 있어도 실패하지 않도록 NOT NULL은 기본값이 있는 컬럼에만 먼저 건다)
ALTER TABLE MEMBER ADD (
 PASSWORD VARCHAR2(100),
 NICKNAME VARCHAR2(30),
 PROFILE_IMAGE VARCHAR2(500),
 INTRODUCTION VARCHAR2(300),
 TRUST_SCORE NUMBER(5) DEFAULT 0 NOT NULL,
 MEMBER_ROLE VARCHAR2(10) DEFAULT 'USER' NOT NULL,
 MEMBER_STATUS VARCHAR2(15) DEFAULT 'ACTIVE' NOT NULL,
 CREATED_AT DATE DEFAULT SYSDATE NOT NULL,
 STUDENT_ID NUMBER(10)
);
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_NICKNAME_UK UNIQUE (NICKNAME);
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_STUDENT_UK UNIQUE (STUDENT_ID);
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_ROLE_CK CHECK (MEMBER_ROLE IN ('USER', 'ADMIN'));
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_STATUS_CK CHECK (MEMBER_STATUS IN ('ACTIVE', 'SUSPENDED', 'BANNED', 'WITHDRAWN'));
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_STUDENT_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID);

-- 4. SANCTION (회원 제재)
--    SANCTION_PERIOD_CK: 기간 정지만 종료 시각이 있고, 경고 · 영구 정지는 종료 시각이 없다
--    SANCTION_RELEASE_AT_CK: 해제했으면 해제 시각이 있어야 한다
CREATE TABLE SANCTION (
 SANCTION_ID NUMBER(10) NOT NULL,
 TARGET_ID VARCHAR2(20) NOT NULL,
 ADMIN_ID VARCHAR2(20),
 SANCTION_TYPE VARCHAR2(15) NOT NULL,
 REASON VARCHAR2(500) NOT NULL,
 START_AT DATE DEFAULT SYSDATE NOT NULL,
 END_AT DATE,
 IS_RELEASED CHAR(1) DEFAULT 'N' NOT NULL,
 RELEASED_AT DATE,
 CONSTRAINT SANCTION_PK PRIMARY KEY (SANCTION_ID),
 CONSTRAINT SANCTION_TYPE_CK CHECK (SANCTION_TYPE IN ('WARNING', 'SUSPENSION', 'BAN')),
 CONSTRAINT SANCTION_RELEASED_CK CHECK (IS_RELEASED IN ('N', 'Y')),
 CONSTRAINT SANCTION_PERIOD_CK CHECK (
   (SANCTION_TYPE = 'SUSPENSION' AND END_AT IS NOT NULL AND END_AT > START_AT)
   OR (SANCTION_TYPE IN ('WARNING', 'BAN') AND END_AT IS NULL)),
 CONSTRAINT SANCTION_RELEASE_AT_CK CHECK (
   (IS_RELEASED = 'N' AND RELEASED_AT IS NULL) OR (IS_RELEASED = 'Y' AND RELEASED_AT IS NOT NULL))
);
ALTER TABLE SANCTION ADD CONSTRAINT SANCTION_TARGET_FK FOREIGN KEY (TARGET_ID) REFERENCES MEMBER(USER_ID);
ALTER TABLE SANCTION ADD CONSTRAINT SANCTION_ADMIN_FK FOREIGN KEY (ADMIN_ID) REFERENCES MEMBER(USER_ID);

-- 5. Sequences (MEMBER의 PK는 사용자가 정하는 아이디라 시퀀스 없음)
CREATE SEQUENCE SCHOOL_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE STUDENT_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SANCTION_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- 6. Index: 로그인할 때마다 "이 회원의 해제되지 않은 제재"를 조회하므로
CREATE INDEX SANCTION_TARGET_IDX ON SANCTION (TARGET_ID, IS_RELEASED);
-- (STUDENT(SCHOOL_ID, STUDENT_NO), MEMBER(STUDENT_ID), MEMBER(NICKNAME)는 UK 인덱스가 자동 생성됨)

-- 7. Views
-- 7-1. 회원 프로필: 비밀번호를 빼고(접근 제어) 학적 · 학교를 미리 조인(질의 단순화)
--      내 프로필, 채팅 상대 정보, 관리자 화면에서 사용
CREATE OR REPLACE VIEW MEMBER_PROFILE_V AS
SELECT m.USER_ID, m.NICKNAME, m.PROFILE_IMAGE, m.INTRODUCTION, m.TRUST_SCORE,
       m.MEMBER_ROLE, m.MEMBER_STATUS, m.CREATED_AT,
       s.STUDENT_ID, s.STUDENT_NO, s.STUDENT_NAME, s.DEPARTMENT, s.EMAIL,
       sc.SCHOOL_ID, sc.SCHOOL_NAME
  FROM MEMBER m
  LEFT JOIN STUDENT s ON m.STUDENT_ID = s.STUDENT_ID
  LEFT JOIN SCHOOL sc ON s.SCHOOL_ID = sc.SCHOOL_ID;

-- 7-2. 현재 유효한 제재: 해제되지 않았고 기간이 남은 제재 (경고 포함)
--      로그인 차단은 SANCTION_TYPE IN ('SUSPENSION', 'BAN')인 행으로 판단
CREATE OR REPLACE VIEW ACTIVE_SANCTION_V AS
SELECT SANCTION_ID, TARGET_ID, ADMIN_ID, SANCTION_TYPE, REASON, START_AT, END_AT
  FROM SANCTION
 WHERE IS_RELEASED = 'N'
   AND (END_AT IS NULL OR END_AT > SYSDATE);

-- 8. Comments (테이블 · 컬럼 의미)
COMMENT ON TABLE SCHOOL IS '더미 학교 데이터. 가입 시 학교 선택 목록';
COMMENT ON COLUMN SCHOOL.EMAIL_DOMAIN IS '학교 웹메일 도메인';
COMMENT ON TABLE STUDENT IS '더미 학적 데이터. 가입 요청의 학교·학번·이름과 대조';
COMMENT ON COLUMN STUDENT.STUDENT_NO IS '학번. 같은 학교 안에서만 유일';
COMMENT ON COLUMN STUDENT.ENROLL_STATUS IS 'ENROLLED=재학, LEAVE=휴학, GRADUATED=졸업. 재학생만 가입 가능';
COMMENT ON TABLE MEMBER IS '회원 계정';
COMMENT ON COLUMN MEMBER.USER_ID IS '로그인 아이디 (사용자가 정함)';
COMMENT ON COLUMN MEMBER.TRUST_SCORE IS '신뢰 점수. 거래·리뷰 결과로 변동';
COMMENT ON COLUMN MEMBER.MEMBER_ROLE IS 'USER=일반 회원, ADMIN=관리자';
COMMENT ON COLUMN MEMBER.MEMBER_STATUS IS 'ACTIVE=정상, SUSPENDED=기간 정지, BANNED=영구 정지, WITHDRAWN=탈퇴';
COMMENT ON COLUMN MEMBER.STUDENT_ID IS '가입 때 확인된 학적. 학생 1명당 계정 1개. 관리자는 NULL 가능';
COMMENT ON TABLE SANCTION IS '회원에게 내린 제재 1건';
COMMENT ON COLUMN SANCTION.TARGET_ID IS '제재받은 회원';
COMMENT ON COLUMN SANCTION.ADMIN_ID IS '제재를 내린 관리자. 신고 누적 자동 제재면 NULL';
COMMENT ON COLUMN SANCTION.SANCTION_TYPE IS 'WARNING=경고(이용 제한 없음), SUSPENSION=기간 정지, BAN=영구 정지';
COMMENT ON COLUMN SANCTION.END_AT IS '정지 종료 시각. SUSPENSION만 값이 있음';
COMMENT ON COLUMN SANCTION.IS_RELEASED IS '관리자가 해제했는지 (Y/N)';

-- 9. 예제 레코드
-- 9-1. 학교 5곳
INSERT INTO SCHOOL VALUES (SCHOOL_SEQ.NEXTVAL, '서울대학교', 'snu.ac.kr');
INSERT INTO SCHOOL VALUES (SCHOOL_SEQ.NEXTVAL, '고려대학교', 'korea.ac.kr');
INSERT INTO SCHOOL VALUES (SCHOOL_SEQ.NEXTVAL, '한양대학교', 'hanyang.ac.kr');
INSERT INTO SCHOOL VALUES (SCHOOL_SEQ.NEXTVAL, '국민대학교', 'kookmin.ac.kr');
INSERT INTO SCHOOL VALUES (SCHOOL_SEQ.NEXTVAL, '동덕여자대학교', 'dongduk.ac.kr');

-- 9-2. 학적 (학교마다 3명. 휴학 · 졸업생은 가입 실패 테스트용)
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'snu.ac.kr'), '2023-12345', '김민준', '컴퓨터공학부', 'minjun.kim@snu.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'snu.ac.kr'), '2022-23456', '이서연', '경영학과', 'seoyeon.lee@snu.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'snu.ac.kr'), '2021-34567', '박도윤', '기계공학부', 'doyoon.park@snu.ac.kr', 'LEAVE');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'korea.ac.kr'), '2023130001', '최지우', '컴퓨터학과', 'jiwoo.choi@korea.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'korea.ac.kr'), '2022120002', '정하은', '경제학과', 'haeun.jung@korea.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'korea.ac.kr'), '2019110003', '강시우', '국어국문학과', 'siwoo.kang@korea.ac.kr', 'GRADUATED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'hanyang.ac.kr'), '2023012345', '윤서준', '컴퓨터소프트웨어학부', 'seojun.yoon@hanyang.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'hanyang.ac.kr'), '2022023456', '임지아', '건축학부', 'jia.lim@hanyang.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'hanyang.ac.kr'), '2021034567', '한예준', '전자공학부', 'yejun.han@hanyang.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'kookmin.ac.kr'), '20231234', '오수아', '소프트웨어학부', 'sua.oh@kookmin.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'kookmin.ac.kr'), '20222345', '서지호', '자동차공학과', 'jiho.seo@kookmin.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'kookmin.ac.kr'), '20213456', '신유나', '시각디자인학과', 'yuna.shin@kookmin.ac.kr', 'LEAVE');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'dongduk.ac.kr'), '20231001', '권하린', '컴퓨터학과', 'harin.kwon@dongduk.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'dongduk.ac.kr'), '20222002', '황채원', '정보통계학과', 'chaewon.hwang@dongduk.ac.kr', 'ENROLLED');
INSERT INTO STUDENT VALUES (STUDENT_SEQ.NEXTVAL, (SELECT SCHOOL_ID FROM SCHOOL WHERE EMAIL_DOMAIN = 'dongduk.ac.kr'), '20213003', '안소율', '경영학과', 'soyul.ahn@dongduk.ac.kr', 'ENROLLED');

-- 9-3. 회원 (관리자 1명 + 가입한 학생 7명. 비밀번호는 시연용 평문)
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('admin', 'admin1234', '운영자', 0, 'ADMIN', 'ACTIVE', NULL);
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('minjun01', '1234', '민준', 36, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'minjun.kim@snu.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('jiwoo02', '1234', '지우네', 12, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'jiwoo.choi@korea.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('seojun03', '1234', '서준', 20, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'seojun.yoon@hanyang.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('sua04', '1234', '수아책방', 48, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'sua.oh@kookmin.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('harin05', '1234', '하린', 25, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'harin.kwon@dongduk.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('chaewon06', '1234', '채원', 3, 'USER', 'SUSPENDED', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'chaewon.hwang@dongduk.ac.kr'));
INSERT INTO MEMBER (USER_ID, PASSWORD, NICKNAME, TRUST_SCORE, MEMBER_ROLE, MEMBER_STATUS, STUDENT_ID)
VALUES ('soyul07', '1234', '소율', 8, 'USER', 'ACTIVE', (SELECT STUDENT_ID FROM STUDENT WHERE EMAIL = 'soyul.ahn@dongduk.ac.kr'));

-- 9-4. 제재 (경고 1건, 진행 중인 기간 정지 1건, 해제된 기간 정지 1건)
INSERT INTO SANCTION (SANCTION_ID, TARGET_ID, ADMIN_ID, SANCTION_TYPE, REASON, START_AT, END_AT, IS_RELEASED, RELEASED_AT)
VALUES (SANCTION_SEQ.NEXTVAL, 'soyul07', 'admin', 'WARNING', '거래 약속 시간 반복 불이행', SYSDATE - 3, NULL, 'N', NULL);
INSERT INTO SANCTION (SANCTION_ID, TARGET_ID, ADMIN_ID, SANCTION_TYPE, REASON, START_AT, END_AT, IS_RELEASED, RELEASED_AT)
VALUES (SANCTION_SEQ.NEXTVAL, 'chaewon06', 'admin', 'SUSPENSION', 'Safe Zone 물품 미전달 신고 3건 확인', SYSDATE - 1, SYSDATE + 6, 'N', NULL);
INSERT INTO SANCTION (SANCTION_ID, TARGET_ID, ADMIN_ID, SANCTION_TYPE, REASON, START_AT, END_AT, IS_RELEASED, RELEASED_AT)
VALUES (SANCTION_SEQ.NEXTVAL, 'jiwoo02', 'admin', 'SUSPENSION', '허위 매물 게시 (소명 후 해제)', SYSDATE - 10, SYSDATE + 20, 'Y', SYSDATE - 8);

-- 10. 다른 팀원이 테스트용으로 넣어 둔 MEMBER 행이 있으면 빈 값을 채운다
--     (일반 회원은 테스트용 학적을 만들어 연결, 닉네임은 아이디, 비밀번호는 1234)
DECLARE
  v_school SCHOOL.SCHOOL_ID%TYPE;
  v_student STUDENT.STUDENT_ID%TYPE;
BEGIN
  SELECT SCHOOL_ID INTO v_school FROM SCHOOL WHERE EMAIL_DOMAIN = 'dongduk.ac.kr';
  FOR m IN (SELECT USER_ID FROM MEMBER WHERE STUDENT_ID IS NULL AND MEMBER_ROLE = 'USER') LOOP
    SELECT STUDENT_SEQ.NEXTVAL INTO v_student FROM DUAL;
    INSERT INTO STUDENT (STUDENT_ID, SCHOOL_ID, STUDENT_NO, STUDENT_NAME, DEPARTMENT, EMAIL, ENROLL_STATUS)
    VALUES (v_student, v_school, 'T' || v_student, m.USER_ID, '테스트학과', LOWER(m.USER_ID) || '@test.dongduk.ac.kr', 'ENROLLED');
    UPDATE MEMBER SET STUDENT_ID = v_student WHERE USER_ID = m.USER_ID;
  END LOOP;
  UPDATE MEMBER SET NICKNAME = NVL(NICKNAME, USER_ID), PASSWORD = NVL(PASSWORD, '1234')
   WHERE NICKNAME IS NULL OR PASSWORD IS NULL;
END;
/

-- 빈 값이 다 채워졌으므로 필수 조건을 건다
ALTER TABLE MEMBER MODIFY (PASSWORD NOT NULL, NICKNAME NOT NULL);
ALTER TABLE MEMBER ADD CONSTRAINT MEMBER_STUDENT_CK CHECK (MEMBER_ROLE = 'ADMIN' OR STUDENT_ID IS NOT NULL);

COMMIT;

-- 11. 확인
SELECT table_name, column_name, data_type, data_length, nullable FROM user_tab_columns
 WHERE table_name IN ('MEMBER', 'SCHOOL', 'STUDENT', 'SANCTION') ORDER BY table_name, column_id;
SELECT constraint_name, table_name, constraint_type FROM user_constraints
 WHERE table_name IN ('MEMBER', 'SCHOOL', 'STUDENT', 'SANCTION') ORDER BY table_name, constraint_name;
SELECT * FROM MEMBER_PROFILE_V ORDER BY USER_ID;
SELECT * FROM ACTIVE_SANCTION_V ORDER BY SANCTION_ID;

-- 애플리케이션에서 지켜야 하는 규칙 (제약조건만으로는 보장 안 됨):
-- 가입: STUDENT에서 (학교, 학번, 이름) 일치 + ENROLL_STATUS = 'ENROLLED' + 아직 MEMBER에 연결 안 된 학적만 허용.
-- 제재 적용 시 MEMBER_STATUS도 함께 변경 (SUSPENSION → SUSPENDED, BAN → BANNED), 해제 · 기간 만료 시 ACTIVE로 되돌림.
-- 이 스크립트를 다시 실행하면 이미 있는 객체 때문에 오류가 나므로, 재실행 전에 4개 테이블과 시퀀스 · 뷰를 먼저 삭제할 것.
