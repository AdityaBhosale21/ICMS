CREATE OR REPLACE PACKAGE Pkg_Mts_Upload AS

  /********************************************************************************************
     PACKAGE NAME :   Pkg_Mts_Upload
     AUTHOR       :   Sanjay Pardhi
     CREATE DATE  :   21-May-2010
     PURPOSE      :   To Upload following Back Office Details to Front Office
                      1. Bank Master
                      2. DP Master
                      3. Client Trading Account
                      4. Client Bank
                      5. Client DP
                      6. Holiday Master
     CHANGES      :   VERSION       DATE         CHANGED BY         DESCRIPTION

  *********************************************************************************************/

  PROCEDURE P_Load_Bank_Master_Mts;

  PROCEDURE P_Load_Dp_Master_Mts;

  PROCEDURE P_Load_Entity_Mts;

  PROCEDURE P_Load_Ent_Bank_Details_Mts;

  PROCEDURE P_Load_Ent_Dp_Details_Mts;

  PROCEDURE P_Load_Holiday_Master_Mts;

  PROCEDURE P_Updt_Rda_Sign_Status_Mts;

  PROCEDURE P_Load_Security_Master_Mts;

  PROCEDURE P_Load_Rda_Mts(Out_Success OUT VARCHAR2, Out_Num OUT NUMBER);

  PROCEDURE P_Load_Nav_Master_Mts;

  PROCEDURE P_Load_Scheme_Master_Mts;

