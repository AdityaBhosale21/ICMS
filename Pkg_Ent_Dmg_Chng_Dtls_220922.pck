CREATE OR REPLACE PACKAGE Pkg_Ent_Dmg_Chng_Dtls IS
  -- Author  : Ruchi Shinde
  -- Created : 3/12/2008 4:37:45 AM
  -- Purpose : Package to fetch entity details for demographic change page
  -- Called By: Demographic change page

  --Procedure to fetch entity details
  PROCEDURE p_Get_Ent_Dtls(i_Ent_Id     IN VARCHAR2,
                           o_Ref_Cursor OUT SYS_REFCURSOR,
                           o_Error_Code OUT VARCHAR2,
                           o_Error_Msg  OUT VARCHAR2);
  --Procedure to fetch entity bank account details
  PROCEDURE p_Get_Ent_Bank_Dtls(i_Ent_Id     IN VARCHAR2,
                                o_Ref_Cursor OUT SYS_REFCURSOR,
                                o_Error_Code OUT VARCHAR2,
                                o_Error_Msg  OUT VARCHAR2,
                                P_Nri_Type   IN VARCHAR2 DEFAULT 'ALL');

  --Procedure to fetch entity demat account details
  PROCEDURE p_Get_Ent_Dp_Dtls(i_Ent_Id     IN VARCHAR2,
                              o_Ref_Cursor OUT SYS_REFCURSOR,
                              o_Error_Code OUT VARCHAR2,
                              o_Error_Msg  OUT VARCHAR2,
							  P_Nri_Type   IN VARCHAR2 DEFAULT 'ALL');
  --Procedure to update entity email_Id and phone no. details in intermediate and final tables
  PROCEDURE p_Update_Ent_Dtls(i_Ent_Id              IN VARCHAR2,
                              i_Pgm_Id              IN VARCHAR2,
                              i_Ent_Phone_No_1      IN VARCHAR2,
                              i_Ent_Phone_No_2      IN VARCHAR2,
                              i_Ent_Mobile_No       IN VARCHAR2,
                              i_Ent_Mobile_No_2     IN VARCHAR2,--v1.7
                              i_Ent_Fax_No_1        IN VARCHAR2,
                              i_End_Email_Id        IN VARCHAR2,
                              i_End_Cc_To           IN VARCHAR2,
                              i_End_Bcc_To          IN VARCHAR2,
                              i_Occupation          IN VARCHAR2,--v1.7
                              i_Application_Id      IN VARCHAR2,
                              i_Application_User_Id IN VARCHAR2,
                              i_Ent_Isd_1           IN VARCHAR2,
                              i_Ent_Isd_2           IN VARCHAR2,
                              i_Ent_Std_1           IN VARCHAR2,
                              i_Ent_Std_2           IN VARCHAR2,
                              i_Accepted_By         IN VARCHAR2,--v1.7
                              i_Income_Range        IN VARCHAR2,--v1.7
                              i_Email_Fl            IN VARCHAR2,--v1.7
                              i_Gst_No              IN VARCHAR2,
                              i_Ent_uid_no          IN VARCHAR2,
                              o_Error_Code          OUT VARCHAR2,
                              o_Error_Msg           OUT VARCHAR2);

FUNCTION f_get_I_Agree_Flag RETURN varchar2;

