CREATE OR REPLACE PACKAGE Pkg_Mfss_Securities_Settlement
AS

  g_Count_Directory NUMBER := 0;
  g_Company_Title   VARCHAR2(500);

  TYPE t_Trd_Details IS TABLE OF Mfss_Trades%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE Tab_Err_Msg IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  PROCEDURE P_Qry_Trades_Mfss(p_Qry     IN VARCHAR2,
                              t_Tab_Qry IN OUT t_Trd_Details);

  FUNCTION F_Get_Field (P_Category_Code IN VARCHAR2,
                        p_Series        IN VARCHAR2,
                        p_Field         IN VARCHAR2,
                        p_yn            IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE P_Download_Order_File(P_File_Name  IN VARCHAR2,
                                  P_Final_Flag IN VARCHAR2,
                                  P_Exch_Id    IN VARCHAR2,
                                  P_Source     IN VARCHAR2,
                                  P_Ret_Val    IN OUT VARCHAR2,
                                  P_Ret_Msg    IN OUT VARCHAR2);

  PROCEDURE P_Load_Allotment_File(p_File_Name           IN VARCHAR2,
                                  p_Exch_Id             IN VARCHAR2,
                                  p_Success_Reject_Flag IN VARCHAR2,
                                  p_Ret_Val             IN OUT VARCHAR2,
                                  p_Ret_Msg             IN OUT VARCHAR2);

  PROCEDURE P_Load_Redemption_File(p_File_Name           IN VARCHAR2,
                                   p_Exch_Id             IN VARCHAR2,
                                   p_Success_Reject_Flag IN VARCHAR2,
                                   p_Ret_Val             IN OUT VARCHAR2,
                                   p_Ret_Msg             IN OUT VARCHAR2);

  PROCEDURE P_Dwnld_Securities_Obg_Rep(p_File_Name IN VARCHAR2,
                                       p_Exch_Id   IN VARCHAR2,
                                       p_Ret_Val   IN OUT VARCHAR2,
                                       p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_Gen_Sec_Confirmation_Stmt(p_Exch_Id IN VARCHAR2,
                                        p_Gen_Dt  IN DATE,
                                        p_Ret_Val IN OUT VARCHAR2,
                                        p_Ret_Msg IN OUT VARCHAR2);

  PROCEDURE P_Dwnld_Sec_Conf_Stmt(p_File_Name IN VARCHAR2,
                                  p_Exch_Id   IN VARCHAR2,
                                  p_Ret_Val   IN OUT VARCHAR2,
                                  p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE p_Gen_Mfss_Order_Comfirm_Note(P_Entity_Id  IN VARCHAR2,
                                          P_Exch_Id    IN VARCHAR2,
                                          P_Order_Date IN DATE,
                                          P_Print_Flag  IN  VARCHAR2,
                                          P_Rep_Gen_Seq_Print OUT Std_Lib.Tab,
                                          P_Ret_Val    IN OUT VARCHAR2,
                                          P_Ret_Msg    IN OUT VARCHAR2);

  PROCEDURE P_Gen_Mfe_Order_Confirm_Note (p_From_Date     IN  DATE,
                                          p_To_Date       IN  DATE,
                                          p_Exch_Id       IN  VARCHAR2,
                                          p_From_Ent_Id   IN  VARCHAR2,
                                          p_To_Ent_Id     IN  VARCHAR2,
                                          P_Bounced_Flag  IN  VARCHAR2,
                                          P_Dispatch_Mode IN  VARCHAR2,
                                          P_Print_Flag    IN  VARCHAR2,
                                          P_Rep_Seq_No    OUT NUMBER,
                                          p_Ret_Val       OUT VARCHAR2,
                                          p_Ret_Msg       OUT VARCHAR2);

  PROCEDURE p_Gen_Mfe_Order_Conf_Note_CSV (p_From_Date     IN  DATE,
                                           p_To_Date       IN  DATE,
                                           p_Exch_Id       IN  VARCHAR2,
                                           p_From_Ent_Id   IN  VARCHAR2,
                                           p_To_Ent_Id     IN  VARCHAR2,
                                           P_Bounced_Flag  IN  VARCHAR2,
                                           P_Dispatch_Mode IN  VARCHAR2,
                                           P_Print_Flag    IN  VARCHAR2,
                                           P_Rep_Seq_No    OUT NUMBER,
                                           p_Ret_Val       OUT VARCHAR2,
                                           p_Ret_Msg       OUT VARCHAR2);

  PROCEDURE P_Dwnld_Settlmnt_Calndr_File(p_File_Name IN VARCHAR2,
                                         p_Exch_Id   IN VARCHAR2,
                                         p_Ret_Val   IN OUT VARCHAR2,
                                         p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_Sec_Release (P_Agency_Id   IN  VARCHAR2,
                           o_Status      OUT VARCHAR2);

  PROCEDURE P_Gen_Sec_Payin_File (P_Exch     IN  VARCHAR2,
                                  P_Stc_Type IN  VARCHAR2,
                                  p_Dem_Id   IN  VARCHAR2,
                                  P_Exec_Dt  IN  DATE,
                                  o_Status   OUT VARCHAR2);

  PROCEDURE P_Gen_Sec_Payout_File (P_Exch   IN  VARCHAR2,
                                   P_Date   IN  DATE,
                                   P_Dem_Id IN  VARCHAR2,
                                   p_Stc_Type IN VARCHAR2,
                                   P_Exec_Dt  IN  DATE,
                                   O_Status OUT VARCHAR2);

  PROCEDURE P_Mfd_Load_Mfss_Site_File (P_Path      IN     VARCHAR2,
                                       P_File_Name IN     VARCHAR2,
                                       P_Ret_Val   IN OUT VARCHAR2,
                                       P_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_Mfd_Load_Mfss_Bse_Site_File (P_Path      IN     VARCHAR2,
                                           P_File_Name IN     VARCHAR2,
                                           P_Ret_Val   IN OUT VARCHAR2,
                                           P_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_MFD_Load_Amfi_File( P_Path                IN VARCHAR2 ,
                                  P_File_Name           IN VARCHAR2 ,
                                  P_File_Date           IN DATE     ,
                                  P_Load_Instrument_Yn  IN VARCHAR2);

  PROCEDURE P_Mfd_Load_Mfss_Vendor_File( P_Path      IN VARCHAR2,
                                         P_File_Name IN VARCHAR2,
                                         P_Ret_Val   IN OUT VARCHAR2,
                                         P_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_Download_Nav_Master_File( p_File_Name IN VARCHAR2,
                                        p_Exch_Id   IN VARCHAR2,
                                        p_Ret_Val   IN OUT VARCHAR2,
                                        p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE P_Load_Mf_File_Sec_Hold (P_Agn_Id                IN  VARCHAR2,
                                     P_Server_Filename      IN  VARCHAR2,
                                     o_Ret_Msg              OUT VARCHAR2);

  PROCEDURE p_Get_Slip_Number(p_Dem_Id    Varchar2,
                              p_Dpm_Id    Varchar2,
                              p_Inst_Type Varchar2,
                              p_Dp_Acc_No Varchar2,
                              p_Exch_Id   Varchar2,
                              p_New_Bk_No In Out Varchar2,
                              p_New_Sl_No In Out Number,
                              p_Srl_No    In Out Number,
                              p_Inst_No   In Out Number,
                              p_Err_Msg   Out Varchar2,
                              p_Ret_Val   Out Varchar2);


  PROCEDURE P_Mfd_Load_Sip_Master_Fil_NSE   ( P_File_Name  IN  VARCHAR2,
                                               P_Ret_Val    OUT VARCHAR2,
                                               P_Ret_Msg    OUT VARCHAR2);

  PROCEDURE P_Mfd_Load_Sip_Master_Fil_BSE (P_File_Name  IN  VARCHAR2,
                                             P_Ret_Val    OUT VARCHAR2,
                                             P_Ret_Msg    OUT VARCHAR2);
                                             
  PROCEDURE P_Mfd_Load_Sip_Master_File(P_File_Name  IN  VARCHAR2,
                                     P_Ret_Val    OUT VARCHAR2,
                                     P_Ret_Msg    OUT VARCHAR2);
                                     

  PROCEDURE p_Gen_Mfd_Order_Comfirm_Note(p_Entity_Id   IN VARCHAR2,
                                            p_Exch_Id    IN VARCHAR2,
                                            p_Order_Date IN DATE,
                                            p_Ret_Val    IN OUT VARCHAR2,
                                            p_Ret_Msg    IN OUT VARCHAR2);

  PROCEDURE p_Gen_Mfss_Order_Conf_Note_vb(P_Entity_Id  IN VARCHAR2,
                                          P_Exch_Id    IN VARCHAR2,
                                          P_Order_Date IN DATE,
                                          P_Print_Flag  IN  VARCHAR2,
                                          P_Ret_Val    IN OUT VARCHAR2,
                                          P_Ret_Msg    IN OUT VARCHAR2);

END Pkg_Mfss_Securities_Settlement;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Mfss_Securities_Settlement
AS
  PROCEDURE P_Get_Company_Name IS
  BEGIN
       SELECT Cpm_Desc INTO g_Company_Title
       FROM Company_Master;
  END P_Get_Company_Name;

  PROCEDURE P_Qry_Trades_Mfss(P_Qry     IN VARCHAR2,
                              t_Tab_Qry IN OUT t_Trd_Details)
  IS

    TYPE C_Ref_Qry IS REF CURSOR;
    C_Qry_Trd    C_Ref_Qry;

  BEGIN

    t_Tab_Qry.DELETE;
    OPEN C_Qry_Trd FOR P_Qry;
    LOOP
      FETCH C_Qry_Trd BULK COLLECT
        INTO t_Tab_Qry;
      EXIT WHEN C_Qry_Trd%NOTFOUND;
    END LOOP;
  END P_Qry_Trades_Mfss;
  FUNCTION F_Get_Field (P_Category_Code IN VARCHAR2,
                          p_Series        IN VARCHAR2,
                          p_Field         IN VARCHAR2,
                          P_Yn            IN VARCHAR2)
    RETURN VARCHAR2
    IS
     l_Value VARCHAR2(30);

    BEGIN
      IF P_Yn = 'Y' THEN
        IF  P_Category_Code NOT IN ('DBTCR', 'HLIQD') THEN
          l_Value := p_Field;
        ELSE
          l_Value :=  NULL;
        END IF;
      ELSIF P_Yn = 'N' THEN
        IF P_Category_Code IN ('HLIQD') THEN
          l_Value := p_Field;
        ELSE
          l_Value :=  NULL;
        END IF;
      ELSE
       IF P_Category_Code IN ('DBTCR') THEN
          l_Value := p_Field;
        ELSE
          l_Value :=  NULL;
        END IF;
      END IF;
      RETURN l_Value;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END F_Get_Field;

  PROCEDURE P_Download_Order_File(P_File_Name  IN VARCHAR2,
                                  P_Final_Flag IN VARCHAR2,
                                  P_Exch_Id    IN VARCHAR2,
                                  P_Source     IN VARCHAR2,
                                  P_Ret_Val    IN OUT VARCHAR2,
                                  P_Ret_Msg    IN OUT VARCHAR2)
  IS

    l_Pam_Curr_Date               DATE;
    l_File_Path                   VARCHAR2(300);
    l_Log_File_Handle             Utl_File.File_Type;
    l_Log_File_Name               VARCHAR2(100);
    l_Prg_Process_Id              NUMBER := 0;
    l_Line_Count                  NUMBER := 0;
    Tab_File_Records              Std_Lib.Tab;
    Tab_Split_Record              Std_Lib.Tab;
    Line_No                       NUMBER := 0;
    l_Date                        VARCHAR(30);
    l_Time                        VARCHAR(30);
    l_Order_No                    VARCHAR2(16);
    l_Stc_No                      VARCHAR2(7);
    l_Buy_Sell_Flg                VARCHAR2(1);
    l_Allotment_Mode              VARCHAR2(1);
    l_Order_Date                  DATE;
    l_Order_Time                  VARCHAR2(30);
    l_Amc_Code                    VARCHAR2(30);
    l_Scheme_Code                 VARCHAR2(30);
    l_Rta_Code                    VARCHAR2(10);
    l_Rta_Scheme_Code             VARCHAR2(10);
    l_Scheme_Category             VARCHAR2(10);
    l_Scheme_Symbol               VARCHAR2(10);
    l_Scheme_Series               VARCHAR2(10);
    l_Scheme_Option_Type          VARCHAR2(1);
    l_Isin                        VARCHAR2(12);
    l_Quantity                    NUMBER(15,4);
    l_Amount                      NUMBER(15,2);
    l_Purchase_Type               VARCHAR2(1);
    l_Member_Code                 VARCHAR2(5);
    l_Branch_Code                 NUMBER(3);
    l_Dealer_Code                 NUMBER(5);
    l_Folio_No                    VARCHAR2(30);
    l_Payout_Mechanism            NUMBER(1);
    l_Application_No              VARCHAR2(10);
    l_Ent_Id                      VARCHAR2(10);
    l_Tax_Status                  VARCHAR2(2);
    l_Holding_Mode                VARCHAR2(30);
    l_First_Client_Name           VARCHAR2(250);
    l_First_Client_Pan            VARCHAR2(10);
    l_First_Client_Kyc_Flag       VARCHAR2(1);
    l_Second_Client_Name          VARCHAR2(250);
    l_Second_Client_Pan           VARCHAR2(10);
    l_Second_Client_Kyc_Flag      VARCHAR2(1);
    l_Third_Client_Name           VARCHAR2(250);
    l_Third_Client_Pan            VARCHAR2(10);
    l_Third_Client_Kyc_Flag       VARCHAR2(1);
    l_Guardian_Name               VARCHAR2(250);
    l_Guardian_Pan                VARCHAR2(10);
    l_Dp_Name                     VARCHAR2(30);
    l_Dp_Id                       VARCHAR2(8);
    l_Dp_Acc_No                   VARCHAR2(16);
    l_Mobile_No                   VARCHAR2(15);
    l_Bank_Acc_Type               VARCHAR2(10);
    l_Bank_Acc_No                 VARCHAR2(40);
    l_Bank_Name                   VARCHAR2(40);
    l_Bank_Branch                 VARCHAR2(40);
    l_Bank_City                   VARCHAR2(35);
    l_Micr_Code                   VARCHAR2(11);
    l_Neft_Code                   VARCHAR2(11);
    l_Rtgs_Code                   VARCHAR2(11);
    l_Email_Id                    VARCHAR2(50);
    l_Confirmation_Flag           VARCHAR2(1);
    l_Reject_Reason               VARCHAR2(300);
    l_Scheme_Name                 VARCHAR2(300);
    l_Entry_By                    NUMBER(10);
    l_Order_Status                VARCHAR2(100);
    l_Order_Remark                VARCHAR2(300);
    l_Dp_Folio_No                 VARCHAR2(30);
    l_Trd_Status                  VARCHAR2(1);
    l_Security_Id                 VARCHAR2(30);
    l_Internal_Ref_No             VARCHAR2(10);
    l_Settlement_Type             VARCHAR2(5);
    l_Order_Type                  VARCHAR2(3);
    l_Sip_Regn_No                 NUMBER;
    l_Sip_Txn_No                  NUMBER;
    l_Sip_Regn_Date               DATE;
    l_Sip_Regn_Date_String        VARCHAR2(12);
    l_Count_Inserted              NUMBER := 0;
    l_Count_Update                NUMBER := 0;
    l_Count_Records               NUMBER := 0;
    l_Count_Trades                NUMBER := 0;
    l_Count_Misdeal               NUMBER := 0;
    l_Nse_Broker_Cd               VARCHAR2(30);
    l_Bse_Broker_Cd               VARCHAR2(30);
    l_Mutual_Fund_Seg             VARCHAR2(30);
    l_Count_Confirmed_Trades      NUMBER   :=0;
    l_Count_Cancelled_Trades      NUMBER   :=0;
    l_Message                     VARCHAR2(3000);
    l_Prg_Id                      VARCHAR2(30) := 'CSSBLORDF';
    Excp_Terminate                EXCEPTION;
    Excp_Skip                     EXCEPTION;
    l_Dp_Det_Count                NUMBER := 0;
    l_Count_Cn                    NUMBER := 0;
    l_Total_Rev_Bills             NUMBER := 0;
    l_Prev_Amt                    NUMBER := 0;
    l_Prev_Status                 VARCHAR2(1);
    l_Channel_Id                  VARCHAR2(30);
    l_Terminal_Id                 VARCHAR2(30);
    l_Count_Skipped               NUMBER := 0;
    l_Channel_Id_Mts              VARCHAR2(20);
    l_Nse_Code                    VARCHAR2(30);
    l_Is_Header_Found              VARCHAR2(2) := 'N';
    l_Header_Skipped              NUMBER := 0 ;
    l_Cancel_Trade_Cnt            NUMBER := 0 ;
    l_Count_Bse                   NUMBER := 0 ;
    l_Count_Nse                   NUMBER := 0 ;
    l_Bse_Strt_Time               NUMBER := 0 ;
    l_Nse_Strt_Time               NUMBER := 0 ;
    l_Misdeal_Type                VARCHAR2(30);
    l_Update_Htrf_Count           NUMBER := 0 ;
    l_Nfo_To_Date                 VARCHAR2(15);
    l_Pur_Cut_Off                 VARCHAR2(10);
    l_Order_Stc_Type              VARCHAR2(15);
    l_Ord_Stc_Type                VARCHAR2(15);
    l_Pur_Cut_Off_Time            VARCHAR2(10);
    l_Stc_Type                    VARCHAR2(5);
    l_Facilitator_Code            VARCHAR2(15);
    l_SubBr_Code                  VARCHAR2(30);
    l_EUIN                        VARCHAR2(30);
    l_EUIN_Decl                   VARCHAR2(30);
    l_ALL_Units                   VARCHAR2(30);
    l_DPC                         VARCHAR2(30);
    l_Sub_Order_Type              VARCHAR2(15);
    l_First_Order                 VARCHAR2(15);
    l_Fresh_Add                   VARCHAR2(15);
    l_Member_Remarks              VARCHAR2(200);
    l_KYC_Flag                    VARCHAR2(5);
    l_MIN_redm_flg                VARCHAR2(5);
    l_Sub_brk_ARN_Cd              VARCHAR2(10);

    TYPE t_Entity_Search IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
    Entity_Search_Tab t_Entity_Search;
    Channel_Type_Tab  t_Entity_Search;

    TYPE r_Sem_Search IS RECORD (Security_Id   VARCHAR2(30),
                                 Security_Desc VARCHAR2(200),
                                 Pur_Cut_Off   VARCHAR2(10),
                                 Nfo_To_Date   VARCHAR2(15));

    TYPE t_Sem_Search IS TABLE OF r_Sem_Search INDEX BY VARCHAR2(30);
    Sem_Search_Tab_Nse     t_Sem_Search;
    Sem_Search_Tab_Bse     t_Sem_Search;
    Sem_Search_Tab_Bse_L0  t_Sem_Search;
    Sem_Search_Tab_Nse_L0  t_Sem_Search;
    Sem_Search_Tab_Bse_L1  t_Sem_Search;
    Sem_Search_Tab_Nse_L1  t_Sem_Search;

    TYPE t_Settlement_Search IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
    Sett_Search_Tab        t_Settlement_Search;

    CURSOR C_Settlement_Search
    IS
      SELECT (Mfs_Exch_Id ||'-'|| Mfs_Settlement_Type ||'-'|| Mfs_Settlement_No) Settlement_Details
      FROM   Mfss_Settlement_Calender m
      WHERE  /*( (Mfs_Trade_Date BETWEEN Std_Lib.l_Pam_Curr_Date - 10 AND Std_Lib.l_Pam_Curr_Date + 10)
          OR (Mfs_Trade_Date = '29 SEP 2021')) */    -- ONLY FOR LOADING BACK DATED ORDERS
          Mfs_Trade_Date BETWEEN Std_Lib.l_Pam_Curr_Date - 10 AND Std_Lib.l_Pam_Curr_Date + 10
      AND    M.mfs_exch_id =  P_Exch_Id;

    CURSOR C_Search_Ent IS
      SELECT Ent_Id
      FROM   Entity_Master,
             Entity_Privilege_Mapping
      WHERE  Ent_Id             = Epm_Ent_Id
      AND    Ent_Status         = 'E'
      AND    Ent_Type           = 'CL'
      AND    Ent_Templet_Client = 'N'
      AND    Decode(p_Exch_Id,'NSE',Nvl(Epm_Seg_Mfss,'N'),'BSE',Nvl(Epm_Seg_Mfss_Bse,'N')) = 'Y';

    CURSOR C_Search_Scrip_Nse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Nse_Code,
             Decode(Length(Msm_Nse_Pur_Cut_Off),5,Msm_Nse_Pur_Cut_Off||':00',Msm_Nse_Pur_Cut_Off) Msm_Nse_Pur_Cut_Off,
             Msm_Nfo_To_Date
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Nse_Code IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

    CURSOR C_Search_Scrip_Bse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Bse_Code,
             Msm_Bse_Pur_Cut_Off,
             Msm_Nfo_To_Date
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Bse_Code      IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

    CURSOR C_Search_Scrip_L0_Bse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Bse_LO_Scheme_Code
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Bse_LO_Scheme_Code IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

   CURSOR C_Search_Scrip_L0_Nse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Nse_LO_Scheme_Code
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Nse_LO_Scheme_Code IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

  CURSOR C_Search_Scrip_L1_Bse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Bse_L1_Scheme_Code
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Bse_L1_Scheme_Code IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

   CURSOR C_Search_Scrip_L1_Nse IS
      SELECT Msm_Scheme_Id,
             Msm_Scheme_Desc,
             Msm_Nse_L1_Scheme_Code
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Status        = 'A'
      AND    Msm_Record_Status = 'A'
      AND    Msm_Nse_L1_Scheme_Code IS NOT NULL
      AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

    CURSOR C_Mts_Channel_Type IS
      SELECT Rv_Low_Value,
             Rv_High_Value
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MF_MTS_CHANNEL_TYPE';

    CURSOR C_Mf_Bse_Order_View
    IS
    SELECT Eam_Broker_Id    ||'|'||
           Order_Date       ||'|'||
           Order_Time       ||'|'||
           Order_No         ||'|'||
           Settlement_No    ||'|'||
           Client_Code      ||'|'||
           Client_Name      ||'|'||
           Scheme_Code      ||'|'||
           Scheme_Name      ||'|'||
           Isin_Number      ||'|'||
           Buy_Sell_Indictor||'|'||
           Buy_Value        ||'|'||
           Sell_Qty         ||'|'||
           Dp_Trans         ||'|'||
           Dp_Or_Folio_No   ||'|'||
           Folio_No         ||'|'||
           Entry_By         ||'|'||
           Order_Status     ||'|'||
           Order_Remark     ||'|'||
           Internal_Ref_No  ||'|'||
           Settlement_Type  ||'|'||
           Order_Type       ||'|'||
           Sip_Regn_No      ||'|'||
           Sip_Regn_Date    ||'|'||
           Source_Id        ||'|'||
           User_Id          ||'|'||
           /*Sub_Broker_Arn_Code ||'|'||
           Euin_Number      ||'|'||
           Euin_Declaration*/
           Facilitator_Code
    FROM   Mf_Bse_Orderfile,
           Parameter_Master
    WHERE  Order_Date =  To_Char(Pam_Curr_Dt,'DD/MM/RRRR');

    CURSOR C_Mf_Nse_Order_View
    IS
    SELECT Order_No           ||'|'||
           Sett_Type          ||'|'||
           Sett_No            ||'|'||
           Subs_Redem_Flg     ||'|'||
           Allotment_Mode     ||'|'||
           Order_Date         ||'|'||
           Order_Time         ||'|'||
           Amc_Code           ||'|'||
           Amc_Sch_Code       ||'|'||
           Rta_Code           ||'|'||
           Rta_Sch_Code       ||'|'||
           Scheme_Cat         ||'|'||
           Scheme_Symbol      ||'|'||
           Scheme_Series      ||'|'||
           Scheme_Opt_Type    ||'|'||
           Isin_Code          ||'|'||
           Quantity           ||'|'||
           Amount             ||'|'||
           Purchase_Type      ||'|'||
           Member_Code        ||'|'||
           Branch_Code        ||'|'||
           Dealer_Code        ||'|'||
           Folio_Number       ||'|'||
           Payout_Mech        ||'|'||
           Application_No     ||'|'||
           First_Cli_Code     ||'|'||
           Tax_Status         ||'|'||
           Mode_Of_Holding    ||'|'||
           First_Cli_Name     ||'|'||
           First_Cli_Pan      ||'|'||
           First_Cli_Kyc_Flg  ||'|'||
           Second_Cli_Name    ||'|'||
           Second_Cli_Pan     ||'|'||
           Second_Cli_Kyc_Flg ||'|'||
           Third_Cli_Name     ||'|'||
           Third_Cli_Pan      ||'|'||
           Third_Cli_Kyc_Flg  ||'|'||
           Guardian_Name      ||'|'||
           Guardian_Pan       ||'|'||
           Depository_Name    ||'|'||
           Dp_Id              ||'|'||
           Dp_Client_Id       ||'|'||
           Mobile_No          ||'|'||
           Bank_Account_Type  ||'|'||
           Bank_Account_Number||'|'||
           Bank_Name          ||'|'||
           Bank_Branch        ||'|'||
           Bank_City          ||'|'||
           Micr_Code          ||'|'||
           Neft_Code          ||'|'||
           Rtgs_Code          ||'|'||
           Email_Id           ||'|'||
           Confirmation_Flg   ||'|'||
           Rejection_Reason   ||'|'||
           Sip_Registn_No     ||'|'||
           Sip_Tranche_No     ||'|'||
           Source_Flag        ||'|'||
           User_Id            ||'|'||
           /*Euin_Number*/
           Facilitator_Code
    FROM   Mf_Nse_Orderfile,
           Parameter_Master
    WHERE  Order_Date =  To_Char(Pam_Curr_Dt,'DD-MON-RRRR');


  BEGIN
    Tab_File_Records.DELETE;
    Entity_Search_Tab.DELETE;
    Sem_Search_Tab_Nse.DELETE;
    Sem_Search_Tab_Bse.DELETE;
    Sem_Search_Tab_Bse_L0.DELETE;
    Sem_Search_Tab_Nse_L0.DELETE;
    Sem_Search_Tab_Bse_L1.DELETE;
    Sem_Search_Tab_Nse_L1.DELETE;

    P_Ret_Msg := ' Getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain    = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    P_Ret_Msg := ' In Housekeeping. Check if file exists in /ebos/files/upstrem or Program is running.';
    Std_Lib.P_Housekeeping(l_Prg_Id,
                           P_Exch_Id,
                           P_Exch_Id || ',' || P_Final_Flag || ',' || P_Source || ',' ||
                           P_File_Name,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    l_Pam_Curr_Date  := Std_Lib.l_Pam_Curr_Date;

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,' Current Working Date         : ' ||To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed           :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Source                      : ' || p_Source);
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || P_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' Download Mode               : ' || P_Final_Flag);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name                   : ' || P_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Handle, 2);

    P_Ret_Msg := ' Loading the file ';
    IF P_Source = 'EXCH' OR (P_Source = 'MTS' AND Trim(P_File_Name) IS NOT NULL) THEN
      Std_Lib.Load_File(l_File_Path,
                        P_File_Name,
                        l_Line_Count,
                        Tab_File_Records);
    END IF;

    IF P_Source = 'MTS' AND Trim(P_File_Name) IS NULL THEN
      IF P_Exch_Id = 'NSE' THEN
         OPEN C_Mf_Nse_Order_View;
         LOOP
              FETCH C_Mf_Nse_Order_View BULK COLLECT INTO Tab_File_Records;
              EXIT WHEN C_Mf_Nse_Order_View%NOTFOUND;
         END LOOP;
         CLOSE C_Mf_Nse_Order_View;
      ELSIF P_Exch_Id = 'BSE' THEN
         OPEN C_Mf_Bse_Order_View;
         LOOP
            FETCH C_Mf_Bse_Order_View BULK COLLECT INTO Tab_File_Records;
            EXIT WHEN C_Mf_Bse_Order_View%NOTFOUND;
         END LOOP;
         CLOSE C_Mf_Bse_Order_View;
      END IF;
    END IF;

    l_Line_Count := Tab_File_Records.COUNT;

    IF l_Line_Count = 0 THEN
       P_Ret_Msg := 'No Records found for Pull/Load.';
       Utl_File.Put_Line(l_Log_File_Handle,p_Ret_Msg );
       RAISE Excp_Terminate;
    END IF;

    /*SELECT Nvl(Max(Decode(Prg_Exm_Id,'BSE',1,0)),0),
           Nvl(Max(Decode(Prg_Exm_Id,'NSE',1,0)),0),
           Nvl(To_char(Max(Decode(Prg_Exm_Id,'BSE',Prg_Strt_Time )),'RRRRMMDDHH24MISS'),0) ,
           Nvl(To_Char(Max(Decode(Prg_Exm_Id,'NSE',Prg_Strt_Time )),'RRRRMMDDHH24MISS'),0)
    INTO   l_Count_Bse,
           l_Count_Nse,
           l_Bse_Strt_Time,
           l_Nse_Strt_Time
    FROM   Program_Status ,
           parameter_master
    WHERE  Prg_Dt     = l_Pam_Curr_Date
    AND    Prg_Cmp_Id = 'MFSSSITE'
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id IN ( 'BSE','NSE');

    IF l_Count_Bse = 0 THEN
      p_Ret_Msg := 'BSE Scheme master file has not been loaded for the day.Please load BSE File(Primary File)  First.';
      Utl_File.Put_Line(l_Log_File_Handle,p_Ret_Msg );
      RAISE Excp_Terminate;
    END IF;

    IF l_Count_Nse = 0 THEN
      p_Ret_Msg := 'NSE Scheme master file has not been loaded for the day.Please load NSE File .';
      Utl_File.Put_Line(l_Log_File_Handle,p_Ret_Msg );
      RAISE Excp_Terminate;
    END IF;

    IF l_Count_Bse > 0  AND l_Count_Nse > 0 THEN
      IF l_Bse_Strt_Time > l_Nse_Strt_Time THEN
        p_Ret_Msg := 'NSE Scheme master file has not been loaded after loading BSE scheme master File .Cannot continue';
        Utl_File.Put_Line(l_Log_File_Handle,p_Ret_Msg );
        RAISE Excp_Terminate;
      END IF;
    END IF;*/

    P_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value = p_Exch_Id
    AND    Rv_Abbreviation = 'MFSS';

    P_Ret_Msg := 'Getting the Broker Code from the Master''s for Segment <' ||l_Mutual_Fund_Seg || '> .';
    SELECT MAX(Decode(Eam_Exm_Id, 'NSE', Eam_Broker_Id)),
           MAX(Decode(Eam_Exm_Id, 'BSE', Eam_Broker_Id))
    INTO   l_Nse_Broker_Cd,
           l_Bse_Broker_Cd
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Seg_Id = l_Mutual_Fund_Seg;

    IF P_Source = 'EXCH' OR (P_Source = 'MTS' AND Trim(P_File_Name) IS NOT NULL) THEN
        IF P_Final_Flag = 'I' AND Instr(Upper(P_File_Name), 'PROV') = 0 THEN
           p_Ret_Msg := 'Incremental File name is incorrect';
           RAISE Excp_Terminate;
        END IF;

        IF P_Exch_Id = 'NSE' THEN
          IF P_Final_Flag = 'F' AND Instr(Upper(p_File_Name), 'FNL') = 0 THEN
             P_Ret_Msg := 'Final File name is incorrect';
             RAISE Excp_Terminate;
          END IF;
        ELSIF P_Exch_Id = 'BSE' THEN
          IF P_Final_Flag = 'F' AND Instr(Upper(p_File_Name), 'ORDER') = 0 THEN
             P_Ret_Msg := 'Final File name is incorrect';
             RAISE Excp_Terminate;
          END IF;
        END IF;
    END IF;

    P_Ret_Msg := ' Populating Pl-Sql table for Entity Id';
    FOR i IN c_Search_Ent
    LOOP
      Entity_Search_Tab(i.Ent_Id) := i.Ent_Id;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for Settlement';
    FOR i IN c_Settlement_Search
    LOOP
      Sett_Search_Tab(i.Settlement_Details) := i.Settlement_Details;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for BSE Security Id';
    FOR i IN c_Search_Scrip_Bse
    LOOP
      Sem_Search_Tab_Bse(i.Msm_Bse_Code).Security_Id   := i.Msm_Scheme_Id;
      Sem_Search_Tab_Bse(i.Msm_Bse_Code).Security_Desc := i.Msm_Scheme_Desc;
      Sem_Search_Tab_Bse(i.Msm_Bse_Code).Pur_Cut_Off   := i.Msm_Bse_Pur_Cut_Off;
      Sem_Search_Tab_Bse(i.Msm_Bse_Code).Nfo_To_Date   := i.Msm_Nfo_To_Date;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for BSE L0 Security Id';
    FOR i IN C_Search_Scrip_L0_Bse
    LOOP
      Sem_Search_Tab_Bse_L0(i.Msm_Bse_LO_Scheme_Code).Security_Id   := i.Msm_Scheme_Id;
      Sem_Search_Tab_Bse_L0(i.Msm_Bse_LO_Scheme_Code).Security_Desc := i.Msm_Scheme_Desc;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for NSE L0 Security Id';
    FOR i IN C_Search_Scrip_L0_Nse
    LOOP
      Sem_Search_Tab_Nse_L0(i.Msm_Nse_LO_Scheme_Code).Security_Id   := i.Msm_Scheme_Id;
      Sem_Search_Tab_Nse_L0(i.Msm_Nse_LO_Scheme_Code).Security_Desc := i.Msm_Scheme_Desc;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for BSE L1 Security Id';
    FOR i IN C_Search_Scrip_L1_Bse
    LOOP
      Sem_Search_Tab_Bse_L1(i.Msm_Bse_L1_Scheme_Code).Security_Id   := i.Msm_Scheme_Id;
      Sem_Search_Tab_Bse_L1(i.Msm_Bse_L1_Scheme_Code).Security_Desc := i.Msm_Scheme_Desc;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for NSE L1 Security Id';
    FOR i IN C_Search_Scrip_L1_Nse
    LOOP
      Sem_Search_Tab_Nse_L1(i.Msm_Nse_L1_Scheme_Code).Security_Id   := i.Msm_Scheme_Id;
      Sem_Search_Tab_Nse_L1(i.Msm_Nse_L1_Scheme_Code).Security_Desc := i.Msm_Scheme_Desc;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for NSE Security Id';
    FOR i IN c_Search_Scrip_Nse
    LOOP
      Sem_Search_Tab_Nse(i.Msm_Nse_Code).Security_Id      := i.Msm_Scheme_Id;
      Sem_Search_Tab_Nse(i.Msm_Nse_Code).Security_Desc    := i.Msm_Scheme_Desc;
      Sem_Search_Tab_Nse(i.Msm_Nse_Code).Pur_Cut_Off      := i.Msm_Nse_Pur_Cut_Off;
      Sem_Search_Tab_Nse(i.Msm_Nse_Code).Nfo_To_Date      := i.Msm_Nfo_To_Date;
    END LOOP;

    P_Ret_Msg := ' Populating Pl-Sql table for MTS Channel Type';
    FOR i IN C_Mts_Channel_Type
    LOOP
      Channel_Type_Tab(i.Rv_Low_Value) := i.Rv_High_Value;
    END LOOP;

    P_Ret_Msg := ' Processing records from file . No of records <' ||Tab_File_Records.COUNT||'>';
    FOR Line_No IN Tab_File_Records.FIRST .. Nvl(Tab_File_Records.LAST, 0)
    LOOP
      BEGIN
        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Record.DELETE;

        P_Ret_Msg := '1: Splitting fields in the line buffer';

        /*IF P_Final_Flag = 'F' AND p_Exch_Id = 'NSE' THEN
           Std_Lib.Split_Line(Tab_File_Records(Line_No),',',Tab_Split_Record);
        ELSE*/
          Std_Lib.Split_Line(Tab_File_Records(Line_No),'|',Tab_Split_Record);
        /*END IF;*/

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            P_Ret_Msg := 'Printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,'<' || i || '>' || ' = <' ||Tab_Split_Record(i)|| '>');
          END LOOP;
        END IF;

        l_Order_No               := NULL;
        l_Stc_No                 := NULL;
        l_Buy_Sell_Flg           := NULL;
        l_Allotment_Mode         := NULL;
        l_Date                   := NULL;
        l_Time                   := NULL;
        l_Amc_Code               := NULL;
        l_Scheme_Code            := NULL;
        l_Rta_Code               := NULL;
        l_Rta_Scheme_Code        := NULL;
        l_Scheme_Category        := NULL;
        l_Scheme_Symbol          := NULL;
        l_Scheme_Series          := NULL;
        l_Scheme_Option_Type     := NULL;
        l_Isin                   := NULL;
        l_Quantity               := NULL;
        l_Amount                 := NULL;
        l_Purchase_Type          := NULL;
        l_Member_Code            := NULL;
        l_Branch_Code            := NULL;
        l_Dealer_Code            := NULL;
        l_Folio_No               := NULL;
        l_Payout_Mechanism       := NULL;
        l_Application_No         := NULL;
        l_Ent_Id                 := NULL;
        l_Tax_Status             := NULL;
        l_Holding_Mode           := NULL;
        l_First_Client_Name      := NULL;
        l_First_Client_Pan       := NULL;
        l_First_Client_Kyc_Flag  := NULL;
        l_Second_Client_Name     := NULL;
        l_Second_Client_Pan      := NULL;
        l_Second_Client_Kyc_Flag := NULL;
        l_Third_Client_Name      := NULL;
        l_Third_Client_Pan       := NULL;
        l_Third_Client_Kyc_Flag  := NULL;
        l_Guardian_Name          := NULL;
        l_Guardian_Pan           := NULL;
        l_Dp_Name                := NULL;
        l_Dp_Id                  := NULL;
        l_Dp_Acc_No              := NULL;
        l_Mobile_No              := NULL;
        l_Bank_Acc_Type          := NULL;
        l_Bank_Acc_No            := NULL;
        l_Bank_Name              := NULL;
        l_Bank_Branch            := NULL;
        l_Bank_City              := NULL;
        l_Micr_Code              := NULL;
        l_Neft_Code              := NULL;
        l_Rtgs_Code              := NULL;
        l_Email_Id               := NULL;
        l_Confirmation_Flag      := NULL;
        l_Reject_Reason          := NULL;
        l_Order_Status           := NULL;
        l_Order_Remark           := NULL;
        l_Dp_Id                  := NULL;
        l_Internal_Ref_No        := NULL;
        l_Settlement_Type        := NULL;
        l_Order_Type             := NULL;
        l_Sip_Regn_No            := NULL;
        l_Sip_Regn_Date          := NULL;
        l_Channel_Id             := NULL;
        l_Channel_Id_Mts         := NULL;
        l_Terminal_Id            := NULL;
        l_Nse_Code               := NULL;
        l_Sip_Txn_No             := NULL;
        l_Facilitator_Code       := NULL;
        l_SubBr_Code             := Null;
        l_EUIN                   := Null;
        l_EUIN_Decl              := Null;
        l_ALL_Units              := Null;
        l_DPC                    := Null;
        l_Sub_Order_Type         := Null;
        l_First_Order            := Null;
        l_Fresh_Add              := Null;
        l_Member_Remarks         := Null;
        l_KYC_Flag               := Null;
        l_MIN_redm_flg           := Null;
        l_Sub_brk_ARN_Cd         := Null;

        IF P_Exch_Id = 'BSE' THEN

           P_Ret_Msg := 'Splitting individual fields from BSE file for order no <'||TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3))||'>.';

           l_Member_Code := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

           l_Date                 := TRIM(Substr(Tab_Split_Record(Tab_Split_Record.FIRST + 1),1,10));
           l_Time                 := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
           l_Order_No             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
           l_Stc_No               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
           l_Ent_Id               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));

           BEGIN
            SELECT Decode(Ent_Category,'NRI',Ent_id, l_Ent_Id)
              INTO l_Ent_Id
              FROM Entity_Master
             WHERE Ent_Mf_Ucc_Code = l_Ent_Id;
           EXCEPTION
            WHEN OTHERS THEN
             Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> Unable to find Client category for client <' || l_Ent_Id ||'>');
             Utl_File.Fflush(l_Log_File_Handle);
             RAISE Excp_Skip;
           END;

           l_First_Client_Name    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
           l_Amc_Code             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
           l_Scheme_Code          := l_Amc_Code;
           l_Scheme_Name          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
           l_Isin                 := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
           l_Buy_Sell_Flg         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
           l_Amount               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
           l_Quantity             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
           l_Holding_Mode         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
           l_Dp_Folio_No          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));
           l_Folio_No             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));
           l_Entry_By             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16));
           l_Order_Status         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 17));
           l_Order_Remark         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 18));
           l_Internal_Ref_No      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 19));
           l_Settlement_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 20));
           l_Order_Type           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 21));
           l_Sip_Regn_No          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 22));
           l_Sip_Regn_Date_String := TRIM(Substr(Tab_Split_Record(Tab_Split_Record.FIRST + 23),1,10));
           --l_Facilitator_Code     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 26));
           IF P_Final_Flag = 'I' AND p_Source = 'EXCH' THEN
             l_SubBr_Code       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +24));
             l_EUIN             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +25));
             l_EUIN_Decl        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +26));
             l_ALL_Units        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +27));
             l_DPC              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +28));
             l_Sub_Order_Type   := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +29));
             l_First_Order      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +30));
             l_Fresh_Add        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +31));
             l_Member_Remarks   := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +32));
             l_KYC_Flag         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +33));
             l_MIN_redm_flg     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +34));
             l_Sub_brk_ARN_Cd   := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST +35));
             l_Channel_Id       := 'DEFAULT';
           ELSE
             IF Tab_Split_Record.EXISTS(25) THEN

              l_Channel_Id_Mts := Tab_Split_Record(25);

              IF Channel_Type_Tab.EXISTS(l_Channel_Id_Mts) THEN
                 l_Channel_Id := Channel_Type_Tab(l_Channel_Id_Mts);
              ELSE
                 l_Channel_Id := 'DEFAULT';
              END IF;
           ELSE
              l_Channel_Id := 'DEFAULT';
           END IF;

         /* IF Tab_Split_Record.EXISTS(26) THEN
             l_Terminal_Id := Tab_Split_Record(26);
          END IF;*/

          IF Tab_Split_Record.EXISTS(27) THEN
              l_Facilitator_Code := Tab_Split_Record(27);
           ELSE
              l_Facilitator_Code := NULL;
           END IF;

           END IF;

          l_Dp_Id := Substr(l_Dp_Folio_No, 1, 8);

          /* Changes done 0n 14-Jul-2012 */
          IF l_Member_Code IS NULL THEN
             P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
          END IF;

          IF substr(l_Member_Code ,1,1) = '0' THEN
             IF  l_Member_Code <> l_Bse_Broker_Cd THEN
                 l_Member_Code :=  substr(l_Member_Code,2);
             END IF;
          END IF;

          IF Nvl(l_Member_Code,1) <> l_Bse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Code ||'> of file for the order no < '||l_Order_No||
              '> does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
          END IF;
          /* Changes done 0n 14-Jul-2012 */
          P_Ret_Msg := 'Getting Depository id  and Account No from Dp Id  <'||l_Dp_Id||'> and Folio No <'||l_Dp_Folio_No||'>.';

          BEGIN
            SELECT Dpm_Dem_Id,
                   Decode(Dpm_Dem_Id,'NSDL',Substr(l_Dp_Folio_No, 9, 8),'CDSL',l_Dp_Folio_No)
            INTO   l_Dp_Name,
                   l_Dp_Acc_No
            FROM   Depo_Participant_Master
            WHERE  Dpm_Id   = l_Dp_Id;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> since DP Id <' || l_Dp_Id ||'> not present in system ');
              Utl_File.Fflush(l_Log_File_Handle);
              RAISE Excp_Skip;
          END;

          IF l_Order_Status = 'VALID' THEN
            l_Confirmation_Flag := 'Y';
          ELSIF l_Order_Status = 'INVALID' THEN
            l_Confirmation_Flag := 'N';
          ELSIF l_Order_Status = 'F' THEN
            l_Confirmation_Flag := 'Y';
          END IF;

          l_Reject_Reason := l_Order_Remark;

        ELSIF P_Exch_Id = 'NSE' THEN

          l_Order_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

          P_Ret_Msg := 'Splitting individual fields from NSE file for order no <'||l_Order_No||'>.';

          IF (l_Order_No = 'Order No' OR l_Order_No IS NULL) THEN
            l_Is_Header_Found := 'Y';
            RAISE Excp_Skip; ---Header record . hence skipping the same.
          END IF;

          l_Settlement_Type    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1));
          l_Stc_No             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Buy_Sell_Flg       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Allotment_Mode     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Date               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Time               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Amc_Code           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Scheme_Code        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Rta_Code           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Rta_Scheme_Code    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Scheme_Category    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Scheme_Symbol      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
          l_Scheme_Series      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Scheme_Option_Type := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));
          l_Isin               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));
          l_Quantity           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16));
          l_Amount             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 17));
          l_Purchase_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 18));
          l_Member_Code        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 19));
          --l_Facilitator_Code   := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 58));

          /* Changes done 0n 14-Jul-2012 */
          IF l_Member_Code IS NULL THEN
             P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
          END IF;

          IF substr(l_Member_Code ,1,1) = '0' THEN
             IF  l_Member_Code <> l_Nse_Broker_Cd THEN
                 l_Member_Code :=  substr(l_Member_Code,2);
             END IF;
          END IF;

          IF Nvl(l_Member_Code,1) <> l_Nse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Code ||'> of file for the order no < '||l_Order_No||
              '> does not match with the NSE member code <' ||l_Nse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
          END IF;
          /* Changes done 0n 14-Jul-2012 */

          l_Branch_Code            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 20));
          l_Dealer_Code            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 21));
          l_Folio_No               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 22));
          l_Payout_Mechanism       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 23));
          l_Application_No         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 24));
          l_Ent_Id                 := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 25));

          BEGIN
            SELECT Decode(Ent_Category,'NRI',Ent_id, l_Ent_Id)
              INTO l_Ent_Id
              FROM Entity_Master
             WHERE Ent_Mf_Ucc_Code = l_Ent_Id;
          EXCEPTION
            WHEN OTHERS THEN
             Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> Unable to find Client category for client <' || l_Ent_Id ||'>');
             Utl_File.Fflush(l_Log_File_Handle);
             RAISE Excp_Skip;
          END;

          l_Tax_Status             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 26));
          l_Holding_Mode           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 27));
          l_First_Client_Name      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 28));
          l_First_Client_Pan       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 29));
          l_First_Client_Kyc_Flag  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 30));
          l_Second_Client_Name     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 31));
          l_Second_Client_Pan      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 32));
          l_Second_Client_Kyc_Flag := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 33));
          l_Third_Client_Name      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 34));
          l_Third_Client_Pan       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 35));
          l_Third_Client_Kyc_Flag  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 36));
          l_Guardian_Name          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 37));
          l_Guardian_Pan           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 38));
          l_Dp_Name                := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 39));
          l_Dp_Id                  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 40));
          l_Dp_Acc_No              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 41));
          l_Mobile_No              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 42));
          l_Bank_Acc_Type          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 43));
          l_Bank_Acc_No            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 44));
          l_Bank_Name              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 45));
          l_Bank_Branch            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 46));
          l_Bank_City              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 47));
          l_Micr_Code              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 48));
          l_Neft_Code              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 49));
          l_Rtgs_Code              := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 50));
          l_Email_Id               := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 51));
          l_Confirmation_Flag      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 52));
          l_Reject_Reason          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 53));
          l_Sip_Regn_No            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 54));
          l_Sip_Txn_No             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 55));

          IF Tab_Split_Record.EXISTS(57) THEN

            l_Channel_Id_Mts := Tab_Split_Record(57);

            IF Channel_Type_Tab.EXISTS(l_Channel_Id_Mts) THEN
              l_Channel_Id := Channel_Type_Tab(l_Channel_Id_Mts);
            ELSE
              l_Channel_Id := 'DEFAULT';
            END IF;
          ELSE
            l_Channel_Id := 'DEFAULT';
          END IF;

          IF Tab_Split_Record.EXISTS(58) THEN
             l_Terminal_Id := Tab_Split_Record(58);
          END IF;

          IF Tab_Split_Record.EXISTS(59) THEN
              l_Facilitator_Code := Tab_Split_Record(59);
          ELSE
              l_Facilitator_Code := NULL;
          END IF;

          IF l_Allotment_Mode = 'Y' THEN
             l_Holding_Mode := 'DEMAT';
          ELSE
             l_Holding_Mode := 'PHYSICAL';
          END IF;

          IF (l_Sip_Regn_No IS NOT NULL AND l_Sip_Txn_No IS NOT NULL) THEN
              l_Order_Type := 'SIP';
          ELSE
              l_Order_Type := 'NRM';
          END IF;

          l_Nse_Code := l_Scheme_Symbol||l_Scheme_Series;

          /*This is done since for redemption NSE will always send it as blank for valid orders */
          IF l_Confirmation_Flag IS NULL AND  l_Buy_Sell_Flg = 'R' THEN
             l_Confirmation_Flag := 'Y';
          END IF;

          IF l_Confirmation_Flag NOT IN ( 'Y','F') THEN
             l_Confirmation_Flag := 'N';
          END IF;

          /*IF  l_Confirmation_Flag IS NULL THEN
             l_Confirmation_Flag := 'N';
          END IF;*/

          IF l_Confirmation_Flag = 'Y' THEN
             l_Order_Status := 'VALID';
          ELSIF l_Confirmation_Flag = 'N' THEN
             l_Order_Status := 'INVALID';
          ELSIF l_Confirmation_Flag = 'F' THEN
             l_Order_Status := l_Confirmation_Flag;
             l_Confirmation_Flag := 'Y';
          END IF;

          BEGIN
            P_Ret_Msg := ' Selecting Dp Name and Dp Acc No for Dp Id <'||l_Dp_Id||'>';
            IF Length(l_Dp_Acc_No) = 8 THEN
               SELECT Dpm_Dem_Id,
                      Decode(Dpm_Dem_Id,'NSDL',l_Dp_Acc_No,'CDSL',l_Dp_Id||l_Dp_Acc_No)
               INTO   l_Dp_Name,
                      l_Dp_Acc_No
               FROM   Depo_Participant_Master
               WHERE  Dpm_Id = l_Dp_Id;
            END IF;

            P_Ret_Msg := ' Selecting Dp Name for Dp Id <'||l_Dp_Id||'>';
            IF Length(l_Dp_Acc_No) = 16 THEN
               BEGIN
                 l_Dp_Id := Substr(l_Dp_Acc_No,1,8);
                 SELECT Dpm_Dem_Id
                 INTO   l_Dp_Name
                 FROM   Depo_Participant_Master
                 WHERE  Dpm_Id = l_Dp_Id;
               EXCEPTION
                 WHEN No_Data_Found THEN
                   l_Dp_Id := Substr(l_Dp_Acc_No,-8);
                   SELECT Dpm_Dem_Id
                   INTO   l_Dp_Name
                   FROM   Depo_Participant_Master
                   WHERE  Dpm_Id = l_Dp_Id;
               END;
            END IF;

          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '>
              since DP Id <' || l_Dp_Id ||'> not present in system for Order Type<'||l_Order_Type||'>');
              Utl_File.Fflush(l_Log_File_Handle);
              RAISE Excp_Skip;
          END;

          P_Ret_Msg := 'Getting Settlement type from Scheme Category  <'||l_Scheme_Category||'> ';
          BEGIN
            SELECT Rv_Low_Value
            INTO   l_Settlement_Type
            FROM   Cg_Ref_Codes
            WHERE  Rv_Domain     = 'MF_NSE_SETTLEMENT_TYPE'
            AND    Rv_High_Value = l_Scheme_Category;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,'  Settlement Type not found for scheme Category <' || l_Scheme_Category ||'>');
          END;

          IF P_Final_Flag = 'I' AND Instr(Upper(P_File_Name), 'PROV') > 0 THEN
            IF l_Settlement_Type = 'MF' AND l_Confirmation_Flag IS NULL AND  l_Buy_Sell_Flg = 'P' THEN
               l_Confirmation_Flag := 'Y';
               l_Order_Status      := 'VALID';
            END IF;
          ELSE
             IF l_Settlement_Type = 'MF' AND l_Confirmation_Flag IS NULL AND  l_Buy_Sell_Flg = 'P' THEN
                Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> since Confirmation flag is blank in the file');
                Utl_File.Fflush(l_Log_File_Handle);
                RAISE Excp_Skip;
             END IF;
          END IF;

          IF (l_Settlement_Type <> 'MF' AND l_Confirmation_Flag IS NULL AND  l_Buy_Sell_Flg = 'P') THEN
             Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> since Confirmation flag is blank in the file');
             Utl_File.Fflush(l_Log_File_Handle);
             RAISE Excp_Skip;
          END IF;

        END IF;--- End of NSE and BSE Exchange Values

        IF NOT Sett_Search_Tab.EXISTS(P_Exch_Id||'-'||l_Settlement_Type||'-'||l_Stc_No)  THEN
            P_Ret_Msg := 'Settlement Details not found in Settlement Calendar for Exch <'||P_Exch_Id||'> ' ||
                         'Settlement Type <'|| l_Settlement_Type||'> and Settlement No <'||l_Stc_No||'>.'||
                         'Order No <'||l_Order_No||'>';
             RAISE Excp_Terminate;
        END IF;

        IF l_Buy_Sell_Flg = 'P' AND l_Amount IS NULL THEN
           Utl_File.Put_Line(l_Log_File_Handle,
                            'For order type  purchase ,Amount cannot be zero and Blank.
                             Please check order no <' ||l_Order_No || '>');
           RAISE Excp_Terminate;
          --RAISE Excp_Skip;
        END IF;

        IF l_Buy_Sell_Flg = 'R' AND l_Quantity IS NULL THEN
           Utl_File.Put_Line(l_Log_File_Handle,
                             'For Order Type Redemption ,Quantity cannot be zero and Blank.
                              Please check order no <' ||l_Order_No || '>');
           RAISE Excp_Terminate;
          --RAISE Excp_Skip;
        END IF;

        IF l_Buy_Sell_Flg = 'P' AND l_Quantity IS NULL THEN
           l_Quantity := 0;
        END IF;

        IF l_Buy_Sell_Flg = 'R' AND l_Amount IS NULL THEN
           l_Amount := 0;
        END IF;

        p_Ret_Msg := 'Verifying date format for order no <' || l_Order_No || '>.';
        IF P_Exch_Id = 'BSE' THEN
          l_Order_Date    := To_Date(l_Date, 'DD/MM/YYYY');
          l_Sip_Regn_Date := To_Date(l_Sip_Regn_Date_String, 'DD/MM/YYYY');
        ELSIF P_Exch_Id = 'NSE' THEN
          l_Order_Date  := To_Date(l_Date, 'DD-MON-YYYY');
        END IF;

        l_Order_Time := l_Time;

        P_Ret_Msg := 'Verifying date format for order no <' || l_Order_No || '>.';
        IF l_Order_Date != l_Pam_Curr_Date THEN
          Utl_File.Put_Line(l_Log_File_Handle,'Order Date <' || l_Order_Date ||'> ,does not match with the system date  <' ||l_Pam_Curr_Date || '>.');
          RAISE Excp_Terminate;
        END IF;

        l_Misdeal_Type := NULL;
        l_Trd_Status := 'A';
        IF NOT (Entity_Search_Tab.EXISTS(l_Ent_Id)) THEN
          Utl_File.Put_Line(l_Log_File_Handle,'Client <' || l_Ent_Id ||'> not mapped in the system. Hence marking the order as misdeal order.');
          l_Trd_Status := 'M';
          l_Misdeal_Type := 'CLIENT';
        END IF;

        SELECT COUNT(1)
        INTO   l_Dp_Det_Count
        FROM   Member_Dp_Info
        WHERE  Mdi_Id           = l_Ent_Id
        AND    Mdi_Acc_Type     = '02'
        AND    Mdi_Dpm_Dem_Id   = l_Dp_Name
        AND    Mdi_Dpm_Id       = l_Dp_Id
        AND    Mdi_Dp_Acc_No    = l_Dp_Acc_No
        AND    Mdi_Default_Flag = 'Y'
        AND    Mdi_Status      <> 'C';

        IF l_Dp_Det_Count = 0 THEN
         IF l_Misdeal_Type = 'CLIENT' THEN
            Utl_File.Put_Line(l_Log_File_Handle,'Order no  <' || l_Order_No ||'> has both Client as well as Dp misdeal record.');
            Utl_File.Fflush(l_Log_File_Handle);
            l_Trd_Status   := 'M';
            l_Misdeal_Type := 'CLIENT';
         ELSE
          Utl_File.Put_Line(l_Log_File_Handle,'DP Acc No<' || l_Dp_Acc_No ||'> for Client <'||l_Ent_Id||'>not mapped in the system. Hence marking the order as misdeal order.');
          Utl_File.Fflush(l_Log_File_Handle);
          l_Trd_Status := 'M';
          l_Misdeal_Type := 'DP';
         END IF;
        END IF;

        P_Ret_Msg := 'selecting Mf order purchase cut off time';
        BEGIN
          SELECT Rv_Low_Value,
                 Rv_High_Value,
                 Rv_Abbreviation
          INTO   l_Pur_Cut_Off_Time,
                 l_Ord_Stc_Type,
                 l_Stc_Type
          FROM   Cg_Ref_Codes
          WHERE  Rv_Domain       = 'MF_ORD_PUR_CUT_OFF_TIME'
          AND    Rv_Abbreviation = l_Settlement_Type
          AND    Rv_Meaning      = 'MFE';
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Pur_Cut_Off_Time := NULL;
            l_Order_Stc_Type   := NULL;
            l_Stc_Type         := NULL;
        END;

        IF P_Exch_Id = 'NSE' THEN
        --- l_Scheme_Code replaced with l_Nse_Code
          IF l_Settlement_Type = 'L0' THEN
              IF NOT (Sem_Search_Tab_Nse_L0.EXISTS(l_Nse_Code)) THEN
                Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Nse_Code ||'> not mapped in the system. Hence skipping the order.');
                RAISE Excp_Skip;
              ELSE
                l_Security_Id := Sem_Search_Tab_Nse_L0(l_Nse_Code).Security_Id;
                l_Scheme_Name := Sem_Search_Tab_Nse_L0(l_Nse_Code).Security_Desc;
              END IF;
          ELSIF l_Settlement_Type = 'L1' THEN
              IF NOT (Sem_Search_Tab_Nse_L1.EXISTS(l_Nse_Code)) THEN
                Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Nse_Code ||'> not mapped in the system. Hence skipping the order.');
                RAISE Excp_Skip;
              ELSE
                l_Security_Id := Sem_Search_Tab_Nse_L1(l_Nse_Code).Security_Id;
                l_Scheme_Name := Sem_Search_Tab_Nse_L1(l_Nse_Code).Security_Desc;
              END IF;
          ELSE
            IF NOT (Sem_Search_Tab_Nse.EXISTS(l_Nse_Code)) THEN
              Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Nse_Code ||'> not mapped in the system. Hence skipping the order.');
              RAISE Excp_Skip;
            ELSE
              l_Security_Id      := Sem_Search_Tab_Nse(l_Nse_Code).Security_Id;
              l_Scheme_Name      := Sem_Search_Tab_Nse(l_Nse_Code).Security_Desc;
              l_Pur_Cut_Off      := Sem_Search_Tab_Nse(l_Nse_Code).Pur_Cut_Off;
              l_Nfo_To_Date      := Sem_Search_Tab_Nse(l_Nse_Code).Nfo_To_Date;

              IF l_Settlement_Type = Nvl(l_Stc_Type,'@@') THEN
                IF l_Pam_Curr_Date = Nvl(To_Date(l_Nfo_To_Date,'DD-MON-YYYY'),'15-AUG-1947')
                   AND l_Pur_Cut_Off = Nvl(l_Pur_Cut_Off_Time,'@@') THEN
                   l_Order_Stc_Type := l_Ord_Stc_Type;
                ELSE
                   l_Order_Stc_Type := Null;
                END IF;
              ELSE
                l_Order_Stc_Type := NULL;
              END IF;
           END IF;
          END IF;
        ELSIF P_Exch_Id = 'BSE' THEN
          IF l_Settlement_Type = 'L0' THEN
              IF NOT (Sem_Search_Tab_Bse_L0.EXISTS(l_Scheme_Code)) THEN
                Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Scheme_Code ||'> not mapped in the system. Hence skipping the order.');
                RAISE Excp_Skip;
              ELSE
                l_Security_Id := Sem_Search_Tab_Bse_L0(l_Scheme_Code).Security_Id;
                l_Scheme_Name := Sem_Search_Tab_Bse_L0(l_Scheme_Code).Security_Desc;
              END IF;
          ELSIF l_Settlement_Type = 'L1' THEN
              IF NOT (Sem_Search_Tab_Bse_L1.EXISTS(l_Scheme_Code)) THEN
                Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Scheme_Code ||'> not mapped in the system. Hence skipping the order.');
                RAISE Excp_Skip;
              ELSE
                l_Security_Id := Sem_Search_Tab_Bse_L1(l_Scheme_Code).Security_Id;
                l_Scheme_Name := Sem_Search_Tab_Bse_L1(l_Scheme_Code).Security_Desc;
              END IF;
          ELSE
             IF NOT (Sem_Search_Tab_Bse.EXISTS(l_Scheme_Code)) THEN
                Utl_File.Put_Line(l_Log_File_Handle,'Scheme Code <' || l_Scheme_Code ||'> not mapped in the system. Hence skipping the order.');
                RAISE Excp_Skip;
              ELSE
                l_Security_Id      := Sem_Search_Tab_Bse(l_Scheme_Code).Security_Id;
                l_Scheme_Name      := Sem_Search_Tab_Bse(l_Scheme_Code).Security_Desc;
                l_Pur_Cut_Off      := Sem_Search_Tab_Bse(l_Scheme_Code).Pur_Cut_Off;
                l_Nfo_To_Date      := Sem_Search_Tab_Bse(l_Scheme_Code).Nfo_To_Date;

                IF l_Settlement_Type = Nvl(l_Stc_Type,'@@') THEN
                  IF To_Date(l_Pam_Curr_Date,'DD-MON-YYYY') = Nvl(To_Date(l_Nfo_To_Date,'DD-MON-YYYY'),'15-AUG-1947')
                    AND l_Pur_Cut_Off = Nvl(l_Pur_Cut_Off_Time,'@@') THEN
                   l_Order_Stc_Type := l_Ord_Stc_Type;
                  ELSE
                   l_Order_Stc_Type := Null;
                  END IF;
                ELSE
                   l_Order_Stc_Type := NULL;
                END IF;
              END IF;
          END IF;
        END IF;

        BEGIN
          P_Ret_Msg := 'Inserting Trades for order no  <' || l_Order_No ||'>, Client <' || l_Ent_Id || '> , Scheme Code, ' ||
                       l_Scheme_Code || '> ,Sett No. < ' || l_Stc_No ||'> and   order type <' || l_Buy_Sell_Flg || '>';

          INSERT INTO Mfss_Trades
            (Order_No,                Exm_Id,                   Stc_Type,                 Stc_No,
             Buy_Sell_Flg,            Allotment_Mode,           Order_Date,               Order_Time,
             ------------
             Amc_Code,                Amc_Scheme_Code,          Rta_Code,                 Rta_Scheme_Code,
             Scheme_Category,         Scheme_Symbol,            Scheme_Series,            Scheme_Option_Type,
             ------------
             Isin,                    Quantity,                 Amount,                   Purchase_Type,
             Member_Code,             Branch_Code,              Dealer_Code,              Folio_No,
             ------------
             Payout_Mechanism,        Application_No,           Ent_Id,                   Tax_Status,
             Holding_Mode,            First_Client_Name,        First_Client_Pan,         First_Client_Kyc_Flag,
             ------------
             Second_Client_Name,      Second_Client_Pan,        Second_Client_Kyc_Flag,   Third_Client_Name,
             Third_Client_Pan,        Third_Client_Kyc_Flag,    Guardian_Name,            Guardian_Pan,
             ------------
             Dp_Name,                 Dp_Id,                    Dp_Acc_No,                Mobile_No,
             Bank_Acc_Type,           Bank_Acc_No,              Bank_Name,                Bank_Branch,
             ------------
             Bank_City,               Micr_Code,                Neft_Code,                Rtgs_Code,
             Email_Id,                Confirmation_Flag,        Reject_Reason,            Scheme_Name,
             ------------
             Entry_By,                Order_Status,             Order_Remark,             Creat_Dt,
             Creat_By,                Prg_Id,                   Dp_Folio_No,              Trade_Status,
             ------------
             Security_Id,             Internal_Ref_No,          Settlement_Type,          Order_Type,
             Sip_Regn_No,             Sip_Regn_Date,            Channel_Id,               Terminal_Id,
             Misdeal_Type,            Order_Stc_Type,           Facilitator_Code,         SUBBRCODE,
             EUIN,                    EUIN_DECL,                ALL_UNITS_FLAG,           DPC_FLAG,
             ORDER_SUB_TYPE,          FIRST_ORDER,              FRESH_ADDITIONAL,         MEMBER_REMARKS,
             KYC_FLAG,                MIN_REDM_FLG,             SUB_BRK_ARN_CD,           MFSS_FUNDS_PAYIN_SUCCESS_YN
              )
          VALUES
            (l_Order_No,              P_Exch_Id,                l_Mutual_Fund_Seg,        l_Stc_No,
             l_Buy_Sell_Flg,          l_Allotment_Mode,         l_Order_Date,             l_Order_Time,
             ----------
             l_Amc_Code,              l_Scheme_Code,            l_Rta_Code,               l_Rta_Scheme_Code,
             l_Scheme_Category,       l_Scheme_Symbol,          l_Scheme_Series,          l_Scheme_Option_Type,
             ----------
             l_Isin,                  l_Quantity,               l_Amount,                 l_Purchase_Type,
             l_Member_Code,           l_Branch_Code,            l_Dealer_Code,            l_Folio_No,
             ----------
             l_Payout_Mechanism,      l_Application_No,         l_Ent_Id,                 l_Tax_Status,
             l_Holding_Mode,          l_First_Client_Name,      l_First_Client_Pan,       l_First_Client_Kyc_Flag,
             ----------
             l_Second_Client_Name,    l_Second_Client_Pan,      l_Second_Client_Kyc_Flag, l_Third_Client_Name,
             l_Third_Client_Pan,      l_Third_Client_Kyc_Flag,  l_Guardian_Name,          l_Guardian_Pan,
             ----------
             l_Dp_Name,               l_Dp_Id,                  l_Dp_Acc_No,              l_Mobile_No,
             l_Bank_Acc_Type,         l_Bank_Acc_No,            l_Bank_Name,              l_Bank_Branch,
             ----------
             l_Bank_City,             l_Micr_Code,              l_Neft_Code,              l_Rtgs_Code,
             l_Email_Id,              l_Confirmation_Flag,      l_Reject_Reason,          l_Scheme_Name,
             ----------
             l_Entry_By,              l_Order_Status,           l_Order_Remark,           SYSDATE,
             USER,                    l_Prg_Id,                 l_Dp_Folio_No,            l_Trd_Status,
             ----------
             l_Security_Id,           l_Internal_Ref_No,        l_Settlement_Type,        l_Order_Type,
             l_Sip_Regn_No,           l_Sip_Regn_Date,          l_Channel_Id,             l_Terminal_Id,
             l_Misdeal_Type,          l_Order_Stc_Type,         l_Facilitator_Code,       l_SubBr_Code,
             l_EUIN,                  l_EUIN_Decl,              l_ALL_Units,              l_DPC ,
             l_Sub_Order_Type,        l_First_Order,            l_Fresh_Add,              l_Member_Remarks,
             l_KYC_Flag,              l_MIN_redm_flg,           l_Sub_Brk_ARN_Cd,         DECODE(l_Order_Status, 'VALID',DECODE(l_Buy_Sell_Flg ,'P','Y','N'), 'N')     --CR1231         
             );

          l_Count_Inserted := l_Count_Inserted + 1;


          IF l_Trd_Status != 'A' THEN
            l_Count_Misdeal := l_Count_Misdeal + 1;
          END IF;

        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            SELECT Amount,
                   Confirmation_Flag
            INTO   l_Prev_Amt,
                   l_Prev_Status
            FROM   Mfss_Trades F
            WHERE  Order_No = l_Order_No
            AND    Exm_Id = p_Exch_Id
            AND    Buy_Sell_Flg = l_Buy_Sell_Flg
            AND    Security_Id = l_Security_Id
            AND    Order_Date = l_Order_Date;

            UPDATE Mfss_Trades
            SET    Stc_Type               = l_Mutual_Fund_Seg,
                   Stc_No                 = l_Stc_No,
                   Allotment_Mode         = l_Allotment_Mode,
                   Order_Time             = l_Order_Time,
                   Amc_Code               = l_Amc_Code,
                   Rta_Code               = l_Rta_Code,
                   Rta_Scheme_Code        = l_Rta_Scheme_Code,
                   Scheme_Category        = l_Scheme_Category,
                   Scheme_Symbol          = l_Scheme_Symbol,
                   Scheme_Series          = l_Scheme_Series,
                   Scheme_Option_Type     = l_Scheme_Option_Type,
                   Isin                   = l_Isin,
                   Quantity               = Decode(l_Buy_Sell_Flg,'P',Quantity,l_Quantity),
                   Amount                 = Decode(l_Buy_Sell_Flg,'R',Amount,l_Amount),
                   Purchase_Type          = l_Purchase_Type,
                   Member_Code            = l_Member_Code,
                   Branch_Code            = l_Branch_Code,
                   Dealer_Code            = l_Dealer_Code,
                   Folio_No               = Nvl(Folio_No,l_Folio_No),
                   Payout_Mechanism       = l_Payout_Mechanism,
                   Application_No         = l_Application_No,
                   Ent_Id                 = l_Ent_Id,
                   Tax_Status             = l_Tax_Status,
                   Holding_Mode           = l_Holding_Mode,
                   First_Client_Name      = l_First_Client_Name,
                   First_Client_Pan       = l_First_Client_Pan,
                   First_Client_Kyc_Flag  = l_First_Client_Kyc_Flag,
                   Second_Client_Name     = l_Second_Client_Name,
                   Second_Client_Pan      = l_Second_Client_Pan,
                   Second_Client_Kyc_Flag = l_Second_Client_Kyc_Flag,
                   Third_Client_Name      = l_Third_Client_Name,
                   Third_Client_Pan       = l_Third_Client_Pan,
                   Third_Client_Kyc_Flag  = l_Third_Client_Kyc_Flag,
                   Guardian_Name          = l_Guardian_Name,
                   Guardian_Pan           = l_Guardian_Pan,
                   Dp_Name                = l_Dp_Name,
                   Dp_Id                  = l_Dp_Id,
                   Dp_Acc_No              = l_Dp_Acc_No,
                   Mobile_No              = l_Mobile_No,
                   Bank_Acc_Type          = l_Bank_Acc_Type,
                   Bank_Acc_No            = l_Bank_Acc_No,
                   Bank_Name              = l_Bank_Name,
                   Bank_Branch            = l_Bank_Branch,
                   Bank_City              = l_Bank_City,
                   Micr_Code              = l_Micr_Code,
                   Neft_Code              = l_Neft_Code,
                   Rtgs_Code              = l_Rtgs_Code,
                   Email_Id               = l_Email_Id,
                   Confirmation_Flag      = Decode(Order_Status,'CANCEL',Confirmation_Flag,l_Confirmation_Flag),
                   Reject_Reason          = l_Reject_Reason,
                   Scheme_Name            = l_Scheme_Name,
                   Entry_By               = l_Entry_By,
                   order_status           = Decode(Order_Status,'CANCEL',Order_Status,'VALID',Decode(l_Order_Status,'F',Order_Status,l_Order_Status),
                                                    Decode(l_Order_Status,'VALID',
                                                             Decode(P_Source,'MTS',(decode(order_status,'F',l_Order_Status,order_status)),order_status),l_Order_Status)),
                   Order_Remark           = Decode(Order_Status,'CANCEL',Order_Remark,l_Order_Remark),
                   Prg_Id                 = l_Prg_Id,
                   Dp_Folio_No            = l_Dp_Folio_No,
                   Internal_Ref_No        = l_Internal_Ref_No,
                   Settlement_Type        = l_Settlement_Type,
                   Order_Type             = l_Order_Type,
                   Sip_Regn_No            = l_Sip_Regn_No,
                   Sip_Regn_Date          = l_Sip_Regn_Date,
                   Channel_Id             = Nvl(Channel_Id,l_Channel_Id),
                   Terminal_Id            = Nvl(Terminal_Id,l_Terminal_Id),
                   Last_Updt_By           = USER,
                   Last_Updt_Dt           = SYSDATE,
                   Facilitator_Code       = Decode(P_Source,'MTS',l_Facilitator_Code,Facilitator_Code)
                  --- MFSS_FUNDS_PAYIN_SUCCESS_YN = 'Y'    --CR1231
            WHERE  Order_No               = l_Order_No
            AND    Exm_Id                 = p_Exch_Id
            AND    Buy_Sell_Flg           = l_Buy_Sell_Flg
            AND    Security_Id            = l_Security_Id
            AND    Order_Date             = l_Order_Date;

            UPDATE Mfss_Trades 
            SET    MFSS_FUNDS_PAYIN_SUCCESS_YN = DECODE(order_status, 'VALID',DECODE(Buy_Sell_Flg ,'P','Y','N'), 'N') --CR1231
            WHERE  Order_No               = l_Order_No
            AND    Exm_Id                 = p_Exch_Id
            AND    Buy_Sell_Flg           = l_Buy_Sell_Flg
            AND    Security_Id            = l_Security_Id
            AND    Order_Date             = l_Order_Date;

            IF l_Trd_Status != 'A' THEN
               l_Count_Misdeal := l_Count_Misdeal + 1;
            ELSE
               l_Count_Update  := l_Count_Update + 1;
            END IF;

            IF l_Confirmation_Flag = 'N' THEN
               SELECT COUNT(1)
               INTO   l_Cancel_Trade_Cnt
               FROM   Mfss_Trades a
               WHERE  Order_No                    = l_Order_No
               AND    Exm_Id                      = P_Exch_Id
               AND    Buy_Sell_Flg                = l_Buy_Sell_Flg
               AND    Security_Id                 = l_Security_Id
               AND    Order_Date                  = l_Order_Date
               AND    Ent_Id                      = l_Ent_Id
               AND    Stc_No                      = l_Stc_No
               AND    Order_Status                = 'CANCEL'
               AND    Confirmation_Flag           = 'N'
               AND    Mfss_Funds_Payin_Success_Yn = 'N';
            ELSE
                l_Cancel_Trade_Cnt := 0;
            END IF;

            IF l_Confirmation_Flag = 'N' THEN
              SELECT Count(1)
              INTO   l_Count_Cn
              FROM   Mfss_contract_note a
              Where  Exm_id           = p_Exch_Id
              AND    Buy_Sell_Flag    = l_Buy_Sell_Flg
              AND    Transaction_Date = l_Order_Date
              AND    Order_no         = l_Order_No
              AND    Amc_Scheme_Code  = l_Security_Id
              AND    Ent_Id           = l_Ent_Id
              AND    Stc_No           = l_Stc_No;
            ELSE
              l_Count_Cn := 0;
            END IF;

            IF l_Cancel_Trade_Cnt = 0 AND (l_Count_Cn > 0 OR (l_Prev_Amt <> l_Amount))
                                      AND  l_Order_No <> 0 THEN

              P_Ret_Msg := ' Calling Reverse Bill procedure for order no  <' || l_Order_No ||'>, Client <' || l_Ent_Id || '> ,
                             Scheme Code, ' ||l_Scheme_Code || '> ,Sett No. < ' || l_Stc_No ||'>,order type <' || l_Buy_Sell_Flg || '>
                             and Confirmation Flag <'||l_Confirmation_Flag||'>';

              Pkg_Mfss_Settlement_Funds.P_Reverse_Bills(l_Ent_Id,
                                                        l_Order_No,
                                                        l_Order_Date,
                                                        l_Buy_Sell_Flg,
                                                        p_Exch_Id,
                                                        l_Stc_No,
                                                        l_Security_Id,
                                                        'ORDER CANCELLATION SCREEN',
                                                        'A',
                                                        p_Ret_Val,
                                                        l_Total_Rev_Bills);


              IF p_Ret_Val <> 'SUCCESS' THEN
                p_Ret_Msg := 'Error occurred in reversing the bills for client: ' || l_Ent_Id || ', Order No: '|| l_Order_No ||', Exchange: '||p_Exch_Id || ', Date: '||l_Order_Date ||', Security_id: ' ||l_Security_Id;
                Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
              ELSE
                p_Ret_Msg := 'Reversing the bills and canceling the contract for client: ' || l_Ent_Id || ', Order No: '|| l_Order_No ||', Exchange: '||p_Exch_Id || ', Date: '||l_Order_Date ||', Security_id: ' ||l_Security_Id;
                Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
              END IF;
            END IF;

            IF l_Prev_Amt <> l_Amount AND (l_Prev_Status = l_Confirmation_Flag)
                                      AND  l_Order_Status = 'VALID' THEN
              UPDATE Mfss_Trades t
              SET    t.contract_no       = NULL,
                     t.Confirmation_Flag = 'Y',
                     t.bill_no           = NULL,
                     t.Order_Status      = 'VALID',
                     t.order_remark      = l_Order_Remark,
                     t.reject_reason     = NULL
              WHERE  t.Order_No          = l_Order_No
              AND    t.Exm_Id            = p_Exch_Id
              AND    t.Stc_No            = l_Stc_No
              AND    t.Buy_Sell_Flg      = l_Buy_Sell_Flg
              AND    t.Order_Date        = l_Order_Date
              AND    t.Ent_Id            = l_Ent_Id
              AND    t.Security_Id       = l_Security_Id;
            END IF;

            p_Ret_Msg := ' Updating Hrt_Sec_All_Txn for Client <'||l_Ent_Id||'> and ISIN <'||l_Isin||'>';

            IF P_Source = 'EXCH' OR (P_Source = 'MTS' AND Trim(P_File_Name) IS NOT NULL) THEN
               IF (P_Exch_Id = 'NSE' AND P_Final_Flag = 'F' AND Instr(Upper(p_File_Name), 'FNL') = 0)
                 OR (P_Exch_Id = 'BSE' AND P_Final_Flag = 'F' AND Instr(Upper(p_File_Name), 'ORDER') = 0) THEN

                  IF l_Order_Status = 'INVALID' AND l_Confirmation_Flag = 'N' THEN

                     SELECT COUNT(1)
                     INTO   l_Update_Htrf_Count
                     FROM   Hrt_Sec_All_Txn
                     WHERE  Hat_Txn_Cd    = 'HTRF'
                     AND    Hat_Db_Cr_Flg = 'D'
                     AND    Hat_Txn_Dt    = l_Pam_Curr_Date
                     AND    Hat_Ent_Id    = l_Ent_Id
                     AND    Hat_Isin_Id   = l_Isin
                     AND    Hat_Sem_Id    = l_Security_Id
                     AND    Hat_Dem_Id    = l_Dp_Name
                     AND    Hat_Dpm_Id    = l_Dp_Id
                     AND    Hat_Acc_No    = l_Dp_Acc_No  ;

                     IF l_Update_Htrf_Count > 0 THEN

                         UPDATE Hrt_Sec_All_Txn a
                         SET    Hat_Appr_Flg = 'I',
                                Hat_Last_Updt_Dt = SYSDATE,
                                Hat_Last_Updt_By = USER,
                                Hat_Prg_Id       = l_Prg_Id
                         WHERE  Hat_Txn_Cd    = 'HTRF'
                         AND    Hat_Db_Cr_Flg = 'D'
                         AND    Hat_Txn_Dt    = l_Pam_Curr_Date
                         AND    Hat_Ent_Id    = l_Ent_Id
                         AND    Hat_Isin_Id   = l_Isin
                         AND    Hat_Sem_Id    = l_Security_Id
                         AND    Hat_Dem_Id    = l_Dp_Name
                         AND    Hat_Dpm_Id    = l_Dp_Id
                         AND    Hat_Acc_No    = l_Dp_Acc_No;

                     END IF;
                  END IF;
               END IF;
            END IF;
          WHEN OTHERS THEN
            p_Ret_Msg := p_Ret_Msg || SQLERRM;
            RAISE Excp_Terminate;
        END;

        l_Count_Records := l_Count_Records + 1;
      EXCEPTION
        WHEN Excp_Skip THEN
          IF l_Is_Header_Found = 'Y' THEN
            l_Header_Skipped := l_Header_Skipped + 1;
          ELSE
           l_Count_Skipped := l_Count_Skipped + 1;
          END IF;
          l_Is_Header_Found := 'N';
      END;
    END LOOP;

    SELECT COUNT(1) ,
           COUNT(decode(confirmation_flag ,'Y',1)),
           COUNT(decode(confirmation_flag ,'N',1))
    INTO   l_Count_Trades ,
           l_Count_Confirmed_Trades ,
           l_Count_Cancelled_Trades
    FROM   Mfss_Trades
    WHERE  Order_Date = l_Pam_Curr_Date
    AND    Exm_Id = p_Exch_Id;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    IF P_Source = 'EXCH' THEN
       Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File               : ' ||l_Line_Count);
    ELSE
       Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in View               : ' ||l_Line_Count);
    END IF;
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Orders Inserted                  : ' ||l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Misdeal  Orders                  : ' ||l_Count_Misdeal);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Orders Updated                   : ' ||l_Count_Update);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Orders Skipped                   : ' ||l_Count_Skipped);
    Utl_File.Put_Line(l_Log_File_Handle, ' Header Skipped                          : ' ||l_Header_Skipped);
    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, '');
    Utl_File.Put_Line(l_Log_File_Handle, ' Total No. of Orders for the day for ' || p_Exch_Id || '           : ' || l_Count_Trades);
    Utl_File.Put_Line(l_Log_File_Handle, ' Total No. of Confirmed orders for the day for ' || p_Exch_Id || ' : ' || l_Count_Confirmed_Trades);
    Utl_File.Put_Line(l_Log_File_Handle, ' Total No. of Cancelled orders for the day for ' || p_Exch_Id || ' : ' || l_Count_Cancelled_Trades);
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN Excp_Terminate THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||
                   '**Error Occured while :' || p_Ret_Msg;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := Dbms_utility.format_error_backtrace||chr(10)||
                   '**Error Occured while :' || p_Ret_Msg ||SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END P_Download_Order_File;

  --- All IN Parameters are mandatory --
  PROCEDURE P_Load_Allotment_File(P_File_Name           IN VARCHAR2,
                                  P_Exch_Id             IN VARCHAR2,
                                  P_Success_Reject_Flag IN VARCHAR2,
                                  P_Ret_Val             IN OUT VARCHAR2,
                                  P_Ret_Msg             IN OUT VARCHAR2)
  IS

    l_Pam_Curr_Date               DATE;
    l_File_Path                   VARCHAR2(300);
    l_Log_File_Handle             Utl_File.File_Type;
    l_Log_File_Name               VARCHAR2(100);
    l_Prg_Process_Id              NUMBER := 0;
    l_Line_Count                  NUMBER := 0;
    l_Prg_Id                      VARCHAR2(20) := 'CSSALLST';
    Tab_File_Rcd                  Std_Lib.Tab;
    Tab_Split_Rcd                 Std_Lib.Tab;
    l_Report_Date                 VARCHAR2(20);
    l_Order_No                    NUMBER(16);
    l_Sett_Type                   VARCHAR2(5);
    l_Sett_No                     VARCHAR2(7);
    l_Order_Date                  VARCHAR2(20);
    l_Scheme_Code                 VARCHAR2(20);
    l_Isin                        VARCHAR2(12);
    l_Member_Id                   VARCHAR2(10);
    l_Branch_Code                 VARCHAR2(10);
    l_User_Id                     NUMBER;
    l_Folio_No                    VARCHAR2(16);
    l_Rta_Scheme_Code             VARCHAR2(20);
    l_Rta_Trans_No                VARCHAR2(20);
    l_Client_Code                 VARCHAR2(10);
    l_Client_Name                 VARCHAR2(70);
    l_Beneficiary_Id              VARCHAR2(20);
    l_Allotted_Nav                NUMBER;
    l_Allotted_Unit               NUMBER;
    l_Allotment_Amt               NUMBER;
    l_Valid_Flag                  VARCHAR2(1);
    l_Remarks                     VARCHAR2(200);
    l_Report_Dt                   DATE;
    l_Allotment_Mode              VARCHAR2(20);
    l_Order_Time                  VARCHAR2(10);
    l_Scheme_Category             VARCHAR2(20);
    l_Amc_Code                    VARCHAR2(50);
    l_Rta_Code                    VARCHAR2(20);
    l_Scheme_Symbol               VARCHAR2(20);
    l_Scheme_Series               VARCHAR2(20);
    l_Scheme_Option_Type          VARCHAR2(20);
    l_Ordered_Amount              NUMBER(20,2);
    l_Ordered_Qty                 NUMBER(20,4);
    l_Purchase_Type               VARCHAR2(50);
    l_Payout_Mechanism            VARCHAR2(50);
    l_Application_No              VARCHAR2(20);
    l_Tax_Status                  VARCHAR2(20);
    l_Holding_Mode                VARCHAR2(20);
    l_Depository_Name             VARCHAR2(70);
    l_Depository_Id               VARCHAR2(30);
    l_Depository_Client_Id        VARCHAR2(30);
    l_Success_Reject_Status       VARCHAR2(30);
    l_Security_Id                 VARCHAR2(30);
    l_Nse_Broker_Cd               VARCHAR2(30);
    l_Bse_Broker_Cd               VARCHAR2(30);
    l_Mutual_Fund_Seg             VARCHAR2(30);
    l_Stt                         NUMBER(18,2);
    l_Internal_Ref_No             VARCHAR2(10);
    l_Order_Type                  VARCHAR2(3);
    l_Sip_Regn_No                 NUMBER;
    l_Sip_Regn_Date               DATE;
    l_Sip_Regn_Dt_String          VARCHAR2(20);
    l_Message                     VARCHAR2(300);
    l_Count_Skip                  NUMBER := 0;
    l_Count_Inserted              NUMBER := 0;
    l_Count_Records               NUMBER := 0;
    l_Count_Bill_Reversed         NUMBER := 0;
    l_Rev_Ret_Msg                 VARCHAR2(3000);
    l_Total_Reverse_Cnt           NUMBER := 0;
    l_Cnt_Cancelled               NUMBER := 0;
    l_Count_Skipped               NUMBER := 0;
    Excp_Terminate                EXCEPTION;
    Excp_Skip                     EXCEPTION;
    Excp_Skip_Header              EXCEPTION;
    Excp_Sch_Cd_Missing           EXCEPTION;
    l_Sub_Broker_Cd               VARCHAR2(20);  -- New fields BSE
    l_EUIN                        VARCHAR2(20);
    l_EUIN_DECL                   VARCHAR2(30);
    l_DPC_Flag                    VARCHAR2(5);
    l_DP_Trans                    VARCHAR2(5);
    l_Order_Sub_Type              VARCHAR2(10);
  l_scheme_name                 VARCHAR2(300);  --New File Structure BSE  19JUN2020
    l_stamp_duty                  NUMBER(25,8);


  BEGIN

    Tab_File_Rcd.DELETE;

    P_Ret_Msg := ' In Housekeeping. Check if file exists in /ebos/files/upstrem or Program is running.';
    Std_Lib.P_Housekeeping(l_Prg_Id,
                           P_Exch_Id,
                           P_Exch_Id || ',' || P_File_Name,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    P_Ret_Msg := 'Getting current working date';
    l_Pam_Curr_Date  := Std_lib.l_Pam_Curr_Date;

    P_Ret_Msg := ' Getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    P_Ret_Msg := ' Loading the file ';
    Std_Lib.Load_File(l_File_Path,
                      P_File_Name,
                      l_Line_Count,
                      Tab_File_Rcd);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,' Current Working Date    : ' ||To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || P_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name                   : ' || P_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' Success\Reject File         : ' || P_Success_Reject_Flag);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    P_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain       = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value    = P_Exch_Id
    AND    Rv_Abbreviation = 'MFSS';

    P_Ret_Msg := 'Getting the Broker Code from the Master''s for segment <' ||l_Mutual_Fund_Seg || '> .';
    SELECT MAX(Decode(Eam_Exm_Id, 'NSE', Eam_Broker_Id)),
           MAX(Decode(Eam_Exm_Id, 'BSE', Eam_Broker_Id))
    INTO   l_Nse_Broker_Cd,
           l_Bse_Broker_Cd
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Seg_Id = l_Mutual_Fund_Seg;

    FOR Line_No IN Tab_File_Rcd.FIRST .. Nvl(Tab_File_Rcd.LAST, 0)
    LOOP
      BEGIN

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Rcd.DELETE;

        P_Ret_Msg := '2: Splitting fields in the line buffer';

        IF P_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Rcd(Line_No), '|', Tab_Split_Rcd);
        ELSIF P_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Rcd(Line_No), '|', Tab_Split_Rcd);
        END IF;

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Rcd.FIRST .. Tab_Split_Rcd.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,'<' || i || '>' || ' = <' || Tab_Split_Rcd(i) || '>');
          END LOOP;
        END IF;

        IF P_Exch_Id = 'BSE' THEN

           l_Report_Date       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST);
           l_Order_No          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 1);
           l_Sett_Type         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 2);
           l_Sett_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 3);
           l_Order_Date        := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 4),'RRRR-MM-DD');
           l_Scheme_Code       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 5);
           l_Isin              := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 6);
           l_Ordered_Amount    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 7);
           l_Ordered_Qty       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 8);
           l_Member_Id         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 9);

           l_Branch_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 10);
           l_User_Id            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 11);
           l_Folio_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 12);
           l_Rta_Scheme_Code    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 13);
           l_Rta_Trans_No       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 14);
           l_Client_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 15);

           BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, l_Client_Code)
              INTO l_Client_Code
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = l_Client_Code;
           EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                l_Client_Code || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
           END;

           l_Client_Name        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 16);
           l_Beneficiary_Id     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 17);
           l_Allotted_Nav       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 18);
           l_Allotted_Unit      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 19);
           l_Allotment_Amt      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
           l_Valid_Flag         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
           l_Remarks            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
           l_Stt                := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
           l_Internal_Ref_No    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);
           l_Order_Type         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);
           l_Sip_Regn_No        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);
           l_Sip_Regn_Dt_String := TRIM(Substr(Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 27),1,10));
           l_Allotment_Mode     := l_Valid_Flag;
           l_Sub_Broker_Cd      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 28);
           l_EUIN               := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);
           l_EUIN_DECL          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 30);
           l_DPC_Flag           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 31);
           l_DP_Trans           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 32);
           l_Order_Sub_Type     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 33);
       l_Scheme_name        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 34);     --New File Structure BSE
           l_stamp_duty         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 35);


          /* Changes done 0n 14-Jul-2012 */
           IF l_Member_Id IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
           END IF;

           IF substr(l_Member_Id ,1,1) = '0' THEN
             IF  l_Member_Id <> l_Bse_Broker_Cd THEN
                 l_Member_Id :=  substr(l_Member_Id,2);
             END IF;
           END IF;

           IF Nvl(l_Member_Id,1) <> l_Bse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Id ||'> of file for the order no < '||l_Order_No||
              '> does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
           END IF;

          /* Changes done 0n 14-Jul-2012 */

          BEGIN
            P_Ret_Msg := 'Scheme code  < '||l_Scheme_Code||'>.';
            SELECT Msm_Scheme_Id
            INTO   l_Security_Id
            FROM   Mfd_Scheme_Master
            WHERE  Decode(l_Sett_Type,'L0',Msm_Bse_LO_Scheme_Code,'L1',Msm_Bse_L1_Scheme_Code, Msm_Bse_Code) =  l_Scheme_Code
            AND    Msm_Status = 'A'
            AND    Msm_Record_Status = 'A'
            AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;

          l_Depository_Id := Substr(l_Beneficiary_Id, 1, 8);
          BEGIN
            SELECT Dpm_Dem_Id,
                   Decode(Dpm_Dem_Id,'NSDL',Substr(l_Beneficiary_Id,9,8),'CDSL',l_Beneficiary_Id)
            INTO   l_Depository_Name,
                   l_Depository_Client_Id
            FROM   Depo_Participant_Master
            WHERE  Dpm_Id = l_Depository_Id;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,' For Order No <'||l_Order_No||'>, Client <'||l_Client_Code||
                                                  '>, Scheme <'||l_Scheme_Code||'>, DP Id <'||l_Depository_Id||
                                                  '> does not exist in the system, hence skipping the record');
              RAISE Excp_Skip;
          END;

        ELSIF P_Exch_Id = 'NSE' THEN
          l_Report_Date        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST);

          IF UPPER(l_Report_Date) like '%DATE%' THEN
            Utl_File.Put_Line(l_Log_File_Handle,'Header Record Found. hence skipping the same .');
            RAISE Excp_Skip;
          END IF;

          l_Report_Date        := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST),'DDMMYYYY');
          l_Order_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 1);
          l_Sett_Type          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 2);
          l_Sett_No            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 3);
          l_Allotment_Mode     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 4);
          l_Order_Date         := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 5),'DDMMYYYY');
          l_Order_Time         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 6);
          l_Scheme_Category    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 7);
          l_Amc_Code           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 8);
          l_Scheme_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 9);
          l_Rta_Code           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 10);
          l_Rta_Scheme_Code    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 11);
          l_Scheme_Symbol      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 12);
          l_Scheme_Series      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 13);
          l_Scheme_Option_Type := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 14);
          l_Isin               := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 15);
          l_Ordered_Amount     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 17);
          l_Ordered_Qty        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 16);
          l_Purchase_Type      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 18);
          l_Member_Id          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 19);
          l_Branch_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
          l_User_Id            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
          l_Folio_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
          l_Payout_Mechanism   := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
          l_Application_No     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);
          l_Client_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);

          BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, L_CLIENT_CODE)
              INTO L_CLIENT_CODE
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = L_CLIENT_CODE;
          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                L_CLIENT_CODE || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
          END;

          l_Tax_Status         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);
          l_Holding_Mode       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 27);
          l_Client_Name        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 28);

           /* Changes done 0n 14-Jul-2012 */
          IF l_Member_Id IS NULL THEN
             P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
          END IF;

          IF substr(l_Member_Id ,1,1) = '0' THEN
             IF  l_Member_Id <> l_Nse_Broker_Cd THEN
                 l_Member_Id :=  substr(l_Member_Id,2);
             END IF;
          END IF;

          IF Nvl(l_Member_Id,1) <> l_Nse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Id ||'> of file for the order no < '||l_Order_No||
              '> does not match with the NSE member code <' ||l_Nse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
          END IF;

          /* Changes done 0n 14-Jul-2012 */

          P_Ret_Msg := 'Getting  fields values for Success reject Flag <' || P_Success_Reject_Flag || '>.';

          IF P_Success_Reject_Flag = 'SUCCESS' THEN

             l_Depository_Name      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);
             l_Depository_Id        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 30);
             l_Depository_Client_Id := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 31);
             l_Allotted_Nav         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 32);
             l_Allotted_Unit        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 33);
             l_Allotment_Amt        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 34);
       l_stamp_duty           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 40);
             l_Valid_Flag           := l_Allotment_Mode;

          ELSIF P_Success_Reject_Flag = 'REJECT' THEN

             l_Valid_Flag := 'N';
             l_Remarks    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);

          END IF;

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Decode(l_Scheme_Category,'DBTCR',Msm_Nse_L1_Scheme_Code,'HLIQD',Msm_Nse_Lo_Scheme_Code,Msm_Nse_Code) = l_Scheme_Symbol || l_Scheme_Series
            AND   Msm_Status        = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
             WHEN No_Data_Found THEN
               RAISE Excp_Sch_Cd_Missing;
          END;

          BEGIN
            SELECT Rv_Low_Value
            INTO   l_Sett_Type
            FROM   Cg_Ref_Codes
            WHERE  Rv_Domain     = 'MF_NSE_SETTLEMENT_TYPE'
            AND    Rv_High_Value = l_Scheme_Category;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,'  Settlement Type not found for scheme Category <' || l_Scheme_Category ||'>');
              RAISE Excp_Skip;
          END;
        END IF;

        IF P_Exch_Id = 'NSE' THEN
           l_Report_Dt := To_Date(l_Report_Date, 'DD-MM-RRRR');
        ELSIF P_Exch_Id = 'BSE' THEN
           l_Report_Dt     := To_Date(l_Report_Date, 'RRRR-MM-DD');
           --l_Sip_Regn_Date := To_Date(l_Sip_Regn_Dt_String, 'RRRR-MM-DD');
           l_Sip_Regn_Date := To_Date(l_Sip_Regn_Dt_String, 'DD/MM/YYYY');
        END IF;

        BEGIN
          IF P_Exch_Id = 'BSE' THEN
            IF l_Valid_Flag = 'Y' THEN
              l_Success_Reject_Status := 'SUCCESS';
            ELSE
              l_Success_Reject_Status := 'REJECT';
            END IF;
          ELSIF P_Exch_Id = 'NSE' THEN
              l_Success_Reject_Status := P_Success_Reject_Flag;
          END IF;

          IF P_Exch_Id = 'BSE' OR (P_Exch_Id = 'NSE' AND P_Success_Reject_Flag = 'SUCCESS') THEN
            IF (Nvl(l_Allotted_Nav,0)= 0 OR Nvl(l_Allotted_Unit,0) = 0 OR Nvl(l_Allotment_Amt,0)=0) THEN
               Utl_File.Put_Line(l_Log_File_Handle,'Record skipped for Order No <'||l_Order_No||'>Since either of Allotment Nav <'||l_Allotted_Nav ||'>,Allotment Quantity <'||l_Allotted_Unit||'>and Allotment Amount<'||l_Allotment_Amt||'>');
               RAISE Excp_Skip;
            END IF;
          END IF;

          P_Ret_Msg := 'Inserting Data in allotment for order no  <' || l_Order_No ||'>, Client <' || l_Client_Code || '> , Scheme , ' ||
                        l_Scheme_Code || '> ,Sett No. < ' || l_Sett_No ||'> and   order date <' || l_Order_Date || '>';

          INSERT INTO Allotment_Statement
            (Report_Date,             Order_No,               Sett_Type,              Sett_No,
             Allotment_Mode,          Order_Date,             Order_Time,             Scheme_Code,
             ---------
             Scheme_Category,         Amc_Code,               Rta_Code,               Rta_Scheme_Code,
             Scheme_Symbol,           Scheme_Series,          Scheme_Option_Type,     Isin,
             --------
             Ordered_Amount,          Ordered_Qty,            Purchase_Type,          Member_Id,
             Branch_Code,             User_Id,                Folio_No,               Rta_Trans_No,
             ----------
             Payout_Mechanism,        Application_No,         Client_Code,            Tax_Status,
             Holding_Mode,            Client_Name,            Beneficiary_Id,         Depository_Name,
             ----------
             Depository_Id,           Depository_Client_Id,   Allotted_Nav,           Allotted_Unit,
             Allotment_Amt,           Valid_Flag,             Remarks,                Creat_Dt,
             ----------
             Creat_By,                Prg_Id,                 Security_Id,            Exm_Id,
             Success_Reject_Status,   Stt,                    Internal_Ref_No,        Order_Type,
             ---------
             Sip_Regn_No,             Sip_Regn_Date,          Settlement_Type,        SUB_BR_CODE,
             EUIN,                    EUIN_DECL,              DPC_Flag,               DP_Trans,
             Order_Sub_Type,          Scheme_Name,            Stamp_Duty)

          VALUES
            (l_Report_Dt,             l_Order_No,             l_Mutual_Fund_Seg,      l_Sett_No,
             l_Allotment_Mode,        l_Order_Date,           l_Order_Time,           l_Scheme_Code,
             --------
             l_Scheme_Category,       l_Amc_Code,             l_Rta_Code,             l_Rta_Scheme_Code,
             l_Scheme_Symbol,         l_Scheme_Series,        l_Scheme_Option_Type,   l_Isin,
             ---------
             l_Ordered_Amount,        l_Ordered_Qty,          l_Purchase_Type,        l_Member_Id,
             l_Branch_Code,           l_User_Id,              l_Folio_No,             l_Rta_Trans_No,
             ----------
             l_Payout_Mechanism,      l_Application_No,       l_Client_Code,          l_Tax_Status,
             l_Holding_Mode,          l_Client_Name,          l_Beneficiary_Id,       l_Depository_Name,
             -----------
             l_Depository_Id,         l_Depository_Client_Id, l_Allotted_Nav,         l_Allotted_Unit,
             l_Allotment_Amt,         l_Valid_Flag,           l_Remarks,              SYSDATE,
             -----------
             USER,                    l_Prg_Id,               l_Security_Id,          P_Exch_Id,
             l_Success_Reject_Status, l_Stt,                  l_Internal_Ref_No,      l_Order_Type,
             ---------
             l_Sip_Regn_No,           l_Sip_Regn_Date,        l_Sett_Type,            l_Sub_Broker_Cd,
             l_EUIN,                  l_EUIN_DECL,            l_DPC_Flag,             l_DP_Trans,
             l_Order_Sub_Type,        l_scheme_name,          l_stamp_duty);

          P_Ret_Msg := 'Updating data in Trades for order no  <' ||l_Order_No || '>, Client <' || l_Client_Code ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||l_Sett_No || '> and   order date <' || l_Order_Date || '>';

          UPDATE Mfss_Trades Mt
          SET    Mt.Quantity      = l_Allotted_Unit,
                 Mt.Alloted_Nav   = l_Allotted_Nav,
                 Mt.Folio_No      = l_Folio_No,
                 Mt.Stamp_Duty    = l_Stamp_Duty,
                 Mt.Order_Status  = Decode(l_Success_Reject_Status, 'REJECT', 'CANCEL', Mt.Order_Status),
                 Mt.Order_Remark  = Decode(l_Success_Reject_Status, 'REJECT', l_Remarks, Mt.Order_Remark),
                 Mt.Reject_Reason = Decode(l_Success_Reject_Status, 'REJECT', 'CANCELLED IN LOAD ALLOTMENT FILE', Mt.Reject_Reason),
                 Mt.Last_Updt_Dt  = SYSDATE,
                 Mt.Last_Updt_By  = USER,
                 Mt.Prg_Id        = l_Prg_Id
          WHERE  Order_No         = l_Order_No
          AND    Exm_Id           = p_Exch_Id
          AND    Buy_Sell_Flg     = 'P'
          AND    Security_Id      = l_Security_Id;
         -- AND    Order_Date       = l_Order_Date;  -- AMEYA  , 13/APR/2022  , DUE TO DIFFERENT DATE PORTFOLIO NOT GETTING UPDAED

          P_Ret_Msg := 'Updating data in Contract Master for order no  <' ||l_Order_No || '>, Client <' || l_Client_Code ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||l_Sett_No || '> and   order date <' || l_Order_Date || '>';

          UPDATE Mfss_contract_note a
          SET    a.Quantity       = l_Allotted_Unit,
                 a.Amount         = l_Allotment_Amt,
                 a.Mf_Stamp_Duty  = l_Stamp_Duty,
                 a.Updated_By     = USER,
                 a.Updated_Date   = SYSDATE,
                 a.Prg_Id         = 'CSSREDST'
          Where  Exm_id           = p_Exch_Id
          AND    Buy_Sell_Flag    = 'P'
          AND    Transaction_Date = l_Order_Date
          AND    Order_no         = l_Order_No
          AND    Amc_Scheme_Code  = l_Security_Id
          AND    Ent_Id           = l_Client_Code
          AND    Stc_No           = l_Sett_No;


          l_Count_Inserted      := l_Count_Inserted + 1;

        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
              Utl_File.Put_Line(l_Log_File_Handle,'Trade Already Exists for order no  <' ||
                                                  l_Order_No || '>, Client <' ||
                                                  l_Client_Code || '> , Scheme , ' ||
                                                  l_Scheme_Code || '> ,Sett No. < ' ||
                                                  l_Sett_No || '> Hence skipping the record.');
            END IF;

            l_Count_Skip := l_Count_Skip + 1;
            l_Count_Records := l_Count_Records + 1;
            RAISE Excp_Skip_Header;
        END;

        l_Count_Records := l_Count_Records + 1;

        IF l_Allotment_Mode = 'N' THEN

        p_Ret_Msg := 'Reversing Bills for order no  <' || l_Order_No ||'> and client code <' || l_Client_Code || '>';

        Pkg_Mfss_Settlement_Funds.P_Reverse_Bills(l_Client_Code,
                                                  l_Order_No,
                                                  l_Order_Date,
                                                  'P',
                                                  p_Exch_Id,
                                                  l_Sett_No,
                                                  l_Security_Id,
                                                  'LOAD ALLOTMENT FILE',
                                                  'A',
                                                  l_Rev_Ret_Msg,
                                                  l_Count_Bill_Reversed);

        IF l_Rev_Ret_Msg <> 'SUCCESS' AND l_Rev_Ret_Msg <> 'CANCELLED' THEN
          p_Ret_Msg := p_Ret_Msg || ' ' || l_Rev_Ret_Msg || ' ' || SQLERRM;
          RAISE Excp_Terminate;
        END IF;

        IF l_Rev_Ret_Msg = 'CANCELLED' THEN
          l_Cnt_Cancelled := l_Cnt_Cancelled + 1;
        END IF;

      END IF;

      l_Total_Reverse_Cnt := l_Total_Reverse_Cnt + l_Count_Bill_Reversed;

      EXCEPTION
        WHEN Excp_Sch_Cd_Missing THEN
          Utl_File.Put_Line(l_Log_File_Handle, 'Please Map Scheme Code --> '||l_Scheme_Code
                                               ||' For Order No <'||l_Order_No||'>'
                                               ||' For Order Date <'||l_Order_Date||'>'
                                               ||' For Settlement No. <'||l_Sett_No||'>'
                                               ||' For Isin <'||l_Isin||'>'
                                               ||' For Folio No <'||l_Folio_No||'>'
                                               ||' For Client Code <'||l_Client_Code||'>'
                                               ||' For Client Name <'||l_Client_Name||'>'
                           );
          l_Count_Skipped := l_Count_Skipped + 1;
          l_Count_Records := l_Count_Records + 1;
        WHEN Excp_Skip THEN
          l_Count_Skipped := l_Count_Skipped + 1;
          l_Count_Records := l_Count_Records + 1;
        WHEN Excp_Skip_Header THEN
          NULL;
      END;
    END LOOP;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                  : ' || l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted                 : ' || l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records already Processed        : ' || l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                  : ' || l_Count_Skipped);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Bills Reversed                   : ' || l_Total_Reverse_Cnt);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Orders Already Cancelled         : ' || l_Cnt_Cancelled);
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);

    P_Ret_Val := 'SUCCESS';
    P_Ret_Msg := 'Process Completed Successfully ...';

  EXCEPTION
    WHEN Excp_Terminate THEN
      ROLLBACK;
      P_Ret_Val := 'FAIL';
      P_Ret_Msg := dbms_utility.format_error_backtrace||'**Error Occured while :' || p_Ret_Msg;

      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||'**Error Occured while :' || p_Ret_Msg ||'**Error Message is :' || SQLERRM;

      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END P_Load_Allotment_File;

  PROCEDURE P_Load_Redemption_File(P_File_Name           IN VARCHAR2,
                                   P_Exch_Id             IN VARCHAR2,
                                   P_Success_Reject_Flag IN VARCHAR2,
                                   P_Ret_Val             IN OUT VARCHAR2,
                                   P_Ret_Msg             IN OUT VARCHAR2)
  IS

    l_Pam_Curr_Date                DATE;
    l_File_Path                    VARCHAR2(300);
    l_Log_File_Handle              Utl_File.File_Type;
    l_Log_File_Name                VARCHAR2(100);
    l_Prg_Process_Id               NUMBER := 0;
    l_Line_Count                   NUMBER := 0;
    l_Prg_Id                       VARCHAR2(20) := 'CSSREDST';
    Tab_File_Rcd                   Std_Lib.Tab;
    Tab_Split_Rcd                  Std_Lib.Tab;
    l_Report_Date                  VARCHAR2(20);
    l_Order_No                     NUMBER(16);
    l_Sett_Type                    VARCHAR2(5);
    l_Sett_No                      VARCHAR2(7);
    l_Order_Date                   VARCHAR2(20);
    l_Scheme_Code                  VARCHAR2(20);
    l_Isin                         VARCHAR2(12);
    l_Member_Id                    VARCHAR2(10);
    l_Branch_Code                  VARCHAR2(10);
    l_User_Id                      NUMBER;
    l_Folio_No                     VARCHAR2(16);
    l_Rta_Scheme_Code              VARCHAR2(10);
    l_Rta_Trans_No                 VARCHAR2(20);
    l_Client_Code                  VARCHAR2(10);
    l_Client_Name                  VARCHAR2(70);
    l_Beneficiary_Id               VARCHAR2(20);
    l_Nav                          NUMBER(15,4);
    l_Unit                         NUMBER(15,4);
    l_Amt                          NUMBER;
    l_Valid_Flag                   VARCHAR2(1);
    l_Remarks                      VARCHAR2(200);
    l_Report_Dt                    DATE;
    l_Allotment_Mode               VARCHAR2(20);
    l_Order_Time                   VARCHAR2(10);
    l_Scheme_Category              VARCHAR2(20);
    l_Amc_Code                     VARCHAR2(50);
    l_Rta_Code                     VARCHAR2(20);
    l_Scheme_Symbol                VARCHAR2(20);
    l_Scheme_Series                VARCHAR2(20);
    l_Scheme_Option_Type           VARCHAR2(20);
    l_Ordered_Amount               NUMBER(15,2);
    l_Ordered_Qty                  NUMBER(15,4);
    l_Purchase_Type                VARCHAR2(50);
    l_Payout_Mechanism             VARCHAR2(50);
    l_Application_No               VARCHAR2(20);
    l_Tax_Status                   VARCHAR2(20);
    l_Holding_Mode                 VARCHAR2(20);
    l_Rejection_Reason             VARCHAR2(300);
    l_Message                      VARCHAR2(300);
    l_Count_Skip                   NUMBER := 0;
    l_Count_Inserted               NUMBER := 0;
    l_Count_Records                NUMBER := 0;
    l_Count_Skipped                NUMBER := 0;
    l_Security_Id                  VARCHAR2(30);
    l_Success_Reject_Status        VARCHAR2(30);
    l_Bank_Name                    VARCHAR2(300);
    l_Bank_Acc_Type                VARCHAR2(30);
    l_Bank_Acc_No                  VARCHAR2(30);
    l_Nse_Broker_Cd                VARCHAR2(30);
    l_Bse_Broker_Cd                VARCHAR2(30);
    l_Mutual_Fund_Seg              VARCHAR2(30);
    l_Depository_Name              VARCHAR2(30);
    l_Depository_Id                VARCHAR2(30);
    l_Depository_Client_Id         VARCHAR2(30);
    l_Stt                          NUMBER;
    l_Ret_Val                      VARCHAR2(4000);
    l_Ret_Msg                      VARCHAR2(4000);
    Excp_Terminate                 EXCEPTION;
    Excp_Skip                      EXCEPTION;
    Excp_Skip_Header               EXCEPTION;
    Excp_Sch_Cd_Missing            EXCEPTION;

    l_DPC                          VARCHAR2(5);  --new file format BSE
    l_DP_Trans                     VARCHAR2(5);
    l_Order_Type                   VARCHAR2(10);
    l_Sub_Order_Type               VARCHAR2(10);
   l_Scheme_Name                  VARCHAR2(300); --New File Format BSE 19 Jun 2020
    l_Exit_Load                    NUMBER(25,8);
    l_Tax                          NUMBER(25,8);
  BEGIN

    Tab_File_Rcd.DELETE;

    P_Ret_Msg := ' In Housekeeping. Check if file exists in /cbos/files/upstream or Program is running.';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Exch_Id || ',' || p_File_Name,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    P_Ret_Msg := ' Getting current working date';
    l_Pam_Curr_Date := Std_Lib.l_Pam_Curr_Date;


    P_Ret_Msg := ' Getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    P_Ret_Msg := ' Loading the file ';
    Std_Lib.Load_File(l_File_Path,
                      P_File_Name,
                      l_Line_Count,
                      Tab_File_Rcd );

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' ||To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || P_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name                   : ' || P_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' Success\Reject File         : ' || P_Success_Reject_Flag);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    p_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value = P_Exch_Id
    AND    Rv_Abbreviation = 'MFSS';

    P_Ret_Msg := 'Getting the Broker Code from the Master''s .';
    SELECT MAX(Decode(Eam_Exm_Id, 'NSE', Eam_Broker_Id)),
           MAX(Decode(Eam_Exm_Id, 'BSE', Eam_Broker_Id))
    INTO   l_Nse_Broker_Cd,
           l_Bse_Broker_Cd
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Seg_Id = l_Mutual_Fund_Seg;

    FOR Line_No IN Tab_File_Rcd.FIRST .. Nvl(Tab_File_Rcd.LAST, 0)
    LOOP

      BEGIN
        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Rcd.DELETE;

        p_Ret_Msg := '5: Splitting fields in the line buffer';
        IF p_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Rcd(Line_No), '|', Tab_Split_Rcd);
        ELSIF p_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Rcd(Line_No), '|', Tab_Split_Rcd);
        END IF;

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Rcd.FIRST .. Tab_Split_Rcd.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,
                              '<' || i || '>' || ' = <' || Tab_Split_Rcd(i) || '>');
          END LOOP;
        END IF;

        IF p_Exch_Id = 'BSE' THEN

          l_Report_Date    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST);
          l_Order_No       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 1);
          l_Sett_Type      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 2);
          l_Sett_No        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 3);
          l_Order_Date     := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 4),'RRRR-MM_DD');
          l_Scheme_Code    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 5);
          l_Isin           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 6);
          l_Ordered_Amount := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 7);
          l_Ordered_Qty    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 8);
          l_Member_Id      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 9);

          l_Branch_Code     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 10);
          l_User_Id         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 11);
          l_Folio_No        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 12);
          l_Rta_Scheme_Code := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 13);
          l_Rta_Trans_No    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 14);
          l_Client_Code     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 15);

          BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, L_CLIENT_CODE)
              INTO L_CLIENT_CODE
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = L_CLIENT_CODE;
          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                L_CLIENT_CODE || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
          END;

          l_Client_Name     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 16);
          l_Beneficiary_Id  := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 17);
          l_Nav             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 18);
          l_Unit            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 19);
          l_Amt             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
          l_Valid_Flag      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
          l_Remarks         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
          l_Stt             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
          l_DPC             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);
          l_DP_Trans        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);
          l_Order_Type      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);
          l_Sub_Order_Type  := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 27);
      l_Scheme_Name     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 28);   --New file Structure BSE
          l_Exit_Load       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);
          l_Tax             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 30);


          /* Changes done 0n 17-Jul-2012 */
           IF l_Member_Id IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
           END IF;

           IF substr(l_Member_Id ,1,1) = '0' THEN
             IF  l_Member_Id <> l_Bse_Broker_Cd THEN
                 l_Member_Id :=  substr(l_Member_Id,2);
             END IF;
           END IF;

           IF Nvl(l_Member_Id,1) <> l_Bse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Id ||'> of file for the order no < '||l_Order_No||
              '> does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
           END IF;

          /* Changes done 0n 17-Jul-2012 */

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Decode( l_Sett_Type ,'L0',Msm_Bse_LO_Scheme_Code,'L1',Msm_Bse_L1_Scheme_Code, Msm_Bse_Code) = l_Scheme_Code
            AND   Msm_Status = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;

          l_Depository_Id := Substr(l_Beneficiary_Id, 1, 8);
          BEGIN
            SELECT Dpm_Dem_Id,
                   Decode(Dpm_Dem_Id,'NSDL',Substr(l_Beneficiary_Id,9,8),
                                     'CDSL',l_Beneficiary_Id)
            INTO   l_Depository_Name,
                   l_Depository_Client_Id
            FROM   Depo_Participant_Master
            WHERE  Dpm_Id = l_Depository_Id;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,' For Order No <'||l_Order_No||'>, Client <'||l_Client_Code||
                                                  '>, Scheme <'||l_Scheme_Code||'>, DP Id <'||l_Depository_Id||
                                                  '> does not exist in the system, hence skipping the record');
              RAISE Excp_Skip;
          END;

        ELSIF p_Exch_Id = 'NSE' THEN
          l_Report_Date := Tab_Split_Rcd(Tab_Split_Rcd.FIRST);

          IF UPPER(l_Report_Date) like '%DATE%' THEN
            Utl_File.Put_Line(l_Log_File_Handle,
                              'Header Record Found. hence skipping the same .');
            RAISE Excp_Skip;
          END IF;

          l_Report_Date        := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST),'DDMMYYYY');
          l_Order_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 1);
          l_Sett_Type          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 2);
          l_Sett_No            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 3);
          l_Allotment_Mode     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 4);
          l_Order_Date         := To_Date(Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 5),'DDMMYYYY');
          l_Order_Time         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 6);
          l_Scheme_Category    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 7);
          l_Amc_Code           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 8);
          l_Scheme_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 9);
          l_Rta_Code           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 10);
          l_Rta_Scheme_Code    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 11);
          l_Scheme_Symbol      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 12);
          l_Scheme_Series      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 13);
          l_Scheme_Option_Type := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 14);
          l_Isin               := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 15);
          l_Ordered_Amount     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 16);
          l_Ordered_Qty        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 17);
          l_Purchase_Type      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 18);
          l_Member_Id          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 19);
          l_Branch_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
          l_User_Id            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
          l_Folio_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
          l_Payout_Mechanism   := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
          l_Application_No     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);
          l_Client_Code        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);

          BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, L_CLIENT_CODE)
              INTO L_CLIENT_CODE
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = L_CLIENT_CODE;
          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                L_CLIENT_CODE || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
          END;

          l_Tax_Status         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);
          l_Holding_Mode       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 27);
          l_Client_Name        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 28);

          /* Changes done 0n 17-Jul-2012 */
           IF l_Member_Id IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
           END IF;

           IF substr(l_Member_Id ,1,1) = '0' THEN
             IF  l_Member_Id <> l_Nse_Broker_Cd THEN
                 l_Member_Id :=  substr(l_Member_Id,2);
             END IF;
           END IF;

           IF Nvl(l_Member_Id,1) <> l_Nse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Id ||'> of file for the order no < '||l_Order_No||
              '> does not match with the NSE member code <' ||l_Nse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
           END IF;

          /* Changes done 0n 17-Jul-2012 */
          p_Ret_Msg := 'Getting  fields values for Success reject Flag <' ||
                       p_Success_Reject_Flag || '>.';
          IF p_Success_Reject_Flag = 'REJECT' THEN
            l_Remarks := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);
          ELSIF p_Success_Reject_Flag = 'SUCCESS' THEN
            l_Bank_Name             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 29);
            l_Bank_Acc_Type         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 30);
            l_Bank_Acc_No           := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 31);
            l_Nav                   := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 32);
            l_Unit                  := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 33);
            l_Amt                   := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 34);
            l_Success_Reject_Status := 'SUCCESS';
          END IF;

          l_Valid_Flag  := l_Allotment_Mode;

          IF l_Sett_Type = 'L0' THEN
            Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type L0 Not found for exchange NSE');
            RAISE Excp_Terminate;
          END IF;

          l_Scheme_Code := l_Scheme_Symbol || l_Scheme_Series;

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Decode(l_Scheme_Category,'DBTCR',Msm_Nse_L1_Scheme_Code,'HLIQD',Msm_Nse_Lo_Scheme_Code,Msm_Nse_Code) = l_Scheme_Symbol || l_Scheme_Series
            AND   Msm_Status        = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
              WHEN No_Data_Found THEN
               RAISE Excp_Sch_Cd_Missing;
          END;

          BEGIN
            SELECT Rv_Low_Value
            INTO   l_Sett_Type
            FROM   Cg_Ref_Codes
            WHERE  Rv_Domain     = 'MF_NSE_SETTLEMENT_TYPE'
            AND    Rv_High_Value = l_Scheme_Category;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,'  Settlement Type not found for scheme Category <' || l_Scheme_Category ||'>');
              RAISE Excp_Skip;
          END;
       END IF;

        IF p_Exch_Id = 'NSE' THEN
          l_Report_Dt := To_Date(l_Report_Date, 'DD-MM-RRRR');
        ELSIF p_Exch_Id = 'BSE' THEN
          l_Report_Dt := To_Date(l_Report_Date, 'RRRR-MM-DD');
        END IF;

        BEGIN
          IF p_Exch_Id = 'BSE' THEN
            IF l_Valid_Flag = 'Y' THEN
              l_Success_Reject_Status := 'SUCCESS';
            ELSE
              l_Success_Reject_Status := 'REJECT';
            END IF;
          ELSIF p_Exch_Id = 'NSE' THEN
              l_Success_Reject_Status := P_Success_Reject_Flag;
          END IF;

          IF l_Success_Reject_Status = 'REJECT' THEN
             l_Rejection_Reason := 'CANCELLED IN LOAD REDEMPTION FILE';
          ELSE
             l_Rejection_Reason := NULL;
          END IF;

          p_Ret_Msg := 'Inserting Data for order no  <' || l_Order_No ||
                       '>, Client <' || l_Client_Code || '> , Scheme , ' ||
                       l_Scheme_Code || '> ,Sett No. < ' || l_Sett_No ||
                       '> and   order date <' || l_Order_Date || '>';

          INSERT INTO Redemption_Statement
            (Report_Date,         Order_No,               Sett_Type,               Sett_No,
             Allotment_Mode,      Order_Date,             Order_Time,              Scheme_Code,
             -----
             Scheme_Category,     Amc_Code,               Rta_Code,                Rta_Scheme_Code,
             Scheme_Symbol,       Scheme_Series,          Scheme_Option_Type,      Isin,
             ------
             Ordered_Amount,      Ordered_Qty,            Purchase_Type,           Member_Id,
             Branch_Code,         User_Id,                Folio_No,                Rta_Trans_No,
             -------
             Payout_Mechanism,    Application_No,         Client_Code,             Tax_Status,
             Holding_Mode,        Client_Name,            Beneficiary_Id,          Nav,
             ---------
             Unit,                Amt,                    Valid_Flag,              Remarks,
             Rejection_Reason,    Creat_Dt,               Creat_By,                Prg_Id,
             -------
             Exm_Id,              Security_Id,            Success_Reject_Status,   Stt,
             Settlement_Type,     Depository_Name,        Depository_Id,           Depository_Client_Id,
             DPC,                 DP_Trans,               Order_Type,              Sub_Order_Type,
       scheme_name,         Exit_load,              Tax)
          VALUES
            (l_Report_Dt,         l_Order_No,             l_Mutual_Fund_Seg,       l_Sett_No,
             l_Allotment_Mode,    l_Order_Date,           l_Order_Time,            l_Scheme_Code,
             -------
             l_Scheme_Category,   l_Amc_Code,             l_Rta_Code,              l_Rta_Scheme_Code,
             l_Scheme_Symbol,     l_Scheme_Series,        l_Scheme_Option_Type,    l_Isin,
             --------
             l_Ordered_Amount,    l_Ordered_Qty,          l_Purchase_Type,         l_Member_Id,
             l_Branch_Code,       l_User_Id,              l_Folio_No,              l_Rta_Trans_No,
             --------
             l_Payout_Mechanism,  l_Application_No,       l_Client_Code,           l_Tax_Status,
             l_Holding_Mode,      l_Client_Name,          l_Beneficiary_Id,        l_Nav,
             ---------
             l_Unit,              l_Amt,                  l_Valid_Flag,            l_Remarks,
             l_Rejection_Reason,  SYSDATE,                USER,                    l_Prg_Id,
             --------
             P_Exch_Id,           l_Security_Id,          l_Success_Reject_Status, l_Stt,
             l_Sett_Type,         l_Depository_Name,      l_Depository_Id,         l_Depository_Client_Id,
             l_DPC,               l_DP_Trans,             l_Order_Type,            l_Sub_Order_Type,
             l_scheme_name,       l_exit_load,            l_tax);

          p_Ret_Msg := 'Updating data in Trades for order no  <' ||
                       l_Order_No || '>, Client <' || l_Client_Code ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||
                       l_Sett_No || '> and   order date <' || l_Order_Date || '>';

          UPDATE Mfss_Trades Mt
          SET    Mt.Amount        = l_Amt,
                 Mt.Alloted_Nav   = l_Nav,
                 Mt.Folio_No      = l_Folio_No,
         Mt.Exit_load     = Decode(P_Exch_Id,'BSE',l_Exit_Load,0.00),
                 Mt.Stamp_Duty    = Decode(P_Exch_Id,'BSE',l_Tax,0.00),
                 Mt.Order_Status  = Decode(l_Success_Reject_Status, 'REJECT', 'CANCEL', Mt.Order_Status),
                 Mt.Order_Remark  = Decode(l_Success_Reject_Status, 'REJECT', l_Remarks, Mt.Order_Remark),
                 Mt.Reject_Reason = Decode(l_Success_Reject_Status, 'REJECT', 'CANCELLED IN LOAD REDEMPTION FILE', Mt.Reject_Reason),
                 Mt.Last_Updt_Dt  = SYSDATE,
                 Mt.Last_Updt_By  = USER,
                 Mt.Prg_Id        = l_Prg_Id
          WHERE  Order_No         = l_Order_No
          AND    Exm_Id           = p_Exch_Id
          AND    Buy_Sell_Flg     = 'R'
          AND    Security_Id      = l_Security_Id
          AND    Order_Date       = l_Order_Date;

          l_Count_Inserted := l_Count_Inserted + 1;

        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
              Utl_File.Put_Line(l_Log_File_Handle,
                                'Trade Already Exists for order no  <' ||
                                l_Order_No || '>, Client <' ||
                                l_Client_Code || '> , Scheme , ' ||
                                l_Scheme_Code || '> ,Sett No. < ' ||
                                l_Sett_No || '> Hence skipping the record.');
            END IF;
            l_Count_Skip := l_Count_Skip + 1;
        END;

        l_Count_Records := l_Count_Records + 1;
      EXCEPTION
        WHEN Excp_Sch_Cd_Missing THEN
          Utl_File.Put_Line(l_Log_File_Handle, 'Please Map Scheme Code --> '||l_Scheme_Code
                               ||' For Order No <'||l_Order_No||'>'
                               ||' For Order Date <'||l_Order_Date||'>'
                               ||' For Settlement No. <'||l_Sett_No||'>'
                               ||' For Isin <'||l_Isin||'>'
                               ||' For Folio No <'||l_Folio_No||'>'
                               ||' For Client Code <'||l_Client_Code||'>'
                               ||' For Client Name <'||l_Client_Name||'>'
                           );
          l_Count_Skipped := l_Count_Skipped + 1;
          l_Count_Records := l_Count_Records + 1;

        WHEN Excp_Skip THEN
          l_Count_Skipped := l_Count_Skipped + 1;
          l_Count_Records := l_Count_Records + 1;
        WHEN Excp_Skip_Header THEN
          NULL;
      END;
    END LOOP;

    -----Calling procedure for contractin and billing of redemption orders
    p_Ret_Msg := 'Performing Contracting and Billing for redemption orders. ';
    Pkg_Mfss_Settlement_Funds.P_Generate_Payout(p_Exch_Id,
                                                --l_Order_Date,
                                                NULL, --  p_Ent_Id,
                                                l_Ret_Val,
                                                l_Ret_Msg);

    IF l_Ret_Val = 'SUCCESS' THEN
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'C',
                              'Y',
                              l_Message);

      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                  : ' ||l_Count_Records);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted                 : ' ||l_Count_Inserted);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records already Processed        : ' ||l_Count_Skip);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                  : ' ||l_Count_Skipped);
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
      Utl_File.Fclose(l_Log_File_Handle);

      P_Ret_Val := 'SUCCESS';
      P_Ret_Msg := 'Process Completed Successfully ...';
    ELSE
      P_Ret_Msg := l_Ret_Msg;
      RAISE Excp_Terminate;
    END IF;

  EXCEPTION
    WHEN Excp_Terminate THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := ' Error Occured while :' || p_Ret_Msg;

      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);
      ROLLBACK;

    WHEN OTHERS THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := DBMS_UTILITY.format_error_backtrace||' Error Occured while :' || p_Ret_Msg ||
                   ' Error Code is :' || SQLERRM;

      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END P_Load_Redemption_File;

  PROCEDURE P_Dwnld_Securities_Obg_Rep(p_File_Name IN VARCHAR2,
                                       p_Exch_Id   IN VARCHAR2,
                                       p_Ret_Val   IN OUT VARCHAR2,
                                       p_Ret_Msg   IN OUT VARCHAR2) IS

    l_Pam_Curr_Date   DATE;
    l_File_Path       VARCHAR2(300);
    l_Log_File_Handle Utl_File.File_Type;
    l_Log_File_Name   VARCHAR2(100);
    l_Prg_Process_Id  NUMBER := 0;
    l_Line_Count      NUMBER := 0;
    Tab_File_Records Std_Lib.Tab;
    Tab_Split_Record Std_Lib.Tab;
    Line_No     NUMBER := 0;
    l_Order_Dt        VARCHAR2(30);
    l_Order_Date      DATE;
    l_Sett_Date       DATE;
    l_Stc_No          VARCHAR(30);
    l_Member_Code     VARCHAR2(10);
    l_Ent_Id          VARCHAR(30);
    l_Dp_Id           VARCHAR(30);
    l_Dp_Acc_No       VARCHAR(30);
    l_Order_No        VARCHAR(30);
    l_Buy_Sell_Flg    VARCHAR(30);
    l_Scheme_Code     VARCHAR(30);
    l_Isin            VARCHAR(30);
    l_Qty             NUMBER(15,4) := 0;
    l_Order_Status    VARCHAR(100);
    l_Remarks         VARCHAR(300);
    l_Settlement_Type VARCHAR2(5);
    l_Count_Inserted      NUMBER := 0;
    l_Count_Skip          NUMBER := 0;
    l_Count_Records       NUMBER := 0;
    l_Count_Process_Check NUMBER := 0;
    l_Nse_Broker_Cd   VARCHAR2(30);
    l_Bse_Broker_Cd   VARCHAR2(30);
    l_Mutual_Fund_Seg VARCHAR2(30);
    l_Security_Id     VARCHAR2(30);
    l_Symbol          VARCHAR2(30);
    l_Series          VARCHAR2(30);
    l_Prg_Id  VARCHAR2(30) := 'CSSBCSOBG';
    l_Message VARCHAR2(3000);
    Excp_Terminate EXCEPTION;
    Excp_Skip EXCEPTION;
    Excp_Sch_Cd_Missing EXCEPTION;
    l_Dp_Dem_Id         VARCHAR2(10);

  BEGIN
    Tab_File_Records.DELETE;
    p_Ret_Msg := ' getting current working date';

    SELECT Pam_Curr_Dt
    INTO   l_Pam_Curr_Date
    FROM   Parameter_Master;

    p_Ret_Msg := ' Getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    p_Ret_Msg := ' in housekeeping. Check if file exists in /ebos/files/upstrem or Program is running.';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Exch_Id || ',' || p_File_Name,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    p_Ret_Msg := ' Loading the file ';
    Std_Lib.Load_File(l_File_Path,
                      p_File_Name,
                      l_Line_Count,
                      Tab_File_Records);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Current Working Date    : ' ||
                      To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle,' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle,' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle,' ----------------------------------------------------------');

    p_Ret_Msg := 'Checking if the process is already run for the day';
    SELECT COUNT(*)
    INTO   l_Count_Process_Check
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = l_Prg_Id
    AND    Prg_Dt = l_Pam_Curr_Date
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Check > 0 THEN
      p_Ret_Msg := ' Securities Obligation report is already loaded for the day for exchange <' ||
                   p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;

    p_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value = p_Exch_Id
    AND    Rv_Abbreviation = 'MFSS';

    p_Ret_Msg := 'Getting the Broker Code from the Master''s for segment <' ||
                 l_Mutual_Fund_Seg || '> .';

    SELECT MAX(Decode(Eam_Exm_Id, 'NSE', Eam_Broker_Id)),
           MAX(Decode(Eam_Exm_Id, 'BSE', Eam_Broker_Id))
    INTO   l_Nse_Broker_Cd,
           l_Bse_Broker_Cd
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Seg_Id = l_Mutual_Fund_Seg;

    FOR Line_No IN Tab_File_Records.FIRST .. Nvl(Tab_File_Records.LAST, 0)
    LOOP
      BEGIN
        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Record.DELETE;
        p_Ret_Msg := '6: Splitting fields in the line buffer';

        IF p_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             '|',
                             Tab_Split_Record);
        ELSIF p_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             ',',
                             Tab_Split_Record);
        END IF;

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,
                              '<' || i || '>' || ' = <' ||
                              Tab_Split_Record(i) || '>');
          END LOOP;
        END IF;

        l_Order_Date      := NULL;
        l_Sett_Date       := NULL;
        l_Stc_No          := NULL;
        l_Member_Code     := NULL;
        l_Ent_Id          := NULL;
        l_Dp_Id           := NULL;
        l_Dp_Acc_No       := NULL;
        l_Order_No        := NULL;
        l_Buy_Sell_Flg    := NULL;
        l_Scheme_Code     := NULL;
        l_Isin            := NULL;
        l_Qty             := NULL;
        l_Order_Status    := NULL;
        l_Remarks         := NULL;
        l_Symbol          := NULL;
        l_Series          := NULL;
        l_Security_Id     := NULL;
        l_Settlement_Type := NULL;

        IF p_Exch_Id = 'BSE' THEN
          l_Order_Date      := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),'YYYY-MM-DD');
          l_Sett_Date       := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),'YYYY-MM-DD');
          l_Settlement_Type := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Stc_No          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));

          BEGIN
            SELECT Decode(Ent_Category,'NRI',Ent_id, l_Ent_Id)
              INTO l_Ent_Id
              FROM Entity_Master
             WHERE Ent_Mf_Ucc_Code = l_Ent_Id;
          EXCEPTION
            WHEN OTHERS THEN
             Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> Unable to find Client category for client <' || l_Ent_Id ||'>');
             Utl_File.Fflush(l_Log_File_Handle);
             RAISE Excp_Skip;
          END;

          l_Dp_Id           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Scheme_Code     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Isin            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Qty             := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));

           /* Changes done 0n 17-Jul-2012 */
           IF l_Member_Code IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
           END IF;

           IF substr(l_Member_Code ,1,1) = '0' THEN
             IF  l_Member_Code <> l_Bse_Broker_Cd THEN
                 l_Member_Code :=  substr(l_Member_Code,2);
             END IF;
           END IF;

           IF Nvl(l_Member_Code,1) <> l_Bse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Code ||'> of file for the order no < '||l_Order_No||
              '> does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
           END IF;

          /* Changes done 0n 17-Jul-2012 */

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Decode(l_Settlement_Type,'L0',Msm_BSe_LO_Scheme_Code,'L1',Msm_BSe_L1_Scheme_Code,Msm_Bse_Code) = l_Scheme_Code
            AND   Msm_Status = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;

         ELSIF p_Exch_Id = 'NSE' THEN
          l_Order_Dt := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

          IF l_Order_Dt = 'Order Date' THEN
            RAISE Excp_Skip; ---Header record . hence skipping the same.
          END IF;

          l_Order_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),'DD_MM-RRRR');
          l_Sett_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),'DD_MM-RRRR');
          l_Stc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));

          BEGIN
            SELECT Decode(Ent_Category,'NRI',Ent_id, l_Ent_Id)
              INTO l_Ent_Id
              FROM Entity_Master
             WHERE Ent_Mf_Ucc_Code = l_Ent_Id;
          EXCEPTION
            WHEN OTHERS THEN
             Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Order No <' ||l_Order_No || '> Unable to find Client category for client <' || l_Ent_Id ||'>');
             Utl_File.Fflush(l_Log_File_Handle);
             RAISE Excp_Skip;
          END;

          l_Dp_Id        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Symbol       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Series       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Qty          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
          l_Scheme_Code  := l_Symbol || l_Series;

           /* Changes done 0n 17-Jul-2012 */
           IF l_Member_Code IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
           END IF;

           IF substr(l_Member_Code ,1,1) = '0' THEN
             IF  l_Member_Code <> l_Nse_Broker_Cd THEN
                 l_Member_Code :=  substr(l_Member_Code,2);
             END IF;
           END IF;

           IF Nvl(l_Member_Code,1) <> l_Nse_Broker_Cd THEN
             P_Ret_Msg := 'Member Code <' || l_Member_Code ||'> of file for the order no < '||l_Order_No||
              '> does not match with the NSE member code <' ||l_Nse_Broker_Cd || '> of the broker ';
             RAISE Excp_Terminate;
           END IF;

          /* Changes done 0n 17-Jul-2012 */


           IF l_Settlement_Type = 'L0' THEN
             Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type L0 Not found for exchange NSE');
             RAISE Excp_Terminate;
           END IF;

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE  ((Msm_Nse_Code = l_Symbol || l_Series)
            OR     (Msm_Nse_LO_Scheme_Code = l_Symbol || l_Series)
            OR     (Msm_Nse_L1_Scheme_Code = l_Symbol || l_Series))
            AND   Msm_Status = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;

          SELECT MAX(Msm_Isin)
          INTO   l_Isin
          FROM   Mfd_Scheme_Master
          WHERE  Msm_Status    = 'A'
          AND    Msm_Record_Status = 'A'
          AND    Msm_Scheme_Id = l_Security_Id
          AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

       END IF;

        BEGIN
          SELECT Decode(Dpm_Dem_Id,'NSDL',l_Dp_Acc_No,
                                   'CDSL',l_Dp_Id||l_Dp_Acc_No),
                 Dpm_Dem_Id
          INTO   l_Dp_Acc_No,
                 l_Dp_Dem_Id
          FROM   Depo_Participant_Master
          WHERE  Dpm_Id = l_Dp_Id;
        EXCEPTION
          WHEN No_Data_Found THEN
            Utl_File.Put_Line(l_Log_File_Handle,'For Order No <'||l_Order_No||'>, Client <'||l_Ent_Id||
                                                '>, Scheme <'||l_Scheme_Code||'>, DP Id <'||l_Dp_Id||
                                                '> does not exist in the system, hence skipping the record');
            RAISE Excp_Skip;
        END;

        p_Ret_Msg := 'Verifying date format for order no <' || l_Order_No || '>.';
        IF l_Order_Date != l_Pam_Curr_Date THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Order Date <' || l_Order_Date ||
                            '> ,does not match with the system date  <' ||
                            l_Pam_Curr_Date || '>.');
          RAISE Excp_Terminate;
        END IF;

        BEGIN
          p_Ret_Msg := 'Inserting Trades for order no  <' || l_Order_No ||
                       '>, Client <' || l_Ent_Id || '> , Scheme , ' ||
                       l_Security_Id || '> ,Sett No. < ' || l_Stc_No ||
                       '> and   order type <' || l_Buy_Sell_Flg || '>';

          INSERT INTO Mfss_Securities_Obligation
            (Order_Date,             Sett_Date,             Order_No,
             Ent_Id,                 Exm_Id,                Stc_Type,
             Stc_No,                 Buy_Sell_Flg,          Amc_Scheme_Code,
             Isin,                   Quantity,              Member_Code,
             Dp_Id,                  Dp_Acc_No,             Creat_Dt,
             Creat_By,               Prg_Id,                Security_Id,
             Symbol,                 Series,                Settlement_Type,
             Dp_Dem_Id)
          VALUES
            (l_Order_Date,           l_Sett_Date,           l_Order_No,
             l_Ent_Id,               p_Exch_Id,             l_Mutual_Fund_Seg,
             l_Stc_No,               l_Buy_Sell_Flg,        l_Scheme_Code,
             l_Isin,                 l_Qty,                 l_Member_Code,
             l_Dp_Id,                l_Dp_Acc_No,           SYSDATE,
             USER,                   'CSSBCSOBG',           l_Security_Id,
             l_Symbol,               l_Series,              l_Settlement_Type,
             l_Dp_Dem_Id);

          l_Count_Inserted := l_Count_Inserted + 1;

        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            Utl_File.Put_Line(l_Log_File_Handle,'For Order No <'||l_Order_No||'>, Client <'||l_Ent_Id||
                                                '>, Scheme <'||l_Scheme_Code||'>, record is already loaded, hence skipping the record');
            l_Count_Skip := l_Count_Skip + 1;
            RAISE Excp_Skip;
          WHEN OTHERS THEN
            p_Ret_Msg := p_Ret_Msg || SQLERRM;
            RAISE Excp_Terminate;
        END;

        l_Count_Records := l_Count_Records + 1;
      EXCEPTION
        WHEN Excp_Sch_Cd_Missing THEN
          Utl_File.Put_Line(l_Log_File_Handle, 'Please Map Scheme Code --> '||l_Scheme_Code
                               ||' For Order No <'||l_Order_No||'>'
                               ||' For Order Date <'||l_Order_Date||'>'
                               ||' For Settlement No. <'||l_Stc_No||'>'
                               ||' For Isin <'||l_Isin||'>'
                               ||' For DP Id <'||l_Dp_Id||'>'
                               ||' For DP Acc No <'||l_Dp_Acc_No||'>');
        WHEN Excp_Skip THEN
          NULL;
      END;
    END LOOP;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,  ' No. Of Records in File                   : ' || l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle,  ' No. Of Records Inserted                  : ' || l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle,  ' No. Of Records already Processed         : ' || l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Handle,  '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,  ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN Excp_Terminate THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := Dbms_Utility.format_error_backtrace|| '**Error Occured while :' || p_Ret_Msg;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := Dbms_Utility.format_error_backtrace||' Error Occured while :' || p_Ret_Msg ||'**Error Code is :' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END P_Dwnld_Securities_Obg_Rep;

  PROCEDURE P_Gen_Sec_Confirmation_Stmt(p_Exch_Id IN VARCHAR2,
                                        p_Gen_Dt  IN DATE,
                                        p_Ret_Val IN OUT VARCHAR2,
                                        p_Ret_Msg IN OUT VARCHAR2) IS
    l_Pam_Curr_Date         DATE;
    l_Pam_Last_Date         DATE;
    l_Log_File_Handle       Utl_File.File_Type;
    l_Log_File_Name         VARCHAR2(100);
    l_Prg_Process_Id        NUMBER := 0;
    l_Count_Process_Obg_Rep NUMBER := 0;
    l_Batch_No              VARCHAR2(30);
    l_Datafile_Handle       Utl_File.File_Type;
    l_Datafile_Name         VARCHAR2(300);
    l_Datafile_Path         VARCHAR2(300);
    l_Count                 NUMBER := 0;
    l_Prg_Id                VARCHAR2(30) := 'CSSBCSCNS';
    l_Message               VARCHAR2(3000);

    CURSOR c_Sec_Stmt IS
      SELECT t.Order_Date Order_Date,
             Decode(o.Exm_Id,'BSE',To_Char(t.Order_Date, 'RRRR-MM-DD'),
                             'NSE',To_Char(t.Order_Date, 'DD-MON-RRRR')) Order_Dt,
             Decode(o.Exm_Id,'BSE',To_Char(o.Sett_Date, 'RRRR-MM-DD'),
                             'NSE',To_Char(o.Sett_Date, 'DD-MON-RRRR')) Sett_Dt,
             Decode(o.Exm_Id, 'BSE', 'MF', 'NSE', 'U') Sett_Type,
             o.Stc_No Sett_No,
             o.Member_Code Member_Cd,
             decode(a.ent_category, 'NRI',a.ent_mf_ucc_code, o.Ent_Id) Client_Cd,
             o.Dp_Id Dp_Id,
             Decode(Length(o.Dp_Acc_No),16,Substr(o.Dp_Acc_No,9),o.Dp_Acc_No) Dp_Acc_No,
             o.Order_No Order_No,
             o.Buy_Sell_Flg Buy_Sell,
             o.Amc_Scheme_Code Scheme_Id,
             o.Symbol Symbol,
             o.Series Series,
             o.Isin Isin,
             o.Quantity Quantity,
             o.Security_Id Security_Id,
             Nvl(t.Mfss_Dp_Instruction_Flg, 'N') Status,
             Decode(t.Mfss_Dp_Instruction_Flg,'Y','Payin Done','Insufficient Qty') Remarks
      FROM   Mfss_Trades                t,
             Mfss_Securities_Obligation o,
             Entity_Master a
      WHERE  t.Order_No     = o.Order_No
      AND    o.ent_id       = a.ent_id
      AND    t.Exm_Id       = o.Exm_Id
      AND    t.Stc_No       = o.Stc_No
      AND    t.Buy_Sell_Flg = o.Buy_Sell_Flg
      AND    t.Ent_Id       = o.Ent_Id
      AND    t.Buy_Sell_Flg = 'R'
      AND    t.Confirmation_Flag = 'Y'
      AND    t.Order_Date   = o.Order_Date
      AND    t.Order_Date   = p_Gen_Dt
      AND    o.Exm_Id       = p_Exch_Id
      AND    Nvl(o.Sec_Conf_Stmt_Gen_Flg, 'N') = 'N'
      ORDER  BY t.Order_Date,
                o.Ent_Id,
                o.Security_Id;

    Excp_Terminate EXCEPTION;
    Excp_Skip EXCEPTION;

  BEGIN

    p_Ret_Msg := ' getting current working date';

    SELECT Pam_Curr_Dt,
           Pam_Last_Dt
    INTO   l_Pam_Curr_Date,
           l_Pam_Last_Date
    FROM   Parameter_Master;

    p_Ret_Msg := ' In housekeeping for process already Running ';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Exch_Id || ',' || p_Gen_Dt,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' || To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' Generation Date             : ' || p_Gen_Dt);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    p_Ret_Msg := 'Checking if the Securities obligation report is loaded for the day';

    SELECT COUNT(*)
    INTO   l_Count_Process_Obg_Rep
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = 'CSSBCSOBG'
    AND    Prg_Dt     = p_Gen_Dt
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Obg_Rep = 0 THEN
      p_Ret_Msg := ' Securities  Obligation is not loaded for the day for exchange <' || p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;

    p_Ret_Msg := 'Getting Datafile path for generating funds confirmation file .';
    SELECT Rv_High_Value
    INTO   l_Datafile_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    FOR i IN c_Sec_Stmt
    LOOP
      IF l_Count = 0 THEN
        SELECT Lpad(Mfss_Batch_Seq.NEXTVAL, 5, '0')
        INTO   l_Batch_No
        FROM   Dual;

        IF p_Exch_Id = 'BSE' THEN
          l_Datafile_Name := i.Sett_No || '_' || i.Member_Cd || '_CLIENTSECSTMT.txt';

        ELSIF p_Exch_Id = 'NSE' THEN
          l_Datafile_Name := 'M_' || i.Member_Cd || '_COBG_' || To_Char(l_Pam_Curr_Date, 'DDMMRRRR') || '_' ||
                             l_Batch_No || '.csv';
        END IF;
        p_Ret_Msg         := 'Opening File <' || l_Datafile_Name || '> to write .';
        l_Datafile_Handle := Utl_File.Fopen(l_Datafile_Path,l_Datafile_Name, 'W');

      END IF;

      IF p_Exch_Id = 'BSE' THEN
        Utl_File.Put_Line(l_Datafile_Handle,
                          i.Order_Dt || '|' || i.Sett_Dt || '|' ||
                          i.Sett_Type || '|' || i.Sett_No || '|' ||
                          i.Member_Cd || '|' || i.Client_Cd || '|' ||
                          i.Dp_Id || '|' || i.Dp_Acc_No || '|' ||
                          i.Order_No || '|' || i.Buy_Sell || '|' ||
                          i.Scheme_Id || '|' || i.Isin || '|' || i.Quantity || '|' ||
                          i.Status || '|' || i.Remarks);

        l_Count := l_Count + 1;
      ELSIF p_Exch_Id = 'NSE' THEN
        Utl_File.Put_Line(l_Datafile_Handle,
                          i.Order_Dt || ',' || i.Sett_Dt || ',' ||
                          i.Sett_Type || ',' || i.Sett_No || ',' ||
                          i.Member_Cd || ',' || i.Client_Cd || ',|' ||
                          i.Dp_Id || ',' || i.Dp_Acc_No || ',' ||
                          i.Order_No || ',' || i.Buy_Sell || ',' ||
                          i.Symbol || ',' || i.Series || ',' || i.Quantity || ',' ||
                          i.Status);

        l_Count := l_Count + 1;
      END IF;
      p_Ret_Msg := 'Updating the Mfss_Funds_Obligations for order no  <' ||
                   i.Order_No || '>, Client <' || i.Client_Cd ||
                   '> , Scheme , ' || i.Security_Id || '> ,Sett No. < ' || i.Sett_No || '> ';
      UPDATE Mfss_Securities_Obligation
      SET    Sec_Conf_Stmt_Gen_Flg = 'Y',
             Sec_Conf_Gen_File     = l_Datafile_Name,
             Batch_No              = l_Batch_No,
             Last_Updt_By          = USER,
             Last_Updt_Dt          = SYSDATE
      WHERE  Order_No       = i.Order_No
      AND    Exm_Id         = p_Exch_Id
      AND    Stc_No         = i.Sett_No
      AND    Buy_Sell_Flg   = 'R'
      AND    Ent_Id         = i.Client_Cd
      AND    Security_Id    = i.Security_Id
      AND    Order_Date     = i.Order_Date
      AND    Nvl(Sec_Conf_Stmt_Gen_Flg, 'N') = 'N';

      p_Ret_Msg := 'Updating  Mfss_Trades  for order no  <' || i.Order_No ||
                   '>, Client <' || i.Client_Cd || '> , Scheme , ' ||
                   i.Security_Id || '> ,Sett No. < ' || i.Sett_No || '> ';

      UPDATE Mfss_Trades
      SET    Sec_Conf_Stmt_Gen_Flg = 'Y',
             Last_Updt_By          = USER,
             Last_Updt_Dt          = SYSDATE
      WHERE  Order_No     = i.Order_No
      AND    Exm_Id       = p_Exch_Id
      AND    Stc_No       = i.Sett_No
      AND    Buy_Sell_Flg = 'R'
      AND    Ent_Id       = i.Client_Cd
      AND    Security_Id  = i.Security_Id
      AND    Order_Date   = i.Order_Date
      AND    Nvl(Sec_Conf_Stmt_Gen_Flg, 'N') = 'N';

    END LOOP;

    IF l_Count > 0 THEN
      UPDATE Program_Status
      SET    Prg_Output_File = l_Datafile_Path || '/' || l_Datafile_Name
      WHERE  Prg_Process_Id  = l_Prg_Process_Id
      AND    Prg_Cmp_Id      = l_Prg_Id
      AND    Prg_Dt          = l_Pam_Curr_Date;
    END IF;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    IF l_Datafile_Name IS NOT NULL THEN
      Utl_File.Put_Line(l_Log_File_Handle, ' File Generated                           : ' || l_Datafile_Path || '/' || l_Datafile_Name);
    END IF;
    Utl_File.Put_Line(l_Log_File_Handle,   ' No. Of Records in File                   : ' ||    l_Count);
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);
    Utl_File.Fclose(l_Datafile_Handle);

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN Excp_Terminate THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||  '**Error Occured while :' || p_Ret_Msg;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      IF Utl_File.Is_Open(l_Datafile_Handle) THEN
        Utl_File.Fclose(l_Datafile_Handle);
      END IF;
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||
                   '**Error Occured while :' || p_Ret_Msg ||
                   '**Error Code is :' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      IF Utl_File.Is_Open(l_Datafile_Handle) THEN
        Utl_File.Fclose(l_Datafile_Handle);
      END IF;
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

      IF Utl_File.Is_Open(l_Datafile_Handle) THEN
        Utl_File.Fclose(l_Datafile_Handle);
      END IF;
  END P_Gen_Sec_Confirmation_Stmt;

  PROCEDURE P_Dwnld_Sec_Conf_Stmt(p_File_Name IN VARCHAR2,
                                  p_Exch_Id   IN VARCHAR2,
                                  p_Ret_Val   IN OUT VARCHAR2,
                                  p_Ret_Msg   IN OUT VARCHAR2) IS
    l_Pam_Curr_Date           DATE;
    l_File_Path               VARCHAR2(300);
    l_Log_File_Handle         Utl_File.File_Type;
    l_Log_File_Name           VARCHAR2(100);
    l_Prg_Process_Id          NUMBER := 0;
    l_Line_Count              NUMBER := 0;
    Tab_File_Records          Std_Lib.Tab;
    Tab_Split_Record          Std_Lib.Tab;
    Line_No                   NUMBER := 0;
    l_Order_Dt                VARCHAR2(30);
    l_Order_Date              DATE;
    l_Sett_Date               DATE;
    l_Stc_No                  VARCHAR(30);
    l_Member_Code             VARCHAR2(10);
    l_Ent_Id                  VARCHAR(30);
    l_Dp_Id                   VARCHAR(30);
    l_Dp_Acc_No               VARCHAR(30);
    l_Order_No                VARCHAR(30);
    l_Buy_Sell_Flg            VARCHAR(30);
    l_Scheme_Code             VARCHAR(30);
    l_Isin                    VARCHAR(30);
    l_Qty                     NUMBER(15,4) := 0;
    l_Order_Status            VARCHAR(100);
    l_Remarks                 VARCHAR(300);
    l_Count_Inserted          NUMBER := 0;
    l_Count_Update            NUMBER := 0;
    l_Count_Records           NUMBER := 0;
    l_Count_Process_Check     NUMBER := 0;
    l_Nse_Broker_Cd           VARCHAR2(30);
    l_Bse_Broker_Cd           VARCHAR2(30);
    l_Mutual_Fund_Seg         VARCHAR2(30);
    l_Security_Id             VARCHAR2(30);
    l_Count_Bill_Reversed     NUMBER := 0;
    l_Symbol                  VARCHAR2(30);
    l_Series                  VARCHAR2(30);
    l_Message                 VARCHAR2(3000);
    l_Prg_Id                  VARCHAR2(30) := 'CSSBSCONF';
    Excp_Terminate            EXCEPTION;
    Excp_Skip                 EXCEPTION;
    Excp_Sch_Cd_Missing       EXCEPTION;

  BEGIN
    Tab_File_Records.DELETE;

    p_Ret_Msg := ' in housekeeping. Check if file exists in /ebos/files/upstrem or Program is running.';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Exch_Id || ',' || p_File_Name,
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    p_Ret_Msg := ' getting current working date';
    l_Pam_Curr_Date := Std_Lib.l_Pam_Curr_Date;

    p_Ret_Msg := ' getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    p_Ret_Msg := ' Loading the file ';
    Std_Lib.Load_File(l_File_Path,
                      p_File_Name,
                      l_Line_Count,
                      Tab_File_Records);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,' Current Working Date    : ' ||To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle,' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    p_Ret_Msg := 'Checking if the process is already run for the day';
    SELECT COUNT(*)
    INTO   l_Count_Process_Check
    FROM   Program_Status
    WHERE  Prg_Cmp_Id   = l_Prg_Id
    AND    Prg_Dt       = l_Pam_Curr_Date
    AND    Prg_Status   = 'C'
    AND    Prg_Exm_Id   = p_Exch_Id;

    IF l_Count_Process_Check > 0 THEN
      p_Ret_Msg := ' Securities confirmation report is already loaded for the day for exchange <' ||       p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;

    p_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain       = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value    = p_Exch_Id
    AND    Rv_Abbreviation = 'MFSS';

    p_Ret_Msg := 'Getting the Broker Code from the Master''s .';
    SELECT MAX(Decode(Eam_Exm_Id, 'NSE', Eam_Broker_Id)),
           MAX(Decode(Eam_Exm_Id, 'BSE', Eam_Broker_Id))
    INTO   l_Nse_Broker_Cd,
           l_Bse_Broker_Cd
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Seg_Id = l_Mutual_Fund_Seg;

    FOR Line_No IN Tab_File_Records.FIRST .. Nvl(Tab_File_Records.LAST, 0)
    LOOP
      BEGIN
        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle, 'Splitting line no <' || Line_No || '>');
        END IF;
        Tab_Split_Record.DELETE;

        p_Ret_Msg := '7: Splitting fields in the line buffer';
        IF p_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No), '|', Tab_Split_Record);
        ELSIF p_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No), ',', Tab_Split_Record);
        END IF;

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle, '<' || i || '>' || ' = <' || Tab_Split_Record(i) || '>');
          END LOOP;
        END IF;

        l_Order_Dt     := NULL;
        l_Order_Date   := NULL;
        l_Sett_Date    := NULL;
        l_Stc_No       := NULL;
        l_Member_Code  := NULL;
        l_Ent_Id       := NULL;
        l_Dp_Id        := NULL;
        l_Dp_Acc_No    := NULL;
        l_Order_No     := NULL;
        l_Buy_Sell_Flg := NULL;
        l_Scheme_Code  := NULL;
        l_Isin         := NULL;
        l_Qty          := NULL;
        l_Order_Status := NULL;
        l_Remarks      := NULL;

        IF p_Exch_Id = 'BSE' THEN

          l_Order_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),'YYYY-MM-DD');
          l_Sett_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),'YYYY-MM-DD');
          l_Stc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));

          BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, L_ENT_ID)
              INTO L_ENT_ID
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = L_ENT_ID;
          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                L_ENT_ID || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
          END;

          l_Dp_Id        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Scheme_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Isin         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Qty          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
          l_Order_Status := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Remarks      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));

           /* Changes done 0n 17-Jul-2012 */
          IF l_Member_Code IS NULL THEN
              P_Ret_Msg := 'Member Code in file is blank for the order no < '||l_Order_No||'>.';
              RAISE Excp_Terminate;
          END IF;

          IF substr(l_Member_Code ,1,1) = '0' THEN
            IF  l_Member_Code <> l_Bse_Broker_Cd THEN
                l_Member_Code :=  substr(l_Member_Code,2);
            END IF;
          END IF;

          IF Nvl(l_Member_Code,1) <> l_Bse_Broker_Cd THEN
            P_Ret_Msg := 'Member Code <' || l_Member_Code ||'> of file for the order no < '||l_Order_No||
             '> does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;
         /* Changes done 0n 17-Jul-2012 */
          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Msm_Bse_Code      = l_Scheme_Code
            AND   Msm_Status        = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
            WHEN No_Data_Found THEN
              BEGIN
                SELECT Msm_Scheme_Id
                INTO  l_Security_Id
                FROM  Mfd_Scheme_Master
                WHERE Msm_Bse_LO_Scheme_Code = l_Scheme_Code
                AND   Msm_Status        = 'A'
                AND   Msm_Record_Status = 'A'
                AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
              EXCEPTION
                WHEN No_Data_Found THEN
                  BEGIN
                    SELECT Msm_Scheme_Id
                    INTO  l_Security_Id
                    FROM  Mfd_Scheme_Master
                    WHERE Msm_Bse_L1_Scheme_Code = l_Scheme_Code
                    AND   Msm_Status        = 'A'
                    AND   Msm_Record_Status = 'A'
                    AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
                  EXCEPTION
                    WHEN No_Data_Found THEN
                      RAISE Excp_Sch_Cd_Missing;
                  END;
              END;
          END;

         ELSIF p_Exch_Id = 'NSE' THEN
          l_Stc_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

          IF l_Stc_No = 'Order Date' THEN
            RAISE Excp_Skip; ---Header record . hence skipping the same.
          END IF;

          l_Symbol    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1));
          l_Series    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Isin      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Ent_Id    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));

          BEGIN
            SELECT DECODE(ENT_CATEGORY, 'NRI', ENT_ID, L_ENT_ID)
              INTO L_ENT_ID
              FROM ENTITY_MASTER
             WHERE ENT_MF_UCC_CODE = L_ENT_ID;
          EXCEPTION
            WHEN OTHERS THEN
              UTL_FILE.PUT_LINE(L_LOG_FILE_HANDLE,
                                ' Record Skipped for Order No <' || L_ORDER_NO ||
                                '> Unable to find Client category for client <' ||
                                L_ENT_ID || '>');
              UTL_FILE.FFLUSH(L_LOG_FILE_HANDLE);
              RAISE EXCP_SKIP;
          END;

          l_Qty       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Dp_Id     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));

          l_Scheme_Code  := l_Symbol || l_Series;

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE  ((Msm_Nse_Code = l_Symbol || l_Series)
            OR     (Msm_Nse_LO_Scheme_Code = l_Symbol || l_Series)
            OR     (Msm_Nse_L1_Scheme_Code = l_Symbol || l_Series))
            AND   Msm_Status = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;
          l_Buy_Sell_Flg := 'R';
        END IF;

        BEGIN
          SELECT Decode(Dpm_Dem_Id,'NSDL',l_Dp_Acc_No,
                                   'CDSL',l_Dp_Id||l_Dp_Acc_No)
          INTO   l_Dp_Acc_No
          FROM   Depo_Participant_Master
          WHERE  Dpm_Id = l_Dp_Id;
        EXCEPTION
          WHEN No_Data_Found THEN
            Utl_File.Put_Line(l_Log_File_Handle,'For Order No <'||l_Order_No||'>,
                                                 Client <'||l_Ent_Id||'>,
                                                 Scheme <'||l_Scheme_Code||'>,
                                                 DP Id <'||l_Dp_Id||'>
                                                 does not exist in the system, hence skipping the record');
            RAISE Excp_Skip;
        END;

        BEGIN
          p_Ret_Msg := 'Updating Confirmation record   for order no  <' ||
                       l_Order_No || '>, Client <' || l_Ent_Id ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||
                       l_Stc_No || '> and   order type <' || l_Buy_Sell_Flg ||
                       '>.Hence Skipping the record.';

          UPDATE Mfss_Securities_Obligation
          SET    Order_Status           = l_Order_Status,
                 Order_Remark           = l_Remarks,
                 Sec_Conf_Resp_File     = p_File_Name,
                 Sec_Conf_Stmt_Resp_Flg = 'Y',
                 Last_Updt_By           = USER,
                 Last_Updt_Dt           = SYSDATE
          WHERE  Order_No        = l_Order_No
          AND    Buy_Sell_Flg    = l_Buy_Sell_Flg
          AND    Security_Id     = l_Security_Id
          AND    Ent_Id          = l_Ent_Id
          AND    Exm_Id          = p_Exch_Id
          AND    Order_Date      = l_Order_Date
          AND    Stc_No          = l_Stc_No
          AND    Nvl(Sec_Conf_Stmt_Resp_Flg, 'N') = 'N';

          IF SQL%ROWCOUNT = 0 THEN
            p_Ret_Msg := 'Record not found in Mfss_Funds_Obligation. Hence Inserting Trades for order no  <' ||
                         l_Order_No || '>, Client <' || l_Ent_Id ||'> , Scheme , ' || l_Scheme_Code ||
                         '> ,Sett No. < ' || l_Stc_No ||'> and   order type <' || l_Buy_Sell_Flg || '>';

            INSERT INTO Mfss_Securities_Obligation
              (Order_Date,         Sett_Date,             Order_No,
               Ent_Id,             Exm_Id,                Stc_Type,
               Stc_No,             Buy_Sell_Flg,          Amc_Scheme_Code,
               Isin,               Quantity,              Member_Code,
               Dp_Id,              Dp_Acc_No,             Order_Status,
               Order_Remark,       Creat_Dt,              Creat_By,
               Prg_Id,             Security_Id,           Sec_Conf_Resp_File,
               Sec_Conf_Stmt_Resp_Flg)
            VALUES
              (l_Order_Date,       l_Sett_Date,           l_Order_No,
               l_Ent_Id,           p_Exch_Id,             l_Mutual_Fund_Seg,
               l_Stc_No,           l_Buy_Sell_Flg,        l_Scheme_Code,
               l_Isin,             l_Qty,                 l_Member_Code,
               l_Dp_Id,            l_Dp_Acc_No,           l_Order_Status,
               l_Remarks,          SYSDATE,               USER,
               'CSSBFCONF',        l_Security_Id,         p_File_Name,
               'Y');

            l_Count_Inserted := l_Count_Inserted + 1;
          ELSE
            l_Count_Update   := l_Count_Update + 1;
          END IF;

          UPDATE Mfss_Trades
          SET    Sec_Conf_Stmt_Resp_Flg = 'Y',
                 Last_Updt_By           = USER,
                 Last_Updt_Dt           = SYSDATE
          WHERE  Order_No        = l_Order_No
          AND    Buy_Sell_Flg    = l_Buy_Sell_Flg
          AND    Security_Id     = l_Security_Id
          AND    Ent_Id          = l_Ent_Id
          AND    Exm_Id          = p_Exch_Id
          AND    Order_Date      = l_Order_Date
          AND    Stc_No          = l_Stc_No
          AND    Nvl(Sec_Conf_Stmt_Resp_Flg, 'N') = 'N';

        EXCEPTION
          WHEN OTHERS THEN
            p_Ret_Msg := p_Ret_Msg || SQLERRM;
            RAISE Excp_Terminate;
        END;

        l_Count_Records := l_Count_Records + 1;

      EXCEPTION
        WHEN Excp_Sch_Cd_Missing THEN
          Utl_File.Put_Line(l_Log_File_Handle, 'Please Map Scheme Code --> '||l_Scheme_Code
                               ||' For Order No <'||l_Order_No||'>' ||' For Order Date <'||l_Order_Date||'>'
                               ||' For Settlement No. <'||l_Stc_No||'>'||' For Isin <'||l_Isin||'>'
                               ||' For DP Id <'||l_Dp_Id||'>' ||' For DP Acc No <'||l_Dp_Acc_No||'>'
                           );
        WHEN Excp_Skip THEN
          NULL;
      END;

    END LOOP;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                  : ' ||  l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted                 : ' ||  l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated                  : ' ||  l_Count_Update);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. of Bills Reversed                   : ' ||  l_Count_Bill_Reversed);
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);
    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN Excp_Terminate THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := ' Error Occured while :' || p_Ret_Msg;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := ' Error Occured while :' || p_Ret_Msg ||
                   ' Error Code is :' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END p_Dwnld_Sec_Conf_Stmt;

  PROCEDURE p_Gen_Mfss_Order_Comfirm_Note(P_Entity_Id  IN VARCHAR2,
                                          P_Exch_Id    IN VARCHAR2,
                                          P_Order_Date IN DATE,
                                          P_Print_Flag  IN  VARCHAR2,
                                          P_Rep_Gen_Seq_Print OUT Std_Lib.Tab,
                                          P_Ret_Val    IN OUT VARCHAR2,
                                          P_Ret_Msg    IN OUT VARCHAR2)
  AS

    l_File_Name             VARCHAR2(1000);
    g_Html                  VARCHAR2(4000);
    g_Html2                 VARCHAR2(4000);
    g_Html3                 VARCHAR2(4000);
    g_Html4                 VARCHAR2(4000);
    g_Html5                 VARCHAR2(4000);
    l_Path                  VARCHAR2(400);
    l_Log_File_Ptr          Utl_File.File_Type;
    l_File_Ptr              Utl_File.File_Type;
    l_File_Ptr_Lookup       Utl_File.File_Type;
    l_Lookup_File_Name      VARCHAR2(1000);
    l_Log_File_Name         VARCHAR2(1000);
    Comp_Desc               VARCHAR2(400);
    Comp_Add                VARCHAR2(400);
    Deal_Add                VARCHAR2(400);
    Cnt_Dtls                VARCHAR2(400);
    Additional_Dtls         VARCHAR2(400);
    l_Start_Time            DATE;
    l_End_Time              DATE;
    l_Pam_Curr_Dt           DATE;
    l_Prg_Id                VARCHAR2(50) := 'CSSWBMFOCN';
    l_Ent_Id                VARCHAR2(100);
    l_Last_Ent_Id           VARCHAR2(100);
    l_Rep_Gen_Seq           NUMBER;
    l_Mf_Order_Cnfm_Path    VARCHAR2(50);
    l_Server_Cmd            VARCHAR2(5000);
    l_Fold_Name             VARCHAR2(5000);
    l_Folder_Seq            NUMBER;
    l_Count                 NUMBER;
    l_Process_Id            NUMBER;
    l_Lookup_File_Path      VARCHAR2(1000);
    o_Err                   VARCHAR2(4000);
    l_Web_Seq_No            NUMBER := 0;
    l_Ent_Name              VARCHAR2(2000);
    l_Client_Address        VARCHAR2(4000);
    l_Ent_Exch_Client_Id    VARCHAR2(2000);
    l_Count_Mfocn           NUMBER(5) := 0;
    l_Order_Date            DATE;
    l_Time_Stamp            VARCHAR2(2000);
    l_Order_No              NUMBER(20);
    l_Status                VARCHAR2(50);
    l_Sett_No               VARCHAR2(10);
    l_Time                  VARCHAR2(10);
    l_Msm_Amc_Code          VARCHAR2(100);
    l_Msm_Scheme_Name       VARCHAR2(200);
    l_Isin                  VARCHAR2(12);
    l_Mft_Nav               VARCHAR2(100);
    l_Quantity              VARCHAR2(100);
    l_Amount                VARCHAR2(100);
    l_Exm_Name              VARCHAR2(40);
    l_Buy_Sell_Flg          VARCHAR2(30);
    l_Buy_Sell_Desc         VARCHAR2(30);
    l_Last_Pur_Reed         VARCHAR2(30);
    l_Brokerage             VARCHAR2(100);
    l_Service_Tax           VARCHAR2(100);
    l_Edu_Cess              VARCHAR2(100);
    l_Settlement_Type       VARCHAR2(5);
    --l_High_Edu_Cess         VARCHAR2(100);
    l_Stt                   VARCHAR2(100);
    l_Total                 VARCHAR2(100);
    l_Row_Client_Count      NUMBER := 1;
    l_Header                BOOLEAN := TRUE;
    l_Net_Total             NUMBER(15,2):=0;
    l_Net_Total_Des         VARCHAR2(20000);
    Ex_Submit_Cmd           EXCEPTION;
    l_Client_Pan_No         VARCHAR2(2000);
    l_Compliance_Name       VARCHAR2(100);
    l_Compliance_Email      VARCHAR2(100);
    l_Compliance_Tel_No     VARCHAR2(100);
    l_Mfss_Authorised_Signatory   VARCHAR(1000);

    l_Rep_Gen_Seq_Print   NUMBER                       ;
    l_Count_Ledger        NUMBER := 0                  ;
    l_Gen_New_File        BOOLEAN                      ;
    l_CN_Cnt              NUMBER(2)                    ;
    l_Total_CN_In_File    NUMBER(2)                    ;
    l_Rep_Count           NUMBER := 1                  ;

    CURSOR C_Client_Order IS
        SELECT m.Ent_Id Client_Id,
               To_Char(Order_Date, 'DD/MM/YYYY') || ' ' || Order_Time Time_Stamp,
               Order_Date,
               Exm_Name,
               m.Order_No Order_No,
               Erd_Pan_No Pan_No,
               'NEW' Status,
               m.Stc_No Stc_No,
               Order_Time,
               (SELECT Mc.Amc_Name
                FROM   Mfd_Amc_Master Mc
                WHERE  Mc.Amc_Id = Msm_Amc_Id) Msm_Amc_Id,
               Msm_Scheme_Desc,
               m.Isin Isin,
               Decode(m.Settlement_Type,'T1','T+1','T2','T+2','T3','T+3','T4','T+4','T5','T+5','T6','T+6','T7','T+7','L0','T','L1','T+1',Nvl(Msm_Settlement_Type,'--')) Settlement_Type,
               m.Buy_Sell_Flg,
               Decode(m.Buy_Sell_Flg, 'P', 'Purchase', 'R', 'Redemption') Buy_Sell_Desc,
               Nvl(To_Char(m.Alloted_Nav, '99999999999999999990D99999'), '--') Mft_Nav,
               Nvl(To_Char(m.Amount, '99999999999999999990D99'), '--') Amt,
               Nvl(To_Char(m.Quantity, '99999999999999999990D999'), '--') Qty,
               Nvl(To_Char(c.Brokerage, '99999999999999999990D99'), '--') Brokerage,
               Nvl(To_Char(c.Service_Tax, '99999999999999999990D99'), '--') Service_Tax,
               Nvl(To_Char(c.Edu_Cess + c.High_Edu_Cess, '99999999999999999990D99'), '--') Edu_Tax,
              -- Nvl(To_Char(c.High_Edu_Cess, '99999999999999999990D99'), '--') Hdu_Tax,
               Nvl(To_Char(c.Security_Txn_Tax, '99999999999999999990D99'),'--') Stt,
               Nvl(To_Char(Decode(m.Buy_Sell_Flg,'P',(Nvl(m.Amount, 0) + Nvl(c.Brokerage, 0) +
                                  Nvl(c.Service_Tax, 0) + Nvl(c.Edu_Cess, 0) +
                                  Nvl(c.High_Edu_Cess, 0)),(Nvl(m.Amount, 0) -(Nvl(c.Brokerage, 0) +
                                  Nvl(c.Service_Tax, 0) + Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)))),
                                  '99999999999999999990D99'),'--') Total
        FROM   Mfss_Trades m,
               Mfss_Contract_Note c,
               Mfd_Scheme_Master s,
               Exchange_Master e,
               Entity_Registration_Details
        WHERE  m.Exm_Id          = Nvl(p_Exch_Id, m.Exm_Id)
        AND    m.Ent_Id          = Nvl(p_Entity_Id, m.Ent_Id)
        AND    Order_Date        = Nvl(p_Order_Date, Order_Date)
        AND    Trade_Status      = 'A'
        AND    m.Exm_Id          = e.Exm_Id
        AND    m.Ent_Id          = Erd_Ent_Id
        AND    m.Order_Date      = c.Transaction_Date
        AND    m.Exm_Id          = c.Exm_Id
        AND    m.Order_No        = c.Order_No
        AND    m.Security_Id     = c.Amc_Scheme_Code
        AND    m.Contract_No     = c.Cn_No
        AND    Security_Id       = s.Msm_Scheme_Id
        AND    s.Msm_Status      = 'A'
        AND    Msm_Record_Status = 'A'
        AND    s.Msm_Isin        = c.Isin
        AND    l_Pam_Curr_Dt BETWEEN s.Msm_From_Date AND Nvl(s.Msm_To_Date, l_Pam_Curr_Dt)
        ORDER  BY m.Ent_Id,m.Buy_Sell_Flg,m.Order_No,m.Isin;

    CURSOR C_Entity_Id IS
        SELECT Em.Ent_Name AS Client_Name,
               Em.Ent_Id AS Client_Id,
               (Em.Ent_Address_Line_1 || Em.Ent_Address_Line_2) AS Address1,
               (Em.Ent_Address_Line_3 || ' ' || Em.Ent_Address_Line_4) AS Address2,
               (Em.Ent_Address_Line_7 || '(' || Em.Ent_Address_Line_6 || ')') AS Address3,
               Em.Ent_Phone_No_1,
               Em.Ent_Phone_No_2,
               Ed.End_Email_Id Email,
               Ed.End_Email_Id Email_Cc,
               Em.Ent_Dob Dob,
               Em.Ent_First_Name First_Name,
               Em.Ent_Title Title,
               Em.Ent_Mobile_No Mobile,
               Erd.Erd_Pan_No Pan
        FROM   Entity_Master               Em,
               Entity_Details              Ed,
               Entity_Registration_Details Erd
        WHERE  Em.Ent_Id = Erd.Erd_Ent_Id
        AND    Em.Ent_Id = Nvl(l_Ent_Id, Em.Ent_Id)
        AND    Ed.End_Id = Em.Ent_Id
        AND    Em.Ent_Status = 'E'
  AND   Nvl(Em.Ent_Report_Mode,'E') = Decode(p_Print_Flag,'Y','P','E');

    PROCEDURE p_Fund_Order_Confirm_Info
    IS
    BEGIN
      P_Ret_Msg := ' Selecting business date.';
      SELECT Pam_Curr_Dt
      INTO   l_Pam_Curr_Dt
      FROM   Parameter_Master;

      P_Ret_Msg := ' Selecting path for storing  web mutual fund order confirmation Note';
      SELECT Decode(Rv_Meaning,'N',Rv_Low_Value,Rv_High_Value)
      INTO   l_Mf_Order_Cnfm_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain       = 'LOCAL_MAIL_YN'
      AND    Rv_Abbreviation = l_Prg_Id;

      P_Ret_Msg := ' Generating the sequence for web  mutual fund order confirmation note directory ';
      SELECT COUNT(*)
      INTO   l_Folder_Seq
      FROM   Web_Rep_Gen
      WHERE  Rg_Rep_Id = l_Prg_Id
      AND    Rg_Gen_Dt = l_Pam_Curr_Dt;

      l_Folder_Seq := l_Folder_Seq + 1;

      P_Ret_Msg := ' Selecting Folder Name.';
      SELECT To_Char(l_Pam_Curr_Dt, 'DDMONRRRR') ||'_MFE_' || l_Folder_Seq
      INTO   l_Fold_Name
      FROM   Dual;

      P_Ret_Msg          := 'Creating a directory for storing web mutual fund order confirmation note  ';
      l_Server_Cmd       := 'mkdir ' || l_Mf_Order_Cnfm_Path || '/' ||l_Fold_Name;
      l_Lookup_File_Name := 'Lookup_File_'|| l_Folder_Seq ||'.TXT';

      IF g_Count_Directory = 0 THEN

         P_Ret_Msg:=' Selecting count for listner count is <'||l_Count||'>';
         SELECT Submit_Cmd('run_comm' || ' ' || l_Server_Cmd)
         INTO   l_Count
         FROM   Dual;

         IF l_Count != 2 THEN
            RAISE Ex_Submit_Cmd;
         END IF;

      END IF;

      IF substr(l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name,-1) <> '/' THEN
        l_Path             := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name || '/';
        l_Lookup_File_Path := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name || '/';
      ELSE
        l_Path             := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name;
        l_Lookup_File_Path := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name;
      END IF;

      P_Ret_Msg := ' Selecting sequnce from Web_Rep_Gen_Seq';
      SELECT Web_Rep_Gen_Seq.NEXTVAL
      INTO   l_Web_Seq_No
      FROM   Dual;

      P_Ret_Msg := ' Inserting Folder path and details ';
      INSERT INTO Web_Rep_Gen
        (Rg_Seq,                                       Rg_File_Name,                      Rg_Status,
         Rg_Gen_Dt,                                    Rg_Act_Gen_Dt,                     Rg_Start_Time,
         -----------
         Rg_Remarks,                                   Rg_Creat_Dt,                       Rg_Creat_By,
         Rg_Rep_Id,                                    Rg_Exchange,                       Rg_Segment,
         -----------
         Rg_From_Dt,                                   Rg_To_Dt,                          Rg_From_Client,
         Rg_To_Client,                                 Rg_Type,                           Rg_Category,
         ------------
         Rg_Desc,                                      Rg_File_Path,                      Rg_Log_File_Name
         )
      VALUES
        (l_Web_Seq_No,                                 l_Fold_Name,                       'R',
         l_Pam_Curr_Dt,      l_Pam_Curr_Dt           /*P_Order_Date*/,                     SYSDATE,
         ------------
         'Generating mutual fund order confirmation note Started',SYSDATE,                USER,
         l_Prg_Id,                                     'NSE',                             'M',
         -------------
         P_Order_Date,                                 P_Order_Date,                      p_Entity_Id,
         P_Entity_Id,                                  'FOLDER',                          'MF_ORDER_CONFIRMATION',
         -------------
         'WEB MUTUAL FUND CONFIRMATION NOTE',          l_Server_Cmd,                      l_Log_File_Name
         );

      P_Ret_Msg := ' Selecting Broker related info for Main header';
      SELECT UPPER(Cp.Cpm_Desc) Company_Desc,
             Cp.Cpm_Address1 || ' ' || Cp.Cpm_Address2 || ' ' || Cp.Cpm_Address3 || ' ' || Cp.Cpm_Zip_Cd Company_Address,
             Cd.Cpd_Address1 ||' '||Cd.Cpd_Address2||' '||Cd.Cpd_Address3||' '||Cd.Cpd_Zip_Cd  Dealing_Address,
             'Tel No: ' || Nvl(Cpd_Phone_No1, Cpd_Phone_No2) ||' Fax No: ' ||Nvl(Cpd_Fax_No1, Cd.Cpd_Fax_No2)||' Email ID: <a href="mailto:'||Cpd_Email_Id||'">'||Cpd_Email_Id||'</a>' Contact_Details,
             /*'ARN: '||*/Eam_Arn_No||' '||' Service Tax No: '||Cp.Cpm_Service_Tax_No||' '||' PAN: '||Erd_Pan_No  Additional_Dtls
      INTO   Comp_Desc,
             Comp_Add,
             Deal_Add,
             Cnt_Dtls,
             Additional_Dtls
      FROM   Company_Details cd,
             Company_Master  Cp,
             Entity_Registration_Details t,
             Mfss_Exch_Admin_Master M
      WHERE  Cp.Cpm_Id      = Cd.Cpd_Id
      AND    t.Erd_Ent_Id   = Cp.Cpm_Id
      AND    Eam_Ram_Acc_No = Cp.Cpm_Id
      AND    Eam_Exm_Id     = 'BSE'; -- As Amfi Reg No is same for all Exchange

      SELECT Rv_Low_Value
      INTO   l_Mfss_Authorised_Signatory
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MFSS_AUTHORISED_SIGNATORY';

      P_Ret_Msg := ' Selecting compliance officer datils for footer';
      SELECT Cp.Cpm_Compliance_Name,
             Cp.Cpm_Compliance_Email,
             Cp.Cpm_Compliance_Tel_No
      INTO   l_Compliance_Name,
             l_Compliance_Email,
             l_Compliance_Tel_No
      FROM   Company_Master Cp ;

      P_Ret_Msg := 'Selecting Lookup File ';
      IF g_Count_Directory = 0 THEN

        l_File_Ptr_Lookup := Utl_File.Fopen(l_Path, l_Lookup_File_Name, 'w');
        Utl_File.Put_Line(l_File_Ptr_Lookup,'File Name'           ||'|:|'||
                                            'Client Id'           ||'|:|'||
                                            'Email Id1'           ||'|:|'||
                                            'Email Id2'           ||'|:|'||
                                            'DOB'                 ||'|:|'||
                                            'Customer First Name' ||'|:|'||
                                            'Customer Salutation' ||'|:|'||
                                            'Customer Name'       ||'|:|'||
                                            'Layout Type'         ||'|:|'||
                                            'Frequency'           ||'|:|'||
                                            'Start Date'          ||'|:|'||
                                            'End Date'            ||'|:|'||
                                            'Mobile No'           ||'|:|'||
                                            'PAN'                 ||'|:|'||
                                            'Contract Id'         ||'|:|'||
                                            'Subject And Content' ||'|:|'||
                                            'Reserved Field 1'    ||'|:|'||
                                            'Reserved Field 2'    ||'|:|'||
                                            'Reserved Field 3'    ||'|:|'||
                                            'Reserved Field 4');
      END IF;

      g_Count_Directory := g_Count_Directory + 1;

    END p_Fund_Order_Confirm_Info;

    PROCEDURE P_Get_Class_Html
    IS
    BEGIN
      g_Html  := '<Style Type="text/css">table.tablefont td {border-style: solid;  border-width: 1px;
                               padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                               font-size: 8pt;   text-decoration: none;
                               color: #000000;    height:25pt;}
                  </Style>';

      g_Html2 := '<Style Type="text/css">table.tablefont2 td {
                               padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                               font-size: 8pt;    text-decoration: none;
                               color: #000000; }
                  </Style>';

      g_Html3 := '<Style Type="text/css">table.tablefont3 td {border-style: solid;  border-width: 1px;
                               padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                               font-size: 8pt;    text-decoration: none;
                               color: #000000; }
                  </Style>';

      g_Html4 := '<Style type="text/css">table.tablefont4 td {
                               padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                               font-size: 10pt;    text-decoration: none;
                               color: #000000; }
                  </Style>';
      g_html5 :='<style>.break { page-break-before: always; }</style>';

    END;

    PROCEDURE P_Report_Footer(P_Ent_Id IN VARCHAR2 , P_Rep_Gen_Seq IN VARCHAR2)
    AS
    BEGIN
       P_Get_Company_Name;

       ----- Sum of Total in report--------
       Utl_File.Put_Line(l_File_Ptr,  '<TD colspan =19 width = 88%  align = right>'||'Total'||'</TD>');
       l_Net_Total_Des := To_Char(l_Net_Total,'99999999999999999990D99');
       Utl_File.Put_Line(l_File_Ptr,  '<TD colspan =1  width = 12%  align = right>'||l_Net_Total_Des||'</TD>');
       Utl_File.Put_Line(l_File_Ptr,'</Table>');


       Utl_File.Put_Line(l_File_Ptr, '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       ----------- Footer of Report----------------
       Utl_File.Put_Line(l_File_Ptr,       '<TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=19   width = 10% align=Left>Exit Load is charged for Mutual Fund Redemption for selected schemes, wherever applicable. For further details, please read the Key Information Memorandum/Factsheet of the scheme.</TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=1    width = 10% align=left>Date: </TD><TD  COLSPAN=1 width = 10% >' ||l_Pam_Curr_Dt || '</TD>');
       Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=6></TD>');
       --Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=2   width = 20% align=center>Yours faithfully,</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=1 width = 10% align=left>Place: </TD><TD COLSPAN=2 width = 10% >Mumbai</TD> ');
       Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=5></TD>');
       --Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=3   width = 30% align=center>'||Comp_Desc||'</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       /*Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=8></TD>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 20% align=center>(Authorized Signatory)</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=8></TD>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 20% align=center>'||l_Mfss_Authorised_Signatory||'</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');*/

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 10% align=Left><B>Note :<B></TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>1.This is a computer generated statement and does not require signature.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>2.This statement is prepared based on data received from AMCs (Mutual Funds) and RTAs (Registrars). '||g_Company_Title||' is not responsible for issues due to incorrect data received from its sources.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>3.If any discrepancies are observed in this email or statement, please call us on 18001030808 or write to us on <a href="mailto:helpdesk@idbidirect.in">helpdesk@idbidirect.in</a></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>4.Compliance Officer Details: Compliance Officer: '||l_Compliance_Name||' Email ID: <a href="mailto:'||l_Compliance_Email||'">'||l_Compliance_Email||'</a>, Telephone No: '||l_Compliance_Tel_No||'</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');
       Utl_File.Put_Line(l_File_Ptr,       '</TABLE>');

       l_CN_Cnt := l_CN_Cnt + 1;
       IF P_Print_Flag = 'Y' THEN
         IF l_CN_Cnt = l_Total_CN_In_File THEN
           l_CN_Cnt := 0;
           l_Gen_New_File := TRUE;
           l_Rep_Count:= l_Rep_Count + 1;
         ELSE
           l_Gen_New_File := FALSE;
         END IF;
       ELSE
         l_Gen_New_File := FALSE;
       END IF;

       IF p_Print_Flag = 'N' OR (p_Print_Flag = 'Y' AND l_Gen_New_File = TRUE) THEN
         Utl_File.Put_Line(l_File_Ptr,'</Body>');
         Utl_File.Fclose(l_File_Ptr);
       ELSE
         Utl_File.Put_Line(l_File_Ptr,'<h1 class="break">;');
         Utl_File.Put_Line(l_File_Ptr,'</h1>');
       --  Utl_File.Put_Line(l_File_Ptr,'</Body>');
       END IF;

       P_Ret_Msg := ' Updating status as success in Rep_Gen for sequence <'||P_Rep_Gen_Seq||'> and client<'||P_Ent_Id||'>';
       IF  p_Print_Flag = 'N' THEN
         UPDATE Rep_Gen
         SET    Rg_Status       = 'S',
                Rg_End_Time     = SYSDATE,
                Rg_Remarks      = 'Client Fund Order confirmation Note Generated Successfully  For:' ||P_Ent_Id,
                Rg_Last_Updt_By = USER,
                Rg_Last_Updt_Dt = SYSDATE
         WHERE  Rg_Seq          = P_Rep_Gen_Seq;
       ELSIF p_Print_Flag = 'Y' AND l_Gen_New_File = TRUE THEN
         UPDATE Rep_Gen
         SET    Rg_Status       = 'S',
                Rg_End_Time     = SYSDATE,
                Rg_Remarks      = 'Client Order confirmation Note Generated Successfully',
                Rg_Last_Updt_By = USER,
                Rg_Last_Updt_Dt = SYSDATE
         WHERE  Rg_Seq          = P_Rep_Gen_Seq;
       END IF;
    END;

    PROCEDURE P_Main_Header_Report_Name
    AS
    BEGIN
       Utl_File.Put_Line(l_File_Ptr, g_Html);
       Utl_File.Put_Line(l_File_Ptr, g_Html2);
       Utl_File.Put_Line(l_File_Ptr, g_Html5);
       Utl_File.Put_Line(l_File_Ptr, g_Html4);
       Utl_File.Put_Line(l_File_Ptr,'<Body style="background-color:F2FFF2">');
       ----  Main Header of company details------
       Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 50% class=tablefont2 colspan =5 align = center cellspacing=0> ');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD style = color:#0000A0; align = center class=tablefont2><B><font size="+2">' || Comp_Desc || '</font></B></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>Registered Office Address:'|| Comp_Add || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;> Main/Dealing Office Address:' ||Deal_Add || ' </TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>' || Cnt_Dtls || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>' || Additional_Dtls || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,    ' </TABLE>');

       Utl_File.Put_Line(l_File_Ptr,     '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       ------ Report Name-------
       Utl_File.Put_Line(l_File_Ptr,     '<TABLE width = 100% class=tablefont2 colspan = 5 align = center cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,          '<TR><TD style = color:#150517; align = center class=tablefont2><B><font>Mutual Fund Trade Confirmation Note</font></B></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,     '</TABLE>');
    END;


    PROCEDURE P_Salutation_N_Report_Header
    AS
    BEGIN
       -------- Salutation and Start line of report
       Utl_File.Put_Line(l_File_Ptr,  '<TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,       '<TR><TD>Dear Sir/Madam,</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,       '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,       '<TR><TD>I/We have executed the following Mutual Fund transactions in your account.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,  '</TABLE>');

       Utl_File.Put_Line(l_File_Ptr,        '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       ----------- Report Header ----------------
       Utl_File.Put_Line(l_File_Ptr,   '<TABLE width = 100% class=tablefont2 border=1 colspan = 19 cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,        '<TR>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 7%  align = center bgcolor ="#B80000"><B>Exchange Order No.</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 7%  align = center bgcolor ="#B80000"><B>Order Date/Time</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 3%  align = center bgcolor ="#B80000"><B>Settlement Type</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =3 width = 8%  align = center bgcolor ="#B80000"><B>AMC Name</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =4 width = 17% align = center bgcolor ="#B80000"><B>Scheme Name</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 8%  align = center bgcolor ="#B80000"><B>ISIN</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 8%  align = center bgcolor ="#B80000"><B>Transaction Type</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>NAV(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Units</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Amount(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Brokerage(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Service Tax(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Edu Tax(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>STT(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,             '<TD style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Total(Rs.)</B></TD>');
       Utl_File.Put_Line(l_File_Ptr,        '</TR>');
    END;

  BEGIN

    P_Ret_Val := 'FAIL';
    P_Ret_Msg := ' Performing Housekeeping Activities .';

    IF p_Print_Flag = 'Y' THEN
      l_Prg_id := 'CSSWBMFOCP';
      l_Gen_New_File := TRUE;
      l_CN_Cnt := 0;

      SELECT To_Number(RV_LOW_VALUE)
      INTO   l_Total_CN_In_File
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'SEC_MF_CN_COUNT';
    END IF;

    Std_Lib.p_Housekeeping(l_Prg_Id,
                           P_Exch_Id,
                           P_Order_Date || ',' || P_Exch_Id || ',' ||
                           P_Entity_Id,
                           'E',
                           l_Log_File_Ptr,
                           l_Log_File_Name,
                           l_Process_Id);

    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Working Date       :' || l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Ptr,'Exchange           :' || P_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,'Order Date         :' || P_Order_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,'Client             :' || P_Entity_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');

    P_Fund_Order_Confirm_Info;

    FOR i IN C_Client_Order
    LOOP

      l_Ent_Id          := i.Client_Id;
      l_Order_Date      := i.Order_Date;
      l_Time_Stamp      := i.Time_Stamp;
      l_Order_No        := i.Order_No;
      l_Client_Pan_No   := i.Pan_No;
      l_Status          := i.Status;
      l_Sett_No         := i.Stc_No;
      l_Time            := i.Order_Time;
      l_Msm_Amc_Code    := i.Msm_Amc_Id;
      l_Msm_Scheme_Name := i.Msm_Scheme_Desc;
      l_Isin            := i.Isin;
      l_Settlement_Type := i.Settlement_Type;
      l_Buy_Sell_Flg    := i.Buy_Sell_Flg;
      l_Buy_Sell_Desc   := i.Buy_Sell_desc;
      l_Mft_Nav         := i.Mft_Nav;
      l_Quantity        := i.Qty;
      l_Amount          := i.Amt;
      l_Exm_Name        := i.Exm_Name;
      l_Brokerage       := i.Brokerage;
      l_Service_Tax     := i.Service_Tax;
      l_Edu_Cess        := i.Edu_Tax;
      l_Stt             := i.Stt;
      l_Total           := i.Total;

      IF (l_Rep_Gen_Seq IS NOT NULL OR l_Rep_Gen_Seq_Print IS NOT NULL) AND l_Ent_Id <> l_Last_Ent_Id THEN
        IF p_Print_Flag = 'N' THEN
          P_Report_Footer(l_Last_Ent_Id,l_Rep_Gen_Seq);
        ELSIF p_Print_Flag = 'Y' THEN
          P_Report_Footer(l_Last_Ent_Id,l_Rep_Gen_Seq_Print);
        END IF;
      END IF;
      IF l_Ent_Id = l_Last_Ent_Id THEN
         l_Header  := FALSE;
      ELSE
          l_Header := TRUE;
      END IF;


      l_Row_Client_Count := 1;

      IF l_Header THEN

         P_Ret_Msg := ' Selecting client details form entity_master for client<'||l_Ent_Id||'>';
         SELECT Ent_Name,
                Ent_Exch_Client_Id,
                Ent_Address_Line_1||','||Ent_Address_Line_2||','||Ent_Address_Line_3||','||Ent_Address_Line_4||','||Ent_Address_Line_5||','||Ent_Address_Line_6||'-'||Ent_Address_Line_7
         INTO   l_Ent_Name,
                l_Ent_Exch_Client_Id,
                l_Client_Address
         FROM   Entity_Master
         WHERE  Ent_Id = l_Ent_Id;

        l_Net_Total  := 0;
        l_Count_Mfocn      := l_Count_Mfocn + 1;

        IF p_Print_Flag = 'N' THEN

          l_File_Name  := i.Client_Id || '-' ||'CLIENT_MF_ORDER_CONFIRMATION' || '-' ||
                          To_Char(Std_Lib.l_Pam_Curr_Date, 'DDMONYYYY') ||'.htm';
          l_File_Ptr   := Utl_File.Fopen(l_Path, l_File_Name, 'w');
          l_Start_Time := SYSDATE;

          SELECT To_Char(l_Pam_Curr_Dt, 'YYYYMM') ||Lpad(Rep_Gen_Seq.NEXTVAL, 8, 0)
          INTO   l_Rep_Gen_Seq
          FROM   Dual;

          INSERT INTO Rep_Gen
            (Rg_Seq,                              Rg_File_Name,                  Rg_Status,
             Rg_Act_Gen_Dt,                       Rg_Start_Time,                 Rg_Remarks,
             ------------
             Rg_Creat_Dt,                         Rg_Creat_By,                   Rg_Rep_Id,
             Rg_Exchange,                         Rg_Segment,                    Rg_Ent_Id,
             -------------
             Rg_Comm_Channel,                     Rg_End_Time,                   Rg_Gen_Dt
             )
          VALUES
            (l_Rep_Gen_Seq,                       l_File_Name,                   'R',
             l_Pam_Curr_Dt,                       l_Start_Time,                  'MF Order Confirmation Report for client' || i.Client_Id,
             --------------
             SYSDATE,                             USER,                          l_Prg_Id,
             'ALL',                               'E',                           i.Client_Id,
             --------------
             'P',                                 l_End_Time,                    l_Pam_Curr_Dt
             );
        ELSIF p_Print_Flag = 'Y' AND l_Gen_New_File =TRUE THEN
          SELECT To_Char(l_Pam_Curr_Dt,'RRRRMM')||Lpad(Rep_Gen_Seq.NEXTVAL,8,0)
          INTO   l_Rep_Gen_Seq_Print
          FROM   Dual;

          l_File_Name := 'MFSS_ORDER_CONFIRM_'||To_Char(l_Pam_Curr_Dt,'DDMONRRRR')||'_'||l_Rep_Gen_Seq_Print||'.htm';
          l_File_Ptr  := Utl_File.Fopen(l_Path, l_File_Name, 'w');

           P_Rep_Gen_Seq_Print(l_Rep_Count) :=l_Rep_Gen_Seq_Print;

            INSERT INTO Rep_Gen
            (Rg_Seq,                              Rg_File_Name,                  Rg_Status,
             Rg_Act_Gen_Dt,                       Rg_Start_Time,                 Rg_Remarks,
             ------------
             Rg_Creat_Dt,                         Rg_Creat_By,                   Rg_Rep_Id,
             Rg_Exchange,                         Rg_Segment,                    Rg_Ent_Id,
             -------------
             Rg_Comm_Channel,                     Rg_End_Time,                   Rg_Gen_Dt
             )
          VALUES
            (l_Rep_Gen_Seq_Print,                 l_Path || l_File_Name,                   'R',
             l_Pam_Curr_Dt,                       l_Start_Time,                  'MF Order Confirmation Report For Print',
             --------------
             SYSDATE,                             USER,                          l_Prg_Id,
             'ALL',                               'E',                           'ALL',
             --------------
             'P',                                 l_End_Time,                    l_Pam_Curr_Dt
             );

        END IF;
        P_Get_Class_Html;
        P_Main_Header_Report_Name;
        ----- Field after Report Name ---------
        Utl_File.Put_Line(l_File_Ptr,     '<BR></BR>');
        Utl_File.Put_Line(l_File_Ptr,     '<TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
        Utl_File.Put_Line(l_File_Ptr,        '<TR>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=1 width = 20% align=left>Trading & Unique Client Code :</TD><TD COLSPAN=12  width = 10% align =left>' ||l_Ent_Exch_Client_Id||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD Align=left colspan=74>;</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=12   width = 10% align=left>Internal Client Code :</TD><TD COLSPAN=12   width = 10% align =left>' ||i.Client_Id ||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,        '</TR>');

        Utl_File.Put_Line(l_File_Ptr,        '<TR>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=1 width = 15% align=left>Name:</TD><TD  COLSPAN=32 width = 10% >' ||l_Ent_Name||'</TD> ');
        Utl_File.Put_Line(l_File_Ptr,             '<TD Align=left colspan=54>;</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=12   width = 10% align=left>Trade Date:</TD><TD COLSPAN=12   width = 10% align =left>' ||P_Order_Date ||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,        '</TR>');

        Utl_File.Put_Line(l_File_Ptr,        '<TR>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=1 width = 15% align=left valign=top>Address :</TD><TD  COLSPAN=12 width = 25% valign=top>' ||l_Client_Address ||'</TD> ');
        Utl_File.Put_Line(l_File_Ptr,             '<TD Align=left colspan=74>;</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=12   width = 10% align=left valign=top>Sett No:</TD><TD COLSPAN=12   width = 10% align =left valign=top>' ||l_Sett_No ||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,        '</TR>');

        Utl_File.Put_Line(l_File_Ptr,        '<TR>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=1 width = 15% align=left>Exchange : </TD><TD  COLSPAN=12 width = 20% >' ||l_Exm_Name||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD Align=left colspan=74>;</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=12 width = 10%  align=left>;</TD><TD COLSPAN=12 width = 10% align=left>' ||';' ||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,        '</TR>');

        Utl_File.Put_Line(l_File_Ptr,        '<TR>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=1 width = 15% align=left>PAN:</TD><TD COLSPAN=12 width = 10% >' ||l_Client_Pan_No||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,             '<Td Align=left colspan=74>;</Td>');
        Utl_File.Put_Line(l_File_Ptr,             '<TD COLSPAN=12 width = 10%  align=left>;</TD><TD COLSPAN=12 width = 10% align=left>'||';'||'</TD>');
        Utl_File.Put_Line(l_File_Ptr,        '</TR>');
        Utl_File.Put_Line(l_File_Ptr,     '</TABLE>');
        Utl_File.Put_Line(l_File_Ptr, '<BR></BR>');
        ------------ End of Field after Report Name ----------------
        P_Salutation_N_Report_Header;
        ----- Lookup file for client details--------------------
        FOR j IN C_Entity_Id
        LOOP

          Utl_File.Put_Line(l_File_Ptr_Lookup,l_File_Name                  ||'|:|'||
                                              j.Client_Id                  ||'|:|'||
                                              j.Email                      ||'|:|'||
                                              j.Email_Cc                   ||'|:|'||
                                              j.Dob                        ||'|:|'||
                                              j.First_Name                 ||'|:|'||
                                              j.Title                      ||'|:|'||
                                              j.Client_Name                ||'|:|'||
                                              'MFD_ECN'                    ||'|:|'||
                                              'Daily'                      ||'|:|'||
                                              p_Order_Date                 ||'|:|'||
                                              p_Order_Date                 ||'|:|'||
                                              j.Mobile                     ||'|:|'||
                                              j.Pan                        ||'|:|'||
                                              ' '                          ||'|:|'||
                                              ' '                          ||'|:|'||
                                              ' '                          ||'|:|'||
                                              ' '                          ||'|:|'||
                                              ' '                          ||'|:|'||
                                              ' ');
        END LOOP;
      END IF;

      IF l_Buy_Sell_Flg='P' AND l_Last_Pur_Reed IS NULL THEN
         l_Net_Total := 0;
      ELSIF l_Buy_Sell_Flg='R' AND l_Last_Pur_Reed ='P' THEN
         Utl_File.Put_Line(l_File_Ptr, '<TD colspan =19 width = 88%  align = right>'||'Total'||'</TD>');
         l_Net_Total_Des := To_Char(l_Net_Total,'99999999999999999990D99');
         Utl_File.Put_Line(l_File_Ptr,  '<TD colspan =1 width = 12%  align = right>' ||l_Net_Total_Des||'</TD>');
         l_Net_Total := 0;
      END IF;

      l_Net_Total := l_Net_Total + To_Number(l_Total);

      ---------------- Populating report data------------------------
      Utl_File.Put_Line(l_File_Ptr, '<TR>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 7%  align = center>' ||l_Order_No ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 7%  align = center>' ||l_Time_Stamp ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 3%  align = center>' ||l_Settlement_Type ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =3 width = 8% align = center>' ||l_Msm_Amc_Code ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =4 width = 17% align = center>' ||l_Msm_Scheme_Name ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 8%  align = center>' ||l_Isin ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 8%  align = center>' ||l_Buy_Sell_Desc ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Mft_Nav ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Quantity ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Amount ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Brokerage ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Service_Tax ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Edu_Cess ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Stt ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr,      '<TD colspan =1 width = 5%  align = right>'  ||l_Total ||'</TD>');
      Utl_File.Put_Line(l_File_Ptr, '</TR>');

      l_Header := FALSE;
      l_Last_Ent_Id       :=  l_Ent_Id;
      l_Last_Pur_Reed     :=  l_Buy_Sell_Flg;

    END LOOP;

    IF l_Rep_Gen_Seq IS NOT NULL THEN
       P_Report_Footer(l_Ent_Id,l_Rep_Gen_Seq);
    ELSIF l_Rep_Gen_Seq_Print IS NOT NULL THEN
       P_Report_Footer(l_Ent_Id,l_Rep_Gen_Seq_Print);
    END IF;

    Utl_File.Fclose(l_File_Ptr_Lookup);

    P_Ret_Msg := ' Updating status as success in Web_Rep_Gen for sequence <'||l_Web_Seq_No||'> and date<'||l_Pam_Curr_Dt||'>';
    UPDATE Web_Rep_Gen
    SET    Rg_Status       = 'S',
           Rg_Last_Updt_Dt = SYSDATE,
           Rg_Last_Updt_By = USER,
           Rg_End_Time     = SYSDATE,
           Rg_Remarks      = 'Client Mutual Fund Order Confirmation  Report Generated Successfully  For:' ||l_Count_Mfocn
    WHERE  Rg_Seq          = l_Web_Seq_No
    AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

    P_Ret_Msg := ' Updating look up file name and path in Program status for Program id <'||l_Prg_Id||'><and Date<'||l_Pam_Curr_Dt||'>';
    UPDATE Program_Status
    SET    Prg_Status_File  = l_Lookup_File_Path,
           Prg_Output_File  = l_Lookup_File_Name,
           Prg_End_Time     = SYSDATE,
           Prg_Last_Updt_By = USER
    WHERE  Prg_Cmp_Id       = l_Prg_Id
    AND    Prg_Process_Id   = l_Process_Id
    AND    Prg_Dt           = l_Pam_Curr_Dt;

    g_Count_Directory := 0;
    P_Ret_Val         := 'SUCCESS';
    P_Ret_Msg         := 'Process Completed Successfully .';

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Dt,
                            l_Process_Id,
                            'C',
                            'Y',
                            o_Err);

    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation     :');
    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' No. of Client Order Confirmation Report Generated     :  ' ||l_Count_Mfocn);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,'Process Completed Successfully at <' ||To_Char(SYSDATE, 'DD-MON-YYYY:HH:MI:SS AM') || '>');
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN Ex_Submit_Cmd THEN
      ROLLBACK;
      P_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||'**Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation Failed :-');
      Utl_File.Put_Line(l_Log_File_Ptr,' Error Message :- ' ||P_Ret_Msg);

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Err);

      Utl_File.Fclose(l_Log_File_Ptr);
    WHEN OTHERS THEN
      ROLLBACK;
      P_Ret_Val := 'FAIL';
      P_Ret_Msg := dbms_utility.format_error_backtrace||'**Error While ' || p_Ret_Msg || SQLERRM || ':<' ||
                   l_File_Name || '>' || ':<' || l_Ent_Id || '>';

      Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation Failed :-');
      Utl_File.Put_Line(l_Log_File_Ptr,' Error Message :- ' || P_Ret_Msg);


      UPDATE Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = P_Ret_Msg,
             Rg_Last_Updt_By = USER,
             Rg_Last_Updt_Dt = SYSDATE
      WHERE  Rg_Seq          = l_Rep_Gen_Seq;


      UPDATE Web_Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_Last_Updt_Dt = SYSDATE,
             Rg_Last_Updt_By = USER,
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = 'Web Client Mutual Fund Order Confirmation Note Generation Failed:' ||l_Count_Mfocn || P_Ret_Msg
      WHERE  Rg_Seq          = l_Web_Seq_No
      AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;


      UPDATE Program_Status
      SET    Prg_Status_File  = l_Lookup_File_Path,
             Prg_Output_File  = l_Lookup_File_Name,
             Prg_End_Time     = SYSDATE,
             Prg_Last_Updt_By = USER
      WHERE  Prg_Cmp_Id       = l_Prg_Id
      AND    Prg_Process_Id   = l_Process_Id
      AND    Prg_Dt           = l_Pam_Curr_Dt;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Err);

      Utl_File.Fclose(l_File_Ptr);
      Utl_File.Fclose(l_File_Ptr_Lookup);
      Utl_File.Fclose(l_Log_File_Ptr);

  END P_Gen_Mfss_Order_Comfirm_Note;

  PROCEDURE P_Gen_Mfe_Order_Confirm_Note (p_From_Date     IN  DATE,
                                          p_To_Date       IN  DATE,
                                          p_Exch_Id       IN  VARCHAR2,
                                          p_From_Ent_Id   IN  VARCHAR2,
                                          p_To_Ent_Id     IN  VARCHAR2,
                                          P_Bounced_Flag  IN  VARCHAR2,
                                          P_Dispatch_Mode IN  VARCHAR2,
                                          P_Print_Flag    IN  VARCHAR2,
                                          P_Rep_Seq_No    OUT NUMBER,
                                          p_Ret_Val       OUT VARCHAR2,
                                          p_Ret_Msg       OUT VARCHAR2) IS

    l_File_Name                   VARCHAR2(1000);
    g_Count_Directory             NUMBER := 0;
    g_Html                        VARCHAR2(4000);
    g_Html2                       VARCHAR2(4000);
    g_Html3                       VARCHAR2(4000);
    g_Html4                       VARCHAR2(4000);
    l_Log_File_Ptr                Utl_File.File_Type;
    l_File_Ptr                    Utl_File.File_Type;
    l_Log_File_Name               VARCHAR2(1000);
    l_Start_Time                  DATE;
    l_End_Time                    DATE;
    l_Pam_Curr_Dt                 DATE;
    l_Prg_Id                      VARCHAR2(50);
    l_Ent_Id                      VARCHAR2(50);
  l_Net_Mf_Stamp_Duty            NUMBER(15,4);
    l_Mf_Stam_Duty                NUMBER(15,4);
    l_Last_Ent_Id                 VARCHAR2(50);
    l_Rep_Gen_Seq                 NUMBER;
    l_Mf_Order_Cnfm_Path          VARCHAR2(50);
    l_Server_Cmd                  VARCHAR2(5000);
    l_Fold_Name                   VARCHAR2(5000);
    l_Folder_Seq                  NUMBER;
    l_Process_Id                  NUMBER;
    o_Err                         VARCHAR2(4000);
    l_Web_Seq_No                  NUMBER := 0;
    l_Ent_Name                    VARCHAR2(2000);
    l_Ent_Address_Line_1          VARCHAR2(2000);
    l_Ent_Address_Line_2          VARCHAR2(2000);
    l_Ent_Address_Line_3          VARCHAR2(2000);
    l_Ent_Address_Line_4          VARCHAR2(2000);
    l_Ent_Address_Line_5          VARCHAR2(2000);
    l_Ent_Address_Line_6          VARCHAR2(2000);
    l_Ent_Address_Line_7          VARCHAR2(2000);
    l_Ent_Exch_Client_Id          VARCHAR2(2000);
    l_Count_Reports               NUMBER := 0;
    l_Order_Date                  DATE;
    l_Order_No                    NUMBER(12);
    l_Sett_No                     VARCHAR2(10);
    l_Scheme_Id                   VARCHAR2(30);
    l_Scheme_Desc                 VARCHAR2(200);
    l_Isin                        VARCHAR2(12);
    l_Ent_Email_Id                VARCHAR2(100);
    l_Buy_Units                   NUMBER(24,4);
    l_Buy_Units_Display           VARCHAR2(30);
    l_Sell_Units                  NUMBER(24,4);
    l_Sell_Units_Display          VARCHAR2(30);
    l_Buy_Nav                     NUMBER(24,4);
    l_Sell_Nav                    NUMBER(24,4);
    l_Buy_Commission              NUMBER(24,4);
    l_Sell_Commission             NUMBER(24,4);
    l_Buy_Amt                     NUMBER(24,4);
    l_Buy_Amt_Display             VARCHAR2(30);
    l_Sell_Amt                    NUMBER(24,4);
    l_Sell_Amt_Display            VARCHAR2(30);
    l_Broker_Id                   VARCHAR2(30);
    l_Ent_Phone_No                VARCHAR2(30);
    l_Erd_Pan_No                  VARCHAR2(30);
    l_Net_Buy_Amt                 NUMBER(24,4);
    l_Net_Buy_Amt_Display         VARCHAR2(30);
    l_Net_Sell_Amt                NUMBER(24,4);
    l_Net_Sell_Amt_Display        VARCHAR2(30);
    l_Order_Time                  VARCHAR2(30);
    l_Sett_Type                   VARCHAR2(30);
    l_Folio_No                    VARCHAR2(30);
    l_Submit_Cmd_Ret_Val          NUMBER;
    l_Broker_Sebi_Reg_No          VARCHAR2(30);
    l_Exm_Name                    VARCHAR2(40);
    l_Brokerage                   NUMBER(15,4);
    l_Service_Tax                 NUMBER(15,4);
    l_Security_Txn_Tax            NUMBER(15,4);
    l_Edu_Cess                    NUMBER(15,4);
    l_High_Edu_Cess               NUMBER(15,4);
    l_Total                       NUMBER(20,4);
    l_Header                      BOOLEAN := TRUE;
    l_Net_Total                   NUMBER(20,4):=0;
    l_Net_Total_Display           VARCHAR2(30);
    Ex_Submit_Cmd                 EXCEPTION;
    l_Dl_Name                     VARCHAR2(100);
    l_Dl_Address_1                VARCHAR2(1000);
    l_Dl_Address_2                VARCHAR2(1000);
    l_Dl_Phone_No                 VARCHAR2(1000);
    l_Dl_Fax_No                   VARCHAR2(1000);
    l_Cpm_Id                      VARCHAR2(30);
    l_Cpm_Desc                    VARCHAR2(100);
    l_Cpm_Address                 VARCHAR2(1000);
    l_Cpm_Email_Id                VARCHAR2(500);
    l_Cpm_Compliance_Name         VARCHAR2(200);
    l_Cpm_Compliance_Tel_No       VARCHAR2(50);
    l_Cpm_Compliance_Email        VARCHAR2(200);
    l_Broker_Pan_No               VARCHAR2(10);
    l_Eam_Arn_No                  VARCHAR2(10);
    l_Buy_Phy_Demat               VARCHAR2(15);
    l_Sell_Phy_Demat              VARCHAR2(15);
    l_Contract_No                 VARCHAR2(30);
    l_Last_Contract_No            VARCHAR2(30);
    l_Net_Service_Tax             NUMBER(15,4);
    l_Net_Security_Txn_Tax        NUMBER(15,4);

    l_Gen_New_File                BOOLEAN;
    l_CN_Cnt                      NUMBER(4);
    l_Total_CN_In_File            NUMBER(4);

    l_Line_Count                  NUMBER(4) := 0;
    l_Line_Count_1                NUMBER(4) ;
    l_Line_Count_2                NUMBER(4) ;
    l_Line_Count_break            NUMBER(4) := -1;
    l_Auth_Signatory              VARCHAR2(800)  ;
    l_Mkdir_Path                  VARCHAR2(500)  ;
    l_nse_sebi_no                 Varchar2(20);
    l_bse_sebi_no                 Varchar2(20);




    CURSOR c_Client_Order IS
      SELECT  Client_Id,
              Order_No,
              Order_Date,
              Order_Time,
              Sett_Type,
              Stc_No,
              Decode(Order_No,NULL,NULL,Scheme_Id) Scheme_Id,
              Scheme_Desc,
              Isin,
              Folio_No,
              Contract_No,
              Buy_Units,
              Buy_Phy_Demat,
              Buy_Nav,
              Buy_Commission,
              SUM(Buy_Amt) Buy_Amt,
              Sell_Units,
              Sell_Phy_Demat,
              Sell_Nav,
              Sell_Commission,
              SUM(Sell_Amt) Sell_Amt,
              Brokerage,
              Service_Tax,
              Security_Txn_Tax,
        Mf_Stamp_Duty,
              Edu_Tax,
              Hdu_Tax,
              Total
      FROM (SELECT Decode(e.ent_category,'NRI',e.ent_mf_ucc_code ,m.Ent_Id) Client_Id,
                   m.Order_No            Order_No,
                   m.Order_Date          Order_Date,
                   m.Order_Time          Order_Time,
                   m.Settlement_Type     Sett_Type,
                   m.Stc_No              Stc_No,
                   m.Security_Id         Scheme_Id,
                   s.Msm_Scheme_Desc     Scheme_Desc,
                   m.Isin                Isin,
                   m.Folio_No            Folio_No,
                   m.Contract_No         Contract_No,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Quantity),'99999999999999999990D9999'))             Buy_Units,
                   Decode(m.Buy_Sell_Flg,'P','Demat',NULL)                                                      Buy_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Alloted_Nav),'99999999999999999990D9999'))          Buy_Nav,
                   Decode(m.Buy_Sell_Flg,'P', Nvl(c.Brokerage, 0) ,NULL)                                        Buy_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',(m.Amount+ Nvl(c.Brokerage, 0))),'99999999999999999990D99'))Buy_Amt,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Quantity),'99999999999999999990D9999'))             Sell_Units,
                   Decode(m.Buy_Sell_Flg,'R','Demat',NULL)                                                      Sell_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Alloted_Nav),'99999999999999999990D9999'))          Sell_Nav,
                   Decode(m.Buy_Sell_Flg,'R',Nvl(c.Brokerage, 0) ,NULL)                                         Sell_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',-1*(Round(m.Quantity*m.Alloted_Nav,2)- Nvl(c.Brokerage,0))),'99999999999999999990D99')) Sell_Amt,
                   Nvl(c.Brokerage,0)                                                                           Brokerage,
                   Nvl(c.Service_Tax,0) + Nvl(c.Edu_Cess,0) + Nvl(c.High_Edu_Cess,0)                            Service_Tax,
                   Nvl(C.Security_Txn_Tax,0)                                                                    Security_Txn_Tax,
           Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0)                                               Mf_Stamp_Duty,
                   Nvl(c.Edu_Cess,0)                                                                            Edu_Tax,
                   Nvl(c.High_Edu_Cess,0)                                                                       Hdu_Tax,
                   Decode(m.Buy_Sell_Flg,'P',m.Amount + (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)+Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0)),
                                         'R',-1*(Round(m.Quantity*m.Alloted_Nav,2) - (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)+Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0))))  Total ,
                   Stamp_Duty
            FROM   Mfss_Trades m,
                   Mfss_Contract_Note c,
                   Mfd_Scheme_Master s,
                   Entity_Master e
            WHERE  m.Order_Date BETWEEN Nvl(p_From_Date,Order_Date) AND Nvl(p_To_Date,Order_Date)
            AND    m.Order_Date BETWEEN s.Msm_From_Date AND Nvl(s.Msm_To_Date,m.Order_Date)
            AND    m.Order_Date                = c.Transaction_Date
            AND    m.Exm_Id                    = Nvl(p_Exch_Id, m.Exm_Id)
            AND    m.Exm_Id                    = c.Exm_Id
            AND    m.Ent_Id    BETWEEN Nvl(p_From_Ent_Id,m.Ent_Id) AND Nvl(p_To_Ent_Id,m.Ent_Id)
            AND    m.Ent_Id                    = c.Ent_Id
            AND    m.Order_No                  = c.Order_No
            AND    m.Security_Id               = c.Amc_Scheme_Code
            AND    m.Security_Id               = s.Msm_Scheme_Id
            AND    m.Contract_No               = c.Cn_No
            AND    m.Ent_Id                    = e.Ent_Id
            AND    s.Msm_Record_Status         = 'A'
            AND    Trade_Status                = 'A'
            AND    Order_Status                = 'VALID'
            AND    Nvl(Confirmation_Flag,'N')  = 'Y'
            AND    c.Status                    = 'I'
            AND    e.Ent_Dispatch_Mode         = Nvl(P_Dispatch_Mode, e.Ent_Dispatch_Mode)
            AND    Nvl(P_Bounced_Flag,'N')    = 'N'
            ORDER BY 1,11,3,2)
      GROUP BY GROUPING SETS (( Order_Date,
                                Client_Id,
                                Order_No,
                                Order_Time,
                                Sett_Type,
                                Stc_No,
                                Scheme_Id,
                                Scheme_Desc,
                                Isin,
                                Folio_No,
                                Contract_No,
                                Buy_Units,
                                Buy_Phy_Demat,
                                Buy_Nav,
                                Buy_Commission,
                                Buy_Amt,
                                Sell_Units,
                                Sell_Phy_Demat,
                                Sell_Nav,
                                Sell_Commission,
                                Sell_Amt,
                                Brokerage,
                                Service_Tax,
                                Security_Txn_Tax,
                                Mf_Stamp_Duty,
                                Edu_Tax,
                                Hdu_Tax,
                                Total),(Scheme_Id,Order_Date,Client_Id,Service_Tax,Security_Txn_Tax,Mf_Stamp_Duty,Contract_No))
      UNION ALL
      SELECT  Client_Id,
              Order_No,
              Order_Date,
              Order_Time,
              Sett_Type,
              Stc_No,
              Decode(Order_No,NULL,NULL,Scheme_Id) Scheme_Id,
              Scheme_Desc,
              Isin,
              Folio_No,
              Contract_No,
              Buy_Units,
              Buy_Phy_Demat,
              Buy_Nav,
              Buy_Commission,
              SUM(Buy_Amt) Buy_Amt,
              Sell_Units,
              Sell_Phy_Demat,
              Sell_Nav,
              Sell_Commission,
              SUM(Sell_Amt) Sell_Amt,
              Brokerage,
              Service_Tax,
              Security_Txn_Tax,
        Mf_Stamp_Duty,
              Edu_Tax,
              Hdu_Tax,
              Total
      FROM (SELECT Decode(e.ent_category,'NRI',e.ent_mf_ucc_code ,m.Ent_Id)   Client_Id,
                   m.Order_No            Order_No,
                   m.Order_Date          Order_Date,
                   m.Order_Time          Order_Time,
                   m.Settlement_Type     Sett_Type,
                   m.Stc_No              Stc_No,
                   m.Security_Id         Scheme_Id,
                   s.Msm_Scheme_Desc     Scheme_Desc,
                   m.Isin                Isin,
                   m.Folio_No            Folio_No,
                   m.Contract_No         Contract_No,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Quantity),'99999999999999999990D9999'))             Buy_Units,
                   Decode(m.Buy_Sell_Flg,'P','Demat',NULL)                                                      Buy_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Alloted_Nav),'99999999999999999990D9999'))          Buy_Nav,
                   Decode(m.Buy_Sell_Flg,'P', Nvl(c.Brokerage, 0) ,NULL)                                        Buy_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',(m.Amount+ Nvl(c.Brokerage, 0))),'99999999999999999990D99'))Buy_Amt,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Quantity),'99999999999999999990D9999'))             Sell_Units,
                   Decode(m.Buy_Sell_Flg,'R','Demat',NULL)                                                      Sell_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Alloted_Nav),'99999999999999999990D9999'))          Sell_Nav,
                   Decode(m.Buy_Sell_Flg,'R',Nvl(c.Brokerage, 0) ,NULL)                                         Sell_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',-1*(Round(m.Quantity*m.Alloted_Nav,2)- Nvl(c.Brokerage,0))),'99999999999999999990D99')) Sell_Amt,
                   Nvl(c.Brokerage,0)                                                                           Brokerage,
                   Nvl(c.Service_Tax,0) + Nvl(c.Edu_Cess,0) + Nvl(c.High_Edu_Cess,0)                            Service_Tax,
                   Nvl(C.Security_Txn_Tax,0)                                                                    Security_Txn_Tax,
           Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0)                                               Mf_Stamp_Duty,
                   Nvl(c.Edu_Cess,0)                                                                            Edu_Tax,
                   Nvl(c.High_Edu_Cess,0)                                                                       Hdu_Tax,
                   Decode(m.Buy_Sell_Flg,'P',m.Amount + (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)+Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0)),
                                         'R',-1*(Round(m.Quantity*m.Alloted_Nav,2) - (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)+Nvl(C.Mf_Stamp_Duty,0) + NVL(C.Mf_Exit_Load,0))))  Total ,
                   Stamp_Duty
            FROM   Mfss_Trades m,
                   Mfss_Contract_Note c,
                   Mfd_Scheme_Master s,
                   Entity_Master e,
                   Bounced_Contract_Notes Bcn
            WHERE  m.Order_Date BETWEEN s.Msm_From_Date AND Nvl(s.Msm_To_Date,m.Order_Date)
            AND    m.Order_Date                = c.Transaction_Date
            AND    m.Exm_Id                    = Nvl(p_Exch_Id, m.Exm_Id)
            AND    m.Exm_Id                    = c.Exm_Id
            AND    m.Ent_Id     BETWEEN Nvl(p_From_Ent_Id,m.Ent_Id) AND Nvl(p_To_Ent_Id,m.Ent_Id)
            AND    m.Ent_Id                    = c.Ent_Id
            AND    m.Order_No                  = c.Order_No
            AND    m.Security_Id               = c.Amc_Scheme_Code
            AND    m.Security_Id               = s.Msm_Scheme_Id
            AND    m.Contract_No               = c.Cn_No
            AND    m.Ent_Id                    = e.Ent_Id
            AND    s.Msm_Record_Status         = 'A'
            AND    Trade_Status                = 'A'
            AND    Order_Status                = 'VALID'
            AND    Nvl(Confirmation_Flag,'N')  = 'Y'
            AND    c.Status                    = 'I'
            AND    Bcn.Bcn_Date                = C.Transaction_Date
            AND    Bcn.Bcn_Ent_Id              = C.Ent_Id
            AND    Bcn.Bcn_Exm_Id              = C.Exm_Id
            AND    Bcn.Bcn_Seg_Id              = 'M'
            AND    Bcn.Bcn_Cn_No               = C.Cn_No
            AND    Trunc(Bcn.Bcn_Bounced_Dt_Time) BETWEEN Nvl(p_From_Date, Trunc(Bcn.Bcn_Bounced_Dt_Time))
                     AND Nvl(p_To_Date, Trunc(Bcn.Bcn_Bounced_Dt_Time))
            AND    e.Ent_Dispatch_Mode         = Nvl(P_Dispatch_Mode, e.Ent_Dispatch_Mode)
            AND    Nvl(P_Bounced_Flag,'N')    = 'Y'
            ORDER BY 1,11,3,2)
      GROUP BY GROUPING SETS (( Order_Date,
                                Client_Id,
                                Order_No,
                                Order_Time,
                                Sett_Type,
                                Stc_No,
                                Scheme_Id,
                                Scheme_Desc,
                                Isin,
                                Folio_No,
                                Contract_No,
                                Buy_Units,
                                Buy_Phy_Demat,
                                Buy_Nav,
                                Buy_Commission,
                                Buy_Amt,
                                Sell_Units,
                                Sell_Phy_Demat,
                                Sell_Nav,
                                Sell_Commission,
                                Sell_Amt,
                                Brokerage,
                                Service_Tax,
                                Security_Txn_Tax,
                                Mf_Stamp_Duty,
                                Edu_Tax,
                                Hdu_Tax,
                                Total),(Scheme_Id,Order_Date,Client_Id,Service_Tax,Security_Txn_Tax,Mf_Stamp_Duty,Contract_No));

    PROCEDURE p_Get_Class_Html IS
    BEGIN
      g_Html  := '<html><head><title>Transaction Confirmation Note</title> <style type="text/css">#left { text-align:left}#right{ text-align:right}#center{ text-align:center}//a
                  {  text-decoration: none}////A:active {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9; FONT-FAMILY: Arial,Helvetica,
                  sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:link {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9; FONT-FAMILY:
                  Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:visited {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9;
                  FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:hover {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR:
                  #130FC9; FONT-FAMILY: Arial,Helvetica, sans-serif;  TEXT-DECORATION: underline;cursor:hand;}////A.cellLink:active {FONT-WEIGHT: bold;
                  FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:link
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:visited
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:hover
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #FF0000; FONT-FAMILY: Arial,Helvetica, sans-serif;  TEXT-DECORATION: underline;cursor:hand;}.
                  BODY {margin-left:0px;margin-top:0px;background:#FFFEFF}</style>';

      g_Html2 := '<style type = "text/css">th            {color: white;background-color: #214896;text-align: left;padding: 4px;font-size: 12px;font-weight: bold;
                  font-family: sans-serif;margin-bottom:12px;margin-top:0px;}BODY          {margin-left:0px;margin-top:0px;background:#FFFFFF;}
                              BODYMenu        {margin-left:0px;margin-top:0px;background:#FFFFFF;}</style>';

      g_Html3 := '<style type = "text/css">.ctrNoteHdrMainTable  {color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden;} .ctrNoteHdrMainTableW{color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden; WORD-BREAK:BREAK-ALL;} .ctrNoteHdrMainTable1
                {color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden;border-top: 1px solid #95969A;  border-right: 0px solid #95969A; }.rSttHdr
                {FONT-SIZE: 11px;COLOR: #FFFFFF;FONT-FAMILY: Verdana;FONT-WEIGHT: bold;BACKGROUND-COLOR: 22488A;TEXT-ALIGN: left border-bottom: 1px solid #95969A;border-left: 1px solid #95969A;}.rCtrHdr1
                {FONT-SIZE: 11px;COLOR: #333333;FONT-FAMILY: Verdana;FONT-WEIGHT: bold;BACKGROUND-COLOR: #D5D7E6;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-left: 1px solid #95969A;}.rCtrNoteEvenRow
                {FONT-SIZE: 10px; COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: #D5E2EE;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; } .rCtrNoteOddRow
                {FONT-SIZE: 10px;COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: #F8F9FE;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; } .borderclass
                {border-bottom: 1px solid #95969A;border-right: 1px solid #95969A;}.borderclass1      {border-bottom: 1px solid #95969A;border-left: 1px solid #95969A;border-top: 1px solid #95969A;}.borderclass2
                {border-bottom: 1px solid #95969A;border-right: 1px solid #95969A;border-left: 1px solid #95969A;border-top: 1px solid #95969A;}.rDetail        { FONT-SIZE: 10px;';

      g_Html4 := 'COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: white;TEXT-ALIGN: left border-right: 1px solid #95969A;border-bottom: 1px solid #95969A; } .rDetail2
                { FONT-SIZE: 14px;COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: white;TEXT-ALIGN: left border-right: 1px solid #95969A;border-bottom: 1px solid #95969A; } .rHeader
                {font-weight: bold;font-size: 9pt;color: black;font-family: Times New Roman;background-color: white;text-align: center } .textDataShowHDFC    {font-family:
                Arial, Helvetica, sans-serif;color:#FF0000;text-align:left;font-weight: bold;font-size: 24pt;}.textDataShowBlack  {font-family:  Arial, Helvetica, sans-serif;color:black;text-align:left;font-size: 8pt;
                border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; }.textDataShowBlack2  {font-family:  "Arial Black", Gadget, sans-serif;color:black;text-align:left;font-size: 11pt;}.rSTTDetail  {font-family:  Times New Roman,
                Helvetica, sans-serif;font-weight:bold; color:black;text-align:left;font-size: 13pt;}</style>
                <style>.break { page-break-before: always; }</style>
                </head><body bgcolor=white>';
    END p_Get_Class_Html;

    PROCEDURE P_Print_Header IS
    BEGIN
    IF l_Line_Count_break = -1 THEN
      l_Net_Total            := 0;
      l_Net_Buy_Amt          := 0;
      l_Net_Sell_Amt         := 0;
      l_Net_Service_Tax      := 0;
      l_Net_Security_Txn_Tax := 0;
     l_Net_Mf_Stamp_Duty    := 0;
      l_Start_Time           := SYSDATE;
    END IF;

      p_Ret_Msg := ' Selecting address details for Client <'||l_Ent_Id||'>';
      SELECT Ent_Name,                               Ent_Exch_Client_Id,             Ent_Address_Line_1,
             Ent_Address_Line_2,                     Ent_Address_Line_3,             Ent_Address_Line_4,
             Ent_Address_Line_5,                     Ent_Address_Line_6,             Ent_Address_Line_7,
             Nvl(Ent_Phone_No_1,Ent_Phone_No_2),     Erd_Pan_No,                     End_Email_Id||','
      INTO   l_Ent_Name,                             l_Ent_Exch_Client_Id,           l_Ent_Address_Line_1,
             l_Ent_Address_Line_2,                   l_Ent_Address_Line_3,           l_Ent_Address_Line_4,
             l_Ent_Address_Line_5,                   l_Ent_Address_Line_6,           l_Ent_Address_Line_7,
             l_Ent_Phone_No,                         l_Erd_Pan_No,                   l_Ent_Email_Id
      FROM   Entity_Master,
             Entity_Registration_Details,
             Entity_Details
      WHERE  Ent_Id           = Erd_Ent_Id
      AND    Ent_Id           = End_Id
      AND    Ent_Id           = l_Ent_Id
      AND    End_Status       = 'A'
      AND    End_Default_Flag = 'Y';

      p_Ret_Msg := ' Selecting dealer''s address details for Client <'||l_Ent_Id||'>';
      SELECT Ent_Name,
             Nvl(Ent_Address_Line_1,'---') ||', '||
             Nvl(Ent_Address_Line_2,'---') ||', '||
             Nvl(Ent_Address_Line_3,'---') ||', '||
             Nvl(Ent_Address_Line_4,'---') Addr_1,
             Nvl(Ent_Address_Line_5,'---') ||', '||
             Nvl(Ent_Address_Line_6,'---') ||', '||
             Nvl(Ent_Address_Line_7,'---') Addr_2,
             Nvl(Ent_Phone_No_1,'---')     ||'/'||
             Nvl(Ent_Phone_No_2,'---')     Phone,
             Nvl(Ent_Fax_No_1,'---')       ||'/'||
             Nvl(Ent_Fax_No_2,'---')       Fax
      INTO   l_Dl_Name,
             l_Dl_Address_1,
             l_Dl_Address_2,
             l_Dl_Phone_No,
             l_Dl_Fax_No
      FROM   Entity_Master
      WHERE  Ent_Id IN (SELECT Ent_Ctrl_Id
                        FROM   Entity_Master
                        WHERE  Ent_Id IN (SELECT Ent_Mfss_Ctrl_Id
                                          FROM   Entity_Master
                                          WHERE  Ent_Id = l_Ent_Id));


      SELECT Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_1',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_2',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_3',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_4',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_5',Rv_High_Value))
      INTO   l_Auth_Signatory
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain    = 'COMMON_CONTRACT_NOTE'
      AND    Rv_Low_Value LIKE 'AUTHORIZED_SIGN%';

      p_Ret_Msg := ' Generating new file for Client <'||l_Ent_Id||'>';
      IF l_Gen_New_File = TRUE THEN
        SELECT To_Char(l_Pam_Curr_Dt,'RRRRMM')||Lpad(Rep_Gen_Seq.NEXTVAL,8,0)
        INTO   l_Rep_Gen_Seq
        FROM   Dual;

        l_Count_Reports := l_Count_Reports + 1;

        p_Ret_Msg := 'Opening file on server path <'||l_Mf_Order_Cnfm_Path||'><'||l_Fold_Name||'><'||l_File_Name||'>';
        IF P_Print_Flag = 'Y' THEN
          l_File_Name := 'MF_ORDER_CONFIRMATION_'||To_Char(l_Order_Date,'DDMONRRRR')||'_'||l_Rep_Gen_Seq||'.htm';
        ELSE
          l_File_Name := l_Contract_No||'_'||l_Ent_Id||'_'||P_Exch_Id||'_MF_ORDER_CONFIRMATION_'||To_Char(l_Order_Date,'DDMONRRRR')||'.htm';
        END IF;
        l_File_Ptr := Utl_File.Fopen(l_Mf_Order_Cnfm_Path || l_Fold_Name,l_File_Name,'W');

        p_Ret_Msg := ' Inserting data for Client <'||l_Ent_Id||'> in Rep_Gen ';
        INSERT INTO Rep_Gen
          (Rg_Seq,                  Rg_File_Name,            Rg_Status,
           Rg_Act_Gen_Dt,           Rg_Start_Time,           Rg_Remarks,
           Rg_Creat_Dt,             Rg_Creat_By,             Rg_Rep_Id,
           Rg_Exchange,             Rg_Segment,              Rg_Ent_Id,
           Rg_Comm_Channel,         Rg_End_Time,             Rg_Gen_Dt,
           Rg_Rgm_Seq_No,           Rg_Attribute,            Rg_Attribute_1)
        VALUES
          (l_Rep_Gen_Seq,           l_Mf_Order_Cnfm_Path||l_Fold_Name||'/'||l_File_Name,  'R',
           l_Pam_Curr_Dt,           l_Start_Time,                                         'MF Order Confirmation Note for Client '||l_Ent_Id,
           SYSDATE,                 USER,                                                 l_Prg_Id,
           P_Exch_Id,               'M',                                                  l_Ent_Id,
           'P',                     l_End_Time,                                           l_Pam_Curr_Dt,
           l_Web_Seq_No,            l_Ent_Email_Id,                                       'Mutual Fund Order Confirmation Note');

        p_Get_Class_Html;
        Utl_File.Put_Line(l_File_Ptr, g_Html);
        Utl_File.Put_Line(l_File_Ptr, g_Html2);
        Utl_File.Put_Line(l_File_Ptr, g_Html3);
        Utl_File.Put_Line(l_File_Ptr, g_Html4);
      END IF;

      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable" id=mytable cellspacing=0 cellpadding=2 border=0  width = ''100%''> ');
      IF P_Print_Flag = 'Y' THEN
         Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
         Utl_File.Put_Line(l_File_Ptr,'<td align = Right colspan = 2 nowrap><img src="HDFC_Logo.jpg" border="0" class = "textDataShowBlack2" alt="HDFC Securities Ltd." width="200" height="35" ></td>');
         Utl_File.Put_Line(l_File_Ptr,'</tr>');
      END IF;
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
      Utl_File.Put_Line(l_File_Ptr,'  <td align = left colspan = 2 nowrap>TRANSACTION CONFIRMATION NOTE<br>(Mutual Fund Segment of '||p_Exch_Id||')<hr color = ''#333333''></hr></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rheader > ');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = "textDataShowHDFC" colspan = 2 nowrap>'||l_Cpm_Desc||'</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
      Utl_File.Put_Line(l_File_Ptr,'<td align = left colspan = 2 nowrap><br><b>Member of Bombay stock Exchange(BSE Ltd), National stock Exchange(NSE)
                                    </b><br><b>Sebi Registration Nos
                                    </b><br><b>BSE: CM: '||l_bse_sebi_no||' FO: INF011109437
                                    </b><br><b>NSE: CM: '||l_Nse_sebi_no||' FO: INF231109431 CUR: INE231109431 </b>
                                    <br><b>Registered & Corporate Office : </b>'||l_Cpm_Address||'  CIN - U67120MH2000PLC152193
                                    <br> Tel.No. : 30753400 Fax No. : 30753435
                                    <br><b>Customer Care : </b>HDFC Securities Ltd, 2nd Floor, Trade Globe, Kondivita Junction,Andheri Kurla Road, Andheri(E),Mumbai - 400 059.<br>Tel. No. : 39019400 (prefix local code) Fax No. : 28346690 Website : www.hdfcsec.com ;
                                    Email : '||l_Cpm_Email_Id||', For complaints:services@hdfcsec.com<br> <B>Mumbai Dealing :</B> 33553366 (prefix local code only if calling from mobile).eg for mobile - (0 + local area code + 33553366); for locations with 3 digit local std code the no is
                                    <br> 33553366 e.g 044 33553366 ; for locations with 4 digit local std code the no is 3355336 e.g 0484 3355336. <br>
                                    <b>Dealing Office Address : </b>'||l_Dl_Name||','||l_Dl_Address_1||'<br> '||l_Dl_Address_2||
                                    ' Tel. No. :'||l_Dl_Phone_No||' Fax No. :'||l_Dl_Fax_No||'<br><b>Compliance Officer details : Name: </b>'||l_Cpm_Compliance_Name||',<b> Tel no: </b>'||l_Cpm_Compliance_Tel_No||',
                                    <b> Email Id: </b>'||l_Cpm_Compliance_Email||'<br><b>SERVICE TAX NO. : ;AAACH8215RST001</b><br><b>ARN NO. : </b>'||l_Eam_Arn_No||'</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail colspan = 5> ');
      Utl_File.Put_Line(l_File_Ptr,'<td><br>Trading & Unique Client Code: '||l_Ent_Exch_Client_Id||'<br>'||
                                    l_Ent_Name||'<br>'||
                                    l_Ent_Address_Line_1||'<br>   '||
                                    l_Ent_Address_Line_2||'<br>   '||
                                    l_Ent_Address_Line_3||'<br>   '||
                                    l_Ent_Address_Line_4||'<br>   '||
                                    l_Ent_Address_Line_5||'<br>   '||
                                    l_Ent_Address_Line_6||'<br>   '||
                                    l_Ent_Address_Line_7||'<br>   '||
                                    'Ph: '||l_Ent_Phone_No||';<br>'||
                                    'Pan No: '||l_Erd_Pan_No||'</td> ');

      Utl_File.Put_Line(l_File_Ptr,'<td> <table id=mytable cellspacing=0 cellpadding=2 border=0 class = "ctrNoteHdrMainTable" align=center> ');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Sett No: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||l_Sett_No||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Transaction Date: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||To_Char(l_Order_Date,'DD-MON-RRRR')||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Transaction Confirmation note no: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||l_Contract_No||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'  </table> ');
      Utl_File.Put_Line(l_File_Ptr,'</td> ');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');
      Utl_File.Put_Line(l_File_Ptr,'</table><br>');

      Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1"  align=center width = ''100%''>
                                    <tr class = rDetail >
                                    <hr color = ''#333333''></hr>
                                    <td class = "borderclass" align = left colspan = 19>Dear Sir/Madam,<br>
                                    I/we have on this day done by your order and on your account entered the following orders in the Mutual Fund system for the following requests for subscription and / or request for redemption.
                                    </td></tr><tr class = rheader></tr></table>  ');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTableW" id=mytable cellspacing=0 cellpadding=0 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rSttHdr>');
      Utl_File.Put_Line(l_File_Ptr,'  <td align = left class = borderclass colspan = 19>;</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrHdr1>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = ''right''>;</td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass align = center colspan = 5 align = ''right''><b>"Units Bought For You"*</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass align = center colspan = 5 align = ''right''><b>"Units Sold For You"*</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrHdr1>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Order <br>No.</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Order <br>Time</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Sett. <br>Type</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Scheme <br>Id</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>ISIN </b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = center><b>Name of <br>the<br>Mutual<br>Fund<br>Scheme</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Folio No</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>No of <br>Units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Physical <br>/Demat units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Rate<br>Per<br>Unit<br>(NAV)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Commission<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Total <br>Amount<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>No of <br>Units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Physical <br>units/Demat</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Rate<br>Per<br>Unit<br>(NAV)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Commission<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Total<br>Amount<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');
    END P_Print_Header;

    PROCEDURE P_Print_Footer IS
    BEGIN
      IF l_Net_Total > 0 THEN

        IF l_Net_Service_Tax = 0 THEN
          l_Net_Service_Tax := NULL;
        END IF;

        IF l_Net_Buy_Amt = 0 THEN
          l_Net_Buy_Amt_Display := NULL;
        ELSE
          l_Net_Buy_Amt_Display :=  To_Char(l_Net_Buy_Amt,'99999999999999999999D99');
        END IF;

        IF abs(l_Net_Sell_Amt) = 0 THEN
          l_Net_Sell_Amt_Display := NULL;
        ELSE
          l_Net_Sell_Amt := abs(l_Net_Sell_Amt);
          l_Net_Sell_Amt_Display :=  To_Char(l_Net_Sell_Amt,'99999999999999999999D99');
        END IF;

        l_Net_Total := abs(l_Net_Total);
        l_Net_Total_Display := To_Char(l_Net_Total,'99999999999999999999D99');

Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Bought/Sold Value:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Sell_Amt_Display||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Service Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Service_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Security Transaction Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Security_Txn_Tax||';</b></td>');

    Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Stamp Duty/Tax/Exit Load:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Mf_Stamp_Duty||'&nbsp;</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Due From You:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Total_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr></table>');
      ELSE

        IF l_Net_Service_Tax = 0 THEN
          l_Net_Service_Tax := NULL;
        END IF;

        IF l_Net_Buy_Amt = 0 THEN
          l_Net_Buy_Amt_Display := NULL;
        ELSE
          l_Net_Buy_Amt_Display :=  To_Char(l_Net_Buy_Amt,'99999999999999999999D99');
        END IF;

        IF abs(l_Net_Sell_Amt) = 0 THEN
          l_Net_Sell_Amt_Display := NULL;
        ELSE
          l_Net_Sell_Amt := abs(l_Net_Sell_Amt);
          l_Net_Sell_Amt_Display :=  To_Char(l_Net_Sell_Amt,'99999999999999999999D99');
        END IF;

        l_Net_Total := abs(l_Net_Total);
        l_Net_Total_Display := To_Char(l_Net_Total,'99999999999999999999D99');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Bought/Sold Value:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Sell_Amt_Display||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Service Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Service_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Security Transaction Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Security_Txn_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Stamp Duty/Tax/Exit Load:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Mf_Stamp_Duty||'&nbsp;</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Due To You:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Total_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr></table>');
      END IF;

       -- border = 0
      Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1" align=center width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >  <td class = "borderclass" align = left colspan = 19 nowrap><BR>You may kindly note that:
                                                                                                        <BR>*The units shall be directly delivered to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>*Redemption proceeds shall be directly paid to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>
                                                                                                        <BR>1. This memo constitutes and shall be deemed to constitute an agreement between you and me/us.</td></tr>  ');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail>   <td  colspan = 4 valign = top><BR><BR><BR><BR>Place: Mumbai<BR>Date: '||To_Char(l_Pam_Curr_Dt,'DD-MON-RRRR')||'</td>     ');
      Utl_File.Put_Line(l_File_Ptr,'           <td  colspan = 15 nowrap align="right" valign = top><BR>
                                                                                                   <BR>
                                                                                                   <BR>
                                                                                                   <BR>Yours Faithfully
                                                                                                   <br>For '||l_Cpm_Desc||'
                                                                                                   <br>
                                                                                                   <br>Authorised Signatory
                                                                                                   <br>PAN No. of Member : '||l_Broker_Pan_No||'</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable1" id=mytable colspan = 19 cellspacing=0 cellpadding=2 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >
                                       <td class = "borderclass" colspan = 19 >
                                       <B>AUTHORISED SIGNATORY:</b>'||l_Auth_Signatory||'.</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      --Utl_File.Put_Line(l_File_Ptr,'</center>');
      --Utl_File.Put_Line(l_File_Ptr,'</center></body></html>');
      --Utl_File.Fclose(l_File_Ptr);

      IF l_Gen_New_File = TRUE THEN
        Utl_File.Put_Line(l_File_Ptr,'</body></html>');
        Utl_File.Fclose(l_File_Ptr);

        UPDATE Rep_Gen
        SET    Rg_Status       = 'S',
               Rg_Remarks      = 'MF Order Confirmation Note Generated Successfully For '||l_Last_Ent_Id,
               Rg_End_Time     = SYSDATE,
               Rg_Last_Updt_By = USER,
               Rg_Last_Updt_Dt = SYSDATE
        WHERE  Rg_Seq          = l_Rep_Gen_Seq;

      ELSE
        Utl_File.Put_Line(l_File_Ptr,'<h1 class="break">;');
        Utl_File.Put_Line(l_File_Ptr,'</h1>');
      END IF;
    END P_Print_Footer;

    PROCEDURE P_Print_Footer_Signatory IS
    BEGIN
      Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1" align=center width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >  <td class = "borderclass" align = left colspan = 19 nowrap><BR>You may kindly note that:
                                                                                                        <BR>*The units shall be directly delivered to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>*Redemption proceeds shall be directly paid to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>
                                                                                                        <BR>1. This memo constitutes and shall be deemed to constitute an agreement between you and me/us.</td></tr>  ');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail>   <td  colspan = 4 valign = top><BR><BR><BR><BR>Place: Mumbai<BR>Date: '||To_Char(l_Pam_Curr_Dt,'DD-MON-RRRR')||'</td>     ');
      Utl_File.Put_Line(l_File_Ptr,'           <td  colspan = 15 nowrap align="right" valign = top><BR>
                                                                                                   <BR>
                                                                                                   <BR>
                                                                                                   <BR>Yours Faithfully
                                                                                                   <br>For '||l_Cpm_Desc||'
                                                                                                   <br>
                                                                                                   <br>Authorised Signatory
                                                                                                   <br>PAN No. of Member : '||l_Broker_Pan_No||'</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable1" id=mytable colspan = 19 cellspacing=0 cellpadding=2 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >
                                       <td class = "borderclass" colspan = 19 >
                                       <B>AUTHORISED SIGNATORY:</b>'||l_Auth_Signatory||'.</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      IF l_Line_Count_break = 501 THEN
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
      ELSE
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
      END IF;
      --Utl_File.Put_Line(l_File_Ptr,'</center>');
      --Utl_File.Put_Line(l_File_Ptr,'</center></body></html>');
      --Utl_File.Fclose(l_File_Ptr);

    END P_Print_Footer_Signatory;

    PROCEDURE p_Order_Confirmation_Info IS
    BEGIN
      p_Ret_Msg := ' Selecting path for storing MF Order Confirmation Note';
      SELECT Decode(Substr(Rv_Low_Value,-1),'/',Rv_Low_Value,Rv_Low_Value||'/')
      INTO   l_Mf_Order_Cnfm_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MUTUAL_FUND_ORDER_CONFIRM';

      p_Ret_Msg := 'Fetching command for creating directory to write the file';
      SELECT Rv_high_value
      INTO   l_Mkdir_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain    = 'MKDIR'
      AND    Rv_Low_Value = 'MKDIR_PATH';

      p_Ret_Msg := ' Generating the sequence for MF Order Confirmation Note directory ';
      SELECT COUNT(*)
      INTO   l_Folder_Seq
      FROM   Web_Rep_Gen
      WHERE  Rg_Rep_Id = l_Prg_Id
      AND    Rg_Gen_Dt = l_Pam_Curr_Dt;

      l_Folder_Seq := l_Folder_Seq + 1;
      l_Fold_Name  := To_Char(l_Pam_Curr_Dt,'DDMONRRRR')||'_MF_ORD_CONFIRM_'||l_Folder_Seq;

      p_Ret_Msg    := ' Creating a directory for storing MF Order Confirmation Note ';
     --l_Server_Cmd := '/usr/bin/mkdir '||l_Mf_Order_Cnfm_Path || l_Fold_Name;
      l_Server_Cmd := l_Mkdir_Path ||' '|| l_Mf_Order_Cnfm_Path || l_Fold_Name;


      IF g_Count_Directory = 0 THEN
        l_Submit_Cmd_Ret_Val := Submit_Cmd('run_comm ' || l_Server_Cmd);

        IF l_Submit_Cmd_Ret_Val != 2 THEN
          RAISE Ex_Submit_Cmd;
        END IF;
      END IF;

      SELECT Web_Rep_Gen_Seq.NEXTVAL
      INTO   l_Web_Seq_No
      FROM   Dual;

      p_Ret_Msg := ' Inserting Folder path and details in Web_Rep_Gen ';
      INSERT INTO Web_Rep_Gen
        (Rg_Seq,                                          Rg_File_Name,       Rg_Status,
         Rg_Gen_Dt,                                       Rg_Act_Gen_Dt,      Rg_Start_Time,
         Rg_Remarks,                                      Rg_Creat_Dt,        Rg_Creat_By,
         Rg_Rep_Id,                                       Rg_Exchange,        Rg_Segment,
         Rg_From_Dt,                                      Rg_To_Dt,           Rg_From_Client,
         Rg_To_Client,                                    Rg_Type,            Rg_Category,
         Rg_Desc,                                         Rg_File_Path,       Rg_Log_File_Name)
      VALUES
        (l_Web_Seq_No,                                    l_Fold_Name,        'R',
         l_Pam_Curr_Dt,                                   l_Pam_Curr_Dt,      SYSDATE,
         'Generating MF Order Confirmation Note Started', SYSDATE,            USER,
         l_Prg_Id,                                        p_Exch_Id,          'M',
         p_From_Date,                                     p_To_Date,          p_From_Ent_Id,
         p_To_Ent_Id,                                     'FOLDER',           'MF_ORDER_CONFIRMATION',
         'MUTUAL FUND CONFIRMATION NOTE',                 l_Server_Cmd,       l_Log_File_Name);

      p_Ret_Msg := ' Selecting Company Details ';
      SELECT c.Cpm_Id,
             c.Cpm_Desc,
             c.Cpm_Address1||', '||c.Cpm_Address2||', '||c.Cpm_Address3,
             c.Cpm_Email_Id,
             c.Cpm_Compliance_Name,
             c.Cpm_Compliance_Tel_No,
             c.Cpm_Compliance_Email,
             Erd_Pan_No,
             Eam_Arn_No
      INTO   l_Cpm_Id,
             l_Cpm_Desc,
             l_Cpm_Address,
             l_Cpm_Email_Id,
             l_Cpm_Compliance_Name,
             l_Cpm_Compliance_Tel_No,
             l_Cpm_Compliance_Email,
             l_Broker_Pan_No,
             l_Eam_Arn_No
      FROM   Company_Master c,
             Entity_Registration_Details,
             Mfss_Exch_Admin_Master
      WHERE  Cpm_Id     = Erd_Ent_Id
      AND    Cpm_Id     = Eam_Cpd_Id
      AND    Eam_Cpd_Id = Erd_Ent_Id
      AND    Eam_Exm_Id = p_Exch_Id;

      p_Ret_Msg := ' Selecting Broker Details ';
      SELECT Decode(p_Exch_Id,'NSE','NSE MFSS','BSE','BSE Star MF'),
             Decode(p_Exch_Id,'NSE','Member code No. '||m.Eam_Broker_Id,'BSE','Clearing No. '||m.Eam_Broker_Id),
             m.Eam_Sebi_Reg_No
      INTO   l_Exm_Name,
             l_Broker_Id,
             l_Broker_Sebi_Reg_No
      FROM   Exchange_Master,
             Mfss_Exch_Admin_Master m
      WHERE  Exm_Id = m.Eam_Exm_Id
      AND    Exm_Id = p_Exch_Id;

      select Eam_sebi_reg_no
      Into l_nse_sebi_no
      from mfss_exch_admin_master t
      where t.eam_exm_id='NSE';

      select Eam_sebi_reg_no
      Into l_Bse_sebi_no
      from mfss_exch_admin_master t
      where t.eam_exm_id='BSE';

      g_Count_Directory := g_Count_Directory + 1;
    END p_Order_Confirmation_Info;

  BEGIN
    p_Ret_Val := 'FAIL';

    IF P_Print_Flag = 'Y' THEN
      l_Prg_Id := 'CSSWBMFOCNP';
    ELSE
      l_Prg_Id := 'CSSWBMFOCN';
    END IF;

    p_Ret_Msg := ' Performing Housekeeping Activities .';
    Std_Lib.p_Housekeeping(l_Prg_Id,           p_Exch_Id,          p_From_Date||','||p_To_Date||','||p_Exch_Id||','||p_From_Ent_Id||','||p_To_Ent_Id,
                           'E',                l_Log_File_Ptr,     l_Log_File_Name,
                           l_Process_Id);

    l_Pam_Curr_Dt := Std_lib.l_Pam_Curr_Date;

    Utl_File.Put_Line(l_Log_File_Ptr,' Working Date       : ' || l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Ptr,'');
    Utl_File.Put_Line(l_Log_File_Ptr,' Parameters Passed  : ');
    Utl_File.Put_Line(l_Log_File_Ptr,' ---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,' From Date          : ' || p_From_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,' To Date            : ' || p_To_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,' Exchange           : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' From Client        : ' || p_From_Ent_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' To Client          : ' || p_To_Ent_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' ---------------------------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Ptr,2);

    p_Order_Confirmation_Info;

    IF P_Print_Flag = 'Y' THEN
      l_Gen_New_File := TRUE;
      l_CN_Cnt := 0;

      SELECT To_Number(RV_LOW_VALUE)
      INTO   l_Total_CN_In_File
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MF_CN_COUNT';
    ELSE
      l_Gen_New_File := TRUE;
    END IF;

    FOR i IN c_Client_Order
    LOOP
      l_Ent_Id            := i.Client_Id;
      l_Order_Date        := i.Order_Date;
      l_Order_Time        := i.Order_Time;
      l_Order_No          := i.Order_No;
      l_Sett_Type         := i.Sett_Type;
      l_Sett_No           := i.Stc_No;
      l_Scheme_Id         := i.Scheme_Id;
      l_Scheme_Desc       := i.Scheme_Desc;
      l_Isin              := i.Isin;
      l_Folio_No          := i.Folio_No;
      l_Contract_No       := i.Contract_No;
      l_Buy_Units         := i.Buy_Units;
      l_Buy_Phy_Demat     := i.Buy_Phy_Demat;
      l_Buy_Nav           := i.Buy_Nav;
      l_Buy_Commission    := i.Buy_Commission;
      l_Buy_Amt           := i.Buy_Amt;
      l_Sell_Units        := i.Sell_Units;
      l_Sell_Phy_Demat    := i.Sell_Phy_Demat;
      l_Sell_Nav          := i.Sell_Nav;
      l_Sell_Commission   := i.Sell_Commission;
      l_Sell_Amt          := i.Sell_Amt;
      l_Brokerage         := i.Brokerage;
      l_Service_Tax       := i.Service_Tax;
      l_Security_Txn_Tax  := i.Security_Txn_Tax;
    l_Mf_Stam_Duty      := i.Mf_Stamp_Duty;
      l_Edu_Cess          := i.Edu_Tax;
      l_High_Edu_Cess     := i.Hdu_Tax;
      l_Total             := i.Total;

      IF l_Rep_Gen_Seq IS NOT NULL AND (l_Ent_Id <> l_Last_Ent_Id OR l_Last_Contract_No <> l_Contract_No) THEN
        IF P_Print_Flag = 'Y' THEN
          IF l_CN_Cnt = l_Total_CN_In_File THEN
            l_CN_Cnt := 0;
            l_Gen_New_File := TRUE;
          ELSE
            l_Gen_New_File := FALSE;
          END IF;

          P_Print_Footer;
        ELSE
          P_Print_Footer;
        END IF;
      END IF;

      IF (l_Ent_Id = l_Last_Ent_Id AND l_Last_Contract_No = l_Contract_No AND l_Line_Count <> l_Line_Count_break) THEN
        l_Header := FALSE;
      ELSE
        l_Header := TRUE;
      END IF;

      IF l_Header THEN
        IF P_Print_Flag = 'Y' AND l_Line_Count <> l_Line_Count_break THEN
          l_CN_Cnt := l_CN_Cnt + 1;
        END IF;
        P_Print_Header;
        l_Line_Count_1 :=0;
        l_Line_Count_2 :=0;
        l_Line_Count   :=0;
        l_Line_Count_break :=-1;
        l_Gen_New_File := TRUE;
      END IF;

      l_Sell_Amt           := abs(l_Sell_Amt);
      l_Sell_Amt_Display   := To_Char(l_Sell_Amt,'999999999999999999D99');
      l_Buy_Amt_Display    := To_Char(l_Buy_Amt,'999999999999999999D99');
      l_Buy_Units_Display  := To_Char(l_Buy_Units,'999999999999999999D9999');
      l_Sell_Units_Display := To_Char(l_Sell_Units,'999999999999999999D9999');

      IF l_Order_No IS NOT NULL THEN
        l_Net_Total    := l_Net_Total + Nvl(l_Total,0);
        l_Net_Buy_Amt  := l_Net_Buy_Amt + Nvl(l_Buy_Amt,0);
        l_Net_Sell_Amt := l_Net_Sell_Amt + Nvl(l_Sell_Amt,0);
        l_Net_Service_Tax  := Nvl(l_Net_Service_Tax,0)  + Nvl(l_Service_Tax,0);
        l_Net_Security_Txn_Tax  := Nvl(l_Net_Security_Txn_Tax,0)  + Nvl(l_Security_Txn_Tax,0);
       l_Net_Mf_Stamp_Duty     := Nvl(l_Net_Mf_Stamp_Duty,0) + Nvl(l_Mf_Stam_Duty,0);

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteOddRow>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_Time||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Sett_Type||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Scheme_Id||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Isin||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = "left">'||l_Scheme_Desc||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Folio_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" >'||l_Buy_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Amt_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right">'||l_Sell_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Amt_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr>');
        l_Line_Count_1 := l_Line_Count_1 +1;
      ELSE
        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_Time||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Sett_Type||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Scheme_Id||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Isin||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = "left">'||l_Scheme_Desc||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Folio_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" >'||l_Buy_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap><b>'||l_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right">'||l_Sell_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap><b>'||l_Sell_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr>');
        l_Line_Count_2 := l_Line_Count_2 +1;
      END IF;

      l_Header      := FALSE;
      l_Last_Ent_Id := l_Ent_Id;
      l_Last_Contract_No := l_Contract_No;
      l_Line_Count := (l_Line_Count_1 *2)+(l_Line_Count_2*1);
      IF l_Line_Count > 500 THEN
        l_Line_Count_break := l_Line_Count;
        l_Gen_New_File := FALSE;
        P_Print_Footer_Signatory;
        --l_Header := TRUE;
      END IF;
    END LOOP;

    IF l_Rep_Gen_Seq IS NOT NULL THEN
      l_Gen_New_File := TRUE;
      P_Print_Footer;
    END IF;

    UPDATE Web_Rep_Gen
    SET    Rg_Status       = 'S',
           Rg_Last_Updt_Dt = SYSDATE,
           Rg_Last_Updt_By = USER,
           Rg_End_Time     = SYSDATE,
           Rg_Remarks      = 'MF Order Confirmation Note Generated Successfully For '||l_Count_Reports||' Clients'
    WHERE  Rg_Seq          = l_Web_Seq_No
    AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

    g_Count_Directory := 0;
    P_Rep_Seq_No      := l_Web_Seq_No;
    p_Ret_Val         := 'SUCCESS';
    p_Ret_Msg         := 'Process Completed Successfully';

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,             l_Pam_Curr_Dt,             l_Process_Id,
                            'C',                  'Y',                       o_Err);

    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,' Mutual Fund Order Confirmation Note Generated at '||l_Mf_Order_Cnfm_Path || l_Fold_Name);
    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' No. of Client Order Confirmation Reports Generated     :   ' ||    l_Count_Reports);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' Process Completed Successfully at <'||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')||'>');
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN Ex_Submit_Cmd THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||' Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' MF Order Confirmation Note Generation Failed - '||p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,        l_Pam_Curr_Dt,       l_Process_Id,
                              'E',             'Y',                 o_Err);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||' Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' MF Order Confirmation Note Generation Failed - '||p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);
      Utl_File.Fclose(l_File_Ptr);

      UPDATE Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = p_Ret_Msg,
             Rg_Last_Updt_By = USER,
             Rg_Last_Updt_Dt = SYSDATE
      WHERE  Rg_Seq          = l_Rep_Gen_Seq;

      UPDATE Web_Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_Last_Updt_Dt = SYSDATE,
             Rg_Last_Updt_By = USER,
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = p_Ret_Msg
      WHERE  Rg_Seq          = l_Web_Seq_No
      AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,            l_Pam_Curr_Dt,            l_Process_Id,
                              'E',                 'Y',                      o_Err);
  END P_Gen_Mfe_Order_Confirm_Note;

  PROCEDURE p_Gen_Mfe_Order_Conf_Note_CSV (p_From_Date     IN  DATE,
                                           p_To_Date       IN  DATE,
                                           p_Exch_Id       IN  VARCHAR2,
                                           p_From_Ent_Id   IN  VARCHAR2,
                                           p_To_Ent_Id     IN  VARCHAR2,
                                           P_Bounced_Flag  IN  VARCHAR2,
                                           P_Dispatch_Mode IN  VARCHAR2,
                                           P_Print_Flag    IN  VARCHAR2,
                                           P_Rep_Seq_No    OUT NUMBER,
                                           p_Ret_Val       OUT VARCHAR2,
                                           p_Ret_Msg       OUT VARCHAR2) IS

    l_File_Name                   VARCHAR2(1000);
    g_Count_Directory             NUMBER := 0;
    l_log_env                     VARCHAR2(1000);
    /*g_Html                        VARCHAR2(4000);
    g_Html2                       VARCHAR2(4000);
    g_Html3                       VARCHAR2(4000);
    g_Html4                       VARCHAR2(4000);*/
    l_Log_File_Ptr                Utl_File.File_Type;
    l_File_Ptr                    Utl_File.File_Type;
    l_Log_File_Name               VARCHAR2(1000);
    l_Start_Time                  DATE;
    l_End_Time                    DATE;
    l_Pam_Curr_Dt                 DATE;
    l_Prg_Id                      VARCHAR2(50);
    l_Ent_Id                      VARCHAR2(50);
    l_Last_Ent_Id                 VARCHAR2(50);
    l_Rep_Gen_Seq                 NUMBER;
    l_Mf_Order_Cnfm_Path          VARCHAR2(50);
    l_Server_Cmd                  VARCHAR2(5000);
    l_Fold_Name                   VARCHAR2(5000);
    l_Folder_Seq                  NUMBER;
    l_Process_Id                  NUMBER;
    o_Err                         VARCHAR2(4000);
    l_Web_Seq_No                  NUMBER := 0;
    l_Ent_Name                    VARCHAR2(2000);
    l_Ent_Address_Line_1          VARCHAR2(2000);
    l_Ent_Address_Line_2          VARCHAR2(2000);
    l_Ent_Address_Line_3          VARCHAR2(2000);
    l_Ent_Address_Line_4          VARCHAR2(2000);
    l_Ent_Address_Line_5          VARCHAR2(2000);
    l_Ent_Address_Line_6          VARCHAR2(2000);
    l_Ent_Address_Line_7          VARCHAR2(2000);
    l_Ent_Exch_Client_Id          VARCHAR2(2000);
    l_Count_Reports               NUMBER := 0;
    l_Order_Date                  DATE;
    l_Order_No                    NUMBER(12);
    l_Sett_No                     VARCHAR2(10);
    l_Scheme_Id                   VARCHAR2(30);
    l_Scheme_Desc                 VARCHAR2(200);
    l_Isin                        VARCHAR2(12);
    l_Ent_Email_Id                VARCHAR2(100);
    l_Buy_Units                   NUMBER(24,4);
    l_Buy_Units_Display           VARCHAR2(30);
    l_Sell_Units                  NUMBER(24,4);
    l_Sell_Units_Display          VARCHAR2(30);
    l_Buy_Nav                     NUMBER(24,4);
    l_Sell_Nav                    NUMBER(24,4);
    l_Buy_Commission              NUMBER(24,4);
    l_Sell_Commission             NUMBER(24,4);
    l_Buy_Amt                     NUMBER(24,4);
    l_Buy_Amt_Display             VARCHAR2(30);
    l_Sell_Amt                    NUMBER(24,4);
    l_Sell_Amt_Display            VARCHAR2(30);
    l_Broker_Id                   VARCHAR2(30);
    l_Ent_Phone_No                VARCHAR2(30);
    l_Erd_Pan_No                  VARCHAR2(30);
    l_Net_Buy_Amt                 NUMBER(24,4);
    l_Net_Buy_Amt_Display         VARCHAR2(30);
    l_Net_Sell_Amt                NUMBER(24,4);
    l_Net_Sell_Amt_Display        VARCHAR2(30);
    l_Order_Time                  VARCHAR2(30);
    l_Sett_Type                   VARCHAR2(30);
    l_Folio_No                    VARCHAR2(30);
    l_Submit_Cmd_Ret_Val          NUMBER;
    l_Broker_Sebi_Reg_No          VARCHAR2(30);
    l_Exm_Name                    VARCHAR2(40);
    l_Brokerage                   NUMBER(15,4);
    l_Service_Tax                 NUMBER(15,4);
    l_Security_Txn_Tax            NUMBER(15,4);
    l_Edu_Cess                    NUMBER(15,4);
    l_High_Edu_Cess               NUMBER(15,4);
    l_Total                       NUMBER(20,4);
    l_Header                      BOOLEAN := TRUE;
    l_Net_Total                   NUMBER(20,4):=0;
    l_Net_Total_Display           VARCHAR2(30);
    Ex_Submit_Cmd                 EXCEPTION;
    l_Dl_Name                     VARCHAR2(100);
    l_Dl_Address_1                VARCHAR2(1000);
    l_Dl_Address_2                VARCHAR2(1000);
    l_Dl_Phone_No                 VARCHAR2(1000);
    l_Dl_Fax_No                   VARCHAR2(1000);
    l_Cpm_Id                      VARCHAR2(30);
    l_Cpm_Desc                    VARCHAR2(100);
    l_Cpm_Address                 VARCHAR2(1000);
    l_Cpm_Email_Id                VARCHAR2(500);
    l_Cpm_Compliance_Name         VARCHAR2(200);
    l_Cpm_Compliance_Tel_No       VARCHAR2(50);
    l_Cpm_Compliance_Email        VARCHAR2(200);
    l_Broker_Pan_No               VARCHAR2(10);
    l_Eam_Arn_No                  VARCHAR2(10);
    l_Buy_Phy_Demat               VARCHAR2(15);
    l_Sell_Phy_Demat              VARCHAR2(15);
    l_Contract_No                 VARCHAR2(30);
    l_Last_Contract_No            VARCHAR2(30);
    l_Net_Service_Tax             NUMBER(15,4);
    l_Net_Security_Txn_Tax        NUMBER(15,4);

    l_Gen_New_File                BOOLEAN;
    l_CN_Cnt                      NUMBER(4);
    l_Total_CN_In_File            NUMBER(4);

    l_Line_Count                  NUMBER(4) := 0;
    l_Line_Count_1                NUMBER(4) ;
    l_Line_Count_2                NUMBER(4) ;
    l_Line_Count_break            NUMBER(4) := -1;
    l_Auth_Signatory              VARCHAR2(800)  ;
    l_Mkdir_Path                  VARCHAR2(500)  ;
    l_nse_sebi_no                 Varchar2(20);
    l_bse_sebi_no                 Varchar2(20);
    l_str                         VARCHAR2(2500);
    l_Place                       VARCHAR2(20) := 'Mumbai';
    l_Company_Dtls                VARCHAR2(2) := '01';
    l_Client_Dtls                 VARCHAR2(2) := '02';
    l_Settlement_Dtls             VARCHAR2(2) := '03';
    l_Order_Dtls                  VARCHAR2(2) := '04';
    l_Order_Summary_Dtls          VARCHAR2(2) := '05';
    l_Signatory_Dtls              VARCHAR2(2) := '06';


    CURSOR c_Client_Order IS
      SELECT  Client_Id,
              Order_No,
              Order_Date,
              Order_Time,
              Sett_Type,
              Stc_No,
              Decode(Order_No,NULL,NULL,Scheme_Id) Scheme_Id,
              Scheme_Desc,
              Isin,
              Folio_No,
              Contract_No,
              Buy_Units,
              Buy_Phy_Demat,
              Buy_Nav,
              Buy_Commission,
              SUM(Buy_Amt) Buy_Amt,
              Sell_Units,
              Sell_Phy_Demat,
              Sell_Nav,
              Sell_Commission,
              SUM(Sell_Amt) Sell_Amt,
              Brokerage,
              Service_Tax,
              Security_Txn_Tax,
              Edu_Tax,
              Hdu_Tax,
              Total
      FROM (SELECT Decode(e.ent_category,'NRI',e.ent_mf_ucc_code ,m.Ent_Id) Client_Id,
                   m.Order_No            Order_No,
                   m.Order_Date          Order_Date,
                   m.Order_Time          Order_Time,
                   m.Settlement_Type     Sett_Type,
                   m.Stc_No              Stc_No,
                   m.Security_Id         Scheme_Id,
                   s.Msm_Scheme_Desc     Scheme_Desc,
                   m.Isin                Isin,
                   m.Folio_No            Folio_No,
                   m.Contract_No         Contract_No,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Quantity),'99999999999999999990D9999'))             Buy_Units,
                   Decode(m.Buy_Sell_Flg,'P','Demat',NULL)                                                      Buy_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Alloted_Nav),'99999999999999999990D9999'))          Buy_Nav,
                   Decode(m.Buy_Sell_Flg,'P', Nvl(c.Brokerage, 0) ,NULL)                                        Buy_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',(m.Amount+ Nvl(c.Brokerage, 0))),'99999999999999999990D99'))Buy_Amt,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Quantity),'99999999999999999990D9999'))             Sell_Units,
                   Decode(m.Buy_Sell_Flg,'R','Demat',NULL)                                                      Sell_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Alloted_Nav),'99999999999999999990D9999'))          Sell_Nav,
                   Decode(m.Buy_Sell_Flg,'R',Nvl(c.Brokerage, 0) ,NULL)                                         Sell_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',-1*(Round(m.Quantity*m.Alloted_Nav,2)- Nvl(c.Brokerage,0))),'99999999999999999990D99')) Sell_Amt,
                   Nvl(c.Brokerage,0)                                                                           Brokerage,
                   Nvl(c.Service_Tax,0) + Nvl(c.Edu_Cess,0) + Nvl(c.High_Edu_Cess,0)                            Service_Tax,
                   Nvl(C.Security_Txn_Tax,0)                                                                    Security_Txn_Tax,
                   Nvl(c.Edu_Cess,0)                                                                            Edu_Tax,
                   Nvl(c.High_Edu_Cess,0)                                                                       Hdu_Tax,
                   Decode(m.Buy_Sell_Flg,'P',m.Amount + (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)),
                                         'R',-1*(Round(m.Quantity*m.Alloted_Nav,2) - (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0))))          Total
            FROM   Mfss_Trades m,
                   Mfss_Contract_Note c,
                   Mfd_Scheme_Master s,
                   Entity_Master e
            WHERE  m.Order_Date BETWEEN Nvl(p_From_Date,Order_Date) AND Nvl(p_To_Date,Order_Date)
            AND    m.Order_Date BETWEEN s.Msm_From_Date AND Nvl(s.Msm_To_Date,m.Order_Date)
            AND    m.Order_Date                = c.Transaction_Date
            AND    m.Exm_Id                    = Nvl(p_Exch_Id, m.Exm_Id)
            AND    m.Exm_Id                    = c.Exm_Id
            AND    m.Ent_Id    BETWEEN Nvl(p_From_Ent_Id,m.Ent_Id) AND Nvl(p_To_Ent_Id,m.Ent_Id)
            AND    m.Ent_Id                    = c.Ent_Id
            AND    m.Order_No                  = c.Order_No
            AND    m.Security_Id               = c.Amc_Scheme_Code
            AND    m.Security_Id               = s.Msm_Scheme_Id
            AND    m.Contract_No               = c.Cn_No
            AND    m.Ent_Id                    = e.Ent_Id
            AND    s.Msm_Record_Status         = 'A'
            AND    Trade_Status                = 'A'
            AND    Order_Status                = 'VALID'
            AND    Nvl(Confirmation_Flag,'N')  = 'Y'
            AND    c.Status                    = 'I'
            AND    e.Ent_Dispatch_Mode         = Nvl(P_Dispatch_Mode, e.Ent_Dispatch_Mode)
            AND    Nvl(P_Bounced_Flag,'N')    = 'N'
            ORDER BY 1,11,3,2)
      GROUP BY GROUPING SETS (( Order_Date,
                                Client_Id,
                                Order_No,
                                Order_Time,
                                Sett_Type,
                                Stc_No,
                                Scheme_Id,
                                Scheme_Desc,
                                Isin,
                                Folio_No,
                                Contract_No,
                                Buy_Units,
                                Buy_Phy_Demat,
                                Buy_Nav,
                                Buy_Commission,
                                Buy_Amt,
                                Sell_Units,
                                Sell_Phy_Demat,
                                Sell_Nav,
                                Sell_Commission,
                                Sell_Amt,
                                Brokerage,
                                Service_Tax,
                                Security_Txn_Tax,
                                Edu_Tax,
                                Hdu_Tax,
                                Total),(Scheme_Id,Order_Date,Client_Id,Service_Tax,Security_Txn_Tax,Contract_No))
      UNION ALL
      SELECT  Client_Id,
              Order_No,
              Order_Date,
              Order_Time,
              Sett_Type,
              Stc_No,
              Decode(Order_No,NULL,NULL,Scheme_Id) Scheme_Id,
              Scheme_Desc,
              Isin,
              Folio_No,
              Contract_No,
              Buy_Units,
              Buy_Phy_Demat,
              Buy_Nav,
              Buy_Commission,
              SUM(Buy_Amt) Buy_Amt,
              Sell_Units,
              Sell_Phy_Demat,
              Sell_Nav,
              Sell_Commission,
              SUM(Sell_Amt) Sell_Amt,
              Brokerage,
              Service_Tax,
              Security_Txn_Tax,
              Edu_Tax,
              Hdu_Tax,
              Total
      FROM (SELECT Decode(e.ent_category,'NRI',e.ent_mf_ucc_code ,m.Ent_Id)   Client_Id,
                   m.Order_No            Order_No,
                   m.Order_Date          Order_Date,
                   m.Order_Time          Order_Time,
                   m.Settlement_Type     Sett_Type,
                   m.Stc_No              Stc_No,
                   m.Security_Id         Scheme_Id,
                   s.Msm_Scheme_Desc     Scheme_Desc,
                   m.Isin                Isin,
                   m.Folio_No            Folio_No,
                   m.Contract_No         Contract_No,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Quantity),'99999999999999999990D9999'))             Buy_Units,
                   Decode(m.Buy_Sell_Flg,'P','Demat',NULL)                                                      Buy_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',m.Alloted_Nav),'99999999999999999990D9999'))          Buy_Nav,
                   Decode(m.Buy_Sell_Flg,'P', Nvl(c.Brokerage, 0) ,NULL)                                        Buy_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'P',(m.Amount+ Nvl(c.Brokerage, 0))),'99999999999999999990D99'))Buy_Amt,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Quantity),'99999999999999999990D9999'))             Sell_Units,
                   Decode(m.Buy_Sell_Flg,'R','Demat',NULL)                                                      Sell_Phy_Demat,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',m.Alloted_Nav),'99999999999999999990D9999'))          Sell_Nav,
                   Decode(m.Buy_Sell_Flg,'R',Nvl(c.Brokerage, 0) ,NULL)                                         Sell_Commission,
                   TRIM(To_Char(Decode(m.Buy_Sell_Flg,'R',-1*(Round(m.Quantity*m.Alloted_Nav,2)- Nvl(c.Brokerage,0))),'99999999999999999990D99')) Sell_Amt,
                   Nvl(c.Brokerage,0)                                                                           Brokerage,
                   Nvl(c.Service_Tax,0) + Nvl(c.Edu_Cess,0) + Nvl(c.High_Edu_Cess,0)                            Service_Tax,
                   Nvl(C.Security_Txn_Tax,0)                                                                    Security_Txn_Tax,
                   Nvl(c.Edu_Cess,0)                                                                            Edu_Tax,
                   Nvl(c.High_Edu_Cess,0)                                                                       Hdu_Tax,
                   Decode(m.Buy_Sell_Flg,'P',m.Amount + (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0)),
                                         'R',-1*(Round(m.Quantity*m.Alloted_Nav,2) - (Nvl(c.Brokerage, 0) + Nvl(c.Service_Tax, 0) +
                                                        Nvl(c.Edu_Cess, 0) + Nvl(c.High_Edu_Cess, 0)+ Nvl(C.Security_Txn_Tax,0))))          Total
            FROM   Mfss_Trades m,
                   Mfss_Contract_Note c,
                   Mfd_Scheme_Master s,
                   Entity_Master e,
                   Bounced_Contract_Notes Bcn
            WHERE  m.Order_Date BETWEEN s.Msm_From_Date AND Nvl(s.Msm_To_Date,m.Order_Date)
            AND    m.Order_Date                = c.Transaction_Date
            AND    m.Exm_Id                    = Nvl(p_Exch_Id, m.Exm_Id)
            AND    m.Exm_Id                    = c.Exm_Id
            AND    m.Ent_Id     BETWEEN Nvl(p_From_Ent_Id,m.Ent_Id) AND Nvl(p_To_Ent_Id,m.Ent_Id)
            AND    m.Ent_Id                    = c.Ent_Id
            AND    m.Order_No                  = c.Order_No
            AND    m.Security_Id               = c.Amc_Scheme_Code
            AND    m.Security_Id               = s.Msm_Scheme_Id
            AND    m.Contract_No               = c.Cn_No
            AND    m.Ent_Id                    = e.Ent_Id
            AND    s.Msm_Record_Status         = 'A'
            AND    Trade_Status                = 'A'
            AND    Order_Status                = 'VALID'
            AND    Nvl(Confirmation_Flag,'N')  = 'Y'
            AND    c.Status                    = 'I'
            AND    Bcn.Bcn_Date                = C.Transaction_Date
            AND    Bcn.Bcn_Ent_Id              = C.Ent_Id
            AND    Bcn.Bcn_Exm_Id              = C.Exm_Id
            AND    Bcn.Bcn_Seg_Id              = 'M'
            AND    Bcn.Bcn_Cn_No               = C.Cn_No
            AND    Trunc(Bcn.Bcn_Bounced_Dt_Time) BETWEEN Nvl(p_From_Date, Trunc(Bcn.Bcn_Bounced_Dt_Time))
                     AND Nvl(p_To_Date, Trunc(Bcn.Bcn_Bounced_Dt_Time))
            AND    e.Ent_Dispatch_Mode         = Nvl(P_Dispatch_Mode, e.Ent_Dispatch_Mode)
            AND    Nvl(P_Bounced_Flag,'N')    = 'Y'
            ORDER BY 1,11,3,2)
      GROUP BY GROUPING SETS (( Order_Date,
                                Client_Id,
                                Order_No,
                                Order_Time,
                                Sett_Type,
                                Stc_No,
                                Scheme_Id,
                                Scheme_Desc,
                                Isin,
                                Folio_No,
                                Contract_No,
                                Buy_Units,
                                Buy_Phy_Demat,
                                Buy_Nav,
                                Buy_Commission,
                                Buy_Amt,
                                Sell_Units,
                                Sell_Phy_Demat,
                                Sell_Nav,
                                Sell_Commission,
                                Sell_Amt,
                                Brokerage,
                                Service_Tax,
                                Security_Txn_Tax,
                                Edu_Tax,
                                Hdu_Tax,
                                Total),(Scheme_Id,Order_Date,Client_Id,Service_Tax,Security_Txn_Tax,Contract_No));

    /*PROCEDURE p_Get_Class_Html IS
    BEGIN
      g_Html  := '<html><head><title>Transaction Confirmation Note</title> <style type="text/css">#left { text-align:left}#right{ text-align:right}#center{ text-align:center}//a
                  {  text-decoration: none}////A:active {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9; FONT-FAMILY: Arial,Helvetica,
                  sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:link {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9; FONT-FAMILY:
                  Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:visited {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #130FC9;
                  FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A:hover {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR:
                  #130FC9; FONT-FAMILY: Arial,Helvetica, sans-serif;  TEXT-DECORATION: underline;cursor:hand;}////A.cellLink:active {FONT-WEIGHT: bold;
                  FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:link
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:visited
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #EFEFEF; FONT-FAMILY: Arial,Helvetica, sans-serif; TEXT-DECORATION: none;cursor:hand;}////A.cellLink:hover
                  {FONT-WEIGHT: bold; FONT-SIZE: 8pt; COLOR: #FF0000; FONT-FAMILY: Arial,Helvetica, sans-serif;  TEXT-DECORATION: underline;cursor:hand;}.
                  BODY {margin-left:0px;margin-top:0px;background:#FFFEFF}</style>';

      g_Html2 := '<style type = "text/css">th            {color: white;background-color: #214896;text-align: left;padding: 4px;font-size: 12px;font-weight: bold;
                  font-family: sans-serif;margin-bottom:12px;margin-top:0px;}BODY          {margin-left:0px;margin-top:0px;background:#FFFFFF;}
                              BODYMenu        {margin-left:0px;margin-top:0px;background:#FFFFFF;}</style>';

      g_Html3 := '<style type = "text/css">.ctrNoteHdrMainTable  {color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden;} .ctrNoteHdrMainTableW{color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden; WORD-BREAK:BREAK-ALL;} .ctrNoteHdrMainTable1
                {color: =#FFFFCC color: =#FFFFCC text-align: = center visibility: hidden;border-top: 1px solid #95969A;  border-right: 0px solid #95969A; }.rSttHdr
                {FONT-SIZE: 11px;COLOR: #FFFFFF;FONT-FAMILY: Verdana;FONT-WEIGHT: bold;BACKGROUND-COLOR: 22488A;TEXT-ALIGN: left border-bottom: 1px solid #95969A;border-left: 1px solid #95969A;}.rCtrHdr1
                {FONT-SIZE: 11px;COLOR: #333333;FONT-FAMILY: Verdana;FONT-WEIGHT: bold;BACKGROUND-COLOR: #D5D7E6;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-left: 1px solid #95969A;}.rCtrNoteEvenRow
                {FONT-SIZE: 10px; COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: #D5E2EE;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; } .rCtrNoteOddRow
                {FONT-SIZE: 10px;COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: #F8F9FE;TEXT-ALIGN: left border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; } .borderclass
                {border-bottom: 1px solid #95969A;border-right: 1px solid #95969A;}.borderclass1      {border-bottom: 1px solid #95969A;border-left: 1px solid #95969A;border-top: 1px solid #95969A;}.borderclass2
                {border-bottom: 1px solid #95969A;border-right: 1px solid #95969A;border-left: 1px solid #95969A;border-top: 1px solid #95969A;}.rDetail        { FONT-SIZE: 10px;';

      g_Html4 := 'COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: white;TEXT-ALIGN: left border-right: 1px solid #95969A;border-bottom: 1px solid #95969A; } .rDetail2
                { FONT-SIZE: 14px;COLOR: #333333;FONT-FAMILY: Verdana;BACKGROUND-COLOR: white;TEXT-ALIGN: left border-right: 1px solid #95969A;border-bottom: 1px solid #95969A; } .rHeader
                {font-weight: bold;font-size: 9pt;color: black;font-family: Times New Roman;background-color: white;text-align: center } .textDataShowHDFC    {font-family:
                Arial, Helvetica, sans-serif;color:#FF0000;text-align:left;font-weight: bold;font-size: 24pt;}.textDataShowBlack  {font-family:  Arial, Helvetica, sans-serif;color:black;text-align:left;font-size: 8pt;
                border-bottom: 1px solid #95969A; border-right: 1px solid #95969A; }.textDataShowBlack2  {font-family:  "Arial Black", Gadget, sans-serif;color:black;text-align:left;font-size: 11pt;}.rSTTDetail  {font-family:  Times New Roman,
                Helvetica, sans-serif;font-weight:bold; color:black;text-align:left;font-size: 13pt;}</style>
                <style>.break { page-break-before: always; }</style>
                </head><body bgcolor=white>';
    END p_Get_Class_Html;*/

    PROCEDURE P_Print_Header IS
    BEGIN
    IF l_Line_Count_break = -1 THEN
      l_Net_Total            := 0;
      l_Net_Buy_Amt          := 0;
      l_Net_Sell_Amt         := 0;
      l_Net_Service_Tax      := 0;
      l_Net_Security_Txn_Tax := 0;
      l_Start_Time           := SYSDATE;
    END IF;

      p_Ret_Msg := ' Selecting address details for Client <'||l_Ent_Id||'>';
      SELECT Ent_Name,                               Ent_Exch_Client_Id,             Ent_Address_Line_1,
             Ent_Address_Line_2,                     Ent_Address_Line_3,             Ent_Address_Line_4,
             Ent_Address_Line_5,                     Ent_Address_Line_6,             Ent_Address_Line_7,
             Nvl(Ent_Phone_No_1,Ent_Phone_No_2),     Erd_Pan_No,                     End_Email_Id||','
      INTO   l_Ent_Name,                             l_Ent_Exch_Client_Id,           l_Ent_Address_Line_1,
             l_Ent_Address_Line_2,                   l_Ent_Address_Line_3,           l_Ent_Address_Line_4,
             l_Ent_Address_Line_5,                   l_Ent_Address_Line_6,           l_Ent_Address_Line_7,
             l_Ent_Phone_No,                         l_Erd_Pan_No,                   l_Ent_Email_Id
      FROM   Entity_Master,
             Entity_Registration_Details,
             Entity_Details
      WHERE  Ent_Id           = Erd_Ent_Id
      AND    Ent_Id           = End_Id
      AND    Ent_Id           = l_Ent_Id
      AND    End_Status       = 'A'
      AND    End_Default_Flag = 'Y';

      p_Ret_Msg := ' Selecting dealer''s address details for Client <'||l_Ent_Id||'>';
      SELECT Ent_Name,
             Nvl(Ent_Address_Line_1,'---') ||', '||
             Nvl(Ent_Address_Line_2,'---') ||', '||
             Nvl(Ent_Address_Line_3,'---') ||', '||
             Nvl(Ent_Address_Line_4,'---') Addr_1,
             Nvl(Ent_Address_Line_5,'---') ||', '||
             Nvl(Ent_Address_Line_6,'---') ||', '||
             Nvl(Ent_Address_Line_7,'---') Addr_2,
             Nvl(Ent_Phone_No_1,'---')     ||'/'||
             Nvl(Ent_Phone_No_2,'---')     Phone,
             Nvl(Ent_Fax_No_1,'---')       ||'/'||
             Nvl(Ent_Fax_No_2,'---')       Fax
      INTO   l_Dl_Name,
             l_Dl_Address_1,
             l_Dl_Address_2,
             l_Dl_Phone_No,
             l_Dl_Fax_No
      FROM   Entity_Master
      WHERE  Ent_Id IN (SELECT Ent_Ctrl_Id
                        FROM   Entity_Master
                        WHERE  Ent_Id IN (SELECT Ent_Mfss_Ctrl_Id
                                          FROM   Entity_Master
                                          WHERE  Ent_Id = l_Ent_Id));


      SELECT Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_1',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_2',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_3',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_4',Rv_High_Value))||', '||
             Max(decode(Rv_Low_Value,'AUTHORIZED_SIGN_5',Rv_High_Value))
      INTO   l_Auth_Signatory
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain    = 'COMMON_CONTRACT_NOTE'
      AND    Rv_Low_Value LIKE 'AUTHORIZED_SIGN%';

      p_Ret_Msg := ' Generating new file for Client <'||l_Ent_Id||'>';
      IF l_Gen_New_File = TRUE THEN
        SELECT To_Char(l_Pam_Curr_Dt,'RRRRMM')||Lpad(Rep_Gen_Seq.NEXTVAL,8,0)
        INTO   l_Rep_Gen_Seq
        FROM   Dual;

        l_Count_Reports := l_Count_Reports + 1;

        p_Ret_Msg := 'Opening file on server path <'||l_Mf_Order_Cnfm_Path||'><'||l_Fold_Name||'><'||l_File_Name||'>';
        IF P_Print_Flag = 'Y' THEN
          p_Ret_Msg := p_Ret_Msg ||'-'|| '1';
          l_File_Name := 'MF_ORDER_CONFIRMATION_'||To_Char(l_Order_Date,'DDMONRRRR')||'_'||l_Rep_Gen_Seq||'.csv';
        ELSE
          p_Ret_Msg := p_Ret_Msg ||'-'|| '2';
          --l_File_Name := l_Contract_No||'_'||l_Ent_Id||'_'||P_Exch_Id||'_MF_ORDER_CONFIRMATION_'||To_Char(l_Order_Date,'DDMONRRRR')||'.csv';
          l_File_Name := l_Contract_No||'_'||l_Ent_Id||'_'||To_Char(l_Order_Date,'DDMONRRRR')||'.csv';
        END IF;
        p_Ret_Msg := p_Ret_Msg ||'-'|| '3-'||l_Mf_Order_Cnfm_Path||'-'||l_Fold_Name||'-'||l_File_Name;
        l_File_Ptr := Utl_File.Fopen(l_Mf_Order_Cnfm_Path || l_Fold_Name,l_File_Name,'W',32767);
        p_Ret_Msg := p_Ret_Msg ||'-'|| '4';

        p_Ret_Msg := ' Inserting data for Client <'||l_Ent_Id||'> in Rep_Gen ';
        INSERT INTO Rep_Gen
          (Rg_Seq,                  Rg_File_Name,            Rg_Status,
           Rg_Act_Gen_Dt,           Rg_Start_Time,           Rg_Remarks,
           Rg_Creat_Dt,             Rg_Creat_By,             Rg_Rep_Id,
           Rg_Exchange,             Rg_Segment,              Rg_Ent_Id,
           Rg_Comm_Channel,         Rg_End_Time,             Rg_Gen_Dt,
           Rg_Rgm_Seq_No,           Rg_Attribute,            Rg_Attribute_1)
        VALUES
          (l_Rep_Gen_Seq,           l_Mf_Order_Cnfm_Path||l_Fold_Name||'/'||l_File_Name,  'R',
           l_Pam_Curr_Dt,           l_Start_Time,                                         'MF Order Confirmation Note for Client '||l_Ent_Id,
           SYSDATE,                 USER,                                                 l_Prg_Id,
           P_Exch_Id,               'M',                                                  l_Ent_Id,
           'P',                     l_End_Time,                                           l_Pam_Curr_Dt,
           l_Web_Seq_No,            l_Ent_Email_Id,                                       'Mutual Fund Order Confirmation Note');

       /* p_Get_Class_Html;
        Utl_File.Put_Line(l_File_Ptr, g_Html);
        Utl_File.Put_Line(l_File_Ptr, g_Html2);
        Utl_File.Put_Line(l_File_Ptr, g_Html3);
        Utl_File.Put_Line(l_File_Ptr, g_Html4);*/
      END IF;

     /* Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable" id=mytable cellspacing=0 cellpadding=2 border=0  width = ''100%''> ');
      IF P_Print_Flag = 'Y' THEN
         Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
         Utl_File.Put_Line(l_File_Ptr,'<td align = Right colspan = 2 nowrap><img src="HDFC_Logo.jpg" border="0" class = "textDataShowBlack2" alt="HDFC Securities Ltd." width="200" height="35" ></td>');
         Utl_File.Put_Line(l_File_Ptr,'</tr>');
      END IF;
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
      Utl_File.Put_Line(l_File_Ptr,'  <td align = left colspan = 2 nowrap>TRANSACTION CONFIRMATION NOTE<br>(Mutual Fund Segment of '||p_Exch_Id||')<hr color = ''#333333''></hr></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rheader > ');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = "textDataShowHDFC" colspan = 2 nowrap>'||l_Cpm_Desc||'</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail > ');
      Utl_File.Put_Line(l_File_Ptr,'<td align = left colspan = 2 nowrap><br><b>Member of Bombay stock Exchange(BSE Ltd), National stock Exchange(NSE)
                                    </b><br><b>Sebi Registration Nos
                                    </b><br><b>BSE: CM: '||l_bse_sebi_no||' FO: INF011109437
                                    </b><br><b>NSE: CM: '||l_Nse_sebi_no||' FO: INF231109431 CUR: INE231109431 </b>
                                    <br><b>Registered & Corporate Office : </b>'||l_Cpm_Address||'  CIN - U67120MH2000PLC152193
                                    <br> Tel.No. : 30753400 Fax No. : 30753435
                                    <br><b>Customer Care : </b>HDFC Securities Ltd, 2nd Floor, Trade Globe, Kondivita Junction,Andheri Kurla Road, Andheri(E),Mumbai - 400 059.<br>Tel. No. : 39019400 (prefix local code) Fax No. : 28346690 Website : www.hdfcsec.com ;
                                    Email : '||l_Cpm_Email_Id||', For complaints:services@hdfcsec.com<br> <B>Mumbai Dealing :</B> 33553366 (prefix local code only if calling from mobile).eg for mobile - (0 + local area code + 33553366); for locations with 3 digit local std code the no is
                                    <br> 33553366 e.g 044 33553366 ; for locations with 4 digit local std code the no is 3355336 e.g 0484 3355336. <br>
                                    <b>Dealing Office Address : </b>'||l_Dl_Name||','||l_Dl_Address_1||'<br> '||l_Dl_Address_2||
                                    ' Tel. No. :'||l_Dl_Phone_No||' Fax No. :'||l_Dl_Fax_No||'<br><b>Compliance Officer details : Name: </b>'||l_Cpm_Compliance_Name||',<b> Tel no: </b>'||l_Cpm_Compliance_Tel_No||',
                                    <b> Email Id: </b>'||l_Cpm_Compliance_Email||'<br><b>SERVICE TAX NO. : ;AAACH8215RST001</b><br><b>ARN NO. : </b>'||l_Eam_Arn_No||'</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');

      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail colspan = 5> ');
      Utl_File.Put_Line(l_File_Ptr,'<td><br>Trading & Unique Client Code: '||l_Ent_Exch_Client_Id||'<br>'||
                                    l_Ent_Name||'<br>'||
                                    l_Ent_Address_Line_1||'<br>   '||
                                    l_Ent_Address_Line_2||'<br>   '||
                                    l_Ent_Address_Line_3||'<br>   '||
                                    l_Ent_Address_Line_4||'<br>   '||
                                    l_Ent_Address_Line_5||'<br>   '||
                                    l_Ent_Address_Line_6||'<br>   '||
                                    l_Ent_Address_Line_7||'<br>   '||
                                    'Ph: '||l_Ent_Phone_No||';<br>'||
                                    'Pan No: '||l_Erd_Pan_No||'</td> ');

      Utl_File.Put_Line(l_File_Ptr,'<td> <table id=mytable cellspacing=0 cellpadding=2 border=0 class = "ctrNoteHdrMainTable" align=center> ');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Sett No: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||l_Sett_No||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Transaction Date: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||To_Char(l_Order_Date,'DD-MON-RRRR')||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'    <tr class=rDetail>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >Transaction Confirmation note no: </td>');
      Utl_File.Put_Line(l_File_Ptr,'      <td nowrap >'||l_Contract_No||';</td>');
      Utl_File.Put_Line(l_File_Ptr,'    </tr>');
      Utl_File.Put_Line(l_File_Ptr,'  </table> ');
      Utl_File.Put_Line(l_File_Ptr,'</td> ');
      Utl_File.Put_Line(l_File_Ptr,'</tr> ');
      Utl_File.Put_Line(l_File_Ptr,'</table><br>');

      Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1"  align=center width = ''100%''>
                                    <tr class = rDetail >
                                    <hr color = ''#333333''></hr>
                                    <td class = "borderclass" align = left colspan = 19>Dear Sir/Madam,<br>
                                    I/we have on this day done by your order and on your account entered the following orders in the Mutual Fund system for the following requests for subscription and / or request for redemption.
                                    </td></tr><tr class = rheader></tr></table>  ');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTableW" id=mytable cellspacing=0 cellpadding=0 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rSttHdr>');
      Utl_File.Put_Line(l_File_Ptr,'  <td align = left class = borderclass colspan = 19>;</td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrHdr1>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = ''right''>;</td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass align = center colspan = 5 align = ''right''><b>"Units Bought For You"*</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass align = center colspan = 5 align = ''right''><b>"Units Sold For You"*</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrHdr1>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Order <br>No.</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Order <br>Time</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Sett. <br>Type</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Scheme <br>Id</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>ISIN </b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = center><b>Name of <br>the<br>Mutual<br>Fund<br>Scheme</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Folio No</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>No of <br>Units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Physical <br>/Demat units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Rate<br>Per<br>Unit<br>(NAV)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Commission<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Total <br>Amount<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>No of <br>Units</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Physical <br>units/Demat</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Rate<br>Per<br>Unit<br>(NAV)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><br>Commission<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = center><b>Total<br>Amount<br>(Rs.)</b></td>');
      Utl_File.Put_Line(l_File_Ptr,'</tr>');*/
      l_str := l_Company_Dtls           || '~|~' ||
               l_bse_sebi_no            || '~|~' ||
               l_nse_sebi_no            || '~|~' ||
               l_Cpm_Address            || '~|~' ||
               l_Cpm_Email_Id           || '~|~' ||
               l_Dl_Name                || '~|~' ||
               l_Dl_Address_1           || '~|~' ||
               l_Dl_Address_2           || '~|~' ||
               l_Dl_Phone_No            || '~|~' ||
               l_Dl_Fax_No              || '~|~' ||
               l_Cpm_Compliance_Name    || '~|~' ||
               l_Cpm_Compliance_Tel_No  || '~|~' ||
               l_Cpm_Compliance_Email   || '~|~' ||
               l_Eam_Arn_No;
      Utl_File.Put_Line(l_File_Ptr,l_str);

      l_str := l_Client_Dtls            || '~|~' ||
               l_Ent_Exch_Client_Id     || '~|~' ||
               l_Ent_Name               || '~|~' ||
               l_Ent_Address_Line_1     || '~|~' ||
               l_Ent_Address_Line_2     || '~|~' ||
               l_Ent_Address_Line_3     || '~|~' ||
               l_Ent_Address_Line_4     || '~|~' ||
               l_Ent_Address_Line_5     || '~|~' ||
               l_Ent_Address_Line_6     || '~|~' ||
               l_Ent_Address_Line_7     || '~|~' ||
               l_Ent_Phone_No           || '~|~' ||
               l_Erd_Pan_No;

      Utl_File.Put_Line(l_File_Ptr,l_str);

      l_str := l_Settlement_Dtls       || '~|~' ||
               l_Sett_No               || '~|~' ||
               l_Order_Date            || '~|~' ||
               l_Contract_No;

      Utl_File.Put_Line(l_File_Ptr,l_str);

    END P_Print_Header;

    PROCEDURE P_Print_Footer IS
    BEGIN
      IF l_Net_Total > 0 THEN

        IF l_Net_Service_Tax = 0 THEN
          l_Net_Service_Tax := NULL;
        END IF;

        IF l_Net_Buy_Amt = 0 THEN
          l_Net_Buy_Amt_Display := NULL;
        ELSE
          l_Net_Buy_Amt_Display :=  To_Char(l_Net_Buy_Amt,'99999999999999999999D99');
        END IF;

        IF abs(l_Net_Sell_Amt) = 0 THEN
          l_Net_Sell_Amt_Display := NULL;
        ELSE
          l_Net_Sell_Amt := abs(l_Net_Sell_Amt);
          l_Net_Sell_Amt_Display :=  To_Char(l_Net_Sell_Amt,'99999999999999999999D99');
        END IF;

        --l_Net_Total := abs(l_Net_Total);
        l_Net_Total_Display := To_Char(l_Net_Total,'99999999999999999999D99');

        /*Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Bought/Sold Value:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Sell_Amt_Display||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Service Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Service_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Security Transaction Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Security_Txn_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Due From You:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Total_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr></table>');*/
        l_str := l_Order_Summary_Dtls                                              ||'~|~'||
                 NVL(l_Net_Buy_Amt_Display,0)||'/'||NVL(l_Net_Sell_Amt_Display,0)  ||'~|~'||
                 NVL(l_Net_Service_Tax,0)                                          ||'~|~'||
                 NVL(l_Net_Security_Txn_Tax,0)                                     ||'~|~'||
                 NVL(l_Net_Total_Display,0);

        Utl_File.Put_Line(l_File_Ptr,l_str);
      ELSE

        IF l_Net_Service_Tax = 0 THEN
          l_Net_Service_Tax := NULL;
        END IF;

        IF l_Net_Buy_Amt = 0 THEN
          l_Net_Buy_Amt_Display := NULL;
        ELSE
          l_Net_Buy_Amt_Display :=  To_Char(l_Net_Buy_Amt,'99999999999999999999D99');
        END IF;

        IF abs(l_Net_Sell_Amt) = 0 THEN
          l_Net_Sell_Amt_Display := NULL;
        ELSE
          l_Net_Sell_Amt := abs(l_Net_Sell_Amt);
          l_Net_Sell_Amt_Display :=  To_Char(l_Net_Sell_Amt,'99999999999999999999D99');
        END IF;

        --l_Net_Total := abs(l_Net_Total);
        l_Net_Total_Display := To_Char(l_Net_Total,'99999999999999999999D99');

        /*Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Bought/Sold Value:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 5 align = ''right''><b>'||l_Net_Sell_Amt_Display||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Service Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Service_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Security Transaction Tax:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Security_Txn_Tax||';</b></td>');

        Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>  ');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 9 align = "right"><b>Net Due To You:</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 10 align = ''right''><b>'||l_Net_Total_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr></table>');*/

        l_str := l_Order_Summary_Dtls                                              ||'~|~'||
                 NVL(l_Net_Buy_Amt_Display,0)||'/'||NVL(l_Net_Sell_Amt_Display,0)  ||'~|~'||
                 NVL(l_Net_Service_Tax,0)                                          ||'~|~'||
                 NVL(l_Net_Security_Txn_Tax,0)                                     ||'~|~'||
                 NVL(l_Net_Total_Display,0);

        Utl_File.Put_Line(l_File_Ptr,l_str);
      END IF;

       -- border = 0
      /*Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1" align=center width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >  <td class = "borderclass" align = left colspan = 19 nowrap><BR>You may kindly note that:
                                                                                                        <BR>*The units shall be directly delivered to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>*Redemption proceeds shall be directly paid to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>
                                                                                                        <BR>1. This memo constitutes and shall be deemed to constitute an agreement between you and me/us.</td></tr>  ');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail>   <td  colspan = 4 valign = top><BR><BR><BR><BR>Place: Mumbai<BR>Date: '||To_Char(l_Pam_Curr_Dt,'DD-MON-RRRR')||'</td>     ');
      Utl_File.Put_Line(l_File_Ptr,'           <td  colspan = 15 nowrap align="right" valign = top><BR>
                                                                                                   <BR>
                                                                                                   <BR>
                                                                                                   <BR>Yours Faithfully
                                                                                                   <br>For '||l_Cpm_Desc||'
                                                                                                   <br>
                                                                                                   <br>Authorised Signatory
                                                                                                   <br>PAN No. of Member : '||l_Broker_Pan_No||'</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable1" id=mytable colspan = 19 cellspacing=0 cellpadding=2 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >
                                       <td class = "borderclass" colspan = 19 >
                                       <B>AUTHORISED SIGNATORY:</b>'||l_Auth_Signatory||'.</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');*/

      l_str := l_Signatory_Dtls                      ||'~|~'||
               l_Place                               ||'~|~'||
               To_Char(l_Pam_Curr_Dt,'DD-MON-RRRR')  ||'~|~'||
               l_Broker_Pan_No                       ||'~|~'||
               'For'||' '||l_Cpm_Desc;

      Utl_File.Put_Line(l_File_Ptr,l_str);

      IF l_Gen_New_File = TRUE THEN
        /*Utl_File.Put_Line(l_File_Ptr,'</body></html>');*/
        Utl_File.Fclose(l_File_Ptr);

        UPDATE Rep_Gen
        SET    Rg_Status       = 'S',
               Rg_Remarks      = 'MF Order Confirmation Note Generated Successfully For '||l_Last_Ent_Id,
               Rg_End_Time     = SYSDATE,
               Rg_Last_Updt_By = USER,
               Rg_Last_Updt_Dt = SYSDATE
        WHERE  Rg_Seq          = l_Rep_Gen_Seq;

      ELSE
        /*Utl_File.Put_Line(l_File_Ptr,'<h1 class="break">;');
        Utl_File.Put_Line(l_File_Ptr,'</h1>');*/
        NULL;
      END IF;
    END P_Print_Footer;

    /*PROCEDURE P_Print_Footer_Signatory IS
    BEGIN*/
      /*Utl_File.Put_Line(l_File_Ptr,'<table id=mytable colspan = 19 cellspacing=0 cellpadding=2 class = "ctrNoteHdrMainTable1" align=center width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >  <td class = "borderclass" align = left colspan = 19 nowrap><BR>You may kindly note that:
                                                                                                        <BR>*The units shall be directly delivered to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>*Redemption proceeds shall be directly paid to you by the AMC / Mutual Fund / RTAs.
                                                                                                        <BR>
                                                                                                        <BR>1. This memo constitutes and shall be deemed to constitute an agreement between you and me/us.</td></tr>  ');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail>   <td  colspan = 4 valign = top><BR><BR><BR><BR>Place: Mumbai<BR>Date: '||To_Char(l_Pam_Curr_Dt,'DD-MON-RRRR')||'</td>     ');
      Utl_File.Put_Line(l_File_Ptr,'           <td  colspan = 15 nowrap align="right" valign = top><BR>
                                                                                                   <BR>
                                                                                                   <BR>
                                                                                                   <BR>Yours Faithfully
                                                                                                   <br>For '||l_Cpm_Desc||'
                                                                                                   <br>
                                                                                                   <br>Authorised Signatory
                                                                                                   <br>PAN No. of Member : '||l_Broker_Pan_No||'</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      Utl_File.Put_Line(l_File_Ptr,'<table class = "ctrNoteHdrMainTable1" id=mytable colspan = 19 cellspacing=0 cellpadding=2 border=0  width = ''100%''>');
      Utl_File.Put_Line(l_File_Ptr,'<tr class = rDetail >
                                       <td class = "borderclass" colspan = 19 >
                                       <B>AUTHORISED SIGNATORY:</b>'||l_Auth_Signatory||'.</td></tr>');
      Utl_File.Put_Line(l_File_Ptr,'</table>');
      IF l_Line_Count_break = 501 THEN
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
      ELSE
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
        Utl_File.Put_Line(l_File_Ptr,'<BR>;<BR>');
      END IF;*/
      --Utl_File.Put_Line(l_File_Ptr,'</center>');
      --Utl_File.Put_Line(l_File_Ptr,'</center></body></html>');
      --Utl_File.Fclose(l_File_Ptr);

    /*END P_Print_Footer_Signatory;*/

    PROCEDURE p_Order_Confirmation_Info IS
    BEGIN
      p_Ret_Msg := ' Selecting path for storing MF Order Confirmation Note';
      SELECT Decode(Substr(Rv_Low_Value,-1),'/',Rv_Low_Value,Rv_Low_Value||'/')
      INTO   l_Mf_Order_Cnfm_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MUTUAL_FUND_ORDER_CONFIRM';

      p_Ret_Msg := 'Fetching command for creating directory to write the file';
      SELECT Rv_high_value
      INTO   l_Mkdir_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain    = 'MKDIR'
      AND    Rv_Low_Value = 'MKDIR_PATH';

      p_Ret_Msg := ' Generating the sequence for MF Order Confirmation Note directory ';
      SELECT COUNT(*)
      INTO   l_Folder_Seq
      FROM   Web_Rep_Gen
      WHERE  Rg_Rep_Id = l_Prg_Id
      AND    Rg_Gen_Dt = l_Pam_Curr_Dt;

      SELECT Rv_Low_Value
      INTO   l_log_env
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = Decode('E','D','DBOS_LOG_PATH','EBOS_LOG_PATH') ;

      l_Folder_Seq := l_Folder_Seq + 1;
      l_Fold_Name  := To_Char(l_Pam_Curr_Dt,'DDMONRRRR')||'_MF_CSV_'||l_Folder_Seq||'/';

      p_Ret_Msg    := ' Creating a directory for storing MF Order Confirmation Note ';
      --l_Server_Cmd := l_Mkdir_Path ||' '|| l_Mf_Order_Cnfm_Path || l_Fold_Name;
      l_Server_Cmd := substr(l_log_env,1,instr(l_log_env,'/',-2)) || 'sh/BranchDir.sh '|| l_Mf_Order_Cnfm_Path ||' '|| l_Fold_Name;


      IF g_Count_Directory = 0 THEN
        l_Submit_Cmd_Ret_Val := Submit_Cmd('run_comm ' || l_Server_Cmd);

        IF l_Submit_Cmd_Ret_Val != 2 THEN
          RAISE Ex_Submit_Cmd;
        END IF;
      END IF;

      SELECT Web_Rep_Gen_Seq.NEXTVAL
      INTO   l_Web_Seq_No
      FROM   Dual;

      p_Ret_Msg := ' Inserting Folder path and details in Web_Rep_Gen ';
      INSERT INTO Web_Rep_Gen
        (Rg_Seq,                                          Rg_File_Name,       Rg_Status,
         Rg_Gen_Dt,                                       Rg_Act_Gen_Dt,      Rg_Start_Time,
         Rg_Remarks,                                      Rg_Creat_Dt,        Rg_Creat_By,
         Rg_Rep_Id,                                       Rg_Exchange,        Rg_Segment,
         Rg_From_Dt,                                      Rg_To_Dt,           Rg_From_Client,
         Rg_To_Client,                                    Rg_Type,            Rg_Category,
         Rg_Desc,                                         Rg_File_Path,       Rg_Log_File_Name)
      VALUES
        (l_Web_Seq_No,                                    l_Fold_Name,        'R',
         l_Pam_Curr_Dt,                                   l_Pam_Curr_Dt,      SYSDATE,
         'Generating MF Order Confirmation Note Started', SYSDATE,            USER,
         l_Prg_Id,                                        p_Exch_Id,          'M',
         p_From_Date,                                     p_To_Date,          p_From_Ent_Id,
         p_To_Ent_Id,                                     'FOLDER',           'MF_ORDER_CONFIRMATION',
         'MUTUAL FUND CONFIRMATION NOTE',                 l_Server_Cmd,       l_Log_File_Name);

      p_Ret_Msg := ' Selecting Company Details ';

        SELECT c.Cpm_Id,
               c.Cpm_Desc,
               c.Cpm_Address1||', '||c.Cpm_Address2||', '||c.Cpm_Address3,
               c.Cpm_Email_Id,
               c.Cpm_Compliance_Name,
               c.Cpm_Compliance_Tel_No,
               c.Cpm_Compliance_Email,
               Erd_Pan_No,
               Eam_Arn_No
        INTO   l_Cpm_Id,
               l_Cpm_Desc,
               l_Cpm_Address,
               l_Cpm_Email_Id,
               l_Cpm_Compliance_Name,
               l_Cpm_Compliance_Tel_No,
               l_Cpm_Compliance_Email,
               l_Broker_Pan_No,
               l_Eam_Arn_No
        FROM   Company_Master c,
               Entity_Registration_Details,
               Mfss_Exch_Admin_Master
        WHERE  Cpm_Id     = Erd_Ent_Id
        AND    Cpm_Id     = Eam_Cpd_Id
        AND    Eam_Cpd_Id = Erd_Ent_Id
        AND    Eam_Exm_Id = p_Exch_Id;

      p_Ret_Msg := ' Selecting Broker Details ';

        SELECT Decode(p_Exch_Id,'NSE','NSE MFSS','BSE','BSE Star MF'),
               Decode(p_Exch_Id,'NSE','Member code No. '||m.Eam_Broker_Id,'BSE','Clearing No. '||m.Eam_Broker_Id),
               m.Eam_Sebi_Reg_No
        INTO   l_Exm_Name,
               l_Broker_Id,
               l_Broker_Sebi_Reg_No
        FROM   Exchange_Master,
               Mfss_Exch_Admin_Master m
        WHERE  Exm_Id = m.Eam_Exm_Id
        AND    Exm_Id = p_Exch_Id;

      select Eam_sebi_reg_no
      Into l_nse_sebi_no
      from mfss_exch_admin_master t
      where t.eam_exm_id=p_Exch_Id;

      select Eam_sebi_reg_no
      Into l_Bse_sebi_no
      from mfss_exch_admin_master t
      where t.eam_exm_id=p_Exch_Id;

      g_Count_Directory := g_Count_Directory + 1;
    END p_Order_Confirmation_Info;

  BEGIN
    p_Ret_Val := 'FAIL';

    IF P_Print_Flag = 'Y' THEN
      l_Prg_Id := 'CSSWBMFOCNP';
    ELSE
      l_Prg_Id := 'CSSWBMFOCN';
    END IF;

    p_Ret_Msg := ' Performing Housekeeping Activities .';
    Std_Lib.p_Housekeeping(l_Prg_Id,           p_Exch_Id,          p_From_Date||','||p_To_Date||','||p_Exch_Id||','||p_From_Ent_Id||','||p_To_Ent_Id,
                           'E',                l_Log_File_Ptr,     l_Log_File_Name,
                           l_Process_Id);

    l_Pam_Curr_Dt := Std_lib.l_Pam_Curr_Date;

    Utl_File.Put_Line(l_Log_File_Ptr,' Working Date       : ' || l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Ptr,'');
    Utl_File.Put_Line(l_Log_File_Ptr,' Parameters Passed  : ');
    Utl_File.Put_Line(l_Log_File_Ptr,' ---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,' From Date          : ' || p_From_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,' To Date            : ' || p_To_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,' Exchange           : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' From Client        : ' || p_From_Ent_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' To Client          : ' || p_To_Ent_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,' ---------------------------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Ptr,2);

    p_Order_Confirmation_Info;

    IF P_Print_Flag = 'Y' THEN
      l_Gen_New_File := TRUE;
      l_CN_Cnt := 0;

      SELECT To_Number(RV_LOW_VALUE)
      INTO   l_Total_CN_In_File
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MF_CN_COUNT';
    ELSE
      l_Gen_New_File := TRUE;
    END IF;

    FOR i IN c_Client_Order
    LOOP
      l_Ent_Id            := i.Client_Id;
      l_Order_Date        := i.Order_Date;
      l_Order_Time        := i.Order_Time;
      l_Order_No          := i.Order_No;
      l_Sett_Type         := i.Sett_Type;
      l_Sett_No           := i.Stc_No;
      l_Scheme_Id         := i.Scheme_Id;
      l_Scheme_Desc       := i.Scheme_Desc;
      l_Isin              := i.Isin;
      l_Folio_No          := i.Folio_No;
      l_Contract_No       := i.Contract_No;
      l_Buy_Units         := i.Buy_Units;
      l_Buy_Phy_Demat     := i.Buy_Phy_Demat;
      l_Buy_Nav           := i.Buy_Nav;
      l_Buy_Commission    := i.Buy_Commission;
      l_Buy_Amt           := i.Buy_Amt;
      l_Sell_Units        := i.Sell_Units;
      l_Sell_Phy_Demat    := i.Sell_Phy_Demat;
      l_Sell_Nav          := i.Sell_Nav;
      l_Sell_Commission   := i.Sell_Commission;
      l_Sell_Amt          := i.Sell_Amt;
      l_Brokerage         := i.Brokerage;
      l_Service_Tax       := i.Service_Tax;
      l_Security_Txn_Tax  := i.Security_Txn_Tax;
      l_Edu_Cess          := i.Edu_Tax;
      l_High_Edu_Cess     := i.Hdu_Tax;
      l_Total             := i.Total;

      IF l_Rep_Gen_Seq IS NOT NULL AND (l_Ent_Id <> l_Last_Ent_Id OR l_Last_Contract_No <> l_Contract_No) THEN
        IF P_Print_Flag = 'Y' THEN
          IF l_CN_Cnt = l_Total_CN_In_File THEN
            l_CN_Cnt := 0;
            l_Gen_New_File := TRUE;
          ELSE
            l_Gen_New_File := FALSE;
          END IF;

          P_Print_Footer;
        ELSE
          P_Print_Footer;
        END IF;
      END IF;

      IF (l_Ent_Id = l_Last_Ent_Id AND l_Last_Contract_No = l_Contract_No AND l_Line_Count <> l_Line_Count_break) THEN
        l_Header := FALSE;
      ELSE
        l_Header := TRUE;
      END IF;

      IF l_Header THEN
        IF P_Print_Flag = 'Y' AND l_Line_Count <> l_Line_Count_break THEN
          l_CN_Cnt := l_CN_Cnt + 1;
        END IF;
        P_Print_Header;
        l_Line_Count_1 :=0;
        l_Line_Count_2 :=0;
        l_Line_Count   :=0;
        l_Line_Count_break :=-1;
        l_Gen_New_File := TRUE;
      END IF;

      l_Sell_Amt           := abs(l_Sell_Amt);
      l_Sell_Amt_Display   := To_Char(l_Sell_Amt,'999999999999999999D99');
      l_Buy_Amt_Display    := To_Char(l_Buy_Amt,'999999999999999999D99');
      l_Buy_Units_Display  := To_Char(l_Buy_Units,'999999999999999999D9999');
      l_Sell_Units_Display := To_Char(l_Sell_Units,'999999999999999999D9999');

      IF l_Order_No IS NOT NULL THEN
        l_Net_Total    := l_Net_Total + Nvl(l_Total,0);
        l_Net_Buy_Amt  := l_Net_Buy_Amt + Nvl(l_Buy_Amt,0);
        l_Net_Sell_Amt := l_Net_Sell_Amt + Nvl(l_Sell_Amt,0);
        l_Net_Service_Tax  := Nvl(l_Net_Service_Tax,0)  + Nvl(l_Service_Tax,0);
        l_Net_Security_Txn_Tax  := Nvl(l_Net_Security_Txn_Tax,0)  + Nvl(l_Security_Txn_Tax,0);

        /*Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteOddRow>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_Time||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Sett_Type||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Scheme_Id||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Isin||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = "left">'||l_Scheme_Desc||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Folio_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" >'||l_Buy_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Amt_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right">'||l_Sell_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Amt_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr>');*/
        l_str := l_Order_Dtls           ||'~|~'||
                 l_Order_No             ||'~|~'||
                 l_Order_Time           ||'~|~'||
                 l_Sett_Type            ||'~|~'||
                 l_Scheme_Id            ||'~|~'||
                 l_Isin                 ||'~|~'||
                 l_Scheme_Desc          ||'~|~'||
                 l_Folio_No             ||'~|~'||
                 l_Buy_Units_Display    ||'~|~'||
                 l_Buy_Phy_Demat        ||'~|~'||
                 l_Buy_Nav              ||'~|~'||
                 l_Buy_Commission       ||'~|~'||
                 l_Buy_Amt_Display      ||'~|~'||
                 l_Sell_Units_Display   ||'~|~'||
                 l_Sell_Phy_Demat       ||'~|~'||
                 l_Sell_Nav             ||'~|~'||
                 l_Sell_Commission      ||'~|~'||
                 l_Sell_Amt_Display;
      Utl_File.Put_Line(l_File_Ptr,l_str);
      l_Line_Count_1 := l_Line_Count_1 +1;

      ELSE
        /*Utl_File.Put_Line(l_File_Ptr,'<tr class = rCtrNoteEvenRow>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 nowrap>'||l_Order_Time||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Sett_Type||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Scheme_Id||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Isin||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 3 align = "left">'||l_Scheme_Desc||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 >'||l_Folio_No||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" >'||l_Buy_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Buy_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap><b>'||l_Buy_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Units_Display||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right">'||l_Sell_Phy_Demat||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Nav||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap>'||l_Sell_Commission||';</td>');
        Utl_File.Put_Line(l_File_Ptr,'  <td class = borderclass colspan = 1 align = "right" nowrap><b>'||l_Sell_Amt_Display||';</b></td>');
        Utl_File.Put_Line(l_File_Ptr,'</tr>');*/
        l_str := l_Order_Dtls           ||'~|~'||
                 l_Order_No             ||'~|~'||
                 l_Order_Time           ||'~|~'||
                 l_Sett_Type            ||'~|~'||
                 l_Scheme_Id            ||'~|~'||
                 l_Isin                 ||'~|~'||
                 l_Scheme_Desc          ||'~|~'||
                 l_Folio_No             ||'~|~'||
                 l_Buy_Units_Display    ||'~|~'||
                 l_Buy_Phy_Demat        ||'~|~'||
                 l_Buy_Nav              ||'~|~'||
                 l_Buy_Commission       ||'~|~'||
                 l_Buy_Amt_Display      ||'~|~'||
                 l_Sell_Units_Display   ||'~|~'||
                 l_Sell_Phy_Demat       ||'~|~'||
                 l_Sell_Nav             ||'~|~'||
                 l_Sell_Commission      ||'~|~'||
                 l_Sell_Amt_Display;
        Utl_File.Put_Line(l_File_Ptr,l_str);
        l_Line_Count_2 := l_Line_Count_2 +1;
      END IF;

      l_Header      := FALSE;
      l_Last_Ent_Id := l_Ent_Id;
      l_Last_Contract_No := l_Contract_No;
      l_Line_Count := (l_Line_Count_1 *2)+(l_Line_Count_2*1);
      IF l_Line_Count > 500 THEN
        l_Line_Count_break := l_Line_Count;
        l_Gen_New_File := FALSE;
        --P_Print_Footer_Signatory;
      END IF;
    END LOOP;

    IF l_Rep_Gen_Seq IS NOT NULL THEN
      l_Gen_New_File := TRUE;
      P_Print_Footer;
    END IF;

    UPDATE Web_Rep_Gen
    SET    Rg_Status       = 'S',
           Rg_Last_Updt_Dt = SYSDATE,
           Rg_Last_Updt_By = USER,
           Rg_End_Time     = SYSDATE,
           Rg_Remarks      = 'MF Order Confirmation Note Generated Successfully For '||l_Count_Reports||' Clients'
    WHERE  Rg_Seq          = l_Web_Seq_No
    AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

    g_Count_Directory := 0;
    P_Rep_Seq_No      := l_Web_Seq_No;
    p_Ret_Val         := 'SUCCESS';
    p_Ret_Msg         := 'Process Completed Successfully';

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,             l_Pam_Curr_Dt,             l_Process_Id,
                            'C',                  'Y',                       o_Err);

    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,' Mutual Fund Order Confirmation Note Generated at '||l_Mf_Order_Cnfm_Path || l_Fold_Name);
    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' No. of Client Order Confirmation Reports Generated     :   ' ||    l_Count_Reports);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' Process Completed Successfully at <'||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')||'>');
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN Ex_Submit_Cmd THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||' Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' MF Order Confirmation Note Generation Failed - '||p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,        l_Pam_Curr_Dt,       l_Process_Id,
                              'E',             'Y',                 o_Err);
    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||' Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' MF Order Confirmation Note Generation Failed - '||p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);
      Utl_File.Fclose(l_File_Ptr);

      UPDATE Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = p_Ret_Msg,
             Rg_Last_Updt_By = USER,
             Rg_Last_Updt_Dt = SYSDATE
      WHERE  Rg_Seq          = l_Rep_Gen_Seq;

      UPDATE Web_Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_Last_Updt_Dt = SYSDATE,
             Rg_Last_Updt_By = USER,
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = p_Ret_Msg
      WHERE  Rg_Seq          = l_Web_Seq_No
      AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,            l_Pam_Curr_Dt,            l_Process_Id,
                              'E',                 'Y',                      o_Err);
  END p_Gen_Mfe_Order_Conf_Note_CSV;

  PROCEDURE P_Dwnld_Settlmnt_Calndr_File(p_File_Name IN VARCHAR2,
                                         p_Exch_Id   IN VARCHAR2,
                                         p_Ret_Val   IN OUT VARCHAR2,
                                         p_Ret_Msg   IN OUT VARCHAR2)
  IS

    l_Pam_Curr_Dt          DATE;
    l_File_Path            VARCHAR2(300);
    l_Log_File_Handle      Utl_File.File_Type;
    l_Log_File_Name        VARCHAR2(100);
    l_Prg_Process_Id       NUMBER := 0;
    l_Line_Count           NUMBER := 0;
    Tab_File_Records       Std_Lib.Tab;
    Tab_Split_Record       Std_Lib.Tab;
    Line_No                NUMBER := 0;
    l_Count_Inserted       NUMBER := 0;
    l_Count_Update         NUMBER := 0;
    l_Count_Records        NUMBER := 0;
    l_Message              VARCHAR2(300);
    l_Settlement_Type      VARCHAR2(5);
    l_Settlement_No        VARCHAR2(10);
    l_Trade_Date           DATE;
    l_Funds_Payin_Date     DATE;
    l_Sec_Payin_Date       DATE;
    l_Funds_Payout_Date    DATE;
    l_Sec_Payout_Date      DATE;
    l_Old_Record_Count     NUMBER := 0;
    l_Record_Count         NUMBER := 0;
    l_Prg_Id               VARCHAR2(30) := 'CSSDLSET';
    Excp_Terminate         EXCEPTION;

  BEGIN

    P_Ret_Val := 'FAIL';
    p_Ret_Msg := ' in housekeeping. Check if file exists in /ebos/files/upstream or Program is running.';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Exch_Id || ',' || P_File_Name,
                           'M',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    p_Ret_Msg := ' getting current working date';
    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;

    p_Ret_Msg := ' getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    p_Ret_Msg := ' Loading the file ';
    Tab_File_Records.DELETE;
    Std_Lib.Load_File(l_File_Path,
                      p_File_Name,
                      l_Line_Count,
                      Tab_File_Records);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' || To_Char(l_Pam_Curr_Dt, 'DD-MON-RRRR'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    SELECT COUNT(1)
    INTO   l_Record_Count
    FROM   Mfss_Settlement_Calender
    WHERE  Mfs_Exch_Id = p_Exch_Id;

    FOR Line_No IN Tab_File_Records.FIRST .. Nvl(Tab_File_Records.LAST, 0)
    LOOP

      IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
        Utl_File.Put_Line(l_Log_File_Handle,'Splitting line no <' || Line_No || '>');
      END IF;

      p_Ret_Msg := '8: Splitting fields in the line buffer';
      IF Line_No = 1 THEN
        Utl_File.Put_Line(l_Log_File_Handle,'Skipping Line No <' || Line_No || '> as it is a Header Record');
      ELSE

        Tab_Split_Record.DELETE;
        IF P_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),'|', Tab_Split_Record);
        ELSE
          Std_Lib.Split_Line(Tab_File_Records(Line_No),',', Tab_Split_Record);
        END IF;

        IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle, '<' || i || '>' || ' = <' ||  Tab_Split_Record(i) || '>');
          END LOOP;
        END IF;

        -- Refeshing Varible

        IF p_Exch_Id = 'BSE' THEN

          l_Settlement_Type   := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));
          l_Settlement_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1));
          l_Trade_Date        := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2)), 'RRRR-MM-DD');
          l_Funds_Payin_Date  := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3)), 'RRRR-MM-DD');
          l_Sec_Payin_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4)), 'RRRR-MM-DD');
          l_Funds_Payout_Date := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5)), 'RRRR-MM-DD');
          l_Sec_Payout_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6)), 'RRRR-MM-DD');

        END IF;

       IF l_Funds_Payout_Date >= l_Pam_Curr_Dt OR l_Record_Count = 0  THEN
             BEGIN
                P_Ret_Msg := 'Inserting records into Settlement Calender for
                              Settlement No   <' ||l_Settlement_No  || '>,
                              Settlement Type <' ||l_Settlement_Type|| '> ,
                              Trade Date      <' ||l_Trade_Date     || '>';

                INSERT INTO Mfss_Settlement_Calender
                  (Mfs_Settlement_Type,          Mfs_Settlement_No,             Mfs_Exch_Id,
                   Mfs_Trade_Date,               Mfs_Fund_Payin_Date,           Mfs_Sec_Payin_Date,
                   Mfs_Funds_Payout_Date,        Mfs_Sec_Payout_Date,           Mfs_Creat_By,
                   Mfs_Creat_Dt,                 Mfs_Prg_Id)
                VALUES
                  (l_Settlement_Type,             l_Settlement_No,              p_Exch_Id,
                   l_Trade_Date,                  l_Funds_Payin_Date,           l_Sec_Payin_Date,
                   l_Funds_Payout_Date,           l_Sec_Payout_Date,            USER,
                   SYSDATE,                       l_Prg_Id);

                l_Count_Inserted := l_Count_Inserted + 1;

              EXCEPTION
                WHEN Dup_Val_On_Index THEN

                  P_Ret_Msg := 'Updating records into Settlement Calender for
                                Settlement No   <' ||l_Settlement_No  || '>,
                                Settlement Type <' ||l_Settlement_Type|| '> ,
                                Trade Date      <' ||l_Trade_Date     || '>';

                  UPDATE Mfss_Settlement_Calender
                  SET    Mfs_Settlement_Type   = l_Settlement_Type,
                         Mfs_Settlement_No     = l_Settlement_No,
                         Mfs_Exch_Id           = p_Exch_Id,
                         Mfs_Trade_Date        = l_Trade_Date,
                         Mfs_Fund_Payin_Date   = l_Funds_Payin_Date,
                         Mfs_Sec_Payin_Date    = l_Sec_Payin_Date,
                         Mfs_Funds_Payout_Date = l_Funds_Payout_Date,
                         Mfs_Sec_Payout_Date   = l_Sec_Payout_Date,
                         Mfs_Last_Updt_By      = USER,
                         Mfs_Last_Updt_Dt      = SYSDATE,
                         Mfs_Prg_Id            = l_Prg_Id
                  WHERE  Mfs_Settlement_No     = l_Settlement_No
                  AND    Mfs_Settlement_Type   = l_Settlement_Type
                  AND    Mfs_Exch_Id           = P_Exch_Id;

                  l_Count_Update := l_Count_Update + 1;

                WHEN OTHERS THEN
                  P_Ret_Val := 'FAIL';
                  P_Ret_Msg := P_Ret_Msg || ' Error message  is :' || SQLERRM;
                  RAISE Excp_Terminate;
              END;
        ELSE
         l_Old_Record_Count := l_Old_Record_Count + 1;
        END IF;
      END IF;
      l_Count_Records := l_Count_Records + 1;
    END LOOP;

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Dt,
                            l_Prg_Process_Id,
                            'C',
                            'Y',
                            l_Message);

    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File(Including Header) : ' || l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted                  : ' || l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated                   : ' || l_Count_Update);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                   : ' || l_Old_Record_Count);
    Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';

  EXCEPTION
    WHEN Excp_Terminate THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||'**Error Occured while :' || p_Ret_Msg;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace|| '**Error Occured while :' || p_Ret_Msg ||  '**Error Code is :' || SQLERRM;

      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END P_Dwnld_Settlmnt_Calndr_File;

  PROCEDURE P_Sec_Release (P_Agency_Id   IN  VARCHAR2,
                           o_Status      OUT VARCHAR2) IS

    l_Pam_Curr_Dt           DATE;
    l_Process_Id            NUMBER := 0;
    l_Release_Qty           NUMBER(24,4) := 0;
    l_Index                 NUMBER := 0;
    l_Failed_Records        NUMBER := 0;
    l_Pending_Records       NUMBER := 0;
    l_Batch_No              NUMBER := 0;
    l_Run_Mode              VARCHAR2(10);
    l_Rel_Instr_Type        VARCHAR2(10) := '30';
    l_Broker_Name           VARCHAR2(30);
    l_Prg_Id                VARCHAR2(30) := 'CSSQMFSECREL';
    l_Rel_Int_Ref_No        VARCHAR2(30);
    l_Dp                    VARCHAR2(30);
    l_Dp_Id                 VARCHAR2(30);
    l_Dp_Acc_No             VARCHAR2(30);
    l_Isin_Cd               VARCHAR2(30);
    l_Ent_Id                VARCHAR2(30);
    l_Dp_Cust_Id            VARCHAR2(30);
    l_Sem_Id                VARCHAR2(30);
    l_Ret_Val               VARCHAR2(100);
    l_Log_File_Path         VARCHAR2(100);
    l_Data_File_Path        VARCHAR2(100);
    l_Log_File_Name         VARCHAR2(100);
    l_Ret_Msg               VARCHAR2(32767);
    l_Msg                   VARCHAR2(32767);
    Ue_Exception            EXCEPTION;
    l_Log_File_Handle       Utl_File.File_Type;
    G_Hrt_Int_Ref_No        Pkg_Hrt_Online_Instr.Tab_Unique_Ref_No;
    G_Hrt_Response_Tab      Pkg_Hrt_Online_Instr.Tab_Hrt_Sec_All_Txn;

    CURSOR C_Clientwise_Release IS
      SELECT Client_Id,
             Scheme,
             Isin,
             Dp,
             Dp_Id,
             Dp_Acc_No,
             Traded_Qty,
             Existing_Hold_Qty,
             Release_Qty
      FROM (SELECT Existing_Hold.Hat_Ent_Id         Client_Id,
                   Existing_Hold.Hat_Sem_Id         Scheme,
                   Existing_Hold.Hat_Isin_Id        Isin,
                   Existing_Hold.Hat_Dem_Id         Dp,
                   Existing_Hold.Hat_Dpm_Id         Dp_Id,
                   Existing_Hold.Hat_Acc_No         Dp_Acc_No,
                   Nvl(Mf_Orders.Qty,0)             Traded_Qty,
                   Nvl(Existing_Hold.Qty,0)         Existing_Hold_Qty,
                   Nvl(Decode(Sign(Nvl(Mf_Orders.Qty,0) - Nvl(Existing_Hold.Qty,0)),-1,Nvl(Existing_Hold.Qty,0) - Nvl(Mf_Orders.Qty,0),0),0) Release_Qty
            FROM  (SELECT Ent_Id,
                          Security_Id,
                          Isin,
                          Mdi_Dpm_Dem_Id,
                          Dp_Id,
                          Dp_Acc_No,
                          Mdi_Cust_Id,
                          Nvl(SUM(Quantity),0) Qty
                   FROM   Mfss_Trades,
                          Member_Dp_Info,
                          Parameter_Master
                   WHERE  Order_Date                       = Pam_Curr_Dt
                   AND    Mdi_Id                           = Ent_Id
                   AND    Mdi_Dpm_Id                       = Dp_Id
                   AND    Mdi_Dp_Acc_No                    = Dp_Acc_No
                   AND    Mdi_Status                      <> 'C'
                   AND    Mdi_Default_Flag                 = 'Y'
                   AND    Buy_Sell_Flg                     = 'R'
                   AND    Trade_Status                     = 'A'
                   AND    Order_Status                     = 'VALID'
                   AND    Nvl(Mfss_Dp_Instruction_Flg,'N') = 'N'
                   AND    Nvl(Confirmation_Flag,'N')       = 'Y'
                   AND    Nvl(Sec_Payin_Success_Yn,'N')    = 'N'
                   GROUP BY Ent_Id,
                            Security_Id,
                            Isin,
                            Mdi_Dpm_Dem_Id,
                            Dp_Id,
                            Dp_Acc_No,
                            Mdi_Cust_Id) Mf_Orders,
                  (SELECT  Hat_Ent_Id,
                           Hat_Sem_Id,
                           Hat_Isin_Id,
                           Hat_Dem_Id,
                           Hat_Dpm_Id,
                           Hat_Acc_No,
                           Nvl(SUM(Decode(Hat_Db_Cr_Flg,'C',Nvl(Hat_Qty,0),'D',Nvl(-1 * Hat_Qty, 0))),0) Qty
                   FROM    Hrt_Sec_All_Txn,
                           Parameter_Master
                   WHERE   Hat_Txn_Dt              = Pam_Curr_Dt
                   AND     Hat_Agn_Id              = P_Agency_Id
                   AND     Hat_Appr_Flg            = 'A'
                   AND     Hat_Txn_Cd IN ('ROHL','CHLD',Decode(Nvl(Hat_Txn_Id,'-1'),'-1','-X','DREL'),'HTRF')
                   AND     EXISTS (SELECT 1
                                   FROM   Mfd_Scheme_Master
                                   WHERE  Msm_Scheme_Id     = Hat_Sem_Id
                                   AND    Msm_Record_Status = 'A'
                                   AND    Msm_Status        = 'A'
                                   AND    Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,Pam_Curr_Dt))
                   HAVING  SUM(Decode(Hat_Db_Cr_Flg,'C',Nvl(Hat_Qty,0),'D',Nvl(-1 * Hat_Qty,0))) > 0
                   GROUP BY Hat_Ent_Id,
                            Hat_Sem_Id,
                            Hat_Dem_Id,
                            Hat_Dpm_Id,
                            Hat_Acc_No,
                            Hat_Isin_Id) Existing_Hold
            WHERE  Mf_Orders.Ent_Id(+)          = Existing_Hold.Hat_Ent_Id
            AND    Mf_Orders.Security_Id(+)     = Existing_Hold.Hat_Sem_Id
            AND    Mf_Orders.Isin(+)            = Existing_Hold.Hat_Isin_Id
            AND    Mf_Orders.Mdi_Dpm_Dem_Id(+)  = Existing_Hold.Hat_Dem_Id
            AND    Mf_Orders.Dp_Id(+)           = Existing_Hold.Hat_Dpm_Id
            AND    Mf_Orders.Dp_Acc_No(+)       = Existing_Hold.Hat_Acc_No)
      WHERE Release_Qty > 0
      ORDER BY Client_Id;

    PROCEDURE P_Ins_Dp_Instr_Resp IS
    BEGIN
      INSERT INTO Dp_Instr_Resp
        (Dir_Batch_No,       Dir_Ebos_Ref_No,       Dir_Inst_Gen_Dt,
         Dir_Rel_Id,         Dir_Msg_Type,          Dir_Exch_Cd,
         Dir_Dpm_Dem_Id,     Dir_Dpm_Id,            Dir_Acc_No,
         Dir_Isin_Cd,        Dir_Req_Qty,           Dir_Resp_Qty,
         Dir_Resp_Cd,        Dir_Resp_Desc,         Dir_Dbos_Ref_No,
         Dir_Last_Updt_By,   Dir_Last_Updt_Dt,      Dir_Prg_Id,
         Dir_Status,         Dir_Cust_Id,           Dir_Ent_Id,
         Dir_Part_Flag,      Dir_Sem_Id)
      VALUES
        (NULL,               l_Rel_Int_Ref_No,      l_Pam_Curr_Dt,
         NULL,               'HRRP',                'NSE',
         l_Dp,               l_Dp_Id,               l_Dp_Acc_No,
         l_Isin_Cd,          l_Release_Qty,         '0',
         NULL,               NULL,                  NULL,
         NULL,               NULL,                  l_Prg_Id,
         'H',                l_Dp_Cust_Id,          l_Ent_Id,
         'N',                l_Sem_Id);
    END;

    PROCEDURE P_Ins_Dp_Instr_Master IS
    BEGIN
      INSERT INTO Dp_Instr_Master
        (Dim_Batch_No,            Dim_Instr_Type,        Dim_Instr_Dt,
         Dim_Delv_Dpm_Dem_Id,     Dim_Delv_Dpm_Id,       Dim_Delv_Dp_Acc_No,
         Dim_Prg_Id)
      VALUES
        (l_Batch_No,              l_Rel_Instr_Type,      l_Pam_Curr_Dt,
         'NSDL',                  'IN300126',            '999900000000',
         l_Prg_Id);
    END;

  BEGIN
    G_Hrt_Int_Ref_No.DELETE;
    G_Hrt_Response_Tab.DELETE;

    l_Msg :=  'Getting Log file path from   master Setup .';
    SELECT Decode(Substr(Rv_Low_Value,-1),'/',Rv_Low_Value,Rv_Low_Value||'/')
    INTO   l_Log_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'EBOS_LOG_PATH';

    l_Msg :=  'Getting Data file path from   master Setup .';
    SELECT Decode(Substr(Rv_High_Value,-1),'/',Rv_High_Value,Rv_High_Value||'/')
    INTO   l_Data_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain    = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    l_Msg :=  'Getting Simulator  Setup from master Setup';
    SELECT Nvl(Rv_Low_Value,'TEST')
    INTO   l_Run_Mode
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'XML_TEST_SETUP';

    l_Msg := ' Performing Housekeeping Activities ';
    Std_Lib.P_Housekeeping (l_Prg_Id,           'ALL',            P_Agency_Id,   'B',
                            l_Log_File_Handle,  l_Log_File_Name,  l_Process_Id,  'Y');

    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;
    l_Broker_Name := Std_Lib.l_Cpm_Short_Name;

    SELECT Lpad(Batch_Seq_No.NEXTVAL, 10, '0')
    INTO   l_Batch_No
    FROM   Dual;

    l_Msg := ' Opening cursor for calculating clientwise release ';
    FOR i IN C_Clientwise_Release
    LOOP
      l_Ent_Id      := i.Client_Id;
      l_Sem_Id      := i.Scheme;
      l_Isin_Cd     := i.Isin;
      l_Dp          := i.Dp;
      l_Dp_Id       := i.Dp_Id;
      l_Dp_Acc_No   := i.Dp_Acc_No;
      l_Release_Qty := i.Release_Qty;

      SELECT '2' || To_Char(l_Pam_Curr_Dt,'RRRRMMDD') || Lpad(Int_Ref_No.NEXTVAL,6,0)
      INTO   l_Rel_Int_Ref_No
      FROM   Dual;

      l_Msg := ' Inserting in Dp_Instr_Dtls for '||l_Ent_Id||' '||l_Dp||' '||l_Sem_Id||' '||l_Isin_Cd;
      INSERT INTO Dp_Instr_Dtls
        (Did_Dim_Batch_No,           Did_Recv_Acc_No,        Did_Recv_Dpm_Id,
         Did_Recv_Dpm_Dem_Id,        Did_Sem_Id,             Did_Isin_Cd,
         Did_Instr_Qty,              Did_Int_Ref_No,         Did_Prg_Id,
         Did_Exec_Dt,                Did_Serial_No,          Did_Regen_Flg,
         Did_File_Gen_Flg,           Did_Check_Flg,          Did_Check_By,
         Did_Check_Dt,               Did_Dld_No,             Did_Stt_Exm_Id,
         Did_Recv_Ent_Id,            Did_Instr_Dt)
      VALUES
        (l_Batch_No,                 l_Dp_Acc_No,            l_Dp_Id,
         l_Dp,                       l_Sem_Id,               l_Isin_Cd,
         l_Release_Qty,              l_Rel_Int_Ref_No,       l_Prg_Id,
         l_Pam_Curr_Dt,                  0,                      'N',
         'N',                        'A',                    'CHECKER',
         l_Pam_Curr_Dt,              Del_No_Seq.NEXTVAL,     'NSE',
         l_Ent_Id,                   l_Pam_Curr_Dt);

      IF l_Broker_Name <> 'AXIS' THEN
        l_Msg   := ' Inserting in Dp_Instr_Resp for Client Id <'||l_Ent_Id||'> and Isin <'||l_Isin_Cd||'> ';
        P_Ins_Dp_Instr_Resp;
      END IF;

      l_Msg := ' Populating Pl-Sql table for Release Details ';
      l_Index := l_Index + 1;
      G_Hrt_Int_Ref_No(l_Index).Int_Ref_No := l_Rel_Int_Ref_No;
    END LOOP;

    IF G_Hrt_Int_Ref_No.COUNT > 0 THEN
      P_Ins_Dp_Instr_Master;
      Pkg_Hrt_Online_Instr.P_Main_Release_Marking (P_Agency_Id, 'MF');

      Dbms_Lock.Sleep(5);

      Pkg_Hrt_Online_Instr.P_Read_Hold_Rel_Resp_HSL_MF (G_Hrt_Int_Ref_No,
                                                        l_Pam_Curr_Dt,
                                                        P_Agency_Id,
                                                        l_Run_Mode,
                                                        'RELEASE',
                                                        G_Hrt_Response_Tab,
                                                        l_Ret_Val,
                                                        l_Ret_Msg);

      FOR i IN 1..G_Hrt_Response_Tab.COUNT
      LOOP
        IF G_Hrt_Response_Tab(i).Dir_Response = 'FAIL' THEN
          l_Failed_Records := l_Failed_Records + 1;
        ELSIF G_Hrt_Response_Tab(i).Dir_Response = 'PENDING' THEN
          l_Pending_Records := l_Pending_Records + 1;
        END IF;
      END LOOP;
    ELSE
      Utl_File.Put_Line(l_Log_File_Handle,' No Records to be sent ');
      l_Index := 0;
    END IF;

    Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                             'C',          'Y',               l_Msg);

    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,' Total   Records : ' || l_Index);
    Utl_File.Put_Line(l_Log_File_Handle,' Failed  Records : ' || l_Failed_Records);
    Utl_File.Put_Line(l_Log_File_Handle,' Pending Records : ' || l_Pending_Records);
    Utl_File.Put_Line(l_Log_File_Handle,' Success Records : ' || Greatest(To_Number(l_Index - l_Failed_Records - l_Pending_Records),0));
    Utl_File.Put_Line(l_Log_File_Handle,' Batch No        : ' || l_Batch_No);
    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,' Process Completed Successfully at ' || To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS'));

    o_Status := 'SUCCESS';
    Utl_File.Fflush(l_Log_File_Handle);
    Utl_File.Fclose(l_Log_File_Handle);

  EXCEPTION
    WHEN Ue_Exception THEN
      ROLLBACK;
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,Dbms_Utility.format_error_backtrace||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

    WHEN OTHERS THEN
      ROLLBACK;
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,Dbms_Utility.format_error_backtrace||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

  END P_Sec_Release;

  PROCEDURE P_Gen_Sec_Payin_File (P_Exch     IN  VARCHAR2,
                                  P_Stc_Type IN  VARCHAR2,
                                  p_Dem_Id   IN  VARCHAR2,
                                  P_Exec_Dt  IN  DATE,
                                  o_Status   OUT VARCHAR2)
  IS

    l_Pam_Curr_Dt               DATE;
    l_Batch_No                  NUMBER := 0;
    l_Srl_No                    NUMBER := 0;
    l_Int_Reference_No          NUMBER := 0;
    l_Total_Recs                NUMBER := 0;
    l_Process_Id                NUMBER := 0;
    l_Ret_Val                   VARCHAR2(10);
    l_Payin_Instr_Type          VARCHAR2(10) := '29';
    l_New_Bk_No                 VARCHAR2(15) := '0';
    l_New_Sl_No                 VARCHAR2(15) := '0';
    l_Txn_Ref_No                VARCHAR2(20);
    l_Prg_Id                    VARCHAR2(30) := 'CSSQMFINSTPI';
    l_Txn_Ref_Id                VARCHAR2(30);
    l_To_Dp                      VARCHAR2(30);
    l_To_Dp_Id                   VARCHAR2(30);
    l_To_Dp_Acc_No               VARCHAR2(30);
    l_Nsdl_Dp_Id                VARCHAR2(30);
    l_Nsdl_Dp_Acc_No            VARCHAR2(30);
    l_Cdsl_Dp_Id                VARCHAR2(30);
    l_Cdsl_Dp_Acc_No            VARCHAR2(30);
    l_Log_file_Name             VARCHAR2(300);
    l_Nsdl_Exm_Pool_Acc_No      VARCHAR2(30);
    l_Cdsl_Exm_Pool_Acc_No      VARCHAR2(30);
    l_Nsdl_Exm_Pool_Dp_Id       VARCHAR2(30);
    l_Cdsl_Exm_Pool_Dp_Id       VARCHAR2(30);
    l_Msg                       VARCHAR2(1000);
    l_Err_Msg                   VARCHAR2(32767);
    l_Stc_Type                  VARCHAR2(3);
    Ue_Exception                EXCEPTION;
    l_Log_File_Handle           Utl_File.File_Type;

    CURSOR C_Clientwise_Payin IS
      SELECT Order_Date,
             Order_No,
             Client_Id,
             Exch,
             Sett_Type,
             Stc_No,
             Scheme,
             Isin,
             Buy_Sell_Flag,
             Qty,
             Dp,
             Dp_Id,
             Dp_Acc_No,
             Agency_Id
        FROM (SELECT Mf_Orders.Order_Date                              Order_Date,
                     Mf_Orders.Order_No                                Order_No,
                     Mf_Orders.Ent_Id                                  Client_Id,
                     Mf_Orders.Exm_Id                                  Exch,
                     Mf_Orders.Settlement_Type                         Sett_Type,
                     Mf_Orders.Stc_No                                  Stc_No,
                     Mf_Orders.Security_Id                             Scheme,
                     Mf_Orders.Isin                                    Isin,
                     Mf_Orders.Buy_Sell_Flg                            Buy_Sell_Flag,
                     Hold_Dtls.Hat_Dem_Id                              Dp,
                     Hold_Dtls.Hat_Dpm_Id                              Dp_Id,
                     Hold_Dtls.Hat_Acc_No                              Dp_Acc_No,
                     Hold_Dtls.Hat_Agn_Id                              Agency_Id,
                     Mf_Orders.Trd_Qty                                 Qty,
                     Hold_Dtls.Hld_Qty                                 Hld_Qty,
                     Hold_Dtls.Hld_Qty - SUM(Mf_Orders.Trd_Qty)
                     over (PARTITION BY Mf_Orders.Ent_Id,
                                        Mf_Orders.Security_Id
                     ORDER BY Mf_Orders.Ent_Id,
                              Mf_Orders.Security_Id,
                              Mf_Orders.Trd_Qty DESC,
                              Mf_Orders.Order_No
                     ROWS BETWEEN Unbounded Preceding AND CURRENT ROW) Payin_Qty
              FROM  (SELECT Order_Date,
                            Order_No,
                            Ent_Id,
                            Exm_Id,
                            Settlement_Type,
                            Stc_No,
                            Security_Id,
                            Isin,
                            Buy_Sell_Flg,
                            Nvl(SUM(Quantity),0) Trd_Qty
                     FROM   Mfss_Trades T
                     INNER JOIN MFSS_SETTLEMENT_TYPES M ON M.STT_TYPE = T.SETTLEMENT_TYPE AND M.STT_EXM_ID = P_Exch
                     WHERE  Order_Date                         = l_Pam_Curr_Dt
                     AND    Exm_Id                             = P_Exch
                     AND    Buy_Sell_Flg                       = 'R'
                     AND    Trade_Status                       = 'A'
                     AND    Order_Status                       = 'VALID'
                     AND    Nvl(Mfss_Dp_Instruction_Flg,'N')   = 'N'
                     AND    Nvl(Confirmation_Flag,'N')         = 'Y'
                     AND    Nvl(Sec_Payin_Success_Yn,'N')      = 'N'
                     AND    Settlement_Type                    = Decode(P_Stc_Type,'ALL',M.STT_TYPE,P_Stc_Type)
                     AND    Dp_Name                            = p_Dem_Id
                     GROUP BY Order_Date,
                              Order_No,
                              Ent_Id,
                              Exm_Id,
                              Settlement_Type,
                              Stc_No,
                              Security_Id,
                              Isin,
                              Buy_Sell_Flg) Mf_Orders,
                    (SELECT  Hat_Ent_Id,
                             Hat_Sem_Id,
                             Hat_Isin_Id,
                             Hat_Dem_Id,
                             Hat_Dpm_Id,
                             Hat_Acc_No,
                             Mdi_Cust_Id,
                             Hat_Agn_Id,
                             Nvl(SUM(Decode(Hat_Db_Cr_Flg,'C',Nvl(Hat_Qty,0),'D',Nvl(-1 * Hat_Qty, 0))),0) Hld_Qty
                     FROM    Hrt_Sec_All_Txn,
                             Member_Dp_Info
                     WHERE   Hat_Txn_Dt              = l_Pam_Curr_Dt
                     AND     Hat_Ent_Id              = Mdi_Id
                     AND     Hat_Dem_Id              = Mdi_Dpm_Dem_Id
                     AND     Hat_Dpm_Id              = Mdi_Dpm_Id
                     AND     Hat_Acc_No              = Mdi_Dp_Acc_No
                     AND     Hat_Dem_Id              = p_Dem_Id
                     AND     Mdi_Status             <> 'C'
                     AND     Mdi_Default_Flag        = 'Y'
                     AND     Substr(Hat_Isin_Id,1,3) = 'INF'
                     AND     Hat_Appr_Flg            = 'A'
                     AND     Hat_Txn_Cd IN ('ROHL','CHLD',Decode(Nvl(Hat_Txn_Id,-1),-1,'-X','DREL'),'HTRF')
                     HAVING  SUM(Decode(Hat_Db_Cr_Flg,'C',Nvl(Hat_Qty,0),'D',Nvl(-1 * Hat_Qty,0))) > 0
                     GROUP BY Hat_Ent_Id,
                              Hat_Sem_Id,
                              Hat_Isin_Id,
                              Hat_Dem_Id,
                              Hat_Dpm_Id,
                              Hat_Acc_No,
                              Mdi_Cust_Id,
                              Hat_Agn_Id) Hold_Dtls
              WHERE Mf_Orders.Ent_Id          = Hold_Dtls.Hat_Ent_Id
              AND   Mf_Orders.Security_Id     = Hold_Dtls.Hat_Sem_Id
              AND   Mf_Orders.Isin            = Hold_Dtls.Hat_Isin_Id)
      WHERE Payin_Qty >= 0
      ORDER BY Client_Id,
               Order_No;

    CURSOR C_Gen_Mf_Instr(dpm_id VARCHAR2) IS
      SELECT Order_Date                          Order_Date,
             Order_No                            Order_No,
             Ent_Id                              Client_Id,
             Exm_Id                              Exch,
             Settlement_Type                     Sett_Type,
             Stc_No                              Stc_No,
             Security_Id                         Scheme,
             Isin                                Isin,
             Buy_Sell_Flg                        Buy_Sell_Flag,
             Nvl(SUM(Quantity),0)                Qty,
             Dp_Name                             Dp,
             Dp_Id                               Dp_Id,
             Dp_Acc_No                           Dp_Acc_No,
             Member_Code                         Member_Code
      FROM   Mfss_Trades
      WHERE  Order_Date                        = l_Pam_Curr_Dt
      AND    Exm_Id                            = P_Exch
      AND    Dp_Name                           = p_Dem_Id
      AND    Dp_Id                             = dpm_id  --added
      AND    Settlement_Type                   = Decode(P_Stc_Type,'ALL',l_Stc_Type,P_Stc_Type)
      AND    Buy_Sell_Flg                      = 'R'
      AND    Trade_Status                      = 'A'
      AND    Order_Status                      = 'VALID'
      AND    Nvl(Mfss_Dp_Instruction_Flg,'N')  = 'N'
      AND    Nvl(Confirmation_Flag,'N')        = 'Y'
      AND    Nvl(Sec_Payin_Success_Yn,'N')     = 'Y'
      GROUP BY Order_Date,
               Order_No,
               Ent_Id,
               Exm_Id,
               Settlement_Type,
               Stc_No,
               Security_Id,
               Isin,
               Buy_Sell_Flg,
               Dp_Name,
               Dp_Id,
               Dp_Acc_No,
               Member_Code
      ORDER BY Ent_Id;

    CURSOR C_Stt_Type
    IS
    SELECT Stt_Type
    FROM   Mfss_Settlement_Types
    WHERE  Stt_Exm_Id = P_Exch
    AND    Stt_Type   = Decode(P_Stc_Type,'ALL',Stt_Type,P_Stc_Type)
    ORDER  BY Stt_Type;

    --added for agency wise batch no generation
    CURSOR C_Dp_Dtls
    IS
    SELECT Dpm_Id,
           Dpm_Dem_Id
    FROM   Depo_Participant_Master
    WHERE  Dpm_Agency_Cd IS NOT NULL;

    TYPE T_Txn_Ref_No IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(200);
    G_Txn_Ref_No T_Txn_Ref_No;

    TYPE T_Batch_No IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    G_Batch_No T_Batch_No;

    TYPE T_Dp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    G_Dp   T_Dp;
    G_Exch T_Dp;

  BEGIN

    G_Txn_Ref_No.DELETE;
    G_Batch_No.DELETE;
    G_Dp.DELETE;
    G_Exch.DELETE;

    l_Msg := ' Performing Housekeeping Activities ';
    Std_Lib.P_Housekeeping (l_Prg_Id,           P_Exch,           NULL,          'B',
                            l_Log_File_Handle,  l_Log_File_Name,  l_Process_Id,  'Y');

    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;

    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));
    Utl_File.Put_Line(l_Log_File_Handle,'Working Date      :-  '||l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Handle,'Exchange          :-  '||P_Exch );
    Utl_File.Put_Line(l_Log_File_Handle,'Depository Name   :-  '||P_Dem_Id);
    Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type   :-  '||P_Stc_Type);
    Utl_File.Put_Line(l_Log_File_Handle,'Execution Date    :-  '||P_Exec_Dt);
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    l_Msg := ' Opening cursor for Selecting MF Settlement Type.';
    l_Stc_Type := NULL;
    /*FOR j IN C_Stt_Type
    LOOP

       l_Stc_Type := j.Stt_Type;*/

       l_Msg := ' Opening cursor for clientwise payin ';
       FOR i IN C_Clientwise_Payin
       LOOP

          SELECT '2' || To_Char(l_Pam_Curr_Dt,'RRRRMMDD') || Lpad(Int_Ref_No.NEXTVAL,6,0)
          INTO   l_Txn_Ref_Id
          FROM   Dual;

          l_Msg := ' Inserting in Hrt_Sec_All_Txn for Client Id <'||i.Client_Id||'> and Isin <'||i.Isin||'> ';
          INSERT INTO Hrt_Sec_All_Txn
            (Hat_Sr_No,               Hat_Txn_Id,             Hat_Txn_Cd,              Hat_Txn_Dt,
             Hat_Agn_Id,              Hat_Db_Cr_Flg,          Hat_Dem_Id,              Hat_Dpm_Id,
             Hat_Acc_No,              Hat_Ent_Id,             Hat_Exm_Id,              Hat_Set_Type,
             Hat_Set_No,              Hat_Sem_Id,             Hat_Isin_Id,             Hat_Qty,
             Hat_Source,              Hat_Appr_Flg,           Hat_Prg_Id,              Hat_Creat_Dt,
             Hat_Creat_By,            Hat_Remarks)
          VALUES
            (Hat_No_Seq.NEXTVAL,      l_Txn_Ref_Id,           'HTRF',                  l_Pam_Curr_Dt,
             i.Agency_Id,             'D',                    i.Dp,                    i.Dp_Id,
             i.Dp_Acc_No,             i.Client_Id,            i.Exch,                  i.Sett_Type,
             i.Stc_No,                i.Scheme ,              i.Isin,                  i.Qty,
             'MANUAL',                'A',                    l_Prg_Id,                SYSDATE,
             USER,                    'MF SECURITY PAYIN');

          G_Txn_Ref_No(i.Order_No||i.Exch||i.Client_Id||i.Scheme||i.Buy_Sell_Flag) := l_Txn_Ref_Id;

          UPDATE Mfss_Trades
          SET    Sec_Payin_Success_Yn             = 'Y'
          WHERE  Order_Date                       = l_Pam_Curr_Dt
          AND    Order_No                         = i.Order_No
          AND    Exm_Id                           = i.Exch
          AND    Stc_No                           = i.Stc_No
          AND    Ent_Id                           = i.Client_Id
          AND    Security_Id                      = i.Scheme
          AND    Isin                             = i.Isin
          AND    Settlement_Type                  = i.Sett_Type
          AND    Dp_Name                          = p_Dem_Id
          AND    Buy_Sell_Flg                     = 'R'
          AND    Trade_Status                     = 'A'
          AND    Order_Status                     = 'VALID'
          AND    Nvl(Mfss_Dp_Instruction_Flg,'N') = 'N'
          AND    Nvl(Confirmation_Flag,'N')       = 'Y'
          AND    Nvl(Sec_Payin_Success_Yn,'N')    = 'N';

       END LOOP;
    /*END LOOP;*/

    l_Msg := 'getting pool details from Exchange master. ';

    SELECT Eam_Dp_Id               , Eam_Dp_Acc_No,
           Eam_Cdsl_Dp_Id          , Eam_Cdsl_Dp_Acc_No,
           Eam_Nsdl_Exch_Pool_Dp_Id, Eam_Nsdl_Exch_Pool_Dp_Acc_No,
           Eam_Cdsl_Exch_Pool_Dp_Id, Eam_Cdsl_Exch_Pool_Dp_Acc_No
    INTO   l_Nsdl_Dp_Id            , l_Nsdl_Dp_Acc_No,
           l_Cdsl_Dp_Id            , l_Cdsl_Dp_Acc_No,
           l_Nsdl_Exm_Pool_Dp_Id   , l_Nsdl_Exm_Pool_Acc_No,
           l_Cdsl_Exm_Pool_Dp_Id   , l_Cdsl_Exm_Pool_Acc_No
    FROM   Mfss_Exch_Admin_Master
    WHERE  Eam_Exm_Id   = P_Exch  ;

    l_To_Dp        := p_Dem_Id;
    l_To_Dp_Id     := l_Nsdl_Dp_Id;
    l_To_Dp_Acc_No := l_Nsdl_Dp_Acc_No;

    IF P_Dem_Id  = 'NSDL' THEN
      l_To_Dp        := p_Dem_Id;
      l_To_Dp_Id     := l_Nsdl_Exm_Pool_Dp_Id;
      l_To_Dp_Acc_No := l_Nsdl_Exm_Pool_Acc_No;
    ELSIF P_Dem_Id  = 'CDSL' THEN
      l_To_Dp        := p_Dem_Id;
      l_To_Dp_Id     := l_Cdsl_Exm_Pool_Dp_Id;
      l_To_Dp_Acc_No := l_Cdsl_Exm_Pool_Acc_No;
    END IF;

    Utl_File.New_Line(l_Log_File_Handle,2);
    Utl_File.Put_Line(l_Log_File_Handle,'System has generated batch for following Settlement Type');
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));
    Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type         Dp ID            Batch No         No Of Instruction');
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    l_Msg := ' Opening cursor for Selecting MF Settlement Type.';
    l_Stc_Type := NULL;
    FOR j IN C_Stt_Type
    LOOP

       BEGIN
         FOR i IN C_Dp_Dtls LOOP

           l_Stc_Type := j.Stt_Type;
           l_Total_Recs := 0;
           l_Batch_No   := 0;

           l_Msg := ' Opening cursor for generating MF instructions ';
           FOR k IN C_Gen_Mf_Instr(i.dpm_id)
           LOOP
              IF l_Total_Recs  = 0 THEN

                 SELECT Lpad(Batch_Seq_Payout_Ist.NEXTVAL,10,'0')
                 INTO   l_Batch_No
                 FROM   Dual;

                 l_Msg := ' Inserting in Dp_Instr_Master for '||P_Exch||' '||p_Dem_Id||' '||l_To_Dp_Id||' '||l_To_Dp_Acc_No||' '||k.Sett_Type;
                 INSERT INTO Dp_Instr_Master
                    (Dim_Batch_No,            Dim_Instr_Type,           Dim_Instr_Dt,
                     Dim_Delv_Dpm_Dem_Id,     Dim_Delv_Dpm_Id,          Dim_Delv_Dp_Acc_No,
                     Dim_Prg_Id,              Dim_Stc_No,               Dim_Stc_Stt_Type,
                     Dim_Stt_Exm_Id,          Dim_Creat_By,             Dim_Creat_Dt,
                     Dim_Exec_Dt)
                 VALUES
                    (l_Batch_No,              l_Payin_Instr_Type,       l_Pam_Curr_Dt,
                     l_To_Dp,                 l_To_Dp_Id,               l_To_Dp_Acc_No,
                     l_Prg_Id,                k.Stc_No,                 k.Sett_Type,
                     P_Exch,                  USER,                     SYSDATE,
                     P_Exec_Dt);

                  l_New_Bk_No        := '0';
                  l_New_Sl_No        := '0';
                  l_Srl_No           :=  0;
                  l_Int_Reference_No :=  0;

                END IF;
                IF l_Payin_Instr_Type = '29' AND p_Dem_Id = 'CDSL' THEN
                   l_Msg := ' Getting slip number for instruction type <'||l_Payin_Instr_Type||'> '||P_Exch||' '||p_Dem_Id||' '||l_Cdsl_Dp_Id||' '||l_Cdsl_Dp_Acc_No;
                   P_Get_Slip_Number(p_Dem_Id,
                                     l_To_Dp_Id,
                                     '29',
                                     l_To_Dp_Acc_No,
                                     P_Exch,
                                     l_New_Bk_No,
                                     l_New_Sl_No,
                                     l_Srl_No,
                                     l_Int_Reference_No,
                                     l_Err_Msg,
                                     l_Ret_Val);
                ELSE
                  l_Msg := ' Getting slip number for instruction type <'||l_Payin_Instr_Type||'> '||P_Exch||' '||p_Dem_Id||' '||l_To_Dp_Id||' '||l_To_Dp_Acc_No;
                  P_Get_Slip_Number(p_Dem_Id,
                                    l_To_Dp_Id,
                                    l_Payin_Instr_Type,
                                    l_To_Dp_Acc_No,
                                    P_Exch,
                                    l_New_Bk_No,
                                    l_New_Sl_No,
                                    l_Srl_No,
                                    l_Int_Reference_No,
                                    l_Err_Msg,
                                    l_Ret_Val);
                END IF;

                IF l_Ret_Val = '2' THEN
                   l_Msg := ' No slips available for DP instruction generation for MFSS Payin, instruction type <'||l_Payin_Instr_Type||'> ';
                   RAISE Ue_Exception;
                ELSIF l_Ret_Val = '3' THEN
                   l_Msg := l_Err_Msg;
                   RAISE Ue_Exception;
                END IF;

                IF Nvl(l_New_Sl_No,0) = 0 THEN
                   l_Msg := ' Slip No is either null or zero. Please check. ';
                   RAISE Ue_Exception;
                END IF;

                l_Msg := ' Getting internal reference no for '||k.Client_Id||' '||P_Exch||' '||
                          k.Dp||' '||k.Scheme||' '||k.Isin||' '||k.Sett_Type;
                SELECT Decode(Length(l_Int_Reference_No),1,Lpad(l_Int_Reference_No,2,0),l_Int_Reference_No)
                INTO   l_Int_Reference_No
                FROM   Dual;

                l_Txn_Ref_No := G_Txn_Ref_No(k.Order_No   ||
                                             k.Exch       ||
                                             k.Client_Id  ||
                                             k.Scheme     ||
                                             k.Buy_Sell_Flag);

                l_Msg := ' Inserting in Dp_Instr_Dtls for '||k.Client_Id||' '||P_Exch||' '||
                          k.Dp||' '||k.Scheme||' '||k.Isin||' '||k.Sett_Type;
                INSERT INTO Dp_Instr_Dtls
                    (Did_Dim_Batch_No,                Did_Recv_Acc_No,                   Did_Recv_Dpm_Id,
                     Did_Recv_Dpm_Dem_Id,             Did_Sem_Id,                        Did_Isin_Cd,
                     Did_Instr_Qty,                   Did_Int_Ref_No,                    Did_Prg_Id,
                     Did_Exec_Dt,                     Did_Serial_No,                     Did_Regen_Flg,
                     Did_File_Gen_Flg,                Did_Check_Flg,                     Did_Check_By,
                     Did_Check_Dt,                    Did_Dld_No,                        Did_Stc_No,
                     Did_Stc_Stt_Type,                Did_Stt_Exm_Id,                    Did_Recv_Ent_Id,
                     Did_Instr_Dt,                    Did_Active_Flag,                   Did_Txn_Ref_No)
                VALUES
                    (l_Batch_No,                      k.Dp_Acc_No,                       k.Dp_Id,
                     k.Dp,                            k.Scheme,                          k.Isin,
                     k.Qty,                           l_Int_Reference_No,                l_Prg_Id,
                     P_Exec_Dt,                       l_New_Sl_No,                       'N',
                     'N',                             'A',                               'CHECKER',
                     l_Pam_Curr_Dt,                   Del_No_Seq.NEXTVAL,                k.Stc_No,
                     k.Sett_Type,                     P_Exch,                            k.Client_Id,
                     l_Pam_Curr_Dt,                   'Y',                               l_Txn_Ref_No);

                UPDATE Mfss_Trades
                SET    Mfss_Dp_Instruction_Flg          = 'Y',
                       Dp_Batch_No                      = l_Batch_No,
                       Last_Updt_By                     = USER,
                       Last_Updt_Dt                     = SYSDATE
                WHERE  Order_Date                       = k.Order_Date
                AND    Order_No                         = k.Order_No
                AND    Exm_Id                           = P_Exch
                AND    Stc_No                           = k.Stc_No
                AND    Settlement_Type                  = k.Sett_Type
                AND    Ent_Id                           = k.Client_Id
                AND    Security_Id                      = k.Scheme
                AND    Isin                             = k.Isin
                AND    Buy_Sell_Flg                     = 'R'
                AND    Nvl(Mfss_Dp_Instruction_Flg,'N') = 'N';

                l_Total_Recs := l_Total_Recs + 1;
            END LOOP;

            Utl_File.Put_Line(l_Log_File_Handle,Rpad(l_Stc_Type     ,24,' ')||
                                                Rpad(i.dpm_id       ,17,' ')||
                                                Rpad(l_Batch_No     ,17,' ')||
                                                Rpad(l_Total_Recs   ,17,' '));
         END LOOP;
       EXCEPTION
          WHEN OTHERS THEN
            Utl_File.Put_Line(l_Log_File_Handle,'Error Occurred While '||l_Msg||' : '||SQLERRM);
            RAISE Ue_Exception;
       END;

       /*Utl_File.Put_Line(l_Log_File_Handle,Rpad(l_Stc_Type     ,24,' ')||
                                           Rpad(l_Batch_No     ,17,' ')||
                                           Rpad(l_Total_Recs   ,17,' '));*/

    END LOOP;

    Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'C',          'Y',               l_Msg);

    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,'Process Completed Successfully at ' || To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS'));
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    o_Status := 'SUCCESS';
    Utl_File.Fflush(l_Log_File_Handle);
    Utl_File.Fclose(l_Log_File_Handle);

  EXCEPTION
    WHEN Ue_Exception THEN
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57)||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);
      ROLLBACK;

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

    WHEN OTHERS THEN
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57)||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);
      ROLLBACK;

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

  END P_Gen_Sec_Payin_File;

  PROCEDURE P_Gen_Sec_Payout_File (P_Exch     IN  VARCHAR2,
                                   P_Date     IN  DATE,
                                   P_Dem_Id   IN  VARCHAR2,
                                   p_Stc_Type IN VARCHAR2,
                                   P_Exec_Dt  IN  DATE,
                                   O_Status   OUT VARCHAR2)
  IS

    l_Pam_Curr_Dt               DATE;
    l_Batch_No                  NUMBER := 0;
    l_Srl_No                    NUMBER := 0;
    l_Int_Reference_No          NUMBER := 0;
    l_Total_Recs                NUMBER := 0;
    l_Process_Id                NUMBER := 0;
    l_Ret_Val                   VARCHAR2(10);
    l_Exm_Id                    VARCHAR2(10);
    l_Payout_Instr_Type         VARCHAR2(10) := '03' ;
    l_New_Bk_No                 VARCHAR2(15) := '0';
    l_New_Sl_No                 VARCHAR2(15) := '0';
    l_Prg_Id                    VARCHAR2(30) := 'CSSQMFINSTPO';
    l_Dp_Id                     VARCHAR2(30);
    l_Dp_Acc_No                 VARCHAR2(30);
    l_Nsdl_Dp_Id                VARCHAR2(30);
    l_Nsdl_Dp_Acc_No            VARCHAR2(30);
    l_Cdsl_Dp_Id                VARCHAR2(30);
    l_Cdsl_Dp_Acc_No            VARCHAR2(30);
    l_Log_file_Name             VARCHAR2(300);
    l_Msg                       VARCHAR2(1000);
    l_Err_Msg                   VARCHAR2(32767);
    l_Stc_Type                  VARCHAR2(3);
    l_Process_Yn                VARCHAR2(1) := 'N';
    Ue_Exception                EXCEPTION;
    l_Log_File_Handle           Utl_File.File_Type;

    CURSOR C_Gen_Mf_Instr IS
      SELECT a.Order_Date                  Order_Date,
             a.Order_No                    Order_No,
             a.Client_Code                 Client_Id,
             a.Exm_Id                      Exch,
             a.Settlement_Type             Sett_Type,
             a.Sett_No                     Stc_No,
             a.Security_Id                 Scheme,
             a.Isin                        Isin,
             Nvl(a.Allotted_Unit,0)        Qty,
             m.Dp_Name                     Dp,
             m.Dp_Id                       Dp_Id,
             m.Dp_Acc_No                   Dp_Acc_No
      FROM   Allotment_Statement a,
             Mfss_Trades         m
      WHERE /* a.Order_Date                       = m.order_date  --'21-sep-2021'   -- AMEYA  ,  13/APR/2022  ,  DUE TO DIFF DATE INSTR NOT GENERATED
      AND */   Report_Date                        = P_Date
      AND    m.Exm_Id                           = P_Exch
      AND    a.Depository_Name                  = P_Dem_Id
      AND    a.Depository_Name                  = m.Dp_Name
      AND    a.Order_No                         = m.Order_No  --DONT COMMENT THIS CONDITION 
      AND    a.Exm_Id                           = m.Exm_Id
      --AND    a.Sett_No                          = m.Stc_No  -- AMEYA  ,  13/APR/2022  ,  DUE TO DIFF DATE INSTR NOT GENERATED
      AND    a.Settlement_Type                  = m.Settlement_Type
      AND    a.Settlement_Type                  = Decode(P_Stc_Type,'ALL',l_Stc_Type,P_Stc_Type)
      AND    a.Settlement_Type                 <> 'MF'
      AND    a.Client_Code                      = m.Ent_Id
      AND    a.Security_Id                      = m.Security_Id
      AND    a.Isin                             = m.Isin
      AND    a.Valid_Flag                       = 'Y'
      AND    a.Success_Reject_Status            = 'SUCCESS'
      AND    m.Buy_Sell_Flg                     = 'P'
      AND    Nvl(a.Allotted_Unit,0)             > 0
      AND    m.Trade_Status                     = 'A'
      AND    m.Order_Status                     = 'VALID'
      AND    Nvl(m.Mfss_Dp_Instruction_Flg,'N') = 'N'
      AND    Nvl(m.Confirmation_Flag,'N')       = 'Y'
      ORDER BY a.Client_Code,
               a.Scheme_Code;

      CURSOR C_Stt_Type
      IS
      SELECT Stt_Type
      FROM   Mfss_Settlement_Types
      WHERE  Stt_Exm_Id = P_Exch
      AND    Stt_Type   = Decode(P_Stc_Type,'ALL',Stt_Type,P_Stc_Type)
      ORDER  BY Stt_Type;

  BEGIN

    l_Msg := ' Performing Housekeeping Activities ';
    Std_Lib.P_Housekeeping (l_Prg_Id,           P_Exch,           NULL,          'B',
                            l_Log_File_Handle,  l_Log_File_Name,  l_Process_Id,  'Y');

    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;

    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));
    Utl_File.Put_Line(l_Log_File_Handle,'Working Date      :-  '||l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Handle,'Exchange          :-  '||P_Exch );
    Utl_File.Put_Line(l_Log_File_Handle,'Depository Name   :-  '||P_Dem_Id);
    Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type   :-  '||P_Stc_Type);
    Utl_File.Put_Line(l_Log_File_Handle,'Report Date       :-  '||P_Date);
    Utl_File.Put_Line(l_Log_File_Handle,'Execution Date    :-  '||P_Exec_Dt);
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    BEGIN
      SELECT Nvl(Rv_Low_Value,'N')
      INTO   l_Process_Yn
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain     = 'PROCESS_YN'
      AND    Rv_High_Value = 'DP_SLIP_GENERATION';
    EXCEPTION
      WHEN No_Data_Found THEN
         l_Process_Yn := 'N';
    END;

    l_Msg := ' Selecting Dp id and Dp acc no from Mfss Exch admin Master for Exchange <'||p_Exch||'>';
    SELECT Eam_Dp_Id,       Eam_Dp_Acc_No,
           Eam_Cdsl_Dp_Id,  Eam_Cdsl_Dp_Acc_No
    INTO   l_Nsdl_Dp_Id,    l_Nsdl_Dp_Acc_No,
           l_Cdsl_Dp_Id,    l_Cdsl_Dp_Acc_No
    FROM   Mfss_Exch_Admin_Master t
    WHERE  Eam_Exm_Id  = P_Exch ;

    l_Msg := ' selecting Dp id and Dp acc no';
    SELECT Decode(P_Dem_Id,'NSDL',l_Nsdl_Dp_Id,'CDSL',l_Cdsl_Dp_Id),
           Decode(P_Dem_Id,'NSDL',l_Nsdl_Dp_Acc_No,'CDSL',l_Cdsl_Dp_Acc_No)
    INTO   l_Dp_Id,
           l_Dp_Acc_No
    FROM   Dual;

    Utl_File.New_Line(l_Log_File_Handle,2);
    Utl_File.Put_Line(l_Log_File_Handle,'System has generated batch for following Settlement Type');
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));
    Utl_File.Put_Line(l_Log_File_Handle,'Settlement Type         Batch No         No Of Instruction');
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    l_Msg := ' Opening cursor for Selecting MF Settlement Type.';
    l_Stc_Type := NULL;
    FOR j IN C_Stt_Type
    LOOP
       l_Stc_Type    := j.Stt_Type;
       l_Total_Recs  := 0;
       l_Batch_No    := 0;
       BEGIN
         l_Msg := ' Opening cursor for generating MF instructions ';
         FOR i IN C_Gen_Mf_Instr
         LOOP

            IF l_Total_Recs = 0 THEN
              SELECT Lpad(Batch_Seq_Payout_Ist.NEXTVAL, 10, '0')
              INTO   l_Batch_No
              FROM   Dual;

              l_Msg := ' Inserting in Dp_Instr_Master for '||P_Exch||' '||P_Dem_Id||' '||l_Dp_Id||' '||l_Dp_Acc_No||' '||i.Sett_Type;
              INSERT INTO Dp_Instr_Master
                  (Dim_Batch_No,            Dim_Instr_Type,        Dim_Instr_Dt,
                   Dim_Delv_Dpm_Dem_Id,     Dim_Delv_Dpm_Id,       Dim_Delv_Dp_Acc_No,
                   Dim_Prg_Id,              Dim_Stc_No,            Dim_Stc_Stt_Type,
                   Dim_Stt_Exm_Id,          Dim_Exec_Dt,           Dim_Creat_By,
                   Dim_Creat_Dt)
              VALUES
                  (l_Batch_No,              l_Payout_Instr_Type,       l_Pam_Curr_Dt,
                   P_Dem_Id,                l_Dp_Id,                   l_Dp_Acc_No,
                   l_Prg_Id,                i.Stc_No,                  i.Sett_Type,
                   P_Exch,                  P_Exec_Dt,              USER,
                   SYSDATE);

              l_New_Bk_No        := '0';
              l_New_Sl_No        := '0';
              l_Srl_No           :=  0;
              l_Int_Reference_No :=  0;
            END IF;

            IF l_Process_Yn = 'Y' THEN
                l_Msg := ' Getting slip number for instruction type <'||l_Payout_Instr_Type||'> '||l_Exm_Id||' '||P_Dem_Id||' '||l_Dp_Id||' '||l_Dp_Acc_No;
                Pkg_Dp_Register.P_Get_Slip_Number (P_Dem_Id,
                                                   l_Dp_Id,
                                                   l_Payout_Instr_Type,
                                                   l_Dp_Acc_No,
                                                   P_Exch,
                                                   l_New_Bk_No,
                                                   l_New_Sl_No,
                                                   l_Srl_No,
                                                   l_Int_Reference_No,
                                                   l_Err_Msg,
                                                   l_Ret_Val);

                IF l_Ret_Val = '2' THEN
                   l_Msg := ' No slips available for DP instruction generation for MFSS Payout, instruction type <'||l_Payout_Instr_Type||'> ';
                   RAISE Ue_Exception;
                ELSIF l_Ret_Val = '3' THEN
                   l_Msg := l_Err_Msg;
                   RAISE Ue_Exception;
                END IF;

                l_Msg := ' Getting internal reference no ';
                SELECT Decode(Length(l_Int_Reference_No),1,Lpad(l_Int_Reference_No,2,0),l_Int_Reference_No)
                INTO   l_Int_Reference_No
                FROM   Dual;

                IF Nvl(l_New_Sl_No,0) = 0 THEN
                   l_Msg := l_Msg || ' Slip No is either null or zero. Please check. ';
                   RAISE Ue_Exception;
                END IF;
            END IF;

            l_Msg := ' Inserting in Dp_Instr_Dtls for '||i.Client_Id||' '||l_Exm_Id||' '||
                       i.Dp||' '||i.Scheme||' '||i.Isin||' '||i.Sett_Type;

            INSERT INTO Dp_Instr_Dtls
                (Did_Dim_Batch_No,                Did_Recv_Acc_No,                   Did_Recv_Dpm_Id,
                 Did_Recv_Dpm_Dem_Id,             Did_Sem_Id,                        Did_Isin_Cd,
                 Did_Instr_Qty,                   Did_Int_Ref_No,                    Did_Prg_Id,
                 Did_Exec_Dt,                     Did_Serial_No,                     Did_Regen_Flg,
                 Did_File_Gen_Flg,                Did_Check_Flg,                     Did_Check_By,
                 Did_Check_Dt,                    Did_Dld_No,                        Did_Stc_No,
                 Did_Stc_Stt_Type,                Did_Stt_Exm_Id,                    Did_Recv_Ent_Id,
                 Did_Instr_Dt,                    Did_Active_Flag)
            VALUES
                (l_Batch_No,                      i.Dp_Acc_No,                       i.Dp_Id,
                 i.Dp,                            i.Scheme,                          i.Isin,
                 i.Qty,                           l_Int_Reference_No,                l_Prg_Id,
                 P_Exec_Dt,                       l_New_Sl_No,                       'N',
                 'N',                             'A',                               'CHECKER',
                 l_Pam_Curr_Dt,                   Del_No_Seq.NEXTVAL,                i.Stc_No,
                 i.Sett_Type,                     P_Exch,                            i.Client_Id,
                 l_Pam_Curr_Dt,                   'Y');

            l_Msg := ' Updating batch number and dp instruction flag for '||i.Client_Id||' '||P_Exch||' '||
                     i.Dp||' '||i.Scheme||' '||i.Isin||' '||i.Sett_Type;

            UPDATE Mfss_Trades
            SET    Mfss_Dp_Instruction_Flg          = 'Y',
                   Dp_Batch_No                      = l_Batch_No,
                   Last_Updt_By                     = USER,
                   Last_Updt_Dt                     = SYSDATE
            WHERE  /*Order_Date                       = i.Order_Date   -- AMEYA  ,  13/APR/2022  ,  DUE TO DIFF DATE INSTR NOT GENERATED
            AND */   Order_No                         = i.Order_No
            AND    Exm_Id                           = P_Exch
          --  AND    Stc_No                           = i.Stc_No   -- AMEYA  ,  13/APR/2022  ,  DUE TO DIFF DATE INSTR NOT GENERATED
            AND    Ent_Id                           = i.Client_Id
            AND    Security_Id                      = i.Scheme
            AND    Isin                             = i.Isin
            AND    Settlement_Type                  = i.Sett_Type
            AND    Buy_Sell_Flg                     = 'P'
            AND    Nvl(Mfss_Dp_Instruction_Flg,'N') = 'N';

           l_Total_Recs := l_Total_Recs + 1;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE Ue_Exception;
      END;
      Utl_File.Put_Line(l_Log_File_Handle,Rpad(l_Stc_Type     ,24,' ')||
                                          Rpad(l_Batch_No     ,17,' ')||
                                          Rpad(l_Total_Recs   ,17,' '));
    END LOOP;

    Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,      l_Pam_Curr_Dt,      l_Process_Id,
                             'C',           'Y',                l_Msg);

    Utl_File.Put_Line(l_Log_File_Handle,'');
    Utl_File.Put_Line(l_Log_File_Handle,'Process Completed Successfully at ' || To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS'));
    Utl_File.Put_Line(l_Log_File_Handle, Rpad('-',100,'-'));

    o_Status := 'SUCCESS';
    Utl_File.Fflush(l_Log_File_Handle);
    Utl_File.Fclose(l_Log_File_Handle);

  EXCEPTION
    WHEN Ue_Exception THEN
      ROLLBACK;
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57)||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

    WHEN OTHERS THEN
      ROLLBACK;
      o_Status      := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle,'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57)||' - '||l_Msg||' - '||SQLERRM);
      Utl_File.Fflush(l_Log_File_Handle);
      Utl_File.Fclose(l_Log_File_Handle);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Process_Id,
                               'F',          'Y',               l_Msg);

  END P_Gen_Sec_Payout_File;



  PROCEDURE P_Mfd_Load_Mfss_Site_File(P_Path      IN     VARCHAR2,
                                      P_File_Name IN     VARCHAR2,
                                      P_Ret_Val   IN OUT VARCHAR2,
                                      P_Ret_Msg   IN OUT VARCHAR2)
  AS
     l_Prg_Id                         VARCHAR2(10) := 'MFSSSITE';
     l_Primary_File                   VARCHAR2(20);
     l_Log_File_Name                  VARCHAR(200);
     l_Prg_Process_Id                 NUMBER := 0;
     l_Log_File_Handle                Utl_File.File_Type;
     l_File_Ptr                       Utl_File.File_Type;
     l_Line_Buffer                    VARCHAR2(32767);
     l_Line_No                        NUMBER := 0;
     l_Sql_Err                        VARCHAR2(2000);
     l_Pam_Curr_Dt                    DATE;
     l_Change_New                     VARCHAR2(1);
     l_Skip_Yn                        VARCHAR2(1) := 'N';
     l_Count_Records                  NUMBER := 0;
     l_Count_Inserted                 NUMBER := 0;
     l_Count_Updated                  NUMBER := 0;
     l_Count_Skipped                  NUMBER := 0;
     l_Count_Change_Skip              NUMBER := 0;
     l_Mand_Fields_Msg                VARCHAR2(32767);
     l_Nse_Tab                        Std_Lib.Tab;
     r_Mfd_scheme_master              Mfd_scheme_master%Rowtype;
     l_Count_Bse                      NUMBER := 0;
     E_Mand_Exp                       EXCEPTION;
     End_Of_File                      EXCEPTION;
     E_User_Exp                       EXCEPTION;
     Ue_Exception                     EXCEPTION;

     TYPE T_Mfd_Schemes IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
     Tab_Mfd_Schemes T_Mfd_Schemes;

     ---Others Variable to Update Mfd_Scheme_master
     l_Msm_Nse_Code                   VARCHAR2(12);
     l_Msm_Scheme_Type                VARCHAR2(20);
     l_Msm_Div_Option                 VARCHAR2(1);
     l_Msm_Amc_Id                     VARCHAR2(30);
     l_Msm_Rta_Id                     VARCHAR2(30);
     l_Msm_Scheme_Id                  VARCHAR2(30);
     --- Variables For File
     l_Msm_Nse_Unique_No              NUMBER;
     l_Symbol_Msm_Nse_Code            VARCHAR2(10);
     l_Series_Msm_Nse_Code            VARCHAR2(2);
     l_Msm_Max_Redem_Qty              NUMBER(24,3);
     l_Msm_Rta_Sch_Cd                 VARCHAR2(10);
     l_Msm_Amc_Sch_cd                 VARCHAR2(10);
     l_Msm_Demat_Yn                   VARCHAR2(2);
     l_Msm_Isin                       VARCHAR2(12);
     l_Msm_Status                     NUMBER(15);
     l_Eligibility_Flg                NUMBER      ;
     l_Nse_Amc_Code                   VARCHAR2(10);
     l_Nse_Category_Code              VARCHAR2(5);
     l_Msm_Scheme_Desc                VARCHAR2(200);
     l_Msm_Add_Pur_Amt_Mul            NUMBER(24,3);
     l_Nse_Rta_Code                   VARCHAR2(30);
     l_Msm_Val_Dec_Indicator          NUMBER(1);
     l_Msm_Cat_Start_Time             VARCHAR(20);
     l_Msm_Qty_Dec_Indicator          NUMBER(1);
     l_Msm_Cat_End_Time               VARCHAR(20);
     l_Msm_Min_Pur_Amt                NUMBER(24,3);
     l_Msm_Max_Redem_Amt              NUMBER(24,3);

     l_Msm_Nfo_To_Date                VARCHAR2(15);
     l_Msm_Nfo_From_Date              VARCHAR2(15);
     l_Msm_Nfo_Allotment_Date         VARCHAR2(15);
     l_Msm_Nfo_Yn                     VARCHAR2(1);

     l_Msm_Sec_Depmandatory           NUMBER(1);
     l_Msm_Sec_Allowdep               NUMBER(1);
     l_Msm_Redem_Allowed              VARCHAR2(1);
     l_Msm_Sec_Mod_Cxl                NUMBER;
     l_Msm_Pur_Allowed                VARCHAR2(1);
     l_Msm_Min_Redem_Amt              NUMBER(24,3);
     l_Msm_Min_Redem_Qty              NUMBER(24,3);
     l_Msm_Remarks                    VARCHAR2(25);
     l_Msm_Sip_YN                     VARCHAR2(1);

     l_Msm_Max_Pur_Amt                NUMBER(24,3);
     l_Msm_Add_Pur_Amt                NUMBER(24,3);
     l_Msm_Max_Pur_Amt_Nse            NUMBER(24,3);
     l_Msm_Add_Pur_Amt_Nse            NUMBER(24,3);
     l_Msm_Min_Pur_Amt_Nse            NUMBER(24,3);

     l_Msm_Min_Depaddlsubval_Lmt      NUMBER(24,3);

     l_Msm_Max_Redem_Qty_Nse          NUMBER(24,3);
     l_Msm_Min_Redem_Qty_Nse          NUMBER(24,3);

     l_Msm_Pur_Amt_Mul                NUMBER;

     l_Msm_Pur_Amt_Mul_Nse            NUMBER;

     l_Msm_Amc_Name                   VARCHAR2(100);

     --
     l_Msm_Settlement_Type            VARCHAR2(3);
     l_Msm_Scheme_Depcode             VARCHAR2(1);
     l_Msm_Physical_Yn                VARCHAR2(1);
     l_Invalid_Record                 NUMBER := 0 ;
     l_LQ_Count                       NUMBER := 0 ;
     l_Valid_Scheme_Count             NUMBER := 0 ;
     E_Invalid_Excp                   EXCEPTION;
     l_Nfo_allowd                     NUMBER := 0 ;

     CURSOR C_Nse_Dup_No IS
        SELECT * FROM (SELECT D.*, COUNT(MSM_NSE_UNIQUE_NO) OVER (PARTITION BY MSM_NSE_UNIQUE_NO) CNT  FROM  (SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Nse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date  BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        UNION ALL -- Nfo Scheme whose Nav provided by Exchange
        SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Nse_Unique_No
        FROM   Mfd_Scheme_Master m1,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m1.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m1.Msm_Nfo_Yn = 'Y')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_Nfo_From_Date AND Nvl(Msm_Nfo_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Nfo_Yn        = 'Y'
        UNION ALL -- Nfo Scheme whose Nav NOT provided by Exchange
        SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Nse_Unique_No
        FROM   Mfd_Scheme_Master m1/*,
               Mfd_Nav*/
        WHERE  Msm_Scheme_Id Not In (Select Mn_scheme_id From Mfd_Nav)
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_Nfo_From_Date AND Nvl(Msm_Nfo_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Nfo_Yn        = 'Y'
        UNION ALL  --L0 Schemes
        SELECT Msm_Scheme_Id||'L0' Msm_Scheme_Id   ,Msm_Scheme_Desc||'L0' Msm_Scheme_Desc   ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Nse_Lo_Unique_No Msm_Nse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Lo_Allowed_Yn = 'Y'
        UNION ALL  --L1 Schemes
        SELECT Msm_Scheme_Id||'L1' Msm_Scheme_Id   ,Msm_Scheme_Desc||'L1' Msm_Scheme_Desc   ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Nse_L1_Unique_No Msm_Nse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_L1_Allowed_Yn = 'Y') D)
        WHERE CNT>1;

     PROCEDURE P_Insert_Mfd_Scheme_Master
     IS
     BEGIN
       INSERT INTO Mfd_Scheme_Master
           (Msm_Scheme_Id,
            Msm_Scheme_Desc,
            Msm_Amc_Id,
            Msm_Rta_Id,
            Msm_From_Date,
            Msm_Scheme_Type,
            Msm_Nse_Code,
            Msm_Isin,
            Msm_Rta_Sch_Cd,
            Msm_Sch_Cat,
            Msm_Nfo_From_Date,
            Msm_Nfo_To_Date,
            Msm_Pur_Allowed_Nse,
            Msm_Redem_Allowed_Nse,
            Msm_Nse_Allowed,
            Msm_Physical_Yn,
            Msm_Demat_Yn,
            Msm_Sip_Yn,
            Msm_Div_Option,
            Msm_Pur_Cut_Off,
            Msm_Redem_Cut_Off,
            Msm_Creat_By,
            Msm_Creat_Dt,
            Msm_Source,
            Msm_Status,
            Msm_Amc_Name,
            Msm_Remark,
            Msm_Amc_Sch_Cd,
            Msm_Record_Status,
            Msm_Prg_Id,
            Msm_Nse_Unique_No,
            Msm_Amc_Code,
            Msm_Nfo_Allotment_Date,
            Msm_Sec_Depmandatory,
            Msm_Sec_Allowdep,
            Msm_Scheme_Depcode,
            Msm_Sec_Mod_Cxl,
            Msm_Max_Depaddlsubval_Lmt,
            Msm_Cat_Start_Time,
            Msm_Cat_End_Time,
            Msm_Qty_Dec_Indicator,
            Msm_Val_Dec_Indicator,
            Msm_Min_Pur_Amt_Nse,
            Msm_Max_Pur_Amt_Nse,
            Msm_Purc_Amt_Multiplier_Nse,
            Msm_Addtnl_Pur_Amt_Nse,
            Msm_Add_Pur_Amt_Mul_Nse,
            Msm_Min_Redem_Qty_Nse,
            Msm_Max_Redem_Qty_Nse,
            Msm_Min_Pur_Amt,
            Msm_Max_Pur_Amt,
            Msm_Add_Pur_Amt_Mul,
            Msm_Min_Redem_Qty,
            Msm_Max_Redem_Qty,
            Msm_Pur_Amt_Mul,
            Msm_Add_Pur_Amt,
            Msm_Min_Redem_Amt,
            Msm_Max_Redem_Amt,
            Msm_Nse_Pur_Cut_Off,
            Msm_Nse_Redem_Cut_Off,
            Msm_Nse_LO_Sch_Cat,
            Msm_Lo_Allowed_Yn,
            Msm_Nse_Lo_Settlement_Type,
            Msm_Nse_Lo_Unique_No,
            Msm_Nse_Lo_Scheme_Code,
            Msm_Nse_Lo_Pur_Cut_Off,
            Msm_Nse_Lo_Min_Pur_Amt,
            Msm_Nse_Lo_Max_Pur_Amt,
            Msm_Nse_Lo_Addtnl_Pur_Amt,
            Msm_Nse_Lo_Purc_Amt_Multiplier,
            Msm_Nse_Lo_Add_Pur_Amt_Mul,
            Msm_Pur_Allowed_Nse_L0,
            Msm_Settlement_Type,
            ------------L1 -------------------
            Msm_Nse_L1_Sch_Cat,
            Msm_L1_Allowed_Yn,
            Msm_Nse_L1_Settlement_Type,
            Msm_Nse_L1_Unique_No,
            Msm_Nse_L1_Scheme_Code,
            Msm_Nse_L1_Pur_Cut_Off,
            Msm_Nse_L1_Min_Pur_Amt,
            Msm_Nse_L1_Max_Pur_Amt,
            Msm_Nse_L1_Addtnl_Pur_Amt,
            Msm_Nse_L1_Purc_Amt_Multiplier,
            Msm_Nse_L1_Add_Pur_Amt_Mul,
            Msm_Pur_Allowed_Nse_L1,
            Msm_Nfo_Yn,
            Msm_Nfo_Time,
            Msm_Nse_Sip_Allowed)

        VALUES
           (l_Msm_Scheme_Id,
            l_Msm_Scheme_Desc,
            l_Msm_Amc_Id,
            l_Msm_Rta_Id,
            l_Pam_Curr_Dt,
            l_Msm_Scheme_Type,
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Code,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL,l_Msm_Nse_Code),
            l_Msm_Isin,
            l_Msm_Rta_Sch_Cd,
            l_Nse_Category_Code,
            l_Msm_Nfo_From_Date,
            l_Msm_Nfo_To_Date,
            --Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed),'Y'),'N'),
            Decode(l_Nfo_allowd,1,'N',Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed),'Y'),'N')),
            Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,Decode(l_Eligibility_Flg,0,'N',l_Msm_Redem_Allowed),'Y'),'N'),
            --Decode(l_Eligibility_Flg,0,'N','Y'),
            Decode(l_Eligibility_Flg,0,'N',Decode(l_Nfo_allowd,1,'N','Y')),
            l_Msm_Physical_Yn,
            l_Msm_Demat_Yn,
            l_Msm_Sip_Yn,
            l_Msm_Div_Option,
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'Y'),
        --    Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL,l_Msm_Cat_End_Time),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'Y'),
         --   Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL,l_Msm_Cat_End_Time),
            USER,
            SYSDATE,
            'N',
            'A',
            l_Msm_Amc_Name,
            l_Msm_Remarks,
            l_Msm_Amc_Sch_Cd,
            'A',
            l_Prg_Id,
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Unique_No,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Nse_Unique_No),
            l_Nse_Amc_Code,
            l_Msm_Nfo_Allotment_Date,
            l_Msm_Sec_Depmandatory,
            l_Msm_Sec_Allowdep,
            l_Msm_Scheme_Depcode,
            l_Msm_Sec_Mod_Cxl,
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Add_Pur_Amt_Nse,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD',Null,l_Msm_Add_Pur_Amt_Nse),
            l_Msm_Cat_Start_Time,
            l_Msm_Cat_End_Time,
            l_Msm_Qty_Dec_Indicator,
            l_Msm_Val_Dec_Indicator,
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Pur_Amt_Nse,'Y'),
         --   Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Pur_Amt_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Pur_Amt_Nse,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Max_Pur_Amt_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'Y'),
        --    Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Pur_Amt_Mul_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Depaddlsubval_Lmt,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Depaddlsubval_Lmt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Pur_Amt_Mul_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Redem_Qty_Nse,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Redem_Qty_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Redem_Qty_Nse,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Max_Redem_Qty_Nse),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Pur_Amt,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Pur_Amt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Pur_Amt,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Max_Pur_Amt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Add_Pur_Amt_Mul,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Add_Pur_Amt_Mul),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Redem_Qty,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Redem_Qty),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Redem_Qty,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Max_Redem_Qty),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Pur_Amt_Mul),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Add_Pur_Amt,'Y'),
          ---  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Add_Pur_Amt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Redem_Amt,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Min_Redem_Amt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Redem_Amt,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Max_Redem_Amt),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'Y'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL, l_Msm_Cat_End_Time),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'Y'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL,l_Msm_Cat_End_Time),
          --- L0 ---
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Nse_Category_Code,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Nse_Category_Code,'HLIQD', l_Nse_Category_Code, NULL),
            Decode(l_Eligibility_Flg,0,'N',Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,'Y','N'),'N')),
           -- Decode(l_Nse_Category_Code, 'DBTCR', 'Y','HLIQD', 'Y', 'N'),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,'L0','N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', 'L0','HLIQD', 'L0', NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Unique_No,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Nse_Unique_No,'HLIQD', l_Msm_Nse_Unique_No, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Code,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Nse_Code,'HLIQD', l_Msm_Nse_Code, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Cat_End_Time,'HLIQD', l_Msm_Cat_End_Time, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Pur_Amt_Nse,'N'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Min_Pur_Amt_Nse,'HLIQD', l_Msm_Min_Pur_Amt_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Pur_Amt_Nse,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Max_Pur_Amt_Nse,'HLIQD', l_Msm_Max_Pur_Amt_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Depaddlsubval_Lmt,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Min_Depaddlsubval_Lmt  ,'HLIQD', l_Msm_Min_Depaddlsubval_Lmt, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Pur_Amt_Mul_Nse,'HLIQD', l_Msm_Pur_Amt_Mul_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'N'),
            Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed),'N'),'N'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Pur_Amt_Mul_Nse,'HLIQD', l_Msm_Pur_Amt_Mul_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Settlement_Type,'Y'),
            --  Decode(l_Nse_Category_Code, 'DBTCR', NULL,'HLIQD', NULL,l_Msm_Settlement_Type),
            ---L1 ---
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Nse_Category_Code,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Nse_Category_Code,'HLIQD', l_Nse_Category_Code, NULL),
            Decode(l_Eligibility_Flg,0,'N',Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,'Y','Z'),'N')),
           -- Decode(l_Nse_Category_Code, 'DBTCR', 'Y','HLIQD', 'Y', 'N'),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,'L1','Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', 'L0','HLIQD', 'L0', NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Unique_No,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Nse_Unique_No,'HLIQD', l_Msm_Nse_Unique_No, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Nse_Code,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Nse_Code,'HLIQD', l_Msm_Nse_Code, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Cat_End_Time,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Cat_End_Time,'HLIQD', l_Msm_Cat_End_Time, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Pur_Amt_Nse,'Z'),
           -- Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Min_Pur_Amt_Nse,'HLIQD', l_Msm_Min_Pur_Amt_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Max_Pur_Amt_Nse,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Max_Pur_Amt_Nse,'HLIQD', l_Msm_Max_Pur_Amt_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Min_Depaddlsubval_Lmt,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Min_Depaddlsubval_Lmt  ,'HLIQD', l_Msm_Min_Depaddlsubval_Lmt, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Pur_Amt_Mul_Nse,'HLIQD', l_Msm_Pur_Amt_Mul_Nse, NULL),
            F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,l_Msm_Pur_Amt_Mul_Nse,'Z'),
          --  Decode(l_Nse_Category_Code, 'DBTCR', l_Msm_Pur_Amt_Mul_Nse,'HLIQD', l_Msm_Pur_Amt_Mul_Nse, NULL),
            Nvl(F_Get_Field(l_Nse_Category_Code,l_Series_Msm_Nse_Code,Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed),'Z'),'N'),
            l_Msm_Nfo_Yn,
            Decode(l_Msm_Settlement_Type, 'MF' ,l_Msm_Cat_End_Time,NULL),
            l_Msm_Sip_Yn);


     END P_Insert_Mfd_Scheme_Master;

     PROCEDURE p_Full_Upd_Scheme_Master IS
     BEGIN

         IF l_Nse_Category_Code NOT IN ( 'DBTCR','HLIQD') THEN
            UPDATE Mfd_Scheme_Master
            SET    Msm_Scheme_Desc             = Nvl(l_Msm_Scheme_Desc,            Msm_Scheme_Desc),
                   Msm_Amc_Id                  = Nvl(l_Msm_Amc_Id,                 Msm_Amc_Id),
                   Msm_Rta_Id                  = Nvl(l_Msm_Rta_Id,                 Msm_Rta_Id),
                   Msm_Scheme_Type             = Nvl(l_Msm_Scheme_Type,            Msm_Scheme_Type),
                   Msm_Nse_Code                = Nvl(l_Msm_Nse_Code,               Msm_Nse_Code),
                   Msm_Isin                    = Nvl(l_Msm_Isin,                   Msm_Isin),
                   Msm_Rta_Sch_Cd              = Nvl(l_Msm_Rta_Sch_Cd,             Msm_Rta_Sch_Cd),
                   Msm_Sch_Cat                 = Nvl(l_Nse_Category_Code,          Msm_Sch_Cat),
                   Msm_Nfo_From_Date           = Nvl(l_Msm_Nfo_From_Date,          Msm_Nfo_From_Date),
                   Msm_Nfo_To_Date             = Nvl(l_Msm_Nfo_To_Date,            Msm_Nfo_To_Date),
                   --Msm_Pur_Allowed_Nse         = Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed), Msm_Pur_Allowed_Nse),
                   Msm_Pur_Allowed_Nse         = Nvl(Decode(l_Eligibility_Flg,0,'N',Decode(l_Nfo_allowd,1,'N',l_Msm_Pur_Allowed)), Msm_Pur_Allowed_Nse),
                   Msm_Redem_Allowed_Nse       = Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Redem_Allowed),Msm_Redem_Allowed_Nse),
                   --Msm_Nse_Allowed             = Decode(l_Eligibility_Flg,0,'N','Y'),
                   Msm_Nse_Allowed             = Decode(l_Eligibility_Flg,0,'N',Decode(l_Nfo_allowd,1,'N','Y')),
                   Msm_Demat_Yn                = Nvl(l_Msm_Demat_Yn,               Msm_Demat_Yn),
                   Msm_Sip_Yn                  = Nvl(l_Msm_Sip_Yn,                 Msm_Sip_Yn),
                   Msm_Div_Option              = Nvl(l_Msm_Div_Option,            Msm_Div_Option),
                   Msm_Last_Updt_By            = USER,
                   Msm_Nse_Updt_Dt             = SYSDATE,
                   Msm_Source                  = 'N',
                   Msm_Amc_Name                = Nvl(l_Msm_Amc_Name,               Msm_Amc_Name),
                   Msm_Remark                  = Nvl(l_Msm_Remarks,                Msm_Remark),
                   Msm_Amc_Sch_Cd              = Nvl(l_Msm_Amc_Sch_Cd,             Msm_Amc_Sch_Cd),
                   Msm_Prg_Id                  = l_Prg_Id,
                   Msm_Nse_Unique_No           = Nvl(l_Msm_Nse_Unique_No,          Msm_Nse_Unique_No),
                   Msm_Amc_Code                = Nvl(l_Nse_Amc_Code,               Msm_Amc_Code),
                   Msm_Nfo_Allotment_Date      = Nvl(l_Msm_Nfo_Allotment_Date,     Msm_Nfo_Allotment_Date),
                   Msm_Sec_Depmandatory        = Nvl(l_Msm_Sec_Depmandatory,       Msm_Sec_Depmandatory),
                   Msm_Sec_Allowdep            = Nvl(l_Msm_Sec_Allowdep,           Msm_Sec_Allowdep),
                   Msm_Scheme_Depcode          = Nvl(l_Msm_Scheme_Depcode,         Msm_Scheme_Depcode),
                   Msm_Sec_Mod_Cxl             = Nvl(l_Msm_Sec_Mod_Cxl,            Msm_Sec_Mod_Cxl),
                   Msm_Max_Depaddlsubval_Lmt   = Nvl(l_Msm_Add_Pur_Amt_Nse,        Msm_Max_Depaddlsubval_Lmt),
                   Msm_Cat_Start_Time          = Nvl(l_Msm_Cat_Start_Time,         Msm_Cat_Start_Time),
                   Msm_Cat_End_Time            = Nvl(l_Msm_Cat_End_Time,           Msm_Cat_End_Time),
                   Msm_Qty_Dec_Indicator       = Nvl(l_Msm_Qty_Dec_Indicator,      Msm_Qty_Dec_Indicator),
                   Msm_Val_Dec_Indicator       = Nvl(l_Msm_Val_Dec_Indicator,      Msm_Val_Dec_Indicator),
                   Msm_Min_Pur_Amt_Nse         = Nvl(l_Msm_Min_Pur_Amt_Nse,        Msm_Min_Pur_Amt_Nse),
                   Msm_Max_Pur_Amt_Nse         = Nvl(l_Msm_Max_Pur_Amt_Nse,        Msm_Max_Pur_Amt_Nse),
                   Msm_Purc_Amt_Multiplier_Nse = Nvl(l_Msm_Pur_Amt_Mul_Nse,        Msm_Purc_Amt_Multiplier_Nse),
                   Msm_Addtnl_Pur_Amt_Nse      = Nvl(l_Msm_Min_Depaddlsubval_Lmt,  Msm_Addtnl_Pur_Amt_Nse),
                   Msm_Add_Pur_Amt_Mul_Nse     = Nvl(l_Msm_Pur_Amt_Mul_Nse,        Msm_Add_Pur_Amt_Mul_Nse),
                   Msm_Min_Redem_Qty_Nse       = Nvl(l_Msm_Min_Redem_Qty_Nse,      Msm_Min_Redem_Qty_Nse),
                   Msm_Max_Redem_Qty_Nse       = Nvl(l_Msm_Max_Redem_Qty_Nse,      Msm_Max_Redem_Qty_Nse),
                   Msm_Min_Pur_Amt             = Nvl(l_Msm_Min_Pur_Amt,            Msm_Min_Pur_Amt),
                   Msm_Max_Pur_Amt             = Nvl(l_Msm_Max_Pur_Amt,            Msm_Max_Pur_Amt),
                   Msm_Add_Pur_Amt_Mul         = Nvl(l_Msm_Add_Pur_Amt_Mul,        Msm_Add_Pur_Amt_Mul),
                   Msm_Min_Redem_Qty           = Nvl(l_Msm_Min_Redem_Qty,          Msm_Min_Redem_Qty),
                   Msm_Max_Redem_Qty           = Nvl(l_Msm_Max_Redem_Qty,          Msm_Max_Redem_Qty),
                   Msm_Pur_Amt_Mul             = Nvl(l_Msm_Pur_Amt_Mul,            Msm_Pur_Amt_Mul),
                   Msm_Add_Pur_Amt             = Nvl(l_Msm_Add_Pur_Amt,            Msm_Add_Pur_Amt),
                   Msm_Min_Redem_Amt           = Nvl(l_Msm_Min_Redem_Amt,          Msm_Min_Redem_Amt),
                   Msm_Max_Redem_Amt           = Nvl(l_Msm_Max_Redem_Amt,          Msm_Max_Redem_Amt),
                   Msm_Nse_Pur_Cut_Off         = Nvl(l_Msm_Cat_End_Time,           Msm_Nse_Pur_Cut_Off),
                   Msm_Nse_Redem_Cut_Off       = Nvl(l_Msm_Cat_End_Time,           Msm_Nse_Redem_Cut_Off),
                   Msm_Settlement_Type         = Nvl(l_Msm_Settlement_Type,        Msm_Settlement_Type),
                   Msm_Nfo_Yn                  = Nvl(l_Msm_Nfo_Yn,                 Msm_Nfo_Yn),
                   Msm_Nfo_Time                = Nvl(To_Char(Greatest(To_Date(l_Msm_Cat_End_Time,'HH24:MI:SS'),To_Date(Msm_Nfo_Time,'HH24:MI:SS')),'HH24:MI:SS'),Msm_Nfo_Time),
                   Msm_Nse_Sip_Allowed         = Nvl(l_Msm_Sip_Yn , Msm_Nse_Sip_Allowed)
            WHERE  Msm_Scheme_Id               = r_Mfd_Scheme_Master.Msm_Scheme_Id
            AND    Msm_Record_Status           = 'A'
            AND    Msm_Status                  = 'A'
            AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);

          ELSIF l_Nse_Category_Code = 'DBTCR' THEN

            UPDATE Mfd_Scheme_Master m
            SET    Msm_L1_Allowed_Yn          =    Decode(l_Eligibility_Flg,0,Decode(Trunc(Msm_Bse_L1_Updt_Dt),Trunc(SYSDATE),Msm_L1_Allowed_Yn,'N'),'Y'),
                   Msm_Nse_L1_Settlement_Type =    'L1',
                   Msm_Nse_L1_Unique_No       =    Nvl(l_Msm_Nse_Unique_No         , Msm_Nse_L1_Unique_No      ),
                   Msm_Nse_L1_Scheme_Code     =    Nvl(l_Msm_Nse_Code              , Msm_Nse_L1_Scheme_Code    ),
                   Msm_Nse_L1_Pur_Cut_Off     =    Nvl(l_Msm_Cat_End_Time          , Msm_Nse_L1_Pur_Cut_Off    ),
                   Msm_Nse_L1_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt_Nse       , Msm_Nse_L1_Min_Pur_Amt       ),
                   Msm_Nse_L1_Max_Pur_Amt     =    Nvl(l_Msm_Max_Pur_Amt_Nse       , Msm_Nse_L1_Max_Pur_Amt),
                   Msm_Nse_L1_Addtnl_Pur_Amt  =    Nvl(l_Msm_Min_Depaddlsubval_Lmt , Msm_Nse_L1_Addtnl_Pur_Amt),
                   Msm_Nse_L1_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul_Nse      , Msm_Nse_L1_Purc_Amt_Multiplier),
                   Msm_Nse_L1_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul_Nse       , Msm_Nse_L1_Add_Pur_Amt_Mul),
                   Msm_Nse_L1_Sch_Cat         =    Nvl(l_Nse_Category_Code         , Msm_Nse_L1_Sch_Cat),
                   Msm_Pur_Allowed_Nse_L1     =    Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed)  , Msm_Pur_Allowed_Nse_L1),
                  -- Msm_Nse_Allowed            =    Decode(l_Eligibility_Flg,0,'N','Y'),
                   Msm_Last_Updt_By           =    USER,
                   Msm_Nse_l1_Updt_Dt         =    SYSDATE
            WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
            AND    Msm_Status                 =    'A'
            AND    Msm_Record_Status          =    'A'
            AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);

       ELSIF l_Nse_Category_Code = 'HLIQD' THEN

          UPDATE Mfd_Scheme_Master m
          SET    Msm_LO_Allowed_Yn          =    Decode(l_Eligibility_Flg,0,Decode(Trunc(Msm_Bse_Lo_Updt_Dt),Trunc(SYSDATE),Msm_LO_Allowed_Yn,'N'),'Y'),
                 Msm_Nse_LO_Settlement_Type =    'L0',
                 Msm_Nse_LO_Unique_No       =    Nvl(l_Msm_Nse_Unique_No         , Msm_Nse_LO_Unique_No      ),
                 Msm_Nse_LO_Scheme_Code     =    Nvl(l_Msm_Nse_Code              , Msm_Nse_LO_Scheme_Code    ),
                 Msm_Nse_LO_Pur_Cut_Off     =    Nvl(l_Msm_Cat_End_Time          , Msm_Nse_LO_Pur_Cut_Off    ),
                 Msm_Nse_LO_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt_Nse       , Msm_Nse_LO_Min_Pur_Amt       ),
                 Msm_Nse_LO_Max_Pur_Amt     =    Nvl(l_Msm_Max_Pur_Amt_Nse       , Msm_Nse_LO_Max_Pur_Amt),
                 Msm_Nse_LO_Addtnl_Pur_Amt  =    Nvl(l_Msm_Min_Depaddlsubval_Lmt , Msm_Nse_LO_Addtnl_Pur_Amt),
                 Msm_Nse_LO_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul_Nse      , Msm_Nse_LO_Purc_Amt_Multiplier),
                 Msm_Nse_LO_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul_Nse       , Msm_Nse_LO_Add_Pur_Amt_Mul),
                 Msm_Nse_LO_Sch_Cat         =    Nvl(l_Nse_Category_Code         , Msm_Nse_LO_Sch_Cat),
                 Msm_Pur_Allowed_Nse_L0     =    Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed)  , Msm_Pur_Allowed_Nse_L0),
                 --Msm_Nse_Allowed            =    Decode(l_Eligibility_Flg,0,'N','Y'),
                 Msm_Nse_lo_Updt_Dt         =    USER,
                 Msm_Last_Updt_Dt           =    SYSDATE
          WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Status                 =    'A'
          AND    Msm_Record_Status          =    'A'
          AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);

        END IF;

     END p_Full_Upd_Scheme_Master;

     PROCEDURE Null_Upd_Scheme_Master IS
     BEGIN
        IF  l_Nse_Category_Code NOT IN ( 'DBTCR','HLIQD') THEN
          /* Coomon Fields are null updated and NSE Fields are fully updated */
          UPDATE Mfd_Scheme_Master
          SET    Msm_Scheme_Desc             = Nvl(Msm_Scheme_Desc,            l_Msm_Scheme_Desc ),
                 Msm_Amc_Id                  = Nvl(l_Msm_Amc_Id,               Msm_Amc_Id),
                 Msm_Rta_Id                  = Nvl(l_Msm_Rta_Id,               Msm_Rta_Id),
                 Msm_Scheme_Type             = Nvl(l_Msm_Scheme_Type,          Msm_Scheme_Type),
                 Msm_Nse_Code                = Nvl(l_Msm_Nse_Code,             Msm_Nse_Code),
                 Msm_Isin                    = Nvl(Msm_Isin,                   l_Msm_Isin),
                 Msm_Rta_Sch_Cd              = Nvl(l_Msm_Rta_Sch_Cd,           Msm_Rta_Sch_Cd),
                 Msm_Sch_Cat                 = Nvl(l_Nse_Category_Code,        Msm_Sch_Cat),
                 Msm_Nfo_From_Date           = Nvl(l_Msm_Nfo_From_Date,        Msm_Nfo_From_Date),
                 Msm_Nfo_To_Date             = Nvl(l_Msm_Nfo_To_Date,          Msm_Nfo_To_Date),
                 --Msm_Pur_Allowed_Nse         = Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed)  , Msm_Pur_Allowed_Nse),
                 Msm_Pur_Allowed_Nse         = Nvl(Decode(l_Eligibility_Flg,0,'N',Decode(l_Nfo_allowd,1,'N',l_Msm_Pur_Allowed))  , Msm_Pur_Allowed_Nse),
                 Msm_Redem_Allowed_Nse       = Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Redem_Allowed), Msm_Redem_Allowed_Nse),
                 --Msm_Nse_Allowed             = Decode(l_Eligibility_Flg,0,'N','Y'),
                 Msm_Nse_Allowed             = Decode(l_Eligibility_Flg,0,'N',Decode(l_Nfo_allowd,1,'N','Y')),
                 Msm_Demat_Yn                = Nvl(l_Msm_Demat_Yn,             Msm_Demat_Yn),
                 Msm_Sip_Yn                  = Nvl(Msm_Sip_Yn,                 l_Msm_Sip_Yn),
                 Msm_Div_Option              = Nvl(Msm_Div_Option,             l_Msm_Div_Option),
                 Msm_Last_Updt_By            = USER,
                 Msm_Nse_Updt_Dt             = SYSDATE,
                 Msm_Source                  = 'N',
                 Msm_Amc_Name                = Nvl(l_Msm_Amc_Name,              Msm_Amc_Name),
                 Msm_Remark                  = Nvl(l_Msm_Remarks,               Msm_Remark),
                 Msm_Amc_Sch_Cd              = Nvl(l_Msm_Amc_Sch_Cd,            Msm_Amc_Sch_Cd),
                 Msm_Prg_Id                  = l_Prg_Id,
                 Msm_Nse_Unique_No           = Nvl(l_Msm_Nse_Unique_No,         Msm_Nse_Unique_No),
                 Msm_Amc_Code                = Nvl(l_Nse_Amc_Code,              Msm_Amc_Code),
                 Msm_Nfo_Allotment_Date      = Nvl(l_Msm_Nfo_Allotment_Date,    Msm_Nfo_Allotment_Date),
                 Msm_Sec_Depmandatory        = Nvl(l_Msm_Sec_Depmandatory,      Msm_Sec_Depmandatory),
                 Msm_Sec_Allowdep            = Nvl(l_Msm_Sec_Allowdep,          Msm_Sec_Allowdep),
                 Msm_Scheme_Depcode          = Nvl(l_Msm_Scheme_Depcode,        Msm_Scheme_Depcode),
                 Msm_Sec_Mod_Cxl             = Nvl(Msm_Sec_Mod_Cxl,             l_Msm_Sec_Mod_Cxl),
                 Msm_Max_Depaddlsubval_Lmt   = Nvl(l_Msm_Add_Pur_Amt_Nse,       Msm_Max_Depaddlsubval_Lmt),
                 Msm_Cat_Start_Time          = Nvl(Msm_Cat_Start_Time,          l_Msm_Cat_Start_Time),
                 Msm_Cat_End_Time            = Nvl(l_Msm_Cat_End_Time,          Msm_Cat_End_Time),
                 Msm_Qty_Dec_Indicator       = Nvl(l_Msm_Qty_Dec_Indicator,     Msm_Qty_Dec_Indicator),
                 Msm_Val_Dec_Indicator       = Nvl(l_Msm_Val_Dec_Indicator,     Msm_Val_Dec_Indicator),
                 Msm_Min_Pur_Amt_Nse         = Nvl(l_Msm_Min_Pur_Amt_Nse,       Msm_Min_Pur_Amt_Nse),
                 Msm_Max_Pur_Amt_Nse         = Nvl(l_Msm_Max_Pur_Amt_Nse,       Msm_Max_Pur_Amt_Nse),
                 Msm_Purc_Amt_Multiplier_Nse = Nvl(l_Msm_Pur_Amt_Mul_Nse ,      Msm_Purc_Amt_Multiplier_Nse),
                 Msm_Addtnl_Pur_Amt_Nse      = Nvl(l_Msm_Min_Depaddlsubval_Lmt, Msm_Addtnl_Pur_Amt_Nse),
                 Msm_Add_Pur_Amt_Mul_Nse     = Nvl(l_Msm_Pur_Amt_Mul_Nse,   Msm_Add_Pur_Amt_Mul_Nse),
                 Msm_Min_Redem_Qty_Nse       = Nvl(l_Msm_Min_Redem_Qty_Nse,     Msm_Min_Redem_Qty_Nse),
                 Msm_Max_Redem_Qty_Nse       = Nvl(l_Msm_Max_Redem_Qty_Nse,     Msm_Max_Redem_Qty_Nse),
                 Msm_Min_Pur_Amt             = Nvl(l_Msm_Min_Pur_Amt,           Msm_Min_Pur_Amt),
                 Msm_Max_Pur_Amt             = Nvl(l_Msm_Max_Pur_Amt,           Msm_Max_Pur_Amt),
                 Msm_Add_Pur_Amt_Mul         = Nvl(l_Msm_Add_Pur_Amt_Mul,       Msm_Add_Pur_Amt_Mul),
                 Msm_Min_Redem_Qty           = Nvl(l_Msm_Min_Redem_Qty,         Msm_Min_Redem_Qty),
                 Msm_Max_Redem_Qty           = Nvl(l_Msm_Max_Redem_Qty,         Msm_Max_Redem_Qty),
                 Msm_Pur_Amt_Mul             = Nvl(l_Msm_Pur_Amt_Mul,           Msm_Pur_Amt_Mul),
                 Msm_Add_Pur_Amt             = Nvl(l_Msm_Add_Pur_Amt,           Msm_Add_Pur_Amt),
                 Msm_Min_Redem_Amt           = Nvl(l_Msm_Min_Redem_Amt,         Msm_Min_Redem_Amt),
                 Msm_Max_Redem_Amt           = Nvl(l_Msm_Max_Redem_Amt,         Msm_Max_Redem_Amt),
                 Msm_Nse_Pur_Cut_Off         = Nvl(l_Msm_Cat_End_Time,          Msm_Nse_Pur_Cut_Off),
                 Msm_Nse_Redem_Cut_Off       = Nvl(l_Msm_Cat_End_Time,          Msm_Nse_Redem_Cut_Off),
                 Msm_Settlement_Type         = Nvl(Msm_Settlement_Type,         l_Msm_Settlement_Type),
                 Msm_Nfo_Yn                  = Nvl(l_Msm_Nfo_Yn,                Msm_Nfo_Yn),
                 Msm_Nfo_Time                = Nvl(To_Char(Greatest(To_Date(l_Msm_Cat_End_Time,'HH24:MI:SS'),To_Date(Msm_Nfo_Time,'HH24:MI:SS')),'HH24:MI:SS'),Msm_Nfo_Time),
                 Msm_Nse_Sip_Allowed         = Nvl(l_Msm_Sip_Yn , Msm_Nse_Sip_Allowed)
          WHERE  Msm_Scheme_Id               = r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Record_Status           = 'A'
          AND    Msm_Status                  = 'A'
          AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);

         ELSIF l_Nse_Category_Code = 'DBTCR' THEN

          UPDATE Mfd_Scheme_Master m
          SET    Msm_L1_Allowed_Yn          =    Decode(l_Eligibility_Flg,0,Decode(Trunc(Msm_Bse_L1_Updt_Dt),Trunc(SYSDATE),Msm_L1_Allowed_Yn,'N'),'Y'),
                 Msm_Nse_L1_Settlement_Type =    'L1',
                 Msm_Nse_L1_Unique_No       =    Nvl(l_Msm_Nse_Unique_No         ,Msm_Nse_L1_Unique_No     ),
                 Msm_Nse_L1_Scheme_Code     =    Nvl(l_Msm_Nse_Code              ,Msm_Nse_L1_Scheme_Code   ),
                 Msm_Nse_L1_Pur_Cut_Off     =    Nvl(l_Msm_Cat_End_Time          ,Msm_Nse_L1_Pur_Cut_Off   ),
                 Msm_Nse_L1_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt_Nse       ,Msm_Nse_L1_Min_Pur_Amt   ),
                 Msm_Nse_L1_Max_Pur_Amt     =    Nvl(l_Msm_Max_Pur_Amt_Nse       ,Msm_Nse_L1_Max_Pur_Amt   ),
                 Msm_Nse_L1_Addtnl_Pur_Amt  =    Nvl(l_Msm_Min_Depaddlsubval_Lmt ,Msm_Nse_L1_Addtnl_Pur_Amt),
                 Msm_Nse_L1_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul_Nse      ,Msm_Nse_L1_Purc_Amt_Multiplier ),
                 Msm_Nse_L1_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul_Nse       ,Msm_Nse_L1_Add_Pur_Amt_Mul),
                 Msm_Nse_L1_Sch_Cat         =    Nvl(l_Nse_Category_Code         ,Msm_Nse_L1_Sch_Cat      ),
                 Msm_Pur_Allowed_Nse_L1     =    Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed)  , Msm_Pur_Allowed_Nse_L1),
                -- Msm_Nse_Allowed            =    Decode(l_Eligibility_Flg,0,'N','Y'),
                 Msm_Last_Updt_By           =    USER,
                 Msm_Nse_l1_Updt_Dt         =    SYSDATE
          WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Status                 =    'A'
          AND    Msm_Record_Status          =    'A'
          AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);

      ELSIF l_Nse_Category_Code = 'HLIQD' THEN


        UPDATE Mfd_Scheme_Master m
        SET    Msm_LO_Allowed_Yn          =    Decode(l_Eligibility_Flg,0,Decode(Trunc(Msm_Bse_Lo_Updt_Dt),Trunc(SYSDATE),Msm_LO_Allowed_Yn,'N'),'Y'),
               Msm_Nse_LO_Settlement_Type =    'L0',
               Msm_Nse_LO_Unique_No       =    Nvl(l_Msm_Nse_Unique_No         ,Msm_Nse_LO_Unique_No     ),
               Msm_Nse_LO_Scheme_Code     =    Nvl(l_Msm_Nse_Code              ,Msm_Nse_LO_Scheme_Code   ),
               Msm_Nse_LO_Pur_Cut_Off     =    Nvl(l_Msm_Cat_End_Time          ,Msm_Nse_LO_Pur_Cut_Off   ),
               Msm_Nse_LO_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt_Nse       ,Msm_Nse_LO_Min_Pur_Amt   ),
               Msm_Nse_LO_Max_Pur_Amt     =    Nvl(l_Msm_Max_Pur_Amt_Nse       ,Msm_Nse_LO_Max_Pur_Amt   ),
               Msm_Nse_LO_Addtnl_Pur_Amt  =    Nvl(l_Msm_Min_Depaddlsubval_Lmt ,Msm_Nse_LO_Addtnl_Pur_Amt),
               Msm_Nse_LO_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul_Nse      ,Msm_Nse_LO_Purc_Amt_Multiplier ),
               Msm_Nse_LO_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul_Nse       ,Msm_Nse_LO_Add_Pur_Amt_Mul),
               Msm_Nse_LO_Sch_Cat         =    Nvl(l_Nse_Category_Code         ,Msm_Nse_LO_Sch_Cat      ),
               Msm_Pur_Allowed_Nse_L0     =    Nvl(Decode(l_Eligibility_Flg,0,'N',l_Msm_Pur_Allowed)  , Msm_Pur_Allowed_Nse_L0),
             --  Msm_Nse_Allowed            =    Decode(l_Eligibility_Flg,0,'N','Y'),
               Msm_Last_Updt_By           =    USER,
               Msm_Nse_lo_Updt_Dt         =    SYSDATE
        WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
        AND    Msm_Status                 =    'A'
        AND    Msm_Record_Status          =    'A'
        AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);
     END IF;

     END  Null_Upd_Scheme_Master;


     FUNCTION Comp_Col(P_Desc    IN VARCHAR2,
                       P_Tab     IN VARCHAR2,
                       P_Var     IN VARCHAR2,
                       P_Ret_Str IN VARCHAR2) RETURN VARCHAR2 IS
     BEGIN
       IF P_Tab <> P_Var THEN
         IF P_Ret_Str IS NULL THEN
            RETURN P_Desc;
         ELSE
            RETURN P_Ret_Str||','||P_Desc ;
          END IF ;
       END IF ;
       RETURN P_Ret_Str;
     END Comp_Col ;

     PROCEDURE p_Write_Change_Skip_In_Log
     IS
        l_Str VARCHAR2(10000) := NULL;
     BEGIN
        l_Str := Comp_Col('NSE Unique No'            , r_Mfd_Scheme_Master.Msm_Nse_Unique_No    , l_Msm_Nse_Unique_No    ,l_Str);
        l_Str := Comp_Col('NSE Code'                 , r_Mfd_Scheme_Master.Msm_Nse_Code         , l_Msm_Nse_Code         ,l_Str);
        l_Str := Comp_Col('RTA Scheme Code'          , r_Mfd_Scheme_Master.Msm_Rta_Sch_Cd       , l_Msm_Rta_Sch_Cd       ,l_Str);
        l_Str := Comp_Col('AMC Scheme Code'          , r_Mfd_Scheme_Master.Msm_Amc_Sch_Cd       , l_Msm_Amc_Sch_Cd       ,l_Str);
        l_Str := Comp_Col('ISIN'                     , r_Mfd_Scheme_Master.Msm_Isin             , l_Msm_Isin             ,l_Str);
        l_Str := Comp_Col('Scheme Desc'              , r_Mfd_Scheme_Master.Msm_Scheme_Desc      , l_Msm_Scheme_Desc      ,l_Str);
        l_Str := Comp_Col('Purchase Allowed'         , r_Mfd_Scheme_Master.Msm_Pur_Allowed      , l_Msm_Pur_Allowed      ,l_Str);
        l_Str := Comp_Col('Redemption Allow'         , r_Mfd_Scheme_Master.Msm_Redem_Allowed    , l_Msm_Redem_Allowed    ,l_Str);
        l_Str := Comp_Col('SIP Yn'                   , r_Mfd_Scheme_Master.Msm_Sip_Yn           , l_Msm_Sip_Yn           ,l_Str);

       IF l_Str IS NOT NULL THEN
         IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
           Utl_File.Put_Line(l_Log_File_Handle,'Updated fields which were null except '||l_Str ||'> for ISIN <'||l_Msm_Isin||'>.');
         END IF;
         l_Count_Change_Skip  :=  l_Count_Change_Skip + 1;
       END IF ;

     END P_Write_Change_Skip_In_Log;

     PROCEDURE P_Assign_Into_Variables
     IS
     BEGIN
       l_Change_New                   := NULL;
       l_Msm_Nse_Unique_No            := TRIM(l_Nse_Tab(1));
       l_Symbol_Msm_Nse_Code          := TRIM(l_Nse_Tab(2));
       l_Series_Msm_Nse_Code          := TRIM(l_Nse_Tab(3));
       l_Msm_Max_Redem_Qty            := TRIM(l_Nse_Tab(5));
       l_Msm_Rta_Sch_Cd               := TRIM(l_Nse_Tab(6));
       l_Msm_Amc_Sch_cd               := TRIM(l_Nse_Tab(7));
       l_Msm_Demat_Yn                 := TRIM(l_Nse_Tab(8));
       l_Msm_Isin                     := TRIM(l_Nse_Tab(9));
       l_Msm_Status                   := TRIM(l_Nse_Tab(11)); -- Need to identify values
       l_Eligibility_Flg              := TRIM(l_Nse_Tab(16)); -- Flag to determine whether record to skip record
       l_Nse_Amc_Code                 := TRIM(l_Nse_Tab(19));  -- This RTA Amc Code 20-Jul-2012
       l_Nse_Category_Code            := TRIM(l_Nse_Tab(20));
       l_Msm_Scheme_Desc              := TRIM(l_Nse_Tab(21));
       l_Msm_Add_Pur_Amt_Mul          := TRIM(l_Nse_Tab(23));--Phy
       l_Nse_Rta_Code                 := TRIM(l_Nse_Tab(26)); -- RTA Code
       l_Msm_Val_Dec_Indicator        := TRIM(l_Nse_Tab(27));
       l_Msm_Cat_Start_Time           := TRIM(l_Nse_Tab(28));
       l_Msm_Qty_Dec_Indicator        := TRIM(l_Nse_Tab(29));
       l_Msm_Cat_End_Time             := TRIM(l_Nse_Tab(30));
       l_Msm_Min_Pur_Amt              := TRIM(l_Nse_Tab(31));--Phy
       l_Msm_Max_Redem_Amt            := TRIM(l_Nse_Tab(32));--Phy
       l_Msm_Nfo_To_Date              := TRIM(l_Nse_Tab(33));-- NFO
       l_Msm_Nfo_From_Date            := TRIM(l_Nse_Tab(34));-- NFO
       l_Msm_Nfo_Allotment_Date       := TRIM(l_Nse_Tab(36));-- NFO
       l_Msm_Sec_Depmandatory         := TRIM(l_Nse_Tab(40));
       l_Msm_Sec_Allowdep             := TRIM(l_Nse_Tab(42));
       l_Msm_Redem_Allowed            := TRIM(l_Nse_Tab(43));
       l_Msm_Sec_Mod_Cxl              := TRIM(l_Nse_Tab(44));
       l_Msm_Pur_Allowed              := TRIM(l_Nse_Tab(45));
       l_Msm_Min_Redem_Amt            := TRIM(l_Nse_Tab(46));--Phy
       l_Msm_Min_Redem_Qty            := TRIM(l_Nse_Tab(47));--Phy
       l_Msm_Remarks                  := TRIM(l_Nse_Tab(57));
       l_Msm_Sip_YN                   := TRIM(l_Nse_Tab(58));
       l_Msm_Max_Pur_Amt              := TRIM(l_Nse_Tab(59));--Phy
       l_Msm_Add_Pur_Amt              := TRIM(l_Nse_Tab(60));--Phy
       l_Msm_Max_Pur_Amt_Nse          := TRIM(l_Nse_Tab(61));
       l_Msm_Add_Pur_Amt_Nse          := TRIM(l_Nse_Tab(62));
       l_Msm_Min_Pur_Amt_Nse          := TRIM(l_Nse_Tab(63));
       l_Msm_Min_Depaddlsubval_Lmt    := TRIM(l_Nse_Tab(64));
       l_Msm_Max_Redem_Qty_Nse        := TRIM(l_Nse_Tab(65));
       l_Msm_Min_Redem_Qty_Nse        := TRIM(l_Nse_Tab(66));
       l_Msm_Pur_Amt_Mul              := TRIM(l_Nse_Tab(67));--Phy
       l_Msm_Pur_Amt_Mul_Nse          := TRIM(l_Nse_Tab(68));
       l_Msm_Amc_Name                 := Upper(TRIM(l_Nse_Tab(69)));

       --As in nse file amount comes in Paise
       l_Msm_Max_Pur_Amt_Nse          := l_Msm_Max_Pur_Amt_Nse/100;
       l_Msm_Add_Pur_Amt_Nse          := l_Msm_Add_Pur_Amt_Nse/100;
       l_Msm_Min_Pur_Amt_Nse          := l_Msm_Min_Pur_Amt_Nse/100;
       l_Msm_Min_Depaddlsubval_Lmt    := l_Msm_Min_Depaddlsubval_Lmt/100;


       -- As to Convert into Time formt HH:MM:SI -14-Jul-2012 as sent by Sumit
       SELECT  Decode(Length(l_Msm_Cat_Start_Time),2,l_Msm_Cat_Start_Time,
                                 4, Substr(l_Msm_Cat_Start_Time,1,2)||':'||substr(l_Msm_Cat_Start_Time,3,2),
                                 6, Substr(l_Msm_Cat_Start_Time,1,2)||':'||substr(l_Msm_Cat_Start_Time,3,2)||':'||Substr(l_Msm_Cat_Start_Time,5,2))
       INTO l_Msm_Cat_Start_Time
       FROM Dual;

       SELECT  Decode(Length(l_Msm_Cat_End_Time),2,l_Msm_Cat_End_Time,
                                 4, Substr(l_Msm_Cat_End_Time,1,2)||':'||substr(l_Msm_Cat_End_Time,3,2),
                                 6, Substr(l_Msm_Cat_End_Time,1,2)||':'||substr(l_Msm_Cat_End_Time,3,2)||':'||Substr(l_Msm_Cat_End_Time,5,2))
       INTO l_Msm_Cat_End_Time
       FROM Dual;

       -- As to Convert into Time formt HH:MM:SI -14-Jul-2012 as sent by Sumit

       l_Msm_Nfo_To_Date        := To_Char(To_Date('1980-01-01', 'YYYY-MM-DD') + Numtodsinterval(To_Number(l_Msm_Nfo_To_Date), 'SECOND'),'DD-MON-YYYY');
       l_Msm_Nfo_From_Date      := To_Char(To_Date('1980-01-01', 'YYYY-MM-DD') + Numtodsinterval(To_Number(l_Msm_Nfo_From_Date), 'SECOND'),'DD-MON-YYYY');
       l_Msm_Nfo_Allotment_Date := To_Char(To_Date('1980-01-01', 'YYYY-MM-DD') + Numtodsinterval(To_Number(l_Msm_Nfo_Allotment_Date), 'SECOND'),'DD-MON-YYYY');

       IF Upper(l_Msm_Nfo_To_Date) = '01-JAN-1980' THEN
          l_Msm_Nfo_To_Date :=  NULL;
       END IF;

       IF Upper(l_Msm_Nfo_From_Date) = '01-JAN-1980' THEN
          l_Msm_Nfo_From_Date := NULL;
       END IF;

       IF Upper(l_Msm_Nfo_Allotment_Date) = '01-JAN-1980' THEN
          l_Msm_Nfo_Allotment_Date := NULL;
       END IF;

       IF To_Date(l_Msm_Nfo_From_Date,'DD-MON-YYYY') <= l_Pam_Curr_Dt AND To_Date(l_Msm_Nfo_To_Date,'DD-MON-YYYY') >= l_Pam_Curr_Dt THEN
          l_Msm_Nfo_Yn := 'Y';
       ELSE
          l_Msm_Nfo_Yn := 'N';
       END IF;

       l_Nfo_allowd := 0;
       IF Substr(l_Nse_Category_Code,1,3) = 'NFO' AND
          NVl(l_Msm_Nfo_Yn,'N')           = 'N'   AND
          l_Eligibility_Flg               = 1    THEN
          l_Nfo_allowd                   := 1;
       END IF;

       l_Msm_Nse_Code := l_Symbol_Msm_Nse_Code || l_Series_Msm_Nse_Code;

       IF l_Series_Msm_Nse_Code = 'GR' Then
          l_Msm_Div_Option := 'G' ;
       ELSIF l_Series_Msm_Nse_Code = 'DP' Then
          l_Msm_Div_Option := 'P';
       ELSIF l_Series_Msm_Nse_Code = 'DR' Then
          l_Msm_Div_Option := 'R' ;
       ELSIF l_Series_Msm_Nse_Code = 'LQ' Then
          l_Msm_Div_Option := 'G' ; -- to be changed later as per actual
          l_LQ_Count := l_LQ_Count + 1;
          IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
             Utl_File.Put_Line(l_Log_File_Handle,'Marking Default Dividend option flag to <Growth> for Scheme series <'||l_Series_Msm_Nse_Code||'> and ISIN <'||l_Msm_Isin ||'>');
          END IF;
       ELSE
         P_Ret_Msg := 'Record skipped due to Scheme series <'|| l_Series_Msm_Nse_Code ||'> is not valid.';
         RAISE E_User_Exp;
       END IF;

       l_Msm_Scheme_Depcode := l_Msm_Demat_Yn; --- Depository NSDL-N,CDSL-C and Both-B

       IF l_Msm_Demat_Yn in ('N','C','B') Then
          l_Msm_Demat_Yn    := 'Y' ;
          l_Msm_Physical_Yn := 'Y';
       ELSIF l_Msm_Demat_Yn IS NULL THEN
          l_Msm_Physical_Yn := 'N';
          l_Msm_Demat_Yn    := 'N' ;
       ELSE
          l_Msm_Physical_Yn := 'Y';
          l_Msm_Demat_Yn    := 'N' ;
       END IF ;

       IF l_Msm_Redem_Allowed = 1 Then
          l_Msm_Redem_Allowed := 'Y' ;
       ELSE
          l_Msm_Redem_Allowed := 'N' ;
       END IF ;

       IF l_Msm_Pur_Allowed = 1 Then
          l_Msm_Pur_Allowed := 'Y' ;
       ELSE
          l_Msm_Pur_Allowed  := 'N' ;
       END IF;

     END P_Assign_Into_Variables;

     PROCEDURE P_Validate_Data
     IS
     BEGIN
           l_Mand_Fields_Msg := '';
           l_Skip_Yn         := 'N';
        IF l_Msm_Scheme_Desc IS NULL THEN
           l_Mand_Fields_Msg := 'Scheme Desc' ;
           l_Skip_Yn         := 'Y';
        END IF;

        IF l_Msm_Nse_Code IS NULL OR l_Msm_Nse_Unique_No IS NULL THEN
           l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'EITHER--NSE CODE OR NSE UNIQUE NO' ;
           l_Skip_Yn         := 'Y';
        END IF;

        IF l_Symbol_Msm_Nse_Code IS NULL OR l_Series_Msm_Nse_Code IS NULL THEN
           l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'EITHER--NSE SYMBOL OR NSE SERIES' ;
           l_Skip_Yn         := 'Y';
        END IF;

        IF l_Msm_Isin IS NULL THEN
           l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'ISIN';
           l_Skip_Yn         := 'Y';
        END IF;

        IF l_Skip_Yn = 'Y' THEN
           P_Ret_Msg := l_Mand_Fields_Msg;
           RAISE E_Mand_Exp;
        END IF;

    END P_Validate_Data;

  BEGIN

    P_Ret_Msg := ' Performing Housekeeping Activities ';
    Std_Lib.P_Housekeeping (l_Prg_Id,             'NSE',              'NSE'||'-'||P_File_Name,    'N',
                            l_Log_File_Handle,    l_Log_File_Name,    l_Prg_Process_Id,           'Y');

    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;
    l_File_Ptr    := Utl_File.fopen(P_Path,P_File_Name,'R');

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' || To_Char(l_Pam_Curr_Dt, 'DD-MON-RRRR'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange           :     ' || 'NSE');
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name          :     ' || P_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    p_Ret_Msg := ' Populating PlSql table for MFD Schemes ';
    SELECT COUNT(1)
    INTO   l_Count_Bse
    FROM   Program_Status
    WHERE  Prg_Dt     = l_Pam_Curr_Dt
    AND    Prg_Cmp_Id = 'MFSSSITE'
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = 'BSE';

    IF l_Count_Bse = 0 THEN
      p_Ret_Msg := 'BSE Scheme master file has not been loaded for the day.Please load BSE File(Primary File)  First.';
      Utl_File.Put_Line(l_Log_File_Handle,p_Ret_Msg );
      RAISE Ue_Exception;
    END IF;

    SELECT Nvl(MAX(Rv_Low_Value),'NSE')
    INTO   l_Primary_File
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'MFD_PRIMARY_SCHEME_FILE';

    P_Ret_Msg := ' Populating PlSql table for MFD Schemes ';
    FOR i IN (SELECT Msm_Scheme_Id,
                     Msm_Isin
              FROM   Mfd_Scheme_Master
              WHERE  Msm_Status         = 'A'
              AND    Msm_Record_Status  = 'A')
    LOOP
      Tab_Mfd_Schemes(i.Msm_Scheme_Id) := i.Msm_Isin;
    END LOOP;

    LOOP
    P_Ret_Msg:=Null;
      BEGIN
        Utl_File.Get_Line(l_File_Ptr,l_Line_Buffer);
        l_Line_Buffer := Trim(l_Line_Buffer);
        IF l_Line_Buffer is Not Null Then
          l_Line_Buffer := Std_Lib.Remove_Invalid_Char(l_Line_Buffer);
        END IF ;
      EXCEPTION
        WHEN No_Data_Found Then
          RAISE End_Of_File;
      END ;
      l_Line_No := l_Line_No + 1;

     Savepoint currline ;

     BEGIN
      IF l_Line_No > 1 AND l_Line_Buffer is Not Null THEN

         Std_Lib.Split_line(l_Line_Buffer,
                            '|',
                            l_Nse_Tab);


          P_Ret_Msg := ' Assigning values to variables ';
          P_Assign_Into_Variables;
          IF l_Msm_Sec_Depmandatory=0 AND l_Msm_Sec_Allowdep=0 THEN
             P_Ret_Msg := 'Can not mapped in the system as it is a physical script.Symbol<'||l_Symbol_Msm_Nse_Code||'>';
             RAISE E_User_Exp;
          END IF;

          BEGIN
              SELECT Rv_Low_Value
              INTO   l_Msm_Scheme_Type
              FROM   Cg_Ref_Codes
              WHERE  Rv_Domain        = 'MF_SCHEME_TYPE'
              AND    Rv_Abbreviation  = 'NSE'
              AND    Rv_High_Value    = l_Nse_Category_Code ;
            EXCEPTION
              WHEN No_Data_Found THEN
                   P_Ret_Msg := 'Record skipped due to Scheme Type is Not Mapped/Found for Category code <'||l_Nse_Category_Code||'> in the system.';
                   RAISE E_User_Exp;
            END;

            P_Ret_Msg := 'Getting Settlement type from Scheme Category  <'||l_Nse_Category_Code||'> ';
            BEGIN
              SELECT Rv_Low_Value
              INTO   l_Msm_Settlement_Type
              FROM   Cg_Ref_Codes
              WHERE  Rv_Domain     = 'MF_NSE_SETTLEMENT_TYPE'
              AND    Rv_High_Value = l_Nse_Category_Code;
            EXCEPTION
              WHEN No_Data_Found THEN
                P_Ret_Msg := 'Record skipped due to Settlement Type not found for scheme Category <' || l_Nse_Category_Code ||'>';
                RAISE E_User_Exp;
            END;

          IF l_Eligibility_Flg = 0 THEN
            IF l_Nse_Category_Code NOT IN ( 'DBTCR','HLIQD') THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin          = l_Msm_Isin
               --AND    Msm_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status        = 'A'
               AND    Msm_Record_Status = 'A'
               AND    Trunc(Nvl(Msm_Nse_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Eligibility Flag is '||l_Eligibility_Flg ||' FOR ISIN : '||l_Msm_Isin||' And SETTLEMENT TYPE : '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            END IF;
            IF l_Nse_Category_Code = 'DBTCR' THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin                   = l_Msm_Isin
               AND    Msm_Nse_L1_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status                 = 'A'
               AND    Msm_Record_Status          = 'A'
               AND    Trunc(Nvl(Msm_Nse_l1_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Eligibility Flag is '||l_Eligibility_Flg ||' FOR ISIN : '||l_Msm_Isin||' And SETTLEMENT TYPE : '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            END IF;
            IF l_Nse_Category_Code = 'HLIQD' THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin                   = l_Msm_Isin
               AND    Msm_Nse_LO_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status                 = 'A'
               AND    Msm_Record_Status          = 'A'
               AND    Trunc(Nvl(Msm_Nse_lo_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Eligibility Flag is '||l_Eligibility_Flg ||' FOR ISIN : '||l_Msm_Isin||' And SETTLEMENT TYPE : '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            END IF;
          END IF;

            P_Ret_Msg := ' Validate Data ';
            P_Validate_Data;

            BEGIN
              SELECT Rta_Id
              INTO   l_Msm_Rta_Id
              FROM   Mfd_Rta_Master
              WHERE  Rta_Nse_Id = l_Nse_Rta_Code ;
            EXCEPTION
              WHEN No_Data_Found THEN
                P_Ret_Msg := 'Record skipped due to RTA Id is Not Mapped/Found for RTA code <'||l_Nse_Rta_Code||'> in the system.';
                RAISE E_User_Exp;
            END;

            BEGIN
              SELECT Amc_Id
              INTO   l_Msm_Amc_Id
              FROM   Mfd_Amc_Master t
              WHERE  Decode(l_Nse_Rta_Code,'CAMS' , Amc_Cams_Id,
                                           'KARVY', Amc_Karvy_Id,
                                           'SUN'  , Amc_Sun_Id,
                                           'DISPL', Amc_Displ_Cd,
                                           'FTI'  , Amc_Fti_Id )     = l_Nse_Amc_Code
              AND    Amc_Status = 'A';
             -- Changes done since this NSE AMC Code is actually RTA code
            EXCEPTION
              WHEN No_Data_Found THEN
                P_Ret_Msg := 'Record skipped due to AMC Id is Not Mapped/Found  for AMC code <'||l_Nse_Amc_Code||'> in the system.';
                RAISE E_User_Exp;
              WHEN Too_Many_Rows THEN
                P_Ret_Msg := 'Record skipped due to Multiple AMC Id is Mapped/Found  for AMC code <'||l_Nse_Amc_Code||'> in the system.';
                RAISE E_User_Exp;
            END;

            BEGIN
              SELECT *
              INTO   r_Mfd_scheme_master
              FROM   Mfd_scheme_master
              WHERE  Msm_Isin          = l_Msm_Isin
              AND    Msm_Status        = 'A'
              AND    Msm_Record_Status = 'A'
              AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
              l_Change_New := 'C';
            EXCEPTION
              WHEN No_Data_Found THEN
                BEGIN
                  SELECT *
                  INTO   r_Mfd_scheme_master
                  FROM   Mfd_scheme_master
                  WHERE  Decode(l_Nse_Category_Code,'DBTCR',Msm_Nse_L1_Scheme_Code,'HLIQD',Msm_Nse_Lo_Scheme_Code,Msm_Nse_Code) = l_Msm_Nse_Code
                  AND    Msm_Status         = 'A'
                  AND    Msm_Record_Status  = 'A'
                  AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
                  l_Change_New := 'C';
                EXCEPTION
                  WHEN No_Data_Found THEN
                     l_Change_New     := 'N';
                 --    l_Msm_Scheme_Id  := l_Msm_Amc_Id || l_Msm_Rta_Sch_Cd || l_Series_Msm_Nse_Code;
                     l_Msm_Scheme_Id  := l_Msm_Amc_Id || l_Msm_Nse_Code || l_Series_Msm_Nse_Code; -- primary key changed on 03-Aug-2012

                     IF Tab_Mfd_Schemes.EXISTS(l_Msm_Scheme_Id) AND Tab_Mfd_Schemes(l_Msm_Scheme_Id) <> l_Msm_Isin THEN
                        P_Ret_Msg := 'Record skipped due to Scheme Id <'||l_Msm_Scheme_Id||'> is already mapped in the system to Isin <'||Tab_Mfd_Schemes(l_Msm_Scheme_Id)||'>';
                        RAISE E_User_Exp;
                     END IF;
                  WHEN Too_Many_Rows THEN
                      P_Ret_Msg := 'Record skipped due to This BSE, NSE, RTA, AMFI or ISIN exists for multiple records ';
                      RAISE E_User_Exp;
                END ;
            END;

            IF l_Primary_File = 'NSE' THEN
               IF l_Change_New = 'C' THEN
                  P_Full_Upd_Scheme_Master;
                  l_Count_Updated  :=  l_Count_Updated + 1;
               ELSE
                  P_Insert_Mfd_Scheme_Master ;
                  l_Count_Inserted := l_Count_Inserted + 1;
               END IF;
            ELSE
               IF l_Change_New ='C' THEN
                  Null_Upd_Scheme_Master ;
                  l_Count_Updated  :=  l_Count_Updated + 1;
                  P_Write_Change_Skip_In_Log ;
               ELSE
                  P_Insert_Mfd_Scheme_Master ;
                  l_Count_Inserted := l_Count_Inserted + 1;
               END IF ;
            END IF ;
      END IF;
     EXCEPTION
       WHEN  E_Invalid_Excp THEN
          NULL;
        WHEN E_User_Exp THEN
           Utl_File.New_Line(l_Log_File_Handle, 1);
           P_Ret_Msg := P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme : '||l_Msm_Scheme_Desc;
           Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
           l_Count_Skipped := l_Count_Skipped + 1;
        WHEN E_Mand_Exp THEN
          Utl_File.New_Line(l_Log_File_Handle, 1);
          P_Ret_Msg := ' Record Skipped due to null value in mandatory fields - '||P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme : '||l_Msm_Scheme_Desc;
          Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
          l_Count_Skipped := l_Count_Skipped + 1;
        WHEN OTHERS Then
          ROLLBACK TO currline ;
          Utl_File.New_Line(l_Log_File_Handle, 1);
          Utl_File.Put_Line(l_Log_File_Handle, dbms_utility.format_error_backtrace||'*** Error at Line <'||l_Line_No||'> '|| Substr(SQLERRM,1,800));
          Utl_File.Put_Line(l_Log_File_Handle,'    Line <'||l_Line_Buffer||'>');
          l_Count_Skipped := l_Count_Skipped + 1;
     END ;
    END LOOP ;

    Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Prg_Process_Id,
                             'C',          'Y',               l_Sql_Err);

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN End_Of_File Then
      l_Count_Records := Greatest(l_Line_No - 1,0) ;
      Utl_File.New_Line(l_Log_File_Handle,1);
      IF l_LQ_Count > 0 THEN
        Utl_File.Put_Line(l_Log_File_Handle, ' Note : Marking Default Dividend Option flag as Growth for Schemes Present only in NSE LQ Series.');
      END IF;
      Utl_File.New_Line(l_Log_File_Handle,1);
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File(Excluding header)                           : ' || l_Count_Records);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted (Checker Mode)                             : ' || l_Count_Inserted);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated                                             : ' || l_Count_Updated);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                                             : ' || l_Count_Skipped);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped due to invalid ISIN                         : ' || l_Invalid_Record );
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped Updation of Some fields (Due To Difference) : ' || l_Count_Change_Skip);
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, '                 Details Of Records Having Duplicate Unique No In NSE:');
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('-',160,'-'));
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('Scheme Id',30)||' | '||RPAD('Scheme Description',100)||' | '||RPAD('Amc Id',10)||' | '||RPAD('Unique No.',10));
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('-',160,'-'));
      FOR i IN C_Nse_Dup_No
      LOOP
       Utl_File.Put_Line(l_Log_File_Handle, RPAD(i.msm_scheme_id,30)||' | ' ||RPAD(i.msm_scheme_desc,100)||' | '||RPAD(i.msm_amc_id,10)||' | '||RPAD(i.msm_nse_unique_no,10));
      END LOOP;
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
      Utl_File.Fclose(l_Log_File_Handle);
      Utl_File.fclose(l_File_Ptr);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,     l_Prg_Process_Id,
                               'C',          'Y',               l_Sql_Err);

      P_Ret_Val  := 'SUCCESS';
      P_Ret_Msg  := 'Process Completed Successfully !!! ';

    WHEN Ue_Exception THEN
      p_Ret_Val := 'FAIL';
      Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,   l_Prg_Process_Id,
                               'E',          'Y',               l_Sql_Err);

    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      P_Ret_Msg := DBMS_UTILITY.Format_Error_Backtrace || CHR(10) || P_Ret_Msg || ' Error - ' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Dt,   l_Prg_Process_Id,
                               'E',          'Y',               l_Sql_Err);

  END P_Mfd_Load_Mfss_Site_File;

  PROCEDURE P_Mfd_Load_Mfss_Bse_Site_File (P_Path      IN     VARCHAR2,
                                           P_File_Name IN     VARCHAR2,
                                           P_Ret_Val   IN OUT VARCHAR2,
                                           P_Ret_Msg   IN OUT VARCHAR2)
  IS

    l_Pam_Curr_Date                 DATE;
    l_Prg_Process_Id                NUMBER := 0;
    l_Line_No                       NUMBER := 0;
    l_Count_Records                 NUMBER := 0;
    l_Count_Inserted                NUMBER := 0;
    l_Count_Updated                 NUMBER := 0;
    l_Count_Skipped                 NUMBER := 0;
    l_Count_Change_Skip             NUMBER := 0;
    l_Msm_Bse_Unique_No             NUMBER := 0;
    l_Msm_Min_Pur_Amt               NUMBER(24,2);
    l_Msm_Max_Pur_Amt               NUMBER(24,2);
    l_Msm_Pur_Amt_Mul               NUMBER(24,2);--28 field
    l_Msm_Add_Pur_Amt_Mul           NUMBER(24,2);
    l_Msm_Min_Redem_Qty             NUMBER(24,4);
    l_Msm_Max_Redem_Qty             NUMBER(24,4);
    l_Msm_Redem_Qty_Mul             NUMBER(24,4);
    l_Msm_Pur_Allowed               VARCHAR2(1);
    l_Msm_Redem_Allowed             VARCHAR2(1);
    l_Msm_Physical_Yn               VARCHAR2(1);
    l_Msm_Demat_Yn                  VARCHAR2(1);
    l_Msm_Sip_Yn                    VARCHAR2(1);
    l_Msm_Swp_Yn                    VARCHAR2(1);
    l_Msm_Stp_Yn                    VARCHAR2(1);
    l_Msm_Div_Option                VARCHAR2(1);
    l_Msm_Record_Status             VARCHAR2(1);
    l_Change_New                    VARCHAR2(1);
    l_Skip_Yn                       VARCHAR2(1) := 'N';
    l_Divd_Option                   VARCHAR2(1);
    l_Divd_Opt_For_Primary          VARCHAR2(2);
    l_Msm_Settlement_Type           VARCHAR2(3);
    l_Amc_Active_Flag               VARCHAR2(10);
    l_Msm_Scheme_Type               VARCHAR2(20);
    l_Msm_Isin                      VARCHAR2(20);
    l_Mapped_Isin                   VARCHAR2(20);
    l_Already_Mapped_Isin           VARCHAR2(20);
    l_Primary_File                  VARCHAR2(20);
    l_Prg_Id                        VARCHAR2(30) := 'MFSSSITE';
    l_Bse_Amc_Code                  VARCHAR2(30);
    l_Bse_Rta_Code                  VARCHAR2(30);
    l_Internal_Rta_Id               VARCHAR2(30);
    l_Msm_Scheme_Id                 VARCHAR2(30);
    l_Msm_Bse_Code                  VARCHAR2(30);
    l_Msm_Pur_Cut_Off               VARCHAR2(30);
    l_Msm_Redem_Cut_Off             VARCHAR2(30);
    l_Msm_Amc_Sch_Cd                VARCHAR2(50);
    l_Msm_Rta_Sch_Cd                VARCHAR2(50);
    l_Msm_Data_Vendor_Id            VARCHAR2(50);
    l_Internal_Amc_Id               VARCHAR2(50);
    l_Purchase_Transaction_Mode     VARCHAR2(50);
    l_Redemp_Transac_Mode           VARCHAR2(50);
    l_Log_File_Name                 VARCHAR(200);
    l_Msm_Scheme_Desc               VARCHAR2(200);
    l_Sql_Err                       VARCHAR2(2000);
    l_Mand_Fields_Msg               VARCHAR2(32767);
    l_Line_Buffer                   VARCHAR2(32767);
    End_Of_File                     EXCEPTION;
    E_User_Exp                      EXCEPTION;
    E_Mand_Exp                      EXCEPTION;
    E_Invalid_Excp                  EXCEPTION;
    E_Skip_Header                   EXCEPTION;
    l_File_Ptr                      Utl_File.File_Type;
    l_Log_File_Handle               Utl_File.File_Type;
    l_Bse_Tab                       Std_Lib.Tab;
    l_Count_Nse                     NUMBER := 0 ;
    l_Valid_Scheme_Count            NUMBER := 0 ;
    l_Invalid_Record                NUMBER := 0 ;
    r_Mfd_Scheme_Master             Mfd_Scheme_Master%ROWTYPE;
    l_Switch_Fl                     VARCHAR2(1);
    l_Amc_Ind                       VARCHAR2(10);
    l_Face_Value                    VARCHAR2(10);
    l_Start_Date                    DATE;
    l_End_Date                      DATE;
    l_Exit_Load_Fl                  VARCHAR2(1);
    l_Lockin_Period_Fl              VARCHAR2(1);
    l_Lockin_Period                 VARCHAR2(10);
    l_Channel_Partner_Cd            VARCHAR2(10);
    /*l_SIP_Trigger_Fl                VARCHAR2(1);
    l_STP_Trigger_Fl                VARCHAR2(1);
    l_SWP_Trigger_Fl                VARCHAR2(1);*/
    l_Scheme_Plan                   VARCHAR2(100);
    l_Msm_Mul_Redem_Amt             NUMBER(24,2);
    l_Msm_Min_Redem_Amt             NUMBER(24,2);
    l_Msm_Max_Redem_Amt             NUMBER(24,2);

    TYPE T_Mfd_Schemes IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
    Tab_Mfd_Schemes T_Mfd_Schemes;

     CURSOR C_Bse_Dup_No IS
        SELECT * FROM (SELECT D.*, COUNT(MSM_BSE_UNIQUE_NO) OVER (PARTITION BY MSM_BSE_UNIQUE_NO) CNT  FROM  (SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Bse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date  BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        UNION ALL -- Nfo Scheme whose Nav provided by Exchange
        SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Bse_Unique_No
        FROM   Mfd_Scheme_Master m1,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m1.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m1.Msm_Nfo_Yn = 'Y')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_Nfo_From_Date AND Nvl(Msm_Nfo_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Nfo_Yn        = 'Y'
        UNION ALL -- Nfo Scheme whose Nav NOT provided by Exchange
        SELECT Msm_Scheme_Id                       ,Msm_Scheme_Desc                         ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Bse_Unique_No
        FROM   Mfd_Scheme_Master m1/*,
               Mfd_Nav*/
        WHERE  Msm_Scheme_Id Not In (Select Mn_scheme_id From Mfd_Nav)
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_Nfo_From_Date AND Nvl(Msm_Nfo_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Nfo_Yn        = 'Y'
        UNION ALL  --L0 Schemes
        SELECT Msm_Scheme_Id||'L0' Msm_Scheme_Id   ,Msm_Scheme_Desc||'L0' Msm_Scheme_Desc   ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Bse_Lo_Unique_No Msm_Bse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_Lo_Allowed_Yn = 'Y'
     UNION ALL  --L1 Schemes
        SELECT Msm_Scheme_Id||'L1' Msm_Scheme_Id   ,Msm_Scheme_Desc||'L1' Msm_Scheme_Desc   ,Nvl(Msm_Amc_Id, ' ') Msm_Amc_Id,
               Msm_Bse_L1_Unique_No Msm_Bse_Unique_No
        FROM   Mfd_Scheme_Master  m,
               Mfd_Nav
        WHERE  Msm_Scheme_Id = Mn_scheme_id
        AND    m.Msm_Amc_Id  = Mn_Amc_Id
        AND    Mn_Nav_Date   = (SELECT MAX(n.Mn_Nav_Date)
                                FROM   Mfd_Nav n
                                WHERE  n.Mn_Scheme_Id = Mn_Scheme_Id
                                AND    n.Mn_scheme_id = msm_scheme_id
                                AND    n.Mn_Amc_Id    = Mn_Amc_Id
                                AND    m.Msm_Nfo_Yn = 'N')
        AND    Std_Lib.l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, Std_Lib.l_Pam_Curr_Date)
        AND    Msm_Status        = 'A'
        AND    Msm_Record_Status = 'A'
        AND    Msm_L1_Allowed_Yn = 'Y') D)
        WHERE CNT>1;

    PROCEDURE P_Insert_Mfd_Scheme_Master IS
    BEGIN
      INSERT INTO Mfd_Scheme_Master
         (Msm_Scheme_Id,
          Msm_Scheme_Desc,
          Msm_Amc_Id,
          Msm_Rta_Id,
          Msm_From_Date,
          Msm_Scheme_Type,
          Msm_Bse_Code,
          Msm_Bse_Unique_No,
          Msm_Isin,
          Msm_Rta_Sch_Cd,
          Msm_Pur_Allowed,
          Msm_Redem_Allowed,
          Msm_Bse_Allowed,
          Msm_Physical_Yn,
          Msm_Demat_Yn,
          Msm_Sip_Yn,
          Msm_Swp_Yn,
          Msm_Stp_Yn,
          Msm_Div_Option,
          Msm_Min_Pur_Amt_Bse,
          Msm_Max_Pur_Amt_Bse,
          Msm_Addtnl_Pur_Amt_Bse,
          Msm_Bse_Pur_Cut_Off,
          Msm_Min_Redem_Qty_Bse,
          Msm_Max_Redem_Qty_Bse,
          Msm_Redem_Qty_Mul_Bse,
          Msm_Bse_Redem_Cut_Off,
          Msm_Source,
          Msm_Status,
          Msm_Amc_Sch_Cd,
          Msm_Record_Status,
          Msm_Prg_Id,
          Msm_Sch_Cat,
          Msm_Purc_Amt_Multiplier_Bse,
          Msm_Settlement_Type,
          Msm_Add_Pur_Amt_Mul_Bse,
          Msm_Bse_Lo_Settlement_Type,
          Msm_Bse_Lo_Unique_No,
          Msm_Bse_Lo_Scheme_Code,
          Msm_Bse_Lo_Pur_Cut_Off,
          Msm_Bse_Lo_Min_Pur_Amt,
          Msm_Bse_Lo_Max_Pur_Amt,
          Msm_Bse_Lo_Addtnl_Pur_Amt,
          Msm_Bse_Lo_Purc_Amt_Multiplier,
          Msm_Bse_Lo_Add_Pur_Amt_Mul,
          Msm_Lo_Allowed_Yn,
          Msm_Pur_Allowed_Bse_L0,
          Msm_Bse_L1_Settlement_Type,
          Msm_Bse_L1_Unique_No,
          Msm_Bse_L1_Scheme_Code,
          Msm_Bse_L1_Pur_Cut_Off,
          Msm_Bse_L1_Min_Pur_Amt,
          Msm_Bse_L1_Max_Pur_Amt,
          Msm_Bse_L1_Addtnl_Pur_Amt,
          Msm_Bse_L1_Purc_Amt_Multiplier,
          Msm_Bse_L1_Add_Pur_Amt_Mul,
          Msm_L1_Allowed_Yn,
          Msm_Pur_Allowed_Bse_L1,
          Msm_Nfo_Time,
          Msm_Bse_Sip_Allowed,
          Msm_Exit_Load_Fl,
          Msm_Lockin_Fl,
          /*MSM_SIP_TRIGGER_FL_BSE,
          Msm_Stp_Trigger_Fl_BSE,
          Msm_Swp_Trigger_Fl_BSE,*/
          Msm_Unit_Face_Value,
          Msm_Nfo_From_Date,
          Msm_Nfo_To_Date,
          Msm_Elss_Lockin_Months,
          MSM_SCHEME_PLAN,
          MSM_MUL_REDEM_AMT_BSE,
          MSM_MIN_REDEM_AMT_BSE,
          MSM_MAX_REDEM_AMT_BSE,
          Msm_Switch_In /*,
     Msm_Max_Pur_Amt,
          Msm_Min_Pur_Amt,
          Msm_Add_Pur_Amt,
          Msm_Add_Pur_Amt_Mul,
          Msm_Pur_Cut_Off,
          Msm_Min_Redem_Qty,
          Msm_Max_Redem_Qty,
          Msm_Min_Redem_Amt,
          Msm_Max_Redem_Amt,
          Msm_Redem_Qty_Mul,
          Msm_Redem_Cut_Off*/
          )

      VALUES
         (l_Msm_Scheme_Id,
          l_Msm_Scheme_Desc,
          l_Internal_Amc_Id,
          l_Internal_Rta_Id,
          l_Pam_Curr_Date,
          l_Msm_Scheme_Type,
          Decode(l_Msm_Settlement_Type, 'L0', NULL, 'L1', NULL,l_Msm_Bse_Code),
          Decode(l_Msm_Settlement_Type, 'L0', NULL, 'L1', NULL,l_Msm_Bse_Unique_No),
          l_Msm_Isin,
          l_Msm_Rta_Sch_Cd,
          Decode(l_Msm_Settlement_Type, 'L0', 'N', 'L1', 'N',l_Msm_Pur_Allowed),
          Decode(l_Msm_Settlement_Type, 'L0', 'N', 'L1', 'N',l_Msm_Redem_Allowed),
          Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
          l_Msm_Physical_Yn,
          l_Msm_Demat_Yn,
          l_Msm_Sip_Yn,
          l_Msm_Swp_Yn,
          l_Msm_Stp_Yn,
          l_Divd_Option,
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Min_Pur_Amt),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,DECODE(l_Msm_Max_Pur_Amt,'0','',l_Msm_Max_Pur_Amt)),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Add_Pur_Amt_Mul),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Pur_Cut_Off),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Min_Redem_Qty),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Max_Redem_Qty),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Redem_Qty_Mul),
          Decode(l_Msm_Settlement_Type, 'L0', Null,'L1', Null,l_Msm_Redem_Cut_Off),
          'B',
          'A',
          l_Msm_Amc_Sch_Cd,
          Nvl(l_Msm_Record_Status, 'A'),
          l_Prg_Id,
          l_Msm_Scheme_Type,
          Decode(l_Msm_Settlement_Type, 'L0', NULL,'L1', Null, l_Msm_Pur_Amt_Mul),
          Decode(l_Msm_Settlement_Type, 'L0', NULL,'L1', Null, l_Msm_Settlement_Type),
          Decode(l_Msm_Settlement_Type, 'L0', NULL,'L1', Null, l_Msm_Pur_Amt_Mul),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Settlement_Type, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Bse_Unique_No, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Bse_Code, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Pur_Cut_Off, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Min_Pur_Amt, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Max_Pur_Amt, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Add_Pur_Amt_Mul, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Pur_Amt_Mul, NULL),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Pur_Amt_Mul, NULL),
          --Decode(l_Msm_Settlement_Type, 'L0', 'Y', 'N'),--l_Msm_Pur_Allowed
          Decode(l_Msm_Settlement_Type, 'L0',Decode(l_Msm_Pur_Allowed,'Y','Y','N'),'N'),
          Decode(l_Msm_Settlement_Type, 'L0', l_Msm_Pur_Allowed,'N'),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Settlement_Type, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Bse_Unique_No, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Bse_Code, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Pur_Cut_Off, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Min_Pur_Amt, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Max_Pur_Amt, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Add_Pur_Amt_Mul, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Pur_Amt_Mul, NULL),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Pur_Amt_Mul, NULL),
          Decode(l_Msm_Settlement_Type, 'L1',Decode(l_Msm_Pur_Allowed,'Y','Y','N'),'N'),
          Decode(l_Msm_Settlement_Type, 'L1', l_Msm_Pur_Allowed,'N'),
          Decode(l_Msm_Settlement_Type, 'MF', l_Msm_Pur_Cut_Off,NULL),
          l_Msm_Sip_Yn,
          l_Exit_Load_Fl,
          l_Lockin_Period_Fl,
          /*l_SIP_Trigger_Fl,
          l_STP_Trigger_Fl,
          l_SWP_Trigger_Fl,*/
          l_Face_Value,
          l_Start_Date,
          l_End_Date,
          l_Lockin_Period,
          l_Scheme_Plan,
          l_Msm_Mul_Redem_Amt,
          l_Msm_Min_Redem_Amt,
          l_Msm_Max_Redem_Amt,
          l_Switch_Fl/*,
      l_Msm_Max_Pur_Amt,
          l_Msm_Min_Pur_Amt,
          l_Msm_Add_Pur_Amt_Mul,
          l_Msm_Pur_Amt_Mul,
          l_Msm_Pur_Cut_Off,
          l_Msm_Min_Redem_Qty  ,
          l_Msm_Max_Redem_Qty,
          l_Msm_Min_Redem_Amt,
          l_Msm_Max_Redem_Amt,
          l_Msm_Redem_Qty_Mul,
          l_Msm_Redem_Cut_Off*/
          );


    END P_Insert_Mfd_Scheme_Master;

    PROCEDURE p_Full_Upd_Scheme_Master IS
    BEGIN
      IF l_Msm_Settlement_Type NOT IN ( 'L0','L1') THEN
          UPDATE Mfd_Scheme_Master m
          SET    Msm_Scheme_Desc           =    Nvl(l_Msm_Scheme_Desc,        Msm_Scheme_Desc),
                 Msm_Amc_Id                =    Nvl(l_Internal_Amc_Id,        Msm_Amc_Id),
                 Msm_Rta_Id                =    Nvl(l_Internal_Rta_Id,        Msm_Rta_Id),
                 Msm_Scheme_Type           =    Nvl(l_Msm_Scheme_Type,        Msm_Scheme_Type),
                 Msm_Bse_Code              =    Nvl(l_Msm_Bse_Code,           Msm_Bse_Code),
                 Msm_Bse_Unique_No         =    Nvl(l_Msm_Bse_Unique_No,      Msm_Bse_Unique_No),
                 Msm_Isin                  =    Nvl(l_Msm_Isin,               Msm_Isin),
                 /*Msm_Rta_Sch_Cd            =    Nvl(l_Msm_Rta_Sch_Cd,         Msm_Rta_Sch_Cd),*/
                 Msm_Pur_Allowed           =    Nvl(l_Msm_Pur_Allowed,        Msm_Pur_Allowed),
                 Msm_Redem_Allowed         =    Nvl(l_Msm_Redem_Allowed,      Msm_Redem_Allowed),
                 Msm_Bse_Allowed           =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
                 Msm_Physical_Yn           =    Nvl(l_Msm_Physical_Yn,        Msm_Physical_Yn),
                 Msm_Demat_Yn              =    Nvl(l_Msm_Demat_Yn,           Msm_Demat_Yn),
                 Msm_Sip_Yn                =    Nvl(l_Msm_Sip_Yn,             Msm_Sip_Yn),
                 Msm_Swp_Yn                =    Nvl(l_Msm_Swp_Yn,             Msm_Swp_Yn),
                 Msm_Stp_Yn                =    Nvl(l_Msm_Stp_Yn,             Msm_Stp_Yn),
                 Msm_Div_Option            =    Nvl(l_Divd_Option,            Msm_Div_Option),
                 Msm_Min_Pur_Amt_Bse       =    Nvl(l_Msm_Min_Pur_Amt,        Msm_Min_Pur_Amt_Bse),
                 Msm_Max_Pur_Amt_Bse       =    Nvl(decode(l_Msm_Max_Pur_Amt,'0','',l_Msm_Max_Pur_Amt),        Msm_Max_Pur_Amt_Bse),  --AMEYA , 13/APR/2022  ,  0 TO BE CONSIDERED AS INFINITY
                 Msm_Addtnl_Pur_Amt_Bse    =    Nvl(l_Msm_Add_Pur_Amt_Mul,    Msm_Addtnl_Pur_Amt_Bse),---recent change
                 Msm_Bse_Pur_Cut_Off       =    Nvl(l_Msm_Pur_Cut_Off,        Msm_Bse_Pur_Cut_Off),
                 Msm_Min_Redem_Qty_Bse     =    Nvl(l_Msm_Min_Redem_Qty,      Msm_Min_Redem_Qty_Bse),
                 Msm_Max_Redem_Qty_Bse     =    Nvl(decode(l_Msm_Max_Redem_Qty,'0','999999999',l_Msm_Max_Redem_Qty),      Msm_Max_Redem_Qty_Bse),
                 Msm_Redem_Qty_Mul_Bse     =    Nvl(l_Msm_Redem_Qty_Mul,      Msm_Redem_Qty_Mul_Bse),
                 Msm_Bse_Redem_Cut_Off     =    Nvl(l_Msm_Redem_Cut_Off,      Msm_Bse_Redem_Cut_Off),
                 Msm_Purc_Amt_Multiplier_Bse  = Nvl(l_Msm_Pur_Amt_Mul,    Msm_Purc_Amt_Multiplier_Bse),
                 Msm_Source                =    'B',
                 Msm_Amc_Sch_Cd            =    Nvl(l_Msm_Amc_Sch_Cd,         Msm_Amc_Sch_Cd),
                 Msm_Prg_Id                =    l_Prg_Id,
                 Msm_Settlement_Type       =    Nvl(l_Msm_Settlement_Type,    Msm_Settlement_Type),
                 Msm_Add_Pur_Amt_Mul_Bse   =    Nvl(l_Msm_Pur_Amt_Mul,        Msm_Add_Pur_Amt_Mul_Bse),--recent
                 Msm_Sch_Cat               =    Nvl(l_Msm_Scheme_Type,        Msm_Sch_Cat),
                 Msm_Last_Updt_By          =    USER,
                 Msm_Last_Updt_Dt          =    SYSDATE,
                 Msm_Nfo_Time              =    Nvl(l_Msm_Pur_Cut_Off,Msm_Nfo_Time),
                 Msm_Bse_Sip_Allowed       =    Nvl(l_Msm_Sip_Yn , Msm_Bse_Sip_Allowed),
                 Msm_Exit_Load_Fl          =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
                 Msm_Lockin_Fl             =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
                 /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
                 Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
                 Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
                 Msm_Unit_Face_Value       =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
                 Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
                 Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
                 Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
                 MSM_scheme_plan           =    Nvl(l_Scheme_Plan,MSM_scheme_plan),
                 MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
                 MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
                 MSM_MAX_REDEM_AMT_BSE     =    Nvl(decode(l_Msm_Max_Redem_Amt,'0','99999999999',l_Msm_Max_Redem_Amt),MSM_MAX_REDEM_AMT_BSE),
                 Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)/*,
         Msm_Max_Pur_Amt           =    Nvl(l_Msm_Max_Pur_Amt,'0'),
                 Msm_Min_Pur_Amt           =    Nvl(l_Msm_Min_Pur_Amt,'0'),
                 Msm_Add_Pur_Amt           =    Nvl(l_Msm_Pur_Amt_Mul,'0'),
                 Msm_Add_Pur_Amt_Mul       =    Nvl(l_Msm_Add_Pur_Amt_Mul,'0'),
                 Msm_Add_Pur_Amt           =    Nvl(l_Msm_Add_Pur_Amt_Mul,'0'),
                 Msm_Add_Pur_Amt_Mul       =    Nvl(l_Msm_Pur_Amt_Mul,'0'),
                 Msm_Min_Redem_Qty         =    Nvl(l_Msm_Min_Redem_Qty,'0'),
                 Msm_Max_Redem_Qty         =    Nvl(l_Msm_Max_Redem_Qty,'0'),
                 Msm_Min_Redem_Amt         =    Nvl(l_Msm_Min_Redem_Amt,'0'),
                 Msm_Max_Redem_Amt         =    Nvl(l_Msm_Max_Redem_Amt,'0'),
                 Msm_Redem_Qty_Mul         =    Nvl(l_Msm_Redem_Qty_Mul,'0')*/
          WHERE  Msm_Scheme_Id             =    r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Status                =    'A'
          AND    Msm_Record_Status         =    'A'
          AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

          /*IF l_Msm_Settlement_Type = 'MF' THEN */ --mfbo 905
             UPDATE Mfd_Scheme_Master m
             SET    Msm_Nfo_Yn                = 'N'
             WHERE  Msm_Scheme_Id             = r_Mfd_Scheme_Master.Msm_Scheme_Id
             AND    Msm_Status                = 'A'
             AND    Msm_Record_Status         = 'A'
             AND    l_Pam_Curr_Date   > Nvl(Msm_Nfo_To_Date,l_Pam_Curr_Date);
         /* END IF;*/ --mfbo 905

      ELSIF l_Msm_Settlement_Type = 'L0'  THEN

          UPDATE Mfd_Scheme_Master m
          SET    Msm_LO_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed,'Y','Y','N'),
                 --Msm_LO_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
                 Msm_Bse_LO_Settlement_Type =    Nvl(l_Msm_Settlement_Type , Msm_Bse_LO_Settlement_Type),
                 Msm_Bse_LO_Unique_No       =    Nvl(l_Msm_Bse_Unique_No   , Msm_Bse_LO_Unique_No      ),
                 Msm_Bse_LO_Scheme_Code     =    Nvl(l_Msm_Bse_Code        , Msm_Bse_LO_Scheme_Code    ),
                 Msm_Bse_LO_Pur_Cut_Off     =    Nvl(l_Msm_Pur_Cut_Off     , Msm_Bse_LO_Pur_Cut_Off    ),
                 Msm_Bse_LO_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt     , Msm_Bse_LO_Min_Pur_Amt    ),
                 Msm_Bse_LO_Max_Pur_Amt     =    Nvl(l_Msm_Max_Pur_Amt     , Msm_Bse_LO_Max_Pur_Amt    ),
                 Msm_Bse_LO_Addtnl_Pur_Amt  =    Nvl(l_Msm_Add_Pur_Amt_Mul , Msm_Bse_LO_Addtnl_Pur_Amt ),
                 Msm_Bse_LO_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul    , Msm_Bse_LO_Purc_Amt_Multiplier),
                 Msm_Bse_LO_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul     , Msm_Bse_LO_Add_Pur_Amt_Mul),
                 Msm_Div_Option             =    Nvl(l_Divd_Option         , Msm_Div_Option),
                 Msm_Sch_Cat                =    Nvl(l_Msm_Scheme_Type     , Msm_Sch_Cat),
                 Msm_Pur_Allowed_Bse_L0     =    Nvl(l_Msm_Pur_Allowed     , Msm_Pur_Allowed_Bse_L0),
                -- Msm_Bse_Allowed            =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
                 Msm_Last_Updt_By           =    USER,
                -- Msm_Last_Updt_Dt           =    SYSDATE,
                 MSM_BSE_LO_UPDT_DT         =    SYSDATE,
                 Msm_Exit_Load_Fl          =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
                 Msm_Lockin_Fl             =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
                 /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
                 Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
                 Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
                 Msm_Unit_Face_Value       =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
                 Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
                 Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
                 Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
                 MSM_scheme_plan           =    Nvl(l_Scheme_Plan,MSM_scheme_plan),
                 MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
                 MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
                 MSM_MAX_REDEM_AMT_BSE     =    Nvl(l_Msm_Max_Redem_Amt,MSM_MAX_REDEM_AMT_BSE),
                 Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)
          WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Status                 =    'A'
          AND    Msm_Record_Status          =    'A'
          AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

      ELSIF l_Msm_Settlement_Type = 'L1'  THEN

          UPDATE Mfd_Scheme_Master m
          SET    Msm_L1_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed,'Y','Y','N'),
                 --Msm_L1_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
                 Msm_Bse_L1_Settlement_Type =    Nvl(l_Msm_Settlement_Type , Msm_Bse_L1_Settlement_Type),
                 Msm_Bse_L1_Unique_No       =    Nvl(l_Msm_Bse_Unique_No   , Msm_Bse_L1_Unique_No      ),
                 Msm_Bse_L1_Scheme_Code     =    Nvl(l_Msm_Bse_Code        , Msm_Bse_L1_Scheme_Code    ),
                 Msm_Bse_L1_Pur_Cut_Off     =    Nvl(l_Msm_Pur_Cut_Off     , Msm_Bse_L1_Pur_Cut_Off    ),
                 Msm_Bse_L1_Min_Pur_Amt     =    Nvl(l_Msm_Min_Pur_Amt     , Msm_Bse_L1_Min_Pur_Amt    ),
                 Msm_Bse_L1_Max_Pur_Amt     =    Nvl(decode(l_Msm_Max_Pur_Amt,'0','99999999999',l_Msm_Max_Pur_Amt )      , Msm_Bse_L1_Max_Pur_Amt    ),
                 Msm_Bse_L1_Addtnl_Pur_Amt  =    Nvl(l_Msm_Add_Pur_Amt_Mul , Msm_Bse_L1_Addtnl_Pur_Amt ),
                 Msm_Bse_L1_Purc_Amt_Multiplier = Nvl(l_Msm_Pur_Amt_Mul    , Msm_Bse_L1_Purc_Amt_Multiplier),
                 Msm_Bse_L1_Add_Pur_Amt_Mul =    Nvl(l_Msm_Pur_Amt_Mul     , Msm_Bse_L1_Add_Pur_Amt_Mul),
                 Msm_Div_Option             =    Nvl(l_Divd_Option         , Msm_Div_Option),
                 Msm_Sch_Cat                =    Nvl(l_Msm_Scheme_Type     , Msm_Sch_Cat),
                 Msm_Pur_Allowed_Bse_L1     =    Nvl(l_Msm_Pur_Allowed     , Msm_Pur_Allowed_Bse_L1),
               --  Msm_Bse_Allowed            =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
                 Msm_Last_Updt_By           =    USER,
                -- Msm_Last_Updt_Dt           =    SYSDATE,
                 Msm_Bse_L1_Updt_Dt         =    SYSDATE,
                 Msm_Exit_Load_Fl          =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
                 Msm_Lockin_Fl             =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
                 /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
                 Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
                 Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
                 Msm_Unit_Face_Value       =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
                 Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
                 Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
                 Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
                 MSM_scheme_plan           =    nVL(l_Scheme_Plan,MSM_scheme_plan),
                 MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
                 MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
                 MSM_MAX_REDEM_AMT_BSE     =    Nvl(l_Msm_Max_Redem_Amt,MSM_MAX_REDEM_AMT_BSE),
                 Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)
          WHERE  Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
          AND    Msm_Status                 =    'A'
          AND    Msm_Record_Status          =    'A'
          AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
      END IF;

    END p_Full_Upd_Scheme_Master ;

    PROCEDURE Null_Upd_Scheme_Master IS
    BEGIN
      IF l_Msm_Settlement_Type NOT IN ( 'L0','L1') THEN
        UPDATE Mfd_Scheme_Master m
        SET    Msm_Scheme_Desc           =    Nvl(Msm_Scheme_Desc,          l_Msm_Scheme_Desc),
               Msm_Amc_Id                =    Nvl(Msm_Amc_Id,               l_Internal_Amc_Id),
               Msm_Rta_Id                =    Nvl(Msm_Rta_Id,               l_Internal_Rta_Id),
               Msm_Scheme_Type           =    Nvl(Msm_Scheme_Type,          l_Msm_Scheme_Type),
               Msm_Bse_Code              =    Nvl(Msm_Bse_Code,             l_Msm_Bse_Code),
               Msm_Bse_Unique_No         =    Nvl(Msm_Bse_Unique_No,        l_Msm_Bse_Unique_No),
               Msm_Isin                  =    Nvl(Msm_Isin,                 l_Msm_Isin),
               /*Msm_Rta_Sch_Cd            =    Nvl(Msm_Rta_Sch_Cd,           l_Msm_Rta_Sch_Cd),*/
               Msm_Pur_Allowed           =    Nvl(Msm_Pur_Allowed,          l_Msm_Pur_Allowed),
               Msm_Redem_Allowed         =    Nvl(Msm_Redem_Allowed,        l_Msm_Redem_Allowed),
               Msm_Bse_Allowed           =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
               Msm_Physical_Yn           =    Nvl(Msm_Physical_Yn,          l_Msm_Physical_Yn),
               Msm_Demat_Yn              =    Nvl(Msm_Demat_Yn,             l_Msm_Demat_Yn),
               Msm_Sip_Yn                =    Nvl(Msm_Sip_Yn,               l_Msm_Sip_Yn),
               Msm_Swp_Yn                =    Nvl(Msm_Swp_Yn,               l_Msm_Swp_Yn),
               Msm_Stp_Yn                =    Nvl(Msm_Stp_Yn,               l_Msm_Stp_Yn),
               Msm_Div_Option            =    Nvl(Msm_Div_Option,           l_Divd_Option),
               Msm_Min_Pur_Amt_Bse       =    Nvl(Msm_Min_Pur_Amt_Bse,      l_Msm_Min_Pur_Amt),
               Msm_Max_Pur_Amt_Bse       =    Nvl(Msm_Max_Pur_Amt_Bse,      l_Msm_Max_Pur_Amt),
               --Msm_Addtnl_Pur_Amt_Bse    =    Nvl(Msm_Addtnl_Pur_Amt_Bse,   l_Msm_Add_Pur_Amt_Mul),--recent
               Msm_Addtnl_Pur_Amt_Bse    =    Nvl(Msm_Addtnl_Pur_Amt_Bse,   l_Msm_Add_Pur_Amt_Mul),--recent
               Msm_Bse_Pur_Cut_Off       =    Nvl(Msm_Bse_Pur_Cut_Off,      l_Msm_Pur_Cut_Off),
               Msm_Min_Redem_Qty_Bse     =    Nvl(Msm_Min_Redem_Qty_Bse,    l_Msm_Min_Redem_Qty),
               Msm_Max_Redem_Qty_Bse     =    Nvl(Msm_Max_Redem_Qty_Bse,    l_Msm_Max_Redem_Qty),
               Msm_Redem_Qty_Mul_Bse     =    Nvl(Msm_Redem_Qty_Mul_Bse,    l_Msm_Redem_Qty_Mul),
               Msm_Bse_Redem_Cut_Off     =    Nvl(Msm_Bse_Redem_Cut_Off,        l_Msm_Redem_Cut_Off),
               Msm_Purc_Amt_Multiplier_Bse   =    Nvl(Msm_Purc_Amt_Multiplier_Bse, l_Msm_Pur_Amt_Mul),
               Msm_Source                =    'B',
               Msm_Amc_Sch_Cd            =    Nvl(Msm_Amc_Sch_Cd,           l_Msm_Amc_Sch_Cd),
               Msm_Prg_Id                =    l_Prg_Id,
               Msm_Settlement_Type       =    Nvl(Msm_Settlement_Type,      l_Msm_Settlement_Type),
               Msm_Add_Pur_Amt_Mul_Bse   =    Nvl(Msm_Add_Pur_Amt_Mul_Bse,  l_Msm_Pur_Amt_Mul),--recent
               Msm_Sch_Cat               =    Nvl(Msm_Sch_Cat,              l_Msm_Scheme_Type),
               Msm_Last_Updt_By          =    USER,
               Msm_Last_Updt_Dt          =    SYSDATE,
               Msm_Nfo_Time              =    Nvl(To_Char(Greatest(To_Date(l_Msm_Pur_Cut_Off,'HH24:MI:SS'),To_Date(Msm_Nfo_Time,'HH24:MI:SS')),'HH24:MI:SS'),Msm_Nfo_Time),
               Msm_Bse_Sip_Allowed       =    Nvl(l_Msm_Sip_Yn , Msm_Bse_Sip_Allowed),
               Msm_Exit_Load_Fl          =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
               Msm_Lockin_Fl             =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
               /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
               Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
               Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
               Msm_Unit_Face_Value       =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
               Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
               Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
               Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
               MSM_scheme_plan           =    nVL(l_Scheme_Plan,MSM_scheme_plan),
               MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
               MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
               MSM_MAX_REDEM_AMT_BSE     =    Nvl(l_Msm_Max_Redem_Amt,MSM_MAX_REDEM_AMT_BSE),
               Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)
        WHERE  Msm_Scheme_Id             =    r_Mfd_Scheme_Master.Msm_Scheme_Id
        AND    Msm_Status                =    'A'
        AND    Msm_Record_Status         =    'A'
        AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

      ELSIF l_Msm_Settlement_Type  =  'L0' THEN

        UPDATE Mfd_Scheme_Master m
        SET    Msm_LO_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed,'Y','Y','N'),
               Msm_Bse_LO_Settlement_Type =    Nvl(Msm_Bse_LO_Settlement_Type , l_Msm_Settlement_Type),
               Msm_Bse_LO_Unique_No       =    Nvl(Msm_Bse_LO_Unique_No       , l_Msm_Bse_Unique_No      ),
               Msm_Bse_LO_Scheme_Code     =    Nvl(Msm_Bse_LO_Scheme_Code     , l_Msm_Bse_Code    ),
               Msm_Bse_LO_Pur_Cut_Off     =    Nvl(Msm_Bse_LO_Pur_Cut_Off     , l_Msm_Pur_Cut_Off    ),
               Msm_Bse_LO_Min_Pur_Amt     =    Nvl(Msm_Bse_LO_Min_Pur_Amt     , l_Msm_Min_Pur_Amt       ),
               Msm_Bse_LO_Max_Pur_Amt     =    Nvl(Msm_Bse_LO_Max_Pur_Amt     , l_Msm_Max_Pur_Amt),
               Msm_Bse_LO_Addtnl_Pur_Amt  =    Nvl(Msm_Bse_LO_Addtnl_Pur_Amt  , l_Msm_Add_Pur_Amt_Mul),
               Msm_Bse_LO_Purc_Amt_Multiplier = Nvl(Msm_Bse_LO_Purc_Amt_Multiplier , l_Msm_Pur_Amt_Mul),
               Msm_Bse_LO_Add_Pur_Amt_Mul =    Nvl(Msm_Bse_LO_Add_Pur_Amt_Mul , l_Msm_Pur_Amt_Mul),
               Msm_Sch_Cat                =    Nvl(Msm_Sch_Cat,              l_Msm_Scheme_Type),
               Msm_Pur_Allowed_Bse_L0     =    Nvl(l_Msm_Pur_Allowed     , Msm_Pur_Allowed_Bse_L0),
              -- Msm_Bse_Allowed            =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
               Msm_Last_Updt_By           =    USER,
              -- Msm_Last_Updt_Dt           =    SYSDATE,
               MSM_BSE_LO_UPDT_DT         =    SYSDATE,
               Msm_Exit_Load_Fl           =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
               Msm_Lockin_Fl              =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
               /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
               Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
               Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
               Msm_Unit_Face_Value        =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
               Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
               Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
               Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
               MSM_scheme_plan           =    nVL(l_Scheme_Plan,MSM_scheme_plan),
               MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
               MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
               MSM_MAX_REDEM_AMT_BSE     =    Nvl(l_Msm_Max_Redem_Amt,MSM_MAX_REDEM_AMT_BSE),
               Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)
         WHERE Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
         AND   Msm_Status                 =    'A'
         AND   Msm_Record_Status          =    'A'
         AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

      ELSIF l_Msm_Settlement_Type  =  'L1' THEN

        UPDATE Mfd_Scheme_Master m
        SET    Msm_L1_Allowed_Yn          =    Decode(l_Msm_Pur_Allowed,'Y','Y','N'),
               Msm_Bse_L1_Settlement_Type =    Nvl(Msm_Bse_L1_Settlement_Type , l_Msm_Settlement_Type),
               Msm_Bse_L1_Unique_No       =    Nvl(Msm_Bse_L1_Unique_No       , l_Msm_Bse_Unique_No      ),
               Msm_Bse_L1_Scheme_Code     =    Nvl(Msm_Bse_L1_Scheme_Code     , l_Msm_Bse_Code    ),
               Msm_Bse_L1_Pur_Cut_Off     =    Nvl(Msm_Bse_L1_Pur_Cut_Off     , l_Msm_Pur_Cut_Off    ),
               Msm_Bse_L1_Min_Pur_Amt     =    Nvl(Msm_Bse_L1_Min_Pur_Amt     , l_Msm_Min_Pur_Amt       ),
               Msm_Bse_L1_Max_Pur_Amt     =    Nvl(Msm_Bse_L1_Max_Pur_Amt     , l_Msm_Max_Pur_Amt),
               Msm_Bse_L1_Addtnl_Pur_Amt  =    Nvl(Msm_Bse_L1_Addtnl_Pur_Amt  , l_Msm_Add_Pur_Amt_Mul),
               Msm_Bse_L1_Purc_Amt_Multiplier = Nvl(Msm_Bse_L1_Purc_Amt_Multiplier , l_Msm_Pur_Amt_Mul),
               Msm_Bse_L1_Add_Pur_Amt_Mul =    Nvl(Msm_Bse_L1_Add_Pur_Amt_Mul , l_Msm_Pur_Amt_Mul),
               Msm_Sch_Cat                =    Nvl(Msm_Sch_Cat,              l_Msm_Scheme_Type),
               Msm_Pur_Allowed_Bse_L1     =    Nvl(l_Msm_Pur_Allowed     , Msm_Pur_Allowed_Bse_L1),
             --  Msm_Bse_Allowed            =    Decode(l_Msm_Pur_Allowed||l_Msm_Redem_Allowed,'NN','N','Y'),
               Msm_Last_Updt_By           =    USER,
               --Msm_Last_Updt_Dt           =    SYSDATE,
               Msm_Bse_L1_Updt_Dt         =    SYSDATE,
               Msm_Exit_Load_Fl          =    Nvl(l_Exit_Load_Fl, Msm_Exit_Load_Fl),
               Msm_Lockin_Fl             =    Nvl(l_Lockin_Period_Fl, Msm_Lockin_Fl),
               /*MSM_SIP_TRIGGER_FL_BSE    =    Nvl(l_SIP_Trigger_Fl, MSM_SIP_TRIGGER_FL_BSE),
               Msm_Stp_Trigger_Fl_BSE    =    Nvl(l_STP_Trigger_Fl, Msm_Stp_Trigger_Fl_BSE),
               Msm_Swp_Trigger_Fl_BSE    =    Nvl(l_SWP_Trigger_Fl, Msm_Swp_Trigger_Fl_BSE),*/
               Msm_Unit_Face_Value       =    Nvl(l_Face_Value, Msm_Unit_Face_Value),
               Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,l_Start_Date),
               Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,l_End_Date),
               Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months,l_Lockin_Period),
               MSM_scheme_plan           =    nVL(l_Scheme_Plan,MSM_scheme_plan),
               MSM_MUL_REDEM_AMT_BSE     =    Nvl(l_Msm_Mul_Redem_Amt,MSM_MUL_REDEM_AMT_BSE),
               MSM_MIN_REDEM_AMT_BSE     =    Nvl(l_Msm_Min_Redem_Amt,MSM_MIN_REDEM_AMT_BSE),
               MSM_MAX_REDEM_AMT_BSE     =    Nvl(l_Msm_Max_Redem_Amt,MSM_MAX_REDEM_AMT_BSE),
               Msm_Switch_In             =    Nvl(l_Switch_Fl,Msm_Switch_In)
         WHERE Msm_Scheme_Id              =    r_Mfd_Scheme_Master.Msm_Scheme_Id
         AND   Msm_Status                 =    'A'
         AND   Msm_Record_Status          =    'A'
         AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
     END IF;

    END Null_Upd_Scheme_Master;

    FUNCTION Comp_Col(P_Desc    IN VARCHAR2,
                      P_Tab     IN VARCHAR2,
                      P_Var     IN VARCHAR2,
                      P_Ret_Str IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      IF P_Tab <> P_Var THEN
        IF P_Ret_Str IS NULL THEN
          RETURN P_Desc;
        ELSE
          RETURN P_Ret_Str||','||P_Desc ;
        END IF ;
      END IF ;
      RETURN P_Ret_Str;
    END Comp_Col ;

    PROCEDURE p_Write_Change_Skip_In_Log IS
      l_Str VARCHAR2(10000) := NULL;
    BEGIN
      l_Str := Comp_Col('BSE Unique No'            , r_Mfd_Scheme_Master.Msm_Bse_Unique_No    , l_Msm_Bse_Unique_No    ,l_Str);
      l_Str := Comp_Col('BSE Code'                 , r_Mfd_Scheme_Master.Msm_Bse_Code         , l_Msm_Bse_Code         ,l_Str);
      l_Str := Comp_Col('RTA Scheme Code'          , r_Mfd_Scheme_Master.Msm_Rta_Sch_Cd       , l_Msm_Rta_Sch_Cd       ,l_Str);
      l_Str := Comp_Col('AMC Scheme Code'          , r_Mfd_Scheme_Master.Msm_Amc_Sch_Cd       , l_Msm_Amc_Sch_Cd       ,l_Str);
      l_Str := Comp_Col('ISIN'                     , r_Mfd_Scheme_Master.Msm_Isin             , l_Msm_Isin             ,l_Str);
      l_Str := Comp_Col('Scheme Desc'              , r_Mfd_Scheme_Master.Msm_Scheme_Desc      , l_Msm_Scheme_Desc      ,l_Str);
      l_Str := Comp_Col('Purchase Allowed'         , r_Mfd_Scheme_Master.Msm_Pur_Allowed      , l_Msm_Pur_Allowed      ,l_Str);
      l_Str := Comp_Col('Pur Cut-Off Time'         , r_Mfd_Scheme_Master.Msm_Pur_Cut_Off      , l_Msm_Pur_Cut_Off      ,l_Str);
      l_Str := Comp_Col('Redemption Allow'         , r_Mfd_Scheme_Master.Msm_Redem_Allowed    , l_Msm_Redem_Allowed    ,l_Str);
      l_Str := Comp_Col('Redm Cut-Off Time'        , r_Mfd_Scheme_Master.Msm_Redem_Cut_Off    , l_Msm_Redem_Cut_Off    ,l_Str);
      l_Str := Comp_Col('SIP Yn'                   , r_Mfd_Scheme_Master.Msm_Sip_Yn           , l_Msm_Sip_Yn           ,l_Str);
      l_Str := Comp_Col('STP Yn'                   , r_Mfd_Scheme_Master.Msm_Stp_Yn           , l_Msm_Stp_Yn           ,l_Str);
      l_Str := Comp_Col('SWP Yn'                   , r_Mfd_Scheme_Master.Msm_Swp_Yn           , l_Msm_Swp_Yn           ,l_Str);
      l_Str := Comp_Col('Setl Type'                , r_Mfd_Scheme_Master.Msm_Settlement_Type  , l_Msm_Settlement_Type  ,l_Str);

      IF l_Str IS NOT NULL THEN
         IF Std_Lib.l_Debug_Mode = 'ADMIN' THEN
           Utl_File.Put_Line(l_Log_File_Handle,'Updated fields which were null except '||l_Str ||'> for ISIN <'||l_Msm_Isin||'>.');
         END IF;
         l_Count_Change_Skip  :=  l_Count_Change_Skip + 1;
      END IF ;

    END p_Write_Change_Skip_In_Log;

    PROCEDURE p_Assign_Into_Variables IS
    BEGIN
      l_Change_New                      := NULL;
      l_Msm_Bse_Unique_No               := Upper(TRIM(l_Bse_Tab(1)));
      --l_Msm_Bse_Unique_No               := Substr(Upper(TRIM(l_Bse_Tab(1))),-5,5);
      l_Msm_Bse_Code                    := Upper(TRIM(l_Bse_Tab(2)));
      l_Msm_Rta_Sch_Cd                  := Upper(TRIM(l_Bse_Tab(3)));
      l_Msm_Amc_Sch_Cd                  := Upper(TRIM(l_Bse_Tab(4)));
      l_Msm_Isin                        := Upper(TRIM(l_Bse_Tab(5)));
      l_Bse_Amc_Code                    := Upper(TRIM(l_Bse_Tab(6)));
      l_Scheme_Plan                     := Upper(TRIM(l_Bse_Tab(8)));
      l_Msm_Scheme_Desc                 := Upper(TRIM(l_Bse_Tab(9)));
      l_Purchase_Transaction_Mode       := Upper(TRIM(l_Bse_Tab(11)));
      l_Msm_Min_Pur_Amt                 := TRIM(l_Bse_Tab(12));
      l_Msm_Add_Pur_Amt_Mul             := TRIM(l_Bse_Tab(13));
      l_Msm_Max_Pur_Amt                 := TRIM(l_Bse_Tab(14));
      l_Msm_Pur_Allowed                 := Upper(TRIM(l_Bse_Tab(10)));
      l_Msm_Pur_Cut_Off                 := TRIM(l_Bse_Tab(16));
      l_Redemp_Transac_Mode             := Upper(TRIM(l_Bse_Tab(18)));
      l_Msm_Min_Redem_Qty               := TRIM(l_Bse_Tab(19));
      l_Msm_Redem_Qty_Mul               := TRIM(l_Bse_Tab(20));
      l_Msm_Max_Redem_Qty               := TRIM(l_Bse_Tab(21));
      l_Msm_Min_Redem_Amt               := TRIM(l_Bse_Tab(22));
      l_Msm_Max_Redem_Amt               := TRIM(l_Bse_Tab(23));
      l_Msm_Mul_Redem_Amt               := TRIM(l_Bse_Tab(24));
      l_Msm_Redem_Allowed               := Upper(TRIM(l_Bse_Tab(17)));
      l_Msm_Redem_Cut_Off               := TRIM(l_Bse_Tab(25));
      l_Bse_Rta_Code                    := Upper(TRIM(l_Bse_Tab(26)));
      l_Amc_Active_Flag                 := Upper(TRIM(l_Bse_Tab(27)));
      l_Msm_Div_Option                  := Upper(TRIM(l_Bse_Tab(28)));
      l_Msm_Scheme_Type                 := Upper(TRIM(l_Bse_Tab(7)));
      l_Msm_Sip_Yn                      := Upper(TRIM(l_Bse_Tab(29)));
      l_Msm_Stp_Yn                      := Upper(TRIM(l_Bse_Tab(30)));
      l_Msm_Swp_Yn                      := Upper(TRIM(l_Bse_Tab(31)));
      l_Msm_Settlement_Type             := Upper(TRIM(l_Bse_Tab(33)));
      l_Msm_Pur_Amt_Mul                 := TRIM(l_Bse_Tab(15));
      l_Switch_Fl                       := Upper(TRIM(l_Bse_Tab(32)));
      l_Face_Value                      := Upper(TRIM(l_Bse_Tab(35)));
      l_Start_Date                      := TO_DATE(l_Bse_Tab(36),'MON DD YYYY HH:MIAM');
      l_End_Date                        := TO_DATE(l_Bse_Tab(37),'MON DD YYYY HH:MIAM');
      l_Exit_Load_Fl                    := Upper(TRIM(l_Bse_Tab(38)));
      --l_Exit_Load                       := Upper(TRIM(l_Bse_Tab(39)));
      l_Lockin_Period_Fl                := Upper(TRIM(l_Bse_Tab(40)));
      l_Lockin_Period                   := Upper(TRIM(l_Bse_Tab(41)));
      /*l_SIP_Trigger_Fl                  := Upper(TRIM(l_Bse_Tab(43)));
      l_STP_Trigger_Fl                  := Upper(TRIM(l_Bse_Tab(44)));
      l_SWP_Trigger_Fl                  := Upper(TRIM(l_Bse_Tab(45)));*/


      IF l_Msm_Div_Option = 'Y' THEN
        l_Divd_Option          := 'R'; -- Reinvest
        l_Divd_Opt_For_Primary := 'DR';
      ELSIF l_Msm_Div_Option = 'N' THEN
        l_Divd_Option          := 'P'; -- Dividend Payout
        l_Divd_Opt_For_Primary := 'DP';
      ELSIF l_Msm_Div_Option = 'Z' THEN
        l_Divd_Option          := 'G'; -- Growth
        l_Divd_Opt_For_Primary := 'GR';
      END IF;

      IF l_Lockin_Period IS NOT NULL THEN
         l_Lockin_Period := round(l_Lockin_Period/30); -- converted days into months and removed the decimal places
      END IF;

      l_Msm_Physical_Yn := 'Y';

      IF (l_Purchase_Transaction_Mode = 'DP' AND l_Redemp_Transac_Mode = 'DP') OR
         (l_Purchase_Transaction_Mode = 'DP' AND l_Redemp_Transac_Mode = 'P')  OR
         (l_Purchase_Transaction_Mode = 'DP' AND l_Redemp_Transac_Mode = 'D')  OR
         (l_Purchase_Transaction_Mode = 'D'  AND l_Redemp_Transac_Mode = 'DP') OR
         (l_Purchase_Transaction_Mode = 'D'  AND l_Redemp_Transac_Mode = 'P')  OR
         (l_Purchase_Transaction_Mode = 'D'  AND l_Redemp_Transac_Mode = 'D')  OR
         (l_Purchase_Transaction_Mode = 'P'  AND l_Redemp_Transac_Mode = 'DP') OR
         (l_Purchase_Transaction_Mode = 'P'  AND l_Redemp_Transac_Mode = 'D')  THEN

         l_Msm_Demat_Yn    := 'Y';

      ELSE
        l_Msm_Demat_Yn    := 'N';
      END IF;

    END p_Assign_Into_Variables;

    PROCEDURE p_Validate_Data IS
    BEGIN
         l_Mand_Fields_Msg := '';
         l_Skip_Yn         := 'N';
      IF l_Msm_Scheme_Desc IS NULL THEN
        l_Mand_Fields_Msg := 'Scheme Desc' ;
        l_Skip_Yn         := 'Y';
      END IF;

      IF Length(l_Msm_Rta_Sch_Cd) > 5 THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'RTA Scheme Code Length is More Than 5 Charaters';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Scheme_Type IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Scheme Type';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Bse_Code IS NULL OR l_Msm_Bse_Unique_No IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'BSE Code' ||'--'||'BSE Unique No' ;
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Isin IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'ISIN';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Pur_Allowed NOT IN ('Y','N') THEN
        l_Msm_Pur_Allowed := 'N';
      END IF;

      IF l_Msm_Redem_Allowed NOT IN ('Y','N') THEN
        l_Msm_Redem_Allowed := 'N';
      END IF;

      IF l_Msm_Div_Option NOT IN ('Y','N','Z') THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Dividend Option';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Min_Pur_Amt IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Min Pur Amt';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Max_Pur_Amt IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Max Pur Amt';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Add_Pur_Amt_Mul IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Addn Pur Amt Multiplier';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Pur_Cut_Off IS NULL    THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Pur Cut-Off Time';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Min_Redem_Qty IS NULL  THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Min Redm Qty';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Max_Redem_Qty IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Max Redm Qty';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Redem_Qty_Mul IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Redm Qty Multiplier';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Redem_Cut_Off IS NULL THEN
        l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Redm Cut-Off Time';
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Msm_Min_Pur_Amt > 999999999999999999999990.00 THEN
        l_Msm_Min_Pur_Amt := 999999999999999999999990.00;
      END IF;

      IF l_Msm_Max_Pur_Amt > 999999999999999999999990.00 THEN
        l_Msm_Max_Pur_Amt := 999999999999999999999990.00;
      END IF ;

      IF l_Msm_Add_Pur_Amt_Mul > 999999999999999999999990.00 THEN
        l_Msm_Add_Pur_Amt_Mul := 999999999999999999999990.00;
      END IF ;

      IF l_Msm_Min_Redem_Qty > 999999999999999999999990.0000 THEN
        l_Msm_Min_Redem_Qty := 999999999999999999999990.0000;
      END IF ;

      IF l_Msm_Max_Redem_Qty > 999999999999999999999990.0000 THEN
        l_Msm_Max_Redem_Qty := 999999999999999999999990.0000;
      END IF ;

      IF l_Msm_Redem_Qty_Mul > 999999999999999999999990.00 THEN
        l_Msm_Redem_Qty_Mul := 999999999999999999999990.00;
      END IF ;

      IF  Nvl(l_Msm_Bse_Unique_No,0)= 0 THEN /*ASDF*/
        l_Mand_Fields_Msg := 'BSE Unique No Cannot be 0 for scheme code <'||l_Msm_Bse_Code ||'> and ISIN < '||l_Msm_ISIN||'>.' ;
        l_Skip_Yn         := 'Y';
      END IF;

      IF l_Skip_Yn = 'Y' THEN
        P_Ret_Msg := l_Mand_Fields_Msg;
        RAISE E_Mand_Exp;
      END IF;
    END p_Validate_Data;

  BEGIN
    p_Ret_Msg := ' Performing Housekeeping Activities ';
    Std_Lib.P_Housekeeping (l_Prg_Id,             'BSE',              'BSE'||'-'||P_File_Name,    'N',
                            l_Log_File_Handle,    l_Log_File_Name,    l_Prg_Process_Id,           'Y');

    l_Pam_Curr_Date  := Std_Lib.l_Pam_Curr_Date;
    l_File_Ptr       := Utl_File.fopen(P_Path, P_File_Name,'R',32767);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' || To_Char(l_Pam_Curr_Date, 'DD-MON-RRRR'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Exchange           :     ' || 'BSE');
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name          :     ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');

    p_Ret_Msg := ' Populating PlSql table for MFD Schemes ';
    SELECT COUNT(1)
    INTO   l_Count_Nse
    FROM   Program_Status
    WHERE  Prg_Dt     = l_Pam_Curr_Date
    AND    Prg_Cmp_Id = 'MFSSSITE'
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = 'NSE';

    IF l_Count_Nse > 0 THEN
      Utl_File.Put_Line(l_Log_File_Handle, 'WARNING : NSE File is already loaded for the day. Please load the same once again.');
    END IF;

    p_Ret_Msg := ' Populating PlSql table for MFD Schemes ';
    FOR i IN (SELECT Msm_Scheme_Id,
                     Msm_Isin
              FROM   Mfd_Scheme_Master
              WHERE  Msm_Status         = 'A'
              AND    Msm_Record_Status  = 'A')
    LOOP
      Tab_Mfd_Schemes(i.Msm_Scheme_Id) := i.Msm_Isin;
    END LOOP;

    SELECT Nvl(MAX(Rv_Low_Value),'BSE')
    INTO   l_Primary_File
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'MFD_PRIMARY_SCHEME_FILE';

    LOOP
  P_Ret_Msg:=Null;
      BEGIN
        Utl_File.Get_Line(l_File_Ptr,l_Line_Buffer,32767);
        l_Line_Buffer := TRIM(l_Line_Buffer);
      EXCEPTION
        WHEN No_Data_Found THEN
          RAISE End_Of_File;
      END;
      l_Line_No := l_Line_No + 1;
      SAVEPOINT currline ;

      BEGIN
        IF l_Line_No = 1 THEN
           RAISE E_Skip_Header;
        END IF;

        IF l_Line_Buffer IS NOT NULL THEN
          Std_Lib.Split_line(l_Line_Buffer, '|', l_Bse_Tab);

          p_Ret_Msg := ' Assigning values to variables ';
          p_Assign_Into_Variables;

          IF (l_Purchase_Transaction_Mode = 'P' AND l_Redemp_Transac_Mode = 'P') THEN
              P_Ret_Msg := 'Can not mapped in the system as it is a physical script.BSE Code<'||l_Msm_Bse_Code||'>';
              RAISE E_User_Exp;
          END IF ;

          IF substr(l_Msm_Bse_Code ,-2) = '-I' THEN
              P_Ret_Msg := 'This is insurance scheme hence skipped for BSE Code<'||l_Msm_Bse_Code||'>';
              RAISE E_User_Exp;
          END IF;

          p_Ret_Msg := ' Validation active and Inactive Scheme ';
          IF l_Msm_Pur_Allowed = 'N' AND l_Msm_Redem_Allowed = 'N' THEN
            IF l_Msm_Settlement_Type NOT IN ('L0','L1') THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin            = l_Msm_Isin
               --AND    Msm_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status          = 'A'
               AND    Msm_Record_Status   = 'A'
               AND    Trunc(Nvl(Msm_Last_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Purchase allowed and Redem allowed Flag is N for ISIN : '||l_Msm_Isin||' and Settlement type '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            ELSIF l_Msm_Settlement_Type = 'L0' THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin                   = l_Msm_Isin
               AND    Msm_Bse_Lo_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status                 = 'A'
               AND    Msm_Record_Status          = 'A'
               AND    Trunc(Nvl(Msm_Bse_Lo_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Purchase allowed and Redem allowed Flag is N for ISIN : '||l_Msm_Isin||' and Settlement type '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            ELSIF l_Msm_Settlement_Type = 'L1' THEN
               SELECT COUNT(*)
               INTO   l_Valid_Scheme_Count
               FROM   Mfd_Scheme_Master
               WHERE  Msm_Isin                   = l_Msm_Isin
               AND    Msm_Bse_L1_Settlement_Type = l_Msm_Settlement_Type
               AND    Msm_Status                 = 'A'
               AND    Msm_Record_Status          = 'A'
               AND    Trunc(Nvl(Msm_Bse_L1_Updt_Dt,Msm_Creat_Dt)) = Trunc(SYSDATE);

               IF l_Valid_Scheme_Count > 0 THEN
                  P_Ret_Msg  := 'Invalid record as specified by exchange .Purchase allowed and Redem allowed Flag is N for ISIN : '||l_Msm_Isin||' and Settlement type '||l_Msm_Settlement_Type;
                  l_Invalid_Record := l_Invalid_Record + 1;
                  RAISE E_Invalid_Excp;
               END IF;
            END IF;
          END IF;


          P_Ret_Msg := ' Validate Data ';
          p_Validate_Data;

          BEGIN
            SELECT Rv_Low_Value
            INTO   l_Msm_Scheme_Type
            FROM   Cg_Ref_Codes
            WHERE  Rv_Domain       = 'MF_SCHEME_TYPE'
            AND    Rv_Abbreviation = 'BSE'
            AND    Rv_High_Value   = l_Msm_Scheme_Type;
          EXCEPTION
            WHEN No_Data_Found THEN
               P_Ret_Msg := 'Scheme Type <'||l_Msm_Scheme_Type ||'>  is Not Mapped/Found for BSE in the System';
              RAISE E_User_Exp;
          END;

          BEGIN
            SELECT Rta_Id
            INTO   l_Internal_Rta_Id
            FROM   Mfd_Rta_Master
            WHERE  Rta_Bse_Id = l_Bse_Rta_Code;
          EXCEPTION
            WHEN No_Data_Found THEN
               P_Ret_Msg := 'RTA Id  <'||l_Bse_Rta_Code ||'> is Not Mapped/Found for BSE in the System';
              RAISE E_User_Exp;
          END;

          BEGIN
            SELECT Amc_Id
            INTO   l_Internal_Amc_Id
            FROM   Mfd_Amc_Master
            WHERE  Amc_Bse_Id = l_Bse_Amc_Code;
          EXCEPTION
            WHEN No_Data_Found THEN
               P_Ret_Msg := 'AMC Id <'||l_Bse_Amc_Code||'>is Not Mapped/Found for BSE in the System';
              RAISE E_User_Exp;
          END;

          IF l_Msm_Pur_Allowed = 'N' AND l_Msm_Redem_Allowed = 'N' THEN

             BEGIN
               SELECT Msm_Isin
               INTO   l_Already_Mapped_Isin
               FROM   Mfd_Scheme_Master t
               WHERE  Msm_Scheme_Id       = l_Internal_Amc_Id || l_Msm_Rta_Sch_Cd || l_Divd_Opt_For_Primary
               AND    Msm_Status          = 'A'
               AND    Msm_Record_Status   = 'A'
               AND    Msm_Bse_Allowed     = 'Y'
               AND   (Msm_Pur_Allowed     = 'Y' OR Msm_Redem_Allowed = 'Y');
             EXCEPTION
               WHEN No_Data_Found THEN
                 l_Already_Mapped_Isin :=  NULL;
             END;

             IF Nvl(l_Already_Mapped_Isin,l_Msm_Isin) != l_Msm_Isin THEN
                P_Ret_Msg  := 'Invalid record as specified by exchange for ISIN : '||l_Msm_Isin||' and Settlement type '||l_Msm_Settlement_Type;
                l_Invalid_Record := l_Invalid_Record + 1;
                RAISE E_Invalid_Excp;
             END IF;
          END IF;

          BEGIN
            SELECT *
            INTO   r_Mfd_Scheme_Master
            FROM   Mfd_Scheme_Master
            WHERE  Msm_Isin           = l_Msm_Isin
            AND    Msm_Status         = 'A'
            AND    Msm_Record_Status  = 'A'
            AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date) ;
            l_Change_New := 'C';
          EXCEPTION
            WHEN No_Data_Found THEN
              BEGIN
                SELECT *
                INTO   r_Mfd_Scheme_Master
                FROM   Mfd_Scheme_Master
                WHERE  Decode(l_Msm_Settlement_Type,'L0',Msm_Bse_LO_Scheme_Code,'L1',Msm_Bse_L1_Scheme_Code, Msm_Bse_Code) =  l_Msm_Bse_Code
                AND    Msm_Status        =  'A'
                AND    Msm_Record_Status =  'A'
                AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date) ;
                l_Change_New := 'C';
              EXCEPTION
                WHEN No_Data_Found THEN
                  l_Change_New     := 'N';
                  l_Msm_Scheme_Id  := l_Internal_Amc_Id || l_Msm_Rta_Sch_Cd || l_Divd_Opt_For_Primary;

                  IF Tab_Mfd_Schemes.EXISTS(l_Msm_Scheme_Id) AND Tab_Mfd_Schemes(l_Msm_Scheme_Id) <> l_Msm_Isin THEN
                    P_Ret_Msg := 'WARNING : Scheme Id <'||l_Msm_Scheme_Id||'> is already mapped in the system to Isin <'||Tab_Mfd_Schemes(l_Msm_Scheme_Id)||'>
                                  and Settlement Type <'||l_Msm_Settlement_Type||'> Should be manually updated in Scheme Master Screen to ISIN <'||l_Msm_Isin||'>,
                                  Scheme Code <'||l_Msm_Bse_Code||'> ,Unique No <'||l_Msm_Bse_Unique_No||'> ,Purchase Flag <'||l_Msm_Pur_Allowed||'> ,Redemption Flag <'||l_Msm_Redem_Allowed||'>
                                  and Demat Flag <'||l_Msm_Demat_Yn||'>';
                    RAISE E_User_Exp;
                  END IF;
                WHEN Too_Many_Rows THEN
                  P_Ret_Msg := 'This BSE, NSE, RTA, AMFI or ISIN exists for multiple records <'||l_Msm_Data_Vendor_Id||'>';
                  RAISE E_User_Exp;
              END ;
          END;

          IF l_Primary_File = 'BSE' THEN
            IF l_Change_New = 'C' THEN
              p_Full_Upd_Scheme_Master;
              l_Count_Updated  :=  l_Count_Updated + 1;
            ELSE
              l_Msm_Record_Status := 'A';

              p_Insert_Mfd_Scheme_Master ;
              l_Count_Inserted := l_Count_Inserted + 1;
            END IF;
          ELSE
            IF l_Change_New ='C' THEN
               Null_Upd_Scheme_Master ;
               l_Count_Updated  :=  l_Count_Updated + 1;
               p_Write_Change_Skip_In_Log ;
            ELSE
               l_Msm_Record_Status := 'A';
               p_Insert_Mfd_Scheme_Master ;
               l_Count_Inserted := l_Count_Inserted + 1;
            END IF ;
          END IF ;
        END IF;
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          BEGIN
            SELECT Msm_Isin
            INTO   l_Mapped_Isin
            FROM   Mfd_Scheme_Master
            WHERE  Msm_Scheme_Id     = l_Msm_Scheme_Id
            AND    Msm_Record_Status = 'A'
            AND    Msm_Status        = 'A';

            IF l_Msm_Pur_Allowed = 'Y' OR l_Msm_Redem_Allowed = 'Y' THEN
               Utl_File.New_Line(l_Log_File_Handle, 1);
               Utl_File.Put_Line(l_Log_File_Handle,'Line <'||l_Line_Buffer||'>');
               P_Ret_Msg := 'WARNING : Scheme Id <'||l_Msm_Scheme_Id||'> is already mapped in the system to Isin <'||l_Mapped_Isin||'>
                             and Settlement Type <'||l_Msm_Settlement_Type||'> Should be manually updated in Scheme Master Screen to ISIN <'||l_Msm_Isin||'>
                            ,Scheme Code <'||l_Msm_Bse_Code||'> ,Unique No <'||l_Msm_Bse_Unique_No||'> ,Purchase Flag <'||l_Msm_Pur_Allowed||'> ,Redemption Flag <'||l_Msm_Redem_Allowed||'>
                             and Demat Flag <'||l_Msm_Demat_Yn||'>';
               Utl_File.Put_Line(l_Log_File_Handle, P_Ret_Msg);
            END IF;
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;

         l_Count_Skipped := l_Count_Skipped + 1;

        WHEN  E_Invalid_Excp THEN
          NULL;
        WHEN E_User_Exp THEN
          Utl_File.New_Line(l_Log_File_Handle, 1);
          Utl_File.Put_Line(l_Log_File_Handle,'    Line <'||l_Line_Buffer||'>');
          P_Ret_Msg := P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme : '||l_Msm_Scheme_Desc;
          Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
          l_Count_Skipped := l_Count_Skipped + 1;
        WHEN E_Mand_Exp THEN
          Utl_File.New_Line(l_Log_File_Handle, 1);
          P_Ret_Msg := ' Record Skipped due to null value in mandatory fields - '||P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme : '||l_Msm_Scheme_Desc;
          Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
          l_Count_Skipped := l_Count_Skipped + 1;
        WHEN E_Skip_Header THEN
          P_Ret_Msg := 'Skipping Header record : ';
          Utl_File.Put_Line(l_Log_File_Handle,P_Ret_Msg);
        WHEN OTHERS THEN
          ROLLBACK TO currline ;
          Utl_File.New_Line(l_Log_File_Handle, 1);
          Utl_File.Put_Line(l_Log_File_Handle, dbms_utility.format_error_backtrace||'*** Error at Line <'||l_Line_No||'> '|| Substr(SQLERRM,1,800));
          Utl_File.Put_Line(l_Log_File_Handle,'    Line <'||l_Line_Buffer||'>');
          l_Count_Skipped := l_Count_Skipped + 1;
      END;
    END LOOP;

    Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Date,   l_Prg_Process_Id,
                             'C',          'Y',               l_Sql_Err);


    Utl_File.Put_Line(l_Log_File_Handle,'Please Load NSE file .This is required for proper Scheme category updation.');

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';

  EXCEPTION
    WHEN End_Of_File THEN
      l_Count_Records := l_Line_No;
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                                             : ' || l_Count_Records);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted (Checker Mode)                             : ' || l_Count_Inserted);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated                                             : ' || l_Count_Updated);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                                             : ' || l_Count_Skipped);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped due to invalid ISIN                         : ' || l_Invalid_Record );
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped Updation of Some fields (Due To Difference) : ' || l_Count_Change_Skip);
      Utl_File.Put_Line(l_Log_File_Handle, ' ============================================================================================');
      Utl_File.Put_Line(l_Log_File_Handle, '                 Details Of Records Having Duplicate Unique No In BSE:');
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('-',160,'-'));
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('Scheme Id',30)||' | '||RPAD('Scheme Description',100)||' | '||RPAD('Amc Id',10)||' | '||RPAD('Unique No.',10));
      Utl_File.Put_Line(l_Log_File_Handle, RPAD('-',160,'-'));
      FOR i IN C_Bse_Dup_No
      LOOP
       Utl_File.Put_Line(l_Log_File_Handle, RPAD(i.msm_scheme_id,30)||' | ' ||RPAD(i.msm_scheme_desc,100)||' | '||RPAD(i.msm_amc_id,10)||' | '||RPAD(i.msm_bse_unique_no,10));
      END LOOP;
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
      Utl_File.Fclose(l_Log_File_Handle);
      Utl_File.fclose(l_File_Ptr);

      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Date,   l_Prg_Process_Id,
                               'C',          'Y',               l_Sql_Err);

      P_Ret_Val  := 'SUCCESS';
      P_Ret_Msg  := 'Process Completed Successfully !!! ';

    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      P_Ret_Msg := DBMS_UTILITY.Format_Error_Backtrace || CHR(10) || P_Ret_Msg || ' Error - ' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, substr(P_Ret_Msg,1,800));
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,     l_Pam_Curr_Date,   l_Prg_Process_Id,
                               'E',          'Y',               l_Sql_Err);

  END P_Mfd_Load_Mfss_Bse_Site_File;

  PROCEDURE P_MFD_Load_Amfi_File( P_Path      Varchar2,
                                  P_File_Name Varchar2,
                                  P_File_Date Date,
                                  P_Load_Instrument_Yn VARCHAR2)
  AS

     TYPE t_tab IS TABLE OF VARCHAR2(800) INDEX BY BINARY_INTEGER;

     l_Int_Scheme_Code    t_tab;
     l_Amc_Id             t_tab;
     l_Isin               t_tab;

     l_Prg_Id             Varchar2(10) := 'MFDQNAVA';
     o_Log_File_Ptr       Utl_File.File_Type;
     o_Log_File_Name      Varchar(1000);
     o_Process_Id         Number;

     l_File_Ptr           Utl_File.File_Type;
     l_Line_Buffer        Varchar2(1000) ;
     l_Line_No            Number := 0 ;
     l_Number_Blank       Number := 0;
     l_Nav_Data_Lines     Number := 0;
     l_Inst_Data_Lines    Number := 0;
     l_Nav_Inserted       Number := 0;
     l_Nav_Updated        Number := 0;
     l_Zero_Nav           Number := 0;
     l_New_Schems         Number := 0;

     l_Cols               Std_Lib.Tab;
     l_Scheme_Type        Varchar2(100);
     l_Amc_Name           Varchar2(200);
     l_Amfi_Code          Varchar2(30) ;
     l_Scheme_Name        Varchar2(200);
     l_Nav                Number(15,4);
     l_Record_Date        Date ;
     l_Pam_Curr_Date      Date ;

     End_Of_File          Exception;
     l_Sql_Err            Varchar2(2000) ;

     l_Prev_Line_buffer   Varchar2(2000) ;
     l_Data_Row           Varchar2(1):= 'N' ;
     l_Int_Sch_Not_Found_Count Number := 0 ;
     l_Incorrect_Date_Count    Number := 0 ;
  BEGIN
    STD_Lib.P_Housekeeping(l_Prg_Id,
                           Null,
                           'MFD',
                           'N',
                           o_Log_File_Ptr,
                           o_Log_File_Name,
                           o_Process_Id);
    l_Pam_Curr_Date := Std_Lib.l_Pam_Curr_Date;

    l_file_Ptr := Utl_File.fopen(P_Path,P_File_Name,'R');

    LOOP
      l_Int_Scheme_Code.DELETE;
      l_Amc_Id.DELETE;
      l_Isin.DELETE;

      BEGIN
        Utl_File.Get_Line(l_File_Ptr,l_Line_Buffer);
        l_Line_Buffer := Trim(l_Line_Buffer);
        IF l_Line_Buffer is Not Null Then
          l_Line_Buffer := Std_Lib.Remove_Invalid_Char(l_Line_Buffer);
        END IF ;
      EXCEPTION
        WHEN No_Data_Found Then
          RAISE End_Of_File;
      END ;
      l_Line_No := l_Line_No + 1;

  /*    IF l_Line_No = 407 Then -- Uncomment For Deugging purpose only
        l_Data_Row := 'Y' ;
      END IF ;*/

      IF l_Line_No > 1 AND l_Line_Buffer is Not Null Then
        IF Instr(l_Line_Buffer,';',1,5) > 0 Then
           l_Data_Row := 'Y' ;
           l_Nav_Data_Lines    := l_Nav_Data_Lines + 1;
        ELSE
           l_Data_Row := 'N' ;
           l_Inst_Data_Lines    := l_Inst_Data_Lines + 1;
        END IF ;

        IF l_Data_Row = 'N' Then
           IF l_Prev_Line_Buffer is Null Then
             l_Scheme_Type := l_Line_Buffer;
           ELSIF Instr(Nvl(l_Prev_Line_Buffer,'A'),';',1,5) <= 0 Then
             l_Amc_Name := l_Line_Buffer;
             l_Scheme_Type := l_Prev_Line_Buffer;
           ELSIF Instr(Nvl(l_Prev_Line_Buffer,'A'),';',1,5) > 0 Then
             l_Amc_Name := l_Line_Buffer;    -- In case of Scheme Type row, AMC name will be wrongly assigned as scheme type but it will be corrected when we encounter amc name record.
           END IF ;
        ELSE
           Std_Lib.Split_line(l_Line_Buffer,';',l_Cols);
           l_Amfi_Code         := l_Cols(1) ;
           l_Scheme_Name       := l_Cols(4) ;
           BEGIN
             l_Nav               := l_Cols(5) ;
             --l_Record_Date       := To_Date(l_Cols(8),'DD-Mon-YYYY') ;
             l_Record_Date       := To_Date(l_Cols(6),'DD-Mon-YYYY') ;  -- Rajdeep 05-Jul-2018
           EXCEPTION
             When Others Then
               l_Nav      := 0 ;
           END ;
          -- IF  l_Record_Date = P_File_Date THEN
             BEGIN
               SELECT Msm_Scheme_Id, Msm_Amc_Id,MSM_ISIN
               BULK COLLECT INTO l_Int_Scheme_Code, l_Amc_Id, l_Isin
               FROM   Mfd_Scheme_Master M
               WHERE  Msm_Amfi_Code              = l_Amfi_Code
               AND    M.Msm_Record_Status        ='A'
               AND    M.Msm_Status               ='A'
               AND    l_Pam_Curr_Date  BETWEEN M.Msm_From_Date AND nvl(m.Msm_To_Date,l_Pam_Curr_Date);

               IF l_Int_Scheme_Code.COUNT = 0 THEN
                  l_Int_Sch_Not_Found_Count := l_Int_Sch_Not_Found_Count + 1;
               END IF;

               -- We do not need to insert Schemes into Scheme Maaster through this Process
                /*
                 IF P_Load_Instrument_Yn = 'Y' Then
                   SELECT Count(1)
                   INTO   l_Amfi_Exists
                   FROM   Mfd_Scheme_Master
                   WHERE  Msm_Amfi_Code = l_Amfi_Code ;

                   IF l_Amfi_Exists = 0 Then
                     INSERT Into Mfd_Scheme_Master
                        (msm_amfi_code, msm_scheme_desc, msm_scheme_type, msm_amc_name,msm_Source,Msm_Record_Status )
                     VALUES
                        (l_Amfi_Code,l_Scheme_Name,l_Scheme_Type,l_Amc_Name, 'AMFI_NAV','N')  ;

                     l_New_Schems := l_New_Schems + 1 ;
                   END IF ;
                 END IF ;
                */
             END ;

             IF (l_Int_Scheme_Code.COUNT > 0 AND l_Nav = 0) THEN
               l_Zero_Nav := l_Zero_Nav + 1 ;
             END IF ;

             IF (l_Int_Scheme_Code.COUNT > 0 AND l_Nav > 0) THEN
                FOR i IN l_Int_Scheme_Code.FIRST..l_Int_Scheme_Code.LAST LOOP
                  BEGIN
                    INSERT Into Mfd_Nav (Mn_Amc_Id, Mn_Scheme_Id, Mn_Nav_Date, Mn_Nav_Value,MN_ISIN, Mn_Prg_Id, Mn_Source)
                      Values(l_Amc_Id(i),l_Int_Scheme_Code(i),l_Record_Date,l_Nav,l_Isin(i), l_Prg_Id, 'AMFI File');

                      l_Nav_Inserted := l_Nav_Inserted + 1;
                  EXCEPTION
                    WHEN Dup_Val_On_Index Then
                      UPDATE Mfd_Nav
                      SET    Mn_Nav_Value = l_Nav
                      WHERE  Mn_Scheme_Id = l_Int_Scheme_Code(i)
                      AND    Mn_Amc_Id    = l_Amc_Id(i)
                      AND    Mn_Nav_Date  = l_Record_Date ;

                      l_Nav_Updated    := l_Nav_Updated + 1 ;
                  END ;
                END LOOP; -- Loop for inserting & updating NAV
             END IF ;
          -- ELSE
          --   l_Incorrect_Date_Count := l_Incorrect_Date_Count + 1 ;
          -- END IF ;
         END IF ;
        l_Prev_Line_Buffer := l_Line_Buffer;
      END IF ;
    END LOOP ;

    STD_Lib.P_Updt_Prg_Stat(l_Prg_Id,
                            Std_Lib.l_Pam_Curr_Date,
                            o_Process_Id,
                            'Y',
                            'Y',
                            l_Sql_Err);
  EXCEPTION
    WHEN End_Of_File Then
      l_Number_Blank  := l_Line_No-(l_Nav_Data_Lines+l_Inst_Data_Lines);
      Utl_File.Put_Line(o_Log_File_Ptr,'============================================================================================');
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of lines In File                                  :'||lpad(l_Line_No,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of  Blank lines In File                           :'||lpad(l_Number_Blank,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of NAV Data Lines                                 :'||lpad(l_Nav_Data_Lines,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Instrument Data lines                          :'||lpad(l_Inst_Data_Lines,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,'-----------------------------------------------------------------------------------------');
      Utl_File.New_Line(o_Log_File_Ptr);
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Records Inserted for NAV                      :'||lpad(l_Nav_Inserted,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Records Updated  for NAV                      :'||lpad(l_Nav_Updated,7,' ' ));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Records with Zero NAV/Nav Date Is Not Valid   :'||lpad(l_Zero_Nav,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Records NOT FOUND in Scheme Master            :'||lpad(l_Int_Sch_Not_Found_Count,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of Records with old date                         :'||lpad(l_Incorrect_Date_Count,7,' '));
      Utl_File.New_Line(o_Log_File_Ptr);
      Utl_File.New_Line(o_Log_File_Ptr);
      Utl_File.Put_Line(o_Log_File_Ptr,' Number of New Schemes added in Master(Maker)            :'||lpad(l_New_Schems,7,' '));
      Utl_File.Put_Line(o_Log_File_Ptr,'==========================================================================================');
      Utl_File.New_Line(o_Log_File_Ptr);
      Utl_File.Put_Line(o_Log_File_Ptr,'Process Completed Successfully !');
      Utl_File.fclose(l_File_Ptr);
      Utl_File.fclose(o_Log_File_Ptr);
      STD_Lib.P_Updt_Prg_Stat(l_Prg_Id,
                              Std_Lib.l_Pam_Curr_Date,
                              o_Process_Id,
                              'Y',
                              'Y',
                              l_Sql_Err);
    WHEN OTHERS THEN
      ROLLBACK;
      Utl_File.Put_Line(o_Log_File_Ptr, dbms_utility.format_Error_Backtrace||
                                        '*** Error at Line <'||l_Line_No||'> '|| Substr(Sqlerrm,1,800));
      Utl_File.Put_Line(o_Log_File_Ptr, '*** Data Line <'||l_Line_Buffer||'>');
      Utl_File.fclose(o_Log_File_Ptr);
      STD_Lib.P_Updt_Prg_Stat(l_Prg_Id,
                              Std_Lib.l_Pam_Curr_Date,
                              o_Process_Id,
                              'N',
                              'Y',
                              l_Sql_Err);

  END P_MFD_Load_Amfi_File;

  PROCEDURE P_Mfd_Load_Mfss_Vendor_File( P_Path      IN VARCHAR2,
                                         P_File_Name IN VARCHAR2,
                                         P_Ret_Val   IN OUT VARCHAR2,
                                         P_Ret_Msg   IN OUT VARCHAR2) AS

    l_File_Ptr                      Utl_File.File_Type         ;
    l_Log_File_Handle               Utl_File.File_Type         ;
    l_Bse_Tab                        Std_Lib.Tab               ;
    r_Mfd_scheme_master             Mfd_Scheme_Master%ROWTYPE  ;
    l_Prg_id                        VARCHAR2(10) := 'MFVENDOR' ;
    l_Log_File_Name                 VARCHAR(1000)              ;
    l_Prg_Process_Id                NUMBER := 0                ;
    l_Line_Buffer                   VARCHAR2(32767)     ;
    l_Line_No                       NUMBER := 0         ;
    l_Msm_Scheme_Id                 VARCHAR2(30)        ;
    l_Msm_Scheme_Desc               VARCHAR2(200)       ;
    l_Msm_Amc_Id                    VARCHAR2(30)        ;
    l_Msm_Rta_Id                    VARCHAR2(30)        ;
    l_Msm_from_date                 DATE                ;
    l_Msm_To_Date                   DATE                ;
    l_Pam_Curr_Date                 DATE                ;
    l_Msm_Scheme_Type               VARCHAR2(20)        ;
    l_Msm_Bse_Code                  VARCHAR2(30)        ;
    l_Msm_nse_code                  VARCHAR2(30)        ;
    l_Msm_Isin                      VARCHAR2(20)        ;
    l_Msm_Rta_Sch_Cd                VARCHAR2(10)         ;
    l_Msm_Amfi_Code                 VARCHAR2(50)        ;
    l_Msm_Data_Vendor_Id            VARCHAR2(50)        ;
    l_Msm_Sch_Asset_Cls             VARCHAR2(50)        ;
    l_Msm_Sch_Cat                   VARCHAR2(50)        ;
    l_Msm_Sch_Sub_Cat               VARCHAR2(50)        ;
    l_Msm_Unit_Face_Value           NUMBER              ;
    l_Msm_Coll_Cap                  VARCHAR2(50)        ;
    l_Msm_Last_Div_Date             DATE                ;
    l_Msm_Last_Div_Per_Unit         NUMBER(24,4)        ;
    l_Msm_Nfo_From_Date             DATE                ;
    l_Msm_Nfo_To_Date               DATE                ;
    l_Msm_Pur_Allowed               VARCHAR2(1)         ;
    l_Msm_Redem_Allowed             VARCHAR2(1)         ;
    l_Msm_Allowed_For_Coll          VARCHAR2(1)         ;
    l_Msm_Nri_Allowed               VARCHAR2(1)         ;
    l_Msm_Nse_Allowed               VARCHAR2(1)         ;
    l_Msm_Bse_Allowed               VARCHAR2(1)         ;
    l_Msm_Physical_Yn               VARCHAR2(1)         ;
    l_Msm_Demat_Yn                  VARCHAR2(1)         ;
    l_Msm_Nfo_Yn                    VARCHAR2(1)         ;
    l_Msm_Sip_Yn                    VARCHAR2(1)         ;
    l_Msm_Swp_Yn                    VARCHAR2(1)         ;
    l_Msm_Stp_Yn                    VARCHAR2(1)         ;
    l_Msm_Div_Option                VARCHAR2(1)         ;
    l_Msm_Entry_Load                NUMBER              ;
    l_Msm_Exit_Load                 NUMBER              ;
    l_Msm_Bse_Unique_No             NUMBER              ;
    l_Msm_Disp_Onl                  VARCHAR2(1)         ;
    l_Msm_Bank_Ac_No                VARCHAR2(50)        ;
    l_Msm_Bkm_Cd                    VARCHAR2(50)        ;
    l_Msm_Bbm_Cd                    VARCHAR2(50)        ;
    l_Msm_Bank_Ac_Code              VARCHAR2(50)        ;
    l_Msm_Min_Pur_Amt               NUMBER              ;
    l_Msm_Max_Pur_Amt               NUMBER              ;
    l_Msm_Add_Pur_Amt_Mul           NUMBER              ;
    l_Msm_Pur_Cut_Off               VARCHAR2(30)        ;
    l_Msm_Min_Redem_Qty             NUMBER(24,4)        ;
    l_Msm_Max_Redem_Qty             NUMBER(24,4)        ;
    l_Msm_Redem_Qty_Mul             NUMBER              ;
    l_Msm_Redem_Cut_Off             VARCHAR2(30)        ;
    l_Msm_Annual_Com_Per            NUMBER              ;
    l_Msm_Annual_Com_Per_Unit       NUMBER(24,4)        ;
    l_Msm_Annual_Special_Com        NUMBER              ;
    l_Msm_Trail_Com_Per             NUMBER              ;
    l_Msm_Trail_Com_Per_Unit        NUMBER(24,4)        ;
    l_Msm_Trail_Special_Com         NUMBER              ;
    l_Msm_Upfornt_Com_Per           NUMBER              ;
    l_Msm_Upfornt_Com_Per_Unit      NUMBER(24,4)        ;
    l_Msm_Upfornt_Special_Com       NUMBER              ;
    l_Msm_Contact_Person            VARCHAR2(200)       ;
    l_Msm_Contact_Email             VARCHAR2(200)       ;
    l_Msm_Contact_Phone             VARCHAR2(50)        ;
    l_Msm_Contact_Remark            VARCHAR2(3000)      ;
    l_Msm_Status                    VARCHAR2(30)        ;
    l_Msm_Amc_Name                  VARCHAR2(500)       ;
    l_Msm_Remark                    VARCHAR2(3000)      ;
    l_Msm_Fmp_Flag                  VARCHAR2(1)         ;
    l_Msm_Fmp_End_Date              DATE                ;
    l_Msm_Rta_Amc_Cd                VARCHAR2(50)        ;
    l_Msm_Amc_Sch_Cd                VARCHAR2(50)        ;
    l_Msm_Record_Status             VARCHAR2(1)         ;
    l_Msm_Amc_Code                  Varchar2(30)        ;
    l_Msm_Rvr_Fund_Rating           VARCHAR2(50)        ;
    l_Msm_Elss_Flag                 VARCHAR2(1)         ;
    l_Msm_Nfo_Time                  VARCHAR2(20)        ;
    l_Msm_Close_End_Sch             VARCHAR2(1)         ;
    l_Msm_No_Skip_Sip               NUMBER              ;
    l_Msm_Elss_Lockin_Months        NUMBER(3)           ;
    l_Msm_Nse_Unique_No             NUMBER              ;
    l_Msm_Nfo_Allotment_Date        DATE                ;
    l_Msm_Pur_Amt_Mul               NUMBER(24,2)        ;
    l_Msm_Add_Pur_Amt               NUMBER(24,2)        ;
    l_Msm_Min_Redem_Amt             NUMBER(24,2)        ;
    l_Msm_Max_Redem_Amt             NUMBER(24,2)        ;
    l_Msm_Switch_In                 VARCHAR2(1)         ;
    l_Msm_Settlement_Type           VARCHAR2(3)         ;
    l_Msm_Entry_Text                VARCHAR2(100)       ;
    l_Msm_Exit_Text                 VARCHAR2(100)       ;
    l_Msm_Switch_Out                VARCHAR2(1)         ;
    l_Msm_Nse_Pur_Cut_Off           VARCHAR2(10)        ;
    l_Msm_Bse_Pur_Cut_Off           VARCHAR2(10)        ;
    l_Msm_Nse_Redem_Cut_Off         VARCHAR2(10)        ;
    l_Msm_Bse_Redem_Cut_Off         VARCHAR2(10)        ;
    l_Change_New                    VARCHAR2(1)         ;
    l_Count_Records                 NUMBER  := 0        ;
    l_Count_Inserted                NUMBER  := 0        ;
    l_Count_Updated                 NUMBER  := 0        ;
    l_Count_Skipped                 NUMBER  := 0        ;
    l_Count_Updated_Existing        NUMBER  := 0        ;
    l_Sql_Err                       VARCHAR2(2000)      ;
    l_error_line_no                 VARCHAR2(500)       ;
    l_Mand_Fields_Msg               VARCHAR2(8000)      ;
    l_Skip_Yn                       VARCHAR2(1)         ;
    l_divd_option                   VARCHAR2(1)         ;
    l_Divind_Description            VARCHAR2(2)         ;
    l_internal_amc_id               VARCHAR2(50)        ;
    l_Primary_File                  VARCHAR2(20)        ;
    l_Count_Change_Skip             NUMBER := 0         ;
    End_Of_File                     EXCEPTION           ;
    E_User_Exp                      EXCEPTION           ;
    E_Mand_Exp                      EXCEPTION           ;
    l_Msm_Bank_Ac_Name              VARCHAR2(200)        ;

    PROCEDURE p_Insert_Mfd_Scheme_Master IS
    l_Double_Isin_Check  NUMBER := 0 ;
    BEGIN
       BEGIN
          SELECT COUNT(*)
          INTO   l_Double_Isin_Check
          FROM   Mfd_Scheme_Master S ,Parameter_Master p
          WHERE  S.Msm_Record_Status = 'A'
          AND    S.Msm_Status        = 'A'
          AND    p.Pam_Curr_Dt       BETWEEN S.Msm_From_Date AND nvl(s.Msm_To_Date,p.Pam_Curr_Dt)
          AND    S.Msm_Isin          = l_Msm_Isin           ;
       EXCEPTION
          WHEN No_Data_Found THEN
               l_Double_Isin_Check := 0;
       END;

       IF l_Double_Isin_Check > 0 THEN
          P_Ret_Msg := 'ISIN Already Exists ';
          RAISE E_User_Exp ;
       END IF;

       INSERT INTO Mfd_Scheme_Master
         ( Msm_Scheme_Id          , Msm_Scheme_Desc        , Msm_Amc_Id           , Msm_Rta_Id,
           Msm_from_date          , Msm_To_Date            , Msm_Scheme_Type      , Msm_Bse_Code,
           Msm_nse_code           , Msm_Isin               , Msm_Rta_Sch_Cd       , Msm_Amfi_Code,
           Msm_Data_Vendor_Id     , Msm_Sch_Asset_Cls      , Msm_Sch_Cat          , Msm_Sch_Sub_Cat,
           Msm_Unit_Face_Value    , Msm_Coll_Cap           , Msm_Last_Div_Date    , Msm_Last_Div_Per_Unit,
           Msm_Nfo_From_Date      , Msm_Nfo_To_Date        , Msm_Pur_Allowed      , Msm_Redem_Allowed,
           Msm_Allowed_For_Coll   , Msm_Nri_Allowed        , Msm_Nse_Allowed      , Msm_Bse_Allowed,
           Msm_Physical_Yn        , Msm_Demat_Yn           , Msm_Nfo_Yn           , Msm_Sip_Yn,
           Msm_Swp_Yn             , Msm_Stp_Yn             , Msm_Div_Option       , Msm_Entry_Load,
           Msm_Exit_Load          , Msm_Disp_Onl           , Msm_Min_Pur_Amt      , Msm_Max_Pur_Amt,
           Msm_Add_Pur_Amt_Mul    , Msm_Pur_Cut_Off        , Msm_Min_Redem_Qty    , Msm_Max_Redem_Qty,
           Msm_Redem_Qty_Mul      , Msm_Redem_Cut_Off      , Msm_Source           , Msm_Bank_Ac_No,
           Msm_Bank_Ac_Code       , Msm_Status             , Msm_Fmp_Flag         , Msm_Fmp_End_Date,
           Msm_Rta_Amc_Cd         , Msm_Amc_Sch_Cd         , Msm_Record_Status    , Msm_Prg_id,
           Msm_Nse_Unique_no      , Msm_Pur_Amt_Mul        , Msm_Add_Pur_amt      , Msm_Min_Redem_Amt,
           Msm_Max_Redem_Amt      , Msm_Switch_In          , Msm_Settlement_Type  , Msm_Entry_Text,
           Msm_Exit_Text          , Msm_Switch_Out         , Msm_Close_End_Sch    , Msm_Amc_Code,
           Msm_Rvr_Fund_Rating    , Msm_Elss_Flag          , Msm_Nfo_Time         , Msm_No_Skip_Sip,
           Msm_Elss_Lockin_Months , Msm_Nfo_Allotment_Date , Msm_Nse_Pur_Cut_Off  , Msm_Bse_Pur_Cut_Off,
           Msm_Nse_Redem_Cut_Off  , Msm_Bse_Redem_Cut_Off  , Msm_Amc_Name         , Msm_Bank_Ac_Name,
           Msm_Bse_Unique_No      , Msm_Creat_Dt           , Msm_Creat_By
         )
       VALUES
         (l_Msm_Scheme_Id         , UPPER(l_Msm_Scheme_Desc)   , l_Internal_Amc_Id           , Nvl(l_Msm_Rta_Id, 'KARVY'),
          l_Pam_Curr_Date         , l_Msm_To_Date              , l_Msm_Scheme_Type           , l_Msm_Bse_Code,
          l_Msm_nse_code          , l_Msm_Isin                 , l_Msm_Rta_Sch_Cd            , l_Msm_Amfi_Code,
          l_Msm_Data_Vendor_Id    , UPPER(l_Msm_Sch_Asset_Cls) , UPPER(l_Msm_Sch_Cat)        , UPPER(l_Msm_Sch_Sub_Cat),
          l_Msm_Unit_Face_Value   , l_Msm_Coll_Cap             , l_Msm_Last_Div_Date         , l_Msm_Last_Div_Per_Unit,
          l_Msm_Nfo_From_Date     , l_Msm_Nfo_To_Date          , l_Msm_Pur_Allowed           , l_Msm_Redem_Allowed,
          l_Msm_Allowed_For_Coll  , l_Msm_Nri_Allowed          , l_Msm_Nse_Allowed           , l_Msm_Bse_Allowed,
          l_Msm_Physical_Yn       , l_Msm_Demat_Yn             , l_Msm_Nfo_Yn                , l_Msm_Sip_Yn,
          l_Msm_Swp_Yn            , l_Msm_Stp_Yn               , l_divd_option               , l_Msm_Entry_Load,
          l_Msm_Exit_Load         , l_Msm_Disp_Onl             , l_Msm_Min_Pur_Amt           , l_Msm_Max_Pur_Amt,
          l_Msm_Add_Pur_Amt_Mul   , l_Msm_Pur_Cut_Off          , l_Msm_Min_Redem_Qty         , l_Msm_Max_Redem_Qty,
          l_Msm_Redem_Qty_Mul     , l_Msm_Redem_Cut_Off        , 'D'                         , l_Msm_Bank_Ac_No,
          l_Msm_Bank_Ac_Code      , Nvl(l_Msm_Status, 'A')     , l_Msm_Fmp_Flag              , l_Msm_Fmp_End_Date,
          l_Msm_Rta_Amc_Cd        , l_Msm_Amc_Sch_Cd           , Nvl(l_Msm_Record_Status,'A'), l_Prg_id,
          l_Msm_Nse_Unique_No     , l_Msm_Pur_Amt_Mul          , l_Msm_Add_Pur_Amt           , l_Msm_Min_Redem_Amt ,
          l_Msm_Max_Redem_Amt     , l_Msm_Switch_In            , l_Msm_Settlement_Type       , l_Msm_Entry_Text,
          l_Msm_Exit_Text         , l_Msm_Switch_Out           , l_Msm_Close_End_Sch         , l_Msm_Amc_Code,
          l_Msm_Rvr_Fund_Rating   , l_Msm_Elss_Flag            , l_Msm_Nfo_Time              , l_Msm_No_Skip_Sip,
          l_Msm_Elss_Lockin_Months, l_Msm_Nfo_Allotment_Date   , l_Msm_Nse_Pur_Cut_Off       , l_Msm_Bse_Pur_Cut_Off,
          l_Msm_Nse_Redem_Cut_Off , l_Msm_Bse_Redem_Cut_Off    , l_Msm_Amc_Name              , l_Msm_Bank_Ac_Name,
          l_Msm_Bse_Unique_No     , SYSDATE                    , USER
           );

        l_Count_Inserted := l_Count_Inserted + 1;

    END p_Insert_Mfd_Scheme_Master;

    PROCEDURE p_Full_Upd_Scheme_Master IS
    BEGIN
       UPDATE Mfd_scheme_master m
       SET    Msm_Scheme_Desc           =    Nvl(l_Msm_Scheme_Desc,        Msm_Scheme_Desc)  ,
              Msm_Sch_Asset_Cls         =    Nvl(l_Msm_Sch_Asset_Cls,      Msm_Sch_Asset_Cls) ,
              Msm_Sch_Cat               =    Nvl(l_Msm_Sch_Cat,            Msm_Sch_Cat),
              Msm_Sch_Sub_Cat           =    Nvl(l_Msm_Sch_Sub_Cat,        Msm_Sch_Sub_Cat),
              Msm_Scheme_Type           =    Nvl(l_Msm_Scheme_Type,        Msm_Scheme_Type),
              Msm_Data_Vendor_Id        =    Nvl(l_Msm_Data_Vendor_Id,     Msm_Data_Vendor_Id),
              Msm_Bse_Code              =    Nvl(l_Msm_Bse_Code,           Msm_Bse_Code),
              Msm_Nse_Code              =    Nvl(l_Msm_Nse_Code,           Msm_Nse_Code),
              Msm_Rta_Sch_Cd            =    Nvl(l_Msm_Rta_Sch_Cd,         Msm_Rta_Sch_Cd),
              Msm_Amfi_Code             =    Nvl(l_Msm_Amfi_Code,          Msm_Amfi_Code),
              Msm_Isin                  =    Nvl(l_Msm_Isin,               Msm_Isin),
              Msm_Unit_Face_Value       =    Nvl(l_Msm_Unit_Face_Value,    Msm_Unit_Face_Value),
              Msm_Coll_Cap              =    Nvl(l_Msm_Coll_Cap,           Msm_Coll_Cap),
              Msm_Last_Div_Date         =    Nvl(l_Msm_Last_Div_Date,      Msm_Last_Div_Date),
              Msm_Last_Div_Per_Unit     =    Nvl(l_Msm_Last_Div_Per_Unit,  Msm_Last_Div_Per_Unit),
              Msm_Nfo_From_Date         =    Nvl(l_Msm_Nfo_From_Date,      Msm_Nfo_From_Date),
              Msm_Nfo_To_Date           =    Nvl(l_Msm_Nfo_To_Date,        Msm_Nfo_To_Date),
              Msm_Pur_Allowed           =    Nvl(l_Msm_Pur_Allowed,        Msm_Pur_Allowed),
              Msm_Redem_Allowed         =    Nvl(l_Msm_Redem_Allowed,      Msm_Redem_Allowed),
              Msm_Allowed_For_Coll      =    Nvl(l_Msm_Allowed_For_Coll,   Msm_Allowed_For_Coll),
              Msm_Nri_Allowed           =    Nvl(l_Msm_Nri_Allowed,        Msm_Nri_Allowed),
              Msm_Nse_Allowed           =    Nvl(l_Msm_Nse_Allowed,        Msm_Nse_Allowed),
              Msm_Bse_Allowed           =    Nvl(l_Msm_Bse_Allowed,        Msm_Bse_Allowed ),
              Msm_Physical_Yn           =    Nvl(l_Msm_Physical_Yn,        Msm_Physical_Yn  ),
              Msm_Demat_Yn              =    Nvl(l_Msm_Demat_Yn,           Msm_Demat_Yn ),
              Msm_Nfo_Yn                =    Nvl(l_Msm_Nfo_Yn,             Msm_Nfo_Yn ),
              Msm_Sip_Yn                =    Nvl(l_Msm_Sip_Yn,             Msm_Sip_Yn ),
              Msm_Swp_Yn                =    Nvl(l_Msm_Swp_Yn,             Msm_Swp_Yn ),
              Msm_Stp_Yn                =    Nvl(l_Msm_Stp_Yn,             Msm_Stp_Yn ),
              Msm_div_option            =    Nvl(l_divd_option,            Msm_div_option  ),
              Msm_Entry_Load            =    Nvl(l_Msm_Entry_Load,         Msm_Entry_Load ),
              Msm_Exit_Load             =    Nvl(l_Msm_Exit_Load,          Msm_Exit_Load  ),
              Msm_Disp_Onl              =    Nvl(l_Msm_Disp_Onl,           Msm_Disp_Onl  ),
              Msm_Bank_Ac_No            =    Nvl(l_Msm_Bank_Ac_No,         Msm_Bank_Ac_No ),
              Msm_Bkm_Cd                =    Nvl(l_Msm_Bkm_Cd,             Msm_Bkm_Cd     ),
              Msm_Bbm_Cd                =    Nvl(l_Msm_Bbm_Cd,             Msm_Bbm_Cd ),
              Msm_Bank_Ac_Code          =    Nvl(l_Msm_Bank_Ac_Code,       Msm_Bank_Ac_Code),
              Msm_Min_Pur_Amt           =    Nvl(l_Msm_Min_Pur_Amt,        Msm_Min_Pur_Amt),
              Msm_Max_Pur_Amt           =    Nvl(l_Msm_Max_Pur_Amt,        Msm_Max_Pur_Amt),
              Msm_Add_Pur_Amt_Mul       =    Nvl(l_Msm_Add_Pur_Amt_Mul,    Msm_Add_Pur_Amt_Mul),
              Msm_Pur_Cut_Off           =    Nvl(l_Msm_Pur_Cut_Off,        Msm_Pur_Cut_Off),
              Msm_Min_Redem_Qty         =    Nvl(l_Msm_Min_Redem_Qty,      Msm_Min_Redem_Qty),
              Msm_Max_Redem_Qty         =    Nvl(l_Msm_Max_Redem_Qty,      Msm_Max_Redem_Qty    ),
              Msm_Redem_Qty_Mul         =    Nvl(l_Msm_Redem_Qty_Mul,      Msm_Redem_Qty_Mul ),
              Msm_Redem_Cut_Off         =    Nvl(l_Msm_Redem_Cut_Off,      Msm_Redem_Cut_Off ),
              Msm_Annual_Com_Per        =    Nvl(l_Msm_Annual_Com_Per,     Msm_Annual_Com_Per ),
              Msm_Annual_Com_Per_Unit   =    Nvl(l_Msm_Annual_Com_Per_Unit,Msm_Annual_Com_Per_Unit ),
              Msm_Annual_Special_Com    =    Nvl(l_Msm_Annual_Special_Com, Msm_Annual_Special_Com),
              Msm_Trail_Com_Per         =    Nvl(l_Msm_Trail_Com_Per,      Msm_Trail_Com_Per),
              Msm_Trail_Com_Per_Unit    =    Nvl(l_Msm_Trail_Com_Per_Unit, Msm_Trail_Com_Per_Unit ),
              Msm_Trail_Special_Com     =    Nvl(l_Msm_Trail_Special_Com,  Msm_Trail_Special_Com ),
              Msm_Upfornt_Com_Per       =    Nvl(l_Msm_Upfornt_Com_Per,    Msm_Upfornt_Com_Per ),
              Msm_Upfornt_Com_Per_Unit  =    Nvl(l_Msm_Upfornt_Com_Per_Unit,Msm_Upfornt_Com_Per_Unit),
              Msm_Upfornt_Special_Com   =    Nvl(l_Msm_Upfornt_Special_Com,Msm_Upfornt_Special_Com ),
              Msm_Contact_Person        =    Nvl(l_Msm_Contact_Person,     Msm_Contact_Person ),
              Msm_Contact_Email         =    Nvl(l_Msm_Contact_Email,      Msm_Contact_Email  ),
              Msm_Contact_Phone         =    Nvl(l_Msm_Contact_Phone,      Msm_Contact_Phone  ),
              Msm_Contact_Remark        =    Nvl(l_Msm_Contact_Remark,     Msm_Contact_Remark  ),
              Msm_Amc_Name              =    Nvl(l_Msm_Amc_Name,           Msm_Amc_Name      ),
              Msm_Remark                =    Nvl(l_Msm_Remark,             Msm_Remark),
              Msm_Fmp_Flag              =    Nvl(l_Msm_Fmp_Flag,           Msm_Fmp_Flag),
              Msm_Fmp_End_Date          =    Nvl(l_Msm_Fmp_End_Date,       Msm_Fmp_End_Date),
              Msm_Rta_Amc_Cd            =    Nvl(l_Msm_Rta_Amc_Cd,         Msm_Rta_Amc_Cd),
              Msm_Amc_Sch_Cd            =    Nvl(l_Msm_Amc_Sch_Cd,         Msm_Amc_Sch_Cd),
              Msm_Bse_Unique_No         =    Nvl(l_Msm_Bse_Unique_No,      Msm_Bse_Unique_No),
              Msm_Nse_Unique_No         =    Nvl(l_Msm_Nse_Unique_No,      Msm_Nse_Unique_No ),
              Msm_Pur_Amt_Mul           =    Nvl(l_Msm_Pur_Amt_Mul,        Msm_Pur_Amt_Mul ),
              Msm_Add_Pur_Amt           =    Nvl(l_Msm_Add_Pur_Amt,        Msm_Add_Pur_Amt   ),
              Msm_Min_Redem_Amt         =    Nvl(l_Msm_Min_Redem_Amt,      Msm_Min_Redem_Amt  ),
              Msm_Max_Redem_Amt         =    Nvl(l_Msm_Max_Redem_Amt ,     Msm_Max_Redem_Amt  ),
              Msm_Switch_In             =    Nvl(l_Msm_Switch_In  ,        Msm_Switch_In   ),
              Msm_Settlement_Type       =    Nvl(l_Msm_Settlement_Type,    Msm_Settlement_Type ),
              Msm_Entry_Text            =    Nvl(l_Msm_Entry_Text,         Msm_Entry_Text  ),
              Msm_Exit_Text             =    Nvl(l_Msm_Exit_Text,          Msm_Exit_Text  ),
              Msm_Switch_Out            =    Nvl(l_Msm_Switch_Out,         Msm_Switch_Out   ),
              Msm_Close_End_Sch         =    Nvl(l_Msm_Close_End_Sch,      Msm_Close_End_Sch   ),
              Msm_Amc_Code              =    Nvl(l_Msm_Amc_Code,           Msm_Amc_Code     ),
              Msm_Rvr_Fund_Rating       =    Nvl(l_Msm_Rvr_Fund_Rating,    Msm_Rvr_Fund_Rating  ),
              Msm_Elss_Flag              =    Nvl(l_Msm_Elss_Flag,          Msm_Elss_Flag    ),
              Msm_Nfo_Time              =    Nvl(l_Msm_Nfo_Time,           Msm_Nfo_Time     ),
              Msm_No_Skip_Sip            =    Nvl(l_Msm_No_Skip_Sip,        Msm_No_Skip_Sip  ),
              Msm_Elss_Lockin_Months    =    Nvl(l_Msm_Elss_Lockin_Months, Msm_Elss_Lockin_Months),
              Msm_Nfo_Allotment_Date    =    Nvl(l_Msm_Nfo_Allotment_Date, Msm_Nfo_Allotment_Date),
              Msm_Amc_Id                =    Nvl(l_internal_amc_id,        Msm_Amc_Id),
              Msm_Rta_Id                =    Nvl(l_Msm_Rta_Id,             Msm_Rta_Id),
              Msm_Nse_Pur_Cut_Off       =    Nvl(l_Msm_Nse_Pur_Cut_Off,    Msm_Nse_Pur_Cut_Off),
              Msm_Bse_Pur_Cut_Off       =    Nvl(l_Msm_Bse_Pur_Cut_Off,    Msm_Bse_Pur_Cut_Off),
              Msm_Nse_Redem_Cut_Off     =    Nvl(l_Msm_Nse_Redem_Cut_Off,  Msm_Nse_Redem_Cut_Off),
              Msm_Bse_Redem_Cut_Off     =    Nvl(l_Msm_Bse_Redem_Cut_Off,  Msm_Bse_Redem_Cut_Off),
              Msm_Bank_Ac_Name          =    Nvl(l_Msm_Bank_Ac_Name,       Msm_Bank_Ac_Name),
              Msm_Last_Updt_By          =    USER  ,
              Msm_Last_Updt_Dt          =    SYSDATE,
              Msm_Source                =    'D'
       WHERE  Msm_Scheme_Id             =    r_Mfd_scheme_master.Msm_Scheme_Id
       AND    Msm_Status               =    'A'
       AND    Msm_Record_Status        =    'A'
       AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND nvl(Msm_to_Date,l_Pam_Curr_Date) ;

    END p_Full_Upd_Scheme_Master ;

    PROCEDURE p_Null_Upd_Scheme_Master IS
    BEGIN
       UPDATE Mfd_scheme_master m
       SET    Msm_Scheme_Desc           =    Nvl(Msm_Scheme_Desc,        l_Msm_Scheme_Desc)  ,
              Msm_Sch_Asset_Cls         =    Nvl(Msm_Sch_Asset_Cls,      l_Msm_Sch_Asset_Cls),
              Msm_Sch_Cat               =    Nvl(Msm_Sch_Cat,            l_Msm_Sch_Cat),
              Msm_Sch_Sub_Cat           =    Nvl(Msm_Sch_Sub_Cat,        l_Msm_Sch_Sub_Cat),
              Msm_Scheme_Type           =    Nvl(Msm_Scheme_Type,        l_Msm_Scheme_Type),
              Msm_Data_Vendor_Id        =    Nvl(Msm_Data_Vendor_Id,     l_Msm_Data_Vendor_Id),
              Msm_Bse_Code              =    Nvl(Msm_Bse_Code,           l_Msm_Bse_Code),
              Msm_Nse_Code              =    Nvl(Msm_Nse_Code,           l_Msm_Nse_Code),
              Msm_Rta_Sch_Cd            =    Nvl(Msm_Rta_Sch_Cd,         l_Msm_Rta_Sch_Cd),
              Msm_Amfi_Code             =    Nvl(Msm_Amfi_Code,          l_Msm_Amfi_Code),
              Msm_Isin                  =    Nvl(Msm_Isin,               l_Msm_Isin),
              Msm_Unit_Face_Value       =    Nvl(Msm_Unit_Face_Value,    l_Msm_Unit_Face_Value),
              Msm_Coll_Cap              =    Nvl(Msm_Coll_Cap,           l_Msm_Coll_Cap),
              Msm_Last_Div_Date         =    Nvl(Msm_Last_Div_Date,      l_Msm_Last_Div_Date),
              Msm_Last_Div_Per_Unit     =    Nvl(Msm_Last_Div_Per_Unit,  l_Msm_Last_Div_Per_Unit),
              Msm_Nfo_From_Date         =    Nvl(Msm_Nfo_From_Date,      l_Msm_Nfo_From_Date),
              Msm_Nfo_To_Date           =    Nvl(Msm_Nfo_To_Date,        l_Msm_Nfo_To_Date),
              Msm_Pur_Allowed           =    Nvl(Msm_Pur_Allowed,        l_Msm_Pur_Allowed),
              Msm_Redem_Allowed         =    Nvl(Msm_Redem_Allowed,      l_Msm_Redem_Allowed),
              Msm_Allowed_For_Coll      =    Nvl(Msm_Allowed_For_Coll,   l_Msm_Allowed_For_Coll),
              Msm_Nri_Allowed           =    Nvl(Msm_Nri_Allowed,        l_Msm_Nri_Allowed),
              Msm_Nse_Allowed           =    Nvl(Msm_Nse_Allowed,        l_Msm_Nse_Allowed),
              Msm_Bse_Allowed           =    Nvl(Msm_Bse_Allowed,        l_Msm_Bse_Allowed),
              Msm_Physical_Yn           =    Nvl(Msm_Physical_Yn,        l_Msm_Physical_Yn),
              Msm_Demat_Yn              =    Nvl(Msm_Demat_Yn,           l_Msm_Demat_Yn),
              Msm_Nfo_Yn                =    Nvl(Msm_Nfo_Yn,             l_Msm_Nfo_Yn ),
              Msm_Sip_Yn                =    Nvl(Msm_Sip_Yn,             l_Msm_Sip_Yn ),
              Msm_Swp_Yn                =    Nvl(Msm_Swp_Yn,             l_Msm_Swp_Yn ),
              Msm_Stp_Yn                =    Nvl(Msm_Stp_Yn,             l_Msm_Stp_Yn ),
              Msm_div_option            =    Nvl(Msm_div_option,         l_divd_option  ),
              Msm_Entry_Load            =    Nvl(Msm_Entry_Load,         l_Msm_Entry_Load ),
              Msm_Exit_Load             =    Nvl(Msm_Exit_Load,          l_Msm_Exit_Load  ),
              Msm_Disp_Onl              =    Nvl(Msm_Disp_Onl,           l_Msm_Disp_Onl  ),
              Msm_Bank_Ac_No            =    Nvl(Msm_Bank_Ac_No,         l_Msm_Bank_Ac_No ),
              Msm_Bkm_Cd                =    Nvl(Msm_Bkm_Cd,             l_Msm_Bkm_Cd     ),
              Msm_Bbm_Cd                =    Nvl(Msm_Bbm_Cd,             l_Msm_Bbm_Cd ),
              Msm_Bank_Ac_Code          =    Nvl(Msm_Bank_Ac_Code,       l_Msm_Bank_Ac_Code),
              Msm_Min_Pur_Amt           =    Nvl(Msm_Min_Pur_Amt,        l_Msm_Min_Pur_Amt),
              Msm_Max_Pur_Amt           =    Nvl(Msm_Max_Pur_Amt,        l_Msm_Max_Pur_Amt),
              Msm_Add_Pur_Amt_Mul       =    Nvl(Msm_Add_Pur_Amt_Mul,    l_Msm_Add_Pur_Amt_Mul),
              Msm_Pur_Cut_Off           =    Nvl(Msm_Pur_Cut_Off,        l_Msm_Pur_Cut_Off),
              Msm_Min_Redem_Qty         =    Nvl(Msm_Min_Redem_Qty,      l_Msm_Min_Redem_Qty),
              Msm_Max_Redem_Qty         =    Nvl(Msm_Max_Redem_Qty,      l_Msm_Max_Redem_Qty    ),
              Msm_Redem_Qty_Mul         =    Nvl(Msm_Redem_Qty_Mul,      l_Msm_Redem_Qty_Mul ),
              Msm_Redem_Cut_Off         =    Nvl(Msm_Redem_Cut_Off,      l_Msm_Redem_Cut_Off ),
              Msm_Annual_Com_Per        =    Nvl(Msm_Annual_Com_Per,     l_Msm_Annual_Com_Per ),
              Msm_Annual_Com_Per_Unit   =    Nvl(Msm_Annual_Com_Per_Unit,l_Msm_Annual_Com_Per_Unit ),
              Msm_Annual_Special_Com    =    Nvl(Msm_Annual_Special_Com, l_Msm_Annual_Special_Com),
              Msm_Trail_Com_Per         =    Nvl(Msm_Trail_Com_Per,      l_Msm_Trail_Com_Per),
              Msm_Trail_Com_Per_Unit    =    Nvl(Msm_Trail_Com_Per_Unit, l_Msm_Trail_Com_Per_Unit ),
              Msm_Trail_Special_Com     =    Nvl(Msm_Trail_Special_Com,  l_Msm_Trail_Special_Com ),
              Msm_Upfornt_Com_Per       =    Nvl(Msm_Upfornt_Com_Per,    l_Msm_Upfornt_Com_Per ),
              Msm_Upfornt_Com_Per_Unit  =    Nvl(Msm_Upfornt_Com_Per_Unit,l_Msm_Upfornt_Com_Per_Unit),
              Msm_Upfornt_Special_Com   =    Nvl(Msm_Upfornt_Special_Com,l_Msm_Upfornt_Special_Com ),
              Msm_Contact_Person        =    Nvl(Msm_Contact_Person,     l_Msm_Contact_Person ),
              Msm_Contact_Email         =    Nvl(Msm_Contact_Email,      l_Msm_Contact_Email  ),
              Msm_Contact_Phone         =    Nvl(Msm_Contact_Phone,      l_Msm_Contact_Phone  ),
              Msm_Contact_Remark        =    Nvl(Msm_Contact_Remark,     l_Msm_Contact_Remark  ),
              Msm_Amc_Name              =    Nvl(Msm_Amc_Name,           l_Msm_Amc_Name      ),
              Msm_Remark                =    Nvl(Msm_Remark,             l_Msm_Remark),
              Msm_Fmp_Flag              =    Nvl(Msm_Fmp_Flag,           l_Msm_Fmp_Flag),
              Msm_Fmp_End_Date          =    Nvl(Msm_Fmp_End_Date,       l_Msm_Fmp_End_Date),
              Msm_Rta_Amc_Cd            =    Nvl(Msm_Rta_Amc_Cd,         l_Msm_Rta_Amc_Cd),
              Msm_Amc_Sch_Cd            =    Nvl(Msm_Amc_Sch_Cd,         l_Msm_Amc_Sch_Cd),
              Msm_Bse_Unique_No         =    Nvl(Msm_Bse_Unique_No,      l_Msm_Bse_Unique_No),
              Msm_Nse_Unique_No         =    Nvl(Msm_Nse_Unique_No,      l_Msm_Nse_Unique_No ),
              Msm_Pur_Amt_Mul           =    Nvl(Msm_Pur_Amt_Mul,        l_Msm_Pur_Amt_Mul ),
              Msm_Add_Pur_Amt           =    Nvl(Msm_Add_Pur_Amt,        l_Msm_Add_Pur_Amt   ),
              Msm_Min_Redem_Amt         =    Nvl(Msm_Min_Redem_Amt,      l_Msm_Min_Redem_Amt  ),
              Msm_Max_Redem_Amt         =    Nvl(Msm_Max_Redem_Amt ,     l_Msm_Max_Redem_Amt  ),
              Msm_Switch_In             =    Nvl(Msm_Switch_In  ,        l_Msm_Switch_In   ),
              Msm_Settlement_Type       =    Nvl(Msm_Settlement_Type,    l_Msm_Settlement_Type ),
              Msm_Entry_Text            =    Nvl(Msm_Entry_Text,         l_Msm_Entry_Text  ),
              Msm_Exit_Text             =    Nvl(Msm_Exit_Text,          l_Msm_Exit_Text  ),
              Msm_Switch_Out            =    Nvl(Msm_Switch_Out,         l_Msm_Switch_Out   ),
              Msm_Close_End_Sch         =    Nvl(Msm_Close_End_Sch,      l_Msm_Close_End_Sch   ),
              Msm_Amc_Code              =    Nvl(Msm_Amc_Code,           l_Msm_Amc_Code     ),
              Msm_Rvr_Fund_Rating       =    Nvl(Msm_Rvr_Fund_Rating,    l_Msm_Rvr_Fund_Rating  ),
              Msm_Elss_Flag              =    Nvl(Msm_Elss_Flag,          l_Msm_Elss_Flag    ),
              Msm_Nfo_Time              =    Nvl(Msm_Nfo_Time,           l_Msm_Nfo_Time     ),
              Msm_No_Skip_Sip            =    Nvl(Msm_No_Skip_Sip,        l_Msm_No_Skip_Sip  ),
              Msm_Elss_Lockin_Months    =    Nvl(Msm_Elss_Lockin_Months, l_Msm_Elss_Lockin_Months),
              Msm_Nfo_Allotment_Date    =    Nvl(Msm_Nfo_Allotment_Date, l_Msm_Nfo_Allotment_Date),
              Msm_Amc_Id                =    Nvl(Msm_Amc_Id,             l_internal_amc_id),
              Msm_Rta_Id                =    Nvl(Msm_Rta_Id,             l_Msm_Rta_Id),
              Msm_Nse_Pur_Cut_Off       =    Nvl(Msm_Nse_Pur_Cut_Off,    l_Msm_Nse_Pur_Cut_Off),
              Msm_Bse_Pur_Cut_Off       =    Nvl(Msm_Bse_Pur_Cut_Off,    l_Msm_Bse_Pur_Cut_Off),
              Msm_Nse_Redem_Cut_Off     =    Nvl(Msm_Nse_Redem_Cut_Off,  l_Msm_Nse_Redem_Cut_Off),
              Msm_Bse_Redem_Cut_Off     =    Nvl(Msm_Bse_Redem_Cut_Off,  l_Msm_Bse_Redem_Cut_Off),
              Msm_Bank_Ac_Name          =    Nvl(Msm_Bank_Ac_Name,       l_Msm_Bank_Ac_Name),
              Msm_Last_Updt_By          =    USER  ,
              Msm_Last_Updt_Dt          =    SYSDATE,
              Msm_Source                =    'D'
       WHERE  Msm_Scheme_Id             =    r_Mfd_scheme_master.Msm_Scheme_Id
       AND    Msm_Status               =    'A'
       AND    Msm_Record_Status        =    'A'
       AND    l_Pam_Curr_Date BETWEEN Msm_From_Date AND nvl(Msm_to_Date,l_Pam_Curr_Date) ;

    END p_Null_Upd_Scheme_Master ;

    FUNCTION Comp_Col(P_Desc IN Varchar2, p_Tab IN VARCHAR2, p_Var IN VARCHAR2, p_Ret_Str IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      IF p_Tab <> p_Var THEN
        IF p_Ret_Str IS NULL THEN
          RETURN P_Desc;
        ELSE
          RETURN p_Ret_Str||','||P_Desc ;
        END IF ;
      END IF ;
      RETURN p_Ret_Str;
    END Comp_Col ;

    PROCEDURE p_Write_Change_Skip_In_Log IS
      l_Str VARCHAR2(10000) := NULL;
    BEGIN
      l_Str := Comp_Col('Scheme Desc', r_Mfd_scheme_master.Msm_Scheme_Desc,        l_Msm_Scheme_Desc,l_Str);
      l_Str := Comp_Col('Asset Class', r_Mfd_scheme_master.Msm_Sch_Asset_Cls,      l_Msm_Sch_Asset_Cls,l_Str);
      l_Str := Comp_Col('Scheme Category', r_Mfd_scheme_master.Msm_Sch_Cat,            l_Msm_Sch_Cat,l_Str);
      l_Str := Comp_Col('Scheme Sub Category', r_Mfd_scheme_master.Msm_Sch_Sub_Cat,        l_Msm_Sch_Sub_Cat,l_Str);
      l_Str := Comp_Col('Vendor Id', r_Mfd_scheme_master.Msm_Data_Vendor_Id,     l_Msm_Data_Vendor_Id,l_Str);
      l_Str := Comp_Col('BSE Code', r_Mfd_scheme_master.Msm_Bse_Code,           l_Msm_Bse_Code,l_Str);
      l_Str := Comp_Col('NSE Code', r_Mfd_scheme_master.Msm_Nse_Code,           l_Msm_Nse_Code,l_Str);
      l_Str := Comp_Col('RTA'' Scheme Code', r_Mfd_scheme_master.Msm_Rta_Sch_Cd,         l_Msm_Rta_Sch_Cd,l_Str);
      l_Str := Comp_Col('AMFI Code', r_Mfd_scheme_master.Msm_Amfi_Code,          l_Msm_Amfi_Code,l_Str);
      l_Str := Comp_Col('ISIN', r_Mfd_scheme_master.Msm_Isin,               l_Msm_Isin,l_Str);
      l_Str := Comp_Col('Face Value', r_Mfd_scheme_master.Msm_Unit_Face_Value,    l_Msm_Unit_Face_Value,l_Str);
      l_Str := Comp_Col('Collateral Cap', r_Mfd_scheme_master.Msm_Coll_Cap,           l_Msm_Coll_Cap,l_Str);
      l_Str := Comp_Col('Last Div Date', r_Mfd_scheme_master.Msm_Last_Div_Date,      l_Msm_Last_Div_Date,l_Str);
      l_Str := Comp_Col('Last Div Per Unit', r_Mfd_scheme_master.Msm_Last_Div_Per_Unit,  l_Msm_Last_Div_Per_Unit,l_Str);
      l_Str := Comp_Col('NFO From Date', r_Mfd_scheme_master.Msm_Nfo_From_Date,      l_Msm_Nfo_From_Date,l_Str);
      l_Str := Comp_Col('NFO To Date', r_Mfd_scheme_master.Msm_Nfo_To_Date,        l_Msm_Nfo_To_Date,l_Str);
      l_Str := Comp_Col('Purchase Allowed', r_Mfd_scheme_master.Msm_Pur_Allowed,        l_Msm_Pur_Allowed,l_Str);
      l_Str := Comp_Col('Redemption Allow', r_Mfd_scheme_master.Msm_Redem_Allowed,      l_Msm_Redem_Allowed,l_Str);
      l_Str := Comp_Col('Allowed For Collateral', r_Mfd_scheme_master.Msm_Allowed_For_Coll,   l_Msm_Allowed_For_Coll,l_Str);
      l_Str := Comp_Col('NRI Allow', r_Mfd_scheme_master.Msm_Nri_Allowed,        l_Msm_Nri_Allowed,l_Str);
      l_Str := Comp_Col('Allowed in NSE', r_Mfd_scheme_master.Msm_Nse_Allowed,        l_Msm_Nse_Allowed,l_Str);
      l_Str := Comp_Col('Allowed In BSE', r_Mfd_scheme_master.Msm_Bse_Allowed,        l_Msm_Bse_Allowed,l_Str);
      l_Str := Comp_Col('Physical Yn', r_Mfd_scheme_master.Msm_Physical_Yn,        l_Msm_Physical_Yn,l_Str);
      l_Str := Comp_Col('Demat Yn', r_Mfd_scheme_master.Msm_Demat_Yn,           l_Msm_Demat_Yn,l_Str);
      l_Str := Comp_Col('NFO Yn', r_Mfd_scheme_master.Msm_Nfo_Yn,             l_Msm_Nfo_Yn ,l_Str);
      l_Str := Comp_Col('SIP Yn', r_Mfd_scheme_master.Msm_Sip_Yn,             l_Msm_Sip_Yn ,l_Str);
      l_Str := Comp_Col('SWP Yn', r_Mfd_scheme_master.Msm_Swp_Yn,             l_Msm_Swp_Yn ,l_Str);
      l_Str := Comp_Col('STP Yn', r_Mfd_scheme_master.Msm_Stp_Yn,             l_Msm_Stp_Yn ,l_Str);
      l_Str := Comp_Col('Div Option', r_Mfd_scheme_master.Msm_div_option,            l_divd_option ,l_Str);
      l_Str := Comp_Col('Entry Load', r_Mfd_scheme_master.Msm_Entry_Load,         l_Msm_Entry_Load ,l_Str);
      l_Str := Comp_Col('Exit Load', r_Mfd_scheme_master.Msm_Exit_Load,          l_Msm_Exit_Load  ,l_Str);
      l_Str := Comp_Col('Display Online', r_Mfd_scheme_master.Msm_Disp_Onl,           l_Msm_Disp_Onl  ,l_Str);
      l_Str := Comp_Col('AMC Bank Ac No', r_Mfd_scheme_master.Msm_Bank_Ac_No,         l_Msm_Bank_Ac_No ,l_Str);
      l_Str := Comp_Col('AMC Bank ', r_Mfd_scheme_master.Msm_Bkm_Cd,             l_Msm_Bkm_Cd     ,l_Str);
      l_Str := Comp_Col('AMC Bank Branch Code', r_Mfd_scheme_master.Msm_Bbm_Cd,             l_Msm_Bbm_Cd ,l_Str);
      l_Str := Comp_Col('AMC Bank Ac Type', r_Mfd_scheme_master.Msm_Bank_Ac_Code,       l_Msm_Bank_Ac_Code,l_Str);
      l_Str := Comp_Col('Min Pur Amt', r_Mfd_scheme_master.Msm_Min_Pur_Amt,        l_Msm_Min_Pur_Amt,l_Str);
      l_Str := Comp_Col('Max Pur Amt', r_Mfd_scheme_master.Msm_Max_Pur_Amt,        l_Msm_Max_Pur_Amt,l_Str);
      l_Str := Comp_Col('Addn Pur Amt Multiplier', r_Mfd_scheme_master.Msm_Add_Pur_Amt_Mul,    l_Msm_Add_Pur_Amt_Mul,l_Str);
      l_Str := Comp_Col('Pur Cut-Off Time', r_Mfd_scheme_master.Msm_Pur_Cut_Off,        l_Msm_Pur_Cut_Off,l_Str);
      l_Str := Comp_Col('Min Redm Qty', r_Mfd_scheme_master.Msm_Min_Redem_Qty,      l_Msm_Min_Redem_Qty,l_Str);
      l_Str := Comp_Col('Max Redm Qty', r_Mfd_scheme_master.Msm_Max_Redem_Qty,      l_Msm_Max_Redem_Qty ,l_Str);
      l_Str := Comp_Col('Redm Qty Multiplier', r_Mfd_scheme_master.Msm_Redem_Qty_Mul,      l_Msm_Redem_Qty_Mul ,l_Str);
      l_Str := Comp_Col('Redm Cut-Off Time', r_Mfd_scheme_master.Msm_Redem_Cut_Off,      l_Msm_Redem_Cut_Off ,l_Str);
      l_Str := Comp_Col('Annual Comm %', r_Mfd_scheme_master.Msm_Annual_Com_Per,     l_Msm_Annual_Com_Per ,l_Str);
      l_Str := Comp_Col('Annual Comm/Unit', r_Mfd_scheme_master.Msm_Annual_Com_Per_Unit,l_Msm_Annual_Com_Per_Unit ,l_Str);
      l_Str := Comp_Col('Annual Spl Comm', r_Mfd_scheme_master.Msm_Annual_Special_Com, l_Msm_Annual_Special_Com,l_Str);
      l_Str := Comp_Col('Trail Comm %', r_Mfd_scheme_master.Msm_Trail_Com_Per,      l_Msm_Trail_Com_Per,l_Str);
      l_Str := Comp_Col('Trail Comm/Unit', r_Mfd_scheme_master.Msm_Trail_Com_Per_Unit, l_Msm_Trail_Com_Per_Unit ,l_Str);
      l_Str := Comp_Col('Trail Spl Comm', r_Mfd_scheme_master.Msm_Trail_Special_Com,  l_Msm_Trail_Special_Com ,l_Str);
      l_Str := Comp_Col('Upfront Comm %', r_Mfd_scheme_master.Msm_Upfornt_Com_Per,    l_Msm_Upfornt_Com_Per ,l_Str);
      l_Str := Comp_Col('Upfront Comm/Unit', r_Mfd_scheme_master.Msm_Upfornt_Com_Per_Unit,l_Msm_Upfornt_Com_Per_Unit,l_Str);
      l_Str := Comp_Col('Upfront Spl Comm', r_Mfd_scheme_master.Msm_Upfornt_Special_Com,l_Msm_Upfornt_Special_Com ,l_Str);
      l_Str := Comp_Col('Contact Person', r_Mfd_scheme_master.Msm_Contact_Person,     l_Msm_Contact_Person ,l_Str);
      l_Str := Comp_Col('Contact Email', r_Mfd_scheme_master.Msm_Contact_Email,      l_Msm_Contact_Email  ,l_Str);
      l_Str := Comp_Col('Contact Phone', r_Mfd_scheme_master.Msm_Contact_Phone,      l_Msm_Contact_Phone  ,l_Str);
      l_Str := Comp_Col('Contact Remark', r_Mfd_scheme_master.Msm_Contact_Remark,     l_Msm_Contact_Remark  ,l_Str);
      l_Str := Comp_Col('Amc Name', r_Mfd_scheme_master.Msm_Amc_Name,           l_Msm_Amc_Name     ,l_Str);
      l_Str := Comp_Col('FMP YN', r_Mfd_scheme_master.Msm_Fmp_Flag,           l_Msm_Fmp_Flag,l_Str);
      l_Str := Comp_Col('FMP End Date', r_Mfd_scheme_master.Msm_Fmp_End_Date,       l_Msm_Fmp_End_Date,l_Str);
      l_Str := Comp_Col('RTA''s AMC Code', r_Mfd_scheme_master.Msm_Rta_Amc_Cd,         l_Msm_Rta_Amc_Cd,l_Str);
      l_Str := Comp_Col('AMC''s Scheme Code', r_Mfd_scheme_master.Msm_Amc_Sch_Cd,         l_Msm_Amc_Sch_Cd,l_Str);
      l_Str := Comp_Col('BSE Unique No', r_Mfd_scheme_master.Msm_Bse_Unique_No,      l_Msm_Bse_Unique_No,l_Str);
      l_Str := Comp_Col('NSE Unique No', r_Mfd_scheme_master.Msm_Nse_Unique_No,      l_Msm_Nse_Unique_No ,l_Str);
      l_Str := Comp_Col('Pur Amt Multiplier', r_Mfd_scheme_master.Msm_Pur_Amt_Mul,        l_Msm_Pur_Amt_Mul ,l_Str);
      l_Str := Comp_Col('Addn Pur Amt', r_Mfd_scheme_master.Msm_Add_Pur_Amt,        l_Msm_Add_Pur_Amt   ,l_Str);
      l_Str := Comp_Col('Min Redm Amt', r_Mfd_scheme_master.Msm_Min_Redem_Amt,      l_Msm_Min_Redem_Amt  ,l_Str);
      l_Str := Comp_Col('MAx Redm Amt', r_Mfd_scheme_master.Msm_Max_Redem_Amt ,     l_Msm_Max_Redem_Amt  ,l_Str);
      l_Str := Comp_Col('Switch In', r_Mfd_scheme_master.Msm_Switch_In  ,        l_Msm_Switch_In   ,l_Str);
      l_Str := Comp_Col('Setl Type', r_Mfd_scheme_master.Msm_Settlement_Type,    l_Msm_Settlement_Type ,l_Str);
      l_Str := Comp_Col('Switch Out', r_Mfd_scheme_master.Msm_Switch_Out,         l_Msm_Switch_Out  ,l_Str);
      l_Str := Comp_Col('Close End Sch', r_Mfd_scheme_master.Msm_Close_End_Sch,      l_Msm_Close_End_Sch ,l_Str);
      l_Str := Comp_Col('Portal AMC Code', r_Mfd_scheme_master.Msm_Amc_Code,           l_Msm_Amc_Code    ,l_Str);
      l_Str := Comp_Col('Rvr Fund Rating', r_Mfd_scheme_master.Msm_Rvr_Fund_Rating,    l_Msm_Rvr_Fund_Rating ,l_Str);
      l_Str := Comp_Col('ELSS YN', r_Mfd_scheme_master.Msm_Elss_Flag,          l_Msm_Elss_Flag   ,l_Str);
      l_Str := Comp_Col('NFO Allowed Time', r_Mfd_scheme_master.Msm_Nfo_Time,           l_Msm_Nfo_Time    ,l_Str);
      l_Str := Comp_Col('SIP Skip Allowed', r_Mfd_scheme_master.Msm_No_Skip_Sip,        l_Msm_No_Skip_Sip  ,l_Str);
      l_Str := Comp_Col('ELSS Lockin Mths', r_Mfd_scheme_master.Msm_Elss_Lockin_Months, l_Msm_Elss_Lockin_Months,l_Str);
      l_Str := Comp_Col('NFO Allot Date', r_Mfd_scheme_master.Msm_Nfo_Allotment_Date, l_Msm_Nfo_Allotment_Date,l_Str);
      l_Str := Comp_Col('Internal AMC Id', r_Mfd_scheme_master.Msm_Amc_Id,             l_internal_amc_id,l_Str);
      l_Str := Comp_Col('Internal RTA Id', r_Mfd_scheme_master.Msm_Rta_Id,             l_Msm_Rta_Id,l_Str);
      l_Str := Comp_Col('Nse Pur Cut-Off Time', r_Mfd_scheme_master.Msm_Nse_Pur_Cut_Off, l_Msm_Nse_Pur_Cut_Off,l_Str);
      l_Str := Comp_Col('Bse Pur Cut-Off Time', r_Mfd_scheme_master.Msm_Bse_Pur_Cut_Off, l_Msm_Bse_Pur_Cut_Off,l_Str);
      l_Str := Comp_Col('Nse Redem Cut-Off Time', r_Mfd_scheme_master.Msm_Nse_Redem_Cut_Off, l_Msm_Nse_Redem_Cut_Off,l_Str);
      l_Str := Comp_Col('Bse Redem Cut-Off Time', r_Mfd_scheme_master.Msm_Bse_Redem_Cut_Off, l_Msm_Bse_Redem_Cut_Off,l_Str);

       IF l_Str IS NOT NULL THEN
         Utl_File.Put_Line(l_Log_File_Handle,'Skipped Record with difference<'||l_Str ||'>');
         l_Count_Change_Skip  :=  l_Count_Change_Skip + 1;
       END IF ;
    END p_Write_Change_Skip_In_Log;

    PROCEDURE p_Assign_Into_Variables IS
    BEGIN
       l_Msm_Scheme_Id                   := Upper(TRIM(l_Bse_Tab(1)));
       l_Msm_Scheme_Desc                 := Upper(TRIM(l_Bse_Tab(2)));
       l_Msm_Amc_Id                      := Upper(TRIM(l_Bse_Tab(3)));
       l_Msm_Rta_Id                      := Upper(TRIM(l_Bse_Tab(4)));
       l_Msm_From_date                   := TRIM(l_Bse_Tab(5));
       l_Msm_To_Date                     := TRIM(l_Bse_Tab(6));
       l_Msm_Scheme_Type                 := Upper(TRIM(l_Bse_Tab(7)));
       l_Msm_Bse_Code                    := Upper(TRIM(l_Bse_Tab(8)));
       l_Msm_Nse_code                    := upper(TRIM(l_Bse_Tab(9)));
       l_Msm_Isin                        := upper(TRIM(l_Bse_Tab(10)));
       l_Msm_Rta_Sch_Cd                  := upper(TRIM(l_Bse_Tab(11)));
       l_Msm_Amfi_Code                   := TRIM(l_Bse_Tab(12));
       l_Msm_Sch_Asset_Cls               := upper(TRIM(l_Bse_Tab(13)));
       l_Msm_Sch_Cat                     := upper(TRIM(l_Bse_Tab(14)));
       l_Msm_Sch_Sub_Cat                 := upper(TRIM(l_Bse_Tab(15)));
       l_Msm_Unit_Face_Value             := TRIM(l_Bse_Tab(16));
       l_Msm_Coll_Cap                    := TRIM(l_Bse_Tab(17));
       l_Msm_Last_Div_Date               := TRIM(l_Bse_Tab(18));
       l_Msm_Last_Div_Per_Unit           := l_Bse_Tab(19);
       l_Msm_Nfo_From_Date               := TRIM(l_Bse_Tab(20));
       l_Msm_Nfo_To_Date                 := TRIM(l_Bse_Tab(21));
       l_Msm_Pur_Allowed                 := upper(TRIM(l_Bse_Tab(22)));
       l_Msm_Redem_Allowed               := Upper(TRIM(l_Bse_Tab(23)));
       l_Msm_Allowed_For_Coll            := upper(TRIM(l_Bse_Tab(24)));
       l_Msm_Nri_Allowed                 := Upper(TRIM(l_Bse_Tab(25)));
       l_Msm_Nse_Allowed                 := Upper(TRIM(l_Bse_Tab(26)));
       l_Msm_Bse_Allowed                 := upper(TRIM(l_Bse_Tab(27)));
       l_Msm_Physical_Yn                 := upper(TRIM(l_Bse_Tab(28)));
       l_Msm_Demat_Yn                    := upper(TRIM(l_Bse_Tab(29)));
       l_Msm_Nfo_Yn                      := Upper(TRIM(l_Bse_Tab(30)));
       l_Msm_Sip_Yn                      := Upper(TRIM(l_Bse_Tab(31)));
       l_Msm_Swp_Yn                      := upper(TRIM(l_Bse_Tab(32)));
       l_Msm_Stp_Yn                      := upper(TRIM(l_Bse_Tab(33)));
       l_Msm_Div_Option                  := upper(TRIM(l_Bse_Tab(34)));
       l_Msm_Entry_Load                  := TRIM(l_Bse_Tab(35));
       l_Msm_Exit_Load                   := TRIM(l_Bse_Tab(36));
       l_Msm_Bse_Unique_No               := TRIM(l_Bse_Tab(37));
       l_Msm_Disp_Onl                    := Upper(TRIM(l_Bse_Tab(38)));
       l_Msm_Bank_Ac_No                  := TRIM(l_Bse_Tab(39));
       l_Msm_Bkm_Cd                      := TRIM(l_Bse_Tab(40));
       l_Msm_Bbm_Cd                      := TRIM(l_Bse_Tab(41));
       l_Msm_Bank_Ac_Code                := TRIM(l_Bse_Tab(42));
       l_Msm_Min_Pur_Amt                 := TRIM(l_Bse_Tab(43));
       l_Msm_Max_Pur_Amt                 := TRIM(l_Bse_Tab(44));
       l_Msm_Add_Pur_Amt_Mul             := TRIM(l_Bse_Tab(45));
       l_Msm_Pur_Cut_Off                 := TRIM(l_Bse_Tab(46));
       l_Msm_Min_Redem_Qty               := TRIM(l_Bse_Tab(47));
       l_Msm_Max_Redem_Qty               := TRIM(l_Bse_Tab(48));
       l_Msm_Redem_Qty_Mul               := TRIM(l_Bse_Tab(49));
       l_Msm_Redem_Cut_Off               := TRIM(l_Bse_Tab(50));
       l_Msm_Annual_Com_Per              := TRIM(l_Bse_Tab(51));
       l_Msm_Annual_Com_Per_Unit         := TRIM(l_Bse_Tab(52));
       l_Msm_Annual_Special_Com          := TRIM(l_Bse_Tab(53));
       l_Msm_Trail_Com_Per               := TRIM(l_Bse_Tab(54));
       l_Msm_Trail_Com_Per_Unit          := TRIM(l_Bse_Tab(55));
       l_Msm_Trail_Special_Com           := TRIM(l_Bse_Tab(56));
       l_Msm_Upfornt_Com_Per             := TRIM(l_Bse_Tab(57));
       l_Msm_Upfornt_Com_Per_Unit        := TRIM(l_Bse_Tab(58));
       l_Msm_Upfornt_Special_Com         := TRIM(l_Bse_Tab(59));
       l_Msm_Contact_Person              := Upper(TRIM(l_Bse_Tab(60)));
       l_Msm_Contact_Email               := TRIM(l_Bse_Tab(61));
       l_Msm_Contact_Phone               := TRIM(l_Bse_Tab(62));
       l_Msm_Contact_Remark              := TRIM(l_Bse_Tab(63));
       -- 64-67 .. Create & last update
       -- 68 Source of Data
       l_Msm_Status                      := Upper(TRIM(l_Bse_Tab(69)));
       l_Msm_Amc_Name                    := TRIM(l_Bse_Tab(70));
       l_Msm_Remark                      := TRIM(l_Bse_Tab(71));
       l_Msm_Fmp_Flag                    := Upper(TRIM(l_Bse_Tab(72)));
       l_Msm_Fmp_End_Date                := TRIM(l_Bse_Tab(73));
       l_Msm_Rta_Amc_Cd                  := UPPER(TRIM(l_Bse_Tab(74)));
       l_Msm_Data_Vendor_Id              := TRIM(l_Bse_Tab(75));
       l_Msm_Nse_Unique_No               := TRIM(l_Bse_Tab(76));
       l_Msm_Pur_Amt_Mul                 := TRIM(l_Bse_Tab(77));
       l_Msm_Add_Pur_Amt                 := TRIM(l_Bse_Tab(78));
       l_Msm_Min_Redem_Amt               := TRIM(l_Bse_Tab(79));
       l_Msm_Max_Redem_Amt               := TRIM(l_Bse_Tab(80));
       l_Msm_Switch_In                   := Upper(TRIM(l_Bse_Tab(81)));
       l_Msm_Settlement_Type             := TRIM(l_Bse_Tab(82));
       l_Msm_Entry_Text                  := TRIM(l_Bse_Tab(83));
       l_Msm_Exit_Text                   := TRIM(l_Bse_Tab(84));
       l_Msm_Switch_Out                  := Upper(TRIM(l_Bse_Tab(85)));
       l_Msm_Close_End_Sch               := TRIM(l_Bse_Tab(86));
       l_Msm_Amc_Code                    := UPPER(TRIM(l_Bse_Tab(87)));
       l_Msm_Rvr_Fund_Rating             := TRIM(l_Bse_Tab(88));
       l_Msm_Elss_Flag                   := Upper(TRIM(l_Bse_Tab(89)));
       l_Msm_Nfo_Time                    := To_Char(to_date(TRIM(l_Bse_Tab(90)),'HH24:MI:SS'),'HH24:MI');
       l_Msm_No_Skip_Sip                 := TRIM(l_Bse_Tab(91));
       l_Msm_Elss_Lockin_Months          := TRIM(l_Bse_Tab(92));
       l_Msm_Nfo_Allotment_Date          := TRIM(l_Bse_Tab(93));
       l_Msm_Nse_Pur_Cut_Off             := To_Char(To_Date(TRIM(l_Bse_Tab(94)),'HH24:MI:SS'),'HH24:MI');
       l_Msm_Bse_Pur_Cut_Off             := To_Char(To_Date(TRIM(l_Bse_Tab(95)),'HH24:MI:SS'),'HH24:MI');
       l_Msm_Nse_Redem_Cut_Off           := To_Char(To_Date(TRIM(l_Bse_Tab(96)),'HH24:MI:SS'),'HH24:MI');
       l_Msm_Bse_Redem_Cut_Off           := To_Char(To_Date(TRIM(l_Bse_Tab(97)),'HH24:MI:SS'),'HH24:MI');
       l_Msm_Bank_Ac_Name                := TRIM(l_Bse_Tab(98));

       IF l_Msm_Div_Option = 'Y' THEN
          l_Divd_Option := 'R'; -- Reinvest
          l_Divind_Description := 'DR';
       ELSIF l_Msm_Div_Option = 'N' THEN
          l_Divd_Option := 'P'; -- Dividend Payout
          l_Divind_Description := 'DP';
       ELSIF l_Msm_Div_Option = 'Z' THEN
          l_Divd_Option := 'G'; -- Growth
          l_Divind_Description := 'GR';
       END IF;

    END p_Assign_Into_Variables;

    PROCEDURE p_Validate_Data IS
    BEGIN
       l_Mand_Fields_Msg := '  ';
       l_Skip_Yn         := 'N';
       --Validation
       IF l_Msm_Scheme_Desc IS NULL THEN
          l_Mand_Fields_Msg :='Msm_Scheme_Desc' ;
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Amc_Id IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Amc_Id' ;
          l_Skip_Yn                  := 'Y';
       END IF;
       IF length(l_Msm_Rta_Sch_Cd)> 5 THEN
          l_Mand_Fields_Msg := Nvl(l_Mand_Fields_Msg, ' ')||'--'||'RTA Scheme Code Length is More Than 5 Character';
          l_Skip_Yn         := 'Y';
       END IF;
       IF l_Msm_Rta_Id IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Rta_Id' ;
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Scheme_Type IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Rta_Id' ;
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Bse_Allowed ='Y' THEN
          IF l_Msm_Bse_Code IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Bse_Code';
             l_Skip_Yn                  := 'Y';
          END IF;
          IF l_Msm_Bse_Unique_No IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Bse_Unique_No' ;
             l_Skip_Yn                  := 'Y';
          END IF;
       END IF;
       IF l_Msm_Nse_Allowed ='Y' THEN
          IF l_Msm_Nse_Code IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Nse_Code';
             l_Skip_Yn                  := 'Y';
          END IF;
          IF l_Msm_Nse_Unique_No IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Nse_Unique_No' ;
             l_Skip_Yn                  := 'Y';
          END IF;
       END IF;
       IF l_Msm_Nse_Allowed ='Y' OR l_Msm_Bse_Allowed ='Y' THEN
          IF l_Msm_Isin IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Isin';
             l_Skip_Yn                  := 'Y';
          END IF;
       END IF;
       IF l_Msm_Status NOT IN ('I','A')THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Status';
          l_Skip_Yn                  := 'Y';
       END IF;
      /* IF l_Msm_Sch_Asset_Cls IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Sch_Asset_Cls';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Sch_Cat IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Sch_Cat';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Sch_sub_Cat IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Sch_Cat';
          l_Skip_Yn                  := 'Y';
       END IF;*/
       IF l_Msm_Pur_Allowed NOT IN ('Y','N') THEN
          l_Msm_Pur_Allowed := 'N';
       END IF;
       IF l_Msm_Redem_Allowed NOT IN ('Y','N') THEN
          l_Msm_Redem_Allowed := 'N';
       END IF;
       IF l_Msm_Nri_Allowed NOT IN ('Y','N') THEN
          l_Msm_Nri_Allowed :='N';
       END IF;
       IF l_Msm_Nse_Allowed NOT IN ('Y','N') THEN
          l_Msm_Nse_Allowed := 'N';
       END IF;
       IF l_Msm_Bse_Allowed NOT IN ('Y','N') THEN
          l_Msm_Bse_Allowed := 'N';
       END IF;
       IF l_Msm_Physical_Yn NOT IN ('Y','N') THEN
          l_Msm_Physical_Yn := 'N';
       END IF;
       IF l_Msm_Isin IS NOT NULL THEN
          l_Msm_Demat_Yn :='Y';
       ELSE
          l_Msm_Demat_Yn :='N';
       END IF;
       IF (l_Msm_Div_Option NOT IN ('Y','N','Z')) OR(l_Msm_Div_Option IS NULL)  THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Divind option not valid';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Pur_Allowed = 'Y' THEN
         IF l_Msm_Min_Pur_Amt IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Min_Pur_Amt';
            l_Skip_Yn                  := 'Y';
         END IF;
         IF l_Msm_Max_Pur_Amt IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Max_Pur_Amt';
            l_Skip_Yn                  := 'Y';
         END IF;
         IF l_Msm_Add_Pur_Amt_Mul IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Add_Pur_Amt_Mul';
            l_Skip_Yn                  := 'Y';
         END IF;
         IF l_Msm_Pur_Cut_Off IS NULL    THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Pur_Cut_Off';
            l_Skip_Yn                  := 'Y';
         END IF;
       END IF;
       IF l_msm_redem_Allowed = 'Y' THEN
         IF l_Msm_Min_Redem_Qty IS NULL  THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Min_Redem_Qty';
            l_Skip_Yn                  := 'Y';
         END IF;

         IF l_Msm_Max_Redem_Qty IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Max_Redem_Qty';
            l_Skip_Yn                  := 'Y';
         END IF;
         IF l_Msm_Redem_Qty_Mul IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Redem_Qty_Mul';
            l_Skip_Yn                  := 'Y';
         END IF;
         IF l_Msm_Redem_Cut_Off IS NULL THEN
            l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Redem_Cut_Off';
            l_Skip_Yn                  := 'Y';
         END IF;
       END IF;
       IF l_Msm_Data_Vendor_Id IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Data_Vendor_Id';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Amc_Code IS NULL THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Amc_Code';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF  (l_Msm_Nfo_Yn NOT IN ('Y','N')) OR (l_Msm_Nfo_Yn IS NULL) THEN
          l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'NFO Flag is not valid';
          l_Skip_Yn                  := 'Y';
       END IF;
       IF l_Msm_Nfo_Yn ='Y' THEN
          IF l_Msm_Nfo_From_Date IS NULL THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Nfo_From_Date';
             l_Skip_Yn                  := 'Y';
          ELSIF l_Msm_Nfo_To_Date IS NULL THEN
                l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Nfo_To_Date';
                l_Skip_Yn                  := 'Y';
          ELSIF l_Msm_Nfo_Allotment_Date IS NULL THEN
                l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Msm_Nfo_Allotment_Date';
                l_Skip_Yn                  := 'Y';
          ELSIF l_Msm_Nfo_To_Date < l_Pam_Curr_Date THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'NFO Scheme is not valid';
             l_Skip_Yn := 'Y';
          ELSIF  l_Msm_Pur_Allowed = 'N' THEN
             l_Mand_Fields_Msg :=Nvl(l_Mand_Fields_Msg, ' ')||'--'||'Purchase allowed flag not valid';
             l_Skip_Yn := 'Y';
          END IF;
       END IF;

       IF l_Msm_Min_Pur_Amt > 999999999999999999999990.00 THEN
          l_Msm_Min_Pur_Amt := 999999999999999999999990.00;
       END IF;
       IF l_Msm_Max_Pur_Amt > 999999999999999999999990.00 THEN
          l_Msm_Max_Pur_Amt := 999999999999999999999990.00;
       END IF ;
       IF l_Msm_Add_Pur_Amt > 999999999999999999999990.00 THEN
          l_Msm_Add_Pur_Amt := 999999999999999999999990.00;
       END IF ;
       IF l_Msm_Add_Pur_Amt_Mul > 999999999999999999999990.00 THEN
          l_Msm_Add_Pur_Amt_Mul := 999999999999999999999990.00;
       END IF ;
       IF l_Msm_Min_Redem_Qty > 999999999999999999999990.0000 THEN
          l_Msm_Min_Redem_Qty := 999999999999999999999990.0000;
       END IF ;
       IF l_Msm_Max_Redem_Qty > 999999999999999999999990.0000 THEN
          l_Msm_Max_Redem_Qty := 999999999999999999999990.0000;
       END IF ;
       IF l_Msm_Min_Redem_Amt > 999999999999999999999990.00 THEN
          l_Msm_Min_Redem_Amt := 999999999999999999999990.00;
       END IF ;
       IF l_Msm_Max_Redem_Amt > 999999999999999999999990.00 THEN
          l_Msm_Max_Redem_Amt := 999999999999999999999990.00;
       END IF ;
       IF l_Msm_Redem_Qty_Mul > 999999999999999999999990.00 THEN
          l_Msm_Redem_Qty_Mul := 999999999999999999999990.00;
       END IF ;

       IF l_Msm_Rta_Id NOT IN ('KARVY','CAMS','FTI') THEN
          P_Ret_Msg := 'RTA Id is Not Mapped/Found  in the System';
          RAISE E_User_Exp;
       END IF;
       IF l_Skip_Yn = 'Y' THEN
          l_Mand_Fields_Msg := l_Mand_Fields_Msg;
          RAISE E_Mand_Exp;
       END IF;

    END p_Validate_Data;
    BEGIN
      p_Ret_Msg := ' Running Housekeeping. ';
      STD_Lib.P_Housekeeping( l_Prg_Id,
                              'MFD',
                              'MFD-'||P_File_Name,
                              'N',
                              l_Log_File_Handle,
                              l_Log_File_Name,
                              l_Prg_Process_Id
                             );

      l_Pam_Curr_Date  := Std_Lib.l_Pam_Curr_Date;

      l_File_Ptr       := Utl_File.fopen(P_Path, P_File_Name, 'R',32767);
      SELECT Nvl(MAX(R.Rv_Low_Value),'BSE')
      INTO   l_Primary_File
      FROM cg_ref_codes R
      WHERE rv_domain = 'MFD_PRIMARY_SCHEME_FILE';

      Utl_File.New_Line(l_Log_File_Handle, 1);
      Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date    : ' || To_Char(l_Pam_Curr_Date, 'DD-MON-RRRR'));
      Utl_File.New_Line(l_Log_File_Handle, 1);
      Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
      Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' File Name           :     ' || p_File_Name);
      Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
      LOOP
        BEGIN
          Utl_File.Get_Line(l_File_Ptr,l_Line_Buffer,32767);
          l_Line_Buffer := Trim(l_Line_Buffer);
          --IF l_Line_Buffer is Not Null Then
            --l_Line_Buffer := Std_Lib.Remove_Invalid_Char(l_Line_Buffer);
          --END IF ;
        EXCEPTION
          WHEN No_Data_Found Then
            RAISE End_Of_File;
        END;
        l_Line_No := l_Line_No + 1;
        Savepoint currline ;
        BEGIN
          IF l_Line_No > 1 AND l_Line_Buffer IS NOT NULL THEN
             Std_Lib.Split_line(l_Line_Buffer, ',', l_Bse_Tab);
             P_Ret_Msg  :='While Assign Into Variables ';
             p_Assign_Into_Variables ;
             P_Ret_Msg  :=' ';
             p_Validate_Data;
             BEGIN
               SELECT am.amc_id
               INTO l_internal_amc_id
               FROM mfd_amc_master am
               WHERE am.Amc_Data_Vendor_Id = l_Msm_Amc_Id;
             EXCEPTION
               WHEN No_Data_Found THEN
                    l_Mand_Fields_Msg := ' ';
                    P_Ret_Msg := 'AMC Not Mapped/Found for Data Vendor in Amc Master';
                    RAISE E_User_Exp;
             END;

             BEGIN
               SELECT *
               INTO   r_Mfd_scheme_master
               FROM   Mfd_scheme_master
               WHERE  Msm_Data_Vendor_Id =  l_Msm_Data_Vendor_Id
               AND    Msm_Status         =   'A'
               AND    Msm_Record_Status  =   'A'
               AND    Msm_Div_Option     =  l_divd_option
               AND    l_Pam_Curr_Date Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Date) ;
               l_Change_New     := 'C';
             EXCEPTION
               WHEN No_Data_Found THEN
                 BEGIN
                   SELECT *
                   INTO   r_Mfd_scheme_master
                   FROM   Mfd_scheme_master
                   WHERE  (Msm_Bse_Code        =  l_Msm_Bse_Code
                           OR Msm_Nse_Code     =  l_Msm_Nse_Code
                           OR Msm_Rta_Sch_Cd   =  l_Msm_Rta_Sch_Cd
                           OR Msm_Amfi_Code    =  l_Msm_Amfi_Code
                           OR Msm_Isin         =  l_Msm_Isin)
                   AND    Msm_Amc_Id           =  l_internal_amc_id
                   AND    Msm_Status           =  'A'
                   AND    Msm_Record_Status    =  'A'
                   AND    Msm_Div_Option       =  l_divd_option
                   AND    l_Pam_Curr_Date Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Date) ;
                   l_Change_New     := 'C';
                 EXCEPTION
                   WHEN No_Data_Found THEN
                     l_Change_New     := 'N';
                     l_Msm_Scheme_Id  := l_internal_amc_id ||Nvl(l_Msm_Rta_Sch_Cd,Nvl(l_Msm_Amfi_Code,l_Msm_Data_Vendor_Id))||l_Divind_Description;
                   WHEN Too_Many_Rows THEN
                     l_Mand_Fields_Msg := ' ';
                     P_Ret_Msg := 'This BSE, NSE, RTA, AMFI or ISIN exists for multiple records <'||l_Msm_Data_Vendor_Id||'>';
                    RAISE E_User_Exp;
                 END ;
             END;

             IF l_Primary_File ='VENDOR' THEN
               IF l_Change_New = 'C' THEN
                 p_Full_Upd_Scheme_Master ;
                 l_Count_Updated  :=  l_Count_Updated + 1;
               ELSE
                 l_Msm_Record_Status := 'A';
                 p_Insert_Mfd_Scheme_Master ;
               END IF;
             ELSE
               IF l_Change_New ='C' THEN
                 p_Null_Upd_Scheme_Master ;
                 l_Count_Updated  :=  l_Count_Updated + 1;
                 p_Write_Change_Skip_In_Log ;
               ELSE
                 l_Msm_Record_Status := 'A';
                 p_Insert_Mfd_Scheme_Master ;
               END IF ;
             END IF ;
          END IF;
      EXCEPTION
        WHEN E_User_Exp THEN
          Utl_File.New_Line(l_Log_File_Handle, 1);
          P_Ret_Msg := P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme : '||l_Msm_Scheme_Desc;
          Utl_File.Put_Line(l_Log_File_Handle, P_Ret_Msg);
          l_Count_Skipped := l_Count_Skipped + 1;
        WHEN E_Mand_Exp THEN
          Utl_File.New_Line(l_Log_File_Handle, 1);
          P_Ret_Msg  := P_Ret_Msg ||'--'||l_Mand_Fields_Msg;
          P_Ret_Msg := ' Record Skipped due to null value in mandatory fields - '||P_Ret_Msg || Chr(10) || ' For ISIN : '||l_Msm_Isin||' , '||'Scheme :'||l_Msm_Scheme_Desc;
          Utl_File.Put_Line(l_Log_File_Handle, P_Ret_Msg);
          l_Count_Skipped := l_Count_Skipped + 1;
        WHEN OTHERS THEN
          ROLLBACK TO currline ;
            Utl_File.New_Line(l_Log_File_Handle, 1);
            Utl_File.Put_Line(l_Log_File_Handle, dbms_utility.format_error_backtrace||
                                                 '*** Error at Line <'||l_Line_No||'> '|| Substr(Sqlerrm,1,800));
            Utl_File.Put_Line(l_Log_File_Handle,'    Line <'||l_Line_Buffer||'>');
            P_Ret_Msg := P_Ret_Msg || SQLERRM;
            l_Count_Skipped := l_Count_Skipped + 1;
      END ;
    END LOOP ;

      STD_Lib.P_Updt_Prg_Stat( l_Prg_Id                 ,
                               Std_Lib.l_Pam_Curr_Date  ,
                               l_Prg_Process_Id         ,
                               'Y'                      ,
                               'Y'                      ,
                               l_Sql_Err
                             );

      p_Ret_Val := 'SUCCESS';
      p_Ret_Msg := 'Process Completed Successfully ...';

  EXCEPTION
  WHEN End_Of_File THEN
    l_Count_Records  := l_Line_No - 1;
    --l_Count_Updated  :=  abs(l_Count_Updated - l_Count_Updated1);
    Utl_File.Put_Line(l_Log_File_Handle, ' ===================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ===================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                  : ' || l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted(Checker Mode)   : ' || l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated                  : ' || l_Count_Updated);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                  : ' || l_Count_Skipped);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Existing Records Updated         : ' || l_Count_Updated_Existing);
    Utl_File.Put_Line(l_Log_File_Handle, ' ===================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);
    Utl_File.fclose(l_File_Ptr);

    STD_Lib.P_Updt_Prg_Stat(l_Prg_Id,
                            Std_Lib.l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'Y',
                            'Y',
                            l_Sql_Err
                           );

    P_Ret_Val  :='SUCCESS';
    P_Ret_Msg  :='Process Completed Successfully !';

  WHEN OTHERS THEN
    ROLLBACK;
    p_Ret_Val := 'FAIL';
    l_error_line_no := DBMS_UTILITY.Format_Error_Backtrace;
    P_Ret_Msg       := l_error_line_no || CHR(10) || P_Ret_Msg ||
                       CHR(10) || ' Error message  is :' || SQLERRM;

    Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
    Utl_File.Fclose(l_Log_File_Handle);
    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Date,
                            l_Prg_Process_Id,
                            'E',
                            'Y',
                            l_Sql_Err);

  END P_Mfd_Load_Mfss_Vendor_File;

  PROCEDURE P_Download_Nav_Master_File( p_File_Name IN VARCHAR2,
                                        p_Exch_Id   IN VARCHAR2,
                                        p_Ret_Val   IN OUT VARCHAR2,
                                        p_Ret_Msg   IN OUT VARCHAR2
                                      )
  IS

    l_Log_File_Handle Utl_File.File_Type;
    l_File_Ptr        Utl_File.File_Type;
    l_Bse_Nse_Tab     Std_Lib.Tab;

    l_Pam_Curr_Dt     DATE;
    l_Pam_Last_Dt     DATE;
    l_File_Path       VARCHAR2(300);
    l_Log_File_Name   VARCHAR2(100);
    l_Prg_Process_Id  NUMBER := 0;
    --Tab_File_Records  Std_Lib.Tab;
    --Tab_Split_Record  Std_Lib.Tab;
    l_Line_Buffer     VARCHAR2(2000);

    l_Line_No                NUMBER := 0;
    l_Nav_Date               DATE;
    l_Scheme_Code            VARCHAR2(20);
    l_Scheme_Name            VARCHAR2(500);
    l_Rta_Scheme_Code        VARCHAR2(20);
    l_Dividend_Reinvest_Flag VARCHAR2(5);
    l_Isin                   VARCHAR2(12);
    l_Nav_Value              NUMBER(15,4);
    l_Rta_Code               VARCHAR2(20);
    l_Category_Code          VARCHAR2(100);
    l_Category_Name          VARCHAR2(100);
    l_Internal_Amc_Id        VARCHAR2(100);
    l_Internal_Scheme_Id     VARCHAR2(100);
    l_Count_Inserted         NUMBER := 0;
    l_Count_Updated          NUMBER := 0;
    l_Count_Records          NUMBER := 0;
    l_Count_Skip             NUMBER := 0;
    l_Message                VARCHAR2(300);
    l_Symbol                 VARCHAR2(20);
    l_Series                 VARCHAR2(2);
    l_Prg_Id VARCHAR2(30) := 'CSSDLNAV';
    Excp_Terminate        EXCEPTION;
    End_Of_File           EXCEPTION;

  BEGIN

    p_Ret_Msg := ' in housekeeping. Check if file exists in /ebos/files/upstream or Program is running.';
    Std_Lib.p_Housekeeping( l_Prg_Id,
                            p_Exch_Id,
                            p_Exch_Id||','||p_File_Name,
                            NULL,
                            l_Log_File_Handle,
                            l_Log_File_Name,
                            l_Prg_Process_Id
                          );

    p_Ret_Msg := ' getting current working date';
    l_Pam_Curr_Dt  := Std_Lib.l_Pam_Curr_Date;
    l_Pam_Last_Dt  := Std_Lib.l_Eq_Last_Date;

    p_Ret_Msg := ' getting file path';
    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    -- Reading File
    l_File_Ptr       := Utl_File.fopen(l_File_Path,P_File_Name,'R');

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,' Current Working Date    : ' ||To_Char(l_Pam_Curr_Dt, 'DD-MON-RRRR'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle,' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle,' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle,' ----------------------------------------------------------');

    LOOP
      BEGIN
        Utl_File.Get_Line(l_File_Ptr,l_Line_Buffer);
        l_Line_Buffer := Trim(l_Line_Buffer);
        IF l_Line_Buffer is Not Null Then
          l_Line_Buffer := Std_Lib.Remove_Invalid_Char(l_Line_Buffer);
        END IF ;
      EXCEPTION
        WHEN No_Data_Found Then
          RAISE End_Of_File;
      END;
      l_Line_No := l_Line_No + 1;
      BEGIN
        IF l_Line_Buffer IS NOT NULL THEN
           IF p_Exch_Id = 'BSE' THEN
             Std_Lib.Split_line(l_Line_Buffer, '|', l_Bse_Nse_Tab);
           ELSIF p_Exch_Id = 'NSE' THEN
             Std_Lib.Split_line(l_Line_Buffer, ',', l_Bse_Nse_Tab);
           END IF;
           IF p_Exch_Id = 'BSE' THEN
             l_Nav_Date                :=  To_Date(TRIM(l_Bse_Nse_Tab(1)), 'RRRR-MM-DD');
             l_Scheme_Code             :=  TRIM(l_Bse_Nse_Tab(2));
             l_Scheme_Name             :=  TRIM(l_Bse_Nse_Tab(3));
             l_Rta_Scheme_Code         :=  TRIM(l_Bse_Nse_Tab(4));
             l_Dividend_Reinvest_Flag  :=  TRIM(l_Bse_Nse_Tab(5));
             l_Isin                    :=  TRIM(l_Bse_Nse_Tab(6));
             l_Nav_Value               :=  TRIM(l_Bse_Nse_Tab(7));
             l_Rta_Code                :=  TRIM(l_Bse_Nse_Tab(8));
             BEGIN
               SELECT Msm_Amc_Id , Msm_Scheme_Id
               INTO   l_Internal_Amc_Id, l_Internal_Scheme_Id
               FROM   Mfd_Scheme_Master
               WHERE  UPPER(Msm_Isin) = UPPER(l_Isin)
               AND    Msm_Record_Status = 'A'
               AND    Msm_Status = 'A'
               AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
             EXCEPTION
               WHEN No_Data_Found THEN
                 SELECT Msm_Amc_Id , Msm_Scheme_Id
                 INTO   l_Internal_Amc_Id, l_Internal_Scheme_Id
                 FROM   Mfd_Scheme_Master
                 WHERE  UPPER(Msm_Bse_Code) = UPPER(l_Scheme_Code)
                 AND    Msm_Record_Status = 'A'
                 AND    Msm_Status = 'A'
                 AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
             END;
           ELSIF p_Exch_Id = 'NSE' THEN
             l_Nav_Date          :=  To_Date(TRIM(l_Bse_Nse_Tab(1)), 'DD-MON-RRRR');
             l_Symbol            :=  TRIM(l_Bse_Nse_Tab(2));
             l_Series            :=  TRIM(l_Bse_Nse_Tab(3));
             l_Scheme_Name       :=  TRIM(l_Bse_Nse_Tab(4));
             l_Category_Code     :=  TRIM(l_Bse_Nse_Tab(5));
             l_Category_Name     :=  TRIM(l_Bse_Nse_Tab(6));
             l_Isin              :=  TRIM(l_Bse_Nse_Tab(7));
             l_Nav_Value         :=  TRIM(l_Bse_Nse_Tab(8));

             BEGIN
               SELECT Msm_Amc_Id , Msm_Scheme_Id
               INTO   l_Internal_Amc_Id, l_Internal_Scheme_Id
               FROM   Mfd_Scheme_Master
               WHERE  UPPER(Msm_Isin) = UPPER(l_Isin)
               AND    Msm_Record_Status = 'A'
               AND    Msm_Status = 'A'
               AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
             EXCEPTION
               WHEN No_Data_Found THEN
                 SELECT Msm_Amc_Id , Msm_Scheme_Id
                 INTO   l_Internal_Amc_Id, l_Internal_Scheme_Id
                 FROM   Mfd_Scheme_Master
                 WHERE  UPPER(Msm_Nse_code) = UPPER(l_Symbol||l_Series)
                 AND    Msm_Record_Status = 'A'
                 AND    Msm_Status = 'A'
                 AND    l_Pam_Curr_Dt Between Msm_From_Date and nvl(Msm_to_Date,l_Pam_Curr_Dt) ;
             END;
           END IF;

           IF l_Nav_Date != l_Pam_Last_Dt THEN
             Utl_File.Put_Line(l_Log_File_Handle, 'Nav Date <' || l_Nav_Date ||'> ,does not match with the Last Business date  <' ||l_Pam_Last_Dt || '>.');
             p_Ret_Val := 'FAIL';
             RAISE Excp_Terminate;
           END IF;

        END IF;
        INSERT INTO Mfd_Nav
          ( Mn_Amc_Id      ,  Mn_Scheme_Id  ,  Mn_Nav_Date,
            Mn_Nav_Value   ,  Mn_Isin       ,  Mn_Creat_By,
            Mn_Creat_Dt    ,  Mn_Prg_Id     ,  Mn_Source
          )
        VALUES
          ( l_Internal_Amc_Id  ,  l_Internal_Scheme_Id  ,  l_Nav_Date  ,
            l_Nav_Value        ,  l_Isin                ,  USER        ,
            SYSDATE            ,  l_Prg_Id              ,  p_Exch_Id
          );
         l_Count_Inserted := l_Count_Inserted + 1;

         IF l_Count_Inserted = 1  THEN
           UPDATE Cg_Ref_Codes
           SET    Rv_Low_Value  = Decode( l_Nav_Date,Rv_High_Value,Rv_Low_Value,Rv_High_Value),
                  Rv_High_Value = l_Nav_Date
           WHERE Rv_Domain      = 'PORTFOLIO_NAV_2_LATEST_DATE';  --Required for portfolio Computation
         END IF;

      EXCEPTION
        WHEN Dup_Val_On_Index THEN
            UPDATE Mfd_Nav
            SET Mn_Nav_Value         =   l_Nav_Value     ,
                Mn_Isin              =   l_Isin          ,
                Mn_Last_Updt_By      =   USER            ,
                Mn_Last_Updt_Dt      =   SYSDATE
            WHERE Mn_Amc_Id          =   l_Internal_Amc_Id
            AND   Mn_Scheme_Id       =   l_Internal_Scheme_Id
            AND   Mn_Nav_Date        =   to_date(l_Nav_Date, 'DD-Mon-RRRR');

            l_Count_Updated    :=  l_Count_Updated + 1;
        WHEN OTHERS THEN
            Utl_File.Put_Line(l_Log_File_Handle, 'Scheme Not Mapped');
            Utl_File.Put_Line(l_Log_File_Handle,'*** Error at Line <'||l_Line_No||'> '|| Substr(Sqlerrm,1,200));
            Utl_File.Put_Line(l_Log_File_Handle,'    Line <'||l_Line_Buffer||'>');
            l_Count_Skip := l_Count_Skip + 1;
      END;

    END LOOP;

    Std_Lib.p_Updt_Prg_Stat( l_Prg_Id,
                             l_Pam_Curr_Dt,
                             l_Prg_Process_Id,
                             'C',
                             'Y',
                             l_Message
                           );

    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';


  EXCEPTION
    WHEN End_Of_File THEN
      l_Count_Records  := l_Line_No;
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File           :   ' || l_Count_Records);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Inserted          :   ' || l_Count_Inserted);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Updated           :   ' || l_Count_Updated);
      Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped           :   ' || l_Count_Skip);
      Utl_File.Put_Line(l_Log_File_Handle, '---------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
      Utl_File.Fclose(l_Log_File_Handle);

      Std_Lib.p_Updt_Prg_Stat( l_Prg_Id,
                               l_Pam_Curr_Dt,
                               l_Prg_Process_Id,
                               'C',
                               'Y',
                               l_Message
                             );

      p_Ret_Val := 'SUCCESS';
      p_Ret_Msg := 'Process Completed Successfully ...';

    WHEN OTHERS THEN
      p_Ret_Val := 'FAIL';
      P_Ret_Msg       := DBMS_UTILITY.Format_Error_Backtrace || CHR(10) || P_Ret_Msg ||
                         CHR(10) || ' Error message  is :' || SQLERRM;

      ROLLBACK;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END p_Download_Nav_Master_File;

  PROCEDURE P_Load_Mf_File_Sec_Hold (P_Agn_Id                IN  VARCHAR2,
                                     P_Server_Filename      IN  VARCHAR2,
                                     o_Ret_Msg              OUT VARCHAR2)
  AS
    l_Pam_Curr_Dt           DATE;
    l_Qty                   NUMBER := 0;
    l_Count_Skip            NUMBER := 0;
    l_Count_ins             NUMBER := 0;
    l_Line_Count            NUMBER := 0;
    l_Process_Id            NUMBER := 0;
    l_Ent_Status            VARCHAR2(1);
    l_Prg_Id                VARCHAR2(30) := 'MFSSSECHLD';
    l_Sem_Id                VARCHAR2(30);
    l_Client_Id             VARCHAR2(30);
    l_Dp                    VARCHAR2(30);
    l_Dp_Id                 VARCHAR2(30);
    l_Dp_Acc_No             VARCHAR2(30);
    l_Cust_Id               VARCHAR2(30);
    l_Isin                  VARCHAR2(30);
    l_Agency_Id             VARCHAR2(30);
    l_Client_Name           VARCHAR2(100);
    l_Sqlerrm               VARCHAR2(100);
    l_Server_Datafile_Path  VARCHAR2(500);
    l_Log_File_Name         VARCHAR2(500);
    l_Log_File_Handle       Utl_File.File_Type;
    l_Tab                   Std_Lib.Tab;
    l_Split_Fields          Std_Lib.Tab;
    Excp_Terminate          EXCEPTION;
    Excep_skip              EXCEPTION;

    TYPE r_Dpm_Id_Agn IS RECORD(Dpm_Id   VARCHAR2(8),
                                Agn_Id   VARCHAR2(5));

    TYPE t_Dpm_Id_Agn IS TABLE OF r_Dpm_Id_Agn INDEX BY VARCHAR2(13);
    tab_Dpm_Id_Agn      t_Dpm_Id_Agn;

    CURSOR C_Agn_Id IS
      SELECT Dpm_Id
      FROM   Depo_Participant_Master
      WHERE  Dpm_Agency_Cd = p_Agn_Id;

  BEGIN
    SELECT Pam_Curr_Dt
    INTO   l_Pam_Curr_Dt
    FROM   Parameter_Master;

    SELECT Rv_High_Value
    INTO   l_Server_Datafile_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain    = 'DATA_FILES'
    AND     Rv_Low_Value = 'CSS_FILES'
    AND     Rownum       < 2;

    o_Ret_Msg := 'Performing Housekeeping Activities';
    Std_Lib.P_Housekeeping (l_Prg_Id,            'ALL',             P_Agn_Id||'-'||P_Server_Filename,   'M',
                            l_Log_File_Handle,   l_Log_File_Name,   l_Process_Id);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Current Working Date : ' || To_Char(l_Pam_Curr_Dt, 'DD-MON-RRRR'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed    :');
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Agency Id            :     ' || P_Agn_Id);
    Utl_File.Put_Line(l_Log_File_Handle, ' File Name            :     ' || P_Server_Filename);
    Utl_File.Put_Line(l_Log_File_Handle, ' ----------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Fflush(l_Log_File_Handle);

    o_Ret_Msg := 'While opening log file.';

    l_Tab.DELETE;
    Std_Lib.Load_File(l_Server_Datafile_Path,
                      P_Server_Filename,
                      l_Line_Count,
                      l_Tab);

    o_Ret_Msg := 'Getting all DP id for given Agency code ';

    tab_Dpm_Id_Agn.DELETE;
    FOR i IN C_Agn_Id
    LOOP
      tab_Dpm_Id_Agn(i.Dpm_Id||P_Agn_Id).Dpm_Id := i.Dpm_Id;
    END LOOP;

    FOR Line_No IN l_Tab.FIRST .. Nvl(l_Tab.LAST,0)
    LOOP
      BEGIN
        o_Ret_Msg := 'Splitting line no <'||Line_No||'>'||Chr(10)||' <'||l_Tab(Line_No)||'>';

        o_Ret_Msg := 'Splitting fields in the line buffer';
        l_Split_Fields.DELETE;
        Std_Lib.Split_Line(l_Tab(Line_No),
                           ',',
                           l_Split_Fields);

        o_Ret_Msg := 'Assigning values to individual fields ' ||chr(10)||l_Tab(Line_No);

        l_Client_Id := l_Split_Fields(l_Split_Fields.FIRST);
        l_Sem_Id    := l_Split_Fields(l_Split_Fields.FIRST + 1);
        l_Qty       := l_Split_Fields(l_Split_Fields.FIRST + 2);

        IF l_Qty < 0 THEN
          o_Ret_Msg := ' Quantity Cannot be negative for the client < ' ||l_Client_Id || ' >  and Scrip < ' || l_Sem_Id || ' > Qty < '||l_Qty ||' >  ';
          Utl_File.Put_Line(l_Log_File_Handle,o_Ret_Msg);
          Utl_File.Fflush(l_Log_File_Handle);
          RAISE Excp_Terminate;
        END IF ;

        IF l_Qty = 0 THEN
          o_Ret_Msg    := ' Quantity Cannot be zero(0) for the client < ' ||l_Client_Id || ' >  and Scrip < ' || l_Sem_Id || ' > Qty < '||l_Qty ||' > . Hence skipping the record.';
          l_Count_Skip := l_Count_Skip + 1;
          Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
          Utl_File.Fflush(l_Log_File_Handle);
          RAISE Excep_skip;
        END IF ;

        IF l_Qty IS NULL THEN
          o_Ret_Msg := ' Quantity Cannot be blank for the client < ' || l_Client_Id || ' >  and Scrip < ' || l_Sem_Id || ' > Qty < '||l_Qty||' > ';
          Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
          Utl_File.Fflush(l_Log_File_Handle);
          RAISE Excp_Terminate;
        END IF;

        BEGIN
          SELECT Msm_Isin
          INTO   l_Isin
          FROM   Mfd_Scheme_Master
          WHERE  Msm_Scheme_Id      = l_Sem_Id
          AND     Msm_Status        = 'A'
          AND    Msm_Record_Status = 'A'
          AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Dt);
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Isin := NULL;
            o_Ret_Msg := ' Scrip < '||l_Sem_Id||' > not present in the system';
            Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
            Utl_File.Fflush(l_Log_File_Handle);
            RAISE Excp_Terminate;
        END;

        BEGIN
          SELECT Ent_Status,
                 Ent_Name
          INTO   l_Ent_Status,
                 l_Client_Name
          FROM   Entity_Master,
                 Entity_Privilege_Mapping
          WHERE  Ent_Id                    = Epm_Ent_Id
          AND    Ent_Id                    = l_Client_Id
          AND    Ent_Type                  = 'CL'
          AND    Ent_Templet_Client        = 'N'
          AND   (Nvl(Epm_Seg_Mfss_Bse,'N') = 'Y'
          OR     Nvl(Epm_Seg_Mfss,'N')     = 'Y');

          IF l_Ent_Status = 'D' THEN
            o_Ret_Msg := ' Client < ' || l_Client_Id || ' > is disabled in the system ';
            Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
            Utl_File.Fflush(l_Log_File_Handle);
            RAISE Excp_Terminate;
          END IF;
        EXCEPTION
          WHEN No_Data_Found THEN
            o_Ret_Msg := ' Either Client < ' || l_Client_Id || ' > not present in the system or Client does not have MF privileges';
            Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
            Utl_File.Fflush(l_Log_File_Handle);
        END;

        BEGIN
          SELECT Mdi_Dp_Acc_No,
                 Mdi_Cust_Id,
                 Mdi_Dpm_Id,
                 Mdi_Dpm_Dem_Id,
                 Mdi_Agency_Id
          INTO   l_Dp_Acc_No,
                 l_Cust_Id,
                 l_Dp_Id,
                 l_Dp,
                 l_Agency_Id
          FROM   Member_Dp_Info
          WHERE  Mdi_Id            = l_Client_Id
          AND    Mdi_Default_Flag  = 'Y'
          AND    Mdi_Status       != 'C';
        EXCEPTION
          WHEN No_Data_Found THEN
            o_Ret_Msg := ' No data found in Member Dp Info for the Client < ' ||l_Client_Id || ' > and DP Id < ' || l_Dp_Id || ' >';
            Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
            Utl_File.Fflush(l_Log_File_Handle);
            RAISE Excp_Terminate;
          WHEN Too_Many_Rows THEN
            o_Ret_Msg := ' Too many rows retrieved from Member Dp Info for the Client < ' ||l_Client_Id || ' > and DP Id < ' || l_Dp_Id || ' >';
            Utl_File.Put_Line (l_Log_File_Handle,o_Ret_Msg);
            Utl_File.Fflush(l_Log_File_Handle);
            RAISE Excp_Terminate;
        END;

        IF tab_Dpm_Id_Agn.EXISTS(l_Dp_Id||P_Agn_Id) THEN
          INSERT INTO Temp_Hold_Mf
                 (Tmp_Entity_Id,     Tmp_Entity_Name,   Tmp_Sem_Id,
                  Tmp_Isin,          Tmp_Dp,            Tmp_Dp_Id,
                  Tmp_Dp_Acc_No,     Tmp_Cust_Id,       Tmp_Agency_Id,
                  Tmp_Qty)
          VALUES (l_Client_Id,       l_Client_Name,     l_Sem_Id,
                  l_Isin,            l_Dp,              l_Dp_Id,
                  l_Dp_Acc_No,       l_Cust_Id,         l_Agency_Id,
                  l_Qty);

          l_Count_Ins := l_Count_Ins + 1;
        ELSE
          l_Count_Skip := l_Count_Skip + 1 ;
          Utl_File.Put_Line(l_Log_File_Handle,' Record Skipped for Client < '||l_Client_Id|| ' >, Scrip < '||l_Sem_Id||' > since DP details do not exist in system');
          Utl_File.Fflush(l_Log_File_Handle);
        END IF;
      EXCEPTION
        WHEN Excep_Skip THEN
          NULL;
      END;
    END LOOP;

    P_Updt_Program_Status (l_Pam_Curr_Dt,
                           l_Process_Id,
                           l_Prg_Id);

    o_Ret_Msg  := 'SUCCESS';
    Utl_File.New_Line(l_Log_File_Handle,'2');

    Utl_File.Put_Line(l_Log_File_Handle, '====================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle, '====================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records in File                     : ' || l_Line_Count);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Uploaded Successfully       : ' || l_Count_ins);
    Utl_File.Put_Line(l_Log_File_Handle, ' No. Of Records Skipped                     : ' || l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Handle, '====================================================================');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed Successfully !!! ');
    Utl_File.Fflush(l_Log_File_Handle);
    Utl_File.Fclose(l_Log_File_Handle);

  EXCEPTION
    WHEN Excp_Terminate THEN
      ROLLBACK;
      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,   l_Pam_Curr_Dt,   l_Process_Id,
                               'E',        'Y',             l_Sqlerrm);
      Utl_File.Fclose(l_Log_File_Handle);
    WHEN OTHERS THEN
      ROLLBACK;
      o_Ret_Msg := 'Error occured while :' || o_Ret_Msg ||' - '||SQLERRM;
      Std_Lib.P_Updt_Prg_Stat (l_Prg_Id,   l_Pam_Curr_Dt,   l_Process_Id,
                               'E',        'Y',             l_Sqlerrm);
      Utl_File.Fclose(l_Log_File_Handle);
  END P_Load_Mf_File_Sec_Hold;

  Procedure p_Get_Slip_Number(p_Dem_Id    Varchar2,
                              p_Dpm_Id    Varchar2,
                              p_Inst_Type Varchar2,
                              p_Dp_Acc_No Varchar2,
                              p_Exch_Id   Varchar2,
                              p_New_Bk_No In Out Varchar2,
                              p_New_Sl_No In Out Number,
                              p_Srl_No    In Out Number,
                              p_Inst_No   In Out Number,
                              p_Err_Msg   Out Varchar2,
                              p_Ret_Val   Out Varchar2)
 Is
    l_Sql_Stmt            Number;
    l_In_Use_Count        Number;
    l_Not_Used_Count      Number;
    l_Curr_Slip_No        Number;
    l_To_Slip_No          Number;
    l_Seq_No              Number;
    l_Bk_No               Varchar2(10);
    l_Not_Used_Seq_No     Number;
    l_Not_Used_Booklet_No Varchar2(10);
    l_Get_New_Booklet     Varchar2(1);
    l_Srl_No              Number;
    l_Dpm_Id              Varchar2(10);
    do_nothing   EXCEPTION;
  Begin
    p_Err_Msg  := 'SUCCESS';
    p_Ret_Val  := '0';
    l_Sql_Stmt := 1;

    l_Dpm_Id := p_Dpm_Id;


    If (p_Inst_No = 0) Or (p_Inst_No >= p_Srl_No) Then
      -- Check if any booklet is IN USE
        Begin
            Select Count(1)
            Into    l_In_Use_Count
            From    Dp_Book_Register, Dp_Book_Inst_Details
            Where   Dpr_Seq               = Dbi_Dpr_Seq
            AND     Dpr_Booklet_No        = Dbi_Dpr_Booklet_No
            AND     Dpr_Dem_Id            = p_Dem_Id
            And     Dpr_Dpm_Id            = l_Dpm_Id
            AND     Dpr_Acc_No            =  p_Dp_Acc_No
            AND    Nvl(Dpr_Exm_Id, 'ALL') =  p_Exch_Id
            And    Dbi_Inst_Type          = p_Inst_Type
            AND    Dpr_Status             = 'I';

        If (l_In_Use_Count > 0) Then
          -- In Use
            Begin
                -- Get details of the In Use Booklet
                l_Sql_Stmt := 7;
                Select  Nvl(Dpr_Curr_Slip_No, Dpr_Fr_Slip_No - 1),
                        Dpr_To_Slip_No,
                        Dpr_Seq,
                        Dpr_Booklet_No,
                        Nvl(Dpr_Slip_Srl, 0)
                Into    l_Curr_Slip_No, l_To_Slip_No, l_Seq_No, l_Bk_No, l_Srl_No
                From    Dp_Book_Register, Dp_Book_Inst_Details
                Where   Dpr_Seq = Dbi_Dpr_Seq
                AND     Dpr_Booklet_No = Dbi_Dpr_Booklet_No
                AND     Dpr_Dem_Id     = p_Dem_Id
                AND     Dpr_Dpm_Id     = p_Dpm_Id
                AND     Dpr_Acc_No     = p_Dp_Acc_No
               AND      Dpr_Exm_Id     = p_Exch_Id
               AND      Dbi_Inst_Type  = p_Inst_Type
               AND      Dpr_Status     = 'I';

            If (l_Curr_Slip_No + 1 > l_To_Slip_No) Then
              -- No more slips available
              -- Update the status to Used
              l_Sql_Stmt := 8;
                Update  Dp_Book_Register
                Set     Dpr_Status     = 'U'
                Where   Dpr_Seq        = l_Seq_No
                And     Dpr_Booklet_No = l_Bk_No;
             -- l_Get_New_Booklet := 'Y';
            End If;
          End;
        End If;

        -- If in use booklet count is 0 or in use booklet has become full */
        If ((l_In_Use_Count = 0) Or (l_Get_New_Booklet = 'Y')) Then
          -- Not In Use or Used
          Begin
            -- Check if any booklet is NOT USED
            l_Sql_Stmt := 2;
                Select Count(*)
                Into    l_Not_Used_Count
                From    Dp_Book_Register, Dp_Book_Inst_Details
                Where   Dpr_Seq           = Dbi_Dpr_Seq
                AND     Dpr_Booklet_No    = Dbi_Dpr_Booklet_No
                AND     Dpr_Dem_Id        = p_Dem_Id
                AND     Dpr_Dpm_Id        = p_Dpm_Id
                AND     Dpr_Acc_No        = p_Dp_Acc_No
                AND     Dpr_Exm_Id        = p_Exch_Id
                AND     Dbi_Inst_Type     = p_Inst_Type
                AND     Dpr_Status        = 'N';

            -- Not used booklet found
            If (l_Not_Used_Count > 0) Then
              -- Not Used
              -- Get Details of any one Not Used Booklet
              l_Sql_Stmt := 3;
                Select  Dbi_Dpr_Seq, Dbi_Dpr_Booklet_No
                Into    l_Not_Used_Seq_No, l_Not_Used_Booklet_No
                From    Dp_Book_Inst_Details, Dp_Book_Register
                Where   Dpr_Dem_Id            = p_Dem_Id
                AND     Dpr_Dpm_Id            = p_Dpm_Id
                AND     Dbi_Inst_Type         = p_Inst_Type
                AND     Dpr_Acc_No            =  p_Dp_Acc_No
                AND     Dpr_Exm_Id            =  p_Exch_Id
                And     Dpr_Status            = 'N'
                AND     Dpr_Seq               = Dbi_Dpr_Seq
                AND     Dpr_Booklet_No        = Dbi_Dpr_Booklet_No
                And     Rownum < 2
               Order By Dbi_Dpr_Seq, Dbi_Dpr_Booklet_No;

              -- Update that Booklet Status to In Use
              l_Sql_Stmt := 4;
              Update Dp_Book_Register
              Set   Dpr_Status     = 'I'
              Where Dpr_Seq        = l_Not_Used_Seq_No
              AND   Dpr_Booklet_No = l_Not_Used_Booklet_No;


                   -- Get Details of the NEW In Use Booklet
             l_Sql_Stmt := 5;
             Select Nvl(Dpr_Curr_Slip_No, Dpr_Fr_Slip_No),
                    Nvl(Dpr_To_Slip_No, 0),
                    Nvl(Dpr_Seq, 0),
                    Nvl(Dpr_Booklet_No, 0),
                    Nvl(Dpr_Slip_Srl, 0)
             Into   l_Curr_Slip_No, l_To_Slip_No, l_Seq_No, l_Bk_No, l_Srl_No
             From   Dp_Book_Register, Dp_Book_Inst_Details
             Where  Dpr_Seq           = Dbi_Dpr_Seq
             AND    Dpr_Booklet_No    = Dbi_Dpr_Booklet_No
             AND    Dpr_Dem_Id        = p_Dem_Id
             AND    Dpr_Dpm_Id        =  p_Dpm_Id
             AND    Dbi_Inst_Type     = p_Inst_Type
             AND    Dpr_Acc_No        =  p_Dp_Acc_No
             AND    Dpr_Exm_Id        =  p_Exch_Id
             And    Dpr_Status        = 'I';

             If (l_Curr_Slip_No + 1 > l_To_Slip_No) Then
              -- No more slips available
              -- Update the status to Used
              l_Sql_Stmt := 8;
                Update  Dp_Book_Register
                Set     Dpr_Status     = 'U'
                Where   Dpr_Seq        = l_Seq_No
                And     Dpr_Booklet_No = l_Bk_No;
             End if;

          Else
              p_Ret_Val := '2';
              Return;
          End If;
          End;
        End If;


        If (l_Curr_Slip_No + 1 <= l_To_Slip_No) Then
          -- Update the Current Slip Number
          l_Sql_Stmt := 6;
          Update Dp_Book_Register
             Set Dpr_Curr_Slip_No = Decode(Dpr_Curr_Slip_No,
                                           Null,
                                           Dpr_Fr_Slip_No,
                                           Dpr_Curr_Slip_No + 1)
           Where Dpr_Seq = l_Seq_No And Dpr_Booklet_No = l_Bk_No;
        End if;

        If (l_Curr_Slip_No <= l_To_Slip_No) Then
          p_New_Bk_No := l_Bk_No;
          p_New_Sl_No := l_Curr_Slip_No;
          p_Srl_No    := l_Srl_No;
          p_Inst_No   := 1;
          p_Ret_Val   := '1';
        End if;

      End;
    Else
      p_Inst_No := p_Inst_No + 1;
    End If;

    -- Following condition added on 04-SEP-06 to initialise p_New_Bk_No if it's value is null
     IF p_New_Bk_No is null THEN
        p_New_Bk_No := 0;
     END IF;
  -- Added upto here
  Exception
      When Others Then
        If (l_Sql_Stmt = 1) Then
          p_Err_Msg := ('Error in selecting count for IN USE Booklet - ' ||SQLCODE);
        Elsif (l_Sql_Stmt = 2) Then
          p_Err_Msg := ('Error in selecting count for NOT USED Booklets - ' ||SQLCODE);
        Elsif (l_Sql_Stmt = 3) Then
          p_Err_Msg := ('Error in selecting details of NOT USED Booklet - ' ||SQLCODE);
        Elsif (l_Sql_Stmt = 4) Then
          p_Err_Msg := ('Error in updating status from N to I - '|| SQLCODE);
        Elsif (l_Sql_Stmt = 5) Then
          p_Err_Msg := ('Error in selecting details of IN USE Booklet - ' ||SQLCODE);
        Elsif (l_Sql_Stmt = 6) Then
          p_Err_Msg := ('Error in updating Current Slip Number - '||SQLCODE);
        Elsif (l_Sql_Stmt = 7) Then
          p_Err_Msg := ('Error in selecting details of IN USE Booklet :- ORA-' ||SQLCODE);
        Elsif (l_Sql_Stmt = 8) Then
          p_Err_Msg := ('Error in updating status from I to U -'|| SQLCODE);
        End If;

        IF SQLCODE = '-1422' THEN
           p_Err_Msg := ('There are multiple Inused Booklets for given Instruction type < '||p_Inst_Type||'>');
        END IF;

        p_Ret_Val := '3';
        p_New_Bk_No := '0';
  End p_Get_Slip_Number;

  PROCEDURE P_Mfd_Load_Sip_Master_Fil_NSE(P_File_Name  IN  VARCHAR2,
                                       P_Ret_Val    OUT VARCHAR2,
                                       P_Ret_Msg    OUT VARCHAR2)
  
  IS

   l_Prg_Id           VARCHAR2(10) := 'MFSIPNSE'    ;
   l_Log_File_Ptr     Utl_File.File_Type              ;
   l_Log_File_Path    VARCHAR2(300)                   ;
   l_Process_Id       NUMBER(10)                      ;
   l_Pam_Curr_Dt      DATE                            ;
   l_Trace_Level      VARCHAR2(30)                    ;
   l_Data_File_Path   VARCHAR2(300)                   ;
   l_Rec_Count        NUMBER(10) := 0                 ;
   l_Rec_No           NUMBER := 0                     ;
   l_File_Tab         Std_Lib.Tab                     ;
   l_Split_Tab        Std_Lib.Tab                     ;


   l_Msd_Rec_Cnt      NUMBER := 0                     ;
   l_Msp_Rec_Cnt      NUMBER := 0                     ;
   l_Msd_Inst_Rec     NUMBER := 0                     ;
   l_Msd_Updt_Rec     NUMBER := 0                     ;
   l_Msp_Inst_Rec     NUMBER := 0                     ;
   l_Msp_Updt_Rec     NUMBER := 0                     ;

   l_Skip_Rec         NUMBER(10) := 0                 ;
   l_Skip_Date        NUMBER(10) := 0                 ;
   Skip_Date          EXCEPTION                       ;
   Skip_Rec           EXCEPTION                       ;
   Fail_Process       EXCEPTION                       ;
   o_Sql_Msg          VARCHAR2(2000)                  ;
   l_Internal_Sch_Id  VARCHAR2(30)                    ;
   l_Sch_From_Dt      DATE                            ;
   l_Isin             VARCHAR2(12)                    ;
   t_Err_Log          Tab_Err_Msg                     ;
   t_Err_Log_Dt       Tab_Err_Msg                     ;
   -- File Fields
   l_Scheme_Id        VARCHAR2(30)                    ;
   l_Plan_Type        VARCHAR2(3)                     ;
   l_Frequency        VARCHAR2(15)                    ;
   l_Period           NUMBER(10)                      ;
   l_Min_Period       NUMBER(10)                      ;
   l_Max_Period       NUMBER                          ;
   l_Min_Amt          NUMBER(30)                      ;
   l_Max_Amt          NUMBER                          ;
   l_Amt_Multiple     NUMBER(30)                      ;
   l_Min_Units        NUMBER                          ;
   l_Max_Units        NUMBER                          ;
   l_Unit_Multiple    NUMBER                          ;
   l_Dd               VARCHAR2(100)                   ;
   --Handled Sip date like 04|05|06|
   l_Date             NUMBER(2) := 0                  ;
   l_Date_Yn          VARCHAR(1) := 'N'               ;
   l_Process_Date_Identifier        VARCHAR2(15)      ;
   l_Date_Var         VARCHAR2(10)                    ;
   l_Skip_First_Rec   NUMBER    := 0                  ;
   l_Count_Dt         NUMBER    := 0                  ;
   l_Dt_Cnt           NUMBER    := 0                  ;
   l_Process_Date     NUMBER    := 1                  ;
   l_Instr_Cnt        NUMBER    := 0                  ;


   PROCEDURE P_Insert_Mfd_Sip_Details
   IS
   BEGIN
     INSERT INTO Mfd_Sip_Details
          (Sid_Scheme_Id,              Sid_Sch_From_Dt,      Sid_Record_Status,           Sid_Status,
           Sid_Plan_Type,              Sid_Frequency,        Sid_Process_Date_Identifier, Sid_Dd,
           -----
           Sid_Mon,                    Sid_Creat_Dt,         Sid_Creat_By,                Sid_Prg_Id,
           Sid_Exm_Id,                 Sid_Disp_Scheme_id
            )
     VALUES
          (l_Internal_Sch_Id,          l_Sch_From_Dt,        'A',                         'A',
           l_Plan_Type,                l_Frequency,          l_Process_Date_Identifier,   l_Date,
           ------
           NULL,                       SYSDATE,              USER,                        l_Prg_Id,
           'NA',                       l_Internal_Sch_Id
          );
   END P_Insert_Mfd_Sip_Details;

  BEGIN
   P_Ret_Val := 'FAIL';
   P_Ret_Msg := 'Performing Housekeeping......';
   Std_Lib.P_Housekeeping(l_Prg_Id        ,
                          'MF'            ,
                          P_File_Name     ,
                          'E'             ,
                          l_Log_File_Ptr  ,
                          l_Log_File_Path ,
                          l_Process_Id    ,
                          'Y')            ;

   l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date ;
   l_Trace_Level := Std_Lib.l_Debug_Mode    ;

   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Working Date      :-  '||l_Pam_Curr_Dt);
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master File   :-  '||P_File_Name );
   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');

   P_Ret_Msg := ' selecting data file path ';
   SELECT Rv_High_Value
   INTO   l_Data_File_Path
   FROM   Cg_Ref_Codes
   WHERE  Rv_Domain    = 'DATA_FILES'
   AND    Rv_Low_Value = 'CSS_FILES';

   t_Err_log.DELETE;
   t_Err_Log_Dt.DELETE;
   l_File_Tab.DELETE;
   P_Ret_Msg := ' loading the file <'||P_File_Name||'>';
   Std_Lib.Load_File(l_Data_File_Path ,
                     P_File_Name      ,
                     l_Rec_Count      ,
                     l_File_Tab)      ;

   P_Ret_Msg := ' In Main Loop..' ;
   FOR i IN 1..l_File_Tab.COUNT
   LOOP
     IF l_Trace_Level = 'ADMIN' THEN
        Utl_File.Put_Line(l_Log_File_Ptr,'Processing record <'||l_File_Tab(i)||'>');
     END IF;

     -- To Skip Header
     IF l_Rec_No  > 0 THEN
         BEGIN
           l_Split_Tab.DELETE ;
           P_Ret_Msg := ' splitting file data.';
           Std_Lib.Split_line(l_File_Tab(i) ,
                              ','           ,
                              l_Split_Tab)  ;

           l_Scheme_Id                  := Rtrim(LTrim(TRIM(l_Split_Tab(1)),'"'),'"');

           P_Ret_Msg := ' internal Scheme Id Not Found For Scheme Code '||l_Scheme_Id;
           BEGIN
             SELECT Msm_Scheme_Id,
                    Msm_From_Date,
                    Msm_Isin
             INTO   l_Internal_Sch_Id,
                    l_Sch_From_Dt,
                    l_Isin
             FROM   Mfd_Scheme_Master m
             WHERE  Msm_Scheme_Id      = l_Scheme_Id
             AND    l_Pam_Curr_Dt Between m.Msm_From_Date AND Nvl(m.Msm_To_Date,l_Pam_Curr_Dt)
             AND    M.Msm_Status        = 'A'
             AND    m.Msm_Record_Status = 'A';
           EXCEPTION
             WHEN No_Data_Found THEN
                RAISE Skip_Rec;
           END;

           l_Plan_Type                  := Rtrim(LTrim(TRIM(l_Split_Tab(2)),'"'),'"');
           l_Frequency                  := Rtrim(LTrim(TRIM(l_Split_Tab(3)),'"'),'"');
           l_Min_Period                 := Rtrim(LTrim(TRIM(l_Split_Tab(4)),'"'),'"');
           l_Max_Period                 := Rtrim(LTrim(TRIM(l_Split_Tab(5)),'"'),'"');
           l_Period                     := Rtrim(LTrim(TRIM(l_Split_Tab(6)),'"'),'"');
           l_Min_Amt                    := Rtrim(LTrim(TRIM(l_Split_Tab(7)),'"'),'"');
           l_Max_Amt                    := Rtrim(LTrim(TRIM(l_Split_Tab(8)),'"'),'"');
           l_Amt_Multiple               := Rtrim(LTrim(TRIM(l_Split_Tab(9)),'"'),'"');
           l_Min_Units                  := Rtrim(LTrim(TRIM(l_Split_Tab(10)),'"'),'"');
           l_Max_Units                  := Rtrim(LTrim(TRIM(l_Split_Tab(11)),'"'),'"');
           l_Unit_Multiple              := Rtrim(LTrim(TRIM(l_Split_Tab(12)),'"'),'"');
           l_Dd                         := Rtrim(LTrim(TRIM(l_Split_Tab(13)),'"'),'"');

           IF l_Plan_Type IS NULL THEN
              P_Ret_Msg := 'Plan Type is mandatory for <'||l_Internal_Sch_Id||'>';
              RAISE Fail_Process;
           END IF;

           IF l_Frequency IS NULL THEN
              P_Ret_Msg := 'Frequency is mandatory for <'||l_Internal_Sch_Id||'>';
              RAISE Fail_Process;
           END IF;

           IF l_Dd IS NULL THEN
              P_Ret_Msg := 'Date is mandatory for <'||l_Internal_Sch_Id||'>';
              RAISE Fail_Process;
           END IF;

           IF Nvl(l_Min_Period,0) <= 0 THEN
              P_Ret_Msg := 'Minimum period should be greater than equal to 1 for <'||l_Internal_Sch_Id||'>';
              RAISE Fail_Process;
           END IF;

           -- Need to Check
           IF Nvl(l_Period,0) < Nvl(l_Min_Period,0) OR Nvl(l_Period,0) > Nvl(l_Max_Period,0) THEN
                l_Period := l_Min_Period;
           END IF;

           IF Nvl(l_Max_Period,0) > 500 THEN
              P_Ret_Msg := 'Maximum period should be less than equal to 500 for <'||l_Internal_Sch_Id||'>';
              RAISE Fail_Process;
           END IF;

           IF l_Plan_Type = 'SIP' THEN

              IF Nvl(l_Min_Amt,0) <= 0 THEN
                 P_Ret_Msg := 'Minimum amount should be greater than Zero for <'||l_Internal_Sch_Id||'>';
                 RAISE Fail_Process;
              END IF;

              IF Nvl(l_Max_Amt,0) < Nvl(l_Min_Amt,0) THEN
                 P_Ret_Msg := 'Maximum amount should be greater than Minimum Amount for <'||l_Internal_Sch_Id||'>';
                 RAISE Fail_Process;
              END IF;

              l_Min_Units     := 0;
              l_Max_Units     := 0;
              l_Unit_Multiple := 0;

              P_Ret_Msg := ' Updating Sip in Mfd scheme master for scheme id <'|| l_Scheme_Id ||'> and Isin <'|| l_Isin ||'>';
              UPDATE Mfd_Scheme_Master
              SET    Msm_Sip_YN = 'Y'
              WHERE  Msm_Scheme_Id     = l_Scheme_Id
              AND    Msm_Isin          = l_Isin
              AND    Msm_Record_Status = 'A'
              AND    Msm_Status        = 'A';
           END IF;

           IF l_Plan_Type IN ('SWP','STP') THEN

              IF Nvl(l_Min_Units,0) <= 0 THEN
                 P_Ret_Msg := 'Minimum Units should be greater than Zero.';
                 RAISE Fail_Process;
              END IF;

             IF Nvl(l_Max_Units,0) < Nvl(l_Min_Units,0) THEN
                P_Ret_Msg := 'Maximum Units should be greater than Minimum Units.';
                RAISE Fail_Process;
             END IF;

             IF l_Plan_Type = 'SWP' THEN
                P_Ret_Msg := ' Updating Swp in Mfd scheme master for scheme id <'|| l_Scheme_Id ||'> and Isin <'|| l_Isin ||'>';
                UPDATE Mfd_Scheme_Master
                SET    Msm_Swp_Yn = 'Y'
                WHERE  Msm_Scheme_Id     = l_Scheme_Id
                AND    Msm_Isin          = l_Isin
                AND    Msm_Record_Status = 'A'
                AND    Msm_Status        = 'A';
             END IF;

             IF l_Plan_Type = 'STP' THEN
                P_Ret_Msg := ' Updating Stp in Mfd scheme master for scheme id <'|| l_Scheme_Id ||'> and Isin <'|| l_Isin ||'>';
                UPDATE Mfd_Scheme_Master
                SET    Msm_Stp_Yn = 'Y'
                WHERE  Msm_Scheme_Id     = l_Scheme_Id
                AND    Msm_Isin          = l_Isin
                AND    Msm_Record_Status = 'A'
                AND    Msm_Status        = 'A';
             END IF;

           END IF;

           BEGIN
             P_Ret_Msg := ' inserting into systematic plan for internal scheme id<'||l_Internal_Sch_Id||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
             INSERT INTO Mfd_Systematic_Plan
                   ( Msp_Scheme_Id,          Msp_Plan_Type,       Msp_Frequency,            Msp_Min_Amt,
                     Msp_Amt_Multiple,       Msp_Sch_From_Dt,     Msp_Status,               Msp_Record_Status,
                     -------
                     Msp_Period,             Msp_Min_Period,      Msp_Max_Period,           Msp_Max_Amt,
                     Msp_Min_Units,          Msp_Max_Units,       Msp_Unit_Multiple,        Msp_Creat_Dt,
                     -------
                     Msp_Creat_By,           Msp_Prg_Id,          Msp_Isin,                 Msp_Exchange,
                     Msp_Disp_Scheme_Id
                    )
             VALUES
                   ( l_Internal_Sch_Id,      l_Plan_Type,         l_Frequency,              l_Min_Amt,
                     l_Amt_Multiple,         l_Sch_From_Dt,       'A',                      'A',
                     --------
                     l_Period,               l_Min_Period,        l_Max_Period,             l_Max_Amt,
                     l_Min_Units,            l_Max_Units,         l_Unit_Multiple,          SYSDATE,
                     --------
                     USER,                   l_Prg_Id             ,l_Isin,                  'NA',
                     l_Internal_Sch_Id
                   );

             l_Msp_Inst_Rec := l_Msp_Inst_Rec + 1;

             l_Skip_First_Rec  := 0;
             l_Count_Dt        := 0;
             l_Date            := 0;
             l_Dt_Cnt          := 0;
             l_Process_Date    := 1;

             SELECT Length(l_Dd) - Nvl(Length(REPLACE(l_Dd, '|')), 0)
             INTO   l_Count_Dt
             FROM   Dual;

             FOR i IN 1 .. l_Count_Dt + 1
             LOOP
                IF l_Skip_First_Rec > 0 THEN

                   l_Dt_Cnt   := l_Dt_Cnt + 1;

                   IF Instr(l_Dd, '|', 1, (l_Dt_Cnt+1)) > 0 THEN
                      l_Instr_Cnt := Instr(l_Dd, '|', 1, (l_Dt_Cnt+1));
                   ELSE
                      l_Instr_Cnt := Length(l_Dd)+ 1;
                   END IF;

                   l_Date_Var := Substr(l_Dd, Instr(l_Dd, '|', 1, l_Dt_Cnt) + 1, l_Instr_Cnt -(Instr(l_Dd, '|', 1, l_Dt_Cnt) + 1));
                   l_Process_Date            := l_Process_Date + 1;
                   l_Process_Date_Identifier := 'Date ' || l_Process_Date;

                ELSE

                   IF (Instr(l_Dd, '|', 1,1)= 0 AND Length(l_Dd) = 1) THEN
                       l_Date_Var := Substr(l_Dd,1, Length(l_Dd));
                   ELSIF (Instr(l_Dd, '|', 1,1)= 2 AND Length(l_Dd) = 2) THEN
                         l_Date_Var := Substr(l_Dd,1, Length(l_Dd)-1);
                   ELSIF(Instr(l_Dd, '|', 1,1) = 3 AND Length(l_Dd) = 3) THEN
                         l_Date_Var := Substr(l_Dd,1, Length(l_Dd)-1);
                   ELSE
                         l_Date_Var := Nvl(Substr(l_Dd, 1,Instr(l_Dd,'|',1,1)-1),l_Dd);
                   END IF;

                   l_Process_Date_Identifier := 'Date ' || l_Process_Date;
                   l_Skip_First_Rec          := 1;

                END IF;

                BEGIN
                  IF Nvl(Trim(l_Date_Var), '-X') = '-X' THEN
                     l_Process_Date := l_Process_Date - 1;
                     RAISE Skip_Date;
                  END IF;

                  l_Date := To_Number(Trim(l_Date_Var));

                  IF l_Date > 31 THEN
                     l_Process_Date := l_Process_Date - 1;
                     l_Date_Yn := 'Y';
                     RAISE Skip_Date;
                  END IF;

                  P_Ret_Msg := ' inserting into mfd sip details for internal scheme id<'||l_Internal_Sch_Id||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
                  P_Insert_Mfd_Sip_Details;
                  l_Msd_Inst_Rec := l_Msd_Inst_Rec + 1;

                EXCEPTION
                  WHEN Skip_Date THEN
                    l_Skip_Date := l_Skip_Date + 1;
                    l_Rec_No := l_Rec_No + 1;
                    IF l_Date_Yn = 'Y' THEN
                       t_Err_Log(l_Skip_Date) := 'Date is greater than 31 for internal scheme id<'||l_Internal_Sch_Id||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'> and Record line <'||l_Rec_No||'>';
                       l_Date_Yn := 'N';
                    END IF;
                END;
             END LOOP;
           EXCEPTION
              WHEN Dup_Val_On_Index THEN

                 SELECT COUNT(1)
                 INTO   l_Msp_Rec_Cnt
                 FROM   Mfd_Systematic_Plan
                 WHERE  Msp_Scheme_Id     = l_Internal_Sch_Id
                 AND    Msp_Sch_From_Dt   = l_Sch_From_Dt
                 AND    Msp_Plan_Type     = l_Plan_Type
                 AND    Msp_Frequency     = l_Frequency
                 AND    Msp_Record_Status = 'A'
                 AND    Msp_Status        = 'A'
                 AND    Msp_Exchange      = 'NA'
                 AND    Msp_Disp_Scheme_id = l_Internal_Sch_Id;

                 IF l_Msp_Rec_Cnt > 0 THEN
                     l_Msp_Updt_Rec := l_Msp_Updt_Rec + 1;
                     UPDATE Mfd_Systematic_Plan
                     SET    Msp_Min_Amt        =  l_Min_Amt,
                            Msp_Max_Amt        =  l_Max_Amt,
                            Msp_Amt_Multiple   =  l_Amt_Multiple,
                            Msp_Min_Period     =  l_Min_Period,
                            Msp_Max_Period     =  l_Max_Period,
                            Msp_Period         =  l_Period,
                            Msp_Min_Units      =  l_Min_Units,
                            Msp_Max_Units      =  l_Max_Units,
                            Msp_Unit_Multiple  =  l_Unit_Multiple,
                            Msp_Last_Upt_Dt    =  SYSDATE,
                            Msp_Last_Upt_By    =  USER,
                            Msp_Prg_Id         =  l_Prg_Id
                     WHERE  Msp_Scheme_Id      =  l_Internal_Sch_Id
                     AND    Msp_Sch_From_Dt    =  l_Sch_From_Dt
                     AND    Msp_Plan_Type      =  l_Plan_Type
                     AND    Msp_Frequency      =  l_Frequency
                     AND    Msp_Record_Status  = 'A'
                     AND    Msp_Status         = 'A'
                     AND    Msp_Exchange       = 'NA'
                     AND    Msp_Disp_Scheme_id = l_Internal_Sch_Id;

                  END IF;

                  DELETE FROM  Mfd_Sip_Details s
                  WHERE  s.Sid_Scheme_Id               = l_Internal_Sch_Id
                  AND    s.Sid_Sch_From_Dt             = l_Sch_From_Dt
                  AND    s.Sid_Plan_Type               = l_Plan_Type
                  AND    s.Sid_Frequency               = l_Frequency
                  AND    s.Sid_Status                  = 'A'
                  AND    s.Sid_Record_Status           = 'A'
                  AND    s.Sid_Exm_Id                  = 'NA'
                  AND    s.Sid_Disp_Scheme_Id          = l_Internal_Sch_Id;

                  l_Skip_First_Rec := 0;
                  l_Count_Dt       := 0;
                  l_Date           := 0;
                  l_Dt_Cnt         := 0;
                  l_Process_Date   := 1;

                  SELECT Length(l_Dd) - Nvl(Length(REPLACE(l_Dd, '|')), 0)
                  INTO   l_Count_Dt
                  FROM   Dual;

                  FOR i IN 1 .. l_Count_Dt + 1
                  LOOP
                    IF l_Skip_First_Rec > 0 THEN

                         l_Dt_Cnt   := l_Dt_Cnt + 1;

                         IF Instr(l_Dd, '|', 1, (l_Dt_Cnt+1)) > 0 THEN
                            l_Instr_Cnt := Instr(l_Dd, '|', 1, (l_Dt_Cnt+1));
                         ELSE
                            l_Instr_Cnt := Length(l_Dd)+ 1;
                         END IF;

                         l_Date_Var := Substr(l_Dd, Instr(l_Dd, '|', 1, l_Dt_Cnt) + 1, l_Instr_Cnt -(Instr(l_Dd, '|', 1, l_Dt_Cnt) + 1));
                         l_Process_Date            := l_Process_Date + 1;
                         l_Process_Date_Identifier := 'Date ' || l_Process_Date;

                    ELSE

                         IF (Instr(l_Dd, '|', 1,1)= 0 AND Length(l_Dd) = 1) THEN
                             l_Date_Var := Substr(l_Dd,1, Length(l_Dd));
                         ELSIF (Instr(l_Dd, '|', 1,1)= 2 AND Length(l_Dd) = 2) THEN
                               l_Date_Var := Substr(l_Dd,1, Length(l_Dd)-1);
                         ELSIF(Instr(l_Dd, '|', 1,1) = 3 AND Length(l_Dd) = 3) THEN
                               l_Date_Var := Substr(l_Dd,1, Length(l_Dd)-1);
                         ELSE
                               l_Date_Var := Nvl(Substr(l_Dd, 1,Instr(l_Dd,'|',1,1)-1),l_Dd);
                         END IF;

                         l_Process_Date_Identifier := 'Date ' || l_Process_Date;
                         l_Skip_First_Rec          := 1;

                    END IF;

                   BEGIN

                      IF Nvl(Trim(l_Date_Var), '-X') = '-X' THEN
                         l_Process_Date := l_Process_Date - 1;
                         RAISE Skip_Date;
                      END IF;

                      l_Date := To_Number(l_Date_Var);

                      IF l_Date > 31 THEN
                         l_Process_Date := l_Process_Date - 1;
                         l_Date_Yn := 'Y';
                         RAISE Skip_Date;
                      END IF;

                      P_Ret_Msg := ' Dup index inserting into mfd sip details for internal scheme id<'||l_Internal_Sch_Id||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'> and Process Date Identifier<'|| l_Process_Date_Identifier ||'>';
                      P_Insert_Mfd_Sip_Details;
                      l_Msd_Inst_Rec := l_Msd_Inst_Rec + 1;

                   EXCEPTION
                     WHEN Dup_Val_On_Index THEN
                          ---- This scenario will never come as as i m deleting all datas
                           SELECT COUNT(1)
                           INTO  l_Msd_Rec_Cnt
                           FROM  Mfd_Sip_Details s
                           WHERE s.Sid_Scheme_Id               = l_Internal_Sch_Id
                           AND   s.Sid_Sch_From_Dt             = l_Sch_From_Dt
                           AND   s.Sid_Plan_Type               = l_Plan_Type
                           AND   s.Sid_Frequency               = l_Frequency
                           AND   s.Sid_Process_Date_Identifier = l_Process_Date_Identifier
                           AND   s.Sid_Status                  = 'A'
                           AND   s.Sid_Record_Status           = 'A'
                           AND   s.sid_exm_id                  = 'NA'
                           AND   s.sid_disp_scheme_id          = l_Internal_Sch_Id;

                           IF l_Msd_Rec_Cnt > 0 THEN

                              l_Msd_Updt_Rec := l_Msd_Updt_Rec + 1;

                              UPDATE Mfd_Sip_Details
                              SET    Sid_dd                      = l_Date,
                                     Sid_Last_Upt_Dt             = SYSDATE,
                                     Sid_Last_Upt_By             = USER,
                                     Sid_Prg_Id                  = l_Prg_Id
                              WHERE  Sid_Scheme_Id               = l_Internal_Sch_Id
                              AND    Sid_Sch_From_Dt             = l_Sch_From_Dt
                              AND    Sid_Plan_Type               = l_Plan_Type
                              AND    Sid_Frequency               = l_Frequency
                              AND    Sid_Process_Date_Identifier = l_Process_Date_Identifier
                              AND    Sid_Status                  = 'A'
                              AND    Sid_Record_Status           = 'A'
                              AND    Sid_Exm_Id                  = 'NA'
                              AND    Sid_Disp_Scheme_Id          = l_Internal_Sch_Id;

                           ELSE
                              P_Ret_Msg := ' Record already present in Sip details for Process Date Identifier<'||l_Process_Date_Identifier||'>';
                              RAISE Fail_Process;
                           END IF;

                        WHEN Skip_Date THEN
                           l_Skip_Date := l_Skip_Date + 1;
                           l_Rec_No := l_Rec_No + 1;
                           IF l_Date_Yn = 'Y' THEN
                              t_Err_Log(l_Skip_Date) := 'Date is greater than 31 for internal scheme id<'||l_Internal_Sch_Id||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'> and Record line <'||l_Rec_No||'>';
                              l_Date_Yn := 'N';
                           END IF;
                        WHEN OTHERS THEN
                          RAISE Fail_Process;
                    END;
                 END LOOP;
              WHEN OTHERS THEN
                RAISE Fail_Process;
              END;
         EXCEPTION
            WHEN Skip_Rec THEN
            l_Skip_Rec := l_Skip_Rec + 1;
            t_Err_Log(l_Skip_Rec) := 'Internal Scheme Id Not Found For Scheme Code '||l_Scheme_Id;
         END;
     END IF;
     l_Rec_No := l_Rec_No + 1;
   END LOOP;

   l_Rec_Count    := l_Rec_Count -1 ;
   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master upload summary              ');
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records in the file :'||l_Rec_Count);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Inserted    :'||l_Msp_Inst_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Updated     :'||l_Msp_Updt_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Skipped     :'||l_Skip_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.New_Line(l_Log_File_Ptr,1);
   IF t_Err_log.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_log(t));
      END LOOP;
   END IF;
   IF t_Err_Log_Dt.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_Log_Dt(t));
      END LOOP;
   END IF;


   Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                           l_Pam_Curr_Dt  ,
                           l_Process_Id   ,
                           'C'            ,
                           'Y'            ,
                           o_Sql_Msg)     ;

   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'Process Completed Successfully.');
   Utl_File.Fclose(l_Log_File_Ptr);

   P_Ret_Val := 'SUCCESS';
   P_Ret_Msg := 'Process Completed Successfully';

   EXCEPTION
      WHEN Fail_Process THEN
         ROLLBACK;
         P_Ret_Val := 'FAIL';
         P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
         Utl_File.New_Line(l_Log_File_Ptr,2);
         Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
         Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
         Utl_File.Fclose(l_Log_File_Ptr);
         Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;

      WHEN OTHERS THEN
        ROLLBACK;
        P_Ret_Val := 'FAIL';
        P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
        Utl_File.New_Line(l_Log_File_Ptr,2);
        Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
        Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
        Utl_File.Fclose(l_Log_File_Ptr);
        Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;


   END P_Mfd_Load_Sip_Master_Fil_NSE;
  
PROCEDURE P_Mfd_Load_Sip_Master_File(P_File_Name  IN  VARCHAR2,
                                           P_Ret_Val    OUT VARCHAR2,
                                           P_Ret_Msg    OUT VARCHAR2)
  
  IS

   l_Prg_Id           VARCHAR2(10) := 'MFSIPNSE'      ;
   l_Log_File_Ptr     Utl_File.File_Type              ;
   l_Log_File_Path    VARCHAR2(300)                   ;
   l_Process_Id       NUMBER(10)                      ;
   l_Pam_Curr_Dt      DATE                            ;
   l_Trace_Level      VARCHAR2(30)                    ;
   l_Data_File_Path   VARCHAR2(300)                   ;
   l_Rec_Count        NUMBER(10) := 0                 ;
   l_Rec_No           NUMBER := 0                     ;
   l_File_Tab         Std_Lib.Tab                     ;
   l_Split_Tab        Std_Lib.Tab                     ;


   l_Msd_Rec_Cnt      NUMBER := 0                     ;
   l_Msp_Rec_Cnt      NUMBER := 0                     ;
   l_Msd_Inst_Rec     NUMBER := 0                     ;
   l_Msd_Updt_Rec     NUMBER := 0                     ;
   l_Msp_Inst_Rec     NUMBER := 0                     ;
   l_Msp_Updt_Rec     NUMBER := 0                     ;
   l_Skip_Rec         NUMBER(10) := 0                 ;
   /*l_Skip_Date        NUMBER(10) := 0                 ;*/
   Skip_Date          EXCEPTION                       ;
   Skip_Rec           EXCEPTION                       ;
   Fail_Process       EXCEPTION                       ;
   o_Sql_Msg          VARCHAR2(2000)                  ;
   l_Sch_From_Dt      DATE                            ;
   l_Isin             VARCHAR2(12)                    ;
   t_Err_Log          Tab_Err_Msg                     ;
   t_Err_Log_Dt       Tab_Err_Msg                     ;
   -- File Fields
   l_Scheme_Id        VARCHAR2(30)                    ;
   l_Plan_Type        VARCHAR2(3)   := 'SIP'          ;
   l_Frequency        VARCHAR2(15)                    ;
   /*l_Period           NUMBER(10)                      ;*/
   l_Dd               VARCHAR2(100)                   ;
   --Handled Sip date like 04|05|06|
   l_Date             NUMBER(2) := 0                  ;
   /*l_Date_Yn          VARCHAR(1) := 'N'               ;*/
   l_Process_Date_Identifier        VARCHAR2(15)      ;
   /*l_Date_Var         VARCHAR2(10)                    ;*/
   l_Skip_First_Rec   NUMBER    := 0                  ;
   l_Count_Dt         NUMBER    := 0                  ;
   l_Dt_Cnt           NUMBER    := 0                  ;
   l_Process_Date     NUMBER    := 1                  ;
   /*l_Instr_Cnt        NUMBER    := 0                  ;
   l_Amc_Code         VARCHAR2(30)                    ;
   l_Amc_Name         VARCHAR2(200)                   ;*/
   l_Scheme_Code      VARCHAR2(30)                    ;
   l_Scheme_Disp_Code VARCHAR2(30)                    ;
   /*l_Scheme_Name      VARCHAR2(200)                   ;
   l_Transaction_Mode VARCHAR2(15)                    ;
   l_Sip_Dates         VARCHAR2(15)                   ;*/
   l_Min_Gap_Period    VARCHAR2(15)                   ;
   l_Max_Gap_Period    VARCHAR2(15)                   ;
   l_Gap_Period        VARCHAR2(15)                   ;
   l_Delete_flag       VARCHAR2(2)                    ;
   l_Min_Inst_Amt      NUMBER(30)                     ;
   l_Max_Inst_Amt      NUMBER(30)                     ;
   l_Multiplier_Amt    NUMBER(30)                     ;
   /*l_Min_Inst_Numbers  NUMBER(30)                     ;
   l_Max_Inst_Numbers  NUMBER(30)                     ;
   l_Record            NUMBER(15)                     ;
   l_Scheme_type       VARCHAR2(15)                   ;*/
   l_exch              VARCHAR2(10):= 'NSE'           ;
   l_Status            VARCHAR2(1)                    ;
   l_Unique_no         VARCHAR2(30)                   ;
   /*l_Sip_Status        VARCHAR2(1)                    ;*/
   l_Freq_Flag         VARCHAR2(1)                    ;
   l_Sip_Min_Tota_Amt  NUMBER(30)                     ;
   l_symbol            varchar2(30)                   ;
   l_Series            varchar2(30)                   ;
   l_days              varchar2(100)                  ;




   PROCEDURE P_Insert_Mfd_Sip_Details
   IS
   BEGIN
     INSERT INTO Mfd_Sip_Details
          (Sid_Scheme_Id,              Sid_Sch_From_Dt,      Sid_Record_Status,           Sid_Status,
           Sid_Plan_Type,              Sid_Frequency,        Sid_Process_Date_Identifier, Sid_Dd,
           -----
           Sid_Mon,                    Sid_Creat_Dt,         Sid_Creat_By,                Sid_Prg_Id,
           Sid_exm_id,                 Sid_Disp_Scheme_Id)
     VALUES
          (l_scheme_code,              l_Sch_From_Dt,        'A',                         'A',
           l_Plan_Type,                l_Frequency,          l_Process_Date_Identifier,   l_Process_Date,
           ------
           NULL,                       SYSDATE,              USER,                        l_Prg_Id,
           l_exch,                     l_Scheme_Disp_Code
          );
   END P_Insert_Mfd_Sip_Details;

  BEGIN
   P_Ret_Val := 'FAIL';
   P_Ret_Msg := 'Performing Housekeeping......';
   Std_Lib.P_Housekeeping(l_Prg_Id                ,
                          'NSE'                   ,
                          'NSE'||'-'||P_File_Name ,
                          'E'                     ,
                          l_Log_File_Ptr          ,
                          l_Log_File_Path         ,
                          l_Process_Id            ,
                          'Y')            ;

   l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date ;
   l_Trace_Level := Std_Lib.l_Debug_Mode    ;

   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Working Date      :-  '||l_Pam_Curr_Dt);
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master File   :-  '||P_File_Name );
   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');

   P_Ret_Msg := ' selecting data file path ';
   SELECT Rv_High_Value
   INTO   l_Data_File_Path
   FROM   Cg_Ref_Codes
   WHERE  Rv_Domain    = 'DATA_FILES'
   AND    Rv_Low_Value = 'CSS_FILES';

   t_Err_log.DELETE;
   t_Err_Log_Dt.DELETE;
   l_File_Tab.DELETE;
   P_Ret_Msg := ' loading the file <'||P_File_Name||'>';
   Std_Lib.Load_File(l_Data_File_Path ,
                     P_File_Name      ,
                     l_Rec_Count      ,
                     l_File_Tab)      ;

   P_Ret_Msg := ' In Main Loop..' ;
   FOR i IN 1..l_File_Tab.COUNT
   LOOP
     IF l_Trace_Level = 'ADMIN' THEN
        Utl_File.Put_Line(l_Log_File_Ptr,'Processing record <'||l_File_Tab(i)||'>');
     END IF;

     -- To Skip Header
     IF l_Rec_No  > 0 THEN
         BEGIN
           l_Split_Tab.DELETE ;
           P_Ret_Msg := ' splitting file data.';
           Std_Lib.Split_line(l_File_Tab(i) ,
                              '|'           ,
                              l_Split_Tab)  ;

           P_Ret_Msg := ' internal Scheme Id Not Found For Unique No '||l_Unique_no;
           l_Unique_no                  := Rtrim(LTrim(TRIM(l_Split_Tab(1)),'"'),'"');
           l_symbol                     := Rtrim(LTrim(TRIM(l_Split_Tab(2)),'"'),'"');
           l_Series                     := Rtrim(LTrim(TRIM(l_Split_Tab(3)),'"'),'"');
           l_Frequency                  := Rtrim(LTrim(TRIM(l_Split_Tab(4)),'"'),'"');
           l_Freq_Flag                  := Rtrim(LTrim(TRIM(l_Split_Tab(5)),'"'),'"');
          -- l_Gap_Period                 := Rtrim(LTrim(TRIM(l_Split_Tab(6)),'"'),'"');
           l_Days                       := Rtrim(LTrim(TRIM(l_Split_Tab(8)),'"'),'"');
           l_Min_Inst_Amt               := Rtrim(LTrim(TRIM(l_Split_Tab(10)),'"'),'"');
           l_Max_Inst_Amt               := Rtrim(LTrim(TRIM(l_Split_Tab(11)),'"'),'"');
           l_Multiplier_Amt             := Rtrim(LTrim(TRIM(l_Split_Tab(12)),'"'),'"');
           l_Sip_Min_Tota_Amt           := Rtrim(LTrim(TRIM(l_Split_Tab(13)),'"'),'"');
           l_Delete_flag                := Rtrim(LTrim(TRIM(Replace(l_Split_Tab(15),chr(13),'')),'"'),'"');
           BEGIN
             SELECT Msm_From_Date, Msm_Isin,MSm_Scheme_id
             INTO   l_Sch_From_Dt, l_Isin  ,l_Scheme_Code
             FROM   Mfd_Scheme_Master m
             WHERE  Msm_Nse_Unique_No = l_Unique_no
             AND    l_Pam_Curr_Dt Between m.Msm_From_Date AND Nvl(m.Msm_To_Date,l_Pam_Curr_Dt)
             AND    m.Msm_Status        = 'A'
             AND    m.Msm_Record_Status = 'A';

             l_Scheme_Disp_Code := l_Scheme_Code;
           EXCEPTION
             WHEN  Too_Many_Rows THEN
                   P_Ret_Msg := ' There are more than one record for unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>For Record no.<'||l_Rec_No||'>'  ;

             WHEN No_Data_Found THEN
              BEGIN
                  SELECT Msm_From_Date, Msm_Isin,MSm_Scheme_id
                  INTO   l_Sch_From_Dt, l_Isin  ,l_Scheme_Code
                  FROM   Mfd_Scheme_Master m
                  WHERE  m.Msm_Nse_Lo_Unique_No = l_Unique_no
                  AND    l_Pam_Curr_Dt Between m.Msm_From_Date AND Nvl(m.Msm_To_Date,l_Pam_Curr_Dt)
                  AND    m.Msm_Status        = 'A'
                  AND    m.Msm_Record_Status = 'A';

                  l_Scheme_Disp_Code := l_Scheme_Code||'L0';
              EXCEPTION
                 WHEN  Too_Many_Rows THEN
                       P_Ret_Msg := ' There are more than one record for unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>For Record no.<'||l_Rec_No||'>'  ;

                 WHEN No_Data_Found THEN
                    BEGIN
                        SELECT Msm_From_Date, Msm_Isin,MSm_Scheme_id
                        INTO   l_Sch_From_Dt, l_Isin  ,l_Scheme_Code
                        FROM   Mfd_Scheme_Master m
                        WHERE  Msm_Nse_L1_Unique_No = l_Unique_no
                        AND    l_Pam_Curr_Dt Between m.Msm_From_Date AND Nvl(m.Msm_To_Date,l_Pam_Curr_Dt)
                        AND    m.Msm_Status        = 'A'
                        AND    m.Msm_Record_Status = 'A';

                        l_Scheme_Disp_Code := l_Scheme_Code||'L1';
                     EXCEPTION
                       WHEN No_Data_Found THEN
                       RAISE Skip_Rec ;
                       WHEN  Too_Many_Rows THEN
                             P_Ret_Msg := ' There are more than one record for line no.<'||l_Rec_No||'> with Scheme Code <'||l_Scheme_Code||'> For unique No.<'||l_Unique_no||'>';

                     END;
               END;
             END;

           IF l_Frequency IS NULL THEN
              P_Ret_Msg := 'Frequency is mandatory For Record no.<'||l_Rec_No||'>unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>'  ;
              RAISE Fail_Process;
           END IF;

           IF l_Days IS NULL THEN
              P_Ret_Msg := 'Date is mandatory for For Record no.<'||l_Rec_No||'>unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>' ;
              RAISE Fail_Process;
           END IF;

           Select decode(l_Frequency,'1','W','2','M','3','Q','4','S','5','A','A')
           into l_Frequency
           from dual;


           SELECT LENGTH(l_days) -
                  LENGTH(REPLACE(l_days, '1', ''))
           Into l_Dd
           FROM dual;

           IF l_days = '1111111111111111111111111111111' THEN
              l_Dd := 31;
           END IF;

           /*IF Nvl(l_Min_Inst_Amt,0) <= 0 THEN
                 P_Ret_Msg := 'Minimum amount should be greater than Zero for <'||l_Scheme_Code||'>';
                 RAISE Fail_Process;
           END IF;

           IF Nvl(l_Max_Inst_Amt,0) < Nvl(l_Min_Inst_Amt,0) THEN
                 P_Ret_Msg := 'Maximum amount should be greater than Minimum Amount for <'||l_Scheme_Code||'>';
                 RAISE Fail_Process;
           END IF;*/

           IF l_Delete_flag = 'N' THEN
              l_status := 'A';
           ELSE
              l_status := 'I';
           END IF;


             /* P_Ret_Msg := ' Updating Sip in Mfd scheme master for scheme id <'|| l_Scheme_Id ||'> and Isin <'|| l_Isin ||'>';
              UPDATE Mfd_Scheme_Master
              SET    msm_nse_sip_allowed = 'Y'
              WHERE  Msm_Scheme_Id     = l_Scheme_Code
              AND    Msm_Isin          = l_Isin
              AND    Msm_Record_Status = 'A'
              AND    Msm_Status        = 'A';*/
           l_Min_Inst_Amt     := (To_Number(l_Min_Inst_Amt)/100);
           l_Max_Inst_Amt     := (To_Number(l_Max_Inst_Amt)/100);
           l_Sip_Min_Tota_Amt := (To_Number(l_Sip_Min_Tota_Amt)/100);
           l_Min_Gap_Period   :=  l_Sip_Min_Tota_Amt/l_Min_Inst_Amt;

           Select decode(l_Frequency,'W','520','M','120','Q','40','S','20','A','10',10)
           into l_Max_Gap_Period
           from dual;

           BEGIN
             P_Ret_Msg := ' inserting into systematic plan for unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>For Record no.<'||l_Rec_No||'>'  ;
             INSERT INTO Mfd_Systematic_Plan
                   ( Msp_Scheme_Id,          Msp_Plan_Type,       Msp_Frequency,            Msp_Min_Amt,
                     Msp_Amt_Multiple,       Msp_Sch_From_Dt,     Msp_Status,               Msp_Record_Status,
                     -------
                     Msp_Period,             Msp_Min_Period,      Msp_Max_Period,           Msp_Max_Amt,

                     Msp_Creat_Dt,           Msp_Creat_By,        Msp_Prg_Id,               Msp_Isin,
                     Msp_Exchange,           Msp_Disp_Scheme_Id,  Msp_min_Tot_amt
                    )
             VALUES
                   ( l_Scheme_Code,          l_Plan_Type ,        l_Frequency,              l_Min_Inst_Amt,
                     l_Multiplier_Amt,       l_Sch_From_Dt,       l_status ,                      'A',
                     --------
                     l_Gap_Period,           l_Min_Gap_Period,    l_Max_Gap_Period,         l_Max_Inst_Amt,

                     SYSDATE,                USER,                l_Prg_Id,                 l_Isin,
                     l_Exch ,                l_Scheme_Disp_Code , l_Sip_Min_Tota_Amt
                   );

             l_Msp_Inst_Rec := l_Msp_Inst_Rec + 1;

             l_Skip_First_Rec  := 0;
             l_Count_Dt        := 0;
             l_Date            := 0;
             l_Dt_Cnt          := 0;
             l_Process_Date    := 1;
          FOR i in 1 .. l_Dd
          LOOP

          select instr(l_days,'1','1',i)
          into l_Process_Date
          from dual  ;
         -- l_Process_Date            := l_Process_Date + 1;
          l_Process_Date_Identifier := 'Date ' || l_Process_Date;
          BEGIN

          P_Ret_Msg := ' inserting into mfd sip details For Record no.<'||l_Rec_No||'>unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>';
          P_Insert_Mfd_Sip_Details;
          l_Msd_Inst_Rec := l_Msd_Inst_Rec + 1;
          END;
          END LOOP;

           EXCEPTION
              WHEN Dup_Val_On_Index THEN

                 SELECT COUNT(1)
                 INTO   l_Msp_Rec_Cnt
                 FROM   Mfd_Systematic_Plan
                 WHERE  Msp_Scheme_Id      = l_Scheme_Code
                 AND    Msp_Sch_From_Dt    = l_Sch_From_Dt
                 AND    Msp_Plan_Type      = l_Plan_Type
                 AND    Msp_Frequency      = l_Frequency
                 AND    Msp_Disp_Scheme_Id = l_Scheme_Disp_Code
                 AND    Msp_Record_Status  = 'A'
                 AND    Msp_Exchange       = 'NSE'
                 AND    Msp_Status         = 'A';

                 IF l_Msp_Rec_Cnt > 0 THEN
                     l_Msp_Updt_Rec := l_Msp_Updt_Rec + 1;
                     UPDATE Mfd_Systematic_Plan
                     SET    Msp_Min_Amt        =  l_Min_Inst_Amt,
                            Msp_Max_Amt        =  l_Max_Inst_Amt,
                            Msp_Amt_Multiple   =  l_Multiplier_Amt,
                            Msp_Min_Period     =  l_Min_Gap_Period,
                            Msp_Max_Period     =  l_Max_Gap_Period,
                            Msp_Period         =  l_Gap_Period,
                            Msp_Last_Upt_Dt    =  SYSDATE,
                            Msp_Last_Upt_By    =  USER,
                            Msp_Prg_Id         =  l_Prg_Id
                     WHERE  Msp_Scheme_Id      =  l_Scheme_Code
                     AND    Msp_Sch_From_Dt    =  l_Sch_From_Dt
                     AND    Msp_Plan_Type      =  l_Plan_Type
                     AND    Msp_Frequency      =  l_Frequency
                     AND    Msp_Disp_Scheme_Id = l_Scheme_Disp_Code
                     AND    Msp_Record_Status  = 'A'
                     AND    Msp_Exchange       = 'NSE'
                     AND    Msp_Status         = 'A';

               END IF;
             l_Skip_First_Rec  := 0;
             l_Count_Dt        := 0;
             l_Date            := 0;
             l_Dt_Cnt          := 0;
             l_Process_Date    := 1;
          FOR i in 1 .. l_Dd
          LOOP

          select instr(l_days,'1','1',i)
          into l_Process_Date
          from dual  ;
         -- l_Process_Date            := l_Process_Date + 1;
          l_Process_Date_Identifier := 'Date ' || l_Process_Date;
          BEGIN

          P_Ret_Msg := ' inserting into mfd sip details For Record no.<'||l_Rec_No||'>unique no<'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency.<'||l_Frequency||'>';
          P_Insert_Mfd_Sip_Details;
          l_Msd_Inst_Rec := l_Msd_Inst_Rec + 1    ;
          EXCEPTION
                     WHEN Dup_Val_On_Index THEN
                          ---- This scenario will never come as as i m deleting all datas
                           SELECT COUNT(1)
                           INTO  l_Msd_Rec_Cnt
                           FROM  Mfd_Sip_Details s
                           WHERE s.Sid_Scheme_Id               = l_Scheme_Code
                           AND   s.Sid_Sch_From_Dt             = l_Sch_From_Dt
                           AND   s.Sid_Plan_Type               = l_Plan_Type
                           AND   s.Sid_Disp_Scheme_Id           = l_Scheme_Disp_Code
                           AND   s.Sid_Frequency               = l_Frequency
                           AND   s.Sid_Process_Date_Identifier = l_Process_Date_Identifier
                           AND   s.Sid_Status                  = 'A'
                           AND   s.sid_exm_id                  = 'NSE'
                           AND   s.Sid_Record_Status           = 'A';

                           IF l_Msd_Rec_Cnt > 0 THEN

                              l_Msd_Updt_Rec := l_Msd_Updt_Rec + 1;

                              UPDATE Mfd_Sip_Details
                              SET    Sid_dd                      = l_Process_Date,
                                     Sid_Last_Upt_Dt             = SYSDATE,
                                     Sid_Last_Upt_By             = USER,
                                     Sid_Prg_Id                  = l_Prg_Id
                              WHERE  Sid_Scheme_Id               = l_Scheme_Code
                              AND    Sid_Sch_From_Dt             = l_Sch_From_Dt
                              AND    Sid_Disp_Scheme_Id          = l_Scheme_Disp_Code
                              AND    Sid_Plan_Type               = l_Plan_Type
                              AND    Sid_Frequency               = l_Frequency
                              AND    Sid_Process_Date_Identifier = l_Process_Date_Identifier
                              AND    Sid_Status                  = 'A'
                              AND    sid_exm_id                  = 'NSE'
                              AND    Sid_Record_Status           = 'A';

                           ELSE
                              P_Ret_Msg := ' Record already present in Sip details for Process Date Identifier<'||l_Process_Date_Identifier||'>For Record no.<'||l_Scheme_Code||'>';
                              RAISE Fail_Process;
                           END IF;

                   WHEN OTHERS THEN
                          RAISE Fail_Process;
                    END;
                 END LOOP;
              WHEN OTHERS THEN
                RAISE Fail_Process;
              END;
         EXCEPTION
            WHEN Skip_Rec THEN
            l_Skip_Rec := l_Skip_Rec + 1;
            t_Err_Log(l_Skip_Rec) := 'Internal Scheme Id Not Found For Scheme Code <'||l_Scheme_Id||'>for unique no <'||l_Unique_no||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>For Record no.<'||l_Rec_No||'>'   ;
            WHEN  Too_Many_Rows THEN
            P_Ret_Msg := ' There are more than one record for line no.<'||l_Rec_No||'> with Scheme Code <'||l_Scheme_Code||'> For unique no .<'||l_Unique_no||'>';

         END;
     END IF;
     l_Rec_No := l_Rec_No + 1;
   END LOOP;

   l_Rec_Count    := l_Rec_Count -1 ;
   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master upload summary              ');
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records in the file :'||l_Rec_Count);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Inserted    :'||l_Msp_Inst_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Updated     :'||l_Msp_Updt_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Skipped     :'||l_Skip_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.New_Line(l_Log_File_Ptr,1);
   IF t_Err_log.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_log(t));
      END LOOP;
   END IF;
   IF t_Err_Log_Dt.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_Log_Dt(t));
      END LOOP;
   END IF;


   Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                           l_Pam_Curr_Dt  ,
                           l_Process_Id   ,
                           'C'            ,
                           'Y'            ,
                           o_Sql_Msg)     ;

   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'Process Completed Successfully.');
   Utl_File.Fclose(l_Log_File_Ptr);

   P_Ret_Val := 'SUCCESS';
   P_Ret_Msg := 'Process Completed Successfully';

   EXCEPTION
      WHEN Fail_Process THEN
         ROLLBACK;
         P_Ret_Val := 'FAIL';
         P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
         Utl_File.New_Line(l_Log_File_Ptr,2);
         Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
         Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
         Utl_File.Fclose(l_Log_File_Ptr);
         Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;

      WHEN OTHERS THEN
        ROLLBACK;
        P_Ret_Val := 'FAIL';
        P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
        Utl_File.New_Line(l_Log_File_Ptr,2);
        Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
        Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
        Utl_File.Fclose(l_Log_File_Ptr);
        Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;

   END P_Mfd_Load_Sip_Master_File;


PROCEDURE P_Mfd_Load_Sip_Master_Fil_BSE(P_File_Name  IN  VARCHAR2,
                                           P_Ret_Val    OUT VARCHAR2,
                                           P_Ret_Msg    OUT VARCHAR2)
  IS

   l_Prg_Id           VARCHAR2(10) := 'MFSIPNSE'      ;
   l_Log_File_Ptr     Utl_File.File_Type              ;
   l_Log_File_Path    VARCHAR2(300)                   ;
   l_Process_Id       NUMBER(10)                      ;
   l_Pam_Curr_Dt      DATE                            ;
   l_Trace_Level      VARCHAR2(30)                    ;
   l_Data_File_Path   VARCHAR2(300)                   ;
   l_Rec_Count        NUMBER(10) := 0                 ;
   l_Rec_No           NUMBER := 0                     ;
   l_File_Tab         Std_Lib.Tab                     ;
   l_Split_Tab        Std_Lib.Tab                     ;
   l_Dt_Tab           Std_Lib.Tab                     ;

   l_Msd_Rec_Cnt      NUMBER := 0                     ;
   l_Msp_Rec_Cnt      NUMBER := 0                     ;
   l_Msd_Inst_Rec     NUMBER := 0                     ;
   l_Msd_Updt_Rec     NUMBER := 0                     ;
   l_Msp_Inst_Rec     NUMBER := 0                     ;
   l_Msp_Updt_Rec     NUMBER := 0                     ;
   l_Skip_Rec         NUMBER(10) := 0                 ;
   l_Skip_Date        NUMBER(10) := 0                 ;
   Skip_Date          EXCEPTION                       ;
   Skip_Rec           EXCEPTION                       ;
   Fail_Process       EXCEPTION                       ;
   o_Sql_Msg          VARCHAR2(2000)                  ;
   l_Sch_From_Dt      DATE                            ;
   l_Isin             VARCHAR2(12)                    ;
   t_Err_Log          Tab_Err_Msg                     ;
   t_Err_Log_Dt       Tab_Err_Msg                     ;
   -- File Fields
   l_Scheme_Id        VARCHAR2(30)                    ;
   l_Plan_Type        VARCHAR2(3)   := 'SIP'          ;
   l_Frequency        VARCHAR2(15)                    ;
   l_Period           NUMBER(10)                      ;
   l_Dd               VARCHAR2(100)                   ;
   --Handled Sip date like 04|05|06|
   l_Date             NUMBER(2) := 0                  ;
   l_Date_Yn          VARCHAR(1) := 'N'               ;
   l_Process_Date_Identifier        VARCHAR2(15)      ;
   l_Date_Var         VARCHAR2(10)                    ;
   l_Skip_First_Rec   NUMBER    := 0                  ;
   l_Count_Dt         NUMBER    := 0                  ;
   l_Dt_Cnt           NUMBER    := 0                  ;
   l_Process_Date     NUMBER    := 1                  ;
   l_Instr_Cnt        NUMBER    := 0                  ;
   l_Amc_Code         VARCHAR2(50)                    ; --29/06/2021 size change to 50(for mahindra scheme)
   l_Amc_Name         VARCHAR2(200)                   ;
   l_Scheme_Code      VARCHAR2(30)                    ;
   l_internal_Scheme_Code         VARCHAR2(30)        ;
   l_Scheme_Name      VARCHAR2(200)                   ;
   l_Transaction_Mode VARCHAR2(15)                    ;
   l_Sip_Dates         VARCHAR2(15)                   ;
   l_Min_Gap_Period    VARCHAR2(15)                   ;
   l_Max_Gap_Period    VARCHAR2(15)                   ;
   l_Gap_Period        VARCHAR2(15)                   ;
   l_Sip_Status        NUMBER(1):= 0                  ;
   l_Min_Inst_Amt      NUMBER(30)                     ;
   l_Max_Inst_Amt      NUMBER(30) := 0                ;
   l_Multiplier_Amt    NUMBER(30) := 0                ;
   l_Min_Inst_Numbers  NUMBER(30) := 0                ;
   l_Max_Inst_Numbers  NUMBER(30) := 0                ;
   l_Scheme_type       VARCHAR2(15)                   ;
   l_exch              VARCHAR2(10):= 'BSE'           ;
   l_Status            VARCHAR2(1)                    ;
   l_Disp_Scheme_code  VARCHAR2(30)                   ;
   l_status_old        VARCHAR2(1)                    ;
   l_flag              VARCHAR2(1)                    ;
   l_SIP_flg           VARCHAR2(20)                   ;
   l_SIP_Dtl_Flg       VARCHAR2(20)                   ;
   l_Old_SID_Status    VARCHAR2(1)                    ;
   l_Curr_Index        VARCHAR2(1000)                 ;
   l_Prev_Index        VARCHAR2(1000)                 ;
   L_DAYS              VARCHAR2(100)                  ;
   l_rec_cntr          NUMBER                         ;
   l_test              varchar2(100)                  ;
   l_Sip_Count         NUMBER(5)                      ;
   SIP_EXISTS          EXCEPTION                      ;
   l_Pause_flg         VARCHAR2(1)                    ;
   l_Pause_Min_Inst    VARCHAR2(30)                   ;
   l_Pause_Max_Inst    VARCHAR2(30)                   ;
   l_FILLER_1          VARCHAR2(100)                  ;
   l_FILLER_2          VARCHAR2(100)                  ;
   l_FILLER_3          VARCHAR2(100)                  ;
   l_FILLER_4          VARCHAR2(100)                  ;
   l_FILLER_5          VARCHAR2(100)                  ;


  BEGIN
   P_Ret_Val := 'FAIL';
   P_Ret_Msg := 'Performing Housekeeping......';
   Std_Lib.P_Housekeeping(l_Prg_Id                     ,
                          'BSE'                        ,
                          'BSE'||'-'||P_File_Name     ,
                          'E'                         ,
                          l_Log_File_Ptr              ,
                          l_Log_File_Path             ,
                          l_Process_Id                ,
                          'Y') ;

   l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date ;
   l_Trace_Level := Std_Lib.l_Debug_Mode    ;

   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Working Date      :-  '||l_Pam_Curr_Dt);
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master File   :-  '||P_File_Name );
   Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------');

   P_Ret_Msg := ' selecting data file path ';
   SELECT Rv_High_Value
   INTO   l_Data_File_Path
   FROM   Cg_Ref_Codes
   WHERE  Rv_Domain    = 'DATA_FILES'
   AND    Rv_Low_Value = 'CSS_FILES';

   t_Err_log.DELETE;
   t_Err_Log_Dt.DELETE;
   l_File_Tab.DELETE;
   P_Ret_Msg := ' loading the file <'||P_File_Name||'>';
   Std_Lib.Load_File(l_Data_File_Path ,
                     P_File_Name      ,
                     l_Rec_Count      ,
                     l_File_Tab)      ;

   P_Ret_Msg := ' In Main Loop..' ;
   l_Prev_Index := '~';
   FOR i IN 1..l_File_Tab.COUNT
   LOOP
     IF l_Trace_Level = 'ADMIN' THEN
        Utl_File.Put_Line(l_Log_File_Ptr,'Processing record <'||l_File_Tab(i)||'>');
     END IF;

     -- To Skip Header
     IF l_Rec_No  > 0 THEN
         BEGIN
           l_Split_Tab.DELETE ;
           P_Ret_Msg := ' splitting file data, at record no -' || l_rec_no;
           Std_Lib.Split_line(l_File_Tab(i) ,
                              '|'           ,
                              l_Split_Tab)  ;


           P_Ret_Msg := ' reading row data from file';


           l_Amc_Code                   := Rtrim(LTrim(TRIM(l_Split_Tab(1)),'"'),'"');
           l_Amc_Name                   := Rtrim(LTrim(TRIM(l_Split_Tab(2)),'"'),'"');
           l_internal_Scheme_Code       := Rtrim(LTrim(TRIM(l_Split_Tab(3)),'"'),'"');
           l_Scheme_Name                := Rtrim(LTrim(TRIM(l_Split_Tab(4)),'"'),'"');
           l_Transaction_Mode           := Rtrim(LTrim(TRIM(l_Split_Tab(5)),'"'),'"');
           l_Frequency                  := Rtrim(LTrim(TRIM(l_Split_Tab(6)),'"'),'"');
           l_Dd                         := Rtrim(LTrim(TRIM(l_Split_Tab(7)),'"'),'"');
           l_Min_Gap_Period             := Rtrim(LTrim(TRIM(l_Split_Tab(8)),'"'),'"');
           l_Max_Gap_Period             := Rtrim(LTrim(TRIM(l_Split_Tab(9)),'"'),'"');
           l_Gap_Period                 := Rtrim(LTrim(TRIM(l_Split_Tab(10)),'"'),'"');
           l_Sip_Status                 := Rtrim(LTrim(TRIM(l_Split_Tab(11)),'"'),'"');
           l_Min_Inst_Amt               := Rtrim(LTrim(TRIM(l_Split_Tab(12)),'"'),'"');
           l_Max_Inst_Amt               := Rtrim(LTrim(TRIM(l_Split_Tab(13)),'"'),'"');
           l_Multiplier_Amt             := Rtrim(LTrim(TRIM(l_Split_Tab(14)),'"'),'"');
           l_Min_Inst_Numbers           := Rtrim(LTrim(TRIM(l_Split_Tab(15)),'"'),'"');
           l_Max_Inst_Numbers           := Rtrim(LTrim(TRIM(l_Split_Tab(16)),'"'),'"');
           l_Isin                       := Rtrim(LTrim(TRIM(l_Split_Tab(17)),'"'),'"');
           l_Scheme_type                := Rtrim(LTrim(TRIM(l_Split_Tab(18)),'"'),'"');
       l_Pause_flg                  := Rtrim(LTrim(TRIM(l_Split_Tab(19)),'"'),'"');
           l_Pause_Min_Inst             := Rtrim(LTrim(TRIM(l_Split_Tab(20)),'"'),'"');
           l_Pause_Max_Inst             := Rtrim(LTrim(TRIM(l_Split_Tab(21)),'"'),'"');
           l_FILLER_1                   := Rtrim(LTrim(TRIM(l_Split_Tab(22)),'"'),'"');
           l_FILLER_2                   := Rtrim(LTrim(TRIM(l_Split_Tab(23)),'"'),'"');
           l_FILLER_3                   := Rtrim(LTrim(TRIM(l_Split_Tab(24)),'"'),'"');
           l_FILLER_4                   := Rtrim(LTrim(TRIM(l_Split_Tab(25)),'"'),'"');
           l_FILLER_5                   := Rtrim(LTrim(TRIM(l_Split_Tab(26)),'"'),'"');
           l_flag                       := NULL;
           l_Msp_Rec_Cnt                := 0;
           l_Frequency                  := Substr(l_Frequency,1,1);
           l_status_old                 := NULL;

        P_Ret_Msg := ' fetching scheme details for ISIN:'||l_Isin;
           BEGIN

                   SELECT Msm_Scheme_Id, Msm_From_Date
                   INTO   l_Scheme_Code,l_Sch_From_Dt
                   FROM   Mfd_Scheme_Master m
                   WHERE  Msm_Isin      = l_Isin
                   AND    l_Pam_Curr_Dt Between m.Msm_From_Date AND Nvl(m.Msm_To_Date,l_Pam_Curr_Dt)
                   AND    M.Msm_Status        = 'A'
                   AND    m.Msm_Record_Status = 'A';



                   IF    l_internal_Scheme_Code LIKE '%L0'  THEN
                         l_Disp_Scheme_code := l_Scheme_Code||'L0';

                   ELSIF l_internal_Scheme_Code  LIKE '%L1' THEN
                         l_Disp_Scheme_code := l_Scheme_Code||'L1';
                   ELSE
                         l_Disp_Scheme_code := l_Scheme_Code;
                   END IF;

           EXCEPTION
             WHEN No_Data_Found THEN
                  P_Ret_Msg := 'Internal Scheme Id Not Found For Record No.<'|| l_rec_no||'> scheme code <'||l_Scheme_Code||'> isin<'||l_isin||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
                RAISE Skip_Rec;
             WHEN  Too_Many_Rows THEN
                 P_Ret_Msg := 'There are more than one record For Record no.<'||l_Rec_No||'> scheme code <'||l_Scheme_Code||'> plan type <'||l_Plan_Type||'> and frequency <'||l_Frequency||'>' ;
           END;


        P_Ret_Msg := 'Initializing varaibles';
        IF l_Sip_Status = 1 THEN
          l_status := 'A';
        ELSE
          l_status := 'I';
           END IF;

        l_SIP_flg      := NULL;
        l_SIP_Dtl_flg  := NULL;
        --ps
        IF l_Dd IS NULL THEN
            P_Ret_Msg := 'Date is blank For Record No.<'|| l_rec_no||'> scheme<'||l_Scheme_Code||'> isin<'||l_isin||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
            RAISE Skip_Rec;
        ELSE
            Std_Lib.Split_line(l_dd,
                               ',',
                               l_Dt_Tab);
        END IF;

        l_rec_cntr := l_Dt_Tab.COUNT;
       /* l_Process_Date    := 1;

        SELECT LENGTH(L_DD) - LENGTH(REPLACE(L_DD, '1', ''))
          INTO L_DAYS
          FROM DUAL;

        IF L_DD = '1111111111111111111111111111111' THEN
          L_DAYS := 31;
        END IF;*/

        FOR i in 1..l_rec_cntr
          LOOP
         /* SELECT INSTR(L_DD, '1', '1', I) INTO L_PROCESS_DATE FROM DUAL;*/
          L_PROCESS_DATE := TRIM(l_Dt_Tab(i));
          L_PROCESS_DATE_IDENTIFIER := 'Date ' || L_PROCESS_DATE;

        --pe

        --l_Process_Date_Identifier := 'Date ' || Nvl(l_Dd, '0');
        l_Curr_Index   := l_Scheme_Code||l_Sch_From_Dt||l_Plan_Type||l_Frequency||l_Disp_Scheme_code || l_Process_Date_Identifier;

        P_Ret_Msg := 'Checking if SIP detail already exists or not for scheme<'||l_Scheme_Code||'> isin<'||l_isin||'> and Record no.<'||l_Rec_No||'>' ;
        SELECT Count(1), Max(Sid_Status)
        INTO   l_Msd_Rec_Cnt, l_Old_SID_Status
        FROM   Mfd_Sip_Details
        WHERE  Sid_Scheme_Id               = l_Scheme_Code
        AND    Sid_Sch_From_Dt             = l_Sch_From_Dt
        AND    Sid_Plan_Type               = l_Plan_Type
        AND    Sid_Frequency               = l_Frequency
        AND    Sid_Disp_Scheme_Id          = l_Disp_Scheme_code
        AND    Sid_Process_Date_Identifier = l_Process_Date_Identifier
        AND    Sid_Exm_Id                  = 'BSE'
        AND    Sid_Record_Status           = 'A';

        P_Ret_Msg := 'Setting record status for SIP details for scheme<'||l_Scheme_Code||'> isin<'||l_isin||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>for Record No.<'|| l_rec_no||'>';
        IF l_Msd_Rec_Cnt = 0 AND l_status = 'A' THEN
          l_SIP_Dtl_flg := 'INSERT';
        ELSIF l_Msd_Rec_Cnt = 0 AND l_status = 'I' THEN
          l_SIP_Dtl_flg := 'SKIP';
        ELSIF l_Msd_Rec_Cnt > 0 AND l_status = 'A' THEN
          l_SIP_Dtl_flg := 'UPDATE';
        ELSIF l_Msd_Rec_Cnt > 0 AND l_status = 'I' AND l_Old_SID_Status = 'I' THEN
          l_SIP_Dtl_flg := 'SKIP';
        ELSIF l_Msd_Rec_Cnt > 0 AND l_status = 'I' AND l_Old_SID_Status = 'A' THEN
          l_SIP_Dtl_flg := 'STATUS_UPDATE';
        ELSE
          l_SIP_Dtl_flg := 'SKIP';
        END IF;

        P_Ret_Msg := 'Setting record status for SIP master for scheme<'||l_Scheme_Code||'> and isin<'||l_isin||'>';
        IF l_status = 'A' AND l_SIP_Dtl_flg NOT IN ('SKIP', 'STATUS_UPDATE') THEN
          IF l_Prev_Index <> l_Curr_Index THEN
            IF l_Msd_Rec_Cnt = 0 THEN
              P_Ret_Msg := 'Checking if SIP master already exists or not for scheme<'||l_Scheme_Code||'> isin<'||l_isin||'>and Record No.<'|| l_rec_no||'>';
              SELECT COUNT(1)
              INTO  l_Msp_Rec_Cnt
              FROM  Mfd_Systematic_Plan T
              WHERE Msp_Scheme_Id      = l_Scheme_Code
              AND   Msp_Sch_From_Dt    = l_Sch_From_Dt
              AND   Msp_Plan_Type      = l_Plan_Type
              AND   Msp_Frequency      = l_Frequency
              AND   Msp_Disp_Scheme_Id = l_Disp_Scheme_code
              AND   Msp_Exchange       = 'BSE'
              AND   Msp_Record_Status  = 'A';
            ELSE
              --since record exists in detail assume that record exists in master too
              l_Msp_Rec_Cnt := 1;
            ENd IF;

            IF l_Msp_Rec_Cnt > 0 THEN
              l_SIP_flg := 'UPDATE';
            ELSE
              l_SIP_flg := 'INSERT';
            END IF;
          END IF;

          l_Prev_Index := l_Curr_Index;
        END If;

        IF l_SIP_Dtl_flg NOT IN ('SKIP', 'STATUS_UPDATE') THEN
          --Validation starts here
          IF l_Frequency IS NULL THEN
            P_Ret_Msg := 'Frequency is mandatory For Record No.<'|| l_rec_no||'> scheme<'||l_Scheme_Code||'> isin<'||l_isin||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
            RAISE Fail_Process;
          END IF;



          ELSIF l_SIP_Dtl_flg = 'SKIP' THEN
              P_Ret_Msg := 'Status is inactive For Record No.<'|| l_rec_no||'> scheme<'||l_Scheme_Code||'> isin<'||l_isin||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';
          RAISE Skip_Rec;

           END IF;


           --INSERT/UPDATE begin for Mfd_Sip_Details
        IF l_SIP_Dtl_flg = 'STATUS_UPDATE' THEN
          P_Ret_Msg := 'Status update in Mfd_Sip_Details. Internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>for Record No.<'|| l_rec_no||'>';
          UPDATE Mfd_Sip_Details
             SET Sid_Status                  = l_status,
                 Sid_Last_Upt_Dt             = SYSDATE,
                 Sid_Last_Upt_By             = USER,
                 Sid_Prg_Id                  = l_Prg_Id
           WHERE Sid_Scheme_Id               = l_Scheme_Code
             AND Sid_Sch_From_Dt             = l_Sch_From_Dt
             AND Sid_Plan_Type               = l_Plan_Type
             AND Sid_Frequency               = l_Frequency
             AND Sid_Disp_Scheme_Id          = l_Disp_Scheme_code
             AND Sid_Process_Date_Identifier = l_Process_Date_Identifier
             AND Sid_Record_Status           = 'A'
             AND Sid_Exm_Id                  = 'BSE'
             AND Sid_Status                  = l_Old_SID_Status;

          l_Msp_Updt_Rec := l_Msp_Updt_Rec +1;

        ELSIF l_SIP_Dtl_flg = 'UPDATE' THEN
      BEGIN
          P_Ret_Msg := 'Overall update in Mfd_Sip_Details. Internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>for Record No.<'|| l_rec_no||'>';
          UPDATE  Mfd_Sip_Details
            SET   Sid_dd                      = L_PROCESS_DATE,
                  Sid_Status                  = l_status,
                  Sid_Last_Upt_Dt             = SYSDATE,
                  Sid_Last_Upt_By             = USER,
                  Sid_Prg_Id                  = l_Prg_Id
            WHERE Sid_Scheme_Id               = l_Scheme_Code
            AND   Sid_Sch_From_Dt             = l_Sch_From_Dt
            AND   Sid_Plan_Type               = l_Plan_Type
            AND   Sid_Frequency               = l_Frequency
            AND   Sid_Disp_Scheme_Id          = l_Disp_Scheme_code
            AND   Sid_Process_Date_Identifier = l_Process_Date_Identifier
            AND   Sid_Record_Status           = 'A'
            AND   Sid_Exm_Id                  = 'BSE'
            AND Sid_Status                    = l_Old_SID_Status;
      EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
             Raise SIP_EXISTS;
          END;
         l_Msp_Updt_Rec := l_Msp_Updt_Rec +1;
        ELSIF l_SIP_Dtl_flg = 'INSERT' THEN
          P_Ret_Msg := 'Insert in Mfd_Sip_Details. Internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>for Record No.<'|| l_rec_no||'>  ' || l_Scheme_Code||l_Sch_From_Dt||l_Plan_Type||l_Frequency||l_Disp_Scheme_code || l_Process_Date_Identifier;
          
          BEGIN
            
          INSERT INTO Mfd_Sip_Details
               (Sid_Scheme_Id,              Sid_Sch_From_Dt,      Sid_Record_Status,           Sid_Status,
                Sid_Plan_Type,              Sid_Frequency,        Sid_Process_Date_Identifier, Sid_Dd,
                -----
                Sid_Mon,                    Sid_Creat_Dt,         Sid_Creat_By,                Sid_Prg_Id,
                Sid_exm_id,                 Sid_Disp_Scheme_Id
                 )
          VALUES
               (l_Scheme_Code,               l_Sch_From_Dt,        'A',                         'A',
                l_Plan_Type,                 Substr(l_Frequency,1,1)  ,        l_Process_Date_Identifier,   L_PROCESS_DATE,
                ------
                NULL,                       SYSDATE,              USER,                        l_Prg_Id,
                l_exch,                     l_Disp_Scheme_code
               );
           l_Msd_Inst_Rec := l_Msd_Inst_Rec +1;
           
           EXCEPTION
             
           WHEN OTHERS THEN
                  NULL; 
           
           END;
        END IF;

        --INSERT/UPDATE begin for Mfd_Systematic_Plan
        IF l_SIP_flg = 'INSERT' THEN
          P_Ret_Msg := 'Insert in Mfd_Systematic_Plan. For Record No.<'|| l_rec_no||'>Internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';


           /*BEGIN
             P_Ret_Msg := ' inserting into systematic plan for internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>for Record No.<'|| l_rec_no||'>';*/

             BEGIN
               
             INSERT INTO Mfd_Systematic_Plan
                   ( Msp_Scheme_Id,          Msp_Plan_Type,       Msp_Frequency,            Msp_Min_Amt,
                     Msp_Amt_Multiple,       Msp_Sch_From_Dt,     Msp_Status,               Msp_Record_Status,
                     -------
                     Msp_Period,             Msp_Min_Period,      Msp_Max_Period,           Msp_Max_Amt,

                     Msp_Creat_Dt,           Msp_Creat_By,        Msp_Prg_Id,               Msp_Isin,
                     Msp_Exchange,           Msp_Disp_Scheme_Id,  Msp_Pause_Flg,            Msp_Pause_Min_Inst,
                     Msp_Pause_Max_Inst
                    )
             VALUES
                   ( l_Scheme_Code,          l_Plan_Type,         l_Frequency  ,            l_Min_Inst_Amt,
                     l_Multiplier_Amt,       l_Sch_From_Dt,       l_status ,                      'A',
                     --------
                     l_Gap_Period,           /*l_Min_Gap_Period*/l_Min_Inst_Numbers,    /*l_Max_Gap_Period*/l_Max_Inst_Numbers,         l_Max_Inst_Amt,

                     SYSDATE,                USER,                l_Prg_Id,                 l_Isin,
                     l_Exch,                 l_Disp_Scheme_code,  l_Pause_flg,              l_Pause_Min_Inst,
                     l_Pause_Max_Inst
                   );

            l_SIP_flg := 'UPDATE';
            
             EXCEPTION
             
           WHEN OTHERS THEN
                  NULL; 
           
           END;

        ELSIF l_SIP_flg = 'UPDATE' THEN
          P_Ret_Msg := 'Overall update Mfd_Systematic_Plan. for Record No.<'|| l_rec_no||'>Internal scheme id<'||l_Scheme_Code||'> plan type<'||l_Plan_Type||'>and frequency<'||l_Frequency||'>';

                    UPDATE Mfd_Systematic_Plan
                     SET    Msp_Min_Amt        =  l_Min_Inst_Amt,
                            Msp_Max_Amt        =  l_Max_Inst_Amt,
                            Msp_Amt_Multiple   =  l_Multiplier_Amt,
                            Msp_Min_Period     =  /*l_Min_Gap_Period*/l_Min_Inst_Numbers,
                            Msp_Max_Period     =  /*l_Max_Gap_Period*/l_Max_Inst_Numbers,
                            Msp_Period         =  l_Gap_Period,
                            Msp_Last_Upt_Dt    =  SYSDATE,
                            Msp_Last_Upt_By    =  USER,
                            Msp_Prg_Id         =  l_Prg_Id,
                            Msp_status         =  l_status,
                            Msp_Pause_Flg      =  l_Pause_flg,
                            Msp_Pause_Min_Inst =  l_Pause_Min_Inst,
                            Msp_Pause_Max_Inst =  l_Pause_Max_Inst
                     WHERE  Msp_Scheme_Id      =  l_Scheme_Code
                     AND    Msp_Sch_From_Dt    =  l_Sch_From_Dt
                     AND    Msp_Plan_Type      =  l_Plan_Type
                     AND    Msp_Disp_Scheme_Id =  l_Disp_Scheme_code
                     AND    Msp_Frequency      =  l_Frequency
                     AND    Msp_Record_Status  = 'A'
                     AND    Msp_Exchange       = 'BSE'
                     AND    Msp_Status         = 'A';

                  END IF;

                  END LOOP;

                   EXCEPTION

       WHEN Skip_Rec THEN
                      l_Skip_Rec := l_Skip_Rec + 1;

                      t_Err_Log(l_Skip_Rec) := 'Skipped Due To' ||': ' || P_Ret_Msg;

       WHEN Fail_Process THEN
          ROLLBACK;
          P_Ret_Val := 'FAIL';
          P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
          Utl_File.New_Line(l_Log_File_Ptr,2);
          Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
          Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
          Utl_File.Fclose(l_Log_File_Ptr);
          Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                                 l_Pam_Curr_Dt  ,
                                 l_Process_Id   ,
                                 'E'            ,
                                 'Y'            ,
                                 o_Sql_Msg)     ;

       WHEN SIP_EXISTS THEN
                Utl_File.Put_Line(l_Log_File_Ptr,'Record already present in MFD_SIP_DETAILS for Record No. :'|| l_Rec_No);
       WHEN OTHERS THEN
                      --l_test := SQLERRM;
                      l_test  :=  DBMS_UTILITY.format_error_backtrace ;
                      RAISE Fail_Process;

               END;
               END IF;

            /*WHEN Skip_Rec THEN
            l_Skip_Rec := l_Skip_Rec + 1;
            t_Err_Log(l_Skip_Rec) := 'Internal Scheme Id Not Found For Scheme Code '||l_Isin;
          WHEN OTHERS THEN
              RAISE Fail_Process;

         END;
     END IF;*/
     l_Rec_No := l_Rec_No + 1;
   END LOOP;

   l_Rec_Count    := l_Rec_Count -1 ;
   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'Sip Master upload summary              ');
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records in the file :'||l_Rec_Count);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Inserted    :'||l_Msd_Inst_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Updated     :'||l_Msp_Updt_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'No of records Skipped     :'||l_Skip_Rec);
   Utl_File.Put_Line(l_Log_File_Ptr,'--------------------------------------------');
   Utl_File.New_Line(l_Log_File_Ptr,1);
   IF t_Err_log.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_log(t));
      END LOOP;
   END IF;
   IF t_Err_Log_Dt.COUNT > 0 THEN
      FOR t IN 1..t_Err_log.COUNT
      LOOP
        Utl_File.Put_Line(l_Log_File_Ptr,' '||t||'. '||t_Err_Log_Dt(t));
      END LOOP;
   END IF;


   Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                           l_Pam_Curr_Dt  ,
                           l_Process_Id   ,
                           'C'            ,
                           'Y'            ,
                           o_Sql_Msg)     ;

   Utl_File.New_Line(l_Log_File_Ptr,2);
   Utl_File.Put_Line(l_Log_File_Ptr,'Process Completed Successfully.');
   Utl_File.Fclose(l_Log_File_Ptr);

   P_Ret_Val := 'SUCCESS';
   P_Ret_Msg := 'Process Completed Successfully';

   EXCEPTION
      /*WHEN Fail_Process THEN
         ROLLBACK;
         P_Ret_Val := 'FAIL';
         P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM;
         Utl_File.New_Line(l_Log_File_Ptr,2);
         Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
         Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
         Utl_File.Fclose(l_Log_File_Ptr);
         Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;*/

      WHEN OTHERS THEN
        ROLLBACK;
        P_Ret_Val := 'FAIL';
        P_Ret_Msg := 'Error on '||Substr(Dbms_Utility.Format_Error_Backtrace,47,57) || P_Ret_Msg || Chr(10) || 'Error :' || SQLERRM||' At Record No - '|| l_rec_no;
        Utl_File.New_Line(l_Log_File_Ptr,2);
        Utl_File.Put_Line(l_Log_File_Ptr,P_Ret_Msg);
        Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed');
        Utl_File.Fclose(l_Log_File_Ptr);
        Std_Lib.P_Updt_Prg_Stat(l_Prg_Id       ,
                                l_Pam_Curr_Dt  ,
                                l_Process_Id   ,
                                'E'            ,
                                'Y'            ,
                                o_Sql_Msg)     ;
   END P_Mfd_Load_Sip_Master_Fil_BSE;

   PROCEDURE P_Gen_Mfd_Order_Comfirm_Note(P_Entity_Id  IN VARCHAR2,
                                          P_Exch_Id    IN VARCHAR2,
                                          P_Order_Date IN DATE,
                                          P_Ret_Val    IN OUT VARCHAR2,
                                          P_Ret_Msg    IN OUT VARCHAR2)
   AS

    l_File_Name              VARCHAR2(1000);
    g_Html                   VARCHAR2(4000);
    g_Html2                  VARCHAR2(4000);
    g_Html3                  VARCHAR2(4000);
    g_Html4                  VARCHAR2(4000);
    l_Path                   VARCHAR2(1000);
    l_Log_File_Ptr           Utl_File.File_Type;
    l_File_Ptr               Utl_File.File_Type;
    l_File_Ptr_Lookup        Utl_File.File_Type;
    l_Lookup_File_Name       VARCHAR2(1000);
    l_Log_File_Name          VARCHAR2(1000);
    Comp_Desc                VARCHAR2(400);
    Comp_Add                 VARCHAR2(400);
    Deal_Add                 VARCHAR2(400);
    Cnt_Dtls                 VARCHAR2(400);
    Additional_Dtls          VARCHAR2(400);
    l_Start_Time             DATE;
    l_End_Time               DATE;
    l_Pam_Curr_Dt            DATE;
    l_Prg_Id                 VARCHAR2(50) := 'CSSWBMFDOCN';
    l_Ent_Id                 VARCHAR2(100);
    l_Last_Ent_Id            VARCHAR2(100);
    l_Rep_Gen_Seq            NUMBER;
    l_Mf_Order_Cnfm_Path     VARCHAR2(150);
    l_Server_Cmd             VARCHAR2(5000);
    l_Folder_Seq             NUMBER;
    l_Fold_Name              VARCHAR2(5000);
    l_Count                  NUMBER;
    l_Process_Id             NUMBER;
    l_Lookup_File_Path       VARCHAR2(3000);
    o_Err                    VARCHAR2(4000);
    l_Web_Seq_No             NUMBER := 0;
    l_Ent_Name               VARCHAR2(2000);
    l_Ent_Exch_Client_Id     VARCHAR2(2000);
    l_Client_Address         VARCHAR2(3000);
    l_Count_Mfocn            NUMBER(5) := 0;
    l_Time_Stamp             VARCHAR2(2000);
    l_Order_No               NUMBER(20);
    l_Status                 VARCHAR2(50);
    l_Time                   VARCHAR2(10);
    l_Msm_Amc_Code           VARCHAR2(200);
    l_Msm_Scheme_Name        VARCHAR2(200);
    l_Folio_No               VARCHAR2(30);
    l_Isin                   VARCHAR2(120);
    l_Transaction_Type       VARCHAR2(30);
    l_nav                    VARCHAR2(100);
    l_Quantity               VARCHAR2(100);
    l_Amount                 VARCHAR2(100);
    l_Exm_Name               VARCHAR2(40);
    l_Brokerage              VARCHAR2(100);
    l_Service_Tax            VARCHAR2(100);
    l_Edu_Cess               VARCHAR2(100);
    l_Settlement_Type        VARCHAR2(5);
    --l_High_Edu_Cess          VARCHAR2(100);
    l_Stt                    VARCHAR2(100);
    l_Total                  VARCHAR2(3000);
    l_Row_Client_Count       NUMBER := 1;
    l_Header                 BOOLEAN := TRUE;
    l_Net_Total              NUMBER(15,2):=0;
    l_Buy_Sell_Flg           VARCHAR2(30);
    l_Last_Pur_Reed          VARCHAR2(30);
    l_Net_Total_Des          VARCHAR2(3000);
    Ex_Submit_Cmd            EXCEPTION;
    l_Client_Pan_No          VARCHAR2(2000);
    l_Compliance_Name        VARCHAR2(100);
    l_Compliance_Email       VARCHAR2(100);
    l_Compliance_Tel_No      VARCHAR2(100);
    l_Mfd_Authorised_Signatory   VARCHAR(1000);

    CURSOR C_Client_Order IS
        SELECT Client_Id,
               Time_Stamp,
               Order_No,
               Pan_No,
               Status,
               Order_Time,
               Amc_Id,
               Msm_Scheme_Desc,
               Msm_Rta_Id,
               Nvl(ISIN,'--') ISIN,
               Nvl(Settlement_Type,'--') Settlement_Type,
               Transaction_Type, --It is Use For Description
               Pur_Redeem,       --It is Use For Prparing The Separe Table
               Pur_Red_Flag,     --It Is user For Query Part
               Nvl(Folio_No,'--') Folio_No,
               Nvl(To_Char(NAV,'99999999999999999990D9999'),'--') NAV,
               Nvl(To_Char(Purchase_Amount,'99999999999999999990D99'),'--') Purchase_Amount,
               Nvl(To_Char(Redem_Units,'99999999999999999990D999'),'--') Redem_Units,
               Nvl(To_Char(Brokerage,'99999999999999999990D99'),'--') Brokerage,
               Nvl(To_Char(Service_Tax_On_Pure_Brk,'99999999999999999990D99'),'--') Service_Tax_On_Pure_Brk,
               Nvl(To_Char(Education_Cess_On_Service_Tax,'99999999999999999990D99'),'--') Education_Cess_On_Service_Tax,
               --Nvl(To_Char(High_Edu_Cess_On_Service_Tax,'99999999999999999990D99'),'--') High_Edu_Cess_On_Service_Tax,
               Nvl(To_Char(Mc.Mc_Stt,'99999999999999999990D99'),'--') Stt,
               Nvl(To_Char(Total,'99999999999999999990D99'),0) Total
        FROM  (SELECT Mo.Ent_Id Client_Id,
                      To_Char(Order_Date) || '  ' || Order_Time Time_Stamp,
                      Mo.Order_Date Order_Date,
                      Mo.Order_No Order_No,
                      Mo.First_Holder_Pan_Number Pan_No,
                      Decode(Mo.Order_Status,'C','Confirmed','Null') Status,
                      Mo.Order_Time,
                      (SELECT Mc.Amc_Name
                       FROM   Mfd_Amc_Master Mc
                       WHERE  Mc.Amc_Id = Msm_Amc_Id
                       )Amc_Id,
                      Msm.Msm_Amc_Id Amc_Id1 ,
                      Msm.Msm_Scheme_Desc,
                      Msm.Msm_Rta_Id,
                      Msm.Msm_Isin ISIN,
                      Decode(Msm_Settlement_Type,'T1','T+1','T2','T+2','T3','T+3','T4','T+4','T5','T+5','T6','T+6','T7','T+7','MF','NFO','L0','NA','L1','NA',Nvl(Msm_Settlement_Type,'--')) Settlement_Type,
                      Decode(Mo.Transaction_Type,'P','Purchase','R','Redemption','S','SIP','W','SWP','T','STP','SI','Switch IN','SO','Switch Out','NFO','NFO') Transaction_Type,
                      Decode(Mo.Transaction_Type,'S','P','W','R','T','R','NFO','P',Mo.Transaction_Type) Pur_Redeem,
                      Pur_Red_Flag,
                      Mo.Folio_No,
                      Mo.Nav_Value NAV,
                      Mo.Amount  Purchase_Amount,
                      Decode(Mo.Pur_Red_Flag,'P',Mo.Purchase_Units,'R',Mo.Redem_Units) Redem_Units,             Mo.Pure_Brokerage_Amt Brokerage,
                      Mo.Service_Tax_On_Pure_Brk,
                      (Mo.Education_Cess_On_Service_Tax + Mo.High_Edu_Cess_On_Service_Tax) Education_Cess_On_Service_Tax,
                      --Mo.High_Edu_Cess_On_Service_Tax,
                      Decode(Mo.Pur_Red_Flag,'P',(Nvl(Mo.Amount, 0) + Nvl(Mo.Pure_Brokerage_Amt, 0) +
                      Nvl(Mo.Service_Tax_On_Pure_Brk, 0) + Nvl(Mo.Education_Cess_On_Service_Tax,0) +
                      Nvl(Mo.High_Edu_Cess_On_Service_Tax,0)),'R',(Mo.Amount-(Nvl(Mo.Pure_Brokerage_Amt, 0) +
                      Nvl(Mo.Service_Tax_On_Pure_Brk, 0) + Nvl(Mo.Education_Cess_On_Service_Tax,0) +
                      Nvl(Mo.High_Edu_Cess_On_Service_Tax,0)))) Total
               FROM   Mfd_Orders Mo,
                      Mfd_Scheme_Master Msm,
                      Parameter_Master
               WHERE  Mo.Scheme_Id            = Msm.Msm_Scheme_Id
               AND    Mo.Amc_Id               = Msm.Msm_Amc_Id
               AND    Mo.Order_Status         ='C'
               AND    Mo.Processing_Status    ='R'
               AND    Mo.Order_Date           = Nvl(p_Order_Date, Mo.Order_Date)
               AND    Mo.Ent_Id               =Nvl(p_Entity_Id,Mo.Ent_Id)
               AND    Mo.Transaction_Type  IN ('P','R','S','T','W','SI','SO','NFO')
               AND    Msm.Msm_Status          ='A'
               AND    Msm.Msm_Record_Status   ='A'
               AND    Mo.Misdeal_Yn           ='N'
               AND    Pam_Curr_Dt BETWEEN Msm.Msm_From_Date AND Nvl(Msm.Msm_To_Date,Pam_Curr_Dt)) Main1,
              Mfd_Confirmation Mc
        WHERE To_Char(Main1.Order_No) = Mc.MC_USR_TRNO(+)
        AND   Main1.Amc_Id1   = Mc.MC_AMC_ID(+)
        AND   Main1.Pur_Red_Flag =Mc.Mc_Buy_Sell_Flg(+)
        ORDER BY Client_Id,Pur_Redeem,Order_No;

    CURSOR C_Entity_Id IS
        SELECT Em.Ent_Name AS Client_Name,
               Em.Ent_Id AS Client_Id,
               (Em.Ent_Address_Line_1 || Em.Ent_Address_Line_2) AS Address1,
               (Em.Ent_Address_Line_3 || ' ' || Em.Ent_Address_Line_4) AS Address2,
               (Em.Ent_Address_Line_7 || '(' || Em.Ent_Address_Line_6 || ')') AS Address3,
               Em.Ent_Phone_No_1,
               Em.Ent_Phone_No_2,
               Ed.End_Email_Id Email,
               Ed.End_Email_Id Email_Cc,
               Em.Ent_Dob Dob,
               Em.Ent_First_Name First_Name,
               Em.Ent_Title Title,
               Em.Ent_Mobile_No Mobile,
               Erd.Erd_Pan_No Pan
        FROM   Entity_Master               Em,
               Entity_Details              Ed,
               Entity_Registration_Details Erd
        WHERE  Em.Ent_Id = Erd.Erd_Ent_Id
        AND    Em.Ent_Id = Nvl(l_Ent_Id, Em.Ent_Id)
        AND    Ed.End_Id = Em.Ent_Id
        AND    Em.Ent_Status = 'E';


    PROCEDURE P_Fund_Order_Confirm_Info
    IS
    BEGIN
      P_Get_Company_Name;
      P_Ret_Msg := ' Selecting path for storing  web mutual fund order confirmation note';
      SELECT Decode(Rv_Meaning,'N',Rv_Low_Value,Rv_High_Value)
      INTO   l_Mf_Order_Cnfm_Path
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain       = 'LOCAL_MAIL_YN'
      AND    Rv_Abbreviation = l_Prg_Id;

      P_Ret_Msg := ' Generating the sequence for web  mutual fund order confirmation note directory ';
      SELECT COUNT(*)
      INTO   l_Folder_Seq
      FROM   Web_Rep_Gen
      WHERE  Rg_Rep_Id = l_Prg_Id
      AND    Rg_Gen_Dt = l_Pam_Curr_Dt;

      l_Folder_Seq := l_Folder_Seq + 1;

      P_Ret_Msg := ' Generating folder name on server';
      SELECT To_Char(l_Pam_Curr_Dt, 'DDMONRRRR')||'_MFD_'||l_Folder_Seq
      INTO   l_Fold_Name
      FROM   Dual;

      P_Ret_Msg          := 'Creating a directory for storing web mutual fund distribution order confirmation note  ';
      l_Server_Cmd       := 'mkdir ' || l_Mf_Order_Cnfm_Path || '/' ||l_Fold_Name;
      l_Lookup_File_Name := 'Lookup_File_'||l_Folder_Seq||'.TXT';


      IF g_Count_Directory = 0 THEN

         P_Ret_Msg := ' listerner problem count is <'||l_Count||'> ideally 2';
         SELECT Submit_Cmd('run_comm' || ' ' || l_Server_Cmd)
         INTO   l_Count
         FROM   Dual;

         IF l_Count != 2 THEN
            RAISE Ex_Submit_Cmd;
         END IF;

      END IF;

      l_Path             := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name;
      l_Lookup_File_Path := l_Mf_Order_Cnfm_Path || '/' || l_Fold_Name;

      P_Ret_Msg := ' Generating sequence from Web_Rep_Gen_Seq.';
      SELECT Web_Rep_Gen_Seq.NEXTVAL
      INTO   l_Web_Seq_No
      FROM   Dual;

      P_Ret_Msg := ' Inserting Folder path and details for sequence<'||l_Web_Seq_No||'>.';
      INSERT INTO Web_Rep_Gen
        (Rg_Seq,                               Rg_File_Name,                   Rg_Status,
         Rg_Gen_Dt,                            Rg_Act_Gen_Dt,                  Rg_Start_Time,
         ----------
         Rg_Remarks,                           Rg_Creat_Dt,                    Rg_Creat_By,
         Rg_Rep_Id,                            Rg_Exchange,                    Rg_Segment,
         ----------
         Rg_From_Dt,                           Rg_To_Dt,                       Rg_From_Client,
         Rg_To_Client,                         Rg_Type,                        Rg_Category,
         -----------
         Rg_Desc,                              Rg_File_Path,                   Rg_Log_File_Name
         )
      VALUES
        (l_Web_Seq_No,                         l_Fold_Name,                    'R',
         l_Pam_Curr_Dt,                        P_Order_Date,                   SYSDATE,
         ----------
         'Generating mutual fund distribution order confirmation note Started',SYSDATE, USER,
         l_Prg_Id,                             P_Exch_Id,                      'N',
         -----------
         P_Order_Date,                         P_Order_Date,                   P_Entity_Id,
         P_Entity_Id,                          'FOLDER',                       'MFD_ORDER_CONFIRMATION_NOTE',
         ------------
         'WEB MUTUAL FUND DISTRIBUTION CONFIRMATION NOTE',l_Server_Cmd,        l_Log_File_Name
         );

      P_Ret_Msg := ' Selecting Broker related info for Main header';
      SELECT UPPER(Cp.Cpm_Desc) Company_Desc,
             Cp.Cpm_Address1 || ' ' || Cp.Cpm_Address2 || ' ' || Cp.Cpm_Address3 || ' ' || Cp.Cpm_Zip_Cd Company_Address,
             Cd.Cpd_Address1 ||' '||Cd.Cpd_Address2||' '||Cd.Cpd_Address3||' '||Cd.Cpd_Zip_Cd  Dealing_Address,
             'Tel No: ' || Nvl(Cpd_Phone_No1, Cpd_Phone_No2) ||' Fax No: ' ||Nvl(Cpd_Fax_No1, Cd.Cpd_Fax_No2)||' Email ID: <a href="mailto:'||Cpd_Email_Id||'">'||Cpd_Email_Id||'</a>' Contact_Details,
             /*'ARN: '||*/Eam_Arn_No||' '||' Service Tax No: '||Cp.Cpm_Service_Tax_No||' '||' PAN: '||Erd_Pan_No  Additional_Dtls
      INTO   Comp_Desc,
             Comp_Add,
             Deal_Add,
             Cnt_Dtls,
             Additional_Dtls
      FROM   Company_Details cd,
             Company_Master  Cp,
             Entity_Registration_Details t,
             Mfss_Exch_Admin_Master M
      WHERE  Cp.Cpm_Id      = Cd.Cpd_Id
      AND    t.Erd_Ent_Id   = Cp.Cpm_Id
      AND    Eam_Ram_Acc_No = Cp.Cpm_Id
      AND    Eam_Exm_Id     = 'BSE'; -- As Amfi Reg No is same for all Exchange

      SELECT Rv_Low_Value
      INTO   l_Mfd_Authorised_Signatory
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'MFSS_AUTHORISED_SIGNATORY';

      P_Ret_Msg := ' Selecting compliance officer datils for footer';
      SELECT Cp.Cpm_Compliance_Name,
             Cp.Cpm_Compliance_Email,
             Cp.Cpm_Compliance_Tel_No
      INTO   l_Compliance_Name,
             l_Compliance_Email,
             l_Compliance_Tel_No
      FROM   Company_Master Cp ;

      P_Ret_Msg := 'Selecting Lookup File ';
      IF g_Count_Directory = 0 THEN

        l_File_Ptr_Lookup := Utl_File.Fopen(l_Path, l_Lookup_File_Name, 'w');
        Utl_File.Put_Line(l_File_Ptr_Lookup,'File Name'           ||'|:|'||
                                            'Client Id'           ||'|:|'||
                                            'Email Id1'           ||'|:|'||
                                            'Email Id2'           ||'|:|'||
                                            'DOB'                 ||'|:|'||
                                            'Customer First Name' ||'|:|'||
                                            'Customer Salutation' ||'|:|'||
                                            'Customer Name'       ||'|:|'||
                                            'Layout Type'         ||'|:|'||
                                            'Frequency'           ||'|:|'||
                                            'Start Date'          ||'|:|'||
                                            'End Date'            ||'|:|'||
                                            'Mobile No'           ||'|:|'||
                                            'PAN'                 ||'|:|'||
                                            'Contract Id'         ||'|:|'||
                                            'Subject And Content' ||'|:|'||
                                            'Reserved Field 1'    ||'|:|'||
                                            'Reserved Field 2'    ||'|:|'||
                                            'Reserved Field 3'    ||'|:|'||
                                            'Reserved Field 4');
      END IF;

      g_Count_Directory := g_Count_Directory + 1;

    END P_Fund_Order_Confirm_Info;


    PROCEDURE P_Get_Class_Html
    IS
    BEGIN

      g_Html  := '<Style Type="text/css">table.tablefont td {border-style: solid;  border-width: 1px;
                     padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                     font-size: 8pt;   text-decoration: none;
                     color: #000000;    height:25pt;}
                  </Style>';

      g_Html2 := '<Style Type="text/css">table.tablefont2 td {
                      padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                      font-size: 8pt;    text-decoration: none;
                      color: #000000; }
                  </Style>';

      g_Html3 := '<Style Type="text/css">table.tablefont3 td {border-style: solid;  border-width: 1px;
                     padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                     font-size: 8pt;    text-decoration: none;
                     color: #000000; }
                  </Style>';

      g_Html4 := '<Style Type="text/css">table.tablefont4 td {
                      padding: 1px;     spacing: 0px;    font-family: Arial,Verdana,sans-serif;
                      font-size: 10pt;    text-decoration: none;
                      color: #000000; }
                  </Style>';
    END;

    PROCEDURE P_Report_Footer(P_Ent_Id IN VARCHAR2 , P_Rep_Gen_Seq IN VARCHAR2)
    AS
    BEGIN

       P_Ret_Msg := ' Updating status as success in rep_gen for sequence<'||P_Rep_Gen_Seq||'> and Client<'||l_Last_Ent_Id||'>';
       UPDATE Rep_Gen
       SET    Rg_Status       = 'S',
              Rg_End_Time     = SYSDATE,
              Rg_Remarks      = 'Client Fund Order confirmation Note Generated Successfully For:' ||P_Ent_Id,
              Rg_Last_Updt_By = USER,
              Rg_Last_Updt_Dt = SYSDATE
       WHERE  Rg_Seq          = P_Rep_Gen_Seq;

      ----- Sum of Total in report--------
       Utl_File.Put_Line(l_File_Ptr,  '<TD colspan =19 width = 88%  align = right>'||'Total'||'</TD>');
       l_Net_Total_Des := To_Char(l_Net_Total,'99999999999999999990D99');
       Utl_File.Put_Line(l_File_Ptr,  '<TD colspan =1  width = 12%  align = right>'||l_Net_Total_Des||'</TD>');
       Utl_File.Put_Line(l_File_Ptr, '</Table>');

       Utl_File.Put_Line(l_File_Ptr,  '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

        ------ footer details --------
       Utl_File.Put_Line(l_File_Ptr,       '<TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=19   width = 10% align=Left>Exit Load is charged for Mutual Fund Redemption for selected schemes, wherever applicable. For further details, please read the Key Information Memorandum/Factsheet of the scheme.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=19   width = 10% align=Left>Redemption Amount would be directly credited to your bank account by the RTA/AMC.</TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=1    width = 10% align=left>Date: </TD><TD  COLSPAN=1 width = 10% >' ||l_Pam_Curr_Dt || '</TD>');
       Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=6></TD>');
       --Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=2   width = 20% align=center>Yours faithfully,</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR><TD COLSPAN=1 width = 10% align=left>Place: </TD><TD COLSPAN=2 width = 10% >Mumbai</TD> ');
       Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=5></TD>');
      -- Utl_File.Put_Line(l_File_Ptr,               '<TD COLSPAN=3   width = 30% align=center>'||Comp_Desc||'</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       /*Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=8></TD>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 20% align=center>(Authorized Signatory)</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=8></TD>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 20% align=center>'||l_Mfd_Authorised_Signatory||'</TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');*/

       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=2   width = 10% align=Left><B>Note:<B></TD>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');
       Utl_File.Put_Line(l_File_Ptr,           '<TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>1.This is a computer generated statement and does not require signature.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>2.This statement is prepared based on data received from AMCs (Mutual Funds) and RTAs (Registrars). '||g_Company_Title||' is not responsible for issues due to incorrect data received from its sources.</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>3.If any discrepancies are observed in this email or statement, please call us on 18001030808 or write to us on <a href="mailto:helpdesk@idbidirect.in">helpdesk@idbidirect.in</a></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,                 '<TD COLSPAN=15   width = 10% align=Left>4.Compliance Officer Details: Compliance Officer: '||l_Compliance_Name||' Email ID: <a href="mailto:'||l_Compliance_Email||'">'||l_Compliance_Email||'</a>, Telephone No: '||l_Compliance_Tel_No||'</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,           '</TR>');
       Utl_File.Put_Line(l_File_Ptr,       '</TABLE>');
       Utl_File.Put_Line(l_File_Ptr,'</Body>');
       Utl_File.Fclose(l_File_Ptr);

    END;

    PROCEDURE P_Main_Header_Report_Name
    AS
    BEGIN
       Utl_File.Put_Line(l_File_Ptr, g_Html);
       Utl_File.Put_Line(l_File_Ptr, g_Html2);
       Utl_File.Put_Line(l_File_Ptr, g_Html4);
       Utl_File.Put_Line(l_File_Ptr,' <Body Style="background-color:F2FFF2">');
       ----  Main Header of company details------
       Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 50% class=tablefont2 colspan =5 align = center cellspacing=0> ');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD style = color:#0000A0; align = center class=tablefont2><B><font size="+2">' || Comp_Desc || '</font></B></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>Registered Office Address:'|| Comp_Add || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;> Main/Dealing Office Address:' ||Deal_Add || ' </TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>' || Cnt_Dtls || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD align = center style = color:#0000A0;>' || Additional_Dtls || '</TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,    ' </TABLE>');

       Utl_File.Put_Line(l_File_Ptr,    ' <TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');

       ----------Report Name-------------
       Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 100% class=tablefont2 colspan = 5 align = center cellspacing=0>');
       Utl_File.Put_Line(l_File_Ptr,         ' <TR><TD style = color:#150517; align = center class=tablefont2><B><font>Mutual Fund Trade Confirmation Note</font></B></TD></TR>');
       Utl_File.Put_Line(l_File_Ptr,    ' </TABLE>');
    END;

    PROCEDURE P_Salutation_N_Report_Header
    AS
    BEGIN
      -------- salutation and starting line of report------------
      Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
      Utl_File.Put_Line(l_File_Ptr,         '<TR><TD>Dear Sir/Madam,</TD></TR>');
      Utl_File.Put_Line(l_File_Ptr,         '<TR height=10><TD colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
      Utl_File.Put_Line(l_File_Ptr,         '<TR><TD>I/We have executed the following Mutual Fund Transactions in your account:</TD></TR>');
      Utl_File.Put_Line(l_File_Ptr,    ' </TABLE>');


      Utl_File.Put_Line(l_File_Ptr,    ' <TR Height=10><TD Colspan=100><Font style="height:10px;font-size:2px;">;</Font></TD></TR>');
        --------- Header for confirmation memo------------
      Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 100% Class=tablefont2 Border=1 Colspan = 16 Cellspacing=0>');
      Utl_File.Put_Line(l_File_Ptr,         '<TR>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 7%  align = center bgcolor ="#B80000"><B>Order No</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 7%  align = center bgcolor ="#B80000"><B>Order Date & Time</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 3%  align = center bgcolor ="#B80000"><B>Settlement Type</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =2 width = 8%  align = center bgcolor ="#B80000"><B>AMC Name</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =4 width = 17% align = center bgcolor ="#B80000"><B>Scheme Name</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 8%  align = center bgcolor ="#B80000"><B>Folio No</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 8%  align = center bgcolor ="#B80000"><B>ISIN</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Transaction Type</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>NAV(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Units</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Amount(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Brokerage(Rs)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Service Tax(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Edu Tax(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>STT(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,               '  <TD Style = color:#FFFFFF; colspan =1 width = 5%  align = center bgcolor ="#B80000"><B>Total(Rs.)</B></TD>');
      Utl_File.Put_Line(l_File_Ptr,         '</TR>');
    END;


  BEGIN--Main Begin Block

    P_Ret_Val := 'FAIL';
    P_Ret_Msg := ' Selecting business date.';
    SELECT Pam_Curr_Dt
    INTO   l_Pam_Curr_Dt
    FROM   Parameter_Master;

    P_Ret_Msg := ' Performing Housekeeping Activities .';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           P_Exch_Id,
                           P_Order_Date || ',' || P_Exch_Id || ',' ||
                           P_Entity_Id,
                           'E',
                           l_Log_File_Ptr,
                           l_Log_File_Name,
                           l_Process_Id);

    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Working Date       :' || l_Pam_Curr_Dt);
    Utl_File.Put_Line(l_Log_File_Ptr,'Exchange           :' || P_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,'Order Date         :' || P_Order_Date);
    Utl_File.Put_Line(l_Log_File_Ptr,'Client             :' || P_Entity_Id);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');

    P_Fund_Order_Confirm_Info;

    FOR i IN C_Client_Order
    LOOP

      l_Ent_Id              := i.Client_Id;
      l_Time_Stamp          := i.Time_Stamp;
      l_Order_No            := i.Order_No;
      l_Status              := i.Status;
      l_Time                := i.Order_Time;
      l_Msm_Amc_Code        := i.Amc_Id;
      l_Msm_Scheme_Name     := i.Msm_Scheme_Desc;
      l_Folio_No            := i.Folio_No;
      l_Isin                := i.Isin;
      l_Settlement_Type     := i.Settlement_Type ;
      l_Buy_Sell_Flg        := i.Pur_Redeem;
      l_Transaction_Type    := i.Transaction_Type;
      l_Nav                 := i.Nav;
      l_Quantity            := i.Redem_units;
      l_Amount              := i.Purchase_amount;
      l_Exm_Name            := i.Msm_Rta_Id;
      l_Brokerage           := i.Brokerage;
      l_Service_Tax         := i.Service_Tax_On_Pure_Brk;
      l_Edu_Cess            := i.Education_Cess_On_Service_Tax;
      l_Stt                 := i.Stt;
      l_Total               := i.Total;

      IF l_Rep_Gen_Seq IS NOT NULL AND l_Ent_Id <> l_Last_Ent_Id THEN
         P_Report_Footer(l_Last_Ent_Id,l_Rep_Gen_Seq);
      END IF;

      IF l_Ent_Id = l_Last_Ent_Id THEN
         l_Header  := FALSE;
      ELSE
         l_Header := TRUE;
      END IF;

      l_Count_Mfocn      := l_Count_Mfocn + 1;
      l_Row_Client_Count := 1;

       --- True than print Header
      IF l_Header THEN

         P_Ret_Msg := ' Selecting from entity master for<'||l_Ent_Id||'>.';
         SELECT Ent_Name,
                Ent_Exch_Client_Id,
                Ent_Address_Line_1||','||Ent_Address_Line_2||','||Ent_Address_Line_3||','||Ent_Address_Line_4||','||Ent_Address_Line_5||','||Ent_Address_Line_6||'-'||Ent_Address_Line_7
         INTO   l_Ent_Name,
                l_Ent_Exch_Client_Id,
                l_Client_Address
         FROM   Entity_Master
         WHERE  Ent_Id = l_Ent_Id;

         P_Ret_Msg := ' Selecting PAN No. for<'||l_Ent_Id||'>.';
         SELECT Erd_Pan_No
         INTO l_Client_Pan_No
         FROM Entity_Registration_Details
         WHERE Erd_Ent_Id = l_Ent_Id;

         l_Net_Total  := 0;
         l_File_Name  := i.Client_Id || '-' ||'CLIENT_MF_ORDER_CONFIRMATION' || '-' ||
                        To_Char(Std_Lib.l_Pam_Curr_Date, 'DDMONYYYY') ||'.htm';

         l_File_Ptr   := Utl_File.Fopen(l_Path, l_File_Name, 'w');
         l_Start_Time := SYSDATE;

         SELECT To_Char(l_Pam_Curr_Dt, 'YYYYMM') ||Lpad(Rep_Gen_Seq.NEXTVAL, 8, 0)
         INTO   l_Rep_Gen_Seq
         FROM   Dual;

         INSERT INTO Rep_Gen
           (Rg_Seq,                          Rg_File_Name,                           Rg_Status,
            Rg_Act_Gen_Dt,                   Rg_Start_Time,                          Rg_Remarks,
            -----------
            Rg_Creat_Dt,                     Rg_Creat_By,                            Rg_Rep_Id,
            Rg_Exchange,                     Rg_Segment,                             Rg_Ent_Id,
            ------------
            Rg_Comm_Channel,                 Rg_End_Time,                            Rg_Gen_Dt
            )
         VALUES
           (l_Rep_Gen_Seq,                   l_File_Name,                            'R',
            l_Pam_Curr_Dt,                   l_Start_Time,                           'MF Order Confirmation Report for client' || i.Client_Id,
            -------------
            SYSDATE,                         USER,                                   l_Prg_Id,
            'ALL',                           'E',                                    i.Client_Id,
            --------------
            'P',                             l_End_Time,                             l_Pam_Curr_Dt
            );

         P_Get_Class_Html;
         P_Main_Header_Report_Name;
         -------- Client Details after Report Name--------
         Utl_File.Put_Line(l_File_Ptr,    ' <BR></BR>');
         Utl_File.Put_Line(l_File_Ptr,    ' <TABLE width = 100% class=tablefont2 colspan = 10 cellspacing=0>');
         Utl_File.Put_Line(l_File_Ptr,         '<TR>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=1 width = 15% align=left>Trading Account No:</TD><TD COLSPAN=12  width = 10% align =left>' || l_Ent_Exch_Client_Id || '</TD>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD Align=left colspan=74>;</TD>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=12   width = 10% align=left>Internal Client Code :</TD><TD COLSPAN=12 width = 10% align =left>' ||i.Client_Id || '</TD>');
         Utl_File.Put_Line(l_File_Ptr,         '</TR>');

         Utl_File.Put_Line(l_File_Ptr,         '<TR>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=1 width = 15% align=left>Name: </TD><TD  COLSPAN=32 width = 15% >' ||l_Ent_Name ||'</TD>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD Align=left colspan=54>;</TD>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=12 width = 10% align=left>Trade Date :</TD><TD COLSPAN=12 width = 10% align =left>' ||to_char(P_Order_Date,'DD-MON-RRRR')|| '</TD>');
         Utl_File.Put_Line(l_File_Ptr,         '</TR>');

         Utl_File.Put_Line(l_File_Ptr,         '<TR>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=1 width = 15% align=left valign=top>Address : </TD><TD COLSPAN=25 width = 20% valign=top>' ||l_Client_Address ||'</TD>');
         Utl_File.Put_Line(l_File_Ptr,         '</TR>');

         Utl_File.Put_Line(l_File_Ptr,         '<TR>');
         Utl_File.Put_Line(l_File_Ptr,              '<TD COLSPAN=1 width = 10% align=left>PAN : </TD><TD COLSPAN=12 width = 10% >' ||l_Client_Pan_No || '</TD> ');
         Utl_File.Put_Line(l_File_Ptr,         '</TR>');
         Utl_File.Put_Line(l_File_Ptr,    ' </TABLE>');
         Utl_File.Put_Line(l_File_Ptr,    ' <BR></BR>');

         P_Salutation_N_Report_Header;

         ---- Look up file contains client details while be print only once in file.
         FOR j IN C_Entity_Id
         LOOP
           Utl_File.Put_Line(l_File_Ptr_Lookup,l_File_Name                  ||'|:|'||
                                               j.Client_Id                  ||'|:|'||
                                               j.Email                      ||'|:|'||
                                               j.Email_Cc                   ||'|:|'||
                                               j.Dob                        ||'|:|'||
                                               j.First_Name                 ||'|:|'||
                                               j.Title                      ||'|:|'||
                                               j.Client_Name                ||'|:|'||
                                               'MFD_ECN'                    ||'|:|'||
                                               'Daily'                      ||'|:|'||
                                               P_Order_Date                 ||'|:|'||
                                               P_Order_Date                 ||'|:|'||
                                               j.Mobile                     ||'|:|'||
                                               j.Pan                        ||'|:|'||
                                               ' '                          ||'|:|'||
                                               ' '                          ||'|:|'||
                                               ' '                          ||'|:|'||
                                               ' '                          ||'|:|'||
                                               ' '                          ||'|:|'||
                                               ' ');
         END LOOP;
      END IF;  --- End of to Print Header


      IF l_Buy_Sell_Flg = 'P' AND l_Last_Pur_Reed IS NULL THEN
         l_Net_Total := 0;
      ELSIF l_Buy_Sell_Flg = 'R' AND l_Last_Pur_Reed = 'P' THEN
         Utl_File.Put_Line(l_File_Ptr,  '  <TD colspan =19 width = 88%  align = right>' ||'Total' ||'</TD>');
         l_Net_Total_Des := To_Char(l_Net_Total,'99999999999999999990D99');
         Utl_File.Put_Line(l_File_Ptr,  '  <TD colspan =1 width = 12%  align = right>' ||l_Net_Total_Des || '</TD>');
         l_Net_Total := 0;
      ELSIF l_Buy_Sell_Flg IN ('SI','SO') AND l_Last_Pur_Reed = 'R' THEN
         Utl_File.Put_Line(l_File_Ptr,  '  <TD colspan =19 width = 88%  align = right>' ||'Redemption Amount would be directly credited to your bank account by the RTA/AMC
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;;;;;;;Total</TD>');
         l_Net_Total_Des :=To_Char(l_Net_Total,'99999999999999999990D99');
         Utl_File.Put_Line(l_File_Ptr,  '  <TD colspan =1 width = 12%  align = right>' ||l_Net_Total_Des || '</TD>');
         l_Net_Total := 0;
      END IF;

      l_Net_Total := l_Net_Total + To_Number(l_Total);

      ------ Populating Data in report---------
      Utl_File.Put_Line(l_File_Ptr,  '<TR>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 7%  align = center>'  ||l_Order_No || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 7%  align = center>'  ||l_Time_Stamp || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 3%  align = center>'  ||l_Settlement_Type || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =2 width = 8%  align = center>'  ||l_Msm_Amc_Code || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =4 width = 17% align = center>'  ||l_Msm_Scheme_Name || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 8%  align = center>'  ||l_Folio_No || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 8%  align = center>'  ||l_Isin || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = center>'  ||l_Transaction_Type || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = center>'  ||l_Nav || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Quantity || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Amount || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Brokerage || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Service_Tax || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Edu_Cess || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Stt || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,     '  <TD colspan =1 width = 5%  align = right>'   ||l_Total || '</TD>');
      Utl_File.Put_Line(l_File_Ptr,  '</TR>');

      l_Header := FALSE;
      l_Last_Ent_Id := l_Ent_Id;
      l_Last_Pur_Reed := l_Buy_Sell_Flg;
    END LOOP;

    IF l_Rep_Gen_Seq IS NOT NULL THEN
       P_Report_Footer(l_Ent_Id,l_Rep_Gen_Seq);
    END IF;

    Utl_File.Fclose(l_File_Ptr_Lookup);

    P_Ret_Msg := ' Updating status as success in web_rep_gen for sequence<'||l_Web_Seq_No||'>and Date<'||l_Pam_Curr_Dt||'>';
    UPDATE Web_Rep_Gen
    SET    Rg_Status       = 'S',
           Rg_Last_Updt_Dt = SYSDATE,
           Rg_Last_Updt_By = USER,
           Rg_End_Time     = SYSDATE,
           Rg_Remarks      = 'Client Mutual Fund Order Confirmation  Report Generated Successfully  For:' ||l_Count_Mfocn
    WHERE  Rg_Seq          = l_Web_Seq_No
    AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

    P_Ret_Msg := ' Updating look up file path and name in Program_Status for program id<'||l_Prg_Id||'>and Date<'||l_Pam_Curr_Dt||'>';
    UPDATE Program_Status
    SET    Prg_Status_File  = l_Lookup_File_Path,
           Prg_Output_File  = l_Lookup_File_Name,
           Prg_End_Time     = SYSDATE,
           Prg_Last_Updt_By = USER
    WHERE  Prg_Cmp_Id       = l_Prg_Id
    AND    Prg_Process_Id   = l_Process_Id
    AND    Prg_Dt           = l_Pam_Curr_Dt;

    g_Count_Directory := 0;
    P_Ret_Val         := 'SUCCESS';
    P_Ret_Msg         := 'Process Completed Successfully .';

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Dt,
                            l_Process_Id,
                            'C',
                            'Y',
                            o_Err);

    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation     :');
    Utl_File.New_Line(l_Log_File_Ptr);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,' No . of Client Order Confirmation Report Generated     :   ' ||l_Count_Mfocn);
    Utl_File.Put_Line(l_Log_File_Ptr,'****************************************************************************************************');
    Utl_File.Put_Line(l_Log_File_Ptr,'Process Completed Successfully at <' ||To_Char(SYSDATE, 'DD-MON-YYYY:HH:MI:SS AM') || '>');
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN Ex_Submit_Cmd THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||'**Error While ' || p_Ret_Msg || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation Failed :-');
      Utl_File.Put_Line(l_Log_File_Ptr, ' Error Message :- ' || p_Ret_Msg);

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Err);

      Utl_File.Fclose(l_Log_File_Ptr);

    WHEN OTHERS THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||'**Error While ' || p_Ret_Msg || SQLERRM || ':<' ||
                   l_File_Name || '>' || ':<' || l_Ent_Id || '>';

      Utl_File.Put_Line(l_Log_File_Ptr,' Web Client Mutual Fund Order Confirmation Note Generation Failed :-');
      Utl_File.Put_Line(l_Log_File_Ptr, ' Error Message :- ' || p_Ret_Msg);

      UPDATE Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = p_Ret_Msg,
             Rg_Last_Updt_By = USER,
             Rg_Last_Updt_Dt = SYSDATE
      WHERE  Rg_Seq          = l_Rep_Gen_Seq;

      UPDATE Web_Rep_Gen
      SET    Rg_Status       = 'F',
             Rg_Last_Updt_Dt = SYSDATE,
             Rg_Last_Updt_By = USER,
             Rg_End_Time     = SYSDATE,
             Rg_Remarks      = 'Web Client Mutual Fund Order Confirmation Note Generation Failed:' ||l_Count_Mfocn || p_Ret_Msg
      WHERE  Rg_Seq          = l_Web_Seq_No
      AND    Rg_Gen_Dt       = l_Pam_Curr_Dt;

      UPDATE Program_Status
      SET    Prg_Status_File  = l_Lookup_File_Path,
             Prg_Output_File  = l_Lookup_File_Name,
             Prg_End_Time     = SYSDATE,
             Prg_Last_Updt_By = USER
      WHERE  Prg_Cmp_Id       = l_Prg_Id
      AND    Prg_Process_Id   = l_Process_Id
      AND    Prg_Dt           = l_Pam_Curr_Dt;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Err);

      Utl_File.Fclose(l_File_Ptr);
      Utl_File.Fclose(l_File_Ptr_Lookup);
      Utl_File.Fclose(l_Log_File_Ptr);

  END P_Gen_Mfd_Order_Comfirm_Note;

  PROCEDURE p_Gen_Mfss_Order_Conf_Note_vb(P_Entity_Id  IN VARCHAR2,
                                          P_Exch_Id    IN VARCHAR2,
                                          P_Order_Date IN DATE,
                                          P_Print_Flag  IN  VARCHAR2,
                                          P_Ret_Val    IN OUT VARCHAR2,
                                          P_Ret_Msg    IN OUT VARCHAR2)
  IS
   O_Tab_Rep_Seq  Std_Lib.Tab ;
  BEGIN
    p_Gen_Mfss_Order_Comfirm_Note(P_Entity_Id,
                                  P_Exch_Id,
                                  P_Order_Date,
                                  P_Print_Flag,
                                  O_Tab_Rep_Seq,
                                  P_Ret_Val,
                                  P_Ret_Msg);

  END p_Gen_Mfss_Order_Conf_Note_vb;

END Pkg_Mfss_Securities_Settlement;
/
