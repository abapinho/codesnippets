*&---------------------------------------------------------------------* 
*& Report  ZQC_SECONDARY_INDEXES 
*&
*&---------------------------------------------------------------------* 
*& Compare a simple internal table sorted and accessed using BINARY
*& SEARCH with another one fully specified with two indexes.
*& The results show that the fully specified table can be over 5x faster
*&---------------------------------------------------------------------* 

REPORT zqc_secondary_indexes. 

PARAMETERS: p_recs   TYPE i       DEFAULT 100000,
           p_bukrs   TYPE bukrs   DEFAULT '0231', 
           p_belnr   TYPE belnr_d DEFAULT '8607407481', 
           p_gjahr   TYPE gjahr   DEFAULT '2009', 
           p_augbl   TYPE augbl   DEFAULT '8400057550'. 

TYPES: ty_t_bseg1 TYPE TABLE OF bseg, 

       ty_t_bseg2 TYPE SORTED TABLE OF bseg
         WITH UNIQUE KEY bukrs belnr gjahr buzei
         WITH NON-UNIQUE SORTED KEY key_augbl COMPONENTS augbl.

DATA: t_bseg1 TYPE ty_t_bseg1, 
      t_bseg2 TYPE ty_t_bseg2,
      t0      TYPE i ,
      t1      TYPE i ,
      t2      TYPE i ,
      total1  TYPE i ,
      total2  TYPE i .

* Header
WRITE: /20 'Binary search' RIGHT-JUSTIFIED, 40 'Fully specified' RIGHT-JUSTIFIED.

* Load sample data 
PERFORM load_sample_data. 

skip.

* Reset totals to compare SELECT and subsequent READS independently 
CLEAR: total1 , total2. 

* Read by parcial primary key 
PERFORM read_table. 

* Loop by clearing document ---------------------------- 
PERFORM loop_at. 

SKIP.

WRITE: / 'Totals:', 20 total1, 40 total2.


*&---------------------------------------------------------------------* 
*&      Form  write_cost 
*&---------------------------------------------------------------------* 
*       text 
*----------------------------------------------------------------------* 
*      -->I_DESCRIPTION  text 
*----------------------------------------------------------------------* 
FORM write_cost USING i_description.
  DATA: delta1 TYPE i,
        delta2 TYPE i .

  delta1 = t1 - t0.
  delta2 = t2 - t1.
  ADD delta1 TO total1.
  ADD delta2 TO total2.
  WRITE: / i_description , 20 delta1 , 40 delta2 .
ENDFORM.                    "write_cost

*&---------------------------------------------------------------------* 
*&      Form  load_sample_data 
*&---------------------------------------------------------------------* 
*       text 
*----------------------------------------------------------------------* 
FORM load_sample_data. 
* Load sample data into 
  GET RUN TIME FIELD t0.
  SELECT *
    UP TO p_recs ROWS
    FROM bseg
    INTO TABLE t_bseg1.
  GET RUN TIME FIELD t1.
  SELECT *
    UP TO p_recs ROWS
    FROM bseg
    INTO TABLE t_bseg2.
  GET RUN TIME FIELD t2.
  PERFORM write_cost USING 'Load data'.
ENDFORM.                    "load_sample_data

*&---------------------------------------------------------------------* 
*&      Form  read_table 
*&---------------------------------------------------------------------* 
*       text 
*----------------------------------------------------------------------* 
FORM read_table. 
* Read by primary key ---------------------------- 
* We must sort T_BSEG1 
  GET RUN TIME FIELD t0.
  SORT t_bseg1 BY bukrs belnr gjahr buzei.
  GET RUN TIME FIELD t1.
* No need to sort T_BSEG2 
  GET RUN TIME FIELD t2.
  PERFORM write_cost USING 'Sort by key'.

  DO 10 TIMES .
    GET RUN TIME FIELD t0.
    READ TABLE t_bseg1
      TRANSPORTING NO FIELDS 
      WITH KEY bukrs = p_bukrs
               belnr = p_belnr
               gjahr = p_gjahr BINARY SEARCH.
    GET RUN TIME FIELD t1.
    READ TABLE t_bseg2
      TRANSPORTING NO FIELDS 
      WITH KEY bukrs = p_bukrs
               belnr = p_belnr
               gjahr = p_gjahr .
    GET RUN TIME FIELD t2.
    PERFORM write_cost USING 'Read prim. key' .
  ENDDO.
ENDFORM.                    "read_table

*&---------------------------------------------------------------------* 
*&      Form  loop_at 
*&---------------------------------------------------------------------* 
*       text 
*----------------------------------------------------------------------* 
FORM loop_at. 
  data: count type i .

* We must sort T_BSEG1 again 
  GET RUN TIME FIELD t0.
  SORT t_bseg1 BY augbl.
  GET RUN TIME FIELD t1.
* No need to sort T_BSEG2 
  GET RUN TIME FIELD t2.
  PERFORM write_cost USING 'Sort by AUGBL'.

  DO 10 TIMES .
    GET RUN TIME FIELD t0.
    CLEAR count .
    LOOP AT t_bseg1
      TRANSPORTING NO FIELDS 
      WHERE augbl = p_augbl .
      ADD 1 TO count. 
      IF count = 1000. 
        EXIT .
      ENDIF .
    ENDLOOP .
    GET RUN TIME FIELD t1.
    CLEAR count .
    LOOP AT  t_bseg2
      USING KEY key_augbl      " <--- explicitly saying which index to use
      TRANSPORTING NO FIELDS 
      WHERE  augbl = p_augbl .
      ADD 1 TO count. 
      IF count = 1000. 
        EXIT .
      ENDIF .
    ENDLOOP .
    GET RUN TIME FIELD t2.
    PERFORM write_cost USING 'Loop by AUGBL' .
  ENDDO.
ENDFORM.                    "loop_at