END Pkg_Ent_Dmg_Chng_Dtls;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Ent_Dmg_Chng_Dtls IS
  /*
  Desc : This stored unit is used to view the Client Level Details on Demographic Web App.
         Using the Web App, details like Email Id,Phone,Mobile and Fax can be updated by Online Client.
         The updation will create the same effect as of  the record has been updated by CSSFMMT26 Client Reg Screen.
         Precision User will be able to view the history of the same through CSSFMMT26

  Change history :
           Version      Date         Desc
           1.0          May 08       Created
           1.1          16 Jun 08    Only Active bank and Demat A/C will be shown and SQlERRM Appended to the o_Error_Msg in case of any exception
           1.2          13-Aug-08    Changed by Aniket Shinde | HSL|FTR:133|Changed sequence no logic,added rollback in case of exceptions.
           1.3          22-Aug-08    Changed by Aniket Shinde | HSL|FTR:557|added default bank n dp account flag,order by default flag.
           1.4          14-Oct-2008  Changed By Neeraj Sachan | HSL| FTR 572 | added ISD,STD fields.
           1.5          03-Feb-2009  Changed by Piyush Jain | HSL | FTR 711 | Modified to check i_End_Email_Id for NULL before executing UPDATE or INSERT INTO on the tables ENTITY_DETAILS and ENTITY_DETAILS_INT.
           1.6          04-Feb-2009  Changed by Piyush Jain | HSL | SMS Alert Subscription
           1.7          04-Jan-2010  Changed by Piyush Jain | HSL | PROD 746 | KYC changes related to 'Mobile_No_2', 'Accepted_By', 'Acceptance_Dt', 'Occupation', 'Income_Range', and 'Email_Flag' fields
           2.0          22-Jan-2010  Changed by Piyush Jain | Modified logic for calling procedure Pkg_Common_Client_Updation.p_Ins_Mstr_Into_Int
  */
  PROCEDURE p_Get_Ent_Dtls(i_Ent_Id     IN VARCHAR2,
                           o_Ref_Cursor OUT SYS_REFCURSOR,
                           o_Error_Code OUT VARCHAR2,
                           o_Error_Msg  OUT VARCHAR2) IS

    l_qry            VARCHAR2(32767) := '';
    l_ent_rec_status VARCHAR2(3);
    l_apm_start_period DATE;--v1.7
    l_apm_end_period DATE;--v1.7
  BEGIN
    BEGIN
      SELECT e.ent_rec_status
        INTO l_ent_rec_status
        FROM entity_master_int e
       WHERE e.ent_id = i_Ent_Id AND
             e.ent_rec_seq_no =
             (SELECT max(ent_rec_seq_no)
                FROM entity_master_int
               WHERE ent_id = i_Ent_Id);
    EXCEPTION

      WHEN NO_DATA_FOUND then
        SELECT e.ent_rec_status
          INTO l_ent_rec_status
          FROM entity_master e
         WHERE e.ent_id = i_Ent_Id;

      WHEN OTHERS THEN
        l_ent_rec_status := 'N'; /*Set to 'N' for all records whose status is not 'A'*/
    END;

    IF l_ent_rec_status <> 'A' THEN
      o_Error_Code := '1E';
      o_Error_Msg  := 'Unable to update demographic details. Please contact customer care';
      RETURN;
    END IF;

    /*Start: v1.7*/
    BEGIN
         SELECT APM_START_PERIOD, APM_END_PERIOD
         INTO l_apm_start_period, l_apm_end_period
         FROM ACCOUNT_PERIOD_MASTER
         WHERE APM_CURRENT_FLAG = 'Y' AND APM_CLOSED_STATUS = 'O';
    EXCEPTION
         WHEN OTHERS THEN
              o_Error_Code := '1';
              o_Error_Msg  := 'Fatal error occured while querying data from ACCOUNT_PERIOD_MASTER. Cannot proceed further.' ||SQLERRM;
              RETURN;
    END;
    /*End: v1.7*/

    l_qry := 'SELECT e.ent_name    "Name", ';
    l_qry := l_qry || ' e.ent_middle_name    "Fathers Name", ';
    l_qry := l_qry || ' e.ent_address_line_1 "Address1", ';
    l_qry := l_qry || ' e.ent_address_line_2 "Address2", ';
    l_qry := l_qry || ' e.ent_address_line_3 "Address3", ';
    l_qry := l_qry || ' e.ent_address_line_4 "City", ';
    l_qry := l_qry || ' e.ent_address_line_5 "State", ';
    l_qry := l_qry || ' e.ent_address_line_6 "Country", ';
    l_qry := l_qry || ' e.ent_address_line_7 "Pincode", ';
    l_qry := l_qry || ' d.erd_pan_no         "PAN No.", ';
    l_qry := l_qry || ' e.ent_phone_no_1     "Phone1", ';
    l_qry := l_qry || ' e.ent_phone_no_2     "Phone2", ';
    l_qry := l_qry || ' e.ent_mobile_no      "Mobile", ';
    l_qry := l_qry || ' e.ent_mobile_no_2    "Mobile2", ';--v1.7
    l_qry := l_qry || ' e.ent_fax_no_1       "Fax", ';
    l_qry := l_qry || ' n.end_email_id       "To Email Id",';
    l_qry := l_qry || ' n.end_cc_to          "CC Email Id", ';
    l_qry := l_qry || ' n.end_bcc_to         "BCC Email Id", ';
    l_qry := l_qry || ' e.ENT_ISD_CODE_PHONE_NO_1     "Isd1", ';
    l_qry := l_qry || ' e.ENT_ISD_CODE_PHONE_NO_2    "Isd2", ';
    l_qry := l_qry || ' e.ENT_STD_CODE_PHONE_NO_1     "Std1", ';
    l_qry := l_qry || ' e.ENT_STD_CODE_PHONE_NO_2     "Std2", ';
    l_qry := l_qry || ' e.ENT_OCCUPATION              "Occupation", ';--v1.7

    l_qry := l_qry || ' e.ENT_ACCEPTED_BY             "Accepted By", ';--v1.7
    l_qry := l_qry || ' e.ENT_ACCEPTANCE_DT           "Acceptance Dt", ';--v1.7
    --l_qry := l_qry || ' i.EID_GROSS_INCOME           "Income Range" ,';--v1.7
    l_qry := l_qry || ' NULL           "Income Range" ,';--v1.7 --Changes Made by Devendra as per HSL feedback on 28May10
    --l_qry := l_qry || ' DECODE(E.ENT_DISPATCH_MODE,''E'',''Y'',''N'')         "Dispatch Mode" ,';--v1.7
    l_qry := l_qry || ' DECODE(E.ENT_DISPATCH_MODE,''C'',''N'',''Y'')         "Dispatch Mode" ,';--v1.7 --Changes made by Devendra as per HSL feedback on 28May10
    l_qry := l_qry || ' Pkg_Ent_Dmg_Chng_Dtls.f_get_I_Agree_Flag,';
    l_qry := l_qry || ' e.ENT_OTHERS_OCC_REASON       "Occupation Reason", ';
    l_qry := l_qry || ' e.ENT_EMAIL_RELTN             "Email Relation", ';
    l_qry := l_qry || ' e.ENT_MOBILE_RELTN            "Mobile Relation", ';
    l_qry := l_qry || ' n.END_EMAIL_DECLARATION       "Email Declaration", ';
    l_qry := l_qry || ' e.ENT_MOBILE_NO_DECLARATION   "Mobile Declaration", ';
    l_qry := l_qry || ' e.ENT_GST_NO                  "GST Number", ';
    l_qry := l_qry || ' DECODE(D.Erd_Adh_No ,'''','''',F_Aadhar_Decr(D.erd_encr_aadhar_no ))"Aadhar Number", ';
    l_qry := l_qry  || ' NVL(e.ENT_UID_VERIFIED_YN,''N'')                  "Aadhar Verified Flag" , ';
    l_qry := l_qry ||' NVL(e.ENT_UID_VERIFIED_YN,''N'')                  "Aadhar Verified Flag"  ';
      l_qry := l_qry || 'FROM entity_master e, entity_registration_details d, entity_details n, entity_income_dtls i ';--v1.7
    l_qry := l_qry || ' WHERE e.ent_id = ''' || i_Ent_Id || ''' ';
    l_qry := l_qry || ' AND e.ent_id = d.erd_ent_id(+) ';
    l_qry := l_qry || '  AND e.ent_id = n.end_id(+) ';
    l_qry := l_qry || '  AND i.eid_ent_id(+) = e.ent_id';--v1.7--LEFT OUTER JOIN condition
    l_qry := l_qry || '  AND i.eid_from_yr(+) = '''||l_apm_start_period||'''';--v1.7
    l_qry := l_qry || '  AND i.eid_to_yr(+) = '''||l_apm_end_period||'''';--v1.7
    l_qry := l_qry || ' AND n.end_default_flag(+) = ''Y'' ';


    OPEN o_Ref_Cursor FOR l_qry; /*Opening Ref Cursor for SQL Query*/
    o_Error_Code := '0';
    o_Error_Msg  := 'Success';

  EXCEPTION
    WHEN OTHERS THEN
      o_Error_Code := SQLCODE;
      o_Error_Msg  := 'Failure While Selecting Client Details: ' || SQLERRM;

  END p_Get_Ent_Dtls;

  /************************************************************************/

  PROCEDURE p_Get_Ent_Bank_Dtls(i_Ent_Id     IN VARCHAR2,
                                o_Ref_Cursor OUT SYS_REFCURSOR,
                                o_Error_Code OUT VARCHAR2,
                                o_Error_Msg  OUT VARCHAR2,
                                P_Nri_Type   IN VARCHAR2 DEFAULT 'ALL') IS

    l_Ent_Ctg_Desc VARCHAR2(100);
    l_qry          VARCHAR2(32767) := '';
  BEGIN
    SELECT Ent_Ctg_Desc
    INTO   l_Ent_Ctg_Desc
    FROM   Entity_Master
    WHERE  Ent_Id = i_Ent_Id;

    IF l_Ent_Ctg_Desc = '11' THEN
      l_qry := 'Select ROWNUM "Sr.No.", Bank.* From ( SELECT DISTINCT ' || chr(10) ||
               '    m.bkm_name "Bank Name",' || chr(10) ||
               '     a.bam_no "Bank Account No.",' || chr(10) ||
               '     Decode(a.bam_def_bnk_ind,''Y'',''Yes'',''No'') "Default Flag."' ||chr(10) ||
               '     FROM bank_master m, bank_account_master a, entity_master e' ||chr(10) ||
               '     WHERE e.Ent_Exch_Client_Id = ''' || i_Ent_Id || '''' ||chr(10) ||
               '     AND m.bkm_cd = a.bam_bkm_cd' || chr(10) ||
               '     AND e.ent_id = a.bam_ent_id' || chr(10) ||
               '     AND Decode(''' || P_Nri_Type || ''',''ALL'',''1'',Ent_Nri_Settlement_Type) = Decode(''' || P_Nri_Type || ''',''ALL'',''1'',''' || P_Nri_Type || ''')' || chr(10) ||
               '     AND a.bam_status <>''I''' || chr(10) ||
               '     ORDER BY 3 DESC) Bank' || chr(10) ||
               ' ORDER BY 4 DESC ';

      /*DO NOT DELETE THIS, THIS SHOULD BE UPDATED AS AND WHEN REF CURSOR QUERY IS  UPDATED
          SELECT ROWNUM "Sr.No.",
      m.bkm_name "Bank Name",
       a.bam_no "Bank Account No."
       FROM bank_master m, bank_account_master a, entity_master e
       WHERE e.Ent_Exch_Client_Id = '&i_Ent_Id'
       AND m.bkm_cd = a.bam_bkm_cd
       AND e.ent_id = a.bam_ent_id
       AND a.bam_status <>'I' */

    ELSE
      l_qry := 'Select ROWNUM "Sr.No.", Bank.* From ( SELECT' || chr(10) ||
               '    m.bkm_name "Bank Name",' || chr(10) ||
               '     a.bam_no "Bank Account No.",' || chr(10) ||
               '     Decode(a.bam_def_bnk_ind,''Y'',''Yes'',''No'') "Default Flag."' ||chr(10) ||
               '     FROM bank_master m, bank_account_master a, entity_master e' ||chr(10) ||
               '     WHERE e.ent_id = ''' || i_Ent_Id || '''' ||chr(10) ||
               '     AND m.bkm_cd = a.bam_bkm_cd' || chr(10) ||
               '     AND e.ent_id = a.bam_ent_id' || chr(10) ||
               '     AND a.bam_status <>''I''' || chr(10) ||
               '     ORDER BY bam_def_bnk_ind DESC) Bank' || chr(10) ||
               ' ORDER BY 4 DESC ';

      /*DO NOT DELETE THIS, THIS SHOULD BE UPDATED AS AND WHEN REF CURSOR QUERY IS  UPDATED
          SELECT ROWNUM "Sr.No.",
      m.bkm_name "Bank Name",
       a.bam_no "Bank Account No."
       FROM bank_master m, bank_account_master a, entity_master e
       WHERE e.ent_id = '&i_Ent_Id'
       AND m.bkm_cd = a.bam_bkm_cd
       AND e.ent_id = a.bam_ent_id
       AND a.bam_status <>'I'
      */
    END IF;

    OPEN o_Ref_Cursor FOR l_qry; /*Opening Ref Cursor for SQL Query*/
    o_Error_Code := '0';
    o_Error_Msg  := 'Success';

  EXCEPTION
    WHEN OTHERS THEN
      o_Error_Code := SQLCODE;
      o_Error_Msg  := 'Failure While Selecting Bank A/C :' || SQLERRM;

  END p_Get_Ent_Bank_Dtls;

  /********************************************************************************/

  PROCEDURE p_Get_Ent_Dp_Dtls(i_Ent_Id     IN VARCHAR2,
                              o_Ref_Cursor OUT SYS_REFCURSOR,
                              o_Error_Code OUT VARCHAR2,
                              o_Error_Msg  OUT VARCHAR2,
                               P_Nri_Type   IN VARCHAR2 DEFAULT 'ALL') IS

    l_Ent_Ctg_Desc VARCHAR2(100);
    l_qry          VARCHAR2(32767) := '';

  BEGIN
    SELECT Ent_Ctg_Desc
    INTO   l_Ent_Ctg_Desc
    FROM   Entity_Master
    WHERE  Ent_Id = i_Ent_Id;

    IF l_Ent_Ctg_Desc = '11' THEN
      l_qry := ' SELECT ROWNUM  "Sr. No.", Bank.* from (select DISTINCT ' || chr(10) ||
               '       d.dpm_name "Dp Name",' || chr(10) ||
               '       m.mdi_dpm_dem_id "Depository",' || chr(10) ||
               '       m.mdi_dpm_id "DP Id",' || chr(10) ||
               '       m.mdi_dp_acc_no "Account No.",' || chr(10) ||
               ' Decode(m.mdi_default_flag,''Y'',''Yes'',''No'') "Default Flag."' || chr(10) ||
               ' FROM member_dp_info m, depo_participant_master d, Entity_Master ' ||chr(10) ||
               ' WHERE Ent_Exch_Client_Id = ''' || i_Ent_Id || '''' || chr(10) ||
               ' AND   m.mdi_id = Ent_Id AND d.dpm_id = m.mdi_dpm_id' || chr(10) ||
               '     AND Decode(''' || P_Nri_Type || ''',''ALL'',''1'',Ent_Nri_Settlement_Type) = Decode(''' || P_Nri_Type || ''',''ALL'',''1'',''' || P_Nri_Type || ''')' || chr(10) ||
               ' And   m.mdi_status <> ''C''' || chr(10) ||
               ' ORDER BY 5 DESC) Bank' || chr(10) ||
               ' order by 6 desc';
    ELSE
      l_qry := ' SELECT ROWNUM  "Sr. No.", Bank.* from (select' || chr(10) ||
               '       d.dpm_name "Dp Name",' || chr(10) ||
               '       m.mdi_dpm_dem_id "Depository",' || chr(10) ||
               '       m.mdi_dpm_id "DP Id",' || chr(10) ||
               '       m.mdi_dp_acc_no "Account No.",' || chr(10) ||
               ' Decode(m.mdi_default_flag,''Y'',''Yes'',''No'') "Default Flag."' || chr(10) ||
               ' FROM member_dp_info m, depo_participant_master d' ||chr(10) ||
               ' WHERE m.mdi_id = ''' || i_Ent_Id || '''' || chr(10) ||
               ' AND   d.dpm_id = m.mdi_dpm_id' || chr(10) ||
               ' And   m.mdi_status <> ''C''' || chr(10) ||
               ' ORDER BY mdi_default_flag DESC) Bank' || chr(10) ||
               ' order by 4 desc';

    /* DO NOT DELETE THIS, THIS SHOULD BE UPDATED AS AND WHEN REF CURSOR QUERY IS  UPDATED
      SELECT ROWNUM "Sr. No.",
       d.dpm_name "Dp Name",
       m.mdi_dpm_dem_id "Depository",
       m.mdi_dpm_id "DP Id",
       m.mdi_dp_acc_no "Account No."
       FROM member_dp_info m, depo_participant_master d
       WHERE m.mdi_id = '&i_Ent_Id'
       AND   d.dpm_id = m.mdi_dpm_id
       And   m.mdi_status <> 'C'
    */
    END IF;
    OPEN o_Ref_Cursor FOR l_qry; /*Opening Ref Cursor for SQL Query*/
    o_Error_Code := '0';
    o_Error_Msg  := 'Success';

  EXCEPTION
    WHEN OTHERS THEN
      o_Error_Code := SQLCODE;
      o_Error_Msg  := 'Failure While Select Demat A/C :' || SQLERRM;

  END p_Get_Ent_Dp_Dtls;

  /********************************************************************************/

  PROCEDURE p_Update_Ent_Dtls(i_Ent_Id              IN VARCHAR2,
                              i_Pgm_Id              IN VARCHAR2,
                              i_Ent_Phone_No_1      IN VARCHAR2,
                              i_Ent_Phone_No_2      IN VARCHAR2,
                              i_Ent_Mobile_No       IN VARCHAR2,
                              i_Ent_Mobile_No_2     IN VARCHAR2,--v1.7
                              i_Ent_Fax_No_1        IN VARCHAR2,
                              i_End_Email_Id        IN VARCHAR2,
                              i_End_Cc_To           IN VARCHAR2,
                              i_End_Bcc_To          IN VARCHAR2,
                              i_Occupation          IN VARCHAR2,--v1.7
                              i_application_id      IN VARCHAR2,
                              i_application_user_id IN VARCHAR2,
                              i_Ent_Isd_1           IN VARCHAR2,
                              i_Ent_Isd_2           IN VARCHAR2,
                              i_Ent_Std_1           IN VARCHAR2,
                              i_Ent_Std_2           IN VARCHAR2,
                              i_Accepted_By         IN VARCHAR2,--v1.7
                              i_Income_Range        IN VARCHAR2,--v1.7
                              i_Email_Fl            IN VARCHAR2,--v1.7
                              i_Gst_No              IN VARCHAR2,
                              i_Ent_uid_no          IN VARCHAR2,
                              o_Error_Code          OUT VARCHAR2,
                              o_Error_Msg           OUT VARCHAR2) IS


    l_ent_rec_seq_no         NUMBER := 0;
    l_ent_rec_status         VARCHAR2(3);
    l_email_exists           VARCHAR2(1) := 'N';--v1.7
    l_occ_exists             VARCHAR2(1) := 'N';--v1.7
    o_Rtn_Flg                BOOLEAN;--v1.7
    l_email_flag             VARCHAR2(2);--v1.7
    l_apm_start_period       DATE;--v1.7
    l_apm_end_period         DATE;--v1.7
    l_gross_income_exists    VARCHAR2(1);--v1.7
    l_fin_yr_start_dt        DATE;--v1.7
    l_fin_yr_end_dt          DATE;--v1.7
    l_Ent_Exch_Client_Id     VARCHAR2(30);
    l_Ent_Id                 VARCHAR2(30);
    l_Old_Gross_Income       Varchar(500);
    l_Ent_Ctg_Desc           Varchar(5);
    l_ENT_OTHERS_OCC_REASON  Varchar(200);
    l_reason_len             NUMBER :=0;
    l_occupation             VARCHAR2(50);
    l_dispatch_mode          VARCHAR2(1);
    l_type_of_facilty        VARCHAR2(1);
    l_Ent_Email_Declr        VARCHAR2(1);
    l_Ent_Mobile_Declr       VARCHAR2(1);
    l_Dup_mobile_Exist       NUMBER;
    l_Dup_Email_Exists       NUMBER;
    l_Code                   varchar2(10);
    l_Count                  varchar2(10);
    l_valid_alphabet         varchar2(10);
    l_valid_alphabet_1       varchar2(10);
    l_valid_number           varchar2(10);
    l_Number                 VARCHAR2(10);
    l_ent_ucc_upload_fl      VARCHAR2(1);
    l_ent_matrix_upload      VARCHAR2(1);
    l_Aadhar_Count           NUMBER :=0;
    l_Ent_Uid_Verified_YN    VARCHAR2(1) := 'N';
    l_Previous_Uid_No        VARCHAR2(30);
    l_priv_flag              VARCHAR2(1) := 'N';
    l_Aadhar_Encrypt         VARCHAR2(50);
  L_GROSS_INCOME       VARCHAR2(500);
  L_INCOME_RANGE       VARCHAR2(500);
  l_pam_cur_date       date;
  L_ENT_INCOME_DT      DATE;

    CURSOR C_ENTITY IS
     SELECT Ent_Id
       FROM Entity_Master
      WHERE Ent_Exch_Client_Id = l_Ent_Exch_Client_Id;
  BEGIN
       /*Start: v1.7*/
       /*Start: Validations for KYC demographic fields --comments by Piyush*/
    BEGIN
      SELECT e.ent_rec_status, Nvl(ent_email_declr,'N'), Nvl(ent_mobile_declr, 'N'), Ent_Exch_Client_Id
        INTO l_ent_rec_status, l_Ent_Email_Declr,  l_Ent_Mobile_Declr, l_Ent_Exch_Client_Id

        FROM entity_master_int e
       WHERE e.ent_id = i_Ent_Id AND
             e.ent_rec_seq_no =
             (SELECT max(ent_rec_seq_no)
                FROM entity_master_int
               WHERE ent_id = i_Ent_Id);
    EXCEPTION

      WHEN NO_DATA_FOUND then
        SELECT e.ent_rec_status
          INTO l_ent_rec_status
          FROM entity_master e
         WHERE e.ent_id = i_Ent_Id;

      WHEN OTHERS THEN
        l_ent_rec_status := 'N'; /*Set to 'N' for all records whose status is not 'A'*/
    END;

    BEGIN
       SELECT Ent_Exch_Client_Id    , Ent_Ctg_Desc
         INTO l_Ent_Exch_Client_Id  , l_Ent_Ctg_Desc
         FROM Entity_Master
        WHERE Ent_Id = i_Ent_Id;
    EXCEPTION
         WHEN OTHERS THEN
          o_Error_Code := '1';
          o_Error_Msg  := 'Failed to select Exchange/Category UCC Code:' ||SQLERRM;
          RETURN;
    END;

    OPEN C_ENTITY;
    LOOP
      BEGIN
         FETCH C_ENTITY INTO l_Ent_Id;
         EXIT WHEN C_ENTITY%NOTFOUND;
             BEGIN
                SELECT e.ent_ctg_desc,e.Ent_Dispatch_Mode,e.ent_type_of_facility
                 INTO l_email_flag, l_dispatch_mode, l_type_of_facilty
                 FROM ENTITY_MASTER e
                WHERE ENT_ID = l_Ent_Id;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     l_email_flag := 'X';
                WHEN OTHERS THEN
                     l_email_flag := 'X';
             END;

             IF i_End_Email_Id IS NULL THEN
                IF l_email_flag IN ('06','07','08','18','12','16') OR nvl(l_dispatch_mode,'X') = 'E' OR nvl(l_type_of_facilty,'0') IN ('1','3') THEN   -- category for which email id is mandatory as per form
                   o_Error_Code := '1';
                   o_Error_Msg := 'To Email Id is mandatory.';
                    RETURN;
                END IF;
             ELSE
                Pkg_masters.P_Validate_Email_Id(i_End_Email_Id,o_Error_Msg,o_Rtn_Flg);
                IF o_Rtn_Flg = FALSE THEN
                   o_Error_Code := '1';
                   RETURN;
                END IF;
             END IF;

             IF i_End_Cc_To IS NOT NULL THEN
                Pkg_masters.P_Validate_Email_Id(i_End_Cc_To,o_Error_Msg,o_Rtn_Flg);
                IF o_Rtn_Flg = FALSE THEN
                   o_Error_Code := '1';
                   RETURN;
                 END IF;
             END IF;
             IF i_End_Bcc_To IS NOT NULL THEN
                Pkg_masters.P_Validate_Email_Id(i_End_Bcc_To,o_Error_Msg,o_Rtn_Flg);
                IF o_Rtn_Flg = FALSE THEN
                   o_Error_Code := '1';
                   RETURN;
                 END IF;
             END IF;

             IF Nvl(l_Ent_Email_Declr,'N') = 'N' AND i_End_Email_Id IS NOT NULL THEN
                BEGIN
                 SELECT 1
                   INTO l_Dup_Email_Exists
                   FROM Dual
                  WHERE EXISTS (SELECT end_Email_id
                                FROM entity_details ,Entity_Master a1
                                WHERE Ent_id = End_Id
                                AND upper(End_Email_id) = upper(i_End_Email_Id)
                                AND ent_exch_client_id <> l_Ent_Exch_Client_Id
                                AND End_id <> i_Ent_Id
                                AND END_STATUS = 'A'
                                AND Ent_Status IN ('E','D')
                                AND End_Default_Flag = 'Y'
                                UNION
                                SELECT end_Email_id
                                FROM entity_details_int t  , Entity_Master_Int a1
                                WHERE Ent_id = End_Id
                                AND upper(End_Email_id) = upper(i_End_Email_Id)
                                AND ent_exch_client_id <> l_Ent_Exch_Client_Id
                                AND End_id <> i_Ent_Id
                                AND Ent_Rec_Status = 'P'
                                AND End_rec_Seq_No = Ent_Rec_Seq_No
                                AND END_STATUS = 'A'
                                AND Ent_Status IN ('E','D')
                                AND End_Default_Flag = 'Y');
                EXCEPTION
                  when No_Data_Found then
                     l_Dup_Email_Exists := '0';
                 WHEN OTHERS THEN
                   l_Dup_Email_Exists := '0';
                   o_Error_Code := '1';
                   o_Error_Msg := 'Error while validating Email.';
                   RETURN;
                END;

                IF l_Dup_Email_Exists = 1 THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'This Email is already mapped to another client. Pls contact customer care or nearest branch to submit declaration.';
                   RETURN;
                END IF;
             END IF;

             IF (i_Ent_Phone_No_1 IS NULL AND
                 i_Ent_Phone_No_2 IS NULL AND
                 i_Ent_Mobile_No IS NULL)
             THEN
                 o_Error_Code := '1';
                 o_Error_Msg := 'At least one of Phone No. 1, Phone No. 2 and Mobile No. 1 is mandatory.';
                  RETURN;
             END IF;

             IF i_Ent_Mobile_No IS NULL THEN
                 o_Error_Code := '1';
                 o_Error_Msg := 'Mobile No. 1 is mandatory.';
                  RETURN;
             END IF;

             IF i_Ent_Phone_No_1 IS NOT NULL AND i_Ent_Std_1 IS NULL THEN
                o_Error_Code := '1';
                o_Error_Msg := 'STD code of Phone 1 is Mandatory.';
                 RETURN;
             END IF;

             IF i_Ent_Phone_No_2 IS NOT NULL AND i_Ent_Std_2 IS NULL THEN
                o_Error_Code := '1';
                o_Error_Msg := 'STD code of Phone 2 is Mandatory.';
                 RETURN;
             END IF;

             IF i_Ent_Isd_1 IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Isd_1) != 'Y' THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'ISD 1 should be numeric.';
                   RETURN;
                END IF;
                IF length(i_Ent_Isd_1) < 2 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 1 cannot be less than 2 characters.';
                 RETURN;
               END IF;
                 IF length(i_Ent_Isd_1) > 5 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 1 cannot be more than 5 characters.';
                 RETURN;
               END IF;
                 IF to_number(i_Ent_Isd_1) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 1 cannot be all zeroes.';
                 RETURN;
               END IF;
             END IF;

             IF i_Ent_Isd_2 IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Isd_2) != 'Y' THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'ISD 2 should be numeric.';
                   RETURN;
                END IF;
                IF length(i_Ent_Isd_2) < 2 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 2 cannot be less than 2 characters.';
                 RETURN;
               END IF;
                IF length(i_Ent_Isd_2) > 5 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 2 cannot be more than 5 characters.';
                 RETURN;
               END IF;
                IF to_number(i_Ent_Isd_2) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'ISD 2 cannot be all zeroes.';
                 RETURN;
               END IF;
             END IF;

             IF i_Ent_Std_1 IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Std_1) != 'Y' THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'STD 1 should be numeric.';
                   RETURN;
                END IF;
                 IF length(i_Ent_Std_1) < 2 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 1 cannot be less than 2 characters.';
                 RETURN;
               END IF;
                 IF length(i_Ent_Std_1) > 8 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 1 cannot be more than 8 characters.';
                 RETURN;
               END IF;
                 IF to_number(i_Ent_Std_1) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 1 cannot be all zeroes.';
                 RETURN;
               END IF;
             END IF;

             IF i_Ent_Std_2 IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Std_2) != 'Y' THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'STD 2 should be numeric.';
                   RETURN;
                END IF;
                IF length(i_Ent_Std_2) < 2 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 2 cannot be less than 2 characters.';
                 RETURN;
               END IF;
                 IF length(i_Ent_Std_2) > 8 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 2 cannot be more than 8 characters.';
                 RETURN;
               END IF;
                 IF to_number(i_Ent_Std_2) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'STD 2 cannot be all zeroes.';
                 RETURN;
               END IF;
             END IF;

             IF i_Ent_Phone_No_1 IS NOT NULL THEN
                 IF Pkg_Masters.F_Check_Number(i_Ent_Phone_No_1) != 'Y' THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Phone No. 1 should be numeric.';
                    RETURN;
                 END IF;
                  IF length(i_Ent_Phone_No_1) < 5 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 1 cannot be less than 5 characters.';
                  RETURN;
                END IF;
                  IF length(i_Ent_Phone_No_1) > 15 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 1 cannot be more than 15 characters.';
                  RETURN;
                END IF;
                  IF to_number(i_Ent_Phone_No_1) = 0 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 1 cannot be all zeroes.';
                  RETURN;
                END IF;
             ELSE
                 IF (i_Ent_Isd_1 IS NOT NULL OR i_Ent_Std_1 IS NOT NULL) THEN
                     o_Error_Code := '1';
                     o_Error_Msg := 'Phone No 1 cannot be blank if ISD/STD code for phone no 1 is entered.';
                     RETURN;
                 END IF;
             END IF;

             IF i_Ent_Phone_No_2 IS NOT NULL THEN
                 IF Pkg_Masters.F_Check_Number(i_Ent_Phone_No_2) != 'Y' THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Phone No. 2 has to be numeric.';
                    RETURN;
                 END IF;
                  IF length(i_Ent_Phone_No_2) < 5 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 2 cannot be less than 5 characters.';
                  RETURN;
                END IF;
                  IF length(i_Ent_Phone_No_2) > 15 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 2 cannot be more than 15 characters.';
                  RETURN;
                END IF;
                  IF to_number(i_Ent_Phone_No_2) = 0 THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Phone No. 2 cannot be all zeroes.';
                  RETURN;
                END IF;
             ELSE
                 IF (i_Ent_Isd_2 IS NOT NULL OR i_Ent_Std_2 IS NOT NULL) THEN
                     o_Error_Code := '1';
                     o_Error_Msg := 'Phone No 2 cannot be blank if ISD/STD code for phone no 2 is entered.';
                     RETURN;
                 END IF;
             END IF;

             IF i_Ent_Mobile_No IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Mobile_No) != 'Y' THEN
                    o_Error_Code := '1';
                   o_Error_Msg := 'Mobile No. 1 has to be numeric.';
                   RETURN;
                END IF;
                 IF length(i_Ent_Mobile_No) > 15 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'Mobile No. 1 cannot be more than 15 characters.';
                 RETURN;
               END IF;
                 IF length(i_Ent_Mobile_No) < 5 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'Mobile No. 1 cannot be less than 5 characters.';
                 RETURN;
               END IF;
                 IF TO_NUMBER(i_Ent_Mobile_No) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'Mobile No. 1 cannot contain all zeros.';
                    RETURN;
                END IF;

                IF l_Ent_Ctg_Desc IN ('01','36')THEN
                   IF SUBSTR(i_Ent_Mobile_No,1,1) = '0' then
                      o_Error_Code := '1';
                      o_Error_Msg := 'Mobile No. cannot start with number 0 for Individual Client';
                       RETURN;
                   END IF;
                   IF LENGTH(i_Ent_Mobile_No) <> 10 then
                      o_Error_Code := '1';
                      o_Error_Msg := 'Mobile No. should be of 10 digits only for Individual Client.';
                       RETURN;
                   END IF;
                END IF;
             END IF;  -- Mobile end

             If i_Gst_No IS NOT NULL THEN  --GST strt
                If length(i_Gst_No) <> 15 THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Invalid GSTIN entered. GSTIN must be of 15 characters in length.';
                    RETURN;
                End If;

                If Pkg_Masters.F_Check_AlphaNumeric(i_Gst_No) <> 'Y' THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Invalid GSTIN entered. Please enter only alphanumeric value for GSTIN.';
                    RETURN;
                End If;

                If Pkg_Masters.F_Check_Number(substr(i_Gst_No,1, 2)) <> 'Y' THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Invalid GSTIN entered. First 2 characters of GSTIN must be Numeric.';
                    RETURN;
                End If;
                l_Number := substr(i_Gst_No,8, 4);
                pkg_client_activation.p_chk_for_valid_alphabet(substr(i_Gst_No,3, 5), 5, l_valid_alphabet);
                pkg_client_activation.p_chk_for_valid_alphabet(substr(i_Gst_No,12, 1), 1, l_valid_alphabet_1);
                pkg_client_activation.p_check_for_num(l_Number,l_valid_number);

                If l_valid_alphabet = 'N' OR l_valid_alphabet_1 = 'N' OR  l_valid_number = 'N' Then
                   o_Error_Code := '1';
                   o_Error_Msg := 'Invalid GSTIN entered. First 12 characters of GSTIN should be in Format 99XXXXX9999X.';
                   RETURN;
                End If;

                l_Code := substr(i_Gst_No,1, 2);

                SELECT COUNT(1)
                  into l_Count
                  FROM Cg_Ref_Codes
                 WHERE Rv_Domain = 'STATE_NAME'
                   AND substr(RV_USED_IN,1,2) = l_Code;

                If l_Count = 0 THEN
                    o_Error_Code := '1';
                    o_Error_Msg := 'Invalid GSTIN entered. The First 2 digits of GSTIN (State Code) is Invalid.';
                    RETURN;
                End If;

               SELECT ent_ucc_upload_fl, ent_matrix_upload, ent_ctg_desc
                 INTO l_ent_ucc_upload_fl, l_ent_matrix_upload, l_Ent_Ctg_Desc
                 FROM entity_master
                WHERE ent_id = i_Ent_Id;

               If l_Ent_Ctg_Desc = '11' AND l_ent_ucc_upload_fl = 'N' AND l_ent_matrix_upload = 'N' THEN
                  SELECT COUNT(1)
                    INTO l_Count
                    FROM Cg_Ref_Codes
                   WHERE Rv_Domain = 'STATE_NAME'
                     AND substr(RV_USED_IN,1,2) = substr(i_Gst_No,1, 2)
                     AND Rv_low_value = (SELECT ent_address_line_5 FROM entity_master
                                            WHERE ent_id = (SELECT ent_id FROM entity_master
                                                             WHERE ent_exch_client_id = l_Ent_Exch_Client_Id
                                                             AND ent_ucc_upload_fl    = 'Y'
                                                             AND ent_matrix_upload    = 'Y'));

                   If l_Count = 0 THEN
                     o_Error_Code := '1';
                     o_Error_Msg := 'The First 2 digits of GSTIN (State Code) is different from the Client Parent Account Correspondence State.';
                     RETURN;
                   End If;
               Else
                   SELECT COUNT(1)
                     INTO l_Count
                     FROM Cg_Ref_Codes
                    WHERE Rv_Domain = 'STATE_NAME'
                      AND substr(RV_USED_IN,1,2) = substr(i_Gst_No,1, 2)
                      AND Rv_low_value = (SELECT ent_address_line_5 FROM entity_master
                                           WHERE ent_id = i_Ent_Id);

                    If l_Count = 0 THEN
                     o_Error_Code := '1';
                     o_Error_Msg := 'The First 2 digits of GSTIN (State Code) is different from the Clients Correspondence State.';
                     RETURN;
                   End If;
                End If;

                SELECT COUNT(1)
                  INTO l_Count
                  FROM Dual
                 WHERE substr(i_Gst_No,3, 10) = (SELECT erd_pan_no FROM entity_registration_details WHERE erd_ent_id = i_Ent_Id);

                If l_Count = 0 THEN
                     o_Error_Code := '1';
                     o_Error_Msg := 'The PAN present in the GSTIN is different from the Client PAN.';
                     RETURN;
                End If;
             End If;  -- GST end

              IF i_Ent_Uid_No IS NOT NULL THEN -- aadhar
                IF length(i_Ent_Uid_No) < 12 THEN
                 o_Error_Code := '1';
                 o_Error_Msg := 'Invalid Aadhar No. entered. Aadhar No. must be of 12 characters in length.';
                 RETURN;
                END IF ;

              SELECT COUNT(*)
                INTO l_Aadhar_Count
                FROM Entity_master_int
               WHERE Ent_Id <> i_Ent_Id
               AND   Ent_Uid_No = i_Ent_uid_no;

              IF l_Aadhar_Count = 0 THEN
                SELECT COUNT(*)
                 INTO l_Aadhar_Count
                 FROM Entity_Registration_Dtls_Int
                WHERE Erd_Ent_Id <> i_Ent_Id
                AND   Erd_Adh_No = i_Ent_uid_no;
              END IF;

              IF l_Aadhar_Count > 0 THEN
                o_Error_Code := '1';
                o_Error_Msg := 'Aadhar No. < ' || i_Ent_uid_no || ' > is already present in system,So Skipped.';
               RETURN;
              END IF;
              l_Aadhar_Count := 0;


              SELECT COUNT(*)
                INTO l_Aadhar_Count
                FROM Entity_master
               WHERE Ent_Id <> i_Ent_Id
               AND   Ent_Uid_No = i_Ent_uid_no;

              IF l_Aadhar_Count = 0 THEN
                SELECT COUNT(*)
                 INTO l_Aadhar_Count
                 FROM Entity_Registration_Details
                WHERE Erd_Ent_Id <> i_Ent_Id
                AND   Erd_Adh_No = i_Ent_uid_no;
              END IF;

              IF l_Aadhar_Count > 0 THEN
                o_Error_Code := '1';
                o_Error_Msg := 'Aadhar No. < ' || i_Ent_uid_no || ' > is already present in system,So Skipped.';
               RETURN;
              END IF;

              BEGIN
                SELECT DECODE(e.Ent_Uid_No ,'','',F_Aadhar_Decr(e.Ent_Encr_Uid_No)), NVL( e.ent_uid_verified_yn,'N')
                       INTO l_Previous_Uid_No, l_priv_flag
                  FROM Entity_Master E
                  WHERE e.ent_id=i_ent_id;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_Ent_Uid_Verified_YN := 'N';
                  l_Previous_Uid_No := NULL;
                  l_priv_flag := 'N';
              END;

              IF l_Previous_Uid_No IS NULL THEN
                l_Ent_Uid_Verified_YN := 'N';
                 l_priv_flag := 'N';
              ELSE
                IF l_Previous_Uid_No = i_Ent_uid_no THEN
                  l_Ent_Uid_Verified_YN := l_priv_flag;
                ELSE
                   l_Ent_Uid_Verified_YN := 'N';
                END IF;
              END IF;

             END IF ;-- aadhar end

             IF Nvl(l_Ent_Mobile_Declr,'N') = 'N' AND i_Ent_Mobile_No IS NOT NULL THEN
                BEGIN
                 SELECT 1
                 INTO l_Dup_mobile_Exist
                   FROM Dual
                  WHERE EXISTS
                   (SELECT Ent_Mobile_no
                      FROM Entity_Master
                     WHERE Ent_Mobile_no = i_Ent_Mobile_No
                       AND ent_exch_client_id <> l_ENT_EXCH_CLIENT_ID
                       AND Ent_id <> i_Ent_Id
                       AND Ent_Status IN ( 'E','D')
                  UNION
                    SELECT Ent_Mobile_no
                      FROM Entity_Master_Int
                     WHERE Ent_Mobile_no = i_Ent_Mobile_No
                       AND Ent_Status IN ( 'E','D')
                       AND ent_exch_client_id <> l_ENT_EXCH_CLIENT_ID
                       AND Ent_id <> i_Ent_Id
                       AND Ent_Rec_Status = 'P');
                EXCEPTION
                   when No_Data_Found then
                     l_Dup_mobile_Exist := '0';
                 WHEN OTHERS THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'Error while validating Mobile.';
                 RETURN;
                END;
                IF l_Dup_mobile_Exist = 1 THEN
                  o_Error_Code := '1';
                  o_Error_Msg  := 'This Mobile no. is already mapped to another client. Pls contact customer care or nearest branch to submit declaration.';
                  RETURN;
                END IF;
             END IF;

             IF i_Ent_Mobile_No_2 IS NOT NULL THEN
                IF Pkg_Masters.F_Check_Number(i_Ent_Mobile_No_2) != 'Y' THEN
                    o_Error_Code := '1';
                   o_Error_Msg := 'Mobile No. 2 has to be numeric.';
                   RETURN;
                END IF;
                 IF length(i_Ent_Mobile_No_2) > 15 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'Mobile No. 2 cannot be more than 15 characters.';
                 RETURN;
               END IF;
                 IF length(i_Ent_Mobile_No_2) < 5 THEN
                   o_Error_Code := '1';
                   o_Error_Msg  := 'Mobile No. 2 cannot be less than 5 characters.';
                 RETURN;
               END IF;
                 IF TO_NUMBER(i_Ent_Mobile_No_2) = 0 THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'Mobile No. 2 cannot contain all zeros.';
                    RETURN;
                END IF;

                 IF i_Ent_Mobile_No IS NULL THEN
                   o_Error_Code := '1';
                   o_Error_Msg := 'Please enter Mobile No. 1 first.';
                   RETURN;
                 ELSE
                     IF Pkg_Masters.F_Check_Number(i_Ent_Mobile_No_2) != 'Y' THEN
                        o_Error_Code := '1';
                        o_Error_Msg := 'Mobile no. 2 should be numeric.';
                        RETURN;
                     ELSE
                         IF (i_Ent_Mobile_No = i_Ent_Mobile_No_2) THEN
                             o_Error_Code := '1';
                            o_Error_Msg := 'Mobile No. 1 and Mobile No. 2 should not be same.';
                            RETURN;
                         ELSE
                            IF (SUBSTR(i_Ent_Mobile_No_2,1,1) = '0' AND SUBSTR(i_Ent_Mobile_No_2,2) = i_Ent_Mobile_No) OR
                                (SUBSTR(i_Ent_Mobile_No_2,1,2) = '91' AND SUBSTR(i_Ent_Mobile_No_2,3) = i_Ent_Mobile_No)
                            THEN
                              o_Error_Code := '1';
                              o_Error_Msg := 'Mobile No. 1 and Mobile No. 2 should not be same.';
                              RETURN;
                            END IF;

                            IF (SUBSTR(i_Ent_Mobile_No,1,1) = '0' AND SUBSTR(i_Ent_Mobile_No,2) = i_Ent_Mobile_No_2) OR
                                (SUBSTR(i_Ent_Mobile_No,1,2) = '91' AND SUBSTR(i_Ent_Mobile_No,3) = i_Ent_Mobile_No_2)
                            THEN
                               o_Error_Code := '1';
                              o_Error_Msg := 'Mobile No. 1 and Mobile No. 2 should not be same.';
                              RETURN;
                           END IF;

                           IF (SUBSTR(i_Ent_Mobile_No,1,1) = '0' AND
                                SUBSTR(i_Ent_Mobile_No_2,1,2) = '91' AND
                                SUBSTR(i_Ent_Mobile_No,2) = SUBSTR(i_Ent_Mobile_No_2,3))
                               OR
                               (SUBSTR(i_Ent_Mobile_No,1,2) = '91' AND
                                SUBSTR(i_Ent_Mobile_No_2,1,1) = '0' AND
                                SUBSTR(i_Ent_Mobile_No,3) = SUBSTR(i_Ent_Mobile_No_2,2))
                           THEN
                               o_Error_Code := '1';
                               o_Error_Msg := 'Mobile No. 1 and Mobile No. 2 should not be same.';
                               RETURN;
                           END IF;
                        END IF;
                    END IF;
                END IF;

                IF l_Ent_Ctg_Desc IN ('01','36')THEN
                   IF SUBSTR(i_Ent_Mobile_No_2,1,1) = '0' then
                      o_Error_Code := '1';
                      o_Error_Msg := 'Mobile No 2. cannot start with number 0 for Individual Client';
                       RETURN;
                   END IF;
                   IF LENGTH(i_Ent_Mobile_No_2) <> 10 then
                      o_Error_Code := '1';
                      o_Error_Msg := 'Mobile No 2. should be of 10 digits only for Individual Client.';
                       RETURN;
                   END IF;
                END IF;

            END IF;

            IF i_Ent_Fax_No_1 IS NOT NULL THEN
               IF Pkg_Masters.F_Check_Number(i_Ent_Fax_No_1) != 'Y' THEN
                   o_Error_Code := '1';
                  o_Error_Msg := 'Fax No. 1 has to be numeric.';
                  RETURN;
               END IF;
            END IF;

           l_occupation := i_occupation;  --i_occupation_other
            IF SUBSTR(l_occupation, 1, 6) = 'Others' THEN
             IF Instr(l_occupation,'|',1) = 7 THEN
              l_ENT_OTHERS_OCC_REASON := NULL;
              l_reason_len := length(l_occupation) - 7;
              l_ENT_OTHERS_OCC_REASON := SUBSTR(l_occupation, 8, l_reason_len);
              l_occupation := 'Others';
             ELSE
             o_Error_Code := '1';
             o_Error_Msg  := 'Failed to update ENTITY_MASTER_INT record because of invalid format used to send Remarks for others occupation' ||SQLERRM;
             RETURN;
             END IF;
           END IF;


           IF l_occupation = 'Others' AND l_ENT_OTHERS_OCC_REASON IS NULL THEN
            o_Error_Code := '1';
            o_Error_Msg  := 'Failed to update ENTITY_MASTER_INT record because of Occupation others should have remarks' ||SQLERRM;
            RETURN;
           END IF;




            BEGIN
                 SELECT 'Y' "Occupation Exists"
                 INTO l_occ_exists
                 FROM DUAL
                 WHERE UPPER(l_Occupation) IN (SELECT UPPER(trim(RV_LOW_VALUE))
                                        FROM CG_REF_CODES
                                        WHERE UPPER(RV_DOMAIN) = 'OCCUPATION');
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_occ_exists := 'N';
                 WHEN OTHERS THEN
                      l_occ_exists := 'N';
            END;

            IF l_occ_exists <> 'Y' THEN
               o_Error_Code := '1';
               o_Error_Msg  := 'Failed to update ENTITY_MASTER_INT record because of invalid occupation passed from KYC page:' ||SQLERRM;
               RETURN;
            END IF;





            /*End: Validations for KYC demographic fields --comments by Piyush*/

            /*Fetch Rec_Status and Rec_Seq_No from ENTITY_MASTER_INT for maximum Rec_Seq_No*/
            BEGIN
               SELECT e.ent_rec_status,e.ent_rec_seq_no
               INTO l_ent_rec_status,l_ent_rec_seq_no
               FROM entity_master_int e
               WHERE e.ent_id = l_Ent_Id AND
                     e.ent_rec_seq_no =
                     (SELECT max(ent_rec_seq_no)
                      FROM entity_master_int
                      WHERE ent_id = l_Ent_Id);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    SELECT 'A',0
                    INTO l_ent_rec_status,l_ent_rec_seq_no
                    FROM entity_master e
                    WHERE e.ent_id = l_Ent_Id;
               WHEN OTHERS THEN
                    l_ent_rec_status := 'N'; /*Set to 'N' for all records whose status is not 'A'*/
                    l_ent_rec_seq_no := 0;
            END;

            IF Nvl(l_ent_rec_status, 'X') <> 'A' THEN
               o_Error_Code := '1E';
               o_Error_Msg  := 'Unable to update demographic details. Please contact customer care';
               ROLLBACK;
               RETURN;
            END IF;
            /*End: v1.7*/

            /*Start: v2.0*/
            IF l_ent_rec_seq_no = 0 THEN
               l_Ent_Rec_Seq_No := l_Ent_Rec_Seq_No + 1;
               /*Insert OLD record into master table from its respective intermediate table --comments by Piyush*/
               Pkg_Common_Client_Updation.p_Ins_Mstr_Into_Int(l_Ent_Id,i_Pgm_Id,l_Ent_Rec_Seq_No,o_Error_Code,o_Error_Msg/*,i_application_id*/);
               IF o_Error_Code = 'FAIL' THEN
                 o_Error_Code := '1';
                 o_Error_Msg  := 'Failed for Rec_Seq_No: '||l_Ent_Rec_Seq_No||'. Error Mssg: '||o_Error_Msg;
                 RETURN;
               END IF;

               BEGIN
                  UPDATE ENTITY_MASTER_INT
                     SET ENT_REC_STATUS          = 'A',
                         ENT_REC_REMARKS         = 'Updated from demographic change screen',
                         ENT_LAST_UPDT_BY        = i_application_user_id,
                         ENT_LAST_UPDT_DT        = sysdate,
                         ENT_PRG_ID              = i_Pgm_Id
                   WHERE ent_id = l_Ent_Id
                     AND ent_rec_seq_no = l_ent_rec_seq_no;
                EXCEPTION
                  WHEN OTHERS THEN
                    o_Error_Code := '1';
                    o_Error_Msg  := 'Failed to update ENTITY_MASTER_INT record:' ||SQLERRM;
                    ROLLBACK;
                    RETURN;
                END;

               /*Insert NEW record into master table from its respective intermediate table for updation --comments by Piyush*/
               l_Ent_Rec_Seq_No := l_Ent_Rec_Seq_No + 1;
               Pkg_Common_Client_Updation.p_Ins_Mstr_Into_Int(l_Ent_Id,i_Pgm_Id,l_Ent_Rec_Seq_No,o_Error_Code,o_Error_Msg/*,i_application_id*/);
               IF o_Error_Code = 'FAIL' THEN
                 o_Error_Code := '1';
                 o_Error_Msg  := 'Failed for Rec_Seq_No: '||l_Ent_Rec_Seq_No||'. Error Mssg: '||o_Error_Msg;
                 RETURN;
               END IF;

            ELSE
               /*Insert NEW record into master table from its respective intermediate table for updation --comments by Piyush*/
               l_Ent_Rec_Seq_No := l_Ent_Rec_Seq_No + 1;
               Pkg_Common_Client_Updation.p_Ins_Mstr_Into_Int(l_Ent_Id,i_Pgm_Id,l_Ent_Rec_Seq_No,o_Error_Code,o_Error_Msg/*,i_application_id*/);
               IF o_Error_Code = 'FAIL' THEN
                 o_Error_Code := '1';
                 o_Error_Msg  := 'Failed for Rec_Seq_No: '||l_Ent_Rec_Seq_No||'. Error Mssg: '||o_Error_Msg;
                 RETURN;
               END IF;

            END IF;
            /*End: v2.0*/

            /*Update NEW record inserted into ENTITY_MASTER_INT with data passed from KYC --comments by Piyush*/
            BEGIN
              UPDATE ENTITY_MASTER_INT
                 SET ENT_PHONE_NO_1          = i_Ent_Phone_No_1,
                     ENT_PHONE_NO_2          = i_Ent_Phone_No_2,
                     ENT_MOBILE_NO           = i_Ent_Mobile_No,
                     ENT_MOBILE_NO_2         = i_Ent_Mobile_No_2,--v1.7
                     ENT_FAX_NO_1            = i_Ent_Fax_No_1,
                     ENT_ISD_CODE_PHONE_NO_1 = i_Ent_Isd_1,
                     ENT_ISD_CODE_PHONE_NO_2 = i_Ent_Isd_2,
                     ENT_STD_CODE_PHONE_NO_1 = i_Ent_Std_1,
                     ENT_STD_CODE_PHONE_NO_2 = i_Ent_Std_2,
                     ENT_REC_STATUS          = 'A',
                     ENT_REC_REMARKS         = 'Updated from demographic change screen',
                     ENT_LAST_UPDT_BY        = i_application_user_id,
                     ENT_LAST_UPDT_DT        = sysdate,
                     ENT_PRG_ID              = i_Pgm_Id,
                     ENT_ACCEPTED_BY         = nvl(ENT_ACCEPTED_BY,decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y',i_Accepted_By,ENT_ACCEPTED_BY),ENT_ACCEPTED_BY)),--i_Accepted_By,--v1.7
                     ENT_ACCEPTANCE_DT       = nvl(ENT_ACCEPTANCE_DT,decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y',SYSDATE,ENT_ACCEPTANCE_DT),ENT_ACCEPTANCE_DT)),--SYSDATE,--v1.7
                     ENT_OCCUPATION          = l_Occupation,--v1.7
                     ENT_OTHERS_OCC_REASON   = l_ENT_OTHERS_OCC_REASON,
                     ENT_DISPATCH_MODE       = decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y','E',ENT_DISPATCH_MODE),ENT_DISPATCH_MODE),--v1.7
                     ENT_GST_NO              = Nvl(i_Gst_No,ENT_GST_NO),
                     ENT_UID_NO              = i_Ent_Uid_No,
                     ENT_UID_VERIFIED_YN     = l_Ent_Uid_Verified_YN
               WHERE ent_id = l_Ent_Id
                 AND ent_rec_seq_no = l_ent_rec_seq_no;
            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update ENTITY_MASTER_INT record:' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;

             BEGIN
              UPDATE Entity_Registration_DTLS_INT
                 SET erd_adh_no               = i_Ent_Uid_No,
                     erd_update_by            = 'KYCOWNER',
                     erd_update_dt            = sysdate,
                     erd_prg_id               = i_Pgm_Id
               WHERE erd_ent_id = l_Ent_Id
                 AND erd_rec_seq_no  = l_ent_rec_seq_no;
            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update ENTITY_REGISTARTION_DETAILS record:' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;

            /*Update NEW record inserted into ENTITY_MASTER with data passed from KYC --comments by Piyush*/
            BEGIN
              UPDATE ENTITY_MASTER
                 SET ENT_PHONE_NO_1          = i_Ent_Phone_No_1,
                     ENT_PHONE_NO_2          = i_Ent_Phone_No_2,
                     ENT_MOBILE_NO           = i_Ent_Mobile_No,
                     ENT_MOBILE_NO_2         = i_Ent_Mobile_No_2,--v1.7
                     ENT_FAX_NO_1            = i_Ent_Fax_No_1,
                     ENT_ISD_CODE_PHONE_NO_1 = i_Ent_Isd_1,
                     ENT_ISD_CODE_PHONE_NO_2 = i_Ent_Isd_2,
                     ENT_STD_CODE_PHONE_NO_1 = i_Ent_Std_1,
                     ENT_STD_CODE_PHONE_NO_2 = i_Ent_Std_2,
                     ENT_REC_STATUS          = 'A',
                     ENT_REC_REMARKS         = 'Updated from demographic change screen',
                     ENT_LAST_UPDT_BY        = i_application_user_id,
                     ENT_LAST_UPDT_DT        = sysdate,
                     ENT_PRG_ID              = i_Pgm_Id,
      --               ENT_ACCEPTED_BY         = i_Accepted_By,--v1.7
      --               ENT_ACCEPTANCE_DT       = SYSDATE,--v1.7
                     ENT_ACCEPTED_BY         = nvl(ENT_ACCEPTED_BY,decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y',i_Accepted_By,ENT_ACCEPTED_BY),ENT_ACCEPTED_BY)),--i_Accepted_By,--v1.7
                     ENT_ACCEPTANCE_DT       = nvl(ENT_ACCEPTANCE_DT,decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y',SYSDATE,ENT_ACCEPTANCE_DT),ENT_ACCEPTANCE_DT)),--SYSDATE,--v1.7
                     ENT_OCCUPATION          = l_Occupation,--v1.7
                     ENT_OTHERS_OCC_REASON   = l_ENT_OTHERS_OCC_REASON,
                     ENT_DISPATCH_MODE       = decode(ENT_DISPATCH_MODE,'C',decode(i_Email_Fl,'Y','E',ENT_DISPATCH_MODE),ENT_DISPATCH_MODE),--v1.7
                     ENT_GST_NO              = Nvl(i_Gst_No,ENT_GST_NO),
                     ENT_UID_NO              = i_Ent_Uid_No,
                     ENT_UID_VERIFIED_YN     = l_Ent_Uid_Verified_YN
               WHERE ent_id = l_Ent_Id;
            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update ENTITY_MASTER record:' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;
             /*Update/Insert record into Entity_Registration_Details with data passed from KYC --comments by Piyush*/
             BEGIN
              UPDATE Entity_Registration_Details
                 SET erd_adh_no               = i_Ent_Uid_No,
                     erd_update_by            = 'KYCOWNER',
                     erd_update_dt            = sysdate,
                     erd_prg_id               = i_Pgm_Id
               WHERE erd_ent_id = l_Ent_Id;
            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update ENTITY_REGISTARTION_DETAILS record:' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;

            /*Update/Insert record into ENTITY_DETAILS with data passed from KYC --comments by Piyush*/
            BEGIN
            IF (i_End_Email_Id IS NOT NULL) THEN  --V1.5
              /*Reset Default Flag for all the Email Ids in ENTITY_DETAILS for the Entity Id passed from KYC --comments by Piyush*/
              UPDATE ENTITY_DETAILS
                 SET END_DEFAULT_FLAG = 'N',
                     END_LAST_UPDT_DT = sysdate,
                     END_LAST_UPDT_BY = i_application_user_id,
                     END_PRG_ID       = i_Pgm_Id
               WHERE end_id = l_Ent_Id;

               UPDATE ENTITY_DETAILS_INT
                 SET END_DEFAULT_FLAG = 'N',
                     END_LAST_UPDT_DT = sysdate,
                     END_LAST_UPDT_BY = i_application_user_id,
                     END_PRG_ID       = i_Pgm_Id
               WHERE end_id           = l_Ent_Id
                 AND END_REC_SEQ_NO   = l_ent_rec_seq_no;

              BEGIN
                    SELECT 'Y'
                      into l_email_exists
                      FROM entity_details
                     WHERE END_ID = l_Ent_Id AND END_EMAIL_ID = i_End_Email_Id;
              EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            l_email_exists := 'N';
                       WHEN OTHERS THEN
                            l_email_exists := 'N';
              END;
               /*If Email Id exists, Update ENTITY_DETAILS with data passed from KYC and set the Default Flag to 'Y'.
                 If Email Id does not exist, Insert ENTITY_DETAILS with data passed from KYC and set the Default Flag to 'Y'.*/


                IF l_email_exists = 'Y' THEN
                  UPDATE ENTITY_DETAILS
                     SET END_EMAIL_ID     = i_End_Email_Id,
                         End_Status       = 'A',
                         END_CC_TO        = i_End_Cc_To,
                         END_BCC_TO       = i_End_Bcc_To,
                         END_DEFAULT_FLAG = 'Y',
                         END_LAST_UPDT_DT = SYSDATE,
                         END_LAST_UPDT_BY = i_application_user_id,
                         END_PRG_ID       = i_Pgm_Id
                   WHERE End_Id = l_Ent_Id
                   AND END_EMAIL_ID = i_End_Email_Id;

                  UPDATE ENTITY_DETAILS_INT
                     SET END_EMAIL_ID     = i_End_Email_Id,
                         End_Status       = 'A',
                         END_CC_TO        = i_End_Cc_To,
                         END_BCC_TO       = i_End_Bcc_To,
                         END_DEFAULT_FLAG = 'Y',
                         END_LAST_UPDT_DT = SYSDATE,
                         END_LAST_UPDT_BY = i_application_user_id,
                         END_PRG_ID       = i_Pgm_Id
                   WHERE End_Id = l_Ent_Id
                     AND END_EMAIL_ID = i_End_Email_Id
                     AND END_REC_SEQ_NO = l_ent_rec_seq_no;
                ELSE
                  INSERT INTO ENTITY_DETAILS
                    (END_ID,
                     END_EMAIL_ID,
                     END_CC_TO,
                     END_BCC_TO,
                     END_LAST_UPDT_DT,
                     END_LAST_UPDT_BY,
                     END_PRG_ID,
                     END_DEFAULT_FLAG)
                  VALUES
                    (l_Ent_Id,
                     i_End_Email_Id,
                     i_End_Cc_To,
                     i_End_Bcc_To,
                     SYSDATE,
                     i_application_user_id,
                     i_Pgm_id,
                     'Y');

                  INSERT INTO ENTITY_DETAILS_INT
                    (END_ID
                    ,END_EMAIL_ID
                    ,END_CC_TO
                    ,END_BCC_TO
                    ,END_CREAT_By
                    ,END_CREAT_Dt
                    ,END_PRG_ID
                    ,END_REC_SEQ_NO
                    ,END_DEFAULT_FLAG)
                  VALUES
                    (l_Ent_Id,
                     i_End_Email_Id,
                     i_End_Cc_To,
                     i_End_Bcc_To,
                     i_application_user_id,
                     SYSDATE,
                     i_Pgm_id,
                     l_ent_rec_seq_no,
                     'Y');
                END IF;
              END IF; --V1.5

            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update ENTITY_DETAILS record' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;

            /*Start: v1.7*/
            /*Update/Insert record into ENTITY_INCOME_DETAILS with data passed from KYC --comments by Piyush*/
            BEGIN
              
                SELECT PAM_CURR_DT
                INTO l_pam_cur_date
                FROM PARAMETER_MASTER;
                
                BEGIN
                     SELECT APM_START_PERIOD, APM_END_PERIOD
                     INTO l_apm_start_period, l_apm_end_period
                     FROM ACCOUNT_PERIOD_MASTER
                     WHERE APM_CURRENT_FLAG = 'Y' AND APM_CLOSED_STATUS = 'O';
                EXCEPTION
                     WHEN OTHERS THEN
                          o_Error_Code := '1';
                          o_Error_Msg  := 'Fatal error occured while querying data from ACCOUNT_PERIOD_MASTER. Cannot proceed further.' ||SQLERRM;
                          ROLLBACK;
                          RETURN;
                END;

                BEGIN
                     SELECT RV_LOW_VALUE, RV_HIGH_VALUE
                     INTO l_fin_yr_start_dt, l_fin_yr_end_dt
                     FROM CG_REF_CODES
                     WHERE RV_DOMAIN = 'FINANCIAL_YEAR';
                EXCEPTION
                     WHEN OTHERS THEN
                          o_Error_Code := '1';
                          o_Error_Msg  := 'Fatal error occured while querying current financial year''s start date and end date from CG_REF_CODES. Cannot proceed further.' ||SQLERRM;
                          ROLLBACK;
                          RETURN;
                END;

        SELECT DECODE(I_INCOME_RANGE,
                        'Less than 1 lac',
                        '< 1 lac',
                        '< 1 LAC',
                        '< 1 lac',
                        '1 lac to 5 lac',
                        '1 lac to 5 lac',
                        '5 lac to 10 lac',
                        '5 lac to 10 lac',
                        '10 lac to 25 lac',
                        '10 lac to 25 lac',
                        'Greater than 25 lac',
                        '> 25 lac',
                        I_INCOME_RANGE)
            INTO L_GROSS_INCOME
            FROM DUAL;

        IF L_GROSS_INCOME IS NOT NULL THEN
            L_INCOME_RANGE := 0;
            BEGIN
              SELECT 1
                INTO L_INCOME_RANGE
                FROM CG_REF_CODES
               WHERE RV_DOMAIN = 'INCOME_SLAB'
                 AND RV_LOW_VALUE = L_GROSS_INCOME;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                L_INCOME_RANGE := 0;
            END;

            IF L_INCOME_RANGE = 0 THEN
          O_ERROR_CODE := '1';
          O_ERROR_MSG  := 'Income range format is not correct.';
          RETURN;
      END IF;
      ELSE                                     --NN FOR MANDATORY INCOME RANGE
        O_ERROR_CODE := '1';
        O_ERROR_MSG  := 'Income range cannot be NULL.';
        RETURN;
    END IF;

                BEGIN
                     SELECT 'Y'
                     INTO l_gross_income_exists
                     FROM ENTITY_INCOME_DTLS
                     WHERE EID_ENT_ID = l_Ent_Id AND EID_FROM_YR = l_apm_start_period AND EID_TO_YR  = l_apm_end_period;
                EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          l_gross_income_exists := 'N';
                     WHEN OTHERS THEN
                          l_gross_income_exists := 'N';
                END;

                IF l_gross_income_exists = 'Y' THEN
                   --l_Old_Gross_Income := NULL;

                  /*BEGIN
                   SELECT EID_GROSS_INCOME
                     INTO l_Old_Gross_Income
                     FROM ENTITY_INCOME_DTLS
                    WHERE EID_ENT_ID = l_Ent_Id
                      AND EID_FROM_YR = l_apm_start_period
                      AND EID_TO_YR  = l_apm_end_period;
                   EXCEPTION
                     WHEN OTHERS THEN
                       o_Error_Code := '1';
                       o_Error_Msg  := 'Unable to fetch Gross Income for Entity <'||l_Ent_Id||'>' ||SQLERRM;
                   END;*/

                   --IF l_Old_Gross_Income IS NOT NULL THEN
                      --IF l_Old_Gross_Income <> i_Income_Range THEN
                         UPDATE Entity_Master_Int
                            SET ENT_INCOME_DATE = trunc(SYSDATE)
                          WHERE ent_id          = l_Ent_Id
                            AND Ent_Rec_Seq_No  = l_ent_rec_seq_no;

                          UPDATE Entity_Master
                            SET ENT_INCOME_DATE = trunc(SYSDATE)
                          WHERE ent_id          = l_Ent_Id;
                      --END IF;
                   --END IF;

                   UPDATE ENTITY_INCOME_DTLS
                   SET    EID_GROSS_INCOME = L_GROSS_INCOME,
                          EID_PRG_ID       = i_Pgm_Id,
                          EID_LAST_UPDT_DT = SYSDATE,
                          EID_LAST_UPDT_BY = i_application_user_id
                   WHERE  EID_ENT_ID = l_Ent_Id
                   AND    EID_FROM_YR = l_apm_start_period
                   AND    EID_TO_YR  = l_apm_end_period;

                   UPDATE ENTITY_INCOME_DTLS_INT
                   SET    EID_GROSS_INCOME = L_GROSS_INCOME,
                          EID_PRG_ID       = i_Pgm_Id,
                          EID_LAST_UPDT_DT = SYSDATE,
                          EID_LAST_UPDT_BY = i_application_user_id
                   WHERE  EID_ENT_ID = l_Ent_Id
                   AND    EID_FROM_YR = l_apm_start_period
                   AND    EID_TO_YR  = l_apm_end_period
                   AND    EID_REC_SEQ_NO =l_ent_rec_seq_no;
                ELSE
                   INSERT INTO ENTITY_INCOME_DTLS
                          (EID_ENT_ID,
                           EID_FROM_YR,
                           EID_TO_YR,
                           EID_GROSS_INCOME,
                           EID_PRG_ID,
                           EID_LAST_UPDT_DT,
                           EID_LAST_UPDT_BY
                          )
                   VALUES
                         (l_Ent_Id,
                          to_date(l_fin_yr_start_dt),--decode(sign(3-to_number(to_char(pam_curr_dt,'MM'))),-1,add_months(trunc(pam_curr_dt,'YYYY'),3),add_months(trunc(pam_curr_dt,'YYYY'),-9))
                          to_date(l_fin_yr_end_dt),--decode(sign(3-to_number(to_char(pam_curr_dt,'MM'))),-1,add_months(last_day(trunc(pam_curr_dt,'YYYY')),15),add_months(last_day(trunc(pam_curr_dt,'YYYY')),2))
                          L_GROSS_INCOME,
                          i_Pgm_Id,
                          SYSDATE,
                          i_application_user_id
                         );

                   INSERT INTO ENTITY_INCOME_DTLS_INT
                          (EID_ENT_ID,
                           EID_FROM_YR,
                           EID_TO_YR,
                           EID_GROSS_INCOME,
                           EID_PRG_ID,
                           EID_CREAT_DT,
                           EID_CREAT_BY,
                           EID_REC_SEQ_NO
                          )
                   VALUES
                         (l_Ent_Id,
                          to_date(l_fin_yr_start_dt),--decode(sign(3-to_number(to_char(pam_curr_dt,'MM'))),-1,add_months(trunc(pam_curr_dt,'YYYY'),3),add_months(trunc(pam_curr_dt,'YYYY'),-9))
                          to_date(l_fin_yr_end_dt),--decode(sign(3-to_number(to_char(pam_curr_dt,'MM'))),-1,add_months(last_day(trunc(pam_curr_dt,'YYYY')),15),add_months(last_day(trunc(pam_curr_dt,'YYYY')),2))
                          L_GROSS_INCOME,
                          i_Pgm_Id,
                          SYSDATE,
                          i_application_user_id,
                          l_ent_rec_seq_no
                         );

                   UPDATE Entity_Master_Int
                      SET ENT_INCOME_DATE = trunc(SYSDATE)
                    WHERE ent_id          = l_Ent_Id
                      AND Ent_Rec_Seq_No  = l_ent_rec_seq_no;

                    UPDATE Entity_Master
                      SET ENT_INCOME_DATE = trunc(SYSDATE)
                    WHERE ent_id          = l_Ent_Id;
                END IF;
                
            SELECT E.ENT_INCOME_DATE              --NN FOR INCOME DATE WITHIN 1YR
            INTO L_ENT_INCOME_DT
            FROM ENTITY_MASTER E 
            WHERE E.ENT_ID = L_ENT_ID;
            
            IF Add_Months(l_pam_cur_date, -12) > l_ent_income_dt THEN --NN FOR INCOME DATE WITHIN 1YR
                UPDATE Entity_Master_Int
                SET ENT_INCOME_DATE = trunc(SYSDATE)
                WHERE ent_id          = l_Ent_Id
                AND Ent_Rec_Seq_No  = l_ent_rec_seq_no;

                UPDATE Entity_Master
                SET ENT_INCOME_DATE = trunc(SYSDATE)
                WHERE ent_id          = l_Ent_Id;
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
                  o_Error_Code := '1';
                  o_Error_Msg  := 'Failed to update/insert ENTITY_INCOME_DTLS record' ||SQLERRM;
                  ROLLBACK;
                  RETURN;
            END;
            /*End: v1.7*/

            /*Update Entity_Dmg_Chng with data passed from KYC and reset demographic flag --comments by Piyush*/
            BEGIN
              UPDATE entity_dmg_chng
                 SET edc_report_id           = i_Pgm_Id,
                     edc_entity_dmg_flag     = 'N',
                     edc_application_id      = i_application_id,
                     edc_application_user_id = i_application_user_id,
                     edc_last_updt_dt        = sysdate,
                     edc_last_updt_by        = i_application_user_id
               WHERE edc_ent_id = l_Ent_Id;
            EXCEPTION
              WHEN OTHERS THEN
                o_Error_Code := '1';
                o_Error_Msg  := 'Failed to update entity_dmg_chng flag:' ||SQLERRM;
                ROLLBACK;
                RETURN;
            END;
      END;
    END LOOP;
    o_Error_Code := '0';
    o_Error_Msg  := 'Successfully updated changes';
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      o_Error_Code := SQLCODE;
      o_Error_Msg  := SQLERRM;
      ROLLBACK;
  END p_Update_Ent_Dtls;

  /************************************************************************/

FUNCTION f_get_I_Agree_Flag RETURN VARCHAR2 IS
  O_I_Agree_flag CG_REF_CODES.RV_LOW_VALUE %TYPE;


  BEGIN
       SELECT RV_LOW_VALUE
       INTO O_I_Agree_flag
       FROM CG_REF_CODES
       WHERE RV_DOMAIN = 'FORCED_ECN';

       return O_I_Agree_flag;

 EXCEPTION

       WHEN NO_DATA_FOUND THEN
       O_I_Agree_flag := 'O';
       return O_I_Agree_flag;
       WHEN OTHERS THEN
       O_I_Agree_flag := 'O';
       return O_I_Agree_flag;
  END f_get_I_Agree_Flag;


END Pkg_Ent_Dmg_Chng_Dtls;
/