END Pkg_Mts_Upload;
/
CREATE OR REPLACE PACKAGE BODY PKG_MTS_UPLOAD AS

  PROCEDURE P_LOAD_BANK_MASTER_MTS IS

    L_UPDT            NUMBER := 0;
    L_INSERT          NUMBER := 0;
    L_FETCH           NUMBER := 0;
    L_CURR_DATE       PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID          VARCHAR2(30) := 'CSSBBKUP';
    L_PRG_PROCESS_ID  NUMBER := 0;
    L_FILE_HANDLE     UTL_FILE.FILE_TYPE;
    L_LOG_ENV         VARCHAR2(100);
    L_FILE_NAME       VARCHAR2(70);
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_LOD_SEQ         LOAD_CONTROLS.LOD_SEQ %TYPE;
    L_FIRST_LOAD_TIME DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME  DATE;
    L_BANK_CODE       BANK_MASTER.BKM_CD%TYPE;
    L_SEGMENT_TYPE    BANK_INTERFACE_MASTER.BIM_SEG_ID%TYPE;


    CURSOR C_BANK_INTERFACE_MASTER IS
      SELECT BKM_CD,
             DECODE(BIM_SEG_ID, 'B', 'C', 'C') BIM_SEG_ID,
             NVL(BKM_STATUS, 'A') BKM_STATUS,
             BIM_AGENCY_ID,
             BIM_MERCHANT_CD,
             BIM_ITS_HOLD_URL,
             BIM_OWS_HOLD_URL,
             BIM_ITS_REL_URL,
             BIM_OWS_REL_URL,
             BIM_SERVICE_CHARGE,
             BIM_BANK_KEY,
             BKM_NAME,
             BKM_CPM_ID
        FROM BANK_MASTER,
             (SELECT * FROM BANK_INTERFACE_MASTER WHERE BIM_STATUS = 'A')
       WHERE BKM_CD = BIM_BKM_CD
         AND (BIM_CREAT_DT >= L_LAST_LOAD_TIME OR
             BIM_LAST_UPDT_DT >= L_LAST_LOAD_TIME OR
             BKM_CREAT_DT >= L_LAST_LOAD_TIME OR
             BKM_LAST_UPDT_DT >= L_LAST_LOAD_TIME);
  BEGIN
    BEGIN
      L_IND := 9;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      L_IND         := 10;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Bank Details Upload to MTS -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      L_IND := 6;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      --get last run time for completed batch
      BEGIN

        SELECT NVL(MAX(LOD_START_TIME), L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND LOD_STATUS = 'C';

      END;
      --insert record into program status
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID;
      BEGIN
        L_IND := 7;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status File',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        --get max seq no for today
        L_IND := 16;
        SELECT (NVL(MAX(LOD_SEQ), 0)) + 1
          INTO L_LOD_SEQ
          FROM LOAD_CONTROLS
         WHERE LOD_DT = L_CURR_DATE
           AND LOD_CMP_ID = L_PRG_ID;

        --insert record into load_controls
        L_IND := 15;
        INSERT INTO LOAD_CONTROLS
          (LOD_DT,
           LOD_STATUS,
           LOD_SEQ,
           LOD_START_TIME,
           LOD_PROCESS_ID,
           LOD_CMP_ID,
           LOD_CREAT_BY,
           LOD_CREAT_DT)
        VALUES
          (L_CURR_DATE,
           'R',
           L_LOD_SEQ,
           SYSDATE,
           L_PRG_PROCESS_ID,
           L_PRG_ID,
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        L_IND := 1;

        FOR BANK_INTERFACE_MASTER_REC IN C_BANK_INTERFACE_MASTER LOOP
          L_BANK_CODE    := BANK_INTERFACE_MASTER_REC.BKM_CD;
          L_SEGMENT_TYPE := BANK_INTERFACE_MASTER_REC.BIM_SEG_ID;
          BEGIN
            L_IND := 3;
            UPDATE BOS_BANK_MASTER
               SET BBM_BANK_NAME       = SUBSTR(BANK_INTERFACE_MASTER_REC.BKM_NAME,
                                                1,
                                                30),
                   BBM_COMPANY_ID      = BANK_INTERFACE_MASTER_REC.BKM_CPM_ID,
                   BBM_STATUS          = BANK_INTERFACE_MASTER_REC.BKM_STATUS,
                   BBM_MERCHANT_CODE   = BANK_INTERFACE_MASTER_REC.BIM_MERCHANT_CD,
                   BBM_ITS_HOLD_URL    = BANK_INTERFACE_MASTER_REC.BIM_ITS_HOLD_URL,
                   BBM_OWS_HOLD_URL    = BANK_INTERFACE_MASTER_REC.BIM_OWS_HOLD_URL,
                   BBM_ITS_RELEASE_URL = BANK_INTERFACE_MASTER_REC.BIM_ITS_REL_URL,
                   BBM_OWS_RELEASE_URL = BANK_INTERFACE_MASTER_REC.BIM_OWS_REL_URL,
                   BBM_SERVICE_CHARGE  = BANK_INTERFACE_MASTER_REC.BIM_SERVICE_CHARGE,
                   BBM_BANK_KEY        = BANK_INTERFACE_MASTER_REC.BIM_BANK_KEY,
                   BBM_AGENCY_ID       = BANK_INTERFACE_MASTER_REC.BIM_AGENCY_ID
             WHERE BBM_BANK_CODE = BANK_INTERFACE_MASTER_REC.BKM_CD
               AND BBM_SEGMENT_TYPE = BANK_INTERFACE_MASTER_REC.BIM_SEG_ID;

            IF SQL%FOUND THEN
              L_UPDT := L_UPDT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                ' Updated in MTS,For Bank Code : ' ||
                                BANK_INTERFACE_MASTER_REC.BKM_CD ||
                                '  Segment Type : ' ||
                                BANK_INTERFACE_MASTER_REC.BIM_SEG_ID);
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            IF SQL%NOTFOUND THEN
              BEGIN
                L_IND := 4;
                INSERT INTO BOS_BANK_MASTER
                  (BBM_BANK_CODE,
                   BBM_BANK_NAME,
                   BBM_COMPANY_ID,
                   BBM_STATUS,
                   BBM_SEGMENT_TYPE,
                   BBM_MERCHANT_CODE,
                   BBM_ITS_HOLD_URL,
                   BBM_OWS_HOLD_URL,
                   BBM_ITS_RELEASE_URL,
                   BBM_OWS_RELEASE_URL,
                   BBM_SERVICE_CHARGE,
                   BBM_BANK_KEY,
                   BBM_AGENCY_ID)
                VALUES
                  (BANK_INTERFACE_MASTER_REC.BKM_CD,
                   SUBSTR(BANK_INTERFACE_MASTER_REC.BKM_NAME, 1, 30),
                   BANK_INTERFACE_MASTER_REC.BKM_CPM_ID,
                   BANK_INTERFACE_MASTER_REC.BKM_STATUS,
                   BANK_INTERFACE_MASTER_REC.BIM_SEG_ID,
                   BANK_INTERFACE_MASTER_REC.BIM_MERCHANT_CD,
                   BANK_INTERFACE_MASTER_REC.BIM_ITS_HOLD_URL,
                   BANK_INTERFACE_MASTER_REC.BIM_OWS_HOLD_URL,
                   BANK_INTERFACE_MASTER_REC.BIM_ITS_REL_URL,
                   BANK_INTERFACE_MASTER_REC.BIM_OWS_REL_URL,
                   BANK_INTERFACE_MASTER_REC.BIM_SERVICE_CHARGE,
                   BANK_INTERFACE_MASTER_REC.BIM_BANK_KEY,
                   BANK_INTERFACE_MASTER_REC.BIM_AGENCY_ID);

                L_INSERT := L_INSERT + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  ' Inserted in MTS,For Bank Code : ' ||
                                  BANK_INTERFACE_MASTER_REC.BKM_CD ||
                                  '  Segment Type : ' ||
                                  BANK_INTERFACE_MASTER_REC.BIM_SEG_ID);
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
              END;
            END IF;

          END;
          L_FETCH := L_FETCH + 1;
        END LOOP;
        IF (L_FETCH = 0) THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'No records to be uploaded to MTS BANK MASTER');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END IF;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        L_FLAG := 1;
        IF L_IND = 9 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          ' For Bank Code :' || L_BANK_CODE ||
                          ' Segment Type :' || L_SEGMENT_TYPE);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        IF L_IND = 1 THEN
          L_DESC := 'Error while opening the cursor :' || SQLERRM;
        ELSIF L_IND = 3 THEN
          L_DESC := 'Error while updating the records in MTS BANK MASTER  :' ||
                    SQLERRM;
        ELSIF L_IND = 4 THEN
          L_DESC := 'Error while inserting the records in MTS BANK MASTER  :' ||
                    SQLERRM;
        ELSIF L_IND = 6 THEN
          L_DESC := 'Error while Selecting from Parameter Master   :' ||
                    SQLERRM;
        ELSIF L_IND = 7 THEN
          L_DESC := 'Error while inserting the records in Program Status  :' ||
                    SQLERRM;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while inserting the records in Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 16 THEN
          L_DESC := 'Error while selecting the load sequence from Load Controls   :' ||
                    SQLERRM;
        END IF;

        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;
    IF L_FLAG = 0 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'C',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status for Success : ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'C',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Fetched: ' || L_FETCH);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Inserted: ' || L_INSERT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Updated: ' || L_UPDT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading Bank Details to MTS successfully completed at ' ||
                          TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'E',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'E',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading Bank Details to MTS Unsuccessful');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;
  END P_LOAD_BANK_MASTER_MTS;

  PROCEDURE P_LOAD_DP_MASTER_MTS IS

    L_UPDT            NUMBER := 0;
    L_INSERT          NUMBER := 0;
    L_FETCH           NUMBER := 0;
    L_CURR_DATE       PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID          VARCHAR2(30) := 'CSSBDMUP';
    L_PRG_PROCESS_ID  NUMBER := 0;
    L_FILE_HANDLE     UTL_FILE.FILE_TYPE;
    L_LOG_ENV         VARCHAR2(100);
    L_FILE_NAME       VARCHAR2(70);
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_LOD_SEQ         LOAD_CONTROLS.LOD_SEQ %TYPE;
    L_FIRST_LOAD_TIME DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME  DATE;
    L_DP_CODE         DEPO_PARTICIPANT_MASTER.DPM_ID%TYPE;
    L_DPM_CODE        DEPO_PARTICIPANT_MASTER.DPM_DEM_ID%TYPE;

    CURSOR C_DP_MASTER IS
      SELECT DPM_ID,
             DPM_DEM_ID,
             DPM_NAME,
             DPM_AGENCY_CD,
             DPM_ITS_HOLD_URL,
             DPM_OWS_HOLD_URL,
             DPM_ITS_REL_URL,
             DPM_OWS_REL_URL
        FROM DEPO_PARTICIPANT_MASTER
       WHERE (DPM_CREAT_DT >= L_LAST_LOAD_TIME OR
             DPM_LAST_UPDT_DT >= L_LAST_LOAD_TIME)
         AND DPM_AGENCY_CD IS NOT NULL;

  BEGIN
    BEGIN
      L_IND := 9;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      L_IND         := 10;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For DP Details Upload to MTS -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      L_IND := 6;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      --get last run time for completed batch
      BEGIN
        SELECT NVL(MAX(LOD_START_TIME), L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND LOD_STATUS = 'C';
      END;
      --insert record into program status
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID;
      BEGIN
        L_IND := 7;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status FILE',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        --get max seq no for today
        L_IND := 16;
        SELECT (NVL(MAX(LOD_SEQ), 0)) + 1
          INTO L_LOD_SEQ
          FROM LOAD_CONTROLS
         WHERE LOD_DT = L_CURR_DATE
           AND LOD_CMP_ID = L_PRG_ID;

        --insert record into load_controls
        L_IND := 15;
        INSERT INTO LOAD_CONTROLS
          (LOD_DT,
           LOD_STATUS,
           LOD_SEQ,
           LOD_START_TIME,
           LOD_PROCESS_ID,
           LOD_CMP_ID,
           LOD_CREAT_BY,
           LOD_CREAT_DT)
        VALUES
          (TRUNC(L_CURR_DATE),
           'R',
           L_LOD_SEQ,
           SYSDATE,
           L_PRG_PROCESS_ID,
           L_PRG_ID,
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        L_IND := 1;

        FOR DP_MASTER_REC IN C_DP_MASTER LOOP
          L_DP_CODE  := DP_MASTER_REC.DPM_ID;
          L_DPM_CODE := DP_MASTER_REC.DPM_DEM_ID;

          BEGIN
            L_IND := 3;
            UPDATE BOS_DP_MASTER
               SET BDM_DP_FULL_NAME    = SUBSTR(DP_MASTER_REC.DPM_NAME,
                                                1,
                                                30),
                   BDM_DP_NAME         = DP_MASTER_REC.DPM_ID,
                   BDM_ITS_HOLD_URL    = DP_MASTER_REC.DPM_ITS_HOLD_URL,
                   BDM_ITS_RELEASE_URL = DP_MASTER_REC.DPM_ITS_REL_URL,
                   BDM_OWS_HOLD_URL    = DP_MASTER_REC.DPM_OWS_HOLD_URL,
                   BDM_OWS_RELEASE_URL = DP_MASTER_REC.DPM_OWS_REL_URL,
                   BDM_AGENCY_ID       = DP_MASTER_REC.DPM_AGENCY_CD,
                   BDM_UPDATED_BY      = USER,
                   BDM_UPDATED_DATE    = SYSDATE
             WHERE BDM_DP_CODE = DP_MASTER_REC.DPM_ID
               AND BDM_DP_DEPOSITORY = DP_MASTER_REC.DPM_DEM_ID;

            IF SQL%FOUND THEN
              L_UPDT := L_UPDT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                ' Updated in MTS,For DP Id : ' ||
                                DP_MASTER_REC.DPM_ID || ' Depository Id : ' ||
                                DP_MASTER_REC.DPM_DEM_ID);
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            IF SQL%NOTFOUND THEN
              BEGIN
                L_IND := 4;
                INSERT INTO BOS_DP_MASTER
                  (BDM_DP_CODE,
                   BDM_DP_DEPOSITORY,
                   BDM_AGENCY_ID,
                   BDM_DP_FULL_NAME,
                   BDM_DP_NAME,
                   BDM_ITS_HOLD_URL,
                   BDM_ITS_RELEASE_URL,
                   BDM_OWS_HOLD_URL,
                   BDM_OWS_RELEASE_URL,
                   BDM_UPDATED_BY,
                   BDM_UPDATED_DATE)
                VALUES
                  (DP_MASTER_REC.DPM_ID,
                   DP_MASTER_REC.DPM_DEM_ID,
                   DP_MASTER_REC.DPM_AGENCY_CD,
                   SUBSTR(DP_MASTER_REC.DPM_NAME, 1, 30),
                   DP_MASTER_REC.DPM_ID,
                   DP_MASTER_REC.DPM_ITS_HOLD_URL,
                   DP_MASTER_REC.DPM_ITS_REL_URL,
                   DP_MASTER_REC.DPM_OWS_HOLD_URL,
                   DP_MASTER_REC.DPM_OWS_REL_URL,
                   USER,
                   SYSDATE);

                L_INSERT := L_INSERT + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  ' Inserted in MTS,For DP Id : ' ||
                                  DP_MASTER_REC.DPM_ID ||
                                  ' Depository Id : ' ||
                                  DP_MASTER_REC.DPM_DEM_ID);
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
              END;
            END IF;
          END;
          L_FETCH := L_FETCH + 1;
        END LOOP;
        IF (L_FETCH = 0) THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'No records to be uploaded to MTS DP MASTER ');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END IF;
      END;

    EXCEPTION
      WHEN OTHERS THEN
        L_FLAG := 1;
        IF L_IND = 9 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          ' For DP Id : ' || L_DP_CODE ||
                          ' Depository Id : ' || L_DPM_CODE);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        IF L_IND = 1 THEN
          L_DESC := 'Error while opening the cursor :' || SQLERRM;
        ELSIF L_IND = 3 THEN
          L_DESC := 'Error while updating the records in MTS DP MASTER  : ' ||
                    SQLERRM;
        ELSIF L_IND = 4 THEN
          L_DESC := 'Error while inserting the records in MTS DP MASTER  :' ||
                    SQLERRM;
        ELSIF L_IND = 6 THEN
          L_DESC := 'Error while Selecting from Parameter Master   :' ||
                    SQLERRM;
        ELSIF L_IND = 7 THEN
          L_DESC := 'Error while inserting the records in Program Status  :' ||
                    SQLERRM;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while inserting the records in Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 16 THEN
          L_DESC := 'Error while selecting the load sequence from Load Controls  :' ||
                    SQLERRM;
        END IF;

        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;

    IF L_FLAG = 0 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'C',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_CMP_ID = L_PRG_ID
             AND PRG_DT = L_CURR_DATE
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status for Success : ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'C',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Fetched: ' || L_FETCH);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Inserted: ' || L_INSERT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Updated: ' || L_UPDT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading DP Details to MTS  successfully completed at ' ||
                          TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'E',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'E',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control  :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading DP Details to MTS  Unsuccessful');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;
  END P_LOAD_DP_MASTER_MTS;

  PROCEDURE P_LOAD_ENT_BANK_DETAILS_MTS IS

    L_UPDT            NUMBER := 0;
    L_INSERT          NUMBER := 0;
    L_FETCH           NUMBER := 0;
    L_FAIL            NUMBER := 0;
    L_CURR_DATE       PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID          VARCHAR2(30) := 'CSSBBDUP';
    L_PRG_PROCESS_ID  NUMBER := 0;
    L_FILE_HANDLE     UTL_FILE.FILE_TYPE;
    L_LOG_ENV         VARCHAR2(100);
    L_FILE_NAME       VARCHAR2(70);
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_FIRST_LOAD_TIME DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME  DATE;
    L_ASM_FL          NUMBER;
    --l_Data_File_Name             VARCHAR2(100);
    --l_Data_File_Handle           Utl_File.File_Type;
    L_BATCH_NO      VARCHAR2(100) := '0';
    L_DATA_FILE_ENV VARCHAR2(100);
    --l_Output_String              VARCHAR2(32767);
    L_BAM_NO                  VARCHAR2(30);
    L_BAM_BKM_CD              VARCHAR2(3);
    L_BAM_ENT_ID              VARCHAR2(30);
    L_BAM_STATUS              VARCHAR2(1);
    L_BAM_CPD_ID              VARCHAR2(30);
    L_BAM_DEF_BNK_IND         VARCHAR2(1);
    L_BAM_TYPE                VARCHAR2(2);
    L_BAM_CUST_ID             VARCHAR2(30);
    L_BAM_BBM_CD              VARCHAR2(10);
    L_BAM_NRI_RES_STATUS      NUMBER;
    L_ENT_NRI_SETTLEMENT_TYPE VARCHAR2(30);
    L_MFF_UCC_CD              VARCHAR2(30);
  l_Bam_Poa_Flag               VARCHAR2(1) := 'N';

    CURSOR C_BANK_ACCOUNT_MASTER IS
      SELECT DISTINCT BAM_NO,
                      BAM_BKM_CD,
                      DECODE(ENT_CTG_DESC,
                             11,
                             ENT_EXCH_CLIENT_ID,
                             BAM_ENT_ID) BAM_ENT_ID,
                      DECODE(ENT_STATUS,
                             'E',
                             DECODE(BAM_STATUS, 'A', 'E', 'D'),
                             'D'),
                      BAM_CPD_ID,
                      DECODE(ENT_STATUS,
                             'E',
                             NVL(BAM_DEF_BNK_IND, 'N'),
                             'N'),
                      BAM_TYPE,
                      BAM_CUST_ID,
                      BAM_BBM_CD,
                      DECODE(ENT_NRI_SETTLEMENT_TYPE,
                             'NRO-PIS',
                             1,
                             'NRO-NONPIS',
                             2,
                             'NRE-PIS',
                             3,
                             'NRE-NONPIS',
                             4,
                             0) BAM_NRI_RES_STATUS,
                      ENT_NRI_SETTLEMENT_TYPE,
                      DECODE(ENT_NRI_SETTLEMENT_TYPE,'NRO-NONPIS',DECODE(BAM_DEF_BNK_IND,'Y',ENT_MF_UCC_CODE,''),'NRE-NONPIS',DECODE(BAM_DEF_BNK_IND,'Y',ENT_MF_UCC_CODE,''),'') MF_UCC,
        NVL(ent_poa_flag,'N') Bam_Poa_Flag

        FROM BANK_ACCOUNT_MASTER BAM, ENTITY_MASTER EM
       WHERE BAM.BAM_ENT_ID = EM.ENT_ID
         AND EM.ENT_BANK_DP_FLG IN ('F', 'B')
         AND ENT_TEMPLET_CLIENT = 'N'
         AND ENT_UCC_SUCCESS_FLG = 'Y'
         AND (BAM_CREAT_DT >= L_LAST_LOAD_TIME OR
             BAM_LAST_UPDT_DT >= L_LAST_LOAD_TIME)
         AND EXISTS (SELECT 1
                FROM BANK_MASTER BKM
               WHERE BKM.BKM_CD = BAM_BKM_CD
                 AND NVL((SELECT '1'
                           FROM BANK_INTERFACE_MASTER BIM
                          WHERE BIM.BIM_BKM_CD = BAM_BKM_CD
                            AND BIM.BIM_STATUS = 'A'),
                         'NA') = DECODE(L_ASM_FL,
                                        1,
                                        '1',
                                        0,
                                        NVL((SELECT '1'
                                              FROM BANK_INTERFACE_MASTER BIM
                                             WHERE BIM.BIM_BKM_CD =
                                                   BAM_BKM_CD
                                               AND BIM.BIM_STATUS = 'A'),
                                            'NA')))
         AND BAM_PRG_ID != 'BANK_DATA_MIG'
       ORDER BY BAM_ENT_ID;

    PROCEDURE P_INITIALISE_VARIABLES IS
    BEGIN
      L_BAM_NO                  := NULL;
      L_BAM_BKM_CD              := NULL;
      L_BAM_ENT_ID              := NULL;
      L_BAM_STATUS              := NULL;
      L_BAM_CPD_ID              := NULL;
      L_BAM_DEF_BNK_IND         := NULL;
      L_BAM_TYPE                := NULL;
      L_BAM_CUST_ID             := NULL;
      L_BAM_BBM_CD              := NULL;
      L_BAM_NRI_RES_STATUS      := 0;
      L_ENT_NRI_SETTLEMENT_TYPE := NULL;
    END P_INITIALISE_VARIABLES;

  BEGIN
    BEGIN
      L_FLAG := 0;
      L_IND  := 5;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      SELECT RV_HIGH_VALUE
        INTO L_DATA_FILE_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'DATA_FILES'
         AND RV_LOW_VALUE = 'CSS_FILES';

      SELECT COUNT(1)
        INTO L_ASM_FL
        FROM APPLICATION_SETUP_MASTER ASM
       WHERE ASM.ASM_UTIL_ID = 'FHRT'
         AND ASM.ASM_SEG_ID = 'E'
         AND ASM.ASM_EXM_ID = 'ALL'
         AND ASM.ASM_UTIL_STATUS = 'A';

      L_IND := 10;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;

      L_IND         := 15;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Client Bank Details Upload to MTS -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      BEGIN

        L_IND := 20;
        SELECT NVL(MAX(PRG_STRT_TIME), L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM PROGRAM_STATUS
         WHERE PRG_CMP_ID = L_PRG_ID
           AND PRG_STATUS = 'C';

        SELECT COUNT(*) + 1
          INTO L_BATCH_NO
          FROM PROGRAM_STATUS
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID
           AND PRG_STATUS_FILE LIKE '%ENT_BANK_%';

        --insert record into program status
        L_IND := 25;
        SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
          INTO L_PRG_PROCESS_ID
          FROM PROGRAM_STATUS
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID;

        L_IND := 30;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status File',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      IF LENGTH(L_BATCH_NO) = 1 THEN
        L_BATCH_NO := '0' || L_BATCH_NO;
      ELSE
        L_BATCH_NO := L_BATCH_NO;
      END IF;

      --l_Data_File_Name   := 'ENT_BANK_' || To_Char(l_Curr_Date,'DDMONYYYY') || '_' || l_Batch_No ||'.TXT';
      --l_Data_File_Handle := Utl_File.Fopen(l_Data_File_Env,l_Data_File_Name,'W');

      SET TRANSACTION USE ROLLBACK SEGMENT BIG_RBS;
      L_IND := 45;

      OPEN C_BANK_ACCOUNT_MASTER;
      LOOP
        BEGIN
          P_INITIALISE_VARIABLES;
          FETCH C_BANK_ACCOUNT_MASTER
            INTO L_BAM_NO,
                 L_BAM_BKM_CD,
                 L_BAM_ENT_ID,
                 L_BAM_STATUS,
                 L_BAM_CPD_ID,
                 L_BAM_DEF_BNK_IND,
                 L_BAM_TYPE,
                 L_BAM_CUST_ID,
                 L_BAM_BBM_CD,
                 L_BAM_NRI_RES_STATUS,
                 L_ENT_NRI_SETTLEMENT_TYPE,
                 L_MFF_UCC_CD,
                 l_Bam_Poa_Flag  ;
          EXIT WHEN C_BANK_ACCOUNT_MASTER%NOTFOUND;

          IF L_BAM_NRI_RES_STATUS IN (1, 2) AND L_BAM_TYPE <> 'NO' OR
             L_BAM_NRI_RES_STATUS IN (3, 4) AND L_BAM_TYPE <> 'NE' THEN

            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Record Skipped For Client Id <' ||
                              L_BAM_ENT_ID || '> Bank Code <' ||
                              L_BAM_BKM_CD || '> Bank Branch Code <' ||
                              L_BAM_BBM_CD || '> Bank Account No <' ||
                              L_BAM_NO || '> Since Bank Account Type <' ||
                              L_BAM_TYPE ||
                              '> Not Same As NRI Settlement Type <' ||
                              L_ENT_NRI_SETTLEMENT_TYPE || '>');

          ELSE
            BEGIN
              L_IND := 50;
              UPDATE BOS_ENTITY_BANK_DETAILS
                 SET BEBD_STATUS          = L_BAM_STATUS,
                     BEBD_COMPANY_ID      = L_BAM_CPD_ID,
                     BEBD_DEFAULT_ACC     = L_BAM_DEF_BNK_IND,
                     BEBD_ACC_TYPE        = L_BAM_TYPE,
                     BEBD_ACC_CUSTOMER_ID = L_BAM_CUST_ID,
                     BEBD_BRANCH_CODE     = L_BAM_BBM_CD,
                     Bebd_Poa_Eligibility =  l_Bam_Poa_Flag,
                     BEBD_RES_STATUS      = L_BAM_NRI_RES_STATUS,
                     BEBD_UCC_CODE        = L_MFF_UCC_CD
               WHERE BEBD_ACC_NUMBER = L_BAM_NO
                 AND BEBD_BM_BANK_CODE = L_BAM_BKM_CD
                 AND BEBD_EM_ENTITY_ID = L_BAM_ENT_ID
                 AND BEBD_RES_STATUS = L_BAM_NRI_RES_STATUS;
              IF SQL%FOUND THEN
                L_UPDT := L_UPDT + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  ' Client Id Updated in MTS <' ||
                                  L_BAM_ENT_ID || '> Bank Code <' ||
                                  L_BAM_BKM_CD || '> Bank Branch Code <' ||
                                  L_BAM_BBM_CD || '> Bank Account No <' ||
                                  L_BAM_NO || '>');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
              END IF;

              IF SQL%NOTFOUND THEN
                L_IND := 55;
                INSERT INTO BOS_ENTITY_BANK_DETAILS
                  (BEBD_ACC_NUMBER,
                   BEBD_BM_BANK_CODE,
                   BEBD_EM_ENTITY_ID,
                   BEBD_STATUS,
                   BEBD_COMPANY_ID,
                   BEBD_DEFAULT_ACC,
                   BEBD_ACC_TYPE,
                   BEBD_ACC_CUSTOMER_ID,
                   BEBD_BRANCH_CODE,
                   BEBD_RES_STATUS,
                   BEBD_UCC_CODE,
                   Bebd_Poa_Eligibility)
                VALUES
                  (L_BAM_NO,
                   L_BAM_BKM_CD,
                   L_BAM_ENT_ID,
                   L_BAM_STATUS,
                   L_BAM_CPD_ID,
                   L_BAM_DEF_BNK_IND,
                   L_BAM_TYPE,
                   L_BAM_CUST_ID,
                   L_BAM_BBM_CD,
                   L_BAM_NRI_RES_STATUS,
                   L_MFF_UCC_CD,
           l_Bam_Poa_Flag);

                L_INSERT := L_INSERT + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  ' Client Id Inserted in MTS <' ||
                                  L_BAM_ENT_ID || '> Bank Code <' ||
                                  L_BAM_BKM_CD || '> Bank Branch Code <' ||
                                  L_BAM_BBM_CD || '> Bank Account No <' ||
                                  L_BAM_NO || '>');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
              END IF;

              /*l_Output_String := l_bam_ent_id            || '|' ||
                                 l_bam_bkm_cd            || '|' ||
                                 l_bam_bbm_cd            || '|' ||
                                 l_bam_no                || '|' ||
                                 l_Bam_Cust_Id           || '|' ||
                                 l_Bam_Status            || '|' ||
                                 l_Bam_Def_Bnk_Ind       || '|' ||
                                 l_Bam_Type              || '|' ||
                                 l_Bam_Nri_Res_Status;

              Utl_File.Put_Line(l_Data_File_Handle,l_Output_String);
              Utl_File.Fflush(l_Data_File_Handle);*/

            EXCEPTION
              WHEN OTHERS THEN
                L_FAIL := L_FAIL + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  '--------------------------------------------------------------------------------------------');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  ' Failed For Client Id <' || L_BAM_ENT_ID ||
                                  '> Bank Code <' || L_BAM_BKM_CD ||
                                  '> Bank Branch Code <' || L_BAM_BBM_CD ||
                                  '> Bank Account No <' || L_BAM_NO || '>');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);

                L_FLAG := 1;
                IF L_IND = 45 THEN
                  L_DESC := 'Error while Fetching the records from  Client Bank Details Cursor :' ||
                            SQLERRM;
                ELSIF L_IND = 50 THEN
                  L_DESC := 'Error while updating the records in MTS Client Bank Details  :' ||
                            SQLERRM;
                ELSIF L_IND = 55 THEN
                  L_DESC := 'Error while inserting the records in MTS Client Bank Details  :' ||
                            SQLERRM;
                END IF;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END;
          END IF;
          L_FETCH := L_FETCH + 1;

        END;
      END LOOP;
      CLOSE C_BANK_ACCOUNT_MASTER;

      /*IF Utl_File.Is_Open(l_Data_File_Handle) THEN
        Utl_File.Fclose(l_Data_File_Handle);
      END IF;*/

      IF (L_FETCH = 0) THEN
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'No records to be uploaded to MTS');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        --Utl_File.Fremove(l_Data_File_Env,l_Data_File_Name);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        L_FLAG := 1;
        IF L_IND = 1 THEN
          L_DESC := 'Error while Setting the Sql Trace : ' || SQLERRM;
        ELSIF L_IND = 5 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Selecting from  Parameter Master : ' ||
                    SQLERRM;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        ELSIF L_IND = 20 THEN
          L_DESC := 'Error while Selecting Last Load time from  Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 25 THEN
          L_DESC := 'Error while Selecting Process Id from Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 30 THEN
          L_DESC := 'Error while inserting the records in Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 45 THEN
          L_DESC := 'Error while Fetching the Client Bank Details Cursor : ' ||
                    SQLERRM;
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Fetched: ' || L_FETCH);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Inserted: ' || L_INSERT);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Updated: ' || L_UPDT);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Skipped: ' ||
                      (L_FETCH - L_INSERT - L_UPDT));
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    IF L_FLAG = 0 THEN
      BEGIN
        UPDATE PROGRAM_STATUS
           SET PRG_STATUS       = 'C',
               PRG_STATUS_FILE  = /*Decode(l_fetch,0,*/ 'No Status File' /*,l_Data_File_Env||l_Data_File_Name)*/,
               PRG_END_TIME     = SYSDATE,
               PRG_LAST_UPDT_BY = USER,
               PRG_LAST_UPDT_DT = SYSDATE
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID
           AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Error while updating the records in program status for Success :' ||
                            SQLERRM);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
      END;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Process of Uploading Client Bank Details to MTS successfully completed at ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.FCLOSE_ALL;
      COMMIT;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        UPDATE PROGRAM_STATUS
           SET PRG_STATUS       = 'E',
               PRG_END_TIME     = SYSDATE,
               PRG_LAST_UPDT_BY = USER,
               PRG_LAST_UPDT_DT = SYSDATE
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID
           AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Error while updating the records in program status for Error :' ||
                            SQLERRM);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
      END;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Number of records Failed: ' || L_FAIL);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Process of Uploading Client Bank Details to MTS Unsuccessful');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.FCLOSE_ALL;
      COMMIT;
    END IF;
  END P_LOAD_ENT_BANK_DETAILS_MTS;

  PROCEDURE P_LOAD_ENT_DP_DETAILS_MTS IS

    L_UPDT               NUMBER := 0;
    L_INSERT             NUMBER := 0;
    L_FETCH              NUMBER := 0;
    L_FAIL               NUMBER := 0;
    L_CURR_DATE          PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID             VARCHAR2(30) := 'CSSBDDUP';
    L_PRG_PROCESS_ID     NUMBER := 0;
    L_FILE_HANDLE        UTL_FILE.FILE_TYPE;
    L_LOG_ENV            VARCHAR2(100);
    L_FILE_NAME          VARCHAR2(70);
    L_DESC               VARCHAR2(300);
    L_IND                NUMBER := 0;
    L_FLAG               NUMBER := 0;
    L_FIRST_LOAD_TIME    DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME     DATE;
    L_ASM_FL             NUMBER;
    L_MDI_ID             VARCHAR2(30);
    L_MDI_ACC_TYPE       VARCHAR2(2);
    L_MDI_TYPE           VARCHAR2(3);
    L_MDI_DPM_DEM_ID     VARCHAR2(30);
    L_MDI_DPM_ID         VARCHAR2(30);
    L_MDI_DP_ACC_NO      VARCHAR2(30);
    L_MDI_STATUS         VARCHAR2(1);
    L_MDI_DEFAULT_FLAG   VARCHAR2(1);
    L_MDI_CUST_ID        VARCHAR2(30);
    L_MDI_NRI_RES_STATUS NUMBER;
    --l_Data_File_Name             VARCHAR2(100);
    --l_Data_File_Handle           Utl_File.File_Type;
    L_BATCH_NO      VARCHAR2(100) := '0';
    L_DATA_FILE_ENV VARCHAR2(100);
    --l_Output_String              VARCHAR2(32767);
    L_MFF_UCC_CD VARCHAR2(30);
  l_Mdi_Cl_Holding               VARCHAR2(2);
      l_Mdi_Cl_APP2                   VARCHAR2(175);
      l_Mdi_Cl_PAN2                   VARCHAR2(10);
      l_Mdi_Cl_NOMINEE               VARCHAR2(35);
      l_Mdi_Cl_NOMINEE_RL            VARCHAR2(20);
      l_Mdi_Cl_APP3                   VARCHAR2(175);
      l_Mdi_Cl_PAN3                   VARCHAR2(10);
      L_MDI_POA_FLG                   VARCHAR2(1):='N';

    CURSOR C_ENT_DP_DETAILS IS
      SELECT DISTINCT DECODE(ENT_CTG_DESC, 11, ENT_EXCH_CLIENT_ID, MDI_ID) MDI_ID,
                      NVL(MDI_ACC_TYPE, '02') MDI_ACC_TYPE,
                      MDI_TYPE,
                      MDI_DPM_DEM_ID,
                      MDI_DPM_ID,
                      MDI_DP_ACC_NO,
                      DECODE(ENT_STATUS,
                             'E',
                             DECODE(MDI_STATUS, 'A', 'E', 'N', 'E', 'D'),
                             'D'),
                      DECODE(ENT_STATUS,
                             'E',
                             NVL(MDI_DEFAULT_FLAG, 'N'),
                             'N'),
                      MDI_CUST_ID,
                      DECODE(ENT_NRI_SETTLEMENT_TYPE,
                             'NRO-PIS',
                             1,
                             'NRO-NONPIS',
                             2,
                             'NRE-PIS',
                             3,
                             'NRE-NONPIS',
                             4,
                             0) MDI_NRI_RES_STATUS,
                      DECODE(ENT_NRI_SETTLEMENT_TYPE,
                             'NRO-NONPIS',
                             DECODE(MDI_DEFAULT_FLAG,
                                    'Y',
                                    ENT_MF_UCC_CODE,
                                    ''),
                             'NRE-NONPIS',
                             DECODE(MDI_DEFAULT_FLAG,
                                    'Y',
                                    ENT_MF_UCC_CODE,
                                    ''),
                             '') MF_UCC

        FROM MEMBER_DP_INFO MDI, ENTITY_MASTER EM
       WHERE MDI.MDI_ID = EM.ENT_ID
         AND EM.ENT_BANK_DP_FLG IN ('B', 'D')
         AND ENT_TEMPLET_CLIENT = 'N'
         AND ENT_UCC_SUCCESS_FLG = 'Y'
         AND (MDI_CREAT_DT >= L_LAST_LOAD_TIME OR
             MDI_LAST_UPDT_DT >= L_LAST_LOAD_TIME)
         AND EXISTS (SELECT 1
                FROM DEPO_PARTICIPANT_MASTER DPM
               WHERE DPM.DPM_DEM_ID = MDI_DPM_DEM_ID
                 AND DPM.DPM_ID = MDI_DPM_ID
                 AND NVL(DPM.DPM_AGENCY_CD, 'NA') =
                     DECODE(L_ASM_FL,
                            1,
                            DPM.DPM_AGENCY_CD,
                            0,
                            NVL(DPM.DPM_AGENCY_CD, 'NA')))
         AND MDI_PRG_ID != 'DP_DATA_MIG'
       ORDER BY MDI_ID;

    PROCEDURE P_INITIALISE_VARIABLES IS
    BEGIN
      L_MDI_ID             := NULL;
      L_MDI_ACC_TYPE       := NULL;
      L_MDI_TYPE           := NULL;
      L_MDI_DPM_DEM_ID     := NULL;
      L_MDI_DPM_ID         := NULL;
      L_MDI_DP_ACC_NO      := NULL;
      L_MDI_STATUS         := NULL;
      L_MDI_DEFAULT_FLAG   := NULL;
      L_MDI_CUST_ID        := NULL;
      L_MDI_NRI_RES_STATUS := 0;

    l_Mdi_Cl_Holding       := NULL;
         l_Mdi_Cl_APP2          := NULL;
         l_Mdi_Cl_PAN2          := NULL;
         l_Mdi_Cl_NOMINEE       := NULL;
         l_Mdi_Cl_NOMINEE_RL    := NULL;
         l_Mdi_Cl_APP3          := NULL;
         l_Mdi_Cl_PAN3          := NULL;

    END P_INITIALISE_VARIABLES;

  BEGIN
    BEGIN

      L_FLAG := 0;
      L_IND  := 1;
      L_IND  := 5;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      SELECT RV_HIGH_VALUE
        INTO L_DATA_FILE_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'DATA_FILES'
         AND RV_LOW_VALUE = 'CSS_FILES';

      L_IND := 10;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;

      SELECT COUNT(1)
        INTO L_ASM_FL
        FROM APPLICATION_SETUP_MASTER ASM
       WHERE ASM.ASM_UTIL_ID = 'FHRT'
         AND ASM.ASM_SEG_ID = 'E'
         AND ASM.ASM_EXM_ID = 'ALL'
         AND ASM.ASM_UTIL_STATUS = 'A';

      L_IND         := 15;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Client DP Details Upload to MTS  -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      --get last run time for completed batch
      L_IND := 20;
      SELECT NVL(MAX(PRG_STRT_TIME), L_FIRST_LOAD_TIME)
        INTO L_LAST_LOAD_TIME
        FROM PROGRAM_STATUS
       WHERE PRG_CMP_ID = L_PRG_ID
         AND PRG_STATUS = 'C';

      L_IND := 25;
      --insert record into program status
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID;

      SELECT COUNT(*) + 1
        INTO L_BATCH_NO
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID
         AND PRG_STATUS_FILE LIKE '%ENT_DP_%';

      BEGIN
        L_IND := 30;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status File',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      IF LENGTH(L_BATCH_NO) = 1 THEN
        L_BATCH_NO := '0' || L_BATCH_NO;
      ELSE
        L_BATCH_NO := L_BATCH_NO;
      END IF;

      --l_Data_File_Name   := 'ENT_DP_' || To_Char(l_Curr_Date,'DDMONYYYY') || '_' || l_Batch_No ||'.TXT';
      --l_Data_File_Handle := Utl_File.Fopen(l_Data_File_Env,l_Data_File_Name,'W');

      L_IND := 45;

      SET TRANSACTION USE ROLLBACK SEGMENT BIG_RBS;

      OPEN C_ENT_DP_DETAILS;
      LOOP
        BEGIN
          P_INITIALISE_VARIABLES;
          FETCH C_ENT_DP_DETAILS
            INTO L_MDI_ID,
                 L_MDI_ACC_TYPE,
                 L_MDI_TYPE,
                 L_MDI_DPM_DEM_ID,
                 L_MDI_DPM_ID,
                 L_MDI_DP_ACC_NO,
                 L_MDI_STATUS,
                 L_MDI_DEFAULT_FLAG,
                 L_MDI_CUST_ID,
                 L_MDI_NRI_RES_STATUS,
                 L_MFF_UCC_CD;
          EXIT WHEN C_ENT_DP_DETAILS%NOTFOUND;

          BEGIN
            L_IND := 50;
            UPDATE BOS_ENTITY_DP_DETAILS
               SET BEDD_AC_TYPE         = L_MDI_ACC_TYPE,
                   BEDD_DEFAULT_AC      = L_MDI_DEFAULT_FLAG,
                   BEDD_AC_STATUS       = L_MDI_STATUS,
                   BEDD_ACC_CUSTOMER_ID = L_MDI_CUST_ID,
                   BEDD_UCC_CODE        = L_MFF_UCC_CD,
           BEDD_POA_ELIGIBILITY = l_Mdi_Poa_Flg,
                    BEDD_MODE_OF_HOLD       = l_Mdi_Cl_Holding,
                    BEDD_SECOND_CLIENT_NAME = l_Mdi_Cl_APP2,
                    BEDD_SECOND_CLIENT_PAN  = l_Mdi_Cl_PAN2 ,
                    BEDD_NOMINEE_NAME       = l_Mdi_Cl_NOMINEE,
                    BEDD_NOMINEE_RELATION   = l_Mdi_Cl_NOMINEE_RL,
                    BEDD_THIRD_CLIENT_NAME  = l_Mdi_Cl_APP3,
                    BEDD_THIRD_CLIENT_PAN   = l_Mdi_Cl_PAN3
             WHERE BEDD_EM_ENTITY_ID = L_MDI_ID
               AND BEDD_DP_CODE = L_MDI_DPM_ID
               AND BEDD_AC_NO = SUBSTR(L_MDI_DP_ACC_NO, -8)
               AND BEDD_RES_STATUS = L_MDI_NRI_RES_STATUS;

            IF SQL%FOUND THEN
              L_UPDT := L_UPDT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                ' Client Id Updated in MTS <' || L_MDI_ID ||
                                '> DP Id <' || L_MDI_DPM_ID ||
                                '> DP Account No <' || L_MDI_DP_ACC_NO || '>');
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            IF SQL%NOTFOUND THEN
              L_IND := 55;
              INSERT INTO BOS_ENTITY_DP_DETAILS
                (BEDD_EM_ENTITY_ID,
                 BEDD_DP_CODE,
                 BEDD_AC_NO,
                 BEDD_AC_TYPE,
                 BEDD_DEFAULT_AC,
                 BEDD_AC_STATUS,
                 BEDD_ACC_CUSTOMER_ID,
                 BEDD_RES_STATUS,
                 BEDD_UCC_CODE,
         BEDD_POA_ELIGIBILITY,
                 BEDD_MODE_OF_HOLD,
                 BEDD_SECOND_CLIENT_NAME,
                 BEDD_SECOND_CLIENT_PAN,
                 BEDD_NOMINEE_NAME ,
                 BEDD_NOMINEE_RELATION ,
                 BEDD_THIRD_CLIENT_NAME ,
                 BEDD_THIRD_CLIENT_PAN
         )
              VALUES
                (L_MDI_ID,
                 L_MDI_DPM_ID,
                 SUBSTR(L_MDI_DP_ACC_NO, -8),
                 L_MDI_ACC_TYPE,
                 L_MDI_DEFAULT_FLAG,
                 L_MDI_STATUS,
                 L_MDI_CUST_ID,
                 L_MDI_NRI_RES_STATUS,
                 L_MFF_UCC_CD,
                 l_Mdi_Poa_Flg,
                 l_Mdi_Cl_Holding,
                 l_Mdi_Cl_APP2,
                 l_Mdi_Cl_PAN2 ,
                 l_Mdi_Cl_NOMINEE,
                 l_Mdi_Cl_NOMINEE_RL,
                 l_Mdi_Cl_APP3,
                 l_Mdi_Cl_PAN3);

              L_INSERT := L_INSERT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                ' Client Id Inserted in MTS <' || L_MDI_ID ||
                                '> DP Id <' || L_MDI_DPM_ID ||
                                '> DP Account No <' || L_MDI_DP_ACC_NO || '>');
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            /*l_Output_String := l_Mdi_Id                    || '|' ||
                               l_Mdi_Dpm_Id                || '|' ||
                               Substr(l_Mdi_Dp_Acc_No,-8)  || '|' ||
                               l_Mdi_Cust_Id               || '|' ||
                               l_Mdi_Acc_Type              || '|' ||
                               l_Mdi_Default_Flag          || '|' ||
                               l_Mdi_Status                || '|' ||
                               l_Mdi_Nri_Res_Status;

            Utl_File.Put_Line(l_Data_File_Handle,l_Output_String);
            Utl_File.Fflush(l_Data_File_Handle);*/

          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                '--------------------------------------------------------------------------------------------');
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                ' Failed For Client Id Inserted in MTS <' ||
                                L_MDI_ID || '> DP Id <' || L_MDI_DPM_ID ||
                                '> DP Account No <' || L_MDI_DP_ACC_NO || '>');
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
              L_FLAG := 1;
              IF L_IND = 45 THEN
                L_DESC := 'Error while Fetching the records from  Client DP Details Cursor :' ||
                          SQLERRM;
              ELSIF L_IND = 50 THEN
                L_DESC := 'Error while updating the records in MTS Client DP Details  :' ||
                          SQLERRM;
              ELSIF L_IND = 55 THEN
                L_DESC := 'Error while inserting the records in MTS Client DP Details  :' ||
                          SQLERRM;
              END IF;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
          END;
          L_FETCH := L_FETCH + 1;

        END;
      END LOOP;
      CLOSE C_ENT_DP_DETAILS;

      /*IF Utl_File.Is_Open(l_Data_File_Handle) THEN
        Utl_File.Fclose(l_Data_File_Handle);
      END IF;*/

      IF (L_FETCH = 0) THEN
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'No records to be uploaded to MTS Client DP DETAILS ');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        --Utl_File.Fremove(l_Data_File_Env,l_Data_File_Name);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        L_FLAG := 1;
        IF L_IND = 1 THEN
          L_DESC := 'Error while Setting the Sql Trace : ' || SQLERRM;
        ELSIF L_IND = 5 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Selecting from  Parameter Master : ' ||
                    SQLERRM;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        ELSIF L_IND = 20 THEN
          L_DESC := 'Error while Selecting Last Load time from  Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 25 THEN
          L_DESC := 'Error while Selecting Process Id from Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 30 THEN
          L_DESC := 'Error while inserting the records in Program Status  : ' ||
                    SQLERRM;
        ELSIF L_IND = 45 THEN
          L_DESC := 'Error while Fetching the Client DP Details Cursor : ' ||
                    SQLERRM;
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Fetched: ' || L_FETCH);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Inserted: ' || L_INSERT);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Updated: ' || L_UPDT);
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    IF L_FLAG = 0 THEN
      BEGIN
        UPDATE PROGRAM_STATUS
           SET PRG_STATUS       = 'C',
               PRG_STATUS_FILE  = /*Decode(l_fetch,0,*/ 'No Status File' /*,l_Data_File_Env||l_Data_File_Name)*/,
               PRG_END_TIME     = SYSDATE,
               PRG_LAST_UPDT_BY = USER,
               PRG_LAST_UPDT_DT = SYSDATE
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID
           AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Error while updating the records in program status for Success :' ||
                            SQLERRM);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
      END;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Process of Uploading Client DP Details to MTS  successfully completed at ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.FCLOSE_ALL;
      COMMIT;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        UPDATE PROGRAM_STATUS
           SET PRG_STATUS       = 'E',
               PRG_END_TIME     = SYSDATE,
               PRG_LAST_UPDT_BY = USER,
               PRG_LAST_UPDT_DT = SYSDATE
         WHERE PRG_DT = L_CURR_DATE
           AND PRG_CMP_ID = L_PRG_ID
           AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Error while updating the records in program status :' ||
                            SQLERRM);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
      END;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Number of records Failed: ' || L_FAIL);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Process of Uploading Client DP Details to MTS  Unsuccessful');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.FCLOSE_ALL;
      COMMIT;
    END IF;
  END P_LOAD_ENT_DP_DETAILS_MTS;

  PROCEDURE P_LOAD_ENTITY_MTS IS

    L_ENTITY_ID                  ENTITY_MASTER.ENT_ID%TYPE;
    L_ENTITY_NAME                ENTITY_MASTER.ENT_NAME%TYPE;
    L_ENTITY_TYPE                ENTITY_MASTER.ENT_TYPE%TYPE;
    L_ENTITY_CLIENT_TYPE         ENTITY_MASTER.ENT_CLIENT_TYPE%TYPE;
    L_ENT_CATEGORY               VARCHAR2(3);
    L_ENTITY_STATUS              ENTITY_MASTER.ENT_STATUS%TYPE;
    L_ENTITY_CTRL_ID             ENTITY_MASTER.ENT_CTRL_ID%TYPE;
    L_ENTITY_FAMILY_ID           ENTITY_MASTER.ENT_FAMILY_ID%TYPE;
    L_ENT_DOB                    ENTITY_MASTER.ENT_DOB %TYPE;
    L_ENTITY_ADD_LINE_1          ENTITY_MASTER.ENT_ADDRESS_LINE_1%TYPE;
    L_ENTITY_ADD_LINE_2          ENTITY_MASTER.ENT_ADDRESS_LINE_2%TYPE;
    L_ENTITY_ADD_LINE_3          ENTITY_MASTER.ENT_ADDRESS_LINE_3%TYPE;
    L_ENTITY_ADD_LINE_4          ENTITY_MASTER.ENT_ADDRESS_LINE_4%TYPE;
    L_ENTITY_ADD_LINE_5          ENTITY_MASTER.ENT_ADDRESS_LINE_5%TYPE;
    L_ENTITY_ADD_LINE_6          ENTITY_MASTER.ENT_ADDRESS_LINE_6%TYPE;
    L_ENTITY_ADD_LINE_7          ENTITY_MASTER.ENT_ADDRESS_LINE_7%TYPE;
    L_ENTITY_PHNO_1              ENTITY_MASTER.ENT_PHONE_NO_1%TYPE;
    L_ENTITY_PHNO_2              ENTITY_MASTER.ENT_PHONE_NO_2%TYPE;
    L_ENTITY_FAXNO_1             ENTITY_MASTER.ENT_FAX_NO_1%TYPE;
    L_ENTITY_FAXNO_2             ENTITY_MASTER.ENT_FAX_NO_2%TYPE;
    L_ENT_EOD_REL_FLG            ENTITY_MASTER.ENT_EOD_REL_FLG %TYPE;
    L_ENT_INTERNET_PRIV          ENTITY_MASTER.ENT_INTERNET_PRIV %TYPE;
    L_ENTITY_LOGIN_ID            ENTITY_MASTER.ENT_LOGIN_ID%TYPE;
    L_ERD_PAN_NO                 ENTITY_REGISTRATION_DETAILS.ERD_PAN_NO %TYPE;
    L_ENT_CSC_ID                 ENTITY_MASTER.ENT_CSC_ID %TYPE;
    L_ENTITY_EMAIL_ID            ENTITY_DETAILS.END_EMAIL_ID%TYPE;
    L_ENT_DISCLOSURE_FLAG        VARCHAR2(1);
    L_BAM_ACC_NO                 BANK_ACCOUNT_MASTER.BAM_NO %TYPE;
    L_BAM_ACC_TYPE               BANK_ACCOUNT_MASTER.BAM_TYPE %TYPE;
    L_BAM_CUST_ID                BANK_ACCOUNT_MASTER.BAM_CUST_ID %TYPE;
    L_DP_ACC_NO                  MEMBER_DP_INFO.MDI_DP_ACC_NO %TYPE;
    L_DP_ACC_STATUS              MEMBER_DP_INFO.MDI_STATUS %TYPE;
    L_UPDT                       NUMBER := 0;
    L_INSERT                     NUMBER := 0;
    L_FETCH                      NUMBER := 0;
    L_FAIL                       NUMBER := 0;
    L_CURR_DATE                  PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID                     VARCHAR2(30) := 'CSSBMTSUP';
    L_PRG_PROCESS_ID             NUMBER := 0;
    L_FILE_HANDLE                UTL_FILE.FILE_TYPE;
    L_FILE_NAME                  VARCHAR2(70);
    L_DESC                       VARCHAR2(300);
    L_FLAG                       NUMBER := 0;
    L_ENT_PRIV                   VARCHAR2(50);
    L_FIRST_LOAD_TIME            DATE := '01-jan-1900';
    L_LAST_LOAD_TIME             DATE;
    L_MTS_COMPANY_ID             VARCHAR2(30);
    L_ENT_SEC_REL_FL             ENTITY_MASTER.ENT_SEC_REL_FL%TYPE;
    L_ENT_ORD_CONF_FL            ENTITY_MASTER.ENT_ORDER_CONFIRM%TYPE;
    L_ENT_TRD_CONF_FL            ENTITY_MASTER.ENT_TRD_CONFIRM%TYPE;
    L_SEG_FL                     ENTITY_MASTER.ENT_SEG_FLAG%TYPE;
    L_ENT_MOBILE_NO              ENTITY_MASTER.ENT_MOBILE_NO%TYPE;
    L_ENT_CTG_DESC               ENTITY_MASTER.ENT_CTG_DESC%TYPE;
    L_BAM_BKM_CD                 BANK_ACCOUNT_MASTER.BAM_BKM_CD%TYPE;
    L_BAM_STATUS                 BANK_ACCOUNT_MASTER.BAM_STATUS%TYPE;
    L_MDI_DPM_ID                 MEMBER_DP_INFO.MDI_DPM_ID%TYPE;
    L_MDI_ACC_TYPE               MEMBER_DP_INFO.MDI_ACC_TYPE%TYPE;
    L_MDI_CUST_ID                MEMBER_DP_INFO.MDI_CUST_ID%TYPE;
    L_MARGIN_CC_PRIV_FLAG        VARCHAR2(1);
    L_PVM_SCM_ID                 ENTITY_ATTRIBUTE_MASTER.EAM_PVM_SCM_ID%TYPE;
    L_CC_FLAG                    VARCHAR2(1);
    L_M_OFF_FLAG                 VARCHAR2(1);
    L_MO_FLAG                    VARCHAR2(1);
    L_HRT_CNT                    NUMBER := 0;
    L_CPS_SEG_ID                 BASE_CP_MASTER.CPS_SEG_ID%TYPE;
    L_CPS_EXM_ID                 BASE_CP_MASTER.CPS_EXM_ID%TYPE;
    L_CPS_CPID                   BASE_CP_MASTER.CPS_CPID%TYPE;
    L_NSE_EQ_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_NSE_DR_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_NSE_CR_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_BSE_EQ_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_BSE_DR_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_BSE_CR_CP_ID               BASE_CP_MASTER.CPS_CPID%TYPE;
    L_ENT_EXCH_CLIENT_ID         ENTITY_MASTER.ENT_EXCH_CLIENT_ID%TYPE;
    L_ENT_INT_TRD_PRIV           ENTITY_MASTER.ENT_INT_TRD_PRIV%TYPE;
    L_ENT_SMS_ALERT_FL           ENTITY_MASTER.ENT_SMS_ALERT_FL%TYPE;
    L_ENT_CLIENT_TYPE            VARCHAR2(3);
    L_EPM_SEG_EQUITY             VARCHAR2(1);
    L_EPM_SEG_DERIVATIVES        VARCHAR2(1);
    L_EPM_SEG_CF                 VARCHAR2(1);
    L_EPM_SEG_SLB                VARCHAR2(1);
    L_EPM_SEG_COMMODITIES        VARCHAR2(1);
    L_EPM_SEG_MFSS               VARCHAR2(1);
    L_EPM_CHANNEL_INTERNET       VARCHAR2(1);
    L_EPM_CHANNEL_CALL_N_TRADE   VARCHAR2(1);
    L_EPM_CHANNEL_TWS            VARCHAR2(1);
    L_EPM_CHANNEL_IVRS           VARCHAR2(1);
    L_EPM_CHANNEL_MOBILE         VARCHAR2(1);
    L_EPM_PRODUCT_CC             VARCHAR2(1);
    L_EPM_PRODUCT_MARGIN_ONLINE  VARCHAR2(1);
    L_EPM_PRODUCT_MARGIN_OFFLINE VARCHAR2(1);
    L_EPM_PRODUCT_BTST           VARCHAR2(1);
    L_EPM_PRODUCT_SPOT           VARCHAR2(1);
    L_EPM_PRODUCT_SIP            VARCHAR2(1);
    L_EPM_PRODUCT_SPOT_CAP       NUMBER(15);
    L_EPM_PRODUCT_MARGIN_PLUS    VARCHAR2(1);
    L_EPM_PRODUCT_T5             VARCHAR2(1);
    L_EPM_PRODUCT_MLB            VARCHAR2(1);
    L_EPM_PRODUCT_MLB_CAP        NUMBER(15);
    L_EPM_PRODUCT_T2             VARCHAR2(1);
    L_EPM_PRODUCT_T2_CAP         NUMBER(15);
    L_EPM_SMS_TRADE_CONFIRM      VARCHAR2(1);
    L_EPM_SMS_MRG_VOILATION      VARCHAR2(1);
    L_EPM_EMAIL_CONTRACT_NOTE    VARCHAR2(1);
    L_EPM_EMAIL_CLIENT_LEDGER    VARCHAR2(1);
    L_EPM_SEG_MFD                VARCHAR2(1);
    L_PRODUCT_PRIV_FLAG          VARCHAR2(100);
    L_SUCCESS                    VARCHAR2(1) := 'Y';
    L_STR                        VARCHAR2(2000);
    L_CHECK_ENT_ID               ENTITY_MASTER.ENT_ID%TYPE;
    DONT_SEND EXCEPTION;
    --l_Data_File_Name               VARCHAR2(100);
    --l_Data_File_Handle             Utl_File.File_Type;
    L_BATCH_NO VARCHAR2(100);
    L_LOG_ENV  VARCHAR2(100);
    --l_Output_String                VARCHAR2(32767);
    L_ENT_NATIONALITY             VARCHAR2(50);
    L_ENT_TITLE                   VARCHAR2(10);
    L_ENT_FIRST_NAME              VARCHAR2(80);
    L_ENT_MIDDLE_NAME             VARCHAR2(80);
    L_ENT_LAST_NAME               VARCHAR2(80);
    L_ENT_OCCUPATION              VARCHAR2(80);
    L_EQ_BRK_SCHEME               VARCHAR2(80);
    L_DR_BRK_SCHEME               VARCHAR2(80);
    L_SEGMENT                     VARCHAR2(1);
    L_ENT_BANK_CATEGORY           VARCHAR2(100);
    L_ENT_TRADE_CATEGORY          VARCHAR2(100);
    L_ENT_BANK_CATEGORY_DESC      VARCHAR2(100);
    L_ENT_TRADE_CATEGORY_DESC     VARCHAR2(100);
    L_EPM_PRODUCT_COLLATERAL_SELL VARCHAR2(1);
    L_EPR_APPLN_NO                VARCHAR2(20);
    L_EPM_SEG_EQUITY_BSE          VARCHAR2(1);
    L_EPM_SEG_DERIVATIVES_BSE     VARCHAR2(1);
    L_EPM_SEG_CF_BSE              VARCHAR2(1);
    L_EPM_SEG_SLB_BSE             VARCHAR2(1);
    L_EPM_SEG_COMMODITIES_BSE     VARCHAR2(1);
    L_EPM_SEG_MFSS_BSE            VARCHAR2(1);
    L_EPM_SEG_CF_MCX              VARCHAR2(1);
    L_EPM_SEG_COMMODITIES_MCX     VARCHAR2(1);
    O_LOG_FILE                    VARCHAR2(32767);
    O_STATUS                      VARCHAR2(100);
    L_SEBI_STATUS                 VARCHAR2(1);
    E_BANNED_ENTITY_ERROR EXCEPTION;
    L_DMG_STATUS             ENTITY_DMG_CHNG.EDC_ENTITY_DMG_FLAG%TYPE;
    L_DMG_DEFAULT_VAL        VARCHAR2(1) := 'Y';
    L_MOBILE_TRADING         VARCHAR2(1);
    L_ENT_FOS_PROFILE_ID     VARCHAR2(30); /*HSL3.5*/
    L_MDI_CL_APP2            MEMBER_DP_INFO.MDI_CL_APP2%TYPE;
    L_MDI_CL_APP3            MEMBER_DP_INFO.MDI_CL_APP3%TYPE;
    L_MDI_CL_PAN2            MEMBER_DP_INFO.MDI_CL_PAN2%TYPE;
    L_MDI_CL_PAN3            MEMBER_DP_INFO.MDI_CL_PAN3%TYPE;
    L_MDI_TAX_STATUS         MEMBER_DP_INFO.MDI_CL_APP2%TYPE;
    L_ENT_SEX                ENTITY_MASTER.ENT_SEX%TYPE;
    L_ERD_GUARD_NAME         ENTITY_REGISTRATION_DETAILS.ERD_GUARD_NAME%TYPE;
    L_ERD_GUARDIAN_PAN       ENTITY_REGISTRATION_DETAILS.ERD_GUARDIAN_PAN%TYPE;
    L_MDI_CL_NOMINEE         MEMBER_DP_INFO.MDI_CL_NOMINEE%TYPE;
    L_MDI_CL_NOMINEE_RL      MEMBER_DP_INFO.MDI_CL_NOMINEE_RL%TYPE;
    L_MDI_CL_HOLDING         MEMBER_DP_INFO.MDI_CL_HOLDING%TYPE;
    L_EMD_KYC_COMPLIANT      ENTITY_MFSS_DETAILS.EMD_KYC_COMPLIANT%TYPE;
    L_EMD_CL_DIV_PAYMODE     ENTITY_MFSS_DETAILS.EMD_CL_DIV_PAYMODE%TYPE;
    L_EMD_COMMUNICATION_MODE ENTITY_MFSS_DETAILS.EMD_COMMUNICATION_MODE%TYPE;
    L_BBM_NEFT_CODE          BANK_BRANCH_MASTER.BBM_ETF_CD%TYPE;
    L_ENT_EUIN_NUMBER        ENTITY_MASTER.ENT_EUIN_NO%TYPE;
    L_ERM_RISK_TYPE          ENTITY_RISK_MAPPING.ERM_RISK_TYPE%TYPE;
    L_ECM_RISK_TYPE_FL       ENTITY_COMPLIANCE_DTLS.ECM_RISK_TYPE_FL%TYPE;
    L_ENT_PEP                ENTITY_MASTER.ENT_PEP%TYPE;
    L_ENT_PEP_RELATED        ENTITY_MASTER.ENT_PEP_RELATED%TYPE;
    L_ERD_ADH_NO             ENTITY_REGISTRATION_DETAILS.ERD_ADH_NO%TYPE;
    L_ENT_UID_VERIFIED_YN    ENTITY_MASTER.ENT_UID_VERIFIED_YN%TYPE;
    l_Margin_Fund_Mode             Entity_Registration_Details.ERD_MARGIN_FUND_MODE%TYPE;
    l_Margin_Fund_Date             Entity_Registration_Details.ERD_MARGIN_FUND_DATE%TYPE;
    l_Margin_Fund_Flag             Entity_Registration_Details.ERD_MARGIN_FUND_FLAG%TYPE;
    l_Margin_Fund_User             Entity_Registration_Details.ERD_MARGIN_FUND_USER%TYPE;

    L_INSERT_PROXY_CLIENT NUMBER := 0;
    L_UPDATE_PROXY_CLIENT NUMBER := 0;
    O_SQLERRM             VARCHAR2(3000);


  L_EPM_ADV_PORTFOLIO      VARCHAR2(1) := 'N';
   /* L_MARGIN_FUND_MODE       ENTITY_REGISTRATION_DETAILS.ERD_MARGIN_FUND_MODE%TYPE;
    L_MARGIN_FUND_DATE       ENTITY_REGISTRATION_DETAILS.ERD_MARGIN_FUND_DATE%TYPE;
    L_MARGIN_FUND_FLAG       ENTITY_REGISTRATION_DETAILS.ERD_MARGIN_FUND_FLAG%TYPE;
    L_MARGIN_FUND_USER       ENTITY_REGISTRATION_DETAILS.ERD_MARGIN_FUND_USER%TYPE;*/
    L_ENT_RM_ID              varchar2(30);
    L_ERD_US_NRI_FLG         varchar2(10);
    L_ERD_CKYC_NO            varchar2(30);

    CURSOR C_ENTITY IS
      SELECT ENT_ID,
             SUBSTR(ENT_NAME, 1, 60),
             ENT_TYPE,
             ENT_CLIENT_TYPE,
             ENT_CATEGORY,
             ENT_STATUS,
             COALESCE(ENT_CTRL_ID, ENT_DERV_CTRL_ID, ENT_CURR_CTRL_ID),
             ENT_FAMILY_ID,
             ENT_DOB,
             SUBSTR(ENT_ADDRESS_LINE_1, 1, 50),
             SUBSTR(ENT_ADDRESS_LINE_2, 1, 50),
             SUBSTR(ENT_ADDRESS_LINE_3, 1, 50),
             SUBSTR(ENT_ADDRESS_LINE_4, 1, 35),
             SUBSTR(ENT_ADDRESS_LINE_5, 1, 30),
             NVL(SUBSTR(ENT_ADDRESS_LINE_6, 1, 35), 'INDIA'),
             SUBSTR(ENT_ADDRESS_LINE_7, 1, 10),
             SUBSTR(ENT_ISD_CODE_PHONE_NO_1 || ENT_STD_CODE_PHONE_NO_1 ||
                    ENT_PHONE_NO_1,
                    1,
                    30),
             SUBSTR(ENT_ISD_CODE_PHONE_NO_2 || ENT_STD_CODE_PHONE_NO_2 ||
                    ENT_PHONE_NO_2,
                    1,
                    30),
             ENT_FAX_NO_1,
             ENT_FAX_NO_2,
             ENT_REL_FL,
             ENT_INTERNET_PRIV,
             ERD_PAN_NO,
             ENT_CSC_ID,
             ENT_LOGIN_ID,
             ENT_SEC_REL_FL,
             ENT_ORDER_CONFIRM,
             ENT_TRD_CONFIRM,
             ENT_SEG_FLAG,
             (SELECT CASE LENGTH(SUBSTR(TRIM(ENT_MOBILE_NO), 1, 20))
                       WHEN 11 THEN
                        DECODE(SUBSTR(SUBSTR(SUBSTR(TRIM(ENT_MOBILE_NO),
                                                    1,
                                                    20),
                                             -11),
                                      1,
                                      1),
                               '0',
                               91 ||
                               SUBSTR(SUBSTR(TRIM(ENT_MOBILE_NO), 1, 20), -10),
                               SUBSTR(TRIM(ENT_MOBILE_NO), 1, 20))
                       WHEN 10 THEN
                        '91' || SUBSTR(TRIM(ENT_MOBILE_NO), 1, 20)
                       ELSE
                        SUBSTR(TRIM(ENT_MOBILE_NO), 1, 20)
                     END CASE
                FROM DUAL),
             NVL2(ENT_DISCLOSURE_DT, 'Y', 'N'),
             BAM_BKM_CD,
             BAM_NO,
             BAM_TYPE,
             DECODE(ENT_STATUS, 'E', DECODE(BAM_STATUS, 'A', 'E', 'D'), 'D'),
             BAM_CUST_ID,
             MDI_DPM_ID,
             MDI_DP_ACC_NO,
             DECODE(ENT_STATUS,
                    'E',
                    DECODE(MDI_STATUS, 'A', 'E', 'N', 'E', 'D'),
                    'D'),
             MDI_ACC_TYPE,
             MDI_CUST_ID,
             ENT_CTG_DESC,
             ENT_EXCH_CLIENT_ID,
             ENT_INT_TRD_PRIV,
             ENT_SMS_ALERT_FL,
             ENT_NATIONALITY,
             ENT_TITLE,
             ENT_FIRST_NAME,
             ENT_MIDDLE_NAME,
             ENT_LAST_NAME,
             ENT_OCCUPATION,
             EAM.EQ_BRK_SCHEME,
             EAM.DR_BRK_SCHEME,
             ENT_BANK_CATEGORY,
             ENT_TRADE_CATEGORY,
             EPR.EPR_APPLN_NO,
             ENT_MOBILE_TRADING,
             ENT_FOS_PROFILE_ID,
             MDI_CL_APP2,
             MDI_CL_APP3,
             MDI_CL_PAN2,
             MDI_CL_PAN3,
             MDI_TAX_STATUS,
             ENT_SEX,
             ERD_GUARD_NAME,
             ERD_GUARDIAN_PAN,
             MDI_CL_NOMINEE,
             MDI_CL_NOMINEE_RL,
             MDI_CL_HOLDING,
             EMD_KYC_COMPLIANT,
             EMD_CL_DIV_PAYMODE,
             EMD_COMMUNICATION_MODE,
             BBM_ETF_CD,
             ENT_EUIN_NO,
             ECM_RISK_TYPE,
             ECM_RISK_TYPE_FL,
             ENT_PEP,
             ERD_ADH_NO,
             NVL(ENT_UID_VERIFIED_YN, 'N') ENT_UID_VERIFIED_YN,
             Erd_Margin_Fund_Mode,
             Erd_Margin_Fund_Date,
             ERD_MARGIN_FUND_FLAG,
           -- Nvl(Erd_Margin_Fund_Flag,'P'),
             Erd_Margin_Fund_User
    --  ERD_MARGIN_FUND_FLAG
        FROM ENTITY_MASTER E,
             ENTITY_REGISTRATION_DETAILS,
             ENTITY_PRE_REG EPR,
             ENTITY_COMPLIANCE_DTLS,
             (SELECT EAM_ENT_ID EAM_ID,
                     MAX(DECODE(EAM_SEG_ID, 'E', BRS_SCHEME_DETAILS)) EQ_BRK_SCHEME,
                     MAX(DECODE(EAM_SEG_ID, 'D', BRS_SCHEME_DETAILS)) DR_BRK_SCHEME
                FROM ENTITY_ATTRIBUTE_MASTER, BROKERAGE_SCHEMES
               WHERE EAM_BRK_SCH_ID = BRS_ID
               GROUP BY EAM_ENT_ID) EAM,
             (SELECT BANK_ACCOUNT_MASTER.*, BBM_ETF_CD
                FROM BANK_MASTER, BANK_BRANCH_MASTER, BANK_ACCOUNT_MASTER
               WHERE BKM_CD = BBM_BKM_CD
                 AND BBM_BKM_CD = BAM_BKM_CD
                 AND BBM_CD = BAM_BBM_CD
                 AND EXISTS
               (SELECT 1
                        FROM BANK_INTERFACE_MASTER
                       WHERE BAM_BKM_CD =
                             DECODE(L_HRT_CNT, 1, BIM_BKM_CD, BAM_BKM_CD)
                         AND BIM_STATUS =
                             DECODE(L_HRT_CNT, 1, 'A', BIM_STATUS))
                 AND BAM_DEF_BNK_IND = 'Y'),
             (SELECT *
                FROM MEMBER_DP_INFO
               WHERE EXISTS (SELECT 1
                        FROM DEPO_PARTICIPANT_MASTER
                       WHERE MDI_DPM_ID = DPM_ID
                         AND MDI_DPM_DEM_ID = DPM_DEM_ID
                         AND (MDI_DPM_ID =
                             DECODE(L_HRT_CNT, 1, 'TEST', MDI_DPM_ID) OR
                             DPM_AGENCY_CD IS NOT NULL))
                 AND MDI_DEFAULT_FLAG = 'Y'),
             ENTITY_MFSS_DETAILS,
             ENTITY_DMG_CHNG,
             ENTITY_PRIVILEGE_MAPPING P
       WHERE ENT_TYPE IN ('CL', 'DL', 'SB')
         AND ENT_ID = ERD_ENT_ID(+)
         AND ENT_ID = EPM_ENT_ID(+)
         AND ((ENT_UCC_SUCCESS_FLG = 'Y') OR
             (NVL(P.EPM_SEG_EQUITY, 'N') = 'N' AND
             NVL(P.EPM_SEG_EQUITY_BSE, 'N') = 'N' AND
             NVL(P.EPM_SEG_DERIVATIVES, 'N') = 'N' AND
             Nvl(p.epm_seg_mfss,'N')        = 'N' and
             Nvl(p.epm_Seg_mfss_bse,'N')    = 'N' and
             NVL(P.EPM_SEG_MFD, 'N') = 'Y'))
         AND ENT_ID = BAM_ENT_ID(+)
         AND ENT_ID = MDI_ID(+)
         AND ENT_ID = EAM.EAM_ID(+)
         AND ENT_ID = EPR.EPR_ENT_ID(+)
         AND ENT_ID = EMD_ENT_ID(+)
         AND ENT_ID = EDC_ENT_ID(+)
         AND ENT_ID = ECM_ENT_ID(+)
         AND ENT_MATRIX_UPLOAD = 'Y'
         AND ENT_TEMPLET_CLIENT = 'N'
         AND NVL(ENT_PROCESSING_TYPE, '@@') IN ('RCL', 'HNI', '@@')
         AND (ENT_CREAT_DT >= L_LAST_LOAD_TIME OR
             ENT_LAST_UPDT_DT >= L_LAST_LOAD_TIME OR
             ERD_CREAT_DT >= L_LAST_LOAD_TIME OR
             ERD_UPDATE_DT >= L_LAST_LOAD_TIME OR
             BAM_CREAT_DT >= L_LAST_LOAD_TIME OR
             BAM_LAST_UPDT_DT >= L_LAST_LOAD_TIME OR
             MDI_CREAT_DT >= L_LAST_LOAD_TIME OR
             MDI_LAST_UPDT_DT >= L_LAST_LOAD_TIME OR
             EDC_CREAT_DT > L_LAST_LOAD_TIME OR
             EDC_LAST_UPDT_DT >= L_LAST_LOAD_TIME)
       ORDER BY ENT_ID;

    --Cursor to get CP IDs from Base CP Master
    CURSOR C_CP_ID(L_ENTITY_ID IN VARCHAR2) IS
      SELECT CPS_SEG_ID, CPS_EXM_ID, DECODE(CPS_CPID, 'NA', NULL, CPS_CPID)
        FROM BASE_CP_MASTER
       WHERE CPS_ENT_ID = L_ENTITY_ID
         AND CPS_STATUS = 'A';

    CURSOR C_PROXY_DETAILS IS
      SELECT CLD_CLIENT_ID,
             CLD_ID,
             CLD_HLDR_NAME,
             CLD_HLDR_GEN,
             CLD_ADDRESS1,
             CLD_ADDRESS2,
             CLD_ADDRESS3,
             CLD_ADDRESS4,
             CLD_CITY,
             CLD_STATE,
             CLD_PIN_CD,
             CLD_PHONE_NO,
             CLD_MOBILE_NO,
             CLD_BIRTH_DATE,
             CLD_CLINT_REL,
             CLD_PAN_NO,
             CLD_TEXT1,
             CLD_TEXT2,
             CLD_TEXT3,
             CLD_STATUS,
             CLD_ACTIVATION_DATE,
             CLD_DEACTIVATION_DATE,
             CLD_COUNTRY,
             CLD_VERSION_NO
        FROM CLIENT_PROXY_DTLS T
       WHERE (CLD_CRTD_DATE >= L_LAST_LOAD_TIME OR
             CLD_LST_UPDT_DATE >= L_LAST_LOAD_TIME);

    PROCEDURE P_INITIALISE_VARIABLES IS
    BEGIN
      L_ENTITY_ID              := NULL;
      L_ENTITY_NAME            := NULL;
      L_ENTITY_TYPE            := NULL;
      L_ENTITY_CLIENT_TYPE     := NULL;
      L_ENT_CATEGORY           := NULL;
      L_ENTITY_STATUS          := NULL;
      L_ENTITY_CTRL_ID         := NULL;
      L_ENTITY_FAMILY_ID       := NULL;
      L_ENTITY_ADD_LINE_1      := NULL;
      L_ENTITY_ADD_LINE_2      := NULL;
      L_ENTITY_ADD_LINE_3      := NULL;
      L_ENTITY_ADD_LINE_4      := NULL;
      L_ENTITY_ADD_LINE_5      := NULL;
      L_ENTITY_PHNO_1          := NULL;
      L_ENTITY_PHNO_2          := NULL;
      L_ENTITY_FAXNO_1         := NULL;
      L_ENTITY_FAXNO_2         := NULL;
      L_ENT_EOD_REL_FLG        := NULL;
      L_ENT_INTERNET_PRIV      := NULL;
      L_ERD_PAN_NO             := NULL;
      L_ENTITY_EMAIL_ID        := NULL;
      L_ENT_CSC_ID             := NULL;
      L_ENT_PRIV               := NULL;
      L_ENTITY_LOGIN_ID        := NULL;
      L_ENT_SEC_REL_FL         := NULL;
      L_ENT_ORD_CONF_FL        := NULL;
      L_ENT_TRD_CONF_FL        := NULL;
      L_SEG_FL                 := NULL;
      L_ENT_MOBILE_NO          := NULL;
      L_BAM_BKM_CD             := NULL;
      L_BAM_ACC_NO             := NULL;
      L_BAM_ACC_TYPE           := NULL;
      L_BAM_STATUS             := NULL;
      L_BAM_CUST_ID            := NULL;
      L_MDI_DPM_ID             := NULL;
      L_DP_ACC_NO              := NULL;
      L_DP_ACC_STATUS          := NULL;
      L_MDI_ACC_TYPE           := NULL;
      L_MDI_CUST_ID            := NULL;
      L_MARGIN_CC_PRIV_FLAG    := 'N';
      L_PVM_SCM_ID             := NULL;
      L_CC_FLAG                := 0;
      L_M_OFF_FLAG             := 0;
      L_MO_FLAG                := 0;
      L_ENT_CTG_DESC           := NULL;
      L_ENT_CLIENT_TYPE        := NULL;
      L_ENT_EXCH_CLIENT_ID     := NULL;
      L_ENT_INT_TRD_PRIV       := NULL;
      L_ENT_SMS_ALERT_FL       := NULL;
      L_ENT_NATIONALITY        := NULL;
      L_ENT_TITLE              := NULL;
      L_ENT_FIRST_NAME         := NULL;
      L_ENT_MIDDLE_NAME        := NULL;
      L_ENT_LAST_NAME          := NULL;
      L_ENT_OCCUPATION         := NULL;
      L_EQ_BRK_SCHEME          := NULL;
      L_DR_BRK_SCHEME          := NULL;
      L_ENT_BANK_CATEGORY      := NULL;
      L_ENT_TRADE_CATEGORY     := NULL;
      L_EPR_APPLN_NO           := NULL;
      L_MOBILE_TRADING         := NULL;
      L_ENT_FOS_PROFILE_ID     := NULL; /*HSL3.5*/
      L_MDI_CL_APP2            := NULL;
      L_MDI_CL_APP3            := NULL;
      L_MDI_CL_PAN2            := NULL;
      L_MDI_CL_PAN3            := NULL;
      L_MDI_TAX_STATUS         := NULL;
      L_ENT_SEX                := NULL;
      L_ERD_GUARD_NAME         := NULL;
      L_ERD_GUARDIAN_PAN       := NULL;
      L_MDI_CL_NOMINEE         := NULL;
      L_MDI_CL_NOMINEE_RL      := NULL;
      L_MDI_CL_HOLDING         := NULL;
      L_EMD_KYC_COMPLIANT      := NULL;
      L_EMD_CL_DIV_PAYMODE     := NULL;
      L_EMD_COMMUNICATION_MODE := NULL;
      L_BBM_NEFT_CODE          := NULL;
      L_ENT_EUIN_NUMBER        := NULL;
      L_ERM_RISK_TYPE          := NULL;
      L_ECM_RISK_TYPE_FL       := NULL;
      L_ENT_PEP                := NULL;
      L_ENT_PEP_RELATED        := NULL;
      L_EPM_SEG_MFD            := NULL;
      L_ERD_ADH_NO             := NULL;
      L_ENT_UID_VERIFIED_YN    := 'N';
    L_ENT_RM_ID               :=NULL;
    L_ERD_CKYC_NO             :=NULL;
    L_MARGIN_FUND_FLAG        :='P';

    END P_INITIALISE_VARIABLES;
  BEGIN
    BEGIN

      L_FLAG := 0;
      L_STR  := ' Checking Parameters for running process ';
      SELECT COUNT(1)
        INTO L_HRT_CNT
        FROM APPLICATION_SETUP_MASTER
       WHERE ASM_UTIL_ID = 'FHRT'
         AND ASM_SEG_ID = 'E'
         AND ASM_EXM_ID = 'ALL'
         AND ASM_UTIL_STATUS = 'A';

      L_STR := ' Starting and initialising process ';
      STD_LIB.P_HOUSEKEEPING(L_PRG_ID,
                             'ALL',
                             'ALL',
                             'B',
                             L_FILE_HANDLE,
                             L_FILE_NAME,
                             L_PRG_PROCESS_ID);

      L_CURR_DATE := STD_LIB.L_PAM_CURR_DATE;

      STD_LIB.P_INSERT_UPS_CONTROL(L_CURR_DATE,
                                   'ALL',
                                   NULL,
                                   NULL,
                                   'R',
                                   L_PRG_ID,
                                   L_PRG_PROCESS_ID,
                                   NULL,
                                   NULL);

      L_STR := ' Getting Front Office data for Controlling Id for Branch ';
      SELECT RV_LOW_VALUE
        INTO L_MTS_COMPANY_ID
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'MTS_COMPANY_ID';

      -- This is used to pick up only those clients which were entered/modified after this time.
      L_STR := ' Getting time when process for client upload to front office was last run ';
      SELECT NVL(MAX(PRG_STRT_TIME), L_FIRST_LOAD_TIME)
        INTO L_LAST_LOAD_TIME
        FROM PROGRAM_STATUS
       WHERE PRG_CMP_ID = L_PRG_ID
         AND PRG_STATUS = 'C';

      SELECT RV_HIGH_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'DATA_FILES'
         AND RV_LOW_VALUE = 'CSS_FILES';

      SELECT COUNT(*) + 1
        INTO L_BATCH_NO
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID
         AND PRG_STATUS_FILE LIKE '%ENT_%';

      SELECT ASM_UTIL_STATUS
        INTO L_SEBI_STATUS
        FROM APPLICATION_SETUP_MASTER
       WHERE ASM_UTIL_ID = 'CSBPMU'
         AND ASM_PRG_ID = 'CSSBSBEM';

      IF L_SEBI_STATUS = 'A' THEN
        L_STR := ' Loading Process SEBI Banned Entity ';

        P_LOAD_SEBI_BANNED_ENTITY(O_STATUS, O_LOG_FILE);

        IF O_STATUS <> 'SUCCESS' THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'SEBI Banned Entity Process was unsuccessfull. ' ||
                            'Refer Component Name CSSBSBEM on Process Monitor Screen for more details.');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Log File for SEBI Banned Entity Process: ' ||
                            O_LOG_FILE);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
          RAISE E_BANNED_ENTITY_ERROR;
        ELSE
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'SEBI Banned Entity Process was completed successfully. ' ||
                            'Refer Component Name CSSBSBEM on Process Monitor Screen for more details.');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Log File for SEBI Banned Entity Process: ' ||
                            O_LOG_FILE);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END IF;
      END IF;

      L_STR := ' Getting Front Office data for mapping of privileges ';
      FOR I IN (SELECT MIM_SERIAL_NO,
                       MIM_SEGMENT,
                       MIM_SUBSEGMENT,
                       MIM_INSTRUMENT_ID,
                       MIM_INSTRUMENT_NAME,
                       MIM_EXCH_ID,
                       MIM_PRCSN_SEG_ID,
                       MIM_PRCSN_ISG_TYPE,
                       MIM_PRCSN_EXM_ID,
                       MIM_PRCSN_ITR_ID
                  FROM MTS_INSTR_SEG_EXCH_MAP) LOOP
        -- This is taken in Loop because Single Insert Select across DB may create performance problem
        INSERT INTO TEMP_MTS_INSTR_SEG_EXCH_MAP
          (MIM_SERIAL_NO,
           MIM_SEGMENT,
           MIM_SUBSEGMENT,
           MIM_INSTRUMENT_ID,
           MIM_INSTRUMENT_NAME,
           MIM_EXCH_ID,
           MIM_PRCSN_SEG_ID,
           MIM_PRCSN_ISG_TYPE,
           MIM_PRCSN_EXM_ID,
           MIM_PRCSN_ITR_ID)
        VALUES
          (I.MIM_SERIAL_NO,
           I.MIM_SEGMENT,
           I.MIM_SUBSEGMENT,
           I.MIM_INSTRUMENT_ID,
           I.MIM_INSTRUMENT_NAME,
           I.MIM_EXCH_ID,
           I.MIM_PRCSN_SEG_ID,
           I.MIM_PRCSN_ISG_TYPE,
           I.MIM_PRCSN_EXM_ID,
           I.MIM_PRCSN_ITR_ID);
      END LOOP;

      IF LENGTH(L_BATCH_NO) = 1 THEN
        L_BATCH_NO := '0' || L_BATCH_NO;
      ELSE
        L_BATCH_NO := L_BATCH_NO;
      END IF;

      --l_Data_File_Name   := 'ENT_' || To_Char(l_Curr_Date,'DDMONYYYY') || '_' || l_Batch_No ||'.TXT';
      --l_Data_File_Handle := Utl_File.Fopen(l_Log_Env,l_Data_File_Name,'W');

      L_STR := ' Preparing list of clients to be loaded ';
      OPEN C_ENTITY;
      LOOP
        BEGIN
          P_INITIALISE_VARIABLES;
          L_STR := ' Getting details of next client after client ' ||
                   L_ENTITY_ID;
          FETCH C_ENTITY
            INTO L_ENTITY_ID,
                 L_ENTITY_NAME,
                 L_ENTITY_TYPE,
                 L_ENTITY_CLIENT_TYPE,
                 L_ENT_CATEGORY,
                 L_ENTITY_STATUS,
                 L_ENTITY_CTRL_ID,
                 L_ENTITY_FAMILY_ID,
                 L_ENT_DOB,
                 L_ENTITY_ADD_LINE_1,
                 L_ENTITY_ADD_LINE_2,
                 L_ENTITY_ADD_LINE_3,
                 L_ENTITY_ADD_LINE_4,
                 L_ENTITY_ADD_LINE_5,
                 L_ENTITY_ADD_LINE_6,
                 L_ENTITY_ADD_LINE_7,
                 L_ENTITY_PHNO_1,
                 L_ENTITY_PHNO_2,
                 L_ENTITY_FAXNO_1,
                 L_ENTITY_FAXNO_2,
                 L_ENT_EOD_REL_FLG,
                 L_ENT_INTERNET_PRIV,
                 L_ERD_PAN_NO,
                 L_ENT_CSC_ID,
                 L_ENTITY_LOGIN_ID,
                 L_ENT_SEC_REL_FL,
                 L_ENT_ORD_CONF_FL,
                 L_ENT_TRD_CONF_FL,
                 L_SEG_FL,
                 L_ENT_MOBILE_NO,
                 L_ENT_DISCLOSURE_FLAG,
                 L_BAM_BKM_CD,
                 L_BAM_ACC_NO,
                 L_BAM_ACC_TYPE,
                 L_BAM_STATUS,
                 L_BAM_CUST_ID,
                 L_MDI_DPM_ID,
                 L_DP_ACC_NO,
                 L_DP_ACC_STATUS,
                 L_MDI_ACC_TYPE,
                 L_MDI_CUST_ID,
                 L_ENT_CTG_DESC,
                 L_ENT_EXCH_CLIENT_ID,
                 L_ENT_INT_TRD_PRIV,
                 L_ENT_SMS_ALERT_FL,
                 L_ENT_NATIONALITY,
                 L_ENT_TITLE,
                 L_ENT_FIRST_NAME,
                 L_ENT_MIDDLE_NAME,
                 L_ENT_LAST_NAME,
                 L_ENT_OCCUPATION,
                 L_EQ_BRK_SCHEME,
                 L_DR_BRK_SCHEME,
                 L_ENT_BANK_CATEGORY,
                 L_ENT_TRADE_CATEGORY,
                 L_EPR_APPLN_NO,
                 L_MOBILE_TRADING,
                 L_ENT_FOS_PROFILE_ID,
                 L_MDI_CL_APP2,
                 L_MDI_CL_APP3,
                 L_MDI_CL_PAN2,
                 L_MDI_CL_PAN3,
                 L_MDI_TAX_STATUS,
                 L_ENT_SEX,
                 L_ERD_GUARD_NAME,
                 L_ERD_GUARDIAN_PAN,
                 L_MDI_CL_NOMINEE,
                 L_MDI_CL_NOMINEE_RL,
                 L_MDI_CL_HOLDING,
                 L_EMD_KYC_COMPLIANT,
                 L_EMD_CL_DIV_PAYMODE,
                 L_EMD_COMMUNICATION_MODE,
                 L_BBM_NEFT_CODE /*HSL3.5*/,
                 L_ENT_EUIN_NUMBER,
                 L_ERM_RISK_TYPE,
                 L_ECM_RISK_TYPE_FL,
                 L_ENT_PEP,
                 L_ERD_ADH_NO,
                 L_ENT_UID_VERIFIED_YN,
                 l_Margin_Fund_Mode,
                 l_Margin_Fund_Date,
                 l_Margin_Fund_Flag,
                 l_Margin_Fund_User;

          EXIT WHEN C_ENTITY%NOTFOUND;

          IF L_ENT_CTG_DESC = 11 THEN
            SELECT MIN(ENT_ID) -- Upload First created client id only
              INTO L_CHECK_ENT_ID
              FROM ENTITY_MASTER A
             WHERE ENT_EXCH_CLIENT_ID = L_ENT_EXCH_CLIENT_ID
               AND ENT_MATRIX_UPLOAD = 'Y'
               AND ENT_CREAT_DT =
                   (SELECT MIN(ENT_CREAT_DT)
                      FROM ENTITY_MASTER
                     WHERE ENT_EXCH_CLIENT_ID = L_ENT_EXCH_CLIENT_ID
                       AND ENT_MATRIX_UPLOAD = 'Y');

            IF L_CHECK_ENT_ID != L_ENTITY_ID THEN
              RAISE DONT_SEND;
            END IF;
          END IF;

          IF L_ENTITY_TYPE IN ('CL', 'DL', 'SB') THEN

            L_STR := ' Getting privilege data for client ' || L_ENTITY_ID;
            SELECT NVL(EPM_SEG_EQUITY, 'N'),
                   NVL(EPM_SEG_DERIVATIVES, 'N'),
                   NVL(EPM_SEG_CF, 'N'),
                   EPM_SEG_SLB,
                   EPM_SEG_COMMODITIES,
                   NVL(EPM_SEG_MFSS, 'N'),
                   EPM_CHANNEL_INTERNET,
                   EPM_CHANNEL_CALL_N_TRADE,
                   EPM_CHANNEL_TWS,
                   EPM_CHANNEL_IVRS,
                   EPM_CHANNEL_MOBILE,
                   NVL(EPM_PRODUCT_CC, 'N'),
                   NVL(EPM_PRODUCT_MARGIN_ONLINE, 'N'),
                   NVL(EPM_PRODUCT_MARGIN_OFFLINE, 'N'),
                   EPM_PRODUCT_BTST,
                   NVL(EPM_PRODUCT_SPOT, 'N'),
                   NVL(EPM_PRODUCT_SIP, 'N'),
                   EPM_PRODUCT_SPOT_CAP,
                   NVL(EPM_PRODUCT_MARGIN_PLUS, 'N'),
                   EPM_PRODUCT_T5,
                   NVL(EPM_PRODUCT_MLB, 'N'),
                   EPM_PRODUCT_MLB_CAP,
                   NVL(EPM_PRODUCT_T2, 'N'),
                   EPM_PRODUCT_T2_CAP,
                   EPM_SMS_TRADE_CONFIRM,
                   EPM_SMS_MRG_VOILATION,
                   EPM_EMAIL_CONTRACT_NOTE,
                   EPM_EMAIL_CLIENT_LEDGER,
                   NVL(EPM_PRODUCT_COLLATERAL_SELL, 'N'),
                   EPM_SEG_EQUITY_BSE,
                   EPM_SEG_DERIVATIVES_BSE,
                   NVL(EPM_SEG_CF_BSE, 'N'),
                   EPM_SEG_SLB_BSE,
                   EPM_SEG_COMMODITIES_BSE,
                   NVL(EPM_SEG_MFSS_BSE, 'N'),
                   EPM_SEG_CF_MCX,
                   EPM_SEG_COMMODITIES_MCX,
                   NVL(EPM_SEG_MFD, 'N')
              INTO L_EPM_SEG_EQUITY,
                   L_EPM_SEG_DERIVATIVES,
                   L_EPM_SEG_CF,
                   L_EPM_SEG_SLB,
                   L_EPM_SEG_COMMODITIES,
                   L_EPM_SEG_MFSS,
                   L_EPM_CHANNEL_INTERNET,
                   L_EPM_CHANNEL_CALL_N_TRADE,
                   L_EPM_CHANNEL_TWS,
                   L_EPM_CHANNEL_IVRS,
                   L_EPM_CHANNEL_MOBILE,
                   L_EPM_PRODUCT_CC,
                   L_EPM_PRODUCT_MARGIN_ONLINE,
                   L_EPM_PRODUCT_MARGIN_OFFLINE,
                   L_EPM_PRODUCT_BTST,
                   L_EPM_PRODUCT_SPOT,
                   L_EPM_PRODUCT_SIP,
                   L_EPM_PRODUCT_SPOT_CAP,
                   L_EPM_PRODUCT_MARGIN_PLUS,
                   L_EPM_PRODUCT_T5,
                   L_EPM_PRODUCT_MLB,
                   L_EPM_PRODUCT_MLB_CAP,
                   L_EPM_PRODUCT_T2,
                   L_EPM_PRODUCT_T2_CAP,
                   L_EPM_SMS_TRADE_CONFIRM,
                   L_EPM_SMS_MRG_VOILATION,
                   L_EPM_EMAIL_CONTRACT_NOTE,
                   L_EPM_EMAIL_CLIENT_LEDGER,
                   L_EPM_PRODUCT_COLLATERAL_SELL,
                   L_EPM_SEG_EQUITY_BSE,
                   L_EPM_SEG_DERIVATIVES_BSE,
                   L_EPM_SEG_CF_BSE,
                   L_EPM_SEG_SLB_BSE,
                   L_EPM_SEG_COMMODITIES_BSE,
                   L_EPM_SEG_MFSS_BSE,
                   L_EPM_SEG_CF_MCX,
                   L_EPM_SEG_COMMODITIES_MCX,
                   L_EPM_SEG_MFD
              FROM ENTITY_PRIVILEGE_MAPPING
             WHERE EPM_ENT_ID = L_ENTITY_ID;

            L_ENT_PRIV          := NULL;
            L_PRODUCT_PRIV_FLAG := NULL;

            L_STR := ' Getting front office specific privilege data for client ' ||
                     L_ENTITY_ID;

            -- Privilege String is taken from Mts_Instr_Seg_Exch_Map. It is concat of
            -- 1. NSE  Future Index
            -- 2. BSE  Equity
            -- 3. NSE  Future Stock
            -- 4. NSE  Equity
            -- 5. NSE  Option Index
            -- 6. NSE  Option Stock
            -- 7. NSE  MFSS
            -- 8. BSE  MFSS
            -- 9. BSE  Future Index
            --10. BSE  Future Stock
            --11. BSE  Option Index
            --12. BSE  Option Stock
            -- 13. NSE  Future Index
            --14. NSE  Currency
            --15. NSE  Currency

            L_ENT_PRIV := L_EPM_SEG_DERIVATIVES || L_EPM_SEG_EQUITY_BSE ||
                          L_EPM_SEG_DERIVATIVES || L_EPM_SEG_EQUITY ||
                          L_EPM_SEG_DERIVATIVES || L_EPM_SEG_DERIVATIVES ||
                          L_EPM_SEG_MFSS || L_EPM_SEG_MFSS_BSE ||
                          L_EPM_SEG_DERIVATIVES_BSE ||
                          L_EPM_SEG_DERIVATIVES_BSE ||
                          L_EPM_SEG_DERIVATIVES_BSE ||
                          L_EPM_SEG_DERIVATIVES_BSE ||
                          L_EPM_SEG_DERIVATIVES || L_EPM_SEG_CF ||
                          L_EPM_SEG_CF;

          END IF;

          L_STR := ' Getting Mail id for client ' || L_ENTITY_ID;
          BEGIN
            SELECT SUBSTR(END_EMAIL_ID, 1, 50)
              INTO L_ENTITY_EMAIL_ID
              FROM ENTITY_DETAILS
             WHERE END_ID = L_ENTITY_ID
               AND END_STATUS = 'A'
               AND END_DEFAULT_FLAG = 'Y'
               AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT SUBSTR(END_EMAIL_ID, 1, 50)
                  INTO L_ENTITY_EMAIL_ID
                  FROM ENTITY_DETAILS
                 WHERE END_ID = L_ENTITY_ID
                   AND END_STATUS = 'A'
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  L_ENTITY_EMAIL_ID := NULL;
              END;
          END;

          L_NSE_EQ_CP_ID := NULL;
          L_NSE_DR_CP_ID := NULL;
          L_NSE_CR_CP_ID := NULL;
          L_BSE_EQ_CP_ID := NULL;
          L_BSE_DR_CP_ID := NULL;
          L_BSE_CR_CP_ID := NULL;

          IF L_ENT_CATEGORY IN ('FI', 'NRI') THEN
            L_STR := ' Getting List of CP for client ' || L_ENTITY_ID;

            IF L_ENT_CATEGORY = 'NRI' THEN
              SELECT MAX(ENT_ID)
                INTO L_ENTITY_ID
                FROM ENTITY_MASTER
               WHERE ENT_EXCH_CLIENT_ID = L_ENT_EXCH_CLIENT_ID
                 AND ENT_NRI_SETTLEMENT_TYPE = 'NRO-NONPIS';
            END IF;

            OPEN C_CP_ID(L_ENTITY_ID);
            LOOP
              BEGIN
                L_STR := ' Getting details of CP for client ' ||
                         L_ENTITY_ID;
                FETCH C_CP_ID
                  INTO L_CPS_SEG_ID, L_CPS_EXM_ID, L_CPS_CPID;
                EXIT WHEN C_CP_ID%NOTFOUND;

                IF L_CPS_SEG_ID = 'E' AND L_CPS_EXM_ID = 'NSE' THEN
                  L_NSE_EQ_CP_ID := L_CPS_CPID;
                END IF;

                IF L_CPS_SEG_ID = 'D' AND L_CPS_EXM_ID = 'NSE' THEN
                  L_NSE_DR_CP_ID := L_CPS_CPID;
                END IF;

                IF L_CPS_SEG_ID = 'C' AND L_CPS_EXM_ID = 'NSE' THEN
                  L_NSE_CR_CP_ID := L_CPS_CPID;
                END IF;

                IF L_CPS_SEG_ID = 'E' AND L_CPS_EXM_ID = 'BSE' THEN
                  L_BSE_EQ_CP_ID := L_CPS_CPID;
                END IF;

                IF L_CPS_SEG_ID = 'D' AND L_CPS_EXM_ID = 'BSE' THEN
                  L_BSE_DR_CP_ID := L_CPS_CPID;
                END IF;

                IF L_CPS_SEG_ID = 'C' AND L_CPS_EXM_ID = 'BSE' THEN
                  L_BSE_CR_CP_ID := L_CPS_CPID;
                END IF;

              END;
            END LOOP;
            CLOSE C_CP_ID;
          END IF;

          IF L_ENTITY_TYPE = 'SB' THEN
            L_ENTITY_CTRL_ID := L_MTS_COMPANY_ID;
          END IF;

          IF L_ENTITY_TYPE = 'CL' THEN
            IF NVL(L_ENT_CTG_DESC, '01') = '11' THEN
              L_ENT_CLIENT_TYPE := 'NR';
            ELSIF NVL(L_ENT_CATEGORY, 'RCL') = 'FI' THEN
              L_ENT_CLIENT_TYPE := 'FI';
            ELSIF NVL(L_EPM_CHANNEL_INTERNET, 'N') = 'Y' THEN
              IF NVL(L_EPM_PRODUCT_MARGIN_ONLINE, 'N') = 'Y' OR
                 NVL(L_EPM_PRODUCT_MARGIN_OFFLINE, 'N') = 'Y' THEN
                L_ENT_CLIENT_TYPE := 'IC';
              ELSE
                L_ENT_CLIENT_TYPE := 'FC';
              END IF;
            ELSE
              L_ENT_CLIENT_TYPE := 'NC';
            END IF;

            L_ENT_EOD_REL_FLG := 'Y';
            L_ENT_SEC_REL_FL  := 'Y';

            IF L_EPM_SMS_TRADE_CONFIRM = 'Y' OR
               L_EPM_SMS_MRG_VOILATION = 'Y' THEN
              L_ENT_SMS_ALERT_FL := 'Y';
            END IF;

            -- Product Flog is concatenation of
            -- 1) Margin                  2)  CnC                    3) Intraday
            -- 4) Cover                   5)  Collateral sell        6) Spot
            -- 7) E-Margin                8)  MLB                    9) PMS
            -- 10)SIP Fund

            L_PRODUCT_PRIV_FLAG := L_EPM_PRODUCT_MARGIN_OFFLINE ||
                                   L_EPM_PRODUCT_CC ||
                                   L_EPM_PRODUCT_MARGIN_ONLINE;
            L_PRODUCT_PRIV_FLAG := L_PRODUCT_PRIV_FLAG ||
                                   L_EPM_PRODUCT_MARGIN_PLUS ||
                                   L_EPM_PRODUCT_COLLATERAL_SELL ||
                                   L_EPM_PRODUCT_SPOT;
            L_PRODUCT_PRIV_FLAG := L_PRODUCT_PRIV_FLAG || L_EPM_PRODUCT_T2 ||
                                   L_EPM_PRODUCT_MLB || 'N' ||
                                   L_EPM_PRODUCT_SIP;
          END IF;

          IF L_ENT_CTG_DESC = 11 THEN
            L_ENTITY_ID := L_ENT_EXCH_CLIENT_ID;
          END IF;

          L_STR := ' Processing Demographic Changes for Client Id : ' ||
                   L_ENTITY_ID;

          BEGIN
            SELECT EDC_ENTITY_DMG_FLAG
              INTO L_DMG_STATUS
              FROM ENTITY_DMG_CHNG
             WHERE EDC_ENT_ID = L_ENTITY_ID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                INSERT INTO ENTITY_DMG_CHNG
                  (EDC_ENT_ID,
                   EDC_REPORT_ID,
                   EDC_ENTITY_DMG_FLAG,
                   EDC_APPLICATION_ID,
                   EDC_APPLICATION_USER_ID,
                   EDC_CREAT_DT,
                   EDC_CREAT_BY,
                   EDC_LAST_UPDT_DT,
                   EDC_LAST_UPDT_BY)
                VALUES
                  (L_ENTITY_ID,
                   L_PRG_ID,
                   L_DMG_DEFAULT_VAL,
                   NULL,
                   NULL,
                   SYSDATE,
                   USER,
                   NULL,
                   NULL);
                L_DMG_STATUS := L_DMG_DEFAULT_VAL;
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  NULL; /* NULL to continue with the process and avoid exception handling in outer loop */
              END;
          END;
          ----changes done to push risk type to front office
          L_STR := ' Getting risk type for client ' || L_ENTITY_ID;
          IF NVL(L_ECM_RISK_TYPE_FL, 'N') <> 'Y' THEN
            IF L_ENT_CTG_DESC = '01' AND NVL(L_ENT_PEP, 'N') = 'N' AND
               NVL(L_ENT_PEP_RELATED, 'N') = 'N' AND
               L_ENTITY_ID IS NOT NULL THEN
              BEGIN
                SELECT ERM_RISK_TYPE
                  INTO L_ERM_RISK_TYPE
                  FROM ENTITY_RISK_MAPPING
                 WHERE ERM_RISK_DOMAIN = 'I'
                   AND ERM_RISK_CATEGORY = L_ENT_OCCUPATION;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  L_ERM_RISK_TYPE := NULL;
              END;
            END IF;

            IF L_ENT_CTG_DESC <> '01' AND NVL(L_ENT_PEP, 'N') = 'N' AND
               NVL(L_ENT_PEP_RELATED, 'N') = 'N' AND
               L_ENTITY_ID IS NOT NULL THEN
              BEGIN
                SELECT ERM_RISK_TYPE
                  INTO L_ERM_RISK_TYPE
                  FROM ENTITY_RISK_MAPPING
                 WHERE ERM_RISK_DOMAIN = 'N'
                   AND ERM_RISK_CATEGORY = L_ENT_CTG_DESC;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  L_ERM_RISK_TYPE := NULL;
              END;
            END IF;

            IF NVL(L_ENT_PEP, 'N') = 'Y' OR
               NVL(L_ENT_PEP_RELATED, 'N') = 'Y' THEN
              L_ERM_RISK_TYPE := 'CSC';
            END IF;
          END IF;
          IF L_ENTITY_TYPE <> 'CL' AND L_ERM_RISK_TYPE IS NULL THEN
            L_ERM_RISK_TYPE := 'L';
          END IF;
          -----
          L_STR := ' Updating data in Front Office for client ' ||
                   L_ENTITY_ID;
          UPDATE BOS_ENTITY_MASTER
             SET BEM_ENTITY_ID             = L_ENTITY_ID,
                 BEM_NAME                  = L_ENTITY_NAME,
                 BEM_ENTITY_TYPE           = L_ENTITY_TYPE,
                 BEM_CLIENT_TYPE           = L_ENT_CLIENT_TYPE,
                 BEM_STATUS                = L_ENTITY_STATUS,
                 BEM_CONTROLLER_ID         = L_ENTITY_CTRL_ID,
                 BEM_FAMILY_ID             = L_ENT_EXCH_CLIENT_ID,
                 BEM_DOB                   = L_ENT_DOB,
                 BEM_ADDRESS_LINE_1        = L_ENTITY_ADD_LINE_1,
                 BEM_ADDRESS_LINE_2        = L_ENTITY_ADD_LINE_2,
                 BEM_ADDRESS_LINE_3        = L_ENTITY_ADD_LINE_3,
                 BEM_ADDRESS_LINE_4        = L_ENTITY_ADD_LINE_4,
                 BEM_ADDRESS_LINE_5        = L_ENTITY_ADD_LINE_5,
                 BEM_ADDRESS_LINE_6        = L_ENTITY_ADD_LINE_6,
                 BEM_ADDRESS_LINE_7        = L_ENTITY_ADD_LINE_7,
                 BEM_PHONE_NO_1            = L_ENTITY_PHNO_1,
                 BEM_PHONE_NO_2            = L_ENTITY_PHNO_2,
                 BEM_FAX_NO_1              = L_ENTITY_FAXNO_1,
                 BEM_FAX_NO_2              = L_ENTITY_FAXNO_2,
                 BEM_EOD_EQU_FUND_REL_FLAG = L_ENT_EOD_REL_FLG,
                 BEM_EOD_DRV_FUND_REL_FLAG = L_ENT_EOD_REL_FLG,
                 BEM_INTERNET_PRIV         = L_ENT_INTERNET_PRIV,
                 BEM_PAN_NO                = DECODE(L_ENTITY_ADD_LINE_5,
                                                    'SIKKIM',
                                                    NVL(L_ERD_PAN_NO,
                                                        'PAN_EXEMPT'),
                                                    L_ERD_PAN_NO),
                 BEM_EMAIL_ID              = L_ENTITY_EMAIL_ID,
                 BEM_BANK_ACCOUNT_NO       = L_BAM_ACC_NO,
                 BEM_BANK_ACCOUNT_TYPE     = L_BAM_ACC_TYPE,
                 BEM_BANK_CUSTOMER_ID      = L_BAM_CUST_ID,
                 BEM_DP_ACCOUNT_NO         = SUBSTR(L_DP_ACC_NO, -8),
                 BEM_DP_ACCOUNT_STATUS     = L_DP_ACC_STATUS,
                 BEM_LOGIN_ID              = L_ENTITY_LOGIN_ID,
                 BEM_INSTRUMENT_PRIVILEGE  = L_ENT_PRIV,
                 BEM_ENTITY_INFO           = 'E',
                 BEM_ACTION_FLG            = 'N',
                 BEM_EOD_SEC_REL_FLAG      = L_ENT_SEC_REL_FL,
                 BEM_EQ_ALLOWED            = L_EPM_SEG_EQUITY,
                 BEM_DRV_ALLOWED           = L_EPM_SEG_DERIVATIVES,
                 BEM_MOBILE_NUMBER         = L_ENT_MOBILE_NO,
                 BEM_BANK_CODE             = L_BAM_BKM_CD,
                 BEM_BANK_ACCOUNT_STATUS   = L_BAM_STATUS,
                 BEM_DP_CODE               = L_MDI_DPM_ID,
                 BEM_DP_ACCOUNT_TYPE       = L_MDI_ACC_TYPE,
                 BEM_DP_CUSTOMER_ID        = L_MDI_CUST_ID,
                 BEM_RDA_FLAG              = L_ENT_DISCLOSURE_FLAG,
                 BED_EMAIL_FREQUENCY       = DECODE(L_ENT_ORD_CONF_FL,
                                                    'E',
                                                    'C',
                                                    'I',
                                                    'E',
                                                    'N'),
                 BED_CLIENT_SUB_CATEG      = TO_NUMBER(L_ENT_CTG_DESC),
                 BEM_DEF_NSE_CUST          = L_NSE_EQ_CP_ID,
                 BEM_NSE_DRV_DEF_CUST      = L_NSE_DR_CP_ID,
                 BEM_NSE_CDX_DEF_CUST      = L_NSE_CR_CP_ID,
                 BEM_DEF_BSE_CUST          = L_BSE_EQ_CP_ID,
                 BEM_BSE_DRV_DEF_CUST      = L_BSE_DR_CP_ID,
                 BEM_BSE_CDX_DEF_CUST      = L_BSE_CR_CP_ID,
                 BEM_ACC_TYPE              = 'N',
                 BEM_EXCH_CLIENT_ID        = L_ENT_EXCH_CLIENT_ID,
                 BEM_SMS_ALERT_FLAG        = L_ENT_SMS_ALERT_FL,
                 BEM_PRODUCT_PRIV_FLAG     = L_PRODUCT_PRIV_FLAG,
                 BEM_SPOT_MAX_LIMIT        = DECODE(L_EPM_PRODUCT_CC,
                                                    'Y',
                                                    NVL(L_EPM_PRODUCT_SPOT_CAP,
                                                        0),
                                                    0),
                 BEM_T2_MAX_LIMIT          = DECODE(L_EPM_PRODUCT_T2,
                                                    'Y',
                                                    NVL(L_EPM_PRODUCT_T2_CAP,
                                                        0),
                                                    0),
                 BEM_DMG_FLAG              = L_DMG_STATUS,
                 BEM_MOBILE_ALLOWED        = L_MOBILE_TRADING,
                 BEM_PROFILE_ID            = L_ENT_FOS_PROFILE_ID,
                 BEM_SECOND_CLIENT_NAME    = L_MDI_CL_APP2,
                 BEM_THIRD_CLIENT_NAME     = L_MDI_CL_APP3,
                 BEM_SECOND_CLIENT_PAN     = L_MDI_CL_PAN2,
                 BEM_THIRD_CLIENT_PAN      = L_MDI_CL_PAN3,
                 BEM_KYC_COMPLIANT         = L_EMD_KYC_COMPLIANT,
                 BEM_TAX_STATUS            = L_MDI_TAX_STATUS,
                 BEM_GENDER                = L_ENT_SEX,
                 BEM_GUARDIAN_NAME         = L_ERD_GUARD_NAME,
                 BEM_GUARDIAN_PANNO        = L_ERD_GUARDIAN_PAN,
                 BEM_NOMINEE_NAME          = L_MDI_CL_NOMINEE,
                 BEM_NOMINEE_RELATION      = L_MDI_CL_NOMINEE_RL,
                 BEM_MODEOFHOLDING         = L_MDI_CL_HOLDING,
                 BEM_STMTCOMMUNICATIONMODE = L_EMD_COMMUNICATION_MODE,
                 BEM_PAYOUTMECHANISM       = L_EMD_CL_DIV_PAYMODE,
                 BEM_NEFT_CODE             = L_BBM_NEFT_CODE,
                 BEM_EUIN_NUMBER           = L_ENT_EUIN_NUMBER,
                 BEM_BOS_CLIENT_RISK_CATEG = NVL(L_ERM_RISK_TYPE, 'L'),
                 BEM_OCCUPATION            = DECODE(L_ENT_OCCUPATION,
                                                    'Business',
                                                    '1',
                                                    'Services',
                                                    '2',
                                                    'Professional',
                                                    '3',
                                                    'Agriculture',
                                                    '4',
                                                    'Retired',
                                                    '5',
                                                    'Housewife',
                                                    '6',
                                                    'Student',
                                                    '7',
                                                    'Others',
                                                    '8',
                                                    '8'),
                 BEM_MRG_PRIV              = L_EPM_SEG_MFD,
                 BEM_AADHAAR_NO            = L_ERD_ADH_NO,
                 BEM_AADHAAR_VERIFIED      = L_ENT_UID_VERIFIED_YN,
                 BEM_EMAR_ACCEPT_FLG            = l_Margin_Fund_Flag,
                 BEM_EMAR_ACCEPT_SOURCE         = l_Margin_Fund_Mode,
                 BEM_EMAR_ACCEPT_USER           = l_Margin_Fund_User,
                 BEM_EMAR_ACCEPT_DATE           = l_Margin_Fund_Date
        ,BEM_ADV_PORTFOLIO_FLG             = L_EPM_ADV_PORTFOLIO
            -- ,BEM_EMAR_ACCEPT_FLG               = L_MARGIN_FUND_FLAG
             --,BEM_EMAR_ACCEPT_SOURCE            = L_MARGIN_FUND_MODE
             --,BEM_EMAR_ACCEPT_USER              = L_MARGIN_FUND_USER
         --    ,BEM_EMAR_ACCEPT_DATE              = L_MARGIN_FUND_DATE
             ,BEM_SIP_RELN_MNGR                 = L_ENT_RM_ID
             ,BEM_SELF_LOGIN_ALLOWED            = 'N'
             ,BEM_CKYC_NO                        = L_ERD_CKYC_NO
           WHERE BEM_ENTITY_ID = L_ENTITY_ID;

          IF SQL%FOUND THEN
            L_UPDT := L_UPDT + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Client Id Updated in MTS : ' || L_ENTITY_ID);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := ' Inserting new client data in Front Office for client ' ||
                     L_ENTITY_ID;
            INSERT INTO BOS_ENTITY_MASTER
              (BEM_ENTITY_ID,
               BEM_NAME,
               BEM_ENTITY_TYPE,
               BEM_CLIENT_TYPE,
               BEM_STATUS,
               BEM_CONTROLLER_ID,
               BEM_FAMILY_ID,
               BEM_DOB,
               BEM_ADDRESS_LINE_1,
               BEM_ADDRESS_LINE_2,
               BEM_ADDRESS_LINE_3,
               BEM_ADDRESS_LINE_4,
               BEM_ADDRESS_LINE_5,
               BEM_ADDRESS_LINE_6,
               BEM_ADDRESS_LINE_7,
               BEM_PHONE_NO_1,
               BEM_PHONE_NO_2,
               BEM_FAX_NO_1,
               BEM_FAX_NO_2,
               BEM_EOD_EQU_FUND_REL_FLAG,
               BEM_EOD_DRV_FUND_REL_FLAG,
               BEM_INTERNET_PRIV,
               BEM_PAN_NO,
               BEM_EMAIL_ID,
               BEM_BANK_ACCOUNT_NO,
               BEM_BANK_ACCOUNT_TYPE,
               BEM_BANK_CUSTOMER_ID,
               BEM_DP_ACCOUNT_NO,
               BEM_DP_ACCOUNT_STATUS,
               BEM_LOGIN_ID,
               BEM_INSTRUMENT_PRIVILEGE,
               BEM_ENTITY_INFO,
               BEM_EOD_SEC_REL_FLAG,
               BEM_EQ_ALLOWED,
               BEM_DRV_ALLOWED,
               BEM_MOBILE_NUMBER,
               BEM_BANK_CODE,
               BEM_BANK_ACCOUNT_STATUS,
               BEM_DP_CODE,
               BEM_DP_ACCOUNT_TYPE,
               BEM_DP_CUSTOMER_ID,
               BEM_RDA_FLAG,
               BED_EMAIL_FREQUENCY,
               BED_CLIENT_SUB_CATEG,
               BEM_DEF_NSE_CUST,
               BEM_NSE_DRV_DEF_CUST,
               BEM_DEF_BSE_CUST,
               BEM_BSE_DRV_DEF_CUST,
               BEM_ACC_TYPE,
               BEM_EXCH_CLIENT_ID,
               BEM_SMS_ALERT_FLAG,
               BEM_PRODUCT_PRIV_FLAG,
               BEM_SPOT_MAX_LIMIT,
               BEM_T2_MAX_LIMIT,
               BEM_DMG_FLAG,
               BEM_MOBILE_ALLOWED,
               BEM_PROFILE_ID,
               BEM_SECOND_CLIENT_NAME,
               BEM_THIRD_CLIENT_NAME,
               BEM_SECOND_CLIENT_PAN,
               BEM_THIRD_CLIENT_PAN,
               BEM_KYC_COMPLIANT,
               BEM_TAX_STATUS,
               BEM_GENDER,
               BEM_GUARDIAN_NAME,
               BEM_GUARDIAN_PANNO,
               BEM_NOMINEE_NAME,
               BEM_NOMINEE_RELATION,
               BEM_MODEOFHOLDING,
               BEM_STMTCOMMUNICATIONMODE,
               BEM_PAYOUTMECHANISM,
               BEM_NEFT_CODE,
               BEM_EUIN_NUMBER,
               BEM_OCCUPATION,
               BEM_NSE_CDX_DEF_CUST,
               BEM_BSE_CDX_DEF_CUST,
               BEM_BOS_CLIENT_RISK_CATEG,
               BEM_MRG_PRIV,
               BEM_AADHAAR_NO,
               BEM_AADHAAR_VERIFIED,
               BEM_EMAR_ACCEPT_FLG,
               BEM_EMAR_ACCEPT_SOURCE,
               BEM_EMAR_ACCEPT_USER,
               BEM_EMAR_ACCEPT_DATE
         ,BEM_ADV_PORTFOLIO_FLG
             --  ,BEM_EMAR_ACCEPT_FLG           ,BEM_EMAR_ACCEPT_SOURCE   ,BEM_EMAR_ACCEPT_USER
              -- ,BEM_EMAR_ACCEPT_DATE
                 ,BEM_SIP_RELN_MNGR        ,BEM_SELF_LOGIN_ALLOWED
               ,BEM_CKYC_NO)
            VALUES
              (L_ENTITY_ID,
               L_ENTITY_NAME,
               L_ENTITY_TYPE,
               L_ENT_CLIENT_TYPE,
               L_ENTITY_STATUS,
               L_ENTITY_CTRL_ID,
               L_ENT_EXCH_CLIENT_ID,
               L_ENT_DOB,
               L_ENTITY_ADD_LINE_1,
               L_ENTITY_ADD_LINE_2,
               L_ENTITY_ADD_LINE_3,
               L_ENTITY_ADD_LINE_4,
               L_ENTITY_ADD_LINE_5,
               L_ENTITY_ADD_LINE_6,
               L_ENTITY_ADD_LINE_7,
               L_ENTITY_PHNO_1,
               L_ENTITY_PHNO_2,
               L_ENTITY_FAXNO_1,
               L_ENTITY_FAXNO_2,
               L_ENT_EOD_REL_FLG,
               L_ENT_EOD_REL_FLG,
               L_ENT_INTERNET_PRIV,
               DECODE(L_ENTITY_ADD_LINE_5,
                      'SIKKIM',
                      NVL(L_ERD_PAN_NO, 'PAN_EXEMPT'),
                      L_ERD_PAN_NO),
               L_ENTITY_EMAIL_ID,
               L_BAM_ACC_NO,
               L_BAM_ACC_TYPE,
               L_BAM_CUST_ID,
               SUBSTR(L_DP_ACC_NO, -8),
               L_DP_ACC_STATUS,
               L_ENTITY_LOGIN_ID,
               L_ENT_PRIV,
               'N',
               L_ENT_SEC_REL_FL,
               L_EPM_SEG_EQUITY,
               L_EPM_SEG_DERIVATIVES,
               L_ENT_MOBILE_NO,
               L_BAM_BKM_CD,
               L_BAM_STATUS,
               L_MDI_DPM_ID,
               L_MDI_ACC_TYPE,
               L_MDI_CUST_ID,
               L_ENT_DISCLOSURE_FLAG,
               DECODE(L_ENT_ORD_CONF_FL, 'E', 'C', 'I', 'E', 'N'),
               TO_NUMBER(L_ENT_CTG_DESC),
               L_NSE_EQ_CP_ID,
               L_NSE_DR_CP_ID,
               L_BSE_EQ_CP_ID,
               L_BSE_DR_CP_ID,
               'N',
               L_ENT_EXCH_CLIENT_ID,
               L_ENT_SMS_ALERT_FL,
               L_PRODUCT_PRIV_FLAG,
               DECODE(L_EPM_PRODUCT_CC,
                      'Y',
                      NVL(L_EPM_PRODUCT_SPOT_CAP, 0),
                      0),
               DECODE(L_EPM_PRODUCT_T2,
                      'Y',
                      NVL(L_EPM_PRODUCT_T2_CAP, 0),
                      0),
               L_DMG_STATUS,
               L_MOBILE_TRADING,
               L_ENT_FOS_PROFILE_ID,
               L_MDI_CL_APP2,
               L_MDI_CL_APP3,
               L_MDI_CL_PAN2,
               L_MDI_CL_PAN3,
               L_EMD_KYC_COMPLIANT,
               L_MDI_TAX_STATUS,
               L_ENT_SEX,
               L_ERD_GUARD_NAME,
               L_ERD_GUARDIAN_PAN,
               L_MDI_CL_NOMINEE,
               L_MDI_CL_NOMINEE_RL,
               L_MDI_CL_HOLDING,
               L_EMD_COMMUNICATION_MODE,
               L_EMD_CL_DIV_PAYMODE,
               L_BBM_NEFT_CODE,
               L_ENT_EUIN_NUMBER,
               DECODE(L_ENT_OCCUPATION,
                      'Business',
                      '1',
                      'Services',
                      '2',
                      'Professional',
                      '3',
                      'Agriculture',
                      '4',
                      'Retired',
                      '5',
                      'Housewife',
                      '6',
                      'Student',
                      '7',
                      'Others',
                      '8',
                      '8'),
               L_NSE_CR_CP_ID,
               L_BSE_CR_CP_ID,
               NVL(L_ERM_RISK_TYPE, 'L'),
               L_EPM_SEG_MFD,
               L_ERD_ADH_NO,
               L_ENT_UID_VERIFIED_YN,
               l_Margin_Fund_Flag,
               l_Margin_Fund_Mode,
               l_Margin_Fund_User,
               l_Margin_Fund_Date,
         L_EPM_ADV_PORTFOLIO,
        /* L_MARGIN_FUND_FLAG        ,
         L_MARGIN_FUND_MODE,
              L_MARGIN_FUND_USER             ,
        L_MARGIN_FUND_DATE        ,*/
        L_ENT_RM_ID
              ,'N'                            ,
        L_ERD_CKYC_NO);

            L_INSERT := L_INSERT + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Client Id Inserted in MTS : ' || L_ENTITY_ID);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
          END IF;

          IF L_ENTITY_TYPE = 'CL' THEN

            SELECT DECODE(L_EPM_SEG_EQUITY,
                          'Y',
                          DECODE(L_EPM_SEG_DERIVATIVES, 'Y', 'B', 'E'),
                          'N',
                          DECODE(L_EPM_SEG_DERIVATIVES, 'Y', 'D'))
              INTO L_SEGMENT
              FROM DUAL;

            SELECT MAX(RV_LOW_VALUE)
              INTO L_ENT_BANK_CATEGORY_DESC
              FROM CG_REF_CODES
             WHERE RV_DOMAIN = 'BANK_CATEGORY'
               AND RV_HIGH_VALUE = L_ENT_BANK_CATEGORY;

            SELECT MAX(RV_LOW_VALUE)
              INTO L_ENT_TRADE_CATEGORY_DESC
              FROM CG_REF_CODES
             WHERE RV_DOMAIN = 'TRADE_CATEGORY'
               AND RV_HIGH_VALUE = L_ENT_TRADE_CATEGORY;

            /*l_Output_String := l_entity_id               || '|' ||
                               l_erd_pan_no              || '|' ||
                               l_Epr_Appln_No            || '|' ||
                               l_entity_login_id         || '|' ||
                               l_Segment                 || '|' ||
                               l_entity_status           || '|' ||
                               l_ent_category            || '|' ||
                               l_Ent_Nationality         || '|' ||
                               l_Ent_Bank_Category_Desc  || '|' ||
                               l_Ent_Trade_Category_Desc || '|' ||
                               l_Ent_Title               || '|' ||
                               l_Ent_First_Name          || '|' ||
                               l_Ent_Middle_Name         || '|' ||
                               l_Ent_Last_Name           || '|' ||
                               l_entity_name             || '|' ||
                               l_entity_email_id         || '|' ||
                               l_entity_phno_1           || '|' ||
                               l_entity_phno_2           || '|' ||
                               l_ent_mobile_no           || '|' ||
                               l_ent_dob                 || '|' ||
                               l_Ent_Occupation          || '|' ||
                               l_entity_faxno_1          || '|' ||
                               l_entity_faxno_2          || '|' ||
                               l_entity_add_line_1       || '|' ||
                               l_entity_add_line_2       || '|' ||
                               l_entity_add_line_3       || '|' ||
                               l_entity_add_line_4       || '|' ||
                               l_entity_add_line_5       || '|' ||
                               l_entity_add_line_6       || '|' ||
                               l_entity_add_line_7       || '|' ||
                               l_Eq_Brk_Scheme           || '|' ||
                               l_Dr_Brk_Scheme;

            Utl_File.Put_Line(l_Data_File_Handle,l_Output_String);
            Utl_File.Fflush(l_Data_File_Handle);*/
          END IF;

        EXCEPTION
          WHEN DONT_SEND THEN
            NULL;
          WHEN OTHERS THEN
            L_FAIL := L_FAIL + 1;
            L_FLAG := 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              '--------------------------------------------------------------------------------------------');
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Failed For Client Id : ' || L_ENTITY_ID ||
                              '  Client Name : ' || L_ENTITY_NAME);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
            L_DESC := 'Error While ' || L_STR || ' : ' ||
                      SUBSTR(SQLERRM, 1, 100);
            UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        L_FETCH := L_FETCH + 1;
      END LOOP; -- End of Entity Id Loop

      /*IF Utl_File.Is_Open(l_Data_File_Handle) THEN
        Utl_File.Fclose(l_Data_File_Handle);
      END IF;*/

      IF (L_FETCH = 0) THEN
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'No records to be uploaded to MTS');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        --Utl_File.Fremove(l_Log_Env,l_Data_File_Name);
      END IF;

      L_STR := ' Completing processing for list of clients ';
      CLOSE C_ENTITY;
      L_SUCCESS := 'Y';
    EXCEPTION
      WHEN E_BANNED_ENTITY_ERROR THEN
        L_SUCCESS := 'N';
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Failed in p_Load_Sebi_Banned_Entity.' || CHR(10));
        UTL_FILE.FFLUSH(L_FILE_HANDLE);

      WHEN OTHERS THEN
        L_SUCCESS := 'N';
        L_DESC    := 'Error While ' || L_STR || ' : ' ||
                     SUBSTR(SQLERRM, 1, 100);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;

    ---Proxy Client
    L_STR := 'Uploading proxy client details to Front office .';
    FOR J IN C_PROXY_DETAILS LOOP
      BEGIN
        L_STR := 'Inserting proxy details for client <' || J.CLD_CLIENT_ID ||
                 '< and pan No <' || J.CLD_PAN_NO || '>.';
        INSERT INTO BOS_CLIENT_PROXY_DTLS
          (BCLD_CLIENT_ID,
           BCLD_ID,
           BCLD_HLDR_NAME,
           BCLD_HLDR_GEN,
           BCLD_ADDRESS1,
           BCLD_ADDRESS2,
           BCLD_ADDRESS3,
           BCLD_ADDRESS4,
           BCLD_CITY,
           BCLD_STATE,
           BCLD_PIN_CD,
           BCLD_PHONE_NO,
           BCLD_MOBILE_NO,
           BCLD_BIRTH_DATE,
           BCLD_CLINT_REL,
           BCLD_PAN_NO,
           BCLD_TEXT1,
           BCLD_TEXT2,
           BCLD_TEXT3,
           BCLD_STATUS,
           BCLD_ACTIVATION_DATE,
           BCLD_DEACTIVATION_DATE,
           BCLD_PRG_ID,
           BCLD_CRTD_DATE,
           BCLD_CRTD_BY,
           BCLD_COUNTRY,
           BCLD_VERSION_NO)
        VALUES
          (J.CLD_CLIENT_ID,
           J.CLD_ID,
           J.CLD_HLDR_NAME,
           J.CLD_HLDR_GEN,
           J.CLD_ADDRESS1,
           J.CLD_ADDRESS2,
           J.CLD_ADDRESS3,
           J.CLD_ADDRESS4,
           J.CLD_CITY,
           J.CLD_STATE,
           J.CLD_PIN_CD,
           J.CLD_PHONE_NO,
           J.CLD_MOBILE_NO,
           J.CLD_BIRTH_DATE,
           J.CLD_CLINT_REL,
           J.CLD_PAN_NO,
           J.CLD_TEXT1,
           J.CLD_TEXT2,
           J.CLD_TEXT3,
           J.CLD_STATUS,
           J.CLD_ACTIVATION_DATE,
           J.CLD_DEACTIVATION_DATE,
           L_PRG_ID,
           SYSDATE,
           USER,
           J.CLD_COUNTRY,
           J.CLD_VERSION_NO);
        L_INSERT_PROXY_CLIENT := L_INSERT_PROXY_CLIENT + SQL%ROWCOUNT;

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          L_STR := 'Updating proxy details for client <' || J.CLD_CLIENT_ID ||
                   '< and pan No <' || J.CLD_PAN_NO || '>.';
          UPDATE BOS_CLIENT_PROXY_DTLS
             SET BCLD_ID                = J.CLD_ID,
                 BCLD_HLDR_NAME         = J.CLD_HLDR_NAME,
                 BCLD_HLDR_GEN          = J.CLD_HLDR_GEN,
                 BCLD_ADDRESS1          = J.CLD_ADDRESS1,
                 BCLD_ADDRESS2          = J.CLD_ADDRESS2,
                 BCLD_ADDRESS3          = J.CLD_ADDRESS3,
                 BCLD_ADDRESS4          = J.CLD_ADDRESS4,
                 BCLD_CITY              = J.CLD_CITY,
                 BCLD_STATE             = J.CLD_STATE,
                 BCLD_PIN_CD            = J.CLD_PIN_CD,
                 BCLD_PHONE_NO          = J.CLD_PHONE_NO,
                 BCLD_MOBILE_NO         = J.CLD_MOBILE_NO,
                 BCLD_BIRTH_DATE        = J.CLD_BIRTH_DATE,
                 BCLD_CLINT_REL         = J.CLD_CLINT_REL,
                 BCLD_PAN_NO            = J.CLD_PAN_NO,
                 BCLD_TEXT1             = J.CLD_TEXT1,
                 BCLD_TEXT2             = J.CLD_TEXT2,
                 BCLD_TEXT3             = J.CLD_TEXT3,
                 BCLD_STATUS            = J.CLD_STATUS,
                 BCLD_ACTIVATION_DATE   = J.CLD_ACTIVATION_DATE,
                 BCLD_DEACTIVATION_DATE = J.CLD_DEACTIVATION_DATE,
                 BCLD_PRG_ID            = L_PRG_ID,
                 BCLD_LST_UPDT_DATE     = SYSDATE,
                 BCLD_LST_UPDT_BY       = USER,
                 BCLD_COUNTRY           = J.CLD_COUNTRY,
                 BCLD_VERSION_NO        = J.CLD_VERSION_NO
           WHERE BCLD_CLIENT_ID = J.CLD_CLIENT_ID
             AND BCLD_PAN_NO = J.CLD_PAN_NO;

          L_UPDATE_PROXY_CLIENT := L_UPDATE_PROXY_CLIENT + SQL%ROWCOUNT;
        WHEN OTHERS THEN
          L_SUCCESS := 'N';
          L_DESC    := 'Error While ' || L_STR || ' : ' ||
                       SUBSTR(SQLERRM, 1, 100);
          UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
      END;
    END LOOP;
    COMMIT;

    STD_LIB.P_UPDATE_UPS_CONTROL(L_CURR_DATE,
                                 'ALL',
                                 STD_LIB.L_BATCH_NO,
                                 STD_LIB.L_BATCH_SEQ_NO,
                                 L_SUCCESS,
                                 L_PRG_ID,
                                 L_PRG_PROCESS_ID,
                                 L_FETCH,
                                 L_INSERT + L_UPDT,
                                 NULL,
                                 'Procy Client Updated');

    UPDATE PROGRAM_STATUS
       SET PRG_STATUS         = DECODE(L_SUCCESS, 'Y', 'C', 'E'),
           PRG_STATUS_FILE    = /*Decode(l_fetch,0,*/ 'No Status File' /*,l_Log_Env||l_Data_File_Name)*/,
           PRG_PARTIAL_RUN_YN = 'N',
           PRG_END_TIME       = SYSDATE,
           PRG_LAST_UPDT_BY   = USER,
           PRG_LAST_UPDT_DT   = SYSDATE
     WHERE PRG_DT = L_CURR_DATE
       AND PRG_PROCESS_ID = L_PRG_PROCESS_ID
       AND PRG_CMP_ID = L_PRG_ID;

    COMMIT;

    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Client records Fetched: ' || L_FETCH);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Inserted: ' || L_INSERT);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of records Updated: ' || L_UPDT);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Process Completed at ' ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'Error - ' || L_STR || '-' || SQLERRM);
      UTL_FILE.NEW_LINE(L_FILE_HANDLE, 2);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Process Failed');
      IF UTL_FILE.IS_OPEN(L_FILE_HANDLE) THEN
        UTL_FILE.FCLOSE(L_FILE_HANDLE);
      END IF;

      STD_LIB.P_UPDT_PRG_STAT(L_PRG_ID,
                              L_CURR_DATE,
                              L_PRG_PROCESS_ID,
                              'E',
                              'Y',
                              O_SQLERRM);

  END P_LOAD_ENTITY_MTS;

  PROCEDURE P_LOAD_HOLIDAY_MASTER_MTS IS

    L_UPDT            NUMBER := 0;
    L_INSERT          NUMBER := 0;
    L_FETCH           NUMBER := 0;
    L_CURR_DATE       PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID          VARCHAR2(30) := 'CSSBHMUP';
    L_PRG_PROCESS_ID  NUMBER := 0;
    L_FILE_HANDLE     UTL_FILE.FILE_TYPE;
    L_LOG_ENV         VARCHAR2(100);
    L_FILE_NAME       VARCHAR2(70);
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_LOD_SEQ         LOAD_CONTROLS.LOD_SEQ %TYPE;
    L_FIRST_LOAD_TIME DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME  DATE;
    L_HM_DATE         HOLIDAY_MASTER.HOM_DT%TYPE;
    L_HM_TYPE         HOLIDAY_MASTER.HOM_TYPE%TYPE;
    L_HM_EXM_ID       HOLIDAY_MASTER.HOM_EXM_ID%TYPE;
    L_HM_SEG_ID       HOLIDAY_MASTER.HOM_SEG_ID%TYPE;

    CURSOR C_HOLIDAY_MASTER IS
      SELECT HOM_DT,
             HOM_TYPE,
             HOM_EXM_ID,
             HOM_DESC,
             HOM_REV_FLG,
             HOM_SEG_ID
        FROM HOLIDAY_MASTER
       WHERE HOM_TYPE IN ('W', 'T')
         AND HOM_EXM_ID != 'ALL'
         AND (HOM_CREAT_DT >= L_LAST_LOAD_TIME OR
             HOM_LAST_UPDT_DT >= L_LAST_LOAD_TIME);

  BEGIN

    BEGIN
      L_IND := 9;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';
      L_IND         := 10;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Holidays List Upload to MTS  -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      L_IND := 6;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      --get last run time for completed batch
      BEGIN
        SELECT NVL(MAX(LOD_START_TIME), L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND LOD_STATUS = 'C';
      END;
      --insert record into program status
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID;
      BEGIN
        L_IND := 7;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status FILE',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        --get max seq no for today
        L_IND := 16;
        SELECT (NVL(MAX(LOD_SEQ), 0)) + 1
          INTO L_LOD_SEQ
          FROM LOAD_CONTROLS
         WHERE LOD_DT = L_CURR_DATE
           AND LOD_CMP_ID = L_PRG_ID;

        --insert record into load_controls
        L_IND := 15;
        INSERT INTO LOAD_CONTROLS
          (LOD_DT,
           LOD_STATUS,
           LOD_SEQ,
           LOD_START_TIME,
           LOD_PROCESS_ID,
           LOD_CMP_ID,
           LOD_CREAT_BY,
           LOD_CREAT_DT)
        VALUES
          (TRUNC(L_CURR_DATE),
           'R',
           L_LOD_SEQ,
           SYSDATE,
           L_PRG_PROCESS_ID,
           L_PRG_ID,
           USER,
           SYSDATE);
        COMMIT;
      END;

      --OPENING THE HOLIDAY MASTER CURSOR
      BEGIN
        L_IND := 1;

        FOR HOLIDAY_MASTER_REC IN C_HOLIDAY_MASTER LOOP
          L_HM_DATE   := HOLIDAY_MASTER_REC.HOM_DT;
          L_HM_TYPE   := HOLIDAY_MASTER_REC.HOM_TYPE;
          L_HM_EXM_ID := HOLIDAY_MASTER_REC.HOM_EXM_ID;
          L_HM_SEG_ID := HOLIDAY_MASTER_REC.HOM_SEG_ID;
          --update MTS table
          BEGIN
            L_IND := 3;
            UPDATE BOS_HOLIDAY_MASTER
               SET BHM_HOLIDAY_NAME = HOLIDAY_MASTER_REC.HOM_DESC,
                   BHM_REV_FLG      = HOLIDAY_MASTER_REC.HOM_REV_FLG,
                   BHM_SEGMENT_ID   = DECODE(HOLIDAY_MASTER_REC.HOM_SEG_ID,
                                             'C',
                                             'F',
                                             HOLIDAY_MASTER_REC.HOM_SEG_ID)
             WHERE BHM_HOLIDAY_DATE = HOLIDAY_MASTER_REC.HOM_DT
               AND BHM_EXM_EXCH_ID = HOLIDAY_MASTER_REC.HOM_EXM_ID
               AND BHM_SEGMENT_ID =
                   DECODE(HOLIDAY_MASTER_REC.HOM_SEG_ID,
                          'C',
                          'F',
                          HOLIDAY_MASTER_REC.HOM_SEG_ID);

            IF SQL%FOUND THEN
              L_UPDT := L_UPDT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                'Updated in MTS,For Holiday Date : ' ||
                                HOLIDAY_MASTER_REC.HOM_DT ||
                                '   Holiday Type : ' ||
                                HOLIDAY_MASTER_REC.HOM_TYPE ||
                                '   Exchange Id: ' ||
                                HOLIDAY_MASTER_REC.HOM_EXM_ID);
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            IF SQL%NOTFOUND THEN
              BEGIN
                L_IND := 4;
                INSERT INTO BOS_HOLIDAY_MASTER
                  (BHM_HOLIDAY_DATE,
                   BHM_HOLIDAY_TYPE,
                   BHM_EXM_EXCH_ID,
                   BHM_HOLIDAY_NAME,
                   BHM_REV_FLG,
                   BHM_SEGMENT_ID)
                VALUES
                  (HOLIDAY_MASTER_REC.HOM_DT,
                   HOLIDAY_MASTER_REC.HOM_TYPE,
                   HOLIDAY_MASTER_REC.HOM_EXM_ID,
                   HOLIDAY_MASTER_REC.HOM_DESC,
                   HOLIDAY_MASTER_REC.HOM_REV_FLG,
                   DECODE(HOLIDAY_MASTER_REC.HOM_SEG_ID,
                          'C',
                          'F',
                          HOLIDAY_MASTER_REC.HOM_SEG_ID));

                L_INSERT := L_INSERT + 1;
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  'Inserted in MTS,For Holiday Date : ' ||
                                  HOLIDAY_MASTER_REC.HOM_DT ||
                                  '   Holiday Type : ' ||
                                  HOLIDAY_MASTER_REC.HOM_TYPE ||
                                  '   Exchange Id: ' ||
                                  HOLIDAY_MASTER_REC.HOM_EXM_ID);
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
              END;
            END IF;
          END;
          L_FETCH := L_FETCH + 1;
        END LOOP;
        IF (L_FETCH = 0) THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'No records to be uploaded to MTS HOLIDAY MASTER ');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END IF;
      END;
      --CLOSING THE HOLIDAY MASTER CURSOR
    EXCEPTION
      WHEN OTHERS THEN
        IF L_IND = 9 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'For Date : ' || L_HM_DATE ||
                          '   Holiday Type : ' || L_HM_TYPE ||
                          '   Exchange Id: ' || L_HM_EXM_ID);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        L_FLAG := 1;
        IF L_IND = 1 THEN
          L_DESC := 'Error while opening the cursor :' || SQLERRM;
        ELSIF L_IND = 3 THEN
          L_DESC := 'Error while updating the records in MTS HOLIDAY MASTER  :' ||
                    SQLERRM;
        ELSIF L_IND = 4 THEN
          L_DESC := 'Error while inserting the records in MTS HOLIDAY MASTER  :' ||
                    SQLERRM;
        ELSIF L_IND = 6 THEN
          L_DESC := 'Error while Selecting from Parameter Master   :' ||
                    SQLERRM;
        ELSIF L_IND = 7 THEN
          L_DESC := 'Error while inserting the records in Program Status  :' ||
                    SQLERRM;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while inserting the records in Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 16 THEN
          L_DESC := 'Error while selecting the load sequence from Load Controls  :' ||
                    SQLERRM;
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;

    IF L_FLAG = 0 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'C',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'C',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Fetched: ' || L_FETCH);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Inserted: ' || L_INSERT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of records Updated: ' || L_UPDT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading Holiday List to MTS successfully completed at ' ||
                          TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'E',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'E',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control : ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Uploading Holiday List to MTS Unsuccessful');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;
  END P_LOAD_HOLIDAY_MASTER_MTS;

  PROCEDURE P_UPDT_RDA_SIGN_STATUS_MTS IS

    L_UPDT            NUMBER := 0;
    L_PENDING         NUMBER := 0;
    L_FETCH           NUMBER := 0;
    L_CURR_DATE       PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID          VARCHAR2(30) := 'CSSBENTRDA';
    L_PRG_PROCESS_ID  NUMBER := 0;
    L_FILE_HANDLE     UTL_FILE.FILE_TYPE;
    L_LOG_ENV         VARCHAR2(100);
    L_FILE_NAME       VARCHAR2(70);
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_LOD_SEQ         LOAD_CONTROLS.LOD_SEQ %TYPE;
    L_FIRST_LOAD_TIME DATE := '01-JAN-1900';
    L_LAST_LOAD_TIME  DATE;
    L_CLIENT_ID       ENTITY_MASTER.ENT_ID%TYPE;
    L_ERH_RDA_ID      ENTITY_RDA_HISTORY.ERH_RDA_ID%TYPE;

    CURSOR C_RDA_SIGN_STATUS IS
      SELECT BRSS_EM_ENTITY_ID,
             BRSS_EM_RDA_FLAG,
             BRSS_EM_RDA_SIGN_DATE,
             BRSS_EM_RDA_SIGN_BY
        FROM BOS_RDA_SIGN_STATUS
       WHERE BRSS_EM_RDA_FLAG = 'Y'
         AND BRSS_EM_ENTITY_ID IN
             (SELECT ENT_ID
                FROM ENTITY_MASTER
               WHERE ENT_DISCLOSURE_DT IS NULL);

  BEGIN
    BEGIN
      L_IND := 5;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      L_IND         := 10;
      L_FILE_NAME   := L_PRG_ID || '_' || TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') ||
                       '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Updating the Clients Risk Disclosure Agreement Status -- ' ||
                        TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss') ||
                        '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      L_IND := 15;
      SELECT PAM_CURR_DT INTO L_CURR_DATE FROM PARAMETER_MASTER;

      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || ' Working Date: ' ||
                        L_CURR_DATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Program Id :' || L_PRG_ID);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '--------------------------------------------------------------------------------------------');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);

      L_IND := 20;
      --get last run time for completed batch
      BEGIN
        SELECT NVL(MAX(LOD_START_TIME), L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND LOD_STATUS = 'C';
      END;
      L_IND := 25;
      --insert record into program status
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_DT = L_CURR_DATE
         AND PRG_CMP_ID = L_PRG_ID;
      BEGIN
        L_IND := 30;
        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status FILE',
           L_LOG_ENV || L_FILE_NAME,
           'None',
           'ALL',
           USER,
           SYSDATE);
        COMMIT;
      END;

      BEGIN
        --get max seq no for today
        L_IND := 35;
        SELECT (NVL(MAX(LOD_SEQ), 0)) + 1
          INTO L_LOD_SEQ
          FROM LOAD_CONTROLS
         WHERE LOD_DT = L_CURR_DATE
           AND LOD_CMP_ID = L_PRG_ID;

        --insert record into load_controls
        L_IND := 40;
        INSERT INTO LOAD_CONTROLS
          (LOD_DT,
           LOD_STATUS,
           LOD_SEQ,
           LOD_START_TIME,
           LOD_PROCESS_ID,
           LOD_CMP_ID,
           LOD_CREAT_BY,
           LOD_CREAT_DT)
        VALUES
          (TRUNC(L_CURR_DATE),
           'R',
           L_LOD_SEQ,
           SYSDATE,
           L_PRG_PROCESS_ID,
           L_PRG_ID,
           USER,
           SYSDATE);
        COMMIT;
      END;

      -- To Set the RollBack Segment
      SET TRANSACTION USE ROLLBACK SEGMENT BIG_RBS;
      BEGIN
        L_IND := 6;
        SELECT MAX(TO_NUMBER(BMRI_ID))
          INTO L_ERH_RDA_ID
          FROM BOS_MAX_RDA_ID;
        --  where rownum = 1;

        L_IND := 45;

        FOR C_RDA_SIGN_STATUS_REC IN C_RDA_SIGN_STATUS LOOP
          L_CLIENT_ID := C_RDA_SIGN_STATUS_REC.BRSS_EM_ENTITY_ID;
          BEGIN

            L_IND := 50;
            UPDATE ENTITY_MASTER
               SET ENT_DISCLOSURE_DT = C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_DATE,
                   ENT_RDA_SIGN_BY   = C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_BY
             WHERE ENT_ID = C_RDA_SIGN_STATUS_REC.BRSS_EM_ENTITY_ID;

            IF SQL%FOUND THEN
              L_UPDT := L_UPDT + 1;
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                'Updated for Client Id : ' ||
                                C_RDA_SIGN_STATUS_REC.BRSS_EM_ENTITY_ID);
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
            END IF;

            L_IND := 55;
            UPDATE ENTITY_MASTER_INT
               SET ENT_DISCLOSURE_DT = C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_DATE,
                   ENT_RDA_SIGN_BY   = C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_BY
             WHERE ENT_ID = C_RDA_SIGN_STATUS_REC.BRSS_EM_ENTITY_ID
               AND ENT_REC_STATUS = 'P';

            --Add record in ENTITY_RDA_HISTORY table
            L_IND := 56;
            BEGIN
              INSERT INTO ENTITY_RDA_HISTORY
                (ERH_ENT_ID,
                 ERH_RDA_ID,
                 ERH_RDA_SIGNED_DT,
                 ERH_RDA_SIGNED_BY,
                 ERH_RDA_FLAG,
                 ERH_PRG_ID)
              VALUES
                (C_RDA_SIGN_STATUS_REC.BRSS_EM_ENTITY_ID,
                 L_ERH_RDA_ID,
                 C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_DATE,
                 C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_SIGN_BY,
                 C_RDA_SIGN_STATUS_REC.BRSS_EM_RDA_FLAG,
                 L_PRG_ID);

            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL;
            END;
          END;

        END LOOP;
        IF (L_UPDT = 0) THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'No records to be updated in Client Details for Risk Disclosure Agreement ');
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END IF;
        L_IND := 60;
        SELECT COUNT(1)
          INTO L_PENDING
          FROM ENTITY_MASTER
         WHERE ENT_DISCLOSURE_DT IS NULL;

      END;
      --CLOSING THE  RDA SIGN STATUS CURSOR

    EXCEPTION
      WHEN OTHERS THEN
        IF L_IND = 5 THEN
          L_DESC := 'Error while selecting the log file path ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20001, L_DESC);
        ELSIF L_IND = 10 THEN
          L_DESC := 'Error while Opening the log file  ' || SQLERRM;
          RAISE_APPLICATION_ERROR(-20002, L_DESC);
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'For Client Id : ' || L_CLIENT_ID);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        L_FLAG := 1;
        IF L_IND = 15 THEN
          L_DESC := 'Error while Selecting from Parameter Master   :' ||
                    SQLERRM;
        ELSIF L_IND = 20 THEN
          L_DESC := 'Error while selecting the last load time from Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 6 THEN
          L_DESC := 'Error while Getting uploaded Risk Disclosure Agreement Id, Incorrect setup. ' ||
                    SQLERRM;
        ELSIF L_IND = 25 THEN
          L_DESC := 'Error while selecting the Process Id from Program Status   :' ||
                    SQLERRM;
        ELSIF L_IND = 30 THEN
          L_DESC := 'Error while inserting the records in Program Status  :' ||
                    SQLERRM;
        ELSIF L_IND = 35 THEN
          L_DESC := 'Error while selecting the load sequence from Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 40 THEN
          L_DESC := 'Error while inserting the records in Load Controls  :' ||
                    SQLERRM;
        ELSIF L_IND = 45 THEN
          L_DESC := 'Error while selecting Big RollBack Segment   :' ||
                    SQLERRM;
        ELSIF L_IND = 46 THEN
          L_DESC := 'Error while opening the cursor :' || SQLERRM;
        ELSIF L_IND = 50 THEN
          L_DESC := 'Error while updating the records in Client Details :' ||
                    SQLERRM;
        ELSIF L_IND = 55 THEN
          L_DESC := 'Error while updating the records in Client Details Stage  :' ||
                    SQLERRM;
        ELSIF L_IND = 56 THEN
          L_DESC := 'Error while inserting the records in Client RDA history table  :' ||
                    SQLERRM;
        ELSIF L_IND = 60 THEN
          L_DESC := 'Error while Counting the Clients who are not signed RDA  :' ||
                    SQLERRM;
        END IF;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;
    --dbms_output.put_line('Flag'||l_flag);
    IF L_FLAG = 0 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'C',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'C',
                 LOD_TOTAL_RECS  = L_UPDT,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control for Success :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of Client Details Updated  : ' || L_UPDT);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Number of Clients not signed Risk Disclosure Agreement  : ' ||
                          L_PENDING);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '-------------------------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Updating the Clients Risk Disclosure Agreement Status from MTS successfully completed at ' ||
                          TO_CHAR(SYSDATE, 'DD-MON-YYYY hh24:mi:ss'));
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '-------------------------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;

    IF L_FLAG = 1 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'E',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_DT = L_CURR_DATE
             AND PRG_CMP_ID = L_PRG_ID
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;
        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in program status :' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'E',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_DT = L_CURR_DATE
             AND LOD_CMP_ID = L_PRG_ID
             AND LOD_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the records in Load Control : ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of Updating the Clients Risk Disclosure Agreement Status from MTS Unsuccessful');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          '--------------------------------------------------------------------------------------------');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;
  END P_UPDT_RDA_SIGN_STATUS_MTS;

  PROCEDURE P_LOAD_SECURITY_MASTER_MTS IS

    L_CURR_DATE          DATE;
    L_PRG_PROCESS_ID     NUMBER := 0;
    L_INSERT_NSE         NUMBER := 0;
    L_INSERT_BSE         NUMBER := 0;
    L_UPDT_NSE           NUMBER := 0;
    L_UPDT_BSE           NUMBER := 0;
    L_FETCH_NSE          NUMBER := 0;
    L_FETCH_BSE          NUMBER := 0;
    L_SKIPPED_NSE        NUMBER := 0;
    L_SKIPPED_BSE        NUMBER := 0;
    L_UPDT_COLLATERAL    NUMBER := 0;
    L_INSERT_COLLATERAL  NUMBER := 0;
    L_FETCH_COLLATERAL   NUMBER := 0;
    L_SKIPPED_COLLATERAL NUMBER := 0;
    L_SUCCESS            VARCHAR2(1) := 'Y';
    L_ISIN               VARCHAR2(30);
    L_PRG_ID             VARCHAR2(30) := 'CSSQSECMTS';
    L_FILE_NAME          VARCHAR2(100);
    L_STR                VARCHAR2(32767);
    L_FILE_HANDLE        UTL_FILE.FILE_TYPE;

    /*CURSOR C_Nse_Security_Master IS
      SELECT   Nvl(Sd.Sed_Mts_Sem_Id,Sm.Sem_Id)           Internal_Sec_Id    ,
               Sd.Sed_Exch_Sec_Id                         Nse_Sec_Id         ,
               Substr(Sm.Sem_Desc,1,40)                   Security_Desc      ,
               Substr(Sm.Sem_Id,1,Length(Sm.Sem_Id)-2)    Security_Abbr      ,
               Substr(Sd.Sed_Exch_Sec_Series,
                      1,Length(Sd.Sed_Exch_Sec_Series)-2) Security_Symbol    ,
               Sm.Sem_Isin_Cd                             Isin               ,
               Sd.Sed_Status                              Status             ,
               Esmm.Esmm_Settlement_Mkt_Type              Sett_Mkt_Type      ,
               Substr(Sd.Sed_Reuter_Cd,1,12)              Reuter_Cd          ,
               Substr(Sd.Sed_Bloomberg,1,12)              Bloomberg_Cd       ,
               Substr(Sd.Sed_Cusip,1,12)                  Cusip_Cd           ,
               Substr(Sd.Sed_Sedol,1,12)                  Sedol_Cd           ,
               Substr(Sm.Sem_Sector,1,15)                 Sector             ,
               Substr(Sd.Sed_Exch_Sec_Series,-2,2)        Exch_Sec_Series    ,
               Substr(Sm.Sem_Mkt_Lot,1,5)                 Market_Lot         ,
               Sm.Sem_Tick_Size                           Tick_Size          ,
               Sd.Sed_Aon_Allowed                         Aon_Allowed        ,
               Sd.Sed_Mf_Allowed                          Min_Fill_Allowed   ,
               Sd.Sed_Deleted_Status                      Deleted_Status     ,
               Sd.Sed_Part_Mkt_Index                      Part_Mkt_Index     ,
               Sm.Sem_Type                                Instr_Type         ,
               Sd.Sed_Issued_Capital                      Issued_Capital     ,
               Sd.Sed_Freeze_Percent                      Freeze_Percent     ,
               Sd.Sed_Credit_Rating                       Credit_Rating      ,
               Sd.Sed_Issue_Rate                          Issue_Rate         ,
               Sd.Sed_Issue_Start_Dt                      Issue_Strt_Dt      ,
               Sd.Sed_Issue_Payment_Dt                    Issue_Pmt_Dt       ,
               Sd.Sed_Issue_Maturity_Dt                   Issue_Maturity_Dt  ,
               Sd.Sed_Listing_Dt                          Listing_Dt         ,
               Sd.Sed_Expulsion_Dt                        Expulsion_Dt       ,
               Sd.Sed_Re_Admission_Dt                     Re_Addmssn_Dt      ,
               Sd.Sed_Record_Dt                           Record_Dt          ,
               Sd.Sed_Ex_Dt                               Ex_Dt              ,
               Sd.Sed_No_Del_Strt_Dt                      Nd_Strt_Dt         ,
               Sd.Sed_No_Del_End_Dt                       Nd_End_Dt          ,
               Sd.Sed_Bk_Cl_Strt_Dt                       Bk_Strt_Dt         ,
               Sd.Sed_Bk_Cl_End_Dt                        Bk_End_Dt          ,
               Sd.Sed_Agm                                 Agm                ,
               Sd.Sed_Egm                                 Egm                ,
               Sd.Sed_Interest                            Interest           ,
               Sd.Sed_Dividend                            Dividend           ,
               Sd.Sed_Bonus                               Bonus              ,
               Sd.Sed_Rights                              Rights             ,
               Sd.Sed_Remarks                             Remarks            ,
               Sd.Sed_Creat_By                            Creat_By           ,
               Sd.Sed_Creat_Dt                            Creat_Dt           ,
               Sd.Sed_Last_Updt_By                        Last_Updt_By       ,
               Sd.Sed_Last_Updt_Dt                        Last_Updt_Dt       ,
               Sm.Sem_Face_Val                            Face_Value         ,
               Sd.Sed_Status_Normal                       Status_Normal      ,
               Sd.Sed_Status                              Elig_Normal        ,
               Sd.Sed_Status_Oddlot                       Status_Oddlot      ,
               Sd.Sed_Status_Retdbt                       Status_Retdbt      ,
               Sd.Sed_Status_Auction                      Status_Auction     ,
               Sd.Sed_Eligibility_Oddlot                  Elig_Oddlot        ,
               Sd.Sed_Eligibility_Retdbt                  Elig_Retdbt        ,
               Sd.Sed_Eligibility_Auction                 Elig_Auction       ,
               Sd.Sed_Permitted_To_Trade                  Permit_To_Trade
      FROM     Security_Master         Sm   ,
               Security_Details        Sd   ,
               Exch_Security_Mkt_Maps  Esmm
      WHERE    Sm.Sem_Id              = Sd.Sed_Sem_Id
      AND      Sd.Sed_Sem_Id          = Esmm.Esmm_Sem_Smst_Security_Id
      AND      Sd.Sed_Exch_Sec_Series = Esmm.Esmm_Exch_Sec_Series
      AND      Sd.Sed_Exm_Id          = Esmm.Esmm_Exch_Id
      AND      Sd.Sed_Exm_Id          = 'NSE'
      AND      Sm.Sem_Status          = 'A'
      AND      Sd.Sed_Status          IN ('A','S')
      ORDER BY Sem_Id;

    CURSOR C_Bse_Security_Master IS
      SELECT   Nvl(Sd.Sed_Mts_Sem_Id,Sm.Sem_Id)           Internal_Sec_Id    ,
               Substr(Sm.Sem_Desc,1,40)                   Security_Desc      ,
               Substr(Substr(Sm.Sem_Id,
                             1,Length(Sm.Sem_Id)-2),1,12) Security_Abbr      ,
               Sm.Sem_Isin_Cd                             Isin               ,
               Sd.Sed_Status                              Status             ,
               Esmm.Esmm_Settlement_Mkt_Type              Sett_Mkt_Type      ,
               Substr(Sd.Sed_Reuter_Cd,1,12)              Reuter_Cd          ,
               Substr(Sd.Sed_Bloomberg,1,12)              Bloomberg_Cd       ,
               Substr(Sd.Sed_Cusip,1,12)                  Cusip_Cd           ,
               Substr(Sd.Sed_Sedol,1,12)                  Sedol_Cd           ,
               Substr(Sm.Sem_Sector,1,15)                 Sector             ,
               Substr(Sd.Sed_Exch_Sec_Series,1,12)        Exch_Sec_Series    ,
               Substr(Sd.Sed_Grp_Name,1,2)                Bse_Group          ,
               Sm.Sem_Mkt_Lot                             Market_Lot         ,
               Sm.Sem_Tick_Size                           Tick_Size          ,
               Corp_Act.Nd_Strt_Dt                        Nd_Strt_Dt         ,
               Corp_Act.Nd_End_Dt                         Nd_End_Dt          ,
               Corp_Act.Bk_Strt_Dt                        Bk_Strt_Dt         ,
               Corp_Act.Bk_End_Dt                         Bk_End_Dt          ,
               Corp_Act.Rec_Dt                            Record_Dt          ,
               Sm.Sem_Face_Val                            Face_Value
      FROM     Security_Master         Sm   ,
               Security_Details        Sd   ,
               Exch_Security_Mkt_Maps  Esmm ,
               (SELECT  Cam.Caa_Int_Sec_Id Sec_Id     ,
                        Cam.Caa_Nd_St_Dt   Nd_Strt_Dt ,
                        Cam.Caa_Nd_End_Dt  Nd_End_Dt  ,
                        Cam.Caa_Bk_St_Dt   Bk_Strt_Dt ,
                        Cam.Caa_Bk_Cls_Dt  Bk_End_Dt  ,
                        Cam.Caa_Rec_Dt     Rec_Dt
                FROM    Corporate_Action_Master Cam,
                        Parameter_Master
                WHERE   Cam.Caa_Exm_Id = 'BSE'
                AND    (Pam_Curr_Dt < Cam.Caa_Rec_Dt OR
                        Pam_Curr_Dt < Cam.Caa_Ex_Dt)
               ) Corp_Act
      WHERE    Sm.Sem_Id              = Sd.Sed_Sem_Id
      AND      Sd.Sed_Sem_Id          = Esmm.Esmm_Sem_Smst_Security_Id
      AND      Sd.Sed_Exch_Sec_Series = Esmm.Esmm_Exch_Sec_Series
      AND      Sd.Sed_Exm_Id          = Esmm.Esmm_Exch_Id
      AND      Sd.Sed_Exm_Id          = 'BSE'
      AND      Sd.Sed_Sem_Id          = Corp_Act.Sec_Id(+)
      AND      Sm.Sem_Status          = 'A'
      AND      Sd.Sed_Status          IN ('A','S')
      ORDER BY Sem_Id;*/

    CURSOR SECURITY_COLLATERAL_DTLS IS
      SELECT SEM.SEM_ID SECURITY_ID,
             SEM.SEM_ISIN_CD ISIN,
             NVL(SEM.SEM_CAP_VALIDITY, 'N') COLLATERAL_ALLOWED,
             NVL(SEM.SEM_HAIR_CUT_PERC, 0) VALUATION_PERC,
             NVL(SEM.SEM_COLL_CAP, 0) BROKER_COLL_CAP,
             NVL(SEM.SEM_CLIENT_COLL_CAP, 0) CLIENT_COLL_CAP
        FROM SECURITY_MASTER SEM
       WHERE SEM.SEM_ISIN_CD IS NOT NULL
       ORDER BY SEM.SEM_ID;

    TYPE TAB_ISIN IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
    G_TAB_ISIN TAB_ISIN;

  BEGIN
    BEGIN
      L_STR := ' Performing Housekeeping Functions ';
      STD_LIB.P_HOUSEKEEPING(L_PRG_ID,
                             'ALL',
                             'ALL',
                             'B',
                             L_FILE_HANDLE,
                             L_FILE_NAME,
                             L_PRG_PROCESS_ID);

      L_CURR_DATE := STD_LIB.L_PAM_CURR_DATE;

      /*l_Str := ' Populating Table For ISIN ';
      FOR i IN (SELECT a.Sem_Id,
                       Nvl(b.Sem_Isin_Cd,'DUMMY') Isin_Cd
                FROM   Security_Master a,
                       Security_Master b
                WHERE  a.Sem_Id        <> b.Sem_Id
                AND    a.Sem_Ref_Sem_Id = b.Sem_Id)
      LOOP
        g_Tab_Isin(i.Sem_Id) := i.Isin_Cd;
      END LOOP;

      DELETE FROM Bos_Nse_Security_Master;
      DELETE FROM Bos_Bse_Security_Master;

      l_Str := ' Fetching Data For NSE Security Master ';
      FOR i IN  C_Nse_Security_Master
      LOOP

        l_Str  := ' Getting ISIN For Security Id : ' || i.Internal_Sec_Id;
        l_Isin := NULL;
        IF i.Isin IS NULL THEN
          IF g_Tab_Isin.EXISTS(i.Internal_Sec_Id) THEN
            l_Isin := g_Tab_Isin(i.Internal_Sec_Id);
          ELSE
            l_Isin := 'DUMMY';
          END IF;
        ELSE
          l_Isin := i.Isin;
        END IF;

        BEGIN
          l_Str := ' Updating NSE Data In Front Office For Security Id : ' || i.Internal_Sec_Id;
          UPDATE Bos_Nse_Security_Master
          SET    Bnse_Internal_Security_Name    = i.Security_Desc          ,
                 Bnse_Security_Abvn             = i.Security_Abbr          ,
                 Bnse_Isin_Code                 = l_Isin                   ,
                 Bnse_Status                    = i.Status                 ,
                 Bnse_Mkt_Settlement_Type       = i.Sett_Mkt_Type          ,
                 Bnse_Reuters_Code              = i.Reuter_Cd              ,
                 Bnse_Bloomberg_Code            = i.Bloomberg_Cd           ,
                 Bnse_Cusip                     = i.Cusip_Cd               ,
                 Bnse_Sedol                     = i.Sedol_Cd               ,
                 Bnse_Sector                    = i.Sector                 ,
                 Bnse_Symbol                    = i.Security_Symbol        ,
                 Bnse_Series                    = i.Exch_Sec_Series        ,
                 Bnse_Security_Name             = i.Security_Desc          ,
                 Bnse_Regular_Lot               = i.Market_Lot             ,
                 Bnse_Tick_Size                 = i.Tick_Size              ,
                 Bnse_Aon_Allowed               = i.Aon_Allowed            ,
                 Bnse_Min_Fill_Allowed          = i.Min_Fill_Allowed       ,
                 Bnse_Deleted_Status            = i.Deleted_Status         ,
                 Bnse_Participant_In_Index      = i.Part_Mkt_Index         ,
                 Bnse_Instrument_Type           = i.Instr_Type             ,
                 Bnse_Issued_Capital            = i.Issued_Capital         ,
                 Bnse_Freeze_Pct                = i.Freeze_Percent         ,
                 Bnse_Credit_Rating             = i.Credit_Rating          ,
                 Bnse_Issue_Rate                = i.Issue_Rate             ,
                 Bnse_Issue_Start_Date          = i.Issue_Strt_Dt          ,
                 Bnse_Issue_Payment_Date        = i.Issue_Pmt_Dt           ,
                 Bnse_Issue_Maturity_Date       = i.Issue_Maturity_Dt      ,
                 Bnse_Listing_Date              = i.Listing_Dt             ,
                 Bnse_Expulsion_Date            = i.Expulsion_Dt           ,
                 Bnse_Re_Admission_Date         = i.Re_Addmssn_Dt          ,
                 Bnse_Record_Date               = i.Record_Dt              ,
                 Bnse_Ex_Date                   = i.Ex_Dt                  ,
                 Bnse_No_Delivery_Start_Date    = i.Nd_Strt_Dt             ,
                 Bnse_No_Delivery_End_Date      = i.Nd_End_Dt              ,
                 Bnse_Book_Close_Start_Date     = i.Bk_Strt_Dt             ,
                 Bnse_Book_Close_End_Date       = i.Bk_End_Dt              ,
                 Bnse_Agm                       = i.Agm                    ,
                 Bnse_Egm                       = i.Egm                    ,
                 Bnse_Interest                  = i.Interest               ,
                 Bnse_Dividend                  = i.Dividend               ,
                 Bnse_Bonus                     = i.Bonus                  ,
                 Bnse_Rights                    = i.Rights                 ,
                 Bnse_Remarks                   = i.Remarks                ,
                 Bnse_Created_By                = i.Creat_By               ,
                 Bnse_Created_Date              = i.Creat_Dt               ,
                 Bnse_Update_By                 = i.Last_Updt_By           ,
                 Bnse_Update_Date               = i.Last_Updt_Dt           ,
                 Bnse_Face_Value                = i.Face_Value             ,
                 Bnse_Security_Status_Nl        = i.Status_Normal          ,
                 Bnse_Eligibility_Nl            = i.Elig_Normal            ,
                 Bnse_Security_Status_Ol        = i.Status_Oddlot          ,
                 Bnse_Security_Status_Spot      = i.Status_Retdbt          ,
                 Bnse_Security_Status_Auct      = i.Status_Auction         ,
                 Bnse_Eligibility_Ol            = i.Elig_Oddlot            ,
                 Bnse_Eligibility_Spot          = i.Elig_Retdbt            ,
                 Bnse_Eligibility_Auct          = i.Elig_Auction           ,
                 Bnse_Permit_To_Trade           = i.Permit_To_Trade
          WHERE  Bnse_Internal_Security_Id      = i.Internal_Sec_Id
          AND    Bnse_Security_Id               = i.Nse_Sec_Id;

          IF SQL%FOUND THEN
            l_Updt_Nse := l_Updt_Nse + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            l_Str := ' Inserting NSE Data In Front Office For Security : ' || i.Internal_Sec_Id;
            INSERT INTO Bos_Nse_Security_Master
              (Bnse_Internal_Security_Id,    Bnse_Internal_Security_Name,    Bnse_Security_Abvn,
               Bnse_Isin_Code,               Bnse_Status,                    Bnse_Mkt_Settlement_Type,
               Bnse_Reuters_Code,            Bnse_Bloomberg_Code,            Bnse_Cusip,
               Bnse_Sedol,                   Bnse_Sector,                    Bnse_Security_Id,
               Bnse_Symbol,                  Bnse_Series,                    Bnse_Security_Name,
               Bnse_Regular_Lot,             Bnse_Tick_Size,                 Bnse_Aon_Allowed,
               Bnse_Min_Fill_Allowed,        Bnse_Deleted_Status,            Bnse_Participant_In_Index,
               Bnse_Instrument_Type,         Bnse_Issued_Capital,            Bnse_Freeze_Pct,
               Bnse_Credit_Rating,           Bnse_Issue_Rate,                Bnse_Issue_Start_Date,
               Bnse_Issue_Payment_Date,      Bnse_Issue_Maturity_Date,       Bnse_Listing_Date,
               Bnse_Expulsion_Date,          Bnse_Re_Admission_Date,         Bnse_Record_Date,
               Bnse_Ex_Date,                 Bnse_No_Delivery_Start_Date,    Bnse_No_Delivery_End_Date,
               Bnse_Book_Close_Start_Date,   Bnse_Book_Close_End_Date,       Bnse_Agm,
               Bnse_Egm,                     Bnse_Interest,                  Bnse_Dividend,
               Bnse_Bonus,                   Bnse_Rights,                    Bnse_Remarks,
               Bnse_Created_By,              Bnse_Created_Date,              Bnse_Update_By,
               Bnse_Update_Date,             Bnse_Face_Value,                Bnse_Security_Status_Nl,
               Bnse_Eligibility_Nl,          Bnse_Security_Status_Ol,        Bnse_Security_Status_Spot,
               Bnse_Security_Status_Auct,    Bnse_Eligibility_Ol,            Bnse_Eligibility_Spot,
               Bnse_Eligibility_Auct,        Bnse_Permit_To_Trade)
            VALUES
              (i.Internal_Sec_Id,           i.Security_Desc,               i.Security_Abbr,
               l_Isin,                      i.Status,                      i.Sett_Mkt_Type,
               i.Reuter_Cd,                 i.Bloomberg_Cd,                i.Cusip_Cd,
               i.Sedol_Cd,                  i.Sector,                      i.Nse_Sec_Id,
               i.Security_Symbol,           i.Exch_Sec_Series,             i.Security_Desc,
               i.Market_Lot,                i.Tick_Size,                   i.Aon_Allowed,
               i.Min_Fill_Allowed,          i.Deleted_Status,              i.Part_Mkt_Index,
               i.Instr_Type,                i.Issued_Capital,              i.Freeze_Percent,
               i.Credit_Rating,             i.Issue_Rate,                  i.Issue_Strt_Dt,
               i.Issue_Pmt_Dt,              i.Issue_Maturity_Dt,           i.Listing_Dt,
               i.Expulsion_Dt,              i.Re_Addmssn_Dt,               i.Record_Dt,
               i.Ex_Dt,                     i.Nd_Strt_Dt,                  i.Nd_End_Dt,
               i.Bk_Strt_Dt,                i.Bk_End_Dt,                   i.Agm,
               i.Egm,                       i.Interest,                    i.Dividend,
               i.Bonus,                     i.Rights,                      i.Remarks,
               i.Creat_By,                  i.Creat_Dt,                    i.Last_Updt_By,
               i.Last_Updt_Dt,              Round(i.Face_Value),           i.Status_Normal,
               i.Elig_Normal,               i.Status_Oddlot,               i.Status_Retdbt,
               i.Status_Auction,            i.Elig_Oddlot,                 i.Elig_Retdbt,
               i.Elig_Auction,              i.Permit_To_Trade);

            l_Insert_Nse := l_Insert_Nse + 1;
          END IF;

         EXCEPTION
          WHEN OTHERS THEN
            l_Success := 'N';
            l_Skipped_Nse := l_Skipped_Nse + 1;
            Utl_File.Put_Line(l_File_Handle,' Error While - '|| l_Str || ' - ' || SQLERRM);
            Utl_File.Fflush(l_File_Handle);
         END;

        l_Fetch_Nse := l_Fetch_Nse + 1;

      END LOOP;

      l_Str  := ' Fetching Data For BSE Security Master ';

      FOR j IN  C_Bse_Security_Master
      LOOP

        l_Str  := ' Getting ISIN For Security Id : ' || j.Internal_Sec_Id;
        l_Isin := NULL;
        IF j.Isin IS NULL THEN
          IF g_Tab_Isin.EXISTS(j.Internal_Sec_Id) THEN
            l_Isin := g_Tab_Isin(j.Internal_Sec_Id);
          ELSE
            l_Isin := 'DUMMY';
          END IF;
        ELSE
          l_Isin := j.Isin;
        END IF;

        BEGIN
          l_Str := ' Updating BSE Data In Front Office For Security Id : ' || j.Internal_Sec_Id;
          UPDATE Bos_Bse_Security_Master
          SET    Bbse_Internal_Security_Name = j.Security_Desc       ,
                 Bbse_Security_Abvn          = j.Security_Abbr       ,
                 Bbse_Isin_Code              = l_Isin                ,
                 Bbse_Status                 = j.Status              ,
                 Bbse_Suspension_Status      = j.Status              ,
                 Bbse_Mkt_Settlement_Type    = j.Sett_Mkt_Type       ,
                 Bbse_Reuters_Code           = j.Reuter_Cd           ,
                 Bbse_Sem_Bloomberg_Code     = j.Bloomberg_Cd        ,
                 Bbse_Cusip                  = j.Cusip_Cd            ,
                 Bbse_Sedol                  = j.Sedol_Cd            ,
                 Bbse_Sector                 = j.Sector              ,
                 Bbse_Scrip_Id               = j.Security_Abbr       ,
                 Bbse_Group                  = j.Bse_Group           ,
                 Bbse_Security_Name          = j.Security_Desc       ,
                 Bbse_Regular_Lot            = j.Market_Lot          ,
                 Bbse_Tick_Size              = j.Tick_Size           ,
                 Bbse_No_Delivery_Start_Date = j.Nd_Strt_Dt          ,
                 Bbse_No_Delivery_End_Date   = j.Nd_End_Dt           ,
                 Bbse_Book_Close_Start_Date  = j.Bk_Strt_Dt          ,
                 Bbse_Book_Close_End_Date    = j.Bk_End_Dt           ,
                 Bbse_Recorddate             = j.Record_Dt           ,
                 Bbse_Face_Value             = j.Face_Value
          WHERE  Bbse_Internal_Security_Id   = j.Internal_Sec_Id
          AND    Bbse_Security_Id            = j.Exch_Sec_Series;

          IF SQL%FOUND THEN
            l_Updt_Bse := l_Updt_Bse + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            l_Str := ' Inserting BSE Data In Front Office For Security : ' || j.Internal_Sec_Id;
            INSERT INTO Bos_Bse_Security_Master
              (Bbse_Internal_Security_Id,    Bbse_Internal_Security_Name,   Bbse_Security_Abvn,
               Bbse_Isin_Code,               Bbse_Status,                   Bbse_Mkt_Settlement_Type,
               Bbse_Reuters_Code,            Bbse_Sem_Bloomberg_Code,       Bbse_Cusip,
               Bbse_Sedol,                   Bbse_Sector,                   Bbse_Security_Id,
               Bbse_Scrip_Id,                Bbse_Group,                    Bbse_Security_Name,
               Bbse_Regular_Lot,             Bbse_Tick_Size,                Bbse_No_Delivery_Start_Date,
               Bbse_No_Delivery_End_Date,    Bbse_Book_Close_Start_Date,    Bbse_Book_Close_End_Date,
               Bbse_Recorddate,              Bbse_Face_Value,               Bbse_Suspension_Status)
            VALUES
              (j.Internal_Sec_Id,           j.Security_Desc,              j.Security_Abbr,
               l_Isin,                      j.Status,                     j.Sett_Mkt_Type,
               j.Reuter_Cd,                 j.Bloomberg_Cd,               j.Cusip_Cd,
               j.Sedol_Cd,                  j.Sector,                     j.Exch_Sec_Series,
               j.Security_Abbr,             j.Bse_Group,                  j.Security_Desc,
               j.Market_Lot,                Round(j.Tick_Size,2),         j.Nd_Strt_Dt,
               j.Nd_End_Dt,                 j.Bk_Strt_Dt,                 j.Bk_End_Dt,
               j.Record_Dt,                 Round(j.Face_Value),          j.Status);

            l_Insert_Bse := l_Insert_Bse + 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_Success := 'N';
            l_Skipped_Bse := l_Skipped_Bse + 1;
            Utl_File.Put_Line(l_File_Handle,' Error While - '|| l_Str || ' - ' || SQLERRM);
            Utl_File.Fflush(l_File_Handle);
        END;

        l_Fetch_Bse := l_Fetch_Bse + 1;

      END LOOP;*/

      L_STR := ' Fetching Data For Security Collateral Details ';
      FOR K IN SECURITY_COLLATERAL_DTLS LOOP

        BEGIN
          L_STR := ' Updating Security Collateral Data In Front Office For Security Id : ' ||
                   K.SECURITY_ID;
          UPDATE BOS_SECURITY_COLLATERAL_DTLS
             SET BSCD_ISIN_CODE          = K.ISIN,
                 BSCD_COLLATERAL_ALLOWED = K.COLLATERAL_ALLOWED,
                 BSCD_VALUATION_PERC     = K.VALUATION_PERC,
                 BSCD_BROKERWISE_MAX_LMT = K.BROKER_COLL_CAP,
                 BSCD_CLIENT_MAX_LMIT    = K.CLIENT_COLL_CAP
           WHERE BSCD_ISIN_CODE = K.ISIN;

          IF SQL%FOUND THEN
            L_UPDT_COLLATERAL := L_UPDT_COLLATERAL + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := ' Inserting Security Collateral Data In Front Office For Security : ' ||
                     K.SECURITY_ID;
            INSERT INTO BOS_SECURITY_COLLATERAL_DTLS
              (BSCD_ISIN_CODE,
               BSCD_COLLATERAL_ALLOWED,
               BSCD_VALUATION_PERC,
               BSCD_BROKERWISE_MAX_LMT,
               BSCD_CLIENT_MAX_LMIT)
            VALUES
              (K.ISIN,
               K.COLLATERAL_ALLOWED,
               K.VALUATION_PERC,
               K.BROKER_COLL_CAP,
               K.CLIENT_COLL_CAP);

            L_INSERT_COLLATERAL := L_INSERT_COLLATERAL + 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            L_SUCCESS            := 'N';
            L_SKIPPED_COLLATERAL := L_SKIPPED_COLLATERAL + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Error While - ' || L_STR || ' - ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        L_FETCH_COLLATERAL := L_FETCH_COLLATERAL + 1;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        L_SUCCESS := 'N';
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          ' Error While - ' || L_STR || ' - ' || SQLERRM);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;

    UPDATE PROGRAM_STATUS
       SET PRG_STATUS         = DECODE(L_SUCCESS, 'Y', 'C', 'E'),
           PRG_PARTIAL_RUN_YN = 'N',
           PRG_END_TIME       = SYSDATE,
           PRG_LAST_UPDT_BY   = USER,
           PRG_LAST_UPDT_DT   = SYSDATE
     WHERE PRG_DT = L_CURR_DATE
       AND PRG_PROCESS_ID = L_PRG_PROCESS_ID
       AND PRG_CMP_ID = L_PRG_ID;

    COMMIT;

    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for NSE : ' ||
                      L_FETCH_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for NSE : ' ||
                      L_INSERT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for NSE : ' || L_UPDT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for NSE : ' ||
                      L_SKIPPED_NSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for BSE : ' ||
                      L_FETCH_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for BSE : ' ||
                      L_INSERT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for BSE : ' || L_UPDT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for BSE : ' ||
                      L_SKIPPED_BSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for Collateral Upload : ' ||
                      L_FETCH_COLLATERAL);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for Collateral Upload : ' ||
                      L_INSERT_COLLATERAL);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for Collateral Upload : ' ||
                      L_UPDT_COLLATERAL);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for Collateral Upload : ' ||
                      L_SKIPPED_COLLATERAL);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Process Completed at ' ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.FCLOSE(L_FILE_HANDLE);

  END P_LOAD_SECURITY_MASTER_MTS;

  PROCEDURE P_LOAD_RDA_MTS(OUT_SUCCESS OUT VARCHAR2, OUT_NUM OUT NUMBER) IS

    L_RDA_ID          RISK_DISC_AGREEMENT.RDA_ID%TYPE;
    L_RDA_CONTENT     RISK_DISC_AGREEMENT.RDA_CONTENT%TYPE;
    L_RDA_UPLD_FOS_DT RISK_DISC_AGREEMENT.RDA_UPLD_FOS_DT%TYPE;
    L_RDA_FILE_NAME   RISK_DISC_AGREEMENT.RDA_FILE_NAME%TYPE;

    L_INSERT         NUMBER := 0;
    L_FETCH          NUMBER := 0;
    L_STATUS         PARAMETER_MASTER.PAM_STATUS%TYPE;
    L_CURR_DATE      PARAMETER_MASTER.PAM_CURR_DT%TYPE;
    L_PRG_ID         VARCHAR2(15) := 'CSSBRDAUP';
    L_PRG_PROCESS_ID NUMBER := 0;
    L_FILE_HANDLE    UTL_FILE.FILE_TYPE;
    L_LOG_ENV        VARCHAR2(100);

    L_FILE_NAME       VARCHAR2(70) := 'CSSBRDAUP';
    L_DESC            VARCHAR2(300);
    L_IND             NUMBER := 0;
    L_FLAG            NUMBER := 0;
    L_REC_COUNT       NUMBER := 0;
    L_LOD_SEQ         LOAD_CONTROLS.LOD_SEQ %TYPE;
    L_F_DTM_FMT_Q     VARCHAR2(16) := 'YYYYMMDDHH24MISS';
    L_FIRST_LOAD_TIME VARCHAR2(16) := '19000101000000';
    L_LAST_LOAD_TIME  VARCHAR2(16);

  BEGIN
    BEGIN
      OUT_NUM := 0;

      L_IND := 10;
      SELECT RV_LOW_VALUE
        INTO L_LOG_ENV
        FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'EBOS_LOG_PATH';

      L_FILE_NAME   := L_FILE_NAME || '_' ||
                       TO_CHAR(SYSDATE, 'ddmmyyyyhhmi') || '.LOG';
      L_FILE_HANDLE := UTL_FILE.FOPEN(L_LOG_ENV, L_FILE_NAME, 'A');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        '**********Log Status For Risk Disclosure Agreement Download to MTS Tables (HH:Min:Sec)' ||
                        TO_CHAR(SYSDATE, 'hh24:mi:ss') || '***************');
      UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                        'User: ' || USER || '      ' || 'Date: ' || SYSDATE);
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'Process started');
      UTL_FILE.FFLUSH(L_FILE_HANDLE);
      L_IND := 6;
      SELECT PAM_STATUS, PAM_CURR_DT
        INTO L_STATUS, L_CURR_DATE
        FROM PARAMETER_MASTER;
      IF (L_STATUS = 'C') THEN
        UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'The System is Closed');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        L_FLAG := 1;
      END IF;

      BEGIN
        SELECT NVL(TO_CHAR(MAX(LOD_START_TIME), L_F_DTM_FMT_Q),
                   L_FIRST_LOAD_TIME)
          INTO L_LAST_LOAD_TIME
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND LOD_STATUS = 'C';
      END;

      L_IND := 8;
      SELECT COUNT(*)
        INTO L_REC_COUNT
        FROM RISK_DISC_AGREEMENT
       WHERE RDA_UPLD_FOS_FL <> 'Y';

      IF (L_REC_COUNT = 0) THEN
        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'No records to be uploaded to MTS');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        L_FLAG := 1;
      END IF;

      --insert record into program status
      L_IND := 21;
      SELECT NVL(MAX(PRG_PROCESS_ID) + 1, 1)
        INTO L_PRG_PROCESS_ID
        FROM PROGRAM_STATUS
       WHERE PRG_CMP_ID = L_PRG_ID
         AND PRG_DT = L_CURR_DATE;

      BEGIN
        L_IND := 7;

        INSERT INTO PROGRAM_STATUS
          (PRG_CMP_ID,
           PRG_DT,
           PRG_PROCESS_ID,
           PRG_STATUS,
           PRG_STRT_TIME,
           PRG_STATUS_FILE,
           PRG_LOG_FILE,
           PRG_PARAMETERS,
           PRG_EXM_ID,
           PRG_CREAT_BY,
           PRG_CREAT_DT)
        VALUES
          (L_PRG_ID,
           L_CURR_DATE,
           L_PRG_PROCESS_ID,
           'R',
           SYSDATE,
           'No Status FILE',
           L_LOG_ENV || L_FILE_NAME,
           NULL,
           'ALL',
           USER,
           SYSDATE);

        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                            'Error while inserting records into Program Status:' ||
                            SQLCODE || '-' || SQLERRM);
          UTL_FILE.FFLUSH(L_FILE_HANDLE);
          L_FLAG := 1;
      END;

      BEGIN
        --get max seq no for today
        L_IND := 16;
        SELECT (NVL(MAX(LOD_SEQ), 0)) + 1
          INTO L_LOD_SEQ
          FROM LOAD_CONTROLS
         WHERE LOD_CMP_ID = L_PRG_ID
           AND TRUNC(LOD_DT) = TRUNC(L_CURR_DATE);

        --insert record into load_controls
        BEGIN
          L_IND := 15;

          INSERT INTO LOAD_CONTROLS
            (LOD_DT,
             LOD_STATUS,
             LOD_SEQ,
             LOD_START_TIME,
             LOD_PROCESS_ID,
             LOD_CMP_ID,
             LOD_CREAT_BY,
             LOD_CREAT_DT)
          VALUES
            (TRUNC(L_CURR_DATE),
             'R',
             L_LOD_SEQ,
             SYSDATE,
             L_PRG_PROCESS_ID,
             L_PRG_ID,
             USER,
             SYSDATE);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while inserting records into Load Controls:' ||
                              SQLCODE || '-' || SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
            L_FLAG := 1;
        END;
      END;

      IF L_FLAG = 0 THEN
        BEGIN
          L_IND := 1;
          SET TRANSACTION USE ROLLBACK SEGMENT BIG_RBS;
        END;

        IF L_REC_COUNT > 0 THEN
          BEGIN
            L_IND             := 3;
            L_RDA_UPLD_FOS_DT := SYSDATE;

            INSERT INTO BOS_DISCLAIMER_CONTENT
              (BDC_ID,
               BDC_CONTENT,
               BDC_UPDATED_DATE,
               BDC_UPDATED_BY,
               BDC_DETAIL,
               BDC_FROM_DT,
               BDC_TO_DT)

              SELECT RDA_ID,
                     RDA_CONTENT,
                     SYSDATE,
                     USER,
                     RDA_FILE_NAME,
                     RDA_FROM_DT,
                     RDA_TO_DT
                FROM RISK_DISC_AGREEMENT
               WHERE RDA_UPLD_FOS_FL <> 'Y';

            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Risk Disclosure Agreement is Successfully Inserted into MTS');
            UTL_FILE.FFLUSH(L_FILE_HANDLE);

            L_IND := 22;
            UPDATE RISK_DISC_AGREEMENT R
               SET R.RDA_UPLD_FOS_FL  = 'Y',
                   R.RDA_UPLD_FOS_DT  = SYSDATE,
                   R.RDA_LAST_UPDT_DT = SYSDATE,
                   R.RDA_LAST_UPDT_BY = USER,
                   R.RDA_PRG_ID       = L_PRG_ID
             WHERE RDA_UPLD_FOS_FL <> 'Y';

            L_IND := 23;
            UPDATE ENTITY_MASTER E
               SET E.ENT_DISCLOSURE_DT = NULL,
                   E.ENT_RDA_SIGN_BY   = NULL,
                   E.ENT_PRG_ID        = L_PRG_ID;

            L_IND := 24;
            UPDATE ENTITY_MASTER_INT EI
               SET EI.ENT_DISCLOSURE_DT = NULL,
                   EI.ENT_RDA_SIGN_BY   = NULL,
                   EI.ENT_LAST_UPDT_BY  = USER,
                   EI.ENT_LAST_UPDT_DT  = SYSDATE,
                   EI.ENT_PRG_ID        = L_PRG_ID
             WHERE EI.ENT_REC_STATUS = 'P';

            COMMIT;

          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                L_RDA_ID ||
                                'This Risk Disclosure Agreement Id is Already Inserted into MTS');
              UTL_FILE.FFLUSH(L_FILE_HANDLE);
              L_FLAG := 1;

            WHEN OTHERS THEN
              IF L_IND = 22 THEN
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  L_RDA_ID ||
                                  'Error while updating Risk Disclosure Agreement');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
                L_FLAG := 1;
              ELSIF L_IND = 23 THEN
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  L_RDA_ID ||
                                  'Error while updating the Entity Master');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
                L_FLAG := 1;
              ELSIF L_IND = 24 THEN
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  L_RDA_ID ||
                                  'Error while updating the Entity Master Int');
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
                L_FLAG := 1;
              ELSE
                UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                                  'Error while inserting the records : ' ||
                                  SQLERRM(SQLCODE));
                UTL_FILE.FFLUSH(L_FILE_HANDLE);
                L_FLAG := 1;
              END IF;
          END;
        END IF;

        BEGIN
          L_IND := 5;
        END;
        COMMIT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        OUT_SUCCESS := 'N';
        IF L_IND = 1 THEN
          L_DESC := 'Error while opening the cursor' || SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 2 THEN
          L_DESC := 'Error while fetching the cursor' || SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 3 THEN
          L_DESC := 'Error while inserting the records in MTS table' ||
                    SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 5 THEN
          L_DESC := 'Error while Closing the Cursor' || SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 6 THEN
          L_DESC := 'The System is Closed';
          L_FLAG := 1;
        ELSIF L_IND = 7 THEN
          L_DESC := 'Error while inserting the records in Program Status table' ||
                    SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 8 THEN
          L_DESC := 'Error while getting the count of records to be uploaded to MTS' ||
                    SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 10 THEN
          OUT_NUM := 10;
          L_FLAG  := 1;
        ELSIF L_IND = 15 THEN
          L_DESC := 'Error while inserting the records in Load Controls table' ||
                    SQLERRM;
          L_FLAG := 1;
        ELSIF L_IND = 16 THEN
          L_DESC := 'Error while selecting the load sequence from Load Controls table' ||
                    SQLERRM;
          L_FLAG := 1;
        END IF;

        UTL_FILE.PUT_LINE(L_FILE_HANDLE, L_DESC);
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
    END;

    IF L_FLAG = 0 THEN
      BEGIN
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'C',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_CMP_ID = L_PRG_ID
             AND PRG_DT = L_CURR_DATE
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating program status for Success' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'C',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_PROCESS_ID = L_PRG_PROCESS_ID
             AND LOD_CMP_ID = L_PRG_ID
             AND TRUNC(LOD_DT) = TRUNC(L_CURR_DATE);

        EXCEPTION
          WHEN OTHERS THEN
            OUT_SUCCESS := 'N';
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating Load Controls for Success' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of inserting MTS tables successfully completed');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
        OUT_SUCCESS := 'Y';

      END;
    END IF;

    IF L_FLAG = 1 THEN
      OUT_SUCCESS := 'N';
      BEGIN
        ROLLBACK;
        BEGIN
          UPDATE PROGRAM_STATUS
             SET PRG_STATUS       = 'E',
                 PRG_END_TIME     = SYSDATE,
                 PRG_LAST_UPDT_BY = USER,
                 PRG_LAST_UPDT_DT = SYSDATE
           WHERE PRG_CMP_ID = L_PRG_ID
             AND PRG_DT = L_CURR_DATE
             AND PRG_PROCESS_ID = L_PRG_PROCESS_ID;

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the program status for Error' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        --update load control
        BEGIN
          UPDATE LOAD_CONTROLS
             SET LOD_STATUS      = 'E',
                 LOD_TOTAL_RECS  = L_FETCH,
                 LOD_END_TIME    = SYSDATE,
                 LOD_LAST_UPD_BY = USER,
                 LOD_LAST_UPD_DT = SYSDATE
           WHERE LOD_PROCESS_ID = L_PRG_PROCESS_ID
             AND LOD_CMP_ID = L_PRG_ID
             AND TRUNC(LOD_DT) = TRUNC(L_CURR_DATE);

        EXCEPTION
          WHEN OTHERS THEN
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              'Error while updating the Load Controls for Error' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

        UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                          'Process of inserting Risk Disclosure Agreement to MTS Unsuccessful');
        UTL_FILE.FFLUSH(L_FILE_HANDLE);
        UTL_FILE.FCLOSE_ALL;
        COMMIT;
      END;
    END IF;

  END P_LOAD_RDA_MTS;

  PROCEDURE P_LOAD_NAV_MASTER_MTS IS

    L_CURR_DATE      DATE;
    L_PRG_PROCESS_ID NUMBER := 0;
    L_INSERT_NSE     NUMBER := 0;
    L_INSERT_BSE     NUMBER := 0;
    L_UPDT_NSE       NUMBER := 0;
    L_UPDT_BSE       NUMBER := 0;
    L_FETCH_NSE      NUMBER := 0;
    L_FETCH_BSE      NUMBER := 0;
    L_SKIPPED_NSE    NUMBER := 0;
    L_SKIPPED_BSE    NUMBER := 0;
    L_SUCCESS        VARCHAR2(1) := 'Y';
    L_ISIN           VARCHAR2(30);
    L_PRG_ID         VARCHAR2(30) := 'CSSNAVUP';
    L_FILE_NAME      VARCHAR2(100);
    L_STR            VARCHAR2(32767);
    L_FILE_HANDLE    UTL_FILE.FILE_TYPE;

    CURSOR C_LOAD_NAV_MASTER IS
      SELECT M.NAV_SECURITY_ID,
             M.NAV_DATE,
             M.NAV_SYMBOL,
             M.NAV_SERIES,
             M.NAV_SCHEME_CODE,
             M.NAV_SCHEME_NAME,
             M.NAV_CATEGORY_CODE,
             M.NAV_CATEGORY_NAME,
             M.NAV_RTA_SCHEME_CODE,
             M.NAV_DIVIDEND_REINVEST_FLAG,
             M.NAV_RTA_CODE,
             M.NAV_ISIN,
             M.NAV_VALUE,
             M.NAV_EXCH_ID
        FROM MFSS_NAV M;

  BEGIN

    L_STR := ' Performing Housekeeping Functions ';
    STD_LIB.P_HOUSEKEEPING(L_PRG_ID,
                           'ALL',
                           'ALL',
                           'B',
                           L_FILE_HANDLE,
                           L_FILE_NAME,
                           L_PRG_PROCESS_ID);

    L_CURR_DATE := STD_LIB.L_PAM_CURR_DATE;

    DELETE FROM BOS_NSE_NAV_MASTER;
    DELETE FROM BOS_BSE_NAV_MASTER;

    FOR I IN C_LOAD_NAV_MASTER LOOP

      IF (I.NAV_EXCH_ID = 'NSE') THEN

        BEGIN
          L_STR := 'Updating NSE Data for NAV ID : ' || I.NAV_SECURITY_ID ||
                   ' And  ISIN : ' || I.NAV_ISIN;
          UPDATE BOS_NSE_NAV_MASTER
             SET BNNM_NAV_DATE      = I.NAV_DATE,
                 BNNM_SYMBOL        = I.NAV_SYMBOL,
                 BNNM_SERIES        = I.NAV_SERIES,
                 BNNM_SCHEMENAME    = I.NAV_SCHEME_NAME,
                 BNNM_CATEGORY_CODE = I.NAV_CATEGORY_CODE,
                 BNNM_CATEGORY_NAME = I.NAV_CATEGORY_NAME,
                 BNNM_ISIN          = I.NAV_ISIN,
                 BNNM_NAV_VALUE     = I.NAV_VALUE
           WHERE BNNM_ISIN = I.NAV_ISIN;

          IF SQL%FOUND THEN
            L_UPDT_NSE := L_UPDT_NSE + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := 'Inserting NSE Data for NAV ID : ' ||
                     I.NAV_SECURITY_ID || ' And  ISIN : ' || I.NAV_ISIN;
            INSERT INTO BOS_NSE_NAV_MASTER
              (BNNM_NAV_DATE,
               BNNM_SYMBOL,
               BNNM_SERIES,
               BNNM_SCHEMENAME,
               BNNM_CATEGORY_CODE,
               BNNM_CATEGORY_NAME,
               BNNM_ISIN,
               BNNM_NAV_VALUE)
            VALUES
              (I.NAV_DATE,
               I.NAV_SYMBOL,
               I.NAV_SERIES,
               I.NAV_SCHEME_NAME,
               I.NAV_CATEGORY_CODE,
               I.NAV_CATEGORY_NAME,
               I.NAV_ISIN,
               I.NAV_VALUE);

            L_INSERT_NSE := L_INSERT_NSE + 1;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            L_SUCCESS     := 'N';
            L_SKIPPED_NSE := L_SKIPPED_NSE + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Error While - ' || L_STR || ' - ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

      ELSIF (I.NAV_EXCH_ID = 'BSE') THEN

        BEGIN
          L_STR := 'Updating BSE Data for NAV ID : ' || I.NAV_SECURITY_ID ||
                   ' And  ISIN : ' || I.NAV_ISIN;
          UPDATE BOS_BSE_NAV_MASTER
             SET BBNM_DATE                  = I.NAV_DATE,
                 BBNM_SCHEMECODE            = I.NAV_SCHEME_CODE,
                 BBNM_SCHEMENAME            = I.NAV_SCHEME_NAME,
                 BBNM_RTASCHEMECODE         = I.NAV_RTA_SCHEME_CODE,
                 BBNM_DIVIDEND_REINVESTFLAG = I.NAV_DIVIDEND_REINVEST_FLAG,
                 BBNM_ISIN                  = I.NAV_ISIN,
                 BBNM_VALUE                 = I.NAV_VALUE,
                 BBNM_RTA_CODE              = I.NAV_RTA_CODE
           WHERE BBNM_ISIN = I.NAV_ISIN;

          IF SQL%FOUND THEN
            L_UPDT_BSE := L_UPDT_BSE + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := 'Inserting BSE Data for NAV ID : ' ||
                     I.NAV_SECURITY_ID || ' And  ISIN : ' || I.NAV_ISIN;
            INSERT INTO BOS_BSE_NAV_MASTER
              (BBNM_DATE,
               BBNM_SCHEMECODE,
               BBNM_SCHEMENAME,
               BBNM_RTASCHEMECODE,
               BBNM_DIVIDEND_REINVESTFLAG,
               BBNM_ISIN,
               BBNM_VALUE,
               BBNM_RTA_CODE)
            VALUES
              (I.NAV_DATE,
               I.NAV_SCHEME_CODE,
               I.NAV_SCHEME_NAME,
               I.NAV_RTA_SCHEME_CODE,
               I.NAV_DIVIDEND_REINVEST_FLAG,
               I.NAV_ISIN,
               I.NAV_VALUE,
               I.NAV_RTA_CODE);

            L_INSERT_BSE := L_INSERT_BSE + 1;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            L_SUCCESS     := 'N';
            L_SKIPPED_BSE := L_SKIPPED_BSE + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Error While - ' || L_STR || ' - ' ||
                              SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

      END IF;

    END LOOP;

    UPDATE PROGRAM_STATUS
       SET PRG_STATUS         = DECODE(L_SUCCESS, 'Y', 'C', 'E'),
           PRG_PARTIAL_RUN_YN = 'N',
           PRG_END_TIME       = SYSDATE,
           PRG_LAST_UPDT_BY   = USER,
           PRG_LAST_UPDT_DT   = SYSDATE
     WHERE PRG_DT = L_CURR_DATE
       AND PRG_PROCESS_ID = L_PRG_PROCESS_ID
       AND PRG_CMP_ID = L_PRG_ID;

    COMMIT;

    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for NSE : ' ||
                      L_FETCH_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for NSE : ' ||
                      L_INSERT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for NSE : ' || L_UPDT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for NSE : ' ||
                      L_SKIPPED_NSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for BSE : ' ||
                      L_FETCH_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for BSE : ' ||
                      L_INSERT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for BSE : ' || L_UPDT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for BSE : ' ||
                      L_SKIPPED_BSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Process Completed at ' ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.FCLOSE(L_FILE_HANDLE);

  END P_LOAD_NAV_MASTER_MTS;

  PROCEDURE P_LOAD_SCHEME_MASTER_MTS IS

    L_CURR_DATE      DATE;
    L_PRG_PROCESS_ID NUMBER := 0;
    L_INSERT_NSE     NUMBER := 0;
    L_INSERT_BSE     NUMBER := 0;
    L_UPDT_NSE       NUMBER := 0;
    L_UPDT_BSE       NUMBER := 0;
    L_FETCH_NSE      NUMBER := 0;
    L_FETCH_BSE      NUMBER := 0;
    L_SKIPPED_NSE    NUMBER := 0;
    L_SKIPPED_BSE    NUMBER := 0;
    L_SUCCESS        VARCHAR2(1) := 'Y';
    L_ISIN           VARCHAR2(30);
    L_PRG_ID         VARCHAR2(30) := 'CSSSHEUP';
    L_FILE_NAME      VARCHAR2(100);
    L_STR            VARCHAR2(32767);
    L_FILE_HANDLE    UTL_FILE.FILE_TYPE;

    /* CURSOR C_LOAD_SCHEME_MASTER IS
    SELECT SCM_UNIQUE_NO,
           SCM_EXCH_ID,
           SCM_SCHEME_CODE,
           SCM_SYMBOL,
           SCM_SERIES,
           SCM_SECURITY_ID,
           SCM_INSTRUMENT_TYPE,
           SCM_QUANTITY_LIMIT,
           SCM_SCHEMES_DEPOSITORY_DETAILS,
           SCM_RTA_SCHEME_CODE,
           SCM_AMC_SCHEME_CODE,
           SCM_ISIN,
           SCM_FOLIO_LENGTH,
           SCM_SEC_STATUS_NORMAL_MKT,
           SCM_ELIGIBILITY_NORMAL_MKT,
           SCM_SEC_STATUS_ODD_LOT_MKT,
           SCM_ELIGIBILITY_ODD_LOT_MKT,
           SCM_SEC_STATUS_SPOT_MKT,
           SCM_ELIGIBILITY_SPOT_MKT,
           SCM_SEC_STATUS_AUCTION_MKT,
           SCM_ELIGIBILITY_AUCTION_MKT,
           SCM_AMC_CODE,
           SCM_CATEGORY_CODE,
           SCM_SCHEME_NAME,
           SCM_ISSUE_RATE,
           SCM_MIN_SUBSCRIPTION_ADD,
           SCM_BUY_NAV_PRICE,
           SCM_SELL_NAV_PRICE,
           SCM_RTA_AGENT_CODE,
           SCM_VAL_DECIMAL_INDICATOR,
           SCM_CATEGORY_START_TIME,
           SCM_QTY_DECIMAL_INDICATOR,
           SCM_CATEGORY_END_TIME,
           SCM_MIN_SUBSCRIPTION_FRESH,
           SCM_VALUE_LIMIT,
           SCM_RECORD_DATE,
           SCM_EX_DATE,
           SCM_NAV_DATE,
           SCM_NO_DELIVERY_END_DATE,
           SCM_ST_ELG_PART_IN_MKT_INDEX,
           SCM_ST_ELIGIBLE_AON,
           SCM_ST_ELIGIBLE_MIN_FILL,
           SCM_SEC_DEP_MANDATORY,
           SCM_SEC_DIVIDEND,
           SCM_SEC_ALLOW_DEP,
           SCM_SEC_ALLOW_SELL,
           SCM_SEC_MOD_CXL,
           SCM_SEC_ALLOW_BUY,
           SCM_BOOK_CLOSURE_DATE_START,
           SCM_BOOK_CLOSURE_DATE_END,
           SCM_DIVIDEND,
           SCM_RIGHTS,
           SCM_BONUS,
           SCM_INTEREST,
           SCM_AGM,
           SCM_EGM,
           SCM_OTHER,
           SCM_LOCAL_UPDATE_DATE_TIME,
           SCM_DELETE_FLAG,
           SCM_REMARKS,
           SCM_PURCHASE_TRANSACTION_MODE,
           SCM_MINIMUM_PURCHASE_AMOUNT,
           SCM_ADD_PURCHASE_AMT_MULTIPLE,
           SCM_MAXIMUM_PURCHASE_AMOUNT,
           SCM_PURCHASE_ALLOWED,
           SCM_PURCHASE_CUTOFF_TIME,
           SCM_REDEMPTION_TRANS_MODE,
           SCM_MINIMUM_REDEMPTION_QTY,
           SCM_REDEMPTION_QTY_MULTIPLIER,
           SCM_MAXIMUM_REDEMPTION_QTY,
           SCM_REDEMPTION_ALLOWED,
           SCM_REDEMPTION_CUTOFF_TIME,
           SCM_AMC_ACTIVE_FLAG,
           SCM_DIVIDEND_REINVEST_FLAG,
           SCM_SCHEME_TYPE,
           SCM_CREAT_BY,
           SCM_CREAT_DT,
           SCM_LAST_UPDT_BY,
           SCM_LAST_UPDT_DT,
           SCM_PRG_ID,
           SCM_FOS_ID,
           SCM_SIP_FLAG,
           SCM_STP_FLAG,
           SCM_SWP_FLAG,
           SCM_SETTLEMENT_TYPE
      FROM MFSS_SCHEMES_MASTER MS;*/

  BEGIN

    L_STR := ' Performing Housekeeping Functions ';
    STD_LIB.P_HOUSEKEEPING(L_PRG_ID,
                           'ALL',
                           'ALL',
                           'B',
                           L_FILE_HANDLE,
                           L_FILE_NAME,
                           L_PRG_PROCESS_ID);

    L_CURR_DATE := STD_LIB.L_PAM_CURR_DATE;

    --DELETE FROM BOS_NSE_SCHEME_MASTER;
    --DELETE FROM BOS_BSE_SCHEME_MASTER;

    /*FOR I IN C_LOAD_SCHEME_MASTER LOOP

      IF (I.SCM_EXCH_ID = 'NSE') THEN

        BEGIN
          L_STR := 'Updating NSE Data for SCHEME ---  Security ID : ' ||
                   I.SCM_SECURITY_ID || ' And  ISIN : ' || I.SCM_ISIN;

          UPDATE BOS_NSE_SCHEME_MASTER
             SET BNSM_INTERNAL_SECID          = I.SCM_SECURITY_ID,
                 BNSM_TOKEN                   = I.SCM_UNIQUE_NO,
                 BNSM_SYMBOL                  = I.SCM_SYMBOL,
                 BNSM_SERIES                  = I.SCM_SERIES,
                 BNSM_INSTRUMENTTYPE          = I.SCM_INSTRUMENT_TYPE,
                 BNSM_QUANTITYLIMIT           = I.SCM_QUANTITY_LIMIT,
                 BNSM_RTSCHEMECODE            = I.SCM_RTA_SCHEME_CODE,
                 BNSM_AMCSCHEMECODE           = I.SCM_AMC_SCHEME_CODE,
                 BNSM_SCHMES_DP_DETAILS       = I.SCM_SCHEMES_DEPOSITORY_DETAILS,
                 BNSM_ISIN_CODE               = I.SCM_ISIN,
                 BNSM_FOLIO_LENGTH            = I.SCM_FOLIO_LENGTH,
                 BNSM_SECURITY_STATUS_NL      = I.SCM_SEC_STATUS_NORMAL_MKT,
                 BNSM_ELIGIBILITY_NL          = I.SCM_ELIGIBILITY_NORMAL_MKT,
                 BNSM_SECURITY_STATUS_OL      = I.SCM_SEC_STATUS_ODD_LOT_MKT,
                 BNSM_ELIGIBILITY_OL          = I.SCM_ELIGIBILITY_ODD_LOT_MKT,
                 BNSM_SECURITY_STATUS_SPOT    = I.SCM_SEC_STATUS_SPOT_MKT,
                 BNSM_ELIGIBILITY_SPOT        = I.SCM_ELIGIBILITY_SPOT_MKT,
                 BNSM_SECURITY_STATUS_AU      = I.SCM_SEC_STATUS_AUCTION_MKT,
                 BNSM_ELIGIBILITY_AU          = I.SCM_ELIGIBILITY_AUCTION_MKT,
                 BNSM_AMC_CODE                = I.SCM_AMC_CODE,
                 BNSM_CATEGORY_CODE           = I.SCM_CATEGORY_CODE,
                 BNSM_NAME                    = I.SCM_SCHEME_NAME,
                 BNSM_ISSUERATE               = I.SCM_ISSUE_RATE,
                 BNSM_MINSUBSCRADDL           = I.SCM_MIN_SUBSCRIPTION_ADD,
                 BNSM_BUY_NAVPRICE            = I.SCM_BUY_NAV_PRICE,
                 BNSM_SELL_NAVPRICE           = I.SCM_SELL_NAV_PRICE,
                 BNSM_RT_AGENTCODE            = I.SCM_RTA_AGENT_CODE,
                 BNSM_VALDEC_INDICATOR        = I.SCM_VAL_DECIMAL_INDICATOR,
                 BNSM_CAT_STARTTIME           = I.SCM_CATEGORY_START_TIME,
                 BNSM_QTYDECINDICATOR         = I.SCM_QTY_DECIMAL_INDICATOR,
                 BNSM_CAT_ENDTIME             = I.SCM_CATEGORY_END_TIME,
                 BNSM_MIN_SUBSCR_FRESH        = I.SCM_MIN_SUBSCRIPTION_FRESH,
                 BNSM_VALUELIMIT              = I.SCM_VALUE_LIMIT,
                 BNSM_RECORD_DATE             = I.SCM_RECORD_DATE,
                 BNSM_EX_DATE                 = I.SCM_EX_DATE,
                 BNSM_NAVDATE                 = I.SCM_NAV_DATE,
                 BNSM_NO_DELIVERY_END_DATE    = I.SCM_NO_DELIVERY_END_DATE,
                 BNSM_ST_ELIG_PARTI_MKT_INDEX = I.SCM_ST_ELG_PART_IN_MKT_INDEX,
                 BNSM_ST_ELIGIBLE_AON         = I.SCM_ST_ELIGIBLE_AON,
                 BNSM_ST_ELIGIBLE_MIN_FILL    = I.SCM_ST_ELIGIBLE_MIN_FILL,
                 BNSM_SEC_DEPMANDATORY        = I.SCM_SEC_DEP_MANDATORY,
                 BNSM_SECDIVIDEND             = I.SCM_SEC_DIVIDEND,
                 BNSM_SECALLOWDEP             = I.SCM_SEC_ALLOW_DEP,
                 BNSM_SECALLOWSELL            = I.SCM_SEC_ALLOW_SELL,
                 BNSM_SECMODCXL               = I.SCM_SEC_MOD_CXL,
                 BNSM_SECALLOWBUY             = I.SCM_SEC_ALLOW_BUY,
                 BNSM_BOOK_CLOSURE_START      = I.SCM_BOOK_CLOSURE_DATE_START,
                 BNSM_BOOK_CLOSURE_END        = I.SCM_BOOK_CLOSURE_DATE_END,
                 BNSM_DIVIDEND                = I.SCM_DIVIDEND,
                 BNSM_RIGHTS                  = I.SCM_RIGHTS,
                 BNSM_BONUS                   = I.SCM_BONUS,
                 BNSM_INTEREST                = I.SCM_INTEREST,
                 BNSM_AGM                     = I.SCM_AGM,
                 BNSM_EGM                     = I.SCM_EGM,
                 BNSM_OTHER                   = I.SCM_OTHER,
                 BNSM_LOCAL_UPDATEDATETIME    = I.SCM_LOCAL_UPDATE_DATE_TIME,
                 BNSM_DELETEFLAG              = I.SCM_DELETE_FLAG,
                 BNSM_REMARK                  = I.SCM_REMARKS,
                 BNSM_STATUS                  = I.SCM_AMC_ACTIVE_FLAG,
                 BNSM_SCHEME_TYPE             = I.SCM_SCHEME_TYPE

           WHERE BNSM_TOKEN = I.SCM_UNIQUE_NO;

          IF SQL%FOUND THEN
            L_UPDT_NSE := L_UPDT_NSE + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := 'Inserting NSE Data for Scheme ----  Security ID : ' ||
                     I.SCM_SECURITY_ID || ' And  ISIN : ' || I.SCM_ISIN;

            INSERT INTO BOS_NSE_SCHEME_MASTER
              (BNSM_INTERNAL_SECID,
               BNSM_TOKEN,
               BNSM_SYMBOL,
               BNSM_SERIES,
               BNSM_INSTRUMENTTYPE,
               BNSM_QUANTITYLIMIT,
               BNSM_RTSCHEMECODE,
               BNSM_AMCSCHEMECODE,
               BNSM_SCHMES_DP_DETAILS,
               BNSM_ISIN_CODE,
               BNSM_FOLIO_LENGTH,
               BNSM_SECURITY_STATUS_NL,
               BNSM_ELIGIBILITY_NL,
               BNSM_SECURITY_STATUS_OL,
               BNSM_ELIGIBILITY_OL,
               BNSM_SECURITY_STATUS_SPOT,
               BNSM_ELIGIBILITY_SPOT,
               BNSM_SECURITY_STATUS_AU,
               BNSM_ELIGIBILITY_AU,
               BNSM_AMC_CODE,
               BNSM_CATEGORY_CODE,
               BNSM_NAME,
               BNSM_ISSUERATE,
               BNSM_MINSUBSCRADDL,
               BNSM_BUY_NAVPRICE,
               BNSM_SELL_NAVPRICE,
               BNSM_RT_AGENTCODE,
               BNSM_VALDEC_INDICATOR,
               BNSM_CAT_STARTTIME,
               BNSM_QTYDECINDICATOR,
               BNSM_CAT_ENDTIME,
               BNSM_MIN_SUBSCR_FRESH,
               BNSM_VALUELIMIT,
               BNSM_RECORD_DATE,
               BNSM_EX_DATE,
               BNSM_NAVDATE,
               BNSM_NO_DELIVERY_END_DATE,
               BNSM_ST_ELIG_PARTI_MKT_INDEX,
               BNSM_ST_ELIGIBLE_AON,
               BNSM_ST_ELIGIBLE_MIN_FILL,
               BNSM_SEC_DEPMANDATORY,
               BNSM_SECDIVIDEND,
               BNSM_SECALLOWDEP,
               BNSM_SECALLOWSELL,
               BNSM_SECMODCXL,
               BNSM_SECALLOWBUY,
               BNSM_BOOK_CLOSURE_START,
               BNSM_BOOK_CLOSURE_END,
               BNSM_DIVIDEND,
               BNSM_RIGHTS,
               BNSM_BONUS,
               BNSM_INTEREST,
               BNSM_AGM,
               BNSM_EGM,
               BNSM_OTHER,
               BNSM_LOCAL_UPDATEDATETIME,
               BNSM_DELETEFLAG,
               BNSM_REMARK,
               BNSM_STATUS,
               BNSM_SCHEME_TYPE)
            VALUES
              (I.SCM_SECURITY_ID,
               I.SCM_UNIQUE_NO,
               I.SCM_SYMBOL,
               I.SCM_SERIES,
               I.SCM_INSTRUMENT_TYPE,
               I.SCM_QUANTITY_LIMIT,
               I.SCM_RTA_SCHEME_CODE,
               I.SCM_AMC_SCHEME_CODE,
               I.SCM_SCHEMES_DEPOSITORY_DETAILS,
               I.SCM_ISIN,
               I.SCM_FOLIO_LENGTH,
               I.SCM_SEC_STATUS_NORMAL_MKT,
               I.SCM_ELIGIBILITY_NORMAL_MKT,
               I.SCM_SEC_STATUS_ODD_LOT_MKT,
               I.SCM_ELIGIBILITY_ODD_LOT_MKT,
               I.SCM_SEC_STATUS_SPOT_MKT,
               I.SCM_ELIGIBILITY_SPOT_MKT,
               I.SCM_SEC_STATUS_AUCTION_MKT,
               I.SCM_ELIGIBILITY_AUCTION_MKT,
               I.SCM_AMC_CODE,
               I.SCM_CATEGORY_CODE,
               I.SCM_SCHEME_NAME,
               I.SCM_ISSUE_RATE,
               I.SCM_MIN_SUBSCRIPTION_ADD,
               I.SCM_BUY_NAV_PRICE,
               I.SCM_SELL_NAV_PRICE,
               I.SCM_RTA_AGENT_CODE,
               I.SCM_VAL_DECIMAL_INDICATOR,
               I.SCM_CATEGORY_START_TIME,
               I.SCM_QTY_DECIMAL_INDICATOR,
               I.SCM_CATEGORY_END_TIME,
               I.SCM_MIN_SUBSCRIPTION_FRESH,
               I.SCM_VALUE_LIMIT,
               I.SCM_RECORD_DATE,
               I.SCM_EX_DATE,
               I.SCM_NAV_DATE,
               I.SCM_NO_DELIVERY_END_DATE,
               I.SCM_ST_ELG_PART_IN_MKT_INDEX,
               I.SCM_ST_ELIGIBLE_AON,
               I.SCM_ST_ELIGIBLE_MIN_FILL,
               I.SCM_SEC_DEP_MANDATORY,
               I.SCM_SEC_DIVIDEND,
               I.SCM_SEC_ALLOW_DEP,
               I.SCM_SEC_ALLOW_SELL,
               I.SCM_SEC_MOD_CXL,
               I.SCM_SEC_ALLOW_BUY,
               I.SCM_BOOK_CLOSURE_DATE_START,
               I.SCM_BOOK_CLOSURE_DATE_END,
               I.SCM_DIVIDEND,
               I.SCM_RIGHTS,
               I.SCM_BONUS,
               I.SCM_INTEREST,
               I.SCM_AGM,
               I.SCM_EGM,
               I.SCM_OTHER,
               I.SCM_LOCAL_UPDATE_DATE_TIME,
               I.SCM_DELETE_FLAG,
               I.SCM_REMARKS,
               I.SCM_AMC_ACTIVE_FLAG,
               I.SCM_SCHEME_TYPE);

            L_INSERT_NSE := L_INSERT_NSE + 1;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            L_SUCCESS     := 'N';
            L_SKIPPED_NSE := L_SKIPPED_NSE + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Error While - ' || L_STR || ' - ' || SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

      ELSIF (I.SCM_EXCH_ID = 'BSE') THEN

        BEGIN
          L_STR := 'Updating BSE Data for SCHEME ---  Security ID : ' ||
                   I.SCM_SECURITY_ID || ' And  ISIN : ' || I.SCM_ISIN;

          UPDATE BOS_BSE_SCHEME_MASTER
             SET BBSM_INTERNAL_SECID            = I.SCM_SECURITY_ID,
                 BBSM_SM_ID                     = I.SCM_UNIQUE_NO,
                 BBSM_SM_SCHEMECODE             = I.SCM_SCHEME_CODE,
                 BBSM_SCHEMENAME                = I.SCM_SCHEME_NAME,
                 BBSM_RTA_SCHEMECODE            = I.SCM_RTA_SCHEME_CODE,
                 BBSM_AMCCODE                   = I.SCM_AMC_CODE,
                 BBSM_AMC_SCHEMECODE            = I.SCM_AMC_SCHEME_CODE,
                 BBSM_ISIN_CODE                 = I.SCM_ISIN,
                 BBSM_PURC_TRANS_MODE           = I.SCM_PURCHASE_TRANSACTION_MODE,
                 BBSM_MINI_PURC_AMT             = I.SCM_MINIMUM_PURCHASE_AMOUNT,
                 BBSM_ADD_PURC_AMT_MULTIPLE     = I.SCM_ADD_PURCHASE_AMT_MULTIPLE,
                 BBSM_MAX_PURC_AMT              = I.SCM_MAXIMUM_PURCHASE_AMOUNT,
                 BBSM_PURC_ALLOWED              = I.SCM_PURCHASE_ALLOWED,
                 BBSM_PURC_CUTOFFTIME           = I.SCM_PURCHASE_CUTOFF_TIME,
                 BBSM_REDEMPTION_TRANS_MODE     = I.SCM_REDEMPTION_TRANS_MODE,
                 BBSM_MIN_REDEMPTION_QTY        = I.SCM_MINIMUM_REDEMPTION_QTY,
                 BBSM_REDEMPTION_QTY_MULTIPLIER = I.SCM_REDEMPTION_QTY_MULTIPLIER,
                 BBSM_MAX_REDEMPTION_QTY        = I.SCM_MAXIMUM_REDEMPTION_QTY,
                 BBSM_REDEMPTION_ALLOWED        = I.SCM_REDEMPTION_ALLOWED,
                 BBSM_REDEMPTION_CUTOFFTIME     = I.SCM_REDEMPTION_CUTOFF_TIME,
                 BBSM_RTA_AGENTCODE             = I.SCM_RTA_AGENT_CODE,
                 BBSM_AMC_ACTIVEFLAG            = I.SCM_AMC_ACTIVE_FLAG,
                 BBSM_DIVIDEND_REINVEST_FLAG    = I.SCM_DIVIDEND_REINVEST_FLAG,
                 BBSM_SCHEME_TYPE               = I.SCM_SCHEME_TYPE,
                 BBSM_STATUS                    = I.SCM_AMC_ACTIVE_FLAG,
                 BBSM_PURC_AMT_MULTIPLIER       = i.Scm_Add_Purchase_Amt_Multiple
           WHERE BBSM_SM_ID = I.SCM_UNIQUE_NO;

          IF SQL%FOUND THEN
            L_UPDT_BSE := L_UPDT_BSE + 1;
          END IF;

          IF SQL%NOTFOUND THEN
            L_STR := 'Inserting BSE Data for Scheme ----  Security ID : ' ||
                     I.SCM_SECURITY_ID || ' And  ISIN : ' || I.SCM_ISIN;

            INSERT INTO BOS_BSE_SCHEME_MASTER
              (BBSM_INTERNAL_SECID,
               BBSM_SM_ID,
               BBSM_SM_SCHEMECODE,
               BBSM_SCHEMENAME,
               BBSM_RTA_SCHEMECODE,
               BBSM_AMCCODE,
               BBSM_AMC_SCHEMECODE,
               BBSM_ISIN_CODE,
               BBSM_PURC_TRANS_MODE,
               BBSM_MINI_PURC_AMT,
               BBSM_ADD_PURC_AMT_MULTIPLE,
               BBSM_MAX_PURC_AMT,
               BBSM_PURC_ALLOWED,
               BBSM_PURC_CUTOFFTIME,
               BBSM_REDEMPTION_TRANS_MODE,
               BBSM_MIN_REDEMPTION_QTY,
               BBSM_REDEMPTION_QTY_MULTIPLIER,
               BBSM_MAX_REDEMPTION_QTY,
               BBSM_REDEMPTION_ALLOWED,
               BBSM_REDEMPTION_CUTOFFTIME,
               BBSM_RTA_AGENTCODE,
               BBSM_AMC_ACTIVEFLAG,
               BBSM_DIVIDEND_REINVEST_FLAG,
               BBSM_SCHEME_TYPE,
               BBSM_STATUS,
               BBSM_PURC_AMT_MULTIPLIER)
            VALUES
              (I.SCM_SECURITY_ID,
               I.SCM_UNIQUE_NO,
               I.SCM_SCHEME_CODE,
               I.SCM_SCHEME_NAME,
               I.SCM_RTA_SCHEME_CODE,
               I.SCM_AMC_CODE,
               I.SCM_AMC_SCHEME_CODE,
               I.SCM_ISIN,
               I.SCM_PURCHASE_TRANSACTION_MODE,
               I.SCM_MINIMUM_PURCHASE_AMOUNT,
               I.SCM_ADD_PURCHASE_AMT_MULTIPLE,
               I.SCM_MAXIMUM_PURCHASE_AMOUNT,
               I.SCM_PURCHASE_ALLOWED,
               I.SCM_PURCHASE_CUTOFF_TIME,
               I.SCM_REDEMPTION_TRANS_MODE,
               I.SCM_MINIMUM_REDEMPTION_QTY,
               I.SCM_REDEMPTION_QTY_MULTIPLIER,
               I.SCM_MAXIMUM_REDEMPTION_QTY,
               I.SCM_REDEMPTION_ALLOWED,
               I.SCM_REDEMPTION_CUTOFF_TIME,
               I.SCM_RTA_AGENT_CODE,
               I.SCM_AMC_ACTIVE_FLAG,
               I.SCM_DIVIDEND_REINVEST_FLAG,
               I.SCM_SCHEME_TYPE,
               I.SCM_AMC_ACTIVE_FLAG,
               i.Scm_Add_Purchase_Amt_Multiple);

            L_INSERT_BSE := L_INSERT_BSE + 1;

          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            L_SUCCESS     := 'N';
            L_SKIPPED_BSE := L_SKIPPED_BSE + 1;
            UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                              ' Error While - ' || L_STR || ' - ' || SQLERRM);
            UTL_FILE.FFLUSH(L_FILE_HANDLE);
        END;

      END IF;

    END LOOP;*/

    UPDATE PROGRAM_STATUS
       SET PRG_STATUS         = DECODE(L_SUCCESS, 'Y', 'C', 'E'),
           PRG_PARTIAL_RUN_YN = 'N',
           PRG_END_TIME       = SYSDATE,
           PRG_LAST_UPDT_BY   = USER,
           PRG_LAST_UPDT_DT   = SYSDATE
     WHERE PRG_DT = L_CURR_DATE
       AND PRG_PROCESS_ID = L_PRG_PROCESS_ID
       AND PRG_CMP_ID = L_PRG_ID;

    COMMIT;

    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE, 'SUMMARY :');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for NSE : ' ||
                      L_FETCH_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for NSE : ' ||
                      L_INSERT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for NSE : ' || L_UPDT_NSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for NSE : ' ||
                      L_SKIPPED_NSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Fetched  for BSE : ' ||
                      L_FETCH_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Inserted for BSE : ' ||
                      L_INSERT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Updated  for BSE : ' || L_UPDT_BSE);
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Number of Records Skipped  for BSE : ' ||
                      L_SKIPPED_BSE);

    UTL_FILE.PUT_LINE(L_FILE_HANDLE, '       ');
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      'Process Completed at ' ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    UTL_FILE.PUT_LINE(L_FILE_HANDLE,
                      '--------------------------------------------------------------------------------------------');
    UTL_FILE.FFLUSH(L_FILE_HANDLE);
    UTL_FILE.FCLOSE(L_FILE_HANDLE);

  END P_LOAD_SCHEME_MASTER_MTS;

END PKG_MTS_UPLOAD;
/
