CREATE OR REPLACE PACKAGE Pkg_Mfss_Settlement_Funds
AS

  g_Count_Directory NUMBER := 0;

  TYPE t_Trd_Details IS TABLE OF Mfss_Trades%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE Tab_Err_Msg IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  FUNCTION F_Bill_Amt(P_Ent_Id    IN VARCHAR2,
                      P_Date      IN DATE,
                      P_Order_No  IN NUMBER) RETURN NUMBER;

  PROCEDURE p_Mfss_Contracting(p_Exm_Id              IN VARCHAR2,
                               p_Date                IN DATE,
                               p_Ent_Id              IN VARCHAR2,
                               p_Stc_No              IN VARCHAR2,
                               p_Settlement_Type     IN VARCHAR2,
                               o_Ret_Val             OUT VARCHAR2,
                               o_Ret_Msg             OUT VARCHAR2);


  PROCEDURE p_Dwnld_Funds_Obligation_Rep(p_File_Name IN VARCHAR2,
                                         p_Exch_Id   IN VARCHAR2,
                                         p_Stc_No    IN VARCHAR2,
                                         p_Settlement_Type IN VARCHAR2,
                                         p_Ret_Val   IN OUT VARCHAR2,
                                         p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE p_Gen_Funds_Confirmation_Stmt(P_Mode    IN VARCHAR2,
                                          p_Exch_Id IN VARCHAR2,
                                          p_Gen_Dt  IN DATE,
                                          p_Stc_No  IN VARCHAR2,
                                          p_Settlement_Type IN VARCHAR2,
                                          p_Ret_Val IN OUT VARCHAR2,
                                          p_Ret_Msg IN OUT VARCHAR2);

  PROCEDURE p_Dwnld_Funds_Conf_Stmt(p_File_Name IN VARCHAR2,
                                    p_Exch_Id   IN VARCHAR2,
                                    p_Stc_No    IN VARCHAR2,
                                    p_Settlement_Type IN VARCHAR2,
                                    p_Ret_Val   IN OUT VARCHAR2,
                                    p_Ret_Msg   IN OUT VARCHAR2);

  PROCEDURE p_Load_Redemption_File_Unused(p_File_Name           IN VARCHAR2,
                                   p_Exch_Id             IN VARCHAR2,
                                   p_Success_Reject_Flag IN VARCHAR2,
                                   p_Ret_Val             IN OUT VARCHAR2,
                                   p_Ret_Msg             IN OUT VARCHAR2);

  PROCEDURE p_Generate_Payout(p_Exm_Id  IN VARCHAR2,
                              --p_Date    IN DATE,
                              p_Ent_Id  IN VARCHAR2,
                              o_Ret_Val OUT VARCHAR2,
                              o_Ret_Msg OUT VARCHAR2);

  PROCEDURE p_Reverse_Bills(p_Ent_Id               IN VARCHAR2,
                            p_Order_No             IN VARCHAR2,
                            p_Order_Date           IN DATE,
                            p_Buy_Sell_Flag        IN VARCHAR2,
                            p_Exm_Id               IN VARCHAR2,
                            p_Stc_No               IN NUMBER,
                            p_Security_Id          IN VARCHAR2,
                            p_Cancel_Remark        IN VARCHAR2,
                            p_Cancel_Option         IN VARCHAR2,
                            o_Ret_Msg              OUT VARCHAR,
                            o_Total_Bills_Reversed OUT NUMBER);

  PROCEDURE p_Get_Comm_Rate(p_Ent_Id            IN VARCHAR2,
                            p_Buy_Sell_Flag     IN VARCHAR2,
                            p_Exm_Id            IN VARCHAR2,
                            p_Order_Type        IN VARCHAR2,
                            p_Holding_Mode      IN VARCHAR2,
                            p_Scheme_Id         IN VARCHAR2,
                            o_Sch_Id            OUT VARCHAR2,
                            o_Per_Rate          OUT NUMBER,
                            o_Amt_Per_Trade     OUT NUMBER,
                            o_Min_Amt_Per_Trade OUT NUMBER);

  PROCEDURE P_Gen_MF_SIP_File(P_Exm_Id      IN VARCHAR2  ,
                              p_Settlement_Type  IN VARCHAR2  ,
                              o_Ret_Val     OUT VARCHAR2 ,
                              o_Message     OUT VARCHAR2 );

  PROCEDURE P_Can_MF_SIP_Order(P_Exm_Id        IN VARCHAR2  ,
                               p_Settlement_Type  IN VARCHAR2  ,
                               o_Ret_Val       OUT VARCHAR2 ,
                               o_Message       OUT VARCHAR2 );

  PROCEDURE P_Regen_MF_Batch(P_Exm_Id      IN VARCHAR2  ,
                             P_Batch_Id    IN NUMBER    ,
                             P_Ent_Id      IN VARCHAR2  ,
                             o_Ret_Val     OUT VARCHAR2 ,
                             o_Message     OUT VARCHAR2 );

  /*PROCEDURE P_Mutual_Fund_Netting(P_Ent_Id          IN VARCHAR2,
                                  P_Exm_Id          IN VARCHAR2,
                                  o_Message         OUT VARCHAR2,
                                  o_Ret_Val         OUT VARCHAR2);*/

END Pkg_Mfss_Settlement_Funds;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Mfss_Settlement_Funds
AS

  FUNCTION F_Bill_Amt(P_Ent_Id    VARCHAR2,
                      P_Date      DATE,
                      P_Order_No  NUMBER)
  RETURN NUMBER
  IS
    l_Amt NUMBER;

  BEGIN
    SELECT Amt_Remain
    INTO l_Amt
    FROM
          (SELECT Bld_Ent_Id           ,          Bld_Seg_Id,
                 Bld_Stc_Stt_Exm_Id   ,          SUm(Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0)) Amt_Remain,
                 Bld_Remarks, 'B'
          FROM   Bill_Details B
          WHERE  Bld_Stage               = 'O'
          AND    Bld_Ent_Id              = Nvl(P_Ent_Id,Bld_Ent_Id)
          AND    Bld_Mf_Purc_Redm_Flag   = 'P'
          AND    Bld_Seg_Id              = 'M'
          AND    Bld_Remarks             = P_Order_No
          AND    Bld_Pam_Dt              <= P_Date
          --AND    Bld_Arks                 = P_Order_No
          AND    Bld_Tcm_Cd              NOT IN ('MSC','MSD','RBK', 'RPI', 'RPO', 'UDH', 'RST', 'RTS', 'UDE', 'RTT', 'RSD')
          AND    Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) > 0
          GROUP BY Bld_Remarks, Bld_ENt_Id, Bld_Stc_Stt_Exm_Id, Bld_Seg_Id);
/*          UNION ALL
          SELECT Bld_Ent_Id           ,          Bld_Seg_Id,
                 Bld_Stc_Stt_Exm_Id   ,          SUm(Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0)) ,
                 Bld_Remarks, 'B'
          FROM   Bill_Details B
          WHERE  Bld_Stage               = 'O'
          AND    Bld_Ent_Id              = Nvl(P_Ent_Id,Bld_Ent_Id)
          AND    Bld_Pam_Dt              <= P_Date
          AND    Bld_Remarks             = P_Order_No
          AND    Bld_Seg_Id              = 'M'
          AND    Bld_Tcm_Cd              =  'MSC'
          AND    Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) > 0
          GROUP BY Bld_Remarks, Bld_ENt_Id, Bld_Stc_Stt_Exm_Id, Bld_Seg_Id);*/

          RETURN l_Amt;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END;


  PROCEDURE p_Mfss_Contracting(p_Exm_Id                  IN VARCHAR2,
                               p_Date                    IN DATE,
                               p_Ent_Id                  IN VARCHAR2,
                               p_Stc_No                  IN VARCHAR2,
                               p_Settlement_Type         IN VARCHAR2,
                               o_Ret_Val                 OUT VARCHAR2,
                               o_Ret_Msg                 OUT VARCHAR2) IS

    l_Prg_Id               VARCHAR2(30) := 'CSSBMFCON';
    l_Pam_Curr_Dt          DATE;
    l_Log_File_Name        VARCHAR2(300);
    l_Log_File_Ptr         Utl_File.File_Type;
    l_Seg_Id               VARCHAR2(2) := 'M';
    l_Process_Id           NUMBER(10) := 0;
    l_Skip_Record          EXCEPTION;
    l_Blm_No               VARCHAR2(30);
    l_Blm_No_Prev          VARCHAR2(30) := '@@@@';
    l_Bld_No               NUMBER(20);
    l_Cn_No                VARCHAR2(30);
    l_Scheme_Id            VARCHAR2(200);
    l_Comm_Rate            NUMBER(15,2);
    l_Comm_Amt_Per_Trade   NUMBER(15,2);
    l_Min_Amt              NUMBER(15,2);
    --l_Service_Tax_Rate     NUMBER(15,2);
    --l_Edu_Cess_Rate        NUMBER(15,2);
    --l_High_Edu_Cess_Rate   NUMBER(15,2);
    l_Brk_Amt              NUMBER(15,2);
    l_Set_Amt              NUMBER(15,2);
    l_Edu_Amt              NUMBER(15,2);
    l_High_Edu_Amt         NUMBER(15,2);
    l_Seq                  NUMBER(20);
    l_Prev_Ent_Id          VARCHAR2(30);
    l_Prev_Ent_Id1         VARCHAR2(30);
    l_Company_Id           VARCHAR2(30);
    l_Payin_Date           DATE;
    l_Payout_Date          DATE;
    l_Financial_Year_Start DATE;
    l_Financial_Year_End   DATE;
    l_Mutual_Fund_Seg      VARCHAR2(3);
    l_Nav_Value            NUMBER(15, 4) := 0;
    l_Count_Skip           NUMBER := 0;
    l_Count_Contracts      NUMBER := 0;
    l_Count_Order          NUMBER := 0;
    l_Count_Bills          NUMBER := 0;
    l_Prev_Cn_No           VARCHAR2(20);
    o_Sqlerrm              VARCHAR2(2000);
    l_Exception            EXCEPTION;
    l_Seq_No               NUMBER(14):=1;
    l_Mfss_Contract_Seq    NUMBER;
    l_count                NUMBER := 0;

    l_CGST_Rate            NUMBER             ;
    l_SGST_Rate            NUMBER             ;
    l_IGST_Rate            NUMBER             ;
    l_UT_Flag              VARCHAR2(1)        ;
    l_Receiving_State      VARCHAR2(100)      ;
    l_Servicing_State      VARCHAR2(100)      ;

    TYPE Tcm_Cd IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(5);
    Tcm_Cd_Tab Tcm_Cd;

    CURSOR c_Tcm_Cd IS
      SELECT Tcm_Cd,
             Tcm_Db_Cr_Flg
      FROM   Txn_Code_Master
      WHERE  Tcm_Status = 'A';

    CURSOR c_Mfss_Trd IS
      SELECT Order_No,
             Order_Date,
             Exm_Id,
             Stc_Type,
             Stc_No,
             Ent_Id,
             Security_Id,
             Buy_Sell_Flg,
             Quantity,
             Amount,
             Holding_Mode,
             Order_Type,
             Isin,
             ROWID,
             Settlement_Type,
             Order_Stc_Type
      FROM   Mfss_Trades
      WHERE  Order_Date = p_Date
      AND    Nvl(Exm_Id, 'A') = Nvl(p_Exm_Id, Nvl(Exm_Id, 'A'))
      AND    Ent_Id = Nvl(p_Ent_Id, Ent_Id)
      AND    Trade_Status = 'A'
      AND    Nvl(Confirmation_Flag, 'N') = 'Y'
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND    Contract_No IS NULL
      AND    Bill_No IS NULL
      AND    Buy_Sell_Flg = 'P'
      AND    Order_Status = 'VALID'
      AND    NVL(Order_Stc_Type,'X') = DECODE(p_Settlement_Type,'N','NFOT',NVL(Order_Stc_Type,'X'))
      ORDER By Exm_Id,
               Ent_Id,
               Order_No,
               Security_Id,
               Amount;

     CURSOR c_Duplicate_Order IS
      SELECT Order_No, Exm_Id, Buy_Sell_Flg, Security_Id, Order_Date,ROWID
     FROM (SELECT COUNT(*) Over(PARTITION BY Order_No) Cnt,
                  Order_No,
                  Exm_Id,
                  Buy_Sell_Flg,
                  Security_Id,
                  Order_Date,ROWID --,MAX(ROWID)
             FROM Mfss_Trades a
            WHERE Order_Date = p_Date
            AND   Order_Status='VALID')
    WHERE Cnt > 1;

    PROCEDURE Insert_Bill(lp_Txn_Code       IN VARCHAR2,
                          lp_Bill_Amount    IN NUMBER,
                          lp_Order_No       IN VARCHAR2,
                          lp_Ent_Id         IN VARCHAR2,
                          lp_Exm_Id         IN VARCHAR2,
                          lp_Stc_No         IN VARCHAR2,
                          lp_Stc_Type       IN VARCHAR2,
                          lp_Add_Info_Flag  IN VARCHAR2 DEFAULT 'N') IS
    l_Special_attribute   VARCHAR2(10);
    BEGIN
      IF NVL(lp_Bill_Amount,0) <= 0 THEN
        RETURN;
      END IF;

      SELECT Nvl(MAX(Bld_No), 0) + 1
      INTO   l_Bld_No
      FROM   Bill_Details
      WHERE  Bld_Blm_No = l_Blm_No
      AND    Bld_Blm_Status = 'F'
      AND    Bld_Blm_Cpd_Id = l_Company_Id;

      SELECT decode(e.ent_category,'NRI','B',NULL)
      INTO l_Special_attribute
      FROM entity_master e
      WHERE e.ent_id = lp_Ent_Id;

      o_Ret_Msg := 'Inserting into  Bill Details for '||lp_Txn_Code||' bills for order no <' ||
                   lp_Order_No || '> and client id <' || lp_Ent_Id || '>';
      INSERT INTO Bill_Details
        (Bld_No,
         Bld_Blm_No,
         Bld_Blm_Status,
         Bld_Icn_No,
         Bld_Tcm_Cd,
         Bld_Due_Dt,
         Bld_Due_Amt,
         Bld_Adj_In_Amt,
         Bld_Stage,
         Bld_Blm_Cpd_Id,
         Bld_Creat_By,
         Bld_Creat_Dt,
         Bld_Prg_Id,
         Bld_Pam_Dt,
         Bld_Alloc_Id,
         Bld_Special_Attribute,
         Bld_Ind_Flg,
         Bld_Seg_Id,
         Bld_Ent_Id,
         Bld_Stc_Stt_Exm_Id,
         Bld_Remarks,
         Bld_Dr_Cr_Flag,
         Bld_Stc_Stt_Type,
         Bld_Stc_No,
         Bld_Mf_Purc_Redm_Flag,
         Bld_Arks)
      VALUES
        (l_Bld_No,
         l_Blm_No,
         'F',
         Nvl(l_Prev_Cn_No, l_Cn_No),
         lp_Txn_Code,
         Decode(lp_Stc_Type,'L0',l_Pam_Curr_Dt,'L1',l_Pam_Curr_Dt,l_Payin_Date),
         lp_Bill_Amount,
         0,
         'O',
         l_Company_Id,
         USER,
         SYSDATE,
         l_Prg_Id,
         l_Pam_Curr_Dt,
         NULL,
         l_Special_attribute,
         NULL,
         l_Seg_Id,
         lp_Ent_Id,
         lp_Exm_Id,
         lp_Order_No,
         Tcm_Cd_Tab(lp_Txn_Code),
         lp_Stc_Type,
         lp_Stc_No,
         'P',
         lp_Order_No);

      IF lp_Add_Info_Flag = 'Y' THEN
        INSERT INTO BILL_DETAILS_ADD_INFO
          (BLD_NO, BLD_BLM_NO, BLD_BLM_STATUS,
           BLD_BLM_CPD_ID, BLD_ENT_GST_STATE, BLD_ENT_BRANCH_STATE,
           BLD_ENT_UT_FLAG, BLD_CGST_RATE, BLD_SGST_RATE, BLD_IGST_RATE)
        VALUES
          (l_Bld_No, l_Blm_No, 'F',
           l_Company_Id, l_Receiving_State, l_Servicing_State,
           l_UT_Flag, l_CGST_Rate, l_SGST_Rate, l_IGST_Rate);
      END IF;
    END;

  BEGIN

    o_Ret_Val := 'FAIL';

    o_Ret_Msg := 'Performing Housekeeping ';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           Nvl(p_Exm_Id, 'ALL'),
                           p_Stc_No || '-' || p_Exm_Id || '-' || p_Ent_Id || '-' ||
                           p_Date,
                           'E',
                           l_Log_File_Ptr,
                           l_Log_File_Name,
                           l_Process_Id,
                           'Y');


    l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;
    l_Company_Id  := Std_Lib.l_Cpm_Id;

    o_Ret_Msg := 'Checking Duplicate order ';
    Utl_File.Put_Line(l_Log_File_Ptr, 'Order_No    Exm_Id  Buy_Sell_Flg  Security_Id  Order_Date');
    FOR i IN c_Duplicate_Order
     LOOP
       Utl_File.Put_Line(l_Log_File_Ptr,i.order_no||'  '||i.exm_id||'     '||i.buy_sell_flg||'              '||i.security_id||'  '||i.order_date);
       l_count := l_count + 1;
     END LOOP;
     IF l_count > 1 THEN
       RAISE l_Exception;
     END IF;


    /*o_Ret_Msg := 'selecting service tax rate from masters ';
    BEGIN
      SELECT Srt_Rate,
             Srt_Edu_Cess_Rate,
             Srt_High_Edu_Cess_Rate
      INTO   l_Service_Tax_Rate,
             l_Edu_Cess_Rate,
             l_High_Edu_Cess_Rate
      FROM   Service_Tax
      WHERE  Srt_Segment = l_Seg_Id
      AND    l_Pam_Curr_Dt BETWEEN Srt_Date_From AND
             Nvl(Srt_Date_To, l_Pam_Curr_Dt);
    EXCEPTION
      WHEN No_Data_Found THEN
        o_Ret_Msg := 'Service Tax Not Defined for Segment:' || l_Seg_Id ||
                     ' AND Date: ' || l_Pam_Curr_Dt;
        RAISE l_Exception;
    END;*/

    o_Ret_Msg := 'Getting Financial year start Date ';
    BEGIN
      SELECT Rv_Low_Value,
             Rv_High_Value
      INTO   l_Financial_Year_Start,
             l_Financial_Year_End
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain LIKE 'FINANCIAL_YEAR';
    EXCEPTION
      WHEN No_Data_Found THEN
        o_Ret_Msg := 'Setup Issue - Financial Year missing. <FINANCIAL_YEAR>';
        RAISE l_Exception;
    END;

    o_Ret_Msg := 'Getting MFSS Contract Sequence Number';
    SELECT Nvl(MAX(To_Number(Substr(Cn_No, -7))), 0)
    INTO   l_Mfss_Contract_Seq
    FROM   Mfss_Contract_Note
    WHERE  Transaction_Date >= l_Financial_Year_Start
    AND    Exm_Id = p_Exm_Id;

    o_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    BEGIN
      SELECT Rv_High_Value
      INTO   l_Mutual_Fund_Seg
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'EXCH_SEG_VALID'
      AND    Rv_Low_Value = p_Exm_Id
      AND    Rv_Abbreviation = 'MFSS';
    EXCEPTION
      WHEN No_Data_Found THEN
        o_Ret_Msg := 'Setup Issue - MF segment missing. <EXCH_SEG_VALID, MFSS>';
        RAISE l_Exception;
    END;

    o_Ret_Msg := 'Fetching Transaction Code Master';
    Tcm_Cd_Tab.DELETE;
    FOR i IN c_Tcm_Cd
    LOOP
      Tcm_Cd_Tab(i.Tcm_Cd) := i.Tcm_Db_Cr_Flg;
    END LOOP;

    IF Tcm_Cd_Tab.COUNT = 0 THEN
      o_Ret_Msg := 'Setup Issue - No Transaction Code defined.';
      RAISE l_Exception;
    END IF;

    o_Ret_Msg := 'Fetching MFSS Bill Due Date';
    IF p_Settlement_Type = 'N' THEN
      l_Payin_Date := l_Pam_Curr_Dt;
    ELSE
      Get_Mfss_Bill_Due_Dates(l_Pam_Curr_Dt, l_Payin_Date, l_Payout_Date);
    END IF;

    --Initiating GST Values
    Pkg_GST_Computation.P_Initialize;

    o_Ret_Msg := 'Fetching data for contracting';
    FOR i IN c_Mfss_Trd
    LOOP
      BEGIN
        l_Nav_Value          := 0;
        l_Scheme_Id          := NULL;
        l_Comm_Rate          := 0;
        l_Comm_Amt_Per_Trade := 0;
        l_Min_Amt            := 0;

        l_Receiving_State    := null;
        l_Servicing_State    := null;
        l_UT_Flag            := null;
        l_CGST_Rate          := null;
        l_SGST_Rate          := null;
        l_IGST_Rate          := null;

        o_Ret_Msg := 'selecting scheme details for Entity: ' || i.Ent_Id ||
                     ' and Date: ' || l_Pam_Curr_Dt;


        p_Get_Comm_Rate(i.Ent_Id,
                        i.buy_sell_flg,
                        i.Exm_Id,
                        i.Order_Type,
                        i.Holding_Mode,
                        i.Security_Id,
                        l_Scheme_Id,
                        l_Comm_Rate,
                        l_Comm_Amt_Per_Trade,
                        l_Min_Amt);

        IF l_Scheme_Id IS NULL THEN
          /*l_Brk_Amt      := 0;
          l_Set_Amt      := 0;
          l_Edu_Amt      := 0;
          l_High_Edu_Amt := 0;*/
          o_Ret_Msg := 'Default Scheme Not Found. Please Map Default Scheme to Proceed.';
          RAISE l_Exception;
        ELSE
          l_Brk_Amt := Round(i.Amount * (l_Comm_Rate/ 100),
                             2) + Nvl(l_Comm_Amt_Per_Trade, 0);

          IF l_Brk_Amt < Nvl(l_Min_Amt, 0) THEN
            l_Brk_Amt := l_Min_Amt;
          END IF;

          IF l_Brk_Amt > 0 THEN
            Pkg_GST_Computation.p_Populate_Client(i.Ent_Id, null);

            --Added for fetching and storing GST Details
            o_Ret_Msg := 'Getting GST State and Rate for Entity ID:'||i.Ent_Id;
            Pkg_Gst_Computation.P_Get_GST_State_And_Rate('M',
                                                         i.Ent_Id,
                                                         Null,
                                                         Null,
                                                         l_Receiving_State,
                                                         l_Servicing_State,
                                                         l_UT_Flag,
                                                         l_CGST_Rate,
                                                         l_SGST_Rate,
                                                         l_IGST_Rate);

            --Computing GST amount
            o_Ret_Msg := 'Computing GST for Entity ID:'||i.Ent_Id;
            Pkg_GST_Computation.P_Compute_Gst('M', i.Ent_Id, Null, Null, l_Brk_Amt, 'N',
                                                   l_Set_Amt, l_Edu_Amt, l_High_Edu_Amt);
          ELSE
            l_Set_Amt := 0;
            l_Edu_Amt := 0;
            l_High_Edu_Amt := 0;
          END If;
          /*l_Set_Amt      := Round(l_Brk_Amt *
                                  (l_Service_Tax_Rate / 100),
                                  2);
          l_Edu_Amt      := Round(l_Set_Amt *
                                  (l_Edu_Cess_Rate / 100),
                                  2);
          l_High_Edu_Amt := Round(l_Set_Amt *
                                  (l_High_Edu_Cess_Rate / 100),
                                  2);*/
        END IF;

        IF l_Prev_Ent_Id IS NULL OR Nvl(l_Prev_Ent_Id, '@@') <> i.Ent_Id THEN
          IF l_Prev_Ent_Id1 IS NULL OR Nvl(l_Prev_Ent_Id1, '@@') <> i.Ent_Id THEN
            l_Count_Contracts := l_Count_Contracts + 1;
          END IF;

          l_Prev_Ent_Id1 := i.ent_id;

          o_Ret_Msg := 'Getting Contract Number for Entity ID <'||i.Ent_Id||'> and Exch <'||i.Exm_Id||'>';
          BEGIN
            SELECT Cn_No
            INTO   l_Prev_Cn_No
            FROM   Mfss_Contract_Note
            WHERE  Exm_id           = i.Exm_Id
            AND    Transaction_Date = p_Date
            AND    Ent_Id           = i.Ent_Id
            AND    Rownum = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_Prev_Cn_No := NULL;
          END;

          IF l_Prev_Cn_No IS NULL THEN
            /*SELECT Nvl(MAX(To_Number(Substr(Cn_No, -7))), 0) + 1
            INTO   l_Seq
            FROM   Mfss_Contract_Note
            WHERE  Transaction_Date >= l_Financial_Year_Start
            AND    Exm_Id = p_Exm_Id;*/

            l_Mfss_Contract_Seq := l_Mfss_Contract_Seq +1;
            l_Seq := l_Mfss_Contract_Seq;

            l_Cn_No := p_Exm_Id||l_Mutual_Fund_Seg ||
                       To_Char(l_Pam_Curr_Dt, 'YYYYMMDD') ||
                       Lpad(l_Seq, 7, '0');
          END IF;

          o_Ret_Msg := 'Getting Contract Sequence Number for Entity ID <'||i.Ent_Id||'> and Exch <'||i.Exm_Id||'>';
          BEGIN
            SELECT NVL(MAX(Cnd_Seq_No),0)+1
            INTO   l_Seq_No
            FROM   Mfss_Contract_Note
            WHERE  Exm_Id           = i.Exm_Id
            AND    Transaction_Date = p_Date
            AND    Ent_Id           = i.Ent_Id
            AND    Cn_No            = Nvl(l_Prev_Cn_No, l_Cn_No);
          EXCEPTION
            WHEN OTHERS THEN
              l_Seq_No := 1;
          END;

        /*  o_Ret_Msg := 'Getting bill no for order no <' || i.Order_No ||
                       '> and client id <' || i.Ent_Id || '>';

          Pkg_FA_Entry_Mgmt.P_Get_Bld_No(l_Company_Id ,
                                         i.Exm_Id     ,
                                         l_Seg_Id     ,
                                         i.Ent_Id     ,
                                         NULL         ,
                                         NULL         ,
                                         'F'          ,
                                         l_Pam_Curr_Dt,
                                         NULL         ,
                                         'Y'          ,
                                         l_Blm_No     ,
                                         l_Bld_No     ,
                                         o_Ret_Msg);*/ 

         /* p_Get_Mfss_Bld_No(l_Company_Id,
                            i.Exm_Id,
                            NULL,
                            i.Ent_Id,
                            l_Pam_Curr_Dt,
                            'F',
                            l_Blm_No,
                            l_Bld_No);*/----mf changes
        ELSE
          l_Prev_Ent_Id := i.Ent_Id;
        END IF;

        o_Ret_Msg := 'Inserting into contract Note for order no <' ||
                     i.Order_No || '> and client id <' || i.Ent_Id || '>';

        INSERT INTO Mfss_Contract_Note
          (Cn_No,             Transaction_Date,        Exm_Id,
           Stc_Type,          Stc_No,                  Ent_Id,
           Status,            Amc_Scheme_Code,         Buy_Sell_Flag,
           Order_No,          Quantity,                Amount,
           Brokerage,         Service_Tax,             Edu_Cess,
           High_Edu_Cess,     Scheme_Id,               Holding_Mode,
           Created_By,        Created_Date,            Prg_Id,
           Bill_No,           Isin,                    Cnd_Seq_No/*,
           Cnd_Sip_Flag*/)
        VALUES
          (Nvl(l_Prev_Cn_No, l_Cn_No),
                              p_Date,                  i.Exm_Id,
           i.Settlement_Type,  i.Stc_No,                i.Ent_Id,
           'I',               i.Security_Id,           i.Buy_Sell_Flg,
           i.Order_No,        i.Quantity,              i.Amount,
           l_Brk_Amt,         l_Set_Amt,               l_Edu_Amt,
           l_High_Edu_Amt,    l_Scheme_Id,             i.Holding_Mode,
           USER,              SYSDATE,                 l_Prg_Id,
           l_Blm_No,          i.Isin,                  l_Seq_No/*,
           Decode(i.Order_Type,'SIP','Y','N')*/);

        /*IF l_Receiving_State IS NOT NULL THEN
          INSERT INTO Mfss_Contract_Note_Add_Info
            (CN_NO,                       CND_SEQ_NO      ,        ENT_GST_STATE   ,
             ENT_BRANCH_STATE,            ENT_UT_FLAG     ,        CGST_RATE       ,
             SGST_RATE       ,            IGST_RATE)
          VALUES
            (Nvl(l_Prev_Cn_No, l_Cn_No),  l_Seq_No        ,        l_Receiving_State,
             l_Servicing_State,           l_UT_Flag       ,        l_CGST_Rate      ,
             l_SGST_Rate      ,           l_IGST_Rate);
        END IF;*/

        l_Count_Order := l_Count_Order + 1;

       /* IF (l_Brk_Amt > 0 OR l_Set_Amt > 0 OR l_Edu_Amt > 0 OR l_High_Edu_Amt > 0 ) THEN
          SELECT Nvl(MAX(Bld_No), 0) + 1
          INTO   l_Bld_No
          FROM   Bill_Details
          WHERE  Bld_Blm_No = l_Blm_No
          AND    Bld_Blm_Status = 'F'
          AND    Bld_Blm_Cpd_Id = l_Company_Id;
        END IF;*/

        o_Ret_Msg := 'Inserting bills for Entity ID <'||i.Ent_Id||'> and Order No. <'||i.Order_No||'>';
        Insert_Bill('BRK', l_Brk_Amt, i.Order_No, i.Ent_Id, i.Exm_Id, i.Stc_No, i.Settlement_Type);
        Insert_Bill('SET', l_Set_Amt, i.Order_No, i.Ent_Id, i.Exm_Id, i.Stc_No, i.Settlement_Type, 'Y');
        Insert_Bill('EDU', l_Edu_Amt, i.Order_No, i.Ent_Id, i.Exm_Id, i.Stc_No, i.Settlement_Type, 'Y');
        Insert_Bill('HDU', l_High_Edu_Amt, i.Order_No, i.Ent_Id, i.Exm_Id, i.Stc_No, i.Settlement_Type, 'Y');
       /* IF i.Buy_Sell_Flg = 'P' THEN
          o_Ret_Msg := 'Inserting Purchase bill for Entity ID <'||i.Ent_Id||'> and Order No. <'||i.Order_No||'>';
          Insert_Bill('FPI', i.Amount, i.Order_No, i.Ent_Id, i.Exm_Id, i.Stc_No, i.Settlement_Type);
        END IF;*/ ----mf changes

        IF l_Blm_No_Prev <> l_Blm_No THEN
          l_Count_Bills := l_Count_Bills + 1;
          l_Blm_No_Prev := l_Blm_No;
        END IF;

        IF l_Prev_Cn_No IS NULL THEN
          UPDATE Mfss_Trades
          SET    Bill_No      = l_Blm_No,
                 Contract_No  = l_Cn_No,
                 Last_Updt_Dt = SYSDATE,
                 Last_Updt_By = USER
          WHERE  ROWID = i.ROWID;
        ELSE
          UPDATE Mfss_Trades
          SET    Bill_No      = l_Blm_No,
                 Contract_No  = l_Prev_Cn_No,
                 Last_Updt_Dt = SYSDATE,
                 Last_Updt_By = USER
          WHERE  ROWID = i.ROWID;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          l_Count_Skip := l_Count_Skip + 1;
          o_Ret_Msg    := dbms_utility.format_error_backtrace||
                          '**Error while ' || o_Ret_Msg ||
                          '**Error message is :' || SQLERRM;
          Utl_File.New_Line(l_Log_File_Ptr, 2);
          Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
          Utl_File.Put_Line(l_Log_File_Ptr,
                            'Skipping contract note generation for order no <' ||
                            i.Order_No || '> and client <' || i.Ent_Id || '>');
      END;
    END LOOP;

    o_Ret_Val := 'SUCCESS';
    o_Ret_Msg := 'Process completed successfully ';

    IF l_Count_Skip > 0 THEN
      Std_Lib.l_Partial_Run_Yn := 'Y';
    END IF;

    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Contracts Generated : ' ||l_Count_Contracts );-- || ', for total clients : '||l_Count_Contracts);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Orders Processed : ' ||l_Count_Order);-- || ', for total clients : '||l_Count_Contracts);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Bills Generated : ' ||l_Count_Bills);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Contracts Skipped : ' ||l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' Process Completed Successfully !!! ');

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Dt,
                            l_Process_Id,
                            'C',
                            'Y',
                            o_Sqlerrm);

    Utl_File.New_Line(l_Log_File_Ptr, 2);
    Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN l_Exception THEN
      ROLLBACK;
      o_Ret_Val := 'FAIL';
      o_Ret_Msg := dbms_utility.format_error_backtrace||
                   '**Error while ' || o_Ret_Msg ||
                   '**Error message is :' || SQLERRM;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Sqlerrm);
      Utl_File.New_Line(l_Log_File_Ptr, 2);
      Utl_File.Put_Line(l_Log_File_Ptr, 'Process Failed ');
      Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);

    WHEN OTHERS THEN
      ROLLBACK;
      o_Ret_Val := 'FAIL';
      o_Ret_Msg := dbms_utility.format_error_backtrace||
                   '**Error while ' || o_Ret_Msg ||
                   '**Error message is :' || SQLERRM;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Sqlerrm);
      Utl_File.New_Line(l_Log_File_Ptr, 2);
      Utl_File.Put_Line(l_Log_File_Ptr, 'Process Failed ');
      Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);
  END p_Mfss_Contracting;

  --Procedure for downloading funds obligation report

  --Load  Funds Obligation

  PROCEDURE p_Dwnld_Funds_Obligation_Rep(p_File_Name IN VARCHAR2,
                                         p_Exch_Id   IN VARCHAR2,
                                         p_Stc_No    IN VARCHAR2,
                                         p_Settlement_Type IN VARCHAR2,
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

    l_User_Mode VARCHAR2(30);
    Line_No     NUMBER := 0;

    l_Order_Dt     VARCHAR2(30);
    l_Order_Date   DATE;
    l_Sett_Date    DATE;
    l_Stc_No       VARCHAR(30);
    l_Member_Code  VARCHAR2(10);
    l_Ent_Id       VARCHAR(30);
    l_Dp_Id        VARCHAR(30);
    l_Dp_Acc_No    VARCHAR(30);
    l_Order_No     VARCHAR(30);
    l_Buy_Sell_Flg VARCHAR(30);
    l_Scheme_Code  VARCHAR(30);
    l_Isin         VARCHAR(30);
    l_Amount       NUMBER(18, 2) := 0;
    l_Order_Status VARCHAR(100);
    l_Remarks      VARCHAR(300);

    l_Count_Inserted      NUMBER := 0;
    l_Count_Skip          NUMBER := 0;
    l_Count_Records       NUMBER := 0;
    l_Nse_Broker_Cd   VARCHAR2(30);
    l_Bse_Broker_Cd   VARCHAR2(30);
    l_Mutual_Fund_Seg VARCHAR2(30);
    l_Security_Id     VARCHAR2(30);
    l_Symbol          VARCHAR2(30);
    l_Series          VARCHAR2(30);
    l_Stc_Type        VARCHAR2(30);

    l_Prg_Id  VARCHAR2(30) := 'CSSBCFOBG';
    l_Message VARCHAR2(3000);

    l_Internal_Ref_No VARCHAR2(10);
    l_Order_Type      VARCHAR2(3);
    l_Sip_Regn_No     VARCHAR2(4000);
    l_Sip_Regn_Date   DATE;

    Excp_Terminate EXCEPTION;
    Excp_Skip EXCEPTION;
    Excp_Sch_Cd_Missing EXCEPTION;

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
                           p_Stc_No || '-' || p_Exch_Id || ',' ||
                           p_File_Name,
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
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');

/*    p_Ret_Msg := 'Checking if the process is already run for the day';
    SELECT COUNT(*)
    INTO   l_Count_Process_Check
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = l_Prg_Id
    AND    Prg_Dt = l_Pam_Curr_Date
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Check > 0 THEN
      p_Ret_Msg := ' Funds Obligation report is already loaded for the day for exchange <' ||
                   p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;*/

    p_Ret_Msg := 'Getting the trace mode for the program .';
    SELECT Prg_Trace_Level
    INTO   l_User_Mode
    FROM   Programs
    WHERE  Prg_Id = l_Prg_Id;

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
        IF l_User_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Record.DELETE;
        ------------------------------------------------------------------------------------------------------
        --      calling standard Procedure Split_Line to split the records . Here line separator is '~' Tilda
        -----------------------------------------------------------------------------------------------------
        p_Ret_Msg := '3: Splitting fields in the line buffer';
        
        -- P_log( 'Before Splitting fields-'||Tab_File_Records(Line_No),2);
         
        IF p_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             '|',
                             Tab_Split_Record);
        ELSIF p_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             ',',
                             Tab_Split_Record);
        END IF;

        IF l_User_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,
                              '<' || i || '>' || ' = <' ||
                              Tab_Split_Record(i) || '>');
          END LOOP;
        END IF;
        
       
        l_Order_Date   := NULL;
        l_Sett_Date    := NULL;
        l_Stc_No       := NULL;
        l_Stc_Type     := NULL;
        l_Member_Code  := NULL;
        l_Ent_Id       := NULL;
        l_Dp_Id        := NULL;
        l_Dp_Acc_No    := NULL;
        l_Order_No     := NULL;
        l_Buy_Sell_Flg := NULL;
        l_Scheme_Code  := NULL;
        l_Isin         := NULL;
        l_Amount       := NULL;
        l_Order_Status := NULL;
        l_Remarks      := NULL;
        l_Symbol       := NULL;
        l_Series       := NULL;
        l_Security_Id  := NULL;

        l_Internal_Ref_No := NULL;
        l_Order_Type      := NULL;
        l_Sip_Regn_No     := NULL;
        l_Sip_Regn_Date   := NULL;

        IF p_Exch_Id = 'BSE' THEN
          l_Order_Date      := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),
                                       'YYYY-MM-DD');
          l_Sett_Date       := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),
                                       'YYYY-MM-DD');
          l_Stc_Type        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Stc_No          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Dp_Id           := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Scheme_Code     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Isin            := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Amount          := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
          l_Internal_Ref_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Order_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));
          l_Sip_Regn_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));

          BEGIN
            l_Sip_Regn_Date := Nvl(To_Char(To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16)),
                                                   'DD/MM/YYYY'),
                                           'DD-MON-YYYY'),
                                   '');
          EXCEPTION
            WHEN No_Data_Found THEN
              NULL;
          END;
          
         -- P_log( 'Before l_Security_Id-'||l_Scheme_Code,1);
          BEGIN
             SELECT Msm_Scheme_Id
             INTO  l_Security_Id
             FROM  Mfd_Scheme_Master
             WHERE (Msm_Bse_Code = l_Scheme_Code OR MSM_BSE_LO_SCHEME_CODE = l_Scheme_Code OR MSM_BSE_L1_SCHEME_CODE = l_Scheme_Code)   -- L0
             AND   Msm_Status = 'A'
             AND   Msm_Record_Status = 'A'
             AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
              WHEN No_Data_Found THEN
                RAISE Excp_Sch_Cd_Missing;
          END;

             --l_Security_Id := l_Scheme_Code;
          IF l_Member_Code NOT LIKE '%' || l_Bse_Broker_Cd || '%' THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Code ||
                         '> of file does not match with the BSE member code <' ||
                         l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;

          IF p_Settlement_Type = 'N' THEN
            IF l_Stc_Type <> 'MF' THEN
               p_Ret_Msg := 'Settlement type <'|| l_Stc_Type ||'> of the file
                            does not match with the settlement type MF' ;
                RAISE Excp_Terminate;
            END IF;
          END IF;

        ELSIF p_Exch_Id = 'NSE' THEN
          l_Order_Dt := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

          IF l_Order_Dt = 'Order Date' THEN
            RAISE Excp_Skip; ---Header record . hence skipping the same.
          END IF;

          l_Order_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),
                                    'DD-MM-RRRR');
          l_Sett_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),
                                    'DD-MM-RRRR');
          l_Stc_Type        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Stc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Dp_Id        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));

          IF l_Buy_Sell_Flg = 'S' THEN
            l_Buy_Sell_Flg := 'P';
          END IF;

          l_Symbol := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Series := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Amount := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));

/*          l_Internal_Ref_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Order_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));
          l_Sip_Regn_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));
*/--Commented as per the NSE file structure.
          BEGIN
            l_Sip_Regn_Date := Nvl(To_Char(To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16)),
                                                   'DD/MM/YYYY'),
                                           'DD-MON-YYYY'),
                                   '');
          EXCEPTION
            WHEN No_Data_Found THEN
              NULL;
          END;

          BEGIN
             SELECT Msm_Scheme_Id
             INTO  l_Security_Id
             FROM  Mfd_Scheme_Master
             WHERE Msm_Nse_Code = l_Symbol || l_Series
             AND   Msm_Status = 'A'
             AND   Msm_Record_Status = 'A'
             AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
              WHEN No_Data_Found THEN
                RAISE Excp_Sch_Cd_Missing;
          END;
          --l_Security_Id := l_Symbol || l_Series;
          l_Scheme_Code := l_Symbol || l_Series;

        SELECT MAX(a.Msm_Isin)
        INTO   l_Isin
        FROM   Mfd_Scheme_Master a
        WHERE  a.Msm_Scheme_Id = l_Security_Id
        --AND    a.Msm_Nse_Code  = l_Symbol
        AND    a.Msm_Status    = 'A'
        AND    Msm_Record_Status = 'A'
        AND    l_Pam_Curr_Date BETWEEN a.Msm_From_Date AND NVL(a.Msm_To_Date,l_Pam_Curr_Date);

          IF l_Member_Code != l_Nse_Broker_Cd THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Code ||
                         '> of file does not match with the BSE member code <' ||
                         l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;
        END IF;

        /* P_Ret_msg  := 'Verifying date format for order no <'||l_Order_No||'>.';
        IF  l_Order_Date  != l_Pam_Curr_Date THEN
          Utl_File.Put_Line(l_Log_File_Handle,'Order Date <'||l_Order_Date||'> ,does not match with the system date  <'||l_Pam_Curr_Date||'>.');
          RAISE Excp_Terminate;
        END IF; */

        BEGIN
          p_Ret_Msg := 'Inserting Trades for order no  <' || l_Order_No ||
                       '>, Client <' || l_Ent_Id || '> , Scheme , ' ||
                       l_Security_Id || '> ,Sett No. < ' || l_Stc_No ||
                       '> and   order type <' || l_Buy_Sell_Flg || '>';

          INSERT INTO Mfss_Funds_Obligation
            (Order_Date,
             Sett_Date,
             Order_No,
             Ent_Id,
             Exm_Id,
             Stc_Type,
             Stc_No,
             Buy_Sell_Flg,
             Amc_Scheme_Code,
             Isin,
             Amount,
             Member_Code,
             Dp_Id,
             Dp_Acc_No,
             Creat_Dt,
             Creat_By,
             Prg_Id,
             Security_Id,
             Symbol,
             Series,
             Internal_Ref_No,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Mfo_L0_NonL0)
          VALUES
            (l_Order_Date,
             l_Sett_Date,
             l_Order_No,
             l_Ent_Id,
             p_Exch_Id,
             l_Stc_Type/*l_Mutual_Fund_Seg*/,
             l_Stc_No,
             l_Buy_Sell_Flg,
             l_Scheme_Code,
             l_Isin,
             l_Amount,
             l_Member_Code,
             l_Dp_Id,
             l_Dp_Acc_No,
             SYSDATE,
             USER,
             l_Prg_Id,
             l_Security_Id,
             l_Symbol,
             l_Series,
             l_Internal_Ref_No,
             l_Order_Type,
             l_Sip_Regn_No,
             l_Sip_Regn_Date,
             Decode(p_Settlement_Type,'L','L01','NL0'));
          l_Count_Inserted := l_Count_Inserted + 1;

        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            IF l_User_Mode = 'ADMIN' THEN
              Utl_File.Put_Line(l_Log_File_Handle,
                                'Confirmation record Exists for order no  <' ||
                                l_Order_No || '>, Client <' || l_Ent_Id ||
                                '> , Scheme , ' || l_Scheme_Code ||
                                '> ,Sett No. < ' || l_Stc_No ||
                                '> and   order type <' || l_Buy_Sell_Flg ||
                                '>.Hence Skipping the record.');
            END IF;
            l_Count_Skip := l_Count_Skip + 1;
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
                               ||' For DP Acc No <'||l_Dp_Acc_No||'>'
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

    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records in File                   : ' ||
                      l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records Inserted                  : ' ||
                      l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records already Processed         : ' ||
                      l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);
    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';
  EXCEPTION
    WHEN Excp_Terminate THEN
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||
                   '***Error Occured while : ' || p_Ret_Msg ||
                   '***Error Message : ' || SQLERRM;
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
      p_Ret_Msg := dbms_utility.format_error_backtrace||
                   '***Error Occured while : ' || p_Ret_Msg ||CHR(10)||
                   '***Error Message : ' || SQLERRM;
      Utl_File.Put_Line(l_Log_File_Handle, p_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Handle);
      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Date,
                              l_Prg_Process_Id,
                              'E',
                              'Y',
                              l_Message);

  END p_Dwnld_Funds_Obligation_Rep;

  --Procedure for generating funds confirmation statement

  --Gen.  Funds Confirmation

  PROCEDURE p_Gen_Funds_Confirmation_Stmt(P_Mode    IN VARCHAR2,
                                          p_Exch_Id IN VARCHAR2,
                                          p_Gen_Dt  IN DATE,
                                          p_Stc_No  IN VARCHAR2,
                                          p_Settlement_Type IN VARCHAR2,
                                          p_Ret_Val IN OUT VARCHAR2,
                                          p_Ret_Msg IN OUT VARCHAR2) IS
    l_Pam_Curr_Date DATE;
    l_Pam_Last_Date DATE;
    --l_File_Path       VARCHAR2(300);
    l_Log_File_Handle Utl_File.File_Type;
    l_Log_File_Name   VARCHAR2(100);
    l_Prg_Process_Id  NUMBER := 0;
    --l_Line_Count      NUMBER := 0  ;

    --Tab_File_Records  Std_Lib.tab ;
    --Tab_Split_Record  Std_Lib.tab ;

    --l_count_Process_Check    NUMBER := 0;
    l_Count_Process_Obg_Rep NUMBER := 0;
    l_Batch_No              VARCHAR2(30);
    l_Count_Bill_Reversed   NUMBER := 0;

    l_Datafile_Handle Utl_File.File_Type;
    l_Datafile_Name   VARCHAR2(300);
    l_Datafile_Path   VARCHAR2(300);
    l_Cnt_Cancelled   NUMBER := 0;

    l_Count           NUMBER := 0;
    l_Count_Lq         NUMBER := 0;

    l_Prg_Id              VARCHAR2(30) := 'CSSBCFCNS';
    l_Message             VARCHAR2(3000);
    l_Cnt_Bill_Reversed   NUMBER := 0;
    l_Cnt_Order_Reversed  NUMBER := 0;
    l_Rev_Ret_Msg         VARCHAR2(3000);

    CURSOR c_Funds_Stmt IS
      SELECT t.*,Rownum Rn FROM
      (SELECT t.Order_Date Order_Date,
             Decode(o.Exm_Id,
                    'BSE',
                    To_Char(t.Order_Date, 'RRRR-MM-DD'),
                    'NSE',
                    To_Char(t.Order_Date, 'DD-MON-RRRR')) Order_Dt,
             Decode(o.Exm_Id,
                    'BSE',
                    To_Char(o.Sett_Date, 'RRRR-MM-DD'),
                    'NSE',
                    To_Char(o.Sett_Date, 'DD-MON-RRRR')) Sett_Dt,
             t.Settlement_Type Sett_Type,
             o.Stc_No Sett_No,
             o.Member_Code Member_Cd,
             o.Ent_Id Client_Cd,
             o.Dp_Id Dp_Id,
             o.Dp_Acc_No Dp_Acc_No,
             o.Order_No Order_No,
             o.Buy_Sell_Flg Buy_Sell,
             o.Amc_Scheme_Code Scheme_Id,
             o.Symbol Symbol,
             o.Series Series,
             o.Isin Isin,
             o.Amount Amount,
             o.Security_Id Security_Id,
             Nvl(t.Mfss_Funds_Payin_Success_Yn, 'N') Status,
             e.ent_mf_ucc_code mf_ucc_code,
             Decode(t.Mfss_Funds_Payin_Success_Yn,
                    'Y',
                    'Payin Done',
                    'Insufficient Balance') Remarks,
             Dp_Name
      FROM   Mfss_Trades           t,entity_master e,
             Mfss_Funds_Obligation o
      WHERE  t.Order_No = o.Order_No
      AND    t.ent_id = e.ent_id
      AND    t.Exm_Id = o.Exm_Id
      AND    t.Stc_No = o.Stc_No
      AND    t.Buy_Sell_Flg = o.Buy_Sell_Flg
      AND    t.Ent_Id = o.Ent_Id
      AND    t.Security_Id = o.Security_Id
      AND     t.Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','N','MF','A',Settlement_Type)),
                                    Decode(p_Settlement_Type,'L','L1'))
      AND    t.Buy_Sell_Flg = 'P'
      AND    t.Order_Date = o.Order_Date
      AND    NVL(Order_Stc_Type,'X') = Decode(p_Settlement_Type,'N','NFOT',NVL(Order_Stc_Type,'X'))
      AND    t.Order_Date = p_Gen_Dt
      AND    o.Exm_Id = p_Exch_Id
      AND    p_Exch_Id = 'BSE'
      AND    Nvl(o.Fund_Conf_Stmt_Gen_Flg, 'N') = 'N'
      UNION ALL
      SELECT t.Order_Date Order_Date,
             Decode(o.Exm_Id,
                    'BSE',
                    To_Char(t.Order_Date, 'RRRR-MM-DD'),
                    'NSE',
                    To_Char(t.Order_Date, 'DD-MON-RRRR')) Order_Dt,
             Decode(o.Exm_Id,
                    'BSE',
                    To_Char(o.Sett_Date, 'RRRR-MM-DD'),
                    'NSE',
                    To_Char(o.Sett_Date, 'DD-MON-RRRR')) Sett_Dt,
             t.Settlement_Type Sett_Type,
             o.Stc_No Sett_No,
             o.Member_Code Member_Cd,
             o.Ent_Id Client_Cd,
             o.Dp_Id Dp_Id,
             o.Dp_Acc_No Dp_Acc_No,
             o.Order_No Order_No,
             o.Buy_Sell_Flg Buy_Sell,
             o.Amc_Scheme_Code Scheme_Id,
             o.Symbol Symbol,
             o.Series Series,
             o.Isin Isin,
             o.Amount Amount,
             o.Security_Id Security_Id,
             Nvl(t.Mfss_Funds_Payin_Success_Yn, 'N') Status,
             e.ent_mf_ucc_code mf_ucc_code,
             Decode(t.Mfss_Funds_Payin_Success_Yn,
                    'Y',
                    'Payin Done',
                    'Insufficient Balance') Remarks,
             Dp_Name
      FROM   Mfss_Trades           t, entity_master e,
             Mfss_Funds_Obligation o
      WHERE  t.Order_No = o.Order_No
      AND    t.ent_id = e.ent_id
      AND    t.Exm_Id = o.Exm_Id
      AND    t.Stc_No = o.Stc_No
      AND    t.Buy_Sell_Flg = o.Buy_Sell_Flg
      AND    t.Ent_Id = o.Ent_Id
      AND    t.Security_Id = o.Security_Id
      AND     t.Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','N','MF','A',Settlement_Type)),
                                     Decode(p_Settlement_Type,'L','L1'))
      AND    t.Buy_Sell_Flg = 'P'
      AND    t.Order_Date = o.Order_Date
      AND    NVL(Order_Stc_Type,'X') = Decode(p_Settlement_Type,'N','NFOT',NVL(Order_Stc_Type,'X'))
      AND    t.Order_Date = p_Gen_Dt
      AND    o.Exm_Id = p_Exch_Id
      AND    p_Exch_Id = 'NSE'
      AND    ( Trade_Status = 'M' OR Mfss_Funds_Payin_Success_Yn = 'N' )
      AND    Nvl(o.Fund_Conf_Stmt_Gen_Flg, 'N') = 'N')t
      ORDER  BY rn,
                Order_Date,
                Client_Cd,
                Security_Id;

    CURSOR c_Funds_Stmt_LQ IS
      SELECT  Order_Date,
              Order_No,
              Scheme_Symbol Symbol,
              Scheme_Series Series,
              a.Ent_Id Client_Cd,
              c.Rv_High_Value Brk_Client_Id,
              Bkm_Name Bank_Name,
              Rv_Low_Value Ent_Acc_No,
              NULL Utr_No,
              Amount,
              Decode(Nvl(a.Mfss_Funds_Payin_Success_Yn,'N'),'Y','Y','N') Confirm,
              Member_Code Member_Cd,
              Security_Id,
              Stc_No,
              ent.ent_mf_ucc_code mf_ucc_code,
              Buy_Sell_Flg Buy_Sell
      FROM  Mfss_Trades a,
            Bank_Account_Master Bam,
            Bank_Master b,
            Entity_Master Ent,
            Cg_Ref_Codes c
      WHERE Exm_Id = 'NSE'
      AND   bam_ent_id = Ent.Ent_id
      AND    Bam.Bam_Bkm_Cd = b.Bkm_Cd
      AND    Settlement_Type IN ('L0','L1')
      AND   Scheme_Series IN ('LQ','DP','DR','GR')
      AND   Bam.Bam_no = Rv_Low_Value
      AND   Ent_Type = 'BR'
      AND   RV_DOMAIN = 'MFSS_ACC_BAM_NO'
      AND   Buy_Sell_Flg = 'P'
      AND    Stc_No         = NVL(p_Stc_No,Stc_No)
      AND    Order_Date = p_Gen_Dt
      AND   Fund_Conf_Stmt_Gen_Flg = 'N'
      ORDER  BY Order_Date,
                Ent.Ent_Id,
                Security_Id;

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
                           P_Mode||'-'||p_Settlement_Type||'-'||p_Stc_No || '-' || p_Exch_Id, --Initial mode
                           'E',
                           l_Log_File_Handle,
                           l_Log_File_Name,
                           l_Prg_Process_Id);

    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Current Working Date    : ' ||
                      To_Char(l_Pam_Curr_Date, 'DD-MON-YYYY'));
    Utl_File.New_Line(l_Log_File_Handle, 1);
    Utl_File.Put_Line(l_Log_File_Handle, ' Parameters Passed  :');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Generation Date             : ' || p_Gen_Dt);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');

    p_Ret_Msg := 'Checking if the Funds obligation report is loaded ';
    IF (p_Exch_Id = 'NSE' AND p_Settlement_Type = 'A' OR p_Exch_Id = 'BSE' AND p_Settlement_Type  IN ('A','L','N') ) THEN
    SELECT COUNT(*)
    INTO   l_Count_Process_Obg_Rep
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = 'CSSBCFOBG'
    AND    Prg_Dt = p_Gen_Dt
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Obg_Rep = 0 THEN
      p_Ret_Msg := ' Funds Obligation is not loaded for exchange <' ||
                   p_Exch_Id || '> and Date <' || p_Gen_Dt ||
                   '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;
    END IF;

    p_Ret_Msg := 'Getting Datafile path for generating funds confirmation file .';
    SELECT Rv_High_Value
    INTO   l_Datafile_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    IF   p_Settlement_Type = 'L' AND p_Exch_Id = 'NSE' THEN
      FOR i IN c_Funds_Stmt_LQ
      LOOP
        IF l_Count_LQ = 0 THEN
          SELECT Lpad(Mfss_Batch_Seq.NEXTVAL, 5, '0')
          INTO   l_Batch_No
          FROM   Dual;

          p_Ret_Msg := 'LQ Series confirmation file naming';
          l_Datafile_Name := 'M_' || i.Member_Cd ||'_' ||'ORDC'||'_' ||
                             To_Char(l_Pam_Curr_Date, 'DDMMRRRR') || /*'_' ||
                             l_Batch_No ||*/ '.csv';

          p_Ret_Msg         := 'Opening File <' || l_Datafile_Name ||
                               '> to write .';
          l_Datafile_Handle := Utl_File.Fopen(l_Datafile_Path,l_Datafile_Name,'W');


        Utl_File.Put_Line(l_Datafile_Handle,
                          'TM code' || ',' ||'Order date' || ',' || 'Order no.'|| ',' ||
                          'Symbol' || ',' || 'Series' || ',' ||
                          'Client code' || ',' || 'Client Bank name' || ',' ||
                          'Client Bank a/c No.'|| ',' || 'UTR no.' || ',' ||
                          'Value (Rs.)' || ',' || 'Confirm' );
        END IF;


        Utl_File.Put_Line(l_Datafile_Handle,
                          i.Member_Cd || ',' || To_Char(i.Order_Date,'DDMMRRRR') || ',' || i.Order_No || ',' ||
                          i.Symbol || ',' || i.Series || ',' ||
                          nvl(i.Brk_Client_Id,i.mf_ucc_code) || ',' || i.Bank_Name || ',' ||
                          i.Ent_Acc_No|| ',' || i.utr_no || ',' ||
                          i.Amount || ',' || i.Confirm );


        l_Count_LQ := l_Count_LQ + 1;


        IF P_Mode = 'F' THEN

          p_Ret_Msg := 'Updating  Mfss_Trades  for order no  <' || i.Order_No ||
                       '>, Client <' || i.Client_Cd || '> , Scheme , ' ||
                       i.Security_Id || '> ,Sett No. < ' || i.stc_no || '> ';

          UPDATE Mfss_Trades
          SET    Fund_Conf_Stmt_Gen_Flg = 'Y',
                 Last_Updt_By           = USER,
                 Last_Updt_Dt           = SYSDATE
          WHERE  Order_No = i.Order_No
          AND    Exm_Id = p_Exch_Id
          AND    Stc_No = i.Stc_no
          AND    Buy_Sell_Flg = 'P'
          AND    Ent_Id = i.Client_Cd
          AND    Security_Id = i.Security_Id
          AND    Order_Date = i.Order_Date
          AND    Nvl(Fund_Conf_Stmt_Gen_Flg, 'N') = 'N'
          AND    Mfss_Funds_Payin_Success_Yn = 'Y';

          p_Ret_Msg := 'Reversing Bills for order no  <' || i.Order_No ||
                       '>, Client <' || i.Client_Cd || '> ';
          IF i.Confirm = 'N' THEN
            p_Reverse_Bills(i.Client_Cd,
                            i.Order_No,
                            i.Order_Date,
                            i.Buy_Sell,
                            p_Exch_Id,
                            i.stc_no,
                            i.Security_Id,
                            'GENERATE FUNDS CONFIRMATION',
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

            IF l_Count_Bill_Reversed > 0 THEN
              l_Cnt_Order_Reversed := l_Cnt_Order_Reversed + 1;
              l_Cnt_Bill_Reversed  := l_Cnt_Bill_Reversed +
                                      l_Count_Bill_Reversed;
            END IF;
          END IF;
        END IF;

      END LOOP;
    ELSE
     FOR i IN c_Funds_Stmt
      LOOP
        IF l_Count = 0 THEN
          SELECT Lpad(Mfss_Batch_Seq.NEXTVAL, 5, '0')
          INTO   l_Batch_No
          FROM   Dual;

          IF P_Mode ='F' THEN
            IF p_Exch_Id = 'BSE' THEN
              l_Datafile_Name := i.Sett_No || '_' || i.Member_Cd ||
                                 '_CLIENTFUNDSTMT.txt';

            ELSIF p_Exch_Id = 'NSE' THEN
              l_Datafile_Name := 'M_' || i.Member_Cd || '_COBG_' ||
                                 To_Char(l_Pam_Curr_Date, 'DDMMRRRR') || '_' ||
                                 '01' || '.csv';
            END IF;
          ELSE
           IF p_Exch_Id = 'BSE' THEN
              l_Datafile_Name := i.Sett_No || '_' || i.Member_Cd || To_Char(l_Pam_Curr_Date, 'DDMMRRRR') ||
                                 '_CLIENTFUNDINITIAL.txt';

            ELSIF p_Exch_Id = 'NSE' THEN
              l_Datafile_Name := 'M_' || i.Member_Cd || '_COBG_' ||
                                 To_Char(l_Pam_Curr_Date, 'DDMMRRRR') || '_' ||
                                 '01' || '.csv';
            END IF;
          END IF;
          p_Ret_Msg         := 'Opening File <' || l_Datafile_Name ||
                               '> to write .';
          l_Datafile_Handle := Utl_File.Fopen(l_Datafile_Path,
                                              l_Datafile_Name,
                                              'W');

        END IF;

        IF p_Exch_Id = 'BSE' THEN
          Utl_File.Put_Line(l_Datafile_Handle,
                            i.Order_Dt || '|' || i.Sett_Dt || '|' ||
                            i.Sett_Type || '|' || i.Sett_No || '|' ||
                            i.Member_Cd || '|' || i.mf_ucc_code || '|' ||
                            i.Dp_Id || '|' || i.Dp_Acc_No || '|' ||
                            i.Order_No || '|' || i.Buy_Sell || '|' ||
                            i.Scheme_Id || '|' || i.Isin || '|' || i.Amount || '|' ||
                            i.Status || '|' || i.Remarks);

          l_Count := l_Count + 1;
        ELSIF p_Exch_Id = 'NSE' THEN

          IF i.rn = 1 THEN
              Utl_File.Put_Line(l_Datafile_Handle,
                                  'Order Date' || ',' || 'Settlement Date' || ',' ||
                                  'Settlement type' || ',' || 'Settlement No.' || ',' ||
                                  'TM Code' || ',' || 'Client Code' || ',' ||
                                  'Depository ID' || ',' || 'DP Client ID' || ',' ||
                                  'Order No.' || ',' || 'Order Indicator' || ',' ||
                                  'Symbol' || ',' || 'Series' || ',' || 'Amount' || ',' ||
                                  'Confirmation flag');
          END IF;

          Utl_File.Put_Line(l_Datafile_Handle,
                            To_Char(to_date(i.Order_Dt),'DDMMYYYY') || ',' || To_Char(To_date(i.Sett_Dt),'DDMMYYYY') || ',' ||
                            'S' || ',' || i.Sett_No || ',' ||
                            i.Member_Cd || ',' || i.mf_ucc_code || ',' ||
                            CASE WHEN i.Dp_Name = 'NSDL' THEN 'IN300126' WHEN i.Dp_Name = 'CDSL' THEN NULL ELSE NULL END || ',' ||
                            CASE WHEN i.Dp_Name = 'NSDL' THEN '11178642' WHEN i.Dp_Name = 'CDSL' THEN '1301240000005785' ELSE NULL END|| ',' ||
                            i.Order_No || ',' || 'S' || ',' ||
                            i.Symbol || ',' || i.Series || ',' || Trim(To_Char(i.Amount,'99999999999990D99')) || ',' ||
                            i.Status);

          l_Count := l_Count + 1;
        END IF;

        IF P_Mode = 'F' THEN
          p_Ret_Msg := 'Updating the Mfss_Funds_Obligations for order no  <' ||
                       i.Order_No || '>, Client <' || i.Client_Cd ||
                       '> , Scheme , ' || i.Security_Id || '> ,Sett No. < ' ||
                       i.Sett_No || '> ';
          UPDATE Mfss_Funds_Obligation
          SET    Fund_Conf_Stmt_Gen_Flg = 'Y',
                 Funds_Conf_Gen_File    = l_Datafile_Name,
                 Batch_No               = l_Batch_No,
                 Last_Updt_By           = USER,
                 Last_Updt_Dt           = SYSDATE
          WHERE  Order_No = i.Order_No
          AND    Exm_Id = p_Exch_Id
          AND    Stc_No = i.Sett_No
          AND    Buy_Sell_Flg = 'P'
          AND    Ent_Id = i.Client_Cd
          AND    Security_Id = i.Security_Id
          AND    Order_Date = i.Order_Date
          AND    Nvl(Fund_Conf_Stmt_Gen_Flg, 'N') = 'N';

          p_Ret_Msg := 'Updating  Mfss_Trades  for order no  <' || i.Order_No ||
                       '>, Client <' || i.Client_Cd || '> , Scheme , ' ||
                       i.Security_Id || '> ,Sett No. < ' || i.Sett_No || '> ';

          UPDATE Mfss_Trades
          SET    Fund_Conf_Stmt_Gen_Flg = 'Y',
                 Last_Updt_By           = USER,
                 Last_Updt_Dt           = SYSDATE
          WHERE  Order_No = i.Order_No
          AND    Exm_Id = p_Exch_Id
          AND    Stc_No = i.Sett_No
          AND    Buy_Sell_Flg = 'P'
          AND    Ent_Id = i.Client_Cd
          AND    Security_Id = i.Security_Id
          AND    Order_Date = i.Order_Date
          AND    Nvl(Fund_Conf_Stmt_Gen_Flg, 'N') = 'N';

          p_Ret_Msg := 'Reversing Bills for order no  <' || i.Order_No ||
                       '>, Client <' || i.Client_Cd || '> ';
          IF i.Status = 'N' THEN
            p_Reverse_Bills(i.Client_Cd,
                            i.Order_No,
                            i.Order_Date,
                            i.Buy_Sell,
                            p_Exch_Id,
                            i.Sett_No,
                            i.Security_Id,
                            'GENERATE FUNDS CONFIRMATION',
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

            IF l_Count_Bill_Reversed > 0 THEN
              l_Cnt_Order_Reversed := l_Cnt_Order_Reversed + 1;
              l_Cnt_Bill_Reversed  := l_Cnt_Bill_Reversed +
                                      l_Count_Bill_Reversed;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;
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
    IF l_Datafile_Name IS NOT NULL THEN
      Utl_File.Put_Line(l_Log_File_Handle,
                        ' File Generated                             : ' ||
                        l_Datafile_Path || '/' || l_Datafile_Name);
    END IF;
     IF   p_Settlement_Type = 'L' AND p_Exch_Id = 'NSE' THEN
      Utl_File.Put_Line(l_Log_File_Handle,
                        ' No. Of Records in File                     : ' ||
                        l_Count_Lq);
    ELSE
      Utl_File.Put_Line(l_Log_File_Handle,
                        ' No. Of Records in File                     : ' ||
                        l_Count);
    END IF;
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Bills Reversed                      : ' ||
                      l_Cnt_Bill_Reversed);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Orders Cancelled                    : ' ||
                      l_Cnt_Order_Reversed);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Orders Already Cancelled            : ' ||
                      l_Cnt_Cancelled);
    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Process Completed Successfully !!! ');
    Utl_File.Fclose(l_Log_File_Handle);
    Utl_File.Fclose(l_Datafile_Handle);
    p_Ret_Val := 'SUCCESS';
    p_Ret_Msg := 'Process Completed Successfully ...';

    UPDATE Program_Status
    SET PRG_OUTPUT_FILE  = l_Datafile_Path || '/' || l_Datafile_Name
    WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                   PARAMETER_MASTER
                             WHERE prg_cmp_id = 'CSSBCFCNS'
                             AND    PRG_dT = PAM_CURR_DT)
      AND Prg_Cmp_Id =   'CSSBCFCNS'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);

    COMMIT;

  EXCEPTION
    WHEN Excp_Terminate THEN
      ROLLBACK;
      p_Ret_Val := 'FAIL';
      p_Ret_Msg := dbms_utility.format_error_backtrace||
                   '**Error Occured while :' || p_Ret_Msg;

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
  END p_Gen_Funds_Confirmation_Stmt;

  --Procedure for loading funds response file

  --Load Response

  PROCEDURE p_Dwnld_Funds_Conf_Stmt(p_File_Name IN VARCHAR2,
                                    p_Exch_Id   IN VARCHAR2,
                                    p_Stc_No    IN VARCHAR2,
                                    p_Settlement_Type IN VARCHAR2,
                                    p_Ret_Val   IN OUT VARCHAR2,
                                    p_Ret_Msg   IN OUT VARCHAR2) IS
    l_Pam_Curr_Date   DATE;
    l_Pam_Last_Date   DATE;
    l_File_Path       VARCHAR2(300);
    l_Log_File_Handle Utl_File.File_Type;
    l_Log_File_Name   VARCHAR2(100);
    l_Prg_Process_Id  NUMBER := 0;
    l_Line_Count      NUMBER := 0;

    Tab_File_Records Std_Lib.Tab;
    Tab_Split_Record Std_Lib.Tab;

    l_User_Mode VARCHAR2(30);
    Line_No     NUMBER := 0;

    l_Order_Dt     VARCHAR2(30);
    l_Order_Date   DATE;
    l_Sett_Date    DATE;
    l_Stc_No       VARCHAR(30);
    l_Stc_Type     VARCHAR(30);
    l_Member_Code  VARCHAR2(10);
    l_Ent_Id       VARCHAR(30);
    l_Dp_Id        VARCHAR(30);
    l_Dp_Acc_No    VARCHAR(30);
    l_Order_No     VARCHAR(30);
    l_Buy_Sell_Flg VARCHAR(30);
    l_Scheme_Code  VARCHAR(30);
    l_Isin         VARCHAR(30);
    l_Amount       NUMBER(15,2) := 0;
    l_Order_Status VARCHAR(100);
    l_Remarks      VARCHAR(300);

    l_Count_Inserted      NUMBER := 0;
    l_Count_Update        NUMBER := 0;
    l_Count_Records       NUMBER := 0;
    l_Count_Skip          NUMBER := 0;

    l_Nse_Broker_Cd       VARCHAR2(30);
    l_Bse_Broker_Cd       VARCHAR2(30);
    l_Mutual_Fund_Seg     VARCHAR2(30);
    l_Company_Id          VARCHAR2(30);
    l_Security_Id         VARCHAR2(30);
    l_Count_Bill_Reversed NUMBER := 0;
    l_Rev_Ret_Msg         VARCHAR2(3000);

    l_Symbol  VARCHAR2(30);
    l_Series  VARCHAR2(30);
    l_Message VARCHAR2(3000);

    l_Internal_Ref_No       VARCHAR2(10);
    l_Order_Type            VARCHAR2(3);
    l_Sip_Regn_No           VARCHAR2(4000);
    l_Sip_Regn_Date         DATE;
    l_Count_Process_Con_Gen NUMBER;

    l_Prg_Id               VARCHAR2(30) := 'CSSBFCONF';
    l_Total_Reversed_Bills NUMBER := 0;
    l_Cnt_Cancelled        NUMBER := 0;


    Excp_Terminate EXCEPTION;
    Excp_Skip EXCEPTION;
    Excp_Sch_Cd_Missing EXCEPTION;

    CURSOR c_Failed_Orders IS
      SELECT t.Order_No,
             t.Exm_Id,
             t.Stc_No,
             t.Buy_Sell_Flg,
             t.Ent_Id,
             t.Security_Id,
             t.Bill_No,
             t.Order_Date
      FROM   Mfss_Trades t,
             Mfss_Funds_Obligation o,
             Parameter_Master
      WHERE  t.Order_No = o.Order_No
      AND    t.Exm_Id = o.Exm_Id
      AND    t.Stc_No = o.Stc_No
      AND    t.Buy_Sell_Flg = o.Buy_Sell_Flg
      AND    t.Ent_Id = o.Ent_Id
      AND    t.Security_Id = o.Security_Id
      AND     t.Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                      Decode(p_Settlement_Type,'L','L1'))
      AND    t.Buy_Sell_Flg = 'P'
      AND    t.Confirmation_Flag = 'Y'
      AND    t.Order_Date = o.Order_Date
      AND    o.Sett_Date = Pam_Curr_Dt
      AND    o.Order_Date = Pam_Last_Dt
      AND    o.Exm_Id = p_Exch_Id
      AND    Nvl(o.Fund_Conf_Stmt_Resp_Flg, 'N') = 'Y'
      AND    o.Order_Status = 'N'
      AND    o.Bill_Reversed_Flag = 'N'
      AND    o.Funds_Conf_Resp_File = p_File_Name;

  BEGIN
    Tab_File_Records.DELETE;
    p_Ret_Msg := ' getting current working date';

    SELECT Pam_Curr_Dt,
           Pam_Last_Dt,
           Cpm_Id
    INTO   l_Pam_Curr_Date,
           l_Pam_Last_Date,
           l_Company_Id
    FROM   Parameter_Master,
           Company_Master;

    p_Ret_Msg := ' Getting file path';

    SELECT Rv_High_Value
    INTO   l_File_Path
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    p_Ret_Msg := ' in housekeeping. Check if file exists in /ebos/files/upstrem or Program is running.';
    Std_Lib.p_Housekeeping(l_Prg_Id,
                           p_Exch_Id,
                           p_Stc_No || '-' || p_Exch_Id || ',' ||
                           p_File_Name,
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
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Exchange                    : ' || p_Exch_Id);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' File Name                   : ' || p_File_Name);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' ----------------------------------------------------------');

/*    p_Ret_Msg := 'Checking if the process is already run for the day';
    SELECT COUNT(*)
    INTO   l_Count_Process_Check
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = l_Prg_Id
    AND    Prg_Dt = l_Pam_Curr_Date
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Check > 0 THEN
      p_Ret_Msg := ' Funds confirmation report is already loaded for the day for exchange <' ||
                   p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;
*/
    p_Ret_Msg := 'Checking if the Funds Confirmation report is generated ';
    SELECT COUNT(*)
    INTO   l_Count_Process_Con_Gen
    FROM   Program_Status
    WHERE  Prg_Cmp_Id = 'CSSBCFCNS'
    AND    Prg_Dt = l_Pam_Last_Date
    AND    Prg_Status = 'C'
    AND    Prg_Exm_Id = p_Exch_Id;

    IF l_Count_Process_Con_Gen = 0 THEN
      p_Ret_Msg := ' Funds Confirmation report is not generated for exchange <' ||
                   p_Exch_Id || '>. Cannot proceed.';
      RAISE Excp_Terminate;
    END IF;

    p_Ret_Msg := 'Getting the trace mode for the program .';
    SELECT Prg_Trace_Level
    INTO   l_User_Mode
    FROM   Programs
    WHERE  Prg_Id = l_Prg_Id;

    p_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
    SELECT Rv_High_Value
    INTO   l_Mutual_Fund_Seg
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'EXCH_SEG_VALID'
    AND    Rv_Low_Value = p_Exch_Id
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
        IF l_User_Mode = 'ADMIN' THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Splitting line no <' || Line_No || '>');
        END IF;

        Tab_Split_Record.DELETE;
        ------------------------------------------------------------------------------------------------------
        --      calling standard Procedure Split_Line to split the records . Here line separator is '~' Tilda
        -----------------------------------------------------------------------------------------------------
        p_Ret_Msg := '4: Splitting fields in the line buffer';

        IF p_Exch_Id = 'BSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             '|',
                             Tab_Split_Record);
        ELSIF p_Exch_Id = 'NSE' THEN
          Std_Lib.Split_Line(Tab_File_Records(Line_No),
                             ',',
                             Tab_Split_Record);
        END IF;

        IF l_User_Mode = 'ADMIN' THEN
          FOR i IN Tab_Split_Record.FIRST .. Tab_Split_Record.LAST
          LOOP
            p_Ret_Msg := 'printing the detailed information for splitted fields';
            Utl_File.Put_Line(l_Log_File_Handle,
                              '<' || i || '>' || ' = <' ||
                              Tab_Split_Record(i) || '>');
          END LOOP;
        END IF;

        l_Order_Dt        := NULL;
        l_Order_Date      := NULL;
        l_Sett_Date       := NULL;
        l_Stc_No          := NULL;
        l_Stc_Type        := NULL;
        l_Member_Code     := NULL;
        l_Ent_Id          := NULL;
        l_Dp_Id           := NULL;
        l_Dp_Acc_No       := NULL;
        l_Order_No        := NULL;
        l_Buy_Sell_Flg    := NULL;
        l_Scheme_Code     := NULL;
        l_Isin            := NULL;
        l_Amount          := NULL;
        l_Order_Status    := NULL;
        l_Remarks         := NULL;
        l_Internal_Ref_No := NULL;
        l_Order_Type      := NULL;
        l_Sip_Regn_No     := NULL;
        l_Sip_Regn_Date   := NULL;

        IF p_Exch_Id = 'BSE' THEN
          l_Order_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),
                                    'YYYY-MM-DD');
          l_Sett_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),
                                    'YYYY-MM-DD');
          l_Stc_Type     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Stc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Dp_Id        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));
          l_Scheme_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Isin         := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Amount       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));
          l_Order_Status := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Remarks      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));

          l_Internal_Ref_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));
          l_Order_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16));
          l_Sip_Regn_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 17));

          BEGIN
            l_Sip_Regn_Date := Nvl(To_Char(To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 18)),
                                                   'DD/MM/YYYY'),
                                           'DD-MON-YYYY'),
                                   '');
          EXCEPTION
            WHEN No_Data_Found THEN
              NULL;
          END;

          IF l_Member_Code NOT LIKE '%' || l_Bse_Broker_Cd || '%' THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Code ||
                         '> of file does not match with the BSE member code <' ||
                         l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;

          BEGIN
             SELECT Msm_Scheme_Id
             INTO  l_Security_Id
             FROM  Mfd_Scheme_Master
             WHERE Msm_Bse_Code = l_Scheme_Code
             AND   Msm_Status = 'A'
             AND   Msm_Record_Status = 'A'
             AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);
          EXCEPTION
             WHEN No_Data_Found THEN
               RAISE Excp_Sch_Cd_Missing;
          END;
          --l_Security_Id := l_Scheme_Code;

        ELSIF p_Exch_Id = 'NSE' THEN
          l_Order_Dt := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST));

          IF l_Order_Dt = 'Order Date' THEN
            RAISE Excp_Skip; ---Header record . hence skipping the same.
          END IF;

          l_Order_Date   := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST)),
                                    'DD_MM-RRRR');
          l_Sett_Date    := To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 1)),
                                    'DD_MM-RRRR');
          l_Stc_Type     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 2));
          l_Stc_No       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 3));
          l_Member_Code  := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 4));
          l_Ent_Id       := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 5));
          l_Dp_Id        := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 6));
          l_Dp_Acc_No    := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 7));
          l_Order_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 8));
          l_Buy_Sell_Flg := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 9));

          IF l_Buy_Sell_Flg = 'S' THEN
            l_Buy_Sell_Flg := 'P';
          END IF;

          l_Symbol := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 10));
          l_Series := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 11));
          l_Amount := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 12));

          l_Order_Status := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 13));
          l_Remarks      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 14));
          l_Scheme_Code  := l_Symbol || l_Series;
          /*IF l_Order_Status = 'S' THEN
            l_Order_Status := 'Y';
          ELSIF  l_Order_Status = 'R' THEN
            l_Order_Status := 'N';
          END IF;*/

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Msm_Nse_Code = l_Symbol || l_Series
            AND   Msm_Status = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;
          --l_Security_Id := l_Symbol || l_Series;

          l_Internal_Ref_No := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 15));
          --l_Order_Type      := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 16)); -- Commented as per NSE file format
          --l_Sip_Regn_No     := TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 17));-- Commented as per NSE file format

          BEGIN
            l_Sip_Regn_Date := Nvl(To_Char(To_Date(TRIM(Tab_Split_Record(Tab_Split_Record.FIRST + 18)),
                                                   'DD/MM/YYYY'),
                                           'DD-MON-YYYY'),
                                   '');
          EXCEPTION
            WHEN No_Data_Found THEN
              NULL;
          END;

          IF l_Member_Code != l_Nse_Broker_Cd THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Code ||
                         '> of file does not match with the BSE member code <' ||
                         l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;
        END IF;

        p_Ret_Msg := 'Verifying Settlement date for order no <' ||
                     l_Order_No || '>.';
        IF l_Sett_Date != l_Pam_Curr_Date THEN
          Utl_File.Put_Line(l_Log_File_Handle,
                            'Settlement Date <' || l_Sett_Date ||
                            '> ,does not match with the system date  <' ||
                            l_Pam_Curr_Date || '>.');
          RAISE Excp_Terminate;
        END IF;

        BEGIN
          p_Ret_Msg := 'Updating Confirmation record   for order no  <' ||
                       l_Order_No || '>, Client <' || l_Ent_Id ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||
                       l_Stc_No || '> and   order type <' || l_Buy_Sell_Flg ||
                       '>.Hence Skipping the record.';

          UPDATE Mfss_Funds_Obligation
          SET    Order_Status            = l_Order_Status,
                 Order_Remark            = l_Remarks,
                 Funds_Conf_Resp_File    = p_File_Name,
                 Fund_Conf_Stmt_Resp_Flg = 'Y',
                 Last_Updt_By            = USER,
                 Last_Updt_Dt            = SYSDATE
          WHERE  Order_No = l_Order_No
          AND    Buy_Sell_Flg = l_Buy_Sell_Flg
          AND    Security_Id = l_Security_Id
          AND    Ent_Id = l_Ent_Id
          AND    Exm_Id = p_Exch_Id
          AND    Order_Date = l_Order_Date
          AND    Stc_No = l_Stc_No
          AND    Nvl(Fund_Conf_Stmt_Resp_Flg, 'N') = 'N';

          IF SQL%ROWCOUNT = 0 THEN
            p_Ret_Msg := 'Record not found in Mfss_Funds_Obligation. Hence Inserting Trades for order no  <' ||
                         l_Order_No || '>, Client <' || l_Ent_Id ||
                         '> , Scheme , ' || l_Scheme_Code ||
                         '> ,Sett No. < ' || l_Stc_No ||
                         '> and   order type <' || l_Buy_Sell_Flg || '>';

            BEGIN
              INSERT INTO Mfss_Funds_Obligation
                (Order_Date,
                 Sett_Date,
                 Order_No,
                 Ent_Id,
                 Exm_Id,
                 Stc_Type,
                 Stc_No,
                 Buy_Sell_Flg,
                 Amc_Scheme_Code,
                 Isin,
                 Amount,
                 Member_Code,
                 Dp_Id,
                 Dp_Acc_No,
                 Order_Status,
                 Order_Remark,
                 Creat_Dt,
                 Creat_By,
                 Prg_Id,
                 Security_Id,
                 Funds_Conf_Resp_File,
                 Fund_Conf_Stmt_Resp_Flg,
                 Internal_Ref_No,
                 Order_Type,
                 Sip_Regn_No,
                 Sip_Regn_Date,
                 Mfo_L0_NonL0)
              VALUES
                (l_Order_Date,
                 l_Sett_Date,
                 l_Order_No,
                 l_Ent_Id,
                 p_Exch_Id,
                 l_Stc_Type/*l_Mutual_Fund_Seg*/,
                 l_Stc_No,
                 l_Buy_Sell_Flg,
                 l_Scheme_Code,
                 l_Isin,
                 l_Amount,
                 l_Member_Code,
                 l_Dp_Id,
                 l_Dp_Acc_No,
                 l_Order_Status,
                 l_Remarks,
                 SYSDATE,
                 USER,
                 l_Prg_Id,
                 l_Security_Id,
                 p_File_Name,
                 'Y',
                 l_Internal_Ref_No,
                 l_Order_Type,
                 l_Sip_Regn_No,
                 l_Sip_Regn_Date,
                 Decode(p_Settlement_Type,'L','L01','NL0'));
              l_Count_Inserted := l_Count_Inserted + 1;
            EXCEPTION
              WHEN Dup_Val_On_Index THEN
                IF l_User_Mode = 'ADMIN' THEN
                  Utl_File.Put_Line(l_Log_File_Handle,
                                    'Response record Exists for order no  <' ||
                                    l_Order_No || '>, Client <' || l_Ent_Id ||
                                    '> , Scheme , ' || l_Scheme_Code ||
                                    '> ,Sett No. < ' || l_Stc_No ||
                                    '> and   order type <' || l_Buy_Sell_Flg ||
                                    '>.Hence Skipping the record.');
                END IF;
                l_Count_Skip := l_Count_Skip + 1;
              WHEN OTHERS THEN
                p_Ret_Msg := p_Ret_Msg || SQLERRM;
                RAISE Excp_Terminate;
            END;
          ELSE
            l_Count_Update := l_Count_Update + 1;
          END IF;

          UPDATE Mfss_Trades
          SET    Fund_Conf_Stmt_Resp_Flg = 'Y',
                 Last_Updt_By            = USER,
                 Last_Updt_Dt            = SYSDATE
          WHERE  Order_No = l_Order_No
          AND    Buy_Sell_Flg = l_Buy_Sell_Flg
          AND    Security_Id = l_Security_Id
          AND     Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                      Decode(p_Settlement_Type,'L','L1'))
          AND    Ent_Id = l_Ent_Id
          AND    Exm_Id = p_Exch_Id
          AND    Order_Date = l_Order_Date
          AND    Stc_No = l_Stc_No
          AND    Nvl(Fund_Conf_Stmt_Resp_Flg, 'N') = 'N';

        EXCEPTION
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
                               ||' For DP Acc No <'||l_Dp_Acc_No||'>'
                            );
         WHEN Excp_Skip THEN
           NULL;
      END;
    END LOOP;

    FOR j IN c_Failed_Orders
    LOOP
      p_Ret_Msg := 'Reversing Bills for order number <' || j.Order_No ||
                   '>and  Client <' || j.Ent_Id || '>';
      p_Reverse_Bills(j.Ent_Id,
                      j.Order_No,
                      j.Order_Date,
                      j.Buy_Sell_Flg,
                      j.Exm_Id,
                      j.Stc_No,
                      j.Security_Id,
                      'DOWNLOAD FUNDS CONFIRMATION',
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

      l_Total_Reversed_Bills := l_Total_Reversed_Bills +
                                l_Count_Bill_Reversed;
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
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records in File                  : ' ||
                      l_Count_Records);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records Inserted                 : ' ||
                      l_Count_Inserted);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records already Processed         : ' ||
                      l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Records Updated                  : ' ||
                      l_Count_Update);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. of Bills Reversed                   : ' ||
                      l_Total_Reversed_Bills);
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' No. Of Orders Already Cancelled         : ' ||
                      l_Cnt_Cancelled);
    Utl_File.Put_Line(l_Log_File_Handle,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Handle,
                      ' Process Completed Successfully !!! ');
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
      ROLLBACK;
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

  END p_Dwnld_Funds_Conf_Stmt;

  --Generate Contract and Bill for redemption
  PROCEDURE p_Generate_Payout(p_Exm_Id  IN VARCHAR2,
                              p_Ent_Id  IN VARCHAR2,
                              o_Ret_Val OUT VARCHAR2,
                              o_Ret_Msg OUT VARCHAR2) IS

    l_Prg_Id        VARCHAR2(30) := 'CSSBMFRED';
    l_Pam_Curr_Dt   DATE;
    l_Log_File_Name VARCHAR2(300);
    l_Log_File_Ptr  Utl_File.File_Type;
    l_Seg_Id        VARCHAR2(2) := 'M';
    l_Process_Id    NUMBER(10) := 0;
    l_Skip_Record EXCEPTION;
    l_Blm_No               VARCHAR2(30);
    l_Bld_No               NUMBER(15);
    l_Cn_No                VARCHAR2(20);
    l_Scheme_Id            VARCHAR2(10);
    l_Comm_Rate            NUMBER(15,2);
    l_Comm_Amt_Per_Trade   NUMBER(15,2);
    l_Min_Amt              NUMBER(15,2);
    --l_Service_Tax_Rate     NUMBER(15,2);
    --l_Edu_Cess_Rate        NUMBER(15,2);
    --l_High_Edu_Cess_Rate   NUMBER(15,2);
    l_Brk_Amt              NUMBER(15,2) := 0;
    l_Set_Amt              NUMBER(15,2) := 0;
    l_Seq_No               NUMBER(14):=1;
    l_Edu_Amt              NUMBER(15,2) := 0;
    l_High_Edu_Amt         NUMBER(15,2) := 0;
    l_Seq                  NUMBER(20);
    l_Prev_Ent_Id          VARCHAR2(30);
    l_Prev_Order_Dt        DATE;
    l_Company_Id           VARCHAR2(30);
    l_Payin_Date           DATE;
    l_Payout_Date          DATE;
    l_Mfss_Payout_Date     DATE;
    l_Nav_Value            NUMBER(15,4) := 0;
    l_Financial_Year_Start DATE;
    l_Financial_Year_End   DATE;
    l_Mutual_Fund_Seg      VARCHAR2(3);

    l_Count_Skip      NUMBER := 0;
    l_Count_Contracts NUMBER := 0;
    l_Count_Bills     NUMBER := 0;
    o_Sqlerrm         VARCHAR2(2000);
    l_Amt_Adjust NUMBER := 0;
    l_Amt        NUMBER := 0;

    l_Holding_Mode VARCHAR2(50);
    l_Due_Amt      NUMBER(18, 2);
    -----
    l_First_Apr_Yn    VARCHAR2(1) := 'N';
    l_Financial_Year_Start1 DATE;

    l_CGST_Rate            NUMBER             ;
    l_SGST_Rate            NUMBER             ;
    l_IGST_Rate            NUMBER             ;
    l_UT_Flag              VARCHAR2(1)        ;
    l_Receiving_State      VARCHAR2(100)      ;
    l_Servicing_State      VARCHAR2(100)      ;
    -----
    CURSOR c_Redm_Data IS
      SELECT Rs.Order_No Order_No,
             Rs.Sett_No Sett_No,
             Rs.Client_Code Client_Code,
             Rs.Security_Id Security_Id,
             Rs.Order_Date Order_Date,
             Rs.Exm_Id Exm_Id,
             Rs.Sett_Type Sett_Type,
             Rs.Settlement_Type Settlement_Type,
             Rs.Holding_Mode Holding_Mode,
             Rs.Nav,
             Rs.Unit Unit,
             Rs.Amt Amt,
             Rs.Stt Stt,
             Nvl(Rs.Exit_Load,0) Exit_load,
             Nvl(Rs.Tax,0) Std,
             (Rs.Nav * Rs.Unit) Gross_Amt,
             Mt.Order_Type Order_Type,
             Mt.Isin Isin
      FROM   Redemption_Statement Rs,
             Mfss_Trades          Mt
      WHERE  Rs.Order_No = Mt.Order_No
      AND    Rs.Order_Date = Mt.Order_Date
      AND    Rs.Client_Code = Mt.Ent_Id
      AND    Rs.Exm_Id = Mt.Exm_Id
      AND    RS.SECURITY_ID=MT.SECURITY_ID
      AND    Mt.Buy_Sell_Flg      = 'R'
      AND    Nvl(Rs.Exm_Id, 'A') = Nvl(p_Exm_Id, Nvl(Rs.Exm_Id, 'A'))
      AND    Client_Code = Nvl(p_Ent_Id, Client_Code)
      AND    Valid_Flag = 'Y'
      AND    Success_Reject_Status = 'SUCCESS'
      AND    Nvl(Rem_Payout_Gen, 'N') = 'N'
      AND    Mt.Contract_No IS NULL
      ORDER BY Mt.Order_Date,
               Mt.Ent_Id,
               Mt.Order_No;

    TYPE Redm_Data_Rec IS RECORD(
      Order_No        NUMBER,
      Sett_No         NUMBER,
      Client_Code     VARCHAR2(50),
      Security_Id     VARCHAR2(100),
      Order_Date      DATE,
      Exm_Id          VARCHAR2(10),
      Sett_Type       VARCHAR2(10),
      Settlement_Type VARCHAR2(10),
      Holding_Mode    VARCHAR2(10),
      Nav             NUMBER(15,4),
      Unit            NUMBER(18,4),
      Amt             NUMBER(18,2),
      Stt             NUMBER(18,2),
      Exit_load       NUMBER(25,8),
      Std             NUMBER(25,8),
      Gross_Amt       NUMBER(18,2),
      Isin            VARCHAR2(12));

    Rec_Data Redm_Data_Rec;

    CURSOR c_Tcm_Cd IS
      SELECT Tcm_Cd,
             Tcm_Db_Cr_Flg
      FROM   Txn_Code_Master
      WHERE  Tcm_Status = 'A';

    TYPE Tcm_Cd IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(5);
    Tcm_Cd_Tab Tcm_Cd;

    PROCEDURE p_Initialize IS
    BEGIN
      l_Pam_Curr_Dt := Std_Lib.l_Pam_Curr_Date;
      l_Company_Id  := Std_Lib.l_Cpm_Id;

      /*o_Ret_Msg := 'selecting service tax rate from masters ';
      SELECT Srt_Rate,
             Srt_Edu_Cess_Rate,
             Srt_High_Edu_Cess_Rate
      INTO   l_Service_Tax_Rate,
             l_Edu_Cess_Rate,
             l_High_Edu_Cess_Rate
      FROM   Service_Tax
      WHERE  Srt_Segment = l_Seg_Id
      AND    l_Pam_Curr_Dt BETWEEN Srt_Date_From AND
             Nvl(Srt_Date_To, l_Pam_Curr_Dt);*/

      o_Ret_Msg := 'Getting Financial year start Date ';
      SELECT Rv_Low_Value,
             Rv_High_Value
      INTO   l_Financial_Year_Start,
             l_Financial_Year_End
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain LIKE 'FINANCIAL_YEAR';

      o_Ret_Msg := 'Getting the Mutual Fund Segment From Cg_Ref_Codes';
      SELECT Rv_High_Value
      INTO   l_Mutual_Fund_Seg
      FROM   Cg_Ref_Codes
      WHERE  Rv_Domain = 'EXCH_SEG_VALID'
      AND    Rv_Low_Value = p_Exm_Id
      AND    Rv_Abbreviation = 'MFSS';

      Tcm_Cd_Tab.DELETE;

      FOR i IN c_Tcm_Cd
      LOOP
        Tcm_Cd_Tab(i.Tcm_Cd) := i.Tcm_Db_Cr_Flg;
      END LOOP;

      Get_Mfss_Bill_Due_Dates(l_Pam_Curr_Dt, l_Payin_Date, l_Payout_Date);
    END p_Initialize;

    PROCEDURE p_Get_Mfss_Payout_Dt(p_Order_Date IN DATE,
                                   p_Sett_Type  IN VARCHAR2,
                                   p_Exch       IN VARCHAR2,
                                   p_Sett_No    IN NUMBER,
                                   o_Date       OUT DATE) IS


    BEGIN
      SELECT Sc.Mfs_Funds_Payout_Date
      INTO   o_Date
      FROM   Mfss_Settlement_Calender Sc
      WHERE  Sc.Mfs_Trade_Date = p_Order_Date
      AND    Sc.Mfs_Settlement_Type = p_Sett_Type
      AND    Sc.Mfs_Exch_Id = p_Exch
      AND    Sc.Mfs_Settlement_No = p_Sett_No;
    END;

    PROCEDURE p_Insert_Bill(p_Txn_Code        IN VARCHAR2,
                            Rec               IN Redm_Data_Rec,
                            p_Add_Info_Flag   IN VARCHAR2 DEFAULT 'N') IS

      l_Special_attribute VARCHAR2(10);

    BEGIN
      SELECT Nvl(MAX(Bld_No), 0) + 1
      INTO   l_Bld_No
      FROM   Bill_Details
      WHERE  Bld_Blm_No = l_Blm_No
      AND    Bld_Blm_Status = 'F'
      AND    Bld_Blm_Cpd_Id = l_Company_Id;

      SELECT decode(e.ent_category,'NRI','S',NULL)
      INTO l_Special_attribute
      FROM entity_master e
      WHERE e.ent_id = Rec.Client_Code;

      o_Ret_Msg := 'Inserting into Bill Details for ' || p_Txn_Code ||
                   ' bills for order no <' || Rec.Order_No ||
                   '> and client id <' || Rec.Client_Code || '>';
      INSERT INTO Bill_Details
        (Bld_No,
         Bld_Blm_No,
         Bld_Blm_Status,
         Bld_Icn_No,
         Bld_Tcm_Cd,
         Bld_Due_Dt,
         Bld_Due_Amt,
         Bld_Amt_Recd,
         Bld_Adj_In_Amt,
         Bld_Stage,
         Bld_Blm_Cpd_Id,
         Bld_Creat_By,
         Bld_Creat_Dt,
         Bld_Prg_Id,
         Bld_Pam_Dt,
         Bld_Alloc_Id,
         Bld_Special_Attribute,
         Bld_Ind_Flg,
         Bld_Seg_Id,
         Bld_Ent_Id,
         Bld_Stc_Stt_Exm_Id,
         Bld_Remarks,
         Bld_Dr_Cr_Flag,
         Bld_Stc_Stt_Type,
         Bld_Stc_No,
         Bld_Mf_Purc_Redm_Flag,
         Bld_Arks)
      VALUES
        (l_Bld_No,
         l_Blm_No,
         'F',
         l_Cn_No,
         p_Txn_Code,
         Decode(Sign(l_Pam_Curr_Dt-l_Mfss_Payout_Date),1,l_pam_Curr_Dt,l_Mfss_Payout_Date),
         l_Due_Amt,
         l_Amt_Adjust,
         0,
         'O',
         l_Company_Id,
         USER,
         SYSDATE,
         l_Prg_Id,
         l_Pam_Curr_Dt,
         NULL,
         l_Special_attribute,
         NULL,
         l_Seg_Id,
         Rec.Client_Code,
         Rec.Exm_Id,
         Rec.Order_No,
         Tcm_Cd_Tab(p_Txn_Code),
         Rec.Settlement_Type,
         Rec.Sett_No,
         'R',
         Rec.Order_No);

      IF p_Add_Info_Flag = 'Y' THEN
        INSERT INTO BILL_DETAILS_ADD_INFO
          (BLD_NO, BLD_BLM_NO, BLD_BLM_STATUS,
           BLD_BLM_CPD_ID, BLD_ENT_GST_STATE, BLD_ENT_BRANCH_STATE,
           BLD_ENT_UT_FLAG, BLD_CGST_RATE, BLD_SGST_RATE, BLD_IGST_RATE)
        VALUES
          (l_Bld_No, l_Blm_No, 'F',
           l_Company_Id, l_Receiving_State, l_Servicing_State,
           l_UT_Flag, l_CGST_Rate, l_SGST_Rate, l_IGST_Rate);
      END IF;

      l_Count_Bills := l_Count_Bills + 1;
    END;

    PROCEDURE p_Billing(p_Txn_Code IN VARCHAR2,
                        Rec        IN Redm_Data_Rec) IS
    BEGIN
      IF p_Txn_Code = 'BRK' AND l_Brk_Amt > 0 THEN
        IF l_Amt > 0 THEN
          l_Amt_Adjust := Least(l_Amt, l_Brk_Amt);
          l_Amt        := l_Amt - l_Amt_Adjust;

        END IF;

        l_Due_Amt := l_Brk_Amt;
        p_Insert_Bill('BRK', Rec);
      END IF;

      IF p_Txn_Code = 'SET' AND l_Set_Amt > 0 THEN

        IF l_Amt > 0 THEN
          l_Amt_Adjust := Least(l_Amt, l_Set_Amt);
          l_Amt        := l_Amt - l_Amt_Adjust;

        END IF;

        l_Due_Amt := l_Set_Amt;
        p_Insert_Bill('SET', Rec, 'Y');
      END IF;

      IF p_Txn_Code = 'EDU' AND l_Edu_Amt > 0 THEN

        IF l_Amt > 0 THEN
          l_Amt_Adjust := Least(l_Amt, l_Edu_Amt);
          l_Amt        := l_Amt - l_Amt_Adjust;

        END IF;

        l_Due_Amt := l_Edu_Amt;
        p_Insert_Bill('EDU', Rec, 'Y');
      END IF;

      IF p_Txn_Code = 'HDU' AND l_High_Edu_Amt > 0 THEN

        IF l_Amt > 0 THEN
          l_Amt_Adjust := Least(l_Amt, l_High_Edu_Amt);
          l_Amt        := l_Amt - l_Amt_Adjust;

        END IF;

        l_Due_Amt := l_High_Edu_Amt;
        p_Insert_Bill('HDU', Rec, 'Y');
      END IF;
      /*
          IF p_Txn_Code='STT' AND rec.Stt > 0 THEN


            IF l_Amt > 0 THEN
              l_Amt_Adjust := Least(l_Amt, rec.Stt);
              l_Amt        := l_Amt - l_Amt_Adjust;

            END IF;

            l_Due_Amt:= rec.Stt;
            P_Insert_Bill('STT',rec) ;
          END IF;
      */

      IF p_Txn_Code = 'FPO' THEN
        IF Rec.Amt > 0 THEN
          l_Amt_Adjust := Rec.Amt - l_Amt;

        END IF;

        l_Due_Amt := Rec.Amt;
       -- p_Insert_Bill('FPO', Rec); --- mf changes
      END IF;

      UPDATE Mfss_Trades
      SET    Bill_No      = l_Blm_No,
             Contract_No  = l_Cn_No,
             Last_Updt_Dt = SYSDATE,
             Last_Updt_By = USER
      WHERE  Order_No = Rec.Order_No
      AND    To_Char(Order_Date, 'DD-MON-RR') = To_Char(Rec.Order_Date)
      AND    Exm_Id = Rec.Exm_Id
      AND    Buy_Sell_Flg = 'R'
      AND    Security_Id = Rec.Security_Id;

      UPDATE Redemption_Statement Rs
      SET    Rs.Rem_Payout_Gen = 'Y',
             Rs.Rds_Cn_No      = l_Cn_No
      WHERE  Nvl(Exm_Id, 'A') = Nvl(p_Exm_Id, Nvl(Exm_Id, 'A'))
      AND    Client_Code = Rec.Client_Code
      AND    Valid_Flag = 'Y'
      AND    Success_Reject_Status = 'SUCCESS'
      AND    Nvl(Rem_Payout_Gen, 'N') = 'N'
      AND    Rs.Order_Date       = Rec.Order_Date
      AND    Rs.Rds_Cn_No   IS NULL;
    END p_Billing;

    PROCEDURE p_Contract(Rec Redm_Data_Rec) IS
    BEGIN
      IF Nvl(l_Prev_Ent_Id, '@@') <> Rec.Client_Code OR
         NVL(l_Prev_Order_Dt,'1-Jan-1900')<> Rec.Order_Date THEN
    ---
      l_First_Apr_Yn := 'N';

      IF (To_Char(Rec.Order_Date,'MON') != To_Char(l_Pam_Curr_Dt,'MON')) AND To_Char(l_Pam_Curr_Dt,'MON') = 'APR'
      THEN
          l_First_Apr_Yn := 'Y';
          o_Ret_Msg := 'Getting Fiscal Start date on 1st Apr ';
          SELECT DISTINCT Apm_Start_Period
          INTO   l_Financial_Year_Start1
          FROM   Account_Period_Master
          WHERE  Apm_Start_Period <= Rec.Order_Date
          AND    Apm_End_Period >= Rec.Order_Date;

      END IF;
      ---
        BEGIN
          SELECT Cn_No
          INTO   l_Cn_No
          FROM   Mfss_Contract_Note
          WHERE  Exm_Id           = Rec.Exm_Id
          AND    Transaction_Date = Rec.Order_Date
          AND    Ent_Id           = Rec.Client_Code
          AND    Rownum           = 1;

        EXCEPTION
          WHEN No_Data_Found THEN
            SELECT Nvl(MAX(To_Number(Substr(Cn_No, -7))), 0)
            INTO   l_Seq
            FROM   Mfss_Contract_Note
            WHERE  Transaction_Date >= Decode(l_First_Apr_Yn,'Y',l_Financial_Year_Start1,l_Financial_Year_Start)
            AND    Exm_Id = p_Exm_Id;

            l_Seq := l_Seq + 1;

            l_Cn_No := Rec.Exm_Id||l_Mutual_Fund_Seg || To_Char(Rec.Order_Date, 'YYYYMMDD') ||
                       Lpad(l_Seq, 7, '0');
        END;

       /* o_Ret_Msg := 'Getting bill no for order no <' || Rec.Order_No ||
                     '> and client id <' || Rec.Client_Code || '>';

        Pkg_FA_Entry_Mgmt.P_Get_Bld_No(l_Company_Id       ,
                                       Rec.Exm_Id         ,
                                       l_Mutual_Fund_Seg  ,
                                       Rec.Client_Code    ,
                                       NULL               ,
                                       NULL               ,
                                       'F'                ,
                                       l_Pam_Curr_Dt      ,
                                       NULL               ,
                                       'Y'                ,
                                       l_Blm_No           ,
                                       l_Bld_No           ,
                                       o_Ret_Msg);*/ --- mf changes

      /*  p_Get_Mfss_Bld_No(l_Company_Id,
                          Rec.Exm_Id,
                          NULL,
                          Rec.Client_Code,
                          l_Pam_Curr_Dt,
                          'F',
                          l_Blm_No,
                          l_Bld_No);*/--- mf changes

        l_Prev_Ent_Id := Rec.Client_Code;
        l_Prev_Order_Dt := Rec.Order_Date;
      END IF;

      o_Ret_Msg := 'Finding the sequence no for client '|| Rec.Client_Code;

      BEGIN
        SELECT NVL(MAX(Cnd_Seq_No),0) + 1
        INTO   l_Seq_No
        FROM   Mfss_Contract_Note
        WHERE  Exm_Id           = Rec.Exm_Id
        AND    Transaction_Date = Rec.Order_Date
        AND    Ent_Id           = Rec.Client_Code
        AND    Cn_No            = l_Cn_No;
      EXCEPTION
        WHEN OTHERS THEN
          l_Seq_No := 1;
      END;

      o_Ret_Msg := 'Inserting into contract Note for order no <' ||
                   Rec.Order_No || '> and client id <' || Rec.Client_Code || '>';
      INSERT INTO Mfss_Contract_Note
        (Cn_No,
         Transaction_Date,
         Exm_Id,
         Stc_Type,
         Stc_No,
         Ent_Id,
         Status,
         Amc_Scheme_Code,
         Buy_Sell_Flag,
         Order_No,
         Quantity,
         Amount,
         Brokerage,
         Service_Tax,
         Edu_Cess,
         High_Edu_Cess,
         Security_Txn_Tax,
         MF_Exit_Load,
         MF_Stamp_duty,
         Scheme_Id,
         Holding_Mode,
         Created_By,
         Created_Date,
         Prg_Id,
         Bill_No,
         Isin,
         Cnd_Seq_No)
      VALUES
        (l_Cn_No,
         Rec.Order_Date,
         Rec.Exm_Id,
         Rec.Settlement_Type,
         Rec.Sett_No,
         Rec.Client_Code,
         'I',
         Rec.Security_Id,
         'R',
         Rec.Order_No,
         Rec.Unit,
         Rec.Amt + Nvl(Rec.Stt, 0) +Nvl(Rec.Exit_Load,0) + Nvl(Rec.Std,0),
         l_Brk_Amt,
         l_Set_Amt,
         l_Edu_Amt,
         l_High_Edu_Amt,
         Rec.Stt,
         Rec.Exit_Load,
         Rec.Std,
         l_Scheme_Id,
         l_Holding_Mode,
         USER,
         SYSDATE,
         l_Prg_Id,
         l_Blm_No,
         Rec.Isin,
         l_Seq_No);

      /*IF l_Receiving_State IS NOT NULL THEN
        INSERT INTO Mfss_Contract_Note_Add_Info
            (CN_NO,                       CND_SEQ_NO      ,        ENT_GST_STATE   ,
             ENT_BRANCH_STATE,            ENT_UT_FLAG     ,        CGST_RATE       ,
             SGST_RATE       ,            IGST_RATE)
          VALUES
            (l_Cn_No          ,           l_Seq_No        ,        l_Receiving_State,
             l_Servicing_State,           l_UT_Flag       ,        l_CGST_Rate      ,
             l_SGST_Rate      ,           l_IGST_Rate);
      END IF;*/

      o_Ret_Msg := 'Adding contracts';
      l_Count_Contracts := l_Count_Contracts + 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_Count_Skip := l_Count_Skip + 1;
        o_Ret_Msg    := 'Error while ' || o_Ret_Msg || 'Error message is :' ||
                        SQLERRM;
        Utl_File.New_Line(l_Log_File_Ptr, 2);
        Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
        Utl_File.Put_Line(l_Log_File_Ptr,
                          'Skipping contract note generation for order no <' ||
                          Rec_Data.Order_No || '> and client <' ||
                          Rec_Data.Client_Code || '>');
        Raise_Application_Error(-20100, 'Duplicate contract no or sequence no generated '||l_Cn_No||' or '||l_Seq_No);
    END;

  BEGIN
    -----Main

    o_Ret_Val := 'FAIL';
    o_Ret_Msg := 'Performing Housekeeping ';

    Std_Lib.p_Housekeeping(l_Prg_Id,
                           Nvl(p_Exm_Id, 'ALL'),
                           p_Exm_Id || '-' || p_Ent_Id ,
                           'E',
                           l_Log_File_Ptr,
                           l_Log_File_Name,
                           l_Process_Id,
                           'Y');

    p_Initialize;

    --Initiating GST Values
    Pkg_GST_Computation.P_Initialize;

    FOR Rec IN c_Redm_Data
    LOOP
      l_Nav_Value          := 0;
      l_Scheme_Id          := NULL;
      l_Comm_Rate          := 0;
      l_Comm_Amt_Per_Trade := 0;
      l_Min_Amt            := 0;

      l_Receiving_State    := null;
      l_Servicing_State    := null;
      l_UT_Flag            := null;
      l_CGST_Rate          := null;
      l_SGST_Rate          := null;
      l_IGST_Rate          := null;

      o_Ret_Msg := 'selecting scheme details for Entity: ' ||
                   Rec.Client_Code || ' and Date: ' || l_Pam_Curr_Dt;

      p_Get_Comm_Rate(Rec.Client_Code,
                      'R',
                      Rec.Exm_Id,
                      Rec.Order_Type,
                      Rec.Holding_Mode,
                      Rec.Security_Id,
                      l_Scheme_Id,
                      l_Comm_Rate,
                      l_Comm_Amt_Per_Trade,
                      l_Min_Amt);

      IF l_Scheme_Id IS NULL THEN
        l_Brk_Amt      := 0;
        l_Set_Amt      := 0;
        l_Edu_Amt      := 0;
        l_High_Edu_Amt := 0;
      ELSE
        l_Brk_Amt := Round((Nvl(Rec.Amt, 0) *
                           (Nvl(l_Comm_Rate, 0) / 100)) +
                           Nvl(l_Comm_Amt_Per_Trade, 0),
                           2);

        IF l_Brk_Amt < Nvl(l_Min_Amt, 0) THEN
          l_Brk_Amt := l_Min_Amt;
        END IF;

        IF l_Brk_Amt > 0 THEN
          Pkg_GST_Computation.p_Populate_Client(Rec.Client_Code, null);

          --Added for fetching and storing GST Details
          Pkg_Gst_Computation.P_Get_GST_State_And_Rate('M',
                                                       Rec.Client_Code,
                                                       Null,
                                                       Null,
                                                       l_Receiving_State,
                                                       l_Servicing_State,
                                                       l_UT_Flag,
                                                       l_CGST_Rate,
                                                       l_SGST_Rate,
                                                       l_IGST_Rate);

          --Computing GST amount
          Pkg_GST_Computation.P_Compute_Gst('M', Rec.Client_Code, Null, Null, l_Brk_Amt, 'N',
                                                 l_Set_Amt, l_Edu_Amt, l_High_Edu_Amt);
        ELSE
          l_Set_Amt := 0;
          l_Edu_Amt := 0;
          l_High_Edu_Amt := 0;
        END If;

        /*l_Set_Amt      := Round(Nvl(l_Brk_Amt, 0) *
                                (l_Service_Tax_Rate / 100),
                                2);
        l_Edu_Amt      := Round(Nvl(l_Set_Amt, 0) * (l_Edu_Cess_Rate / 100),
                                2);
        l_High_Edu_Amt := Round(Nvl(l_Set_Amt, 0) *
                                (l_High_Edu_Cess_Rate / 100),
                                2);*/
      END IF;

      Rec_Data.Order_No        := Rec.Order_No;
      Rec_Data.Sett_No         := Rec.Sett_No;
      Rec_Data.Client_Code     := Rec.Client_Code;
      Rec_Data.Security_Id     := Rec.Security_Id;
      Rec_Data.Order_Date      := Rec.Order_Date;
      Rec_Data.Exm_Id          := Rec.Exm_Id;
      Rec_Data.Sett_Type       := Rec.Sett_Type;
      Rec_Data.Settlement_Type := Rec.Settlement_Type;
      Rec_Data.Holding_Mode    := Rec.Holding_Mode;
      Rec_Data.Nav             := Rec.Nav;
      Rec_Data.Unit            := Rec.Unit;
      Rec_Data.Amt             := Rec.Amt;
      Rec_Data.Stt             := Rec.Stt;
      Rec_Data.Exit_Load       := Rec.Exit_Load;
      Rec_Data.Std             := Rec.Std;
      Rec_Data.Gross_Amt       := Rec.Gross_Amt;
      Rec_Data.Isin            := Rec.Isin;

      p_Contract(Rec_Data);

      l_Amt := Rec_Data.Amt;

      o_Ret_Msg := 'Fetching Payout Date for Stc Type:'||Rec_Data.Settlement_Type||', Exch:'||Rec_Data.Exm_Id||', StcNo:'||Rec_Data.Sett_No;
      p_Get_Mfss_Payout_Dt(Rec_Data.Order_Date,
                           Rec_Data.Settlement_Type,
                           Rec_Data.Exm_Id,
                           Rec_Data.Sett_No,
                           l_Mfss_Payout_Date);

      o_Ret_Msg := 'Generating Bill';
      p_Billing('BRK', Rec_Data);
      p_Billing('SET', Rec_Data);
      p_Billing('EDU', Rec_Data);
      p_Billing('HDU', Rec_Data);
      p_Billing('STT', Rec_Data);
      ----p_Billing('FPO', Rec_Data);  ----mf changes

    END LOOP;

    o_Ret_Val := 'SUCCESS';
    o_Ret_Msg := 'Process completed successfully ';

    IF l_Count_Skip > 0 THEN
      Std_Lib.l_Partial_Run_Yn := 'Y';
    END IF;

    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr, ' Process Summary :');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Contracts Generated                          : ' ||
                      l_Count_Contracts);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Bills     Generated                          : ' ||
                      l_Count_Bills);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' No. Of Contracts Skipped                            : ' ||
                      l_Count_Skip);
    Utl_File.Put_Line(l_Log_File_Ptr,
                      '---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,
                      ' Process Completed Successfully !!! ');

    Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                            l_Pam_Curr_Dt,
                            l_Process_Id,
                            'C',
                            'Y',
                            o_Sqlerrm);

    Utl_File.New_Line(l_Log_File_Ptr, 2);
    Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
    Utl_File.Fclose(l_Log_File_Ptr);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      o_Ret_Val := 'FAIL';
      o_Ret_Msg := 'Error while ' || o_Ret_Msg || ' ' || SQLCODE || ' ' ||
                   Substr(SQLERRM, 1, 200)||Dbms_Utility.format_error_backtrace;

      Std_Lib.p_Updt_Prg_Stat(l_Prg_Id,
                              l_Pam_Curr_Dt,
                              l_Process_Id,
                              'E',
                              'Y',
                              o_Sqlerrm);

      Utl_File.New_Line(l_Log_File_Ptr, 2);
      Utl_File.Put_Line(l_Log_File_Ptr, 'Process Failed ');
      Utl_File.Put_Line(l_Log_File_Ptr, o_Ret_Msg);
      Utl_File.Fclose(l_Log_File_Ptr);

  END;

  --Procedure for loading redemption file
  PROCEDURE p_Load_Redemption_File_Unused(P_File_Name           IN VARCHAR2,
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
    l_User_Mode                    VARCHAR2(20);
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
    Excp_Terminate                 EXCEPTION;
    Excp_Skip                      EXCEPTION;
    Excp_Sch_Cd_Missing            EXCEPTION;
    l_Stt                          NUMBER;
    l_scheme_name                  VARCHAR2(300);  --New File Structure BSE
    l_Exit_Load                    NUMBER(25,8);
    l_Tax                          NUMBER(25,8);
    l_Ret_Val                      VARCHAR2(4000);
    l_Ret_Msg                      VARCHAR2(4000);

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
        IF l_User_Mode = 'ADMIN' THEN
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

        IF l_User_Mode = 'ADMIN' THEN
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

          IF l_Member_Id NOT LIKE '%' || l_Bse_Broker_Cd || '%' THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Id ||'> of file does not match with the BSE member code <' ||l_Bse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;

          l_Branch_Code     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 10);
          l_User_Id         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 11);
          l_Folio_No        := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 12);
          l_Rta_Scheme_Code := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 13);
          l_Rta_Trans_No    := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 14);
          l_Client_Code     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 15);
          l_Client_Name     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 16);
          l_Beneficiary_Id  := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 17);
          l_Nav             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 18);
          l_Unit            := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 19);
          l_Amt             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
          l_Valid_Flag      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
          l_Remarks         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
          l_Stt             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
          l_scheme_name     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);  --New File Structure
          l_Exit_Load       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);
          l_Tax             := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Msm_Bse_Code = l_Scheme_Code
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

          IF l_Member_Id != l_Nse_Broker_Cd THEN
            p_Ret_Msg := 'Member Code <' || l_Member_Id ||
                         '> of file does not match with the NSE member code <' ||
                         l_Nse_Broker_Cd || '> of the broker ';
            RAISE Excp_Terminate;
          END IF;

          l_Branch_Code      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 20);
          l_User_Id          := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 21);
          l_Folio_No         := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 22);
          l_Payout_Mechanism := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 23);
          l_Application_No   := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 24);
          l_Client_Code      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 25);
          l_Tax_Status       := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 26);
          l_Holding_Mode     := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 27);
          l_Client_Name      := Tab_Split_Rcd(Tab_Split_Rcd.FIRST + 28);

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

          BEGIN
            SELECT Msm_Scheme_Id
            INTO  l_Security_Id
            FROM  Mfd_Scheme_Master
            WHERE Msm_Nse_Code      = l_Scheme_Symbol || l_Scheme_Series
            AND   Msm_Status        = 'A'
            AND   Msm_Record_Status = 'A'
            AND   l_Pam_Curr_Date BETWEEN Msm_From_Date AND Nvl(Msm_To_Date,l_Pam_Curr_Date);

          EXCEPTION
            WHEN No_Data_Found THEN
              RAISE Excp_Sch_Cd_Missing;
          END;

          l_Scheme_Code := l_Scheme_Symbol || l_Scheme_Series;

          BEGIN
            SELECT Rv_Low_Value
            INTO   l_Sett_Type
            FROM   Cg_Ref_Codes
            WHERE  Rv_Domain     = 'MF_NSE_SETTLEMENT_TYPE'
            AND    Rv_High_Value = l_Scheme_Category;
          EXCEPTION
            WHEN No_Data_Found THEN
              Utl_File.Put_Line(l_Log_File_Handle,'  Settlement Type not found for scheme Category <' || l_Scheme_Category ||'>');
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
             Scheme_Name,         Exit_Load,              Tax)
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
             l_scheme_name,       l_Exit_Load,            l_Tax);

          p_Ret_Msg := 'Updating data in Trades for order no  <' ||
                       l_Order_No || '>, Client <' || l_Client_Code ||
                       '> , Scheme , ' || l_Scheme_Code || '> ,Sett No. < ' ||
                       l_Sett_No || '> and   order date <' || l_Order_Date || '>';

          UPDATE Mfss_Trades Mt
          SET    Mt.Amount        = l_Amt,
                 Mt.Alloted_Nav   = l_Nav,
                 Mt.Exit_load     = l_Exit_Load,
                 Mt.Stamp_Duty    = l_Tax,
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
            IF l_User_Mode = 'ADMIN' THEN
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


        WHEN Excp_Skip THEN
          NULL;
      END;
    END LOOP;

    -----Calling procedure for contractin and billing of redemption orders
   /* p_Ret_Msg := 'Performing Contracting and Billing for redemption orders. ';
    P_Generate_Payout(p_Exch_Id,
                      NULL,
                      l_Ret_Val,
                      l_Ret_Msg);*/---- mf changes

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

  END p_Load_Redemption_File_Unused;

  PROCEDURE p_Reverse_Bills(p_Ent_Id               IN VARCHAR2,
                            p_Order_No             IN VARCHAR2,
                            p_Order_Date           IN DATE,
                            p_Buy_Sell_Flag        IN VARCHAR2,
                            p_Exm_Id               IN VARCHAR2,
                            p_Stc_No               IN NUMBER,
                            p_Security_Id          IN VARCHAR2,
                            p_Cancel_Remark        IN VARCHAR2,
                            p_Cancel_Option         IN VARCHAR2,
                            o_Ret_Msg              OUT VARCHAR,
                            o_Total_Bills_Reversed OUT NUMBER) AS

    l_Contract_No VARCHAR2(100);
    l_Bld_No      NUMBER;
    l_Company_Id  VARCHAR2(100);
    l_Bill_No     VARCHAR2(50);
    l_Bill_Count  NUMBER := 0;
    l_Prg_Id      VARCHAR2(30) := 'MFSSREVBL';

    CURSOR c_Bill_Dtls IS
      SELECT d.Bld_Blm_No Bill_No,
             d.Bld_Tcm_Cd Tcm_Cd
      FROM   Bill_Details d
      WHERE  d.Bld_Icn_No = l_Contract_No
      AND    d.Bld_Blm_Status = 'F'
      AND    d.Bld_Blm_Cpd_Id = l_Company_Id
      AND    d.Bld_Ent_Id = p_Ent_Id
      AND    d.Bld_Remarks = p_Order_No;

  BEGIN
    o_Ret_Msg := 'Selecting Company Id.';
    SELECT Cpm_Id
    INTO   l_Company_Id
    FROM   Company_Master;

    BEGIN
      o_Ret_Msg := 'Selecting Contract Note No for order No  <' ||
                   p_Order_No || '>, j.ent_id <' || p_Ent_Id || '>';
      SELECT t.Contract_No
      INTO   l_Contract_No
      FROM   Mfss_Trades t
      WHERE  t.Order_No = p_Order_No
      AND    t.Exm_Id   = p_Exm_Id
      AND    t.Stc_No   = p_Stc_No
      AND    t.Buy_Sell_Flg = p_Buy_Sell_Flag
      AND    t.Order_Date   = p_Order_Date
      AND    t.Ent_Id       = p_Ent_Id
      AND    t.Security_Id  = p_Security_Id
      AND    t.Order_Status <> 'CANCEL';
    EXCEPTION
      WHEN No_Data_Found THEN
        o_Ret_Msg              := 'CANCELLED';
        o_Total_Bills_Reversed := 0;
        RETURN;
    END;

    o_Ret_Msg := 'Cancelling Contract for order No  <' || p_Order_No ||
                 '>, j.ent_id <' || p_Ent_Id || '>';
    UPDATE Mfss_Contract_Note m
    SET    m.Status       = 'C',
           m.Updated_By   = USER,
           m.Updated_Date = SYSDATE
    WHERE  m.Cn_No = l_Contract_No
    AND    m.Order_No = p_Order_No
    AND    m.Status = 'I';

    FOR j IN c_Bill_Dtls
    LOOP
      IF Nvl(l_Bill_No, 'X') = j.Bill_No THEN
        l_Bld_No := l_Bld_No + 1;
      ELSE
        SELECT Nvl(MAX(Bld_No), 0) + 1
        INTO   l_Bld_No
        FROM   Bill_Details
        WHERE  Bld_Blm_No = j.Bill_No
        AND    Bld_Blm_Status = 'F'
        AND    Bld_Blm_Cpd_Id = l_Company_Id;
      END IF;

      o_Ret_Msg := 'Reversing bill for order No  <' || p_Order_No ||
                   '>, Client <' || p_Ent_Id || '> , Sett No. < ' ||
                   p_Stc_No || '> and Bill type <' || j.Tcm_Cd || '>';

      INSERT INTO Bill_Details b
        (Bld_No,
         Bld_Blm_No,
         Bld_Blm_Status,
         Bld_Icn_No,
         Bld_Tcm_Cd,
         Bld_Due_Dt,
         Bld_Due_Amt,
         Bld_Adj_In_Amt,
         Bld_Amt_Recd,
         Bld_Blm_Cpd_Id,
         Bld_Creat_By,
         Bld_Creat_Dt,
         Bld_Prg_Id,
         Bld_Pam_Dt,
         Bld_Alloc_Id,
         Bld_Special_Attribute,
         Bld_Ind_Flg,
         Bld_Seg_Id,
         Bld_Ent_Id,
         Bld_Stc_Stt_Exm_Id,
         Bld_Remarks,
         Bld_Dr_Cr_Flag,
         Bld_Stc_Stt_Type,
         Bld_Stc_No,
         Bld_Stage,
         Bld_Mf_Purc_Redm_Flag,
         b.Bld_Arks)
        SELECT l_Bld_No,
               Bld_Blm_No,
               Bld_Blm_Status,
               Bld_Icn_No,
               Tcm_Reversal_Cd,
               Pam_Curr_Dt,
               Bld_Due_Amt,
               Bld_Adj_In_Amt,
               Decode(Nvl(Bld_Amt_Recd, 0),0,0,(Bld_Due_Amt - Nvl(Bld_Amt_Recd, 0))),
               Bld_Blm_Cpd_Id,
               USER,
               SYSDATE,
               l_Prg_Id,
               Pam_Curr_Dt,
               Bld_Alloc_Id,
               Decode(Bld_Special_Attribute, 'B', 'S', NULL),
               Bld_Ind_Flg,
               Bld_Seg_Id,
               Bld_Ent_Id,
               Bld_Stc_Stt_Exm_Id,
               Bld_Remarks,
               Decode(Bld_Dr_Cr_Flag, 'D', 'C', 'D'),
               Bld_Stc_Stt_Type,
               Bld_Stc_No,
               'O',
               Bld_Mf_Purc_Redm_Flag,
               'REVERSED IN ' || p_Cancel_Remark
        FROM   Bill_Details,
               Txn_Code_Master,
               Parameter_Master
        WHERE  Bld_Ent_Id = p_Ent_Id
        AND    Bld_Blm_No = j.Bill_No
        AND    Bld_Icn_No = l_Contract_No
        AND    Bld_Tcm_Cd = Tcm_Cd
        AND    Bld_Tcm_Cd = j.Tcm_Cd
        AND    Bld_Remarks= p_Order_No
        AND    Bld_Arks   = p_Order_No
        AND    ROWNUM      = 1;

     /* UPDATE Bill_Details
      SET    Bld_Amt_Recd = Bld_Due_Amt,
             Bld_Stage    = 'C'
      WHERE  Bld_Ent_Id = p_Ent_Id
      AND    Bld_Blm_No = j.Bill_No
      AND    Bld_Icn_No = l_Contract_No
      AND    Bld_Tcm_Cd = j.Tcm_Cd
      AND     Bld_Remarks= p_Order_No
      AND    Bld_Arks   = p_Order_No;*/

      l_Bill_Count := l_Bill_Count + 1;
      l_Bill_No    := j.Bill_No;

    END LOOP;

    o_Total_Bills_Reversed := l_Bill_Count;

    o_Ret_Msg := 'Updating Funds obligations for order No  <' || p_Order_No ||
                 '>, j.ent_id <' || p_Ent_Id || '>';

    UPDATE Mfss_Funds_Obligation o
    SET    Bill_Reversed_Flag = 'Y',
           Order_Status       = 'C',
           Order_Remark       = 'CANCELLED IN ' || p_Cancel_Remark,
           Last_Updt_By       = USER,
           Last_Updt_Dt       = SYSDATE
    WHERE  Order_No = p_Order_No
    AND    Buy_Sell_Flg = p_Buy_Sell_Flag
    AND    Order_Date = p_Order_Date
    AND    Security_Id = p_Security_Id
    AND    Ent_Id = p_Ent_Id
    AND    Exm_Id = p_Exm_Id
    AND    Stc_No = p_Stc_No
    AND    Nvl(Bill_Reversed_Flag, 'N') = 'N';

    o_Ret_Msg := 'Updating MFSS Trades for order No  <' || p_Order_No ||
                 '>, j.ent_id <' || p_Ent_Id || '>';

    IF p_Cancel_Option = 'A' THEN
      UPDATE Mfss_Trades t
      SET    t.Order_Status  = 'CANCEL',
             t.Order_Remark  = 'CANCELLED IN ' || p_Cancel_Remark,
             t.Reject_Reason = 'REJECTED IN ' || p_Cancel_Remark,
             t.Last_Updt_Dt  = SYSDATE,
             t.Last_Updt_By  = USER,
             t.Confirmation_Flag = 'N',
             t.Mfss_Funds_Payin_Success_Yn = 'N'
      WHERE  t.Order_No = p_Order_No
      AND    t.Exm_Id = p_Exm_Id
      AND    t.Stc_No = p_Stc_No
      AND    t.Buy_Sell_Flg = p_Buy_Sell_Flag
      AND    t.Order_Date = p_Order_Date
      AND    t.Ent_Id = p_Ent_Id
      AND    t.Security_Id = p_Security_Id;

    ELSIF p_Cancel_Option  = 'C' THEN
      UPDATE Mfss_Trades t
      SET    BILL_NO           = NULL,
             CONTRACT_NO     = NULL,
             Confirmation_Flag = 'Y',
             Order_Status     = 'VALID',
             t.Order_Remark  = 'Cancelled for ' || p_Cancel_Remark,
             t.Last_Updt_Dt  = SYSDATE,
             t.Last_Updt_By  = USER,
             t.Mfss_Funds_Payin_Success_Yn = 'N'
      WHERE  t.Order_No = p_Order_No
      AND    t.Exm_Id = p_Exm_Id
      AND    t.Stc_No = p_Stc_No
      AND    t.Buy_Sell_Flg = p_Buy_Sell_Flag
      AND    t.Order_Date = p_Order_Date
      AND    t.Ent_Id = p_Ent_Id
      AND    t.Security_Id = p_Security_Id;
    END IF;
    o_Ret_Msg := 'SUCCESS';

  EXCEPTION
    WHEN Others THEN
      o_Ret_Msg := o_Ret_Msg||SQLERRM;
  END p_Reverse_Bills;

  PROCEDURE p_Get_Comm_Rate(p_Ent_Id            IN VARCHAR2,
                            p_Buy_Sell_Flag     IN VARCHAR2,
                            p_Exm_Id            IN VARCHAR2,
                            p_Order_Type        IN VARCHAR2,
                            p_Holding_Mode      IN VARCHAR2,
                            p_Scheme_Id         IN VARCHAR2,
                            o_Sch_Id            OUT VARCHAR2,
                            o_Per_Rate          OUT NUMBER,
                            o_Amt_Per_Trade     OUT NUMBER,
                            o_Min_Amt_Per_Trade OUT NUMBER) IS

    l_Pam_Curr_Dt            DATE;
    l_p_Order_Type           VARCHAR2(10);
    l_scheme_type1           VARCHAR2(30);
    l_scheme_type            VARCHAR2(3);
    l_check                 NUMBER(1);
    l_entity_comm_scheme    NUMBER(30);
    l_flat_charge_per_order NUMBER;
    l_percent_order_value   NUMBER;
    l_min_brk_amt           NUMBER;
    l_scheme_from_dt        DATE;
  BEGIN
    SELECT pam_curr_dt
    INTO   l_Pam_Curr_Dt
    FROM   parameter_master;

    IF p_Order_Type = 'NRM' THEN
       l_p_Order_Type := p_Buy_Sell_Flag;
    ELSIF p_Order_Type = 'SIP' THEN
      SELECT decode(p_Buy_Sell_Flag,'P','S','R','W')
      INTO   l_p_Order_Type
      FROM   dual;
    END IF;

    BEGIN
      SELECT msm_scheme_type
      INTO   l_scheme_type1
      FROM   Mfd_Scheme_Master
      WHERE  Msm_Scheme_Id     = P_Scheme_Id
      AND    l_Pam_Curr_Dt BETWEEN Msm_From_Date AND Nvl(Msm_To_Date, l_Pam_Curr_Dt)
      AND    Msm_Record_Status = 'A'
      AND    Msm_Status        = 'A';

      SELECT config_code
      INTO   l_scheme_type
      FROM   config_data
      WHERE  config_value = l_scheme_type1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_scheme_type := 'D';
    END;

    BEGIN
      SELECT to_number(EMD_SCHEME_ID)
      INTO   l_entity_comm_scheme
      FROM   Entity_Mfss_Details
      WHERE  EMD_ENT_ID = p_Ent_Id;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_entity_comm_scheme := NULL;
    END;

    BEGIN
      SELECT 1
      INTO  l_check
      FROM  dual
      WHERE EXISTS (SELECT mfm_scheme_id
      FROM   mf_commission_scheme_master M
      WHERE to_number(M.mfm_scheme_id) = l_entity_comm_scheme
      AND   l_Pam_Curr_Dt Between M.mfm_from_date AND  Nvl(M.mfm_to_date, l_Pam_Curr_Dt));

      SELECT m.mfm_from_date
      INTO   l_scheme_from_dt
      FROM   mf_commission_scheme_master m, parameter_master
      WHERE  m.mfm_scheme_id = l_entity_comm_scheme
      AND    pam_curr_dt BETWEEN m.mfm_from_date AND Nvl(m.mfm_to_date, pam_curr_dt);

    EXCEPTION
    WHEN No_Data_Found THEN
      BEGIN
      --default scheme id and from date
        SELECT m.mfm_scheme_id,
               m.mfm_from_date
        INTO   l_entity_comm_scheme,
               l_scheme_from_dt
        FROM   mf_commission_scheme_master m
        WHERE  m.mfm_default_flag = 'Y'
        AND    l_Pam_Curr_Dt Between M.mfm_from_date and
        Nvl(M.mfm_to_date, l_Pam_Curr_Dt);
      EXCEPTION
        WHEN No_Data_Found THEN
          RAISE;
      END;
    END;

    BEGIN
      SELECT MFD_AMT_PER_ORDER,
             MFD_RATE_PERCENT,
             MFD_MIN_AMT_PER_ORDER
      INTO    l_flat_charge_per_order,
             l_percent_order_value,
             l_min_brk_amt
      FROM
       (SELECT D.mfd_amt_per_order mfd_amt_per_order,
               D.mfd_rate_percent mfd_rate_percent,
               D.mfd_min_amt_per_order mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = p_Exm_Id --V V V V ---Last four parameters equated with input values : MFD_MF_TYPE, MFD_TXN_TYPE, MFD_APPLICATION_CHANNEL, MFD_EXCHANGE
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = 'DEFAULT'   --V  V  V  D  ---First 3 parameters equated with input values while Mfd_Exch equated with Default value and so on.
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = p_Exm_Id  -- V  V  D  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = 'DEFAULT' --V  V  D  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = p_Exm_Id -- V  D  V  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = 'DEFAULT' -- V  D  V  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = p_Exm_Id -- V  D  D  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = l_scheme_type
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = 'DEFAULT' --V  D  D  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = p_Exm_Id  -- D  V  V  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = 'DEFAULT' --D  V  V  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = p_Exm_Id -- D  V  D  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = l_p_Order_Type
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = 'DEFAULT' --D  V  D  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = p_Exm_Id -- D  D  V  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = decode(p_Holding_Mode,'DEMAT','M','PHYSICAL','P','D')
           AND D.MFD_EXCHANGE = 'DEFAULT' -- D  D  V  D
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = p_Exm_Id --D  D  D  V
        UNION ALL
        SELECT D.mfd_amt_per_order,
               D.mfd_rate_percent,
               D.mfd_min_amt_per_order
        FROM    MF_Commission_Scheme_Master  M,
               MF_Commission_Scheme_Details D
        WHERE  M.mfm_scheme_id = D.mfd_scheme_id
           AND to_number(M.mfm_scheme_id) = l_entity_comm_scheme
           AND M.mfm_from_date = d.mfd_from_date
           AND l_Pam_Curr_Dt Between M.mfm_from_date AND Nvl(M.mfm_to_date, l_Pam_Curr_Dt)
           AND D.MFD_MF_TYPE = 'D'
           AND D.MFD_TXN_TYPE = 'D'
           AND D.MFD_APPLICATION_CHANNEL = 'D'
           AND D.MFD_EXCHANGE = 'DEFAULT') -- D  D  D  D
      WHERE ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_flat_charge_per_order :=0;
        l_percent_order_value   :=0;
        l_min_brk_amt            :=0;
    END;

    o_Sch_Id            := l_entity_comm_scheme;
    o_Per_Rate          := l_percent_order_value;
    o_Amt_Per_Trade     := l_flat_charge_per_order;
    o_Min_Amt_Per_Trade := l_min_brk_amt;

  END p_Get_Comm_Rate;

  -- Procedure to generate the Payment cancellation and Order Cancellation File.
  PROCEDURE P_Gen_MF_SIP_File(P_Exm_Id           IN VARCHAR2  ,
                              p_Settlement_Type  IN VARCHAR2,
                              o_Ret_Val          OUT VARCHAR2 ,
                              o_Message          OUT VARCHAR2 ) IS
    l_Pam_Curr_Dt                    DATE                       ;
    l_Sql_Stmt                       VARCHAR2(1000)             ;
    l_Exception                      EXCEPTION                  ;
    l_Ord_Partial_Count              NUMBER(7):=0               ;
    l_Pmt_Partial_Count              NUMBER(7):=0               ;
    l_Log_File_Ptr                   Utl_File.File_Type         ;
    l_Datafile_Handle_Pmt            Utl_File.File_Type         ;
    l_Datafile_Name_Pmt              VARCHAR2(300)              ;
    l_Datafile_Path_Pmt              VARCHAR2(300)              ;
    l_Datafile_Handle_Ord            Utl_File.File_Type         ;
    l_Datafile_Name_Ord              VARCHAR2(300)              ;
    l_Datafile_Path_Ord              VARCHAR2(300)              ;
    l_Prg_Id                         VARCHAR2(10) := 'CSSMFFG'  ;
    l_Log_File_Path                  VARCHAR2(300)              ;
    l_Process_Id                     NUMBER(10) := 0            ;
    o_Sqlerrm                        VARCHAR2(3000)             ;
    l_Batch_No                       VARCHAR2(30)               ;
    l_Hrt_Status                     VARCHAR2(1)                ;
    l_Hrt_Response_Code              NUMBER(10)                 ;
    l_Ord_Failed_Count               NUMBER :=0                 ;
    l_Pmt_Failed_Count               NUMBER :=0                 ;
    l_Datafile_Handle_Nse            Utl_File.File_Type         ;
    l_Datafile_Name_Nse              VARCHAR2(300)              ;
    l_Datafile_Path_Nse              VARCHAR2(300)              ;
    l_Count                          NUMBER := 0                ;

    CURSOR C_Gen_Order_File_Rec IS
     SELECT t.Ent_Id Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ent_mf_ucc_code,
             t.ROWID
      FROM   Mfss_Trades t,entity_master e
      WHERE  t.Exm_Id       = P_Exm_Id
      AND    t.BUY_SELL_FLG = 'P'
      AND    t.ent_id       = e.ent_id
      AND    t.terminal_id  IS NULL
      AND    t.Order_Status = 'VALID'
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND   t.Order_Date    = l_Pam_Curr_Dt
      AND   Channel_Id      = 'DEFAULT'
      AND   NVL(t.Fund_Hold_Success_Flg,'N') = 'N'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      UNION ALL
      SELECT t.Ent_Id Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ent_mf_ucc_code,
             t.ROWID
      FROM   Mfss_Trades t,entity_master e
      WHERE  t.Exm_Id       = P_Exm_Id
      AND    t.Buy_Sell_Flg = 'P'
      AND    t.ent_id       = e.ent_id
      AND    T.Order_Status = 'F'
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND   T.SIP_REGN_NO IS NOT NULL
      AND   t.Order_Date    = l_Pam_Curr_Dt
      AND   Channel_Id      = 'DEFAULT'
      AND   NVL(t.Fund_Hold_Success_Flg,'N') = 'N'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      ORDER BY Ent_Id,Amount DESC;

      CURSOR C_Gen_Pmt_File_Rec IS
      SELECT t.Ent_Id Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ent_mf_ucc_code,
             t.ROWID
      FROM   Mfss_Trades t,entity_master e
      WHERE t.Exm_Id       = P_Exm_Id
      AND   t.BUY_SELL_FLG = 'P'
      AND   t.ent_id = e.ent_id
      AND   t.terminal_id  IS NULL
      AND   t.Order_Status = 'VALID'
      AND   t.Order_Date   = l_Pam_Curr_Dt
      AND   Channel_Id     = 'DEFAULT'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      UNION ALL
      SELECT t.Ent_Id Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ent_mf_ucc_code,
             t.ROWID
      FROM   Mfss_Trades t,entity_master e
      WHERE t.Exm_Id       = P_Exm_Id
      AND   t.Buy_Sell_Flg = 'P'
      AND   t.ent_id = e.ent_id
      AND   T.Order_Status = 'F'
      AND   Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))

      AND   T.SIP_REGN_NO IS NOT NULL
      AND   t.Order_Date   = l_Pam_Curr_Dt
      AND   Channel_Id     = 'DEFAULT'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y';

     CURSOR c_Funds_Stmt_Sip_L0 IS
      SELECT t.Order_Date Order_Date,
             Decode(T.Exm_Id,
                    'BSE',
                    To_Char(t.Order_Date, 'RRRR-MM-DD'),
                    'NSE',
                    To_Char(t.Order_Date, 'DD-MON-RRRR')) Order_Dt,
             Decode(T.Exm_Id,
                    'BSE',
                    To_Char(PAM_CURR_DT, 'RRRR-MM-DD'),
                    'NSE',
                    Decode(Settlement_Type,'L1',
                    To_Char(PAM_CURR_DT, 'DD-MON-RRRR'),'L0', To_Char(PAM_CURR_DT, 'DD-MON-RRRR')
                    ,Pam_Next_Dt)) Sett_Dt,
             t.Settlement_Type Sett_Type,
             t.Stc_No Sett_No,
             t.member_code Member_Cd,
             t.Ent_Id Client_Cd,
             t.Dp_Id Dp_Id,
             t.dp_acc_no Dp_Acc_No,
             t.Order_No Order_No,
             t.Buy_Sell_Flg Buy_Sell,
             t.Amc_Scheme_Code Scheme_Id,
             t.scheme_symbol Symbol,
             t.scheme_series Series,
             t.isin Isin,
             t.Amount Amount,
             t.Security_Id Security_Id,
             Nvl(t.Fund_Hold_Success_Flg, 'N') Status,
             Decode(t.Fund_Hold_Success_Flg,
                    'Y',
                    'Payin Done',
                    'Insufficient Balance') Remarks,
             ent_mf_ucc_code,
             rownum rn,
             Dp_Name
      FROM   Mfss_Trades T,entity_master e,
             Parameter_Master
      WHERE  t.Exm_Id       = P_Exm_Id
      AND    t.Buy_Sell_Flg = 'P'
      AND    t.ent_id = e.ent_id
      AND    T.Order_Status in ('F','VALID')
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND    t.Order_Date   = l_Pam_Curr_Dt
      AND    Channel_Id     = 'DEFAULT'
      AND    NVL(t.Fund_Hold_Success_Flg,'N') = 'N'
      AND    Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND    t.Mft_Hrt_Batch_No IS NOT NULL;


  BEGIN

    o_Ret_Val := 'FAIL';

    SELECT Pam_Curr_Dt
    INTO l_Pam_Curr_Dt
    FROM Parameter_Master;

    l_Sql_Stmt := 'Getting Datafile path for generating funds payin adequacy file .';
    SELECT Rv_High_Value
    INTO   l_Datafile_Path_Pmt
    FROM   Cg_Ref_Codes
    WHERE  Rv_Domain = 'DATA_FILES'
    AND    Rv_Low_Value = 'CSS_FILES';

    l_Datafile_Path_Ord := l_Datafile_Path_Pmt;
    l_Datafile_Path_NSE := l_Datafile_Path_Pmt;

    l_Sql_Stmt := 'Performing Housekeeping ';

    Std_Lib.P_Housekeeping(l_Prg_Id        ,
                           P_Exm_Id        ,
                           l_Pam_Curr_Dt||'-'||P_Exm_Id,
                           'M'             ,
                           l_Log_File_Ptr  ,
                           l_Log_File_Path ,
                           l_Process_Id    ,
                           'Y')            ;

    l_Sql_Stmt := 'Checking for Nameing the Files';

    IF P_Exm_Id = 'BSE' THEN

      SELECT Lpad(MFSS_PAYMENT_REJECTION_SEQ.NEXTVAL, 5, '0')
      INTO   l_Batch_No
      FROM   Dual;

      l_Sql_Stmt := 'Nameing the file';
       l_Datafile_Name_Pmt   := 'CLIENT_PAYMENT_REJECTION_' ||
                                To_Char(l_Pam_Curr_Dt, 'DD-MM-RRRR') || '_' ||
                                l_Batch_No || '.txt';

      l_Datafile_Name_Ord   := '0393_' ||
                                To_Char(l_Pam_Curr_Dt, 'DDMonRRRR') || '_' ||
                                'ORDERS_' || l_Batch_No || '.txt';

      l_Sql_Stmt := 'Opening File <' || l_Datafile_Name_Pmt ||'> to write .';
      l_Datafile_Handle_Pmt := Utl_File.Fopen(l_Datafile_Path_Pmt,
                                              l_Datafile_Name_Pmt,
                                              'W');
      l_Sql_Stmt := 'Opening File <' || l_Datafile_Name_Ord ||'> to write .';
      l_Datafile_Handle_Ord := Utl_File.FOpen(l_Datafile_Path_Ord,
                                              l_Datafile_Name_Ord,
                                              'W');

    END IF;


    FOR j IN C_Gen_Order_File_Rec
    LOOP
      BEGIN
        SELECT DISTINCT Hrt_Status,
               HRT_RESPONSE_CODE
        INTO   l_Hrt_Status,
               l_Hrt_Response_Code
        FROM   v_Hrt_Funds_Transaction
        WHERE  Hrt_Ent_Id   = j.Ent_Id
        AND    Hrt_Batch_Id = j.Mft_Hrt_Batch_No
        AND    Hrt_Date     = l_Pam_Curr_Dt
        AND    Hrt_Txn_Type = 'HL';
      EXCEPTION
        WHEN OTHERS THEN
          l_Hrt_Status := 'F';
      END;

      IF P_Exm_Id = 'BSE' AND l_Hrt_Status = 'S' THEN

        Utl_File.Put_Line(l_Datafile_Handle_Ord,
                          j.Member_Code|| '|' ||
                          to_Char(l_Pam_Curr_Dt,'DD/MM/RRRR') || '|' ||
                          TO_CHAR(TRUNC(SYSDATE),'HH:MM:SSAM') || '|' ||
                          j.Order_No || '|' ||
                          j.Stc_No || '|' ||
                          j.ent_mf_ucc_code || '|' ||
                          j.First_Client_Name || '|' ||
                          j.Amc_Code || '|' ||
                          j.Scheme_Name || '|' ||
                          j.ISIN || '|' ||
                          j.buy_sell_flg  || '|' ||
                          j.Amount || '|' ||
                          0 || '|' ||
                          NULL || '|' ||
                          j.Dp_Folio_No || '|' ||
                          j.Dp_Folio_No || '|' ||
                          '' || '|' ||
                          'INVALID' || '|' ||
                          'FAILED' || '|' ||
                          j.Internal_Ref_No || '|' ||
                          j.Settlement_Type || '|' ||
                          j.Order_Type || '|' ||
                          j.Sip_Regn_No || '|' ||
                          j.Sip_Regn_Date);
        l_Ord_Partial_Count := l_Ord_Partial_Count + 1;
      ELSIF P_Exm_Id = 'BSE' AND l_Hrt_Status = 'F' THEN

        Utl_File.Put_Line(l_Datafile_Handle_Ord,
                          j.Member_Code|| '|' ||
                          to_Char(l_Pam_Curr_Dt,'DD/MM/RRRR') || '|' ||
                          TO_CHAR(TRUNC(SYSDATE),'HH:MM:SSAM') || '|' ||
                          j.Order_No || '|' ||
                          j.Stc_No || '|' ||
                          j.ent_mf_ucc_code || '|' ||
                          j.First_Client_Name || '|' ||
                          j.Amc_Code || '|' ||
                          j.Scheme_Name || '|' ||
                          j.ISIN || '|' ||
                          j.buy_sell_flg  || '|' ||
                          j.Amount || '|' ||
                          0 || '|' ||
                          '' || '|' ||
                          j.Dp_Folio_No || '|' ||
                          j.Dp_Folio_No || '|' ||
                          '' || '|' ||
                          'INVALID' || '|' ||
                          'FAILED' || '|' ||
                          j.Internal_Ref_No || '|' ||
                          j.Settlement_Type || '|' ||
                          j.Order_Type || '|' ||
                          j.Sip_Regn_No || '|' ||
                          j.Sip_Regn_Date);
        l_Ord_Failed_Count := l_Ord_Failed_Count + 1;
      END IF;
    END LOOP;

    FOR j IN C_Gen_Pmt_File_Rec
    LOOP
      BEGIN
        SELECT DISTINCT Hrt_Status,
               Hrt_Response_Code
        INTO   l_Hrt_Status,
               l_Hrt_Response_Code
        FROM   v_Hrt_Funds_Transaction
        WHERE  Hrt_Ent_Id   = j.Ent_Id
        AND    Hrt_Batch_Id = j.Mft_Hrt_Batch_No
        AND    Hrt_Date     = l_Pam_Curr_Dt
        AND    Hrt_Txn_Type = 'HL';
      EXCEPTION
        WHEN OTHERS THEN
          l_Hrt_Status := 'F';
      END;

      IF P_Exm_Id = 'BSE' AND l_Hrt_Status = 'S' THEN

        Utl_File.Put_Line(l_Datafile_Handle_Pmt,
                              j.Order_No || '|' ||
                              j.Member_Code || '|' ||
                              j.ent_mf_ucc_code || '|' ||
                              j.Stc_No || '|' ||
                              j.Amount || '|' ||
                              'N' || '|' ||
                              'Failed due to Partial Hold Adjustment for Order No: '|| j.Order_No );

        l_Pmt_Partial_Count := l_Pmt_Partial_Count + 1;

      ELSIF P_Exm_Id = 'BSE' AND l_Hrt_Status = 'F' THEN

        Utl_File.Put_Line(l_Datafile_Handle_Pmt,
                          j.Order_No || '|' ||
                          j.Member_Code || '|' ||
                          j.ent_mf_ucc_code || '|' ||
                          j.Stc_No || '|' ||
                          j.Amount || '|' ||
                          'N' || '|' ||
                          'Failed due to unsuccessful bank transaction for order no: <'|| j.Order_No  ||'> with bank response code: ' ||l_Hrt_Response_Code);

        l_Pmt_Failed_Count := l_Pmt_Failed_Count + 1;
      END IF;
    END LOOP;

     IF P_Exm_Id = 'NSE' THEN

      FOR i IN c_Funds_Stmt_Sip_L0
      LOOP
      IF l_Count = 0 THEN

      SELECT Lpad(MFSS_PAYMENT_REJECTION_SEQ.NEXTVAL, 5, '0')
      INTO   l_Batch_No
      FROM   Dual;

      l_Sql_Stmt := 'Nameing the file for NSE';

      l_Datafile_Name_Nse := 'M_' || i.Member_Cd || '_COBG_' ||
                                 To_Char(l_Pam_Curr_Dt, 'DDMMRRRR') || '_' ||
                                 '01' || '.csv';

      l_Sql_Stmt := 'Opening File <' || l_Datafile_Path_NSE ||'> to write .';
      l_Datafile_Handle_Nse := Utl_File.Fopen(l_Datafile_Path_NSE,
                                              l_Datafile_Name_Nse,
                                              'W');
      END IF;

    IF i.rn = 1 THEN
      Utl_File.Put_Line(l_Datafile_Handle_Nse,
                            'Order Date' || ',' || 'Settlement Date' || ',' ||
                            'Settlement type' || ',' || 'Settlement No.' || ',' ||
                            'TM Code' || ',' || 'Client Code' || ',' ||
                            'Depository ID' || ',' || 'DP Client ID' || ',' ||
                            'Order No.' || ',' || 'Order Indicator' || ',' ||
                            'Symbol' || ',' || 'Series' || ',' || 'Amount' || ',' ||
                            'Confirmation flag');
      END IF;

      Utl_File.Put_Line(l_Datafile_Handle_Nse,
                            To_Char(to_date(i.Order_Dt),'DDMMYYYY') || ',' || To_Char(To_date(i.Sett_Dt),'DDMMYYYY') || ',' ||
                            'S' || ',' || i.Sett_No || ',' ||
                            i.Member_Cd || ',' || i.ent_mf_ucc_code || ',' ||
                            CASE WHEN i.Dp_Name = 'NSDL' THEN 'IN300126' WHEN i.Dp_Name = 'CDSL' THEN NULL ELSE NULL END|| ',' ||
                            CASE WHEN i.Dp_Name = 'NSDL' THEN '11178642' WHEN i.Dp_Name = 'CDSL' THEN '1301240000005785' ELSE NULL END|| ',' ||
                            i.Order_No || ',' || 'S' || ',' ||
                            i.Symbol || ',' || i.Series || ',' ||Trim(To_Char(i.Amount,'99999999999990D99')) || ',' ||
                            i.Status);

      l_Count := l_Count + 1;

    END LOOP;
    END IF;

    Utl_File.Fclose(l_Datafile_Handle_Pmt);
    Utl_File.Fclose(l_Datafile_Handle_Ord);
    Utl_File.Fclose(l_Datafile_Handle_Nse);

    l_Sql_Stmt := 'Updating Program Status ';

    Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                            l_Pam_Curr_Dt ,
                            l_Process_Id  ,
                            'C'           ,
                            'Y'           ,
                            o_Sqlerrm)    ;

    o_Ret_Val := 'SUCCESS';
    l_Sql_Stmt:= 'Process Completed Successfully ';
    o_Message := l_Sql_Stmt;

    IF l_Ord_Partial_Count > 0 OR l_Ord_Failed_Count > 0 OR l_Pmt_Partial_Count > 0 OR l_Pmt_Failed_Count > 0THEN
      Utl_File.New_Line(l_Log_File_Ptr,2);
      Utl_File.Put_Line(l_Log_File_Ptr,'Following file created at '||l_Datafile_Path_Pmt);
      Utl_File.Put_Line(l_Log_File_Ptr,'1) '||l_Datafile_Name_Pmt);
      Utl_File.Put_Line(l_Log_File_Ptr,'2) '||l_Datafile_Name_Ord);
    END IF;

    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Order File');
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Records due to Partial Hold                 : ' || l_Ord_Partial_Count);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Records due to failed bank transactions     : ' || l_Ord_Failed_Count/*l_Fail_Count*/);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Payment File');
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Records due to Partial Hold                 : ' || l_Pmt_Partial_Count);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Records due to failed bank transactions     : ' || l_Pmt_Failed_Count/*l_Fail_Count*/);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,o_Message);
    Utl_File.Fclose(l_Log_File_Ptr);

  IF P_Exm_Id='BSE' THEN

    IF l_Datafile_Name_Pmt IS NOT NULL THEN
      UPDATE program_status a
      SET Prg_OutPut_File =  l_Datafile_Path_Pmt || '/' || l_Datafile_Name_Pmt
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND    PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id)
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);
    ELSE
      UPDATE program_status a
      SET Prg_OutPut_File =  NULL
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND    PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id)
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);
    END IF;

    IF l_Datafile_Name_Ord IS NOT NULL THEN
      UPDATE program_status a
      SET Prg_Status_File =  l_Datafile_Path_Ord || '/' || l_Datafile_Name_Ord
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND    PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id)
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);

    ELSE
      UPDATE program_status a
      SET Prg_Status_File =  NULL
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND    PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id)
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);
    END IF;
  END IF;

  IF P_Exm_Id='NSE' THEN
    IF l_Datafile_Name_Nse IS NOT NULL THEN
      UPDATE program_status a
      SET Prg_Status_File =  l_Datafile_Path_Nse || '/' || l_Datafile_Name_Nse
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND   PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id )
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);
    ELSE
      UPDATE program_status a
      SET Prg_Status_File =  NULL
      WHERE Prg_Process_Id = (SELECT MAX(pRG_pROCESS_ID)
                              FROM Program_Status,
                                    PARAMETER_MASTER
                              WHERE prg_cmp_id = 'CSSMFFG'
                              AND    PRG_dT = PAM_CURR_DT
                              AND   Prg_Exm_Id = P_Exm_Id )
      AND Prg_Cmp_Id =   'CSSMFFG'
      AND  Prg_Dt = (SELECT Pam_Curr_Dt FROM Parameter_Master);
    END IF;
  END IF;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      o_Ret_Val := 'FAIL';
      o_Message := 'Error while '||l_Sql_Stmt ||' '||SQLCODE||' '||Substr(SQLERRM,1,200);

      Utl_File.New_Line(l_Log_File_Ptr,2);
      Utl_File.Put_Line(l_Log_File_Ptr,l_Sql_Stmt);
      Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed ');

      Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                              l_Pam_Curr_Dt ,
                              l_Process_Id  ,
                              'E'           ,
                              'Y'           ,
                              o_Sqlerrm)    ;


      IF Utl_File.is_open(l_Log_File_Ptr) THEN
        Utl_File.Fclose(l_Log_File_Ptr);
      END IF;
      IF Utl_File.is_open(l_Datafile_Handle_Pmt) THEN
        Utl_File.Fclose(l_Datafile_Handle_Pmt);
      END IF;
      IF Utl_File.is_open(l_Datafile_Handle_Ord) THEN
        Utl_File.Fclose(l_Datafile_Handle_Ord);
      END IF;
      IF Utl_File.is_open(l_Datafile_Handle_Nse) THEN
        Utl_File.Fclose(l_Datafile_Handle_Nse);
      END IF;
  END P_Gen_MF_SIP_File;

  -- Procedure to cancel the records having Fund_Hold_Success_Flg = 'N'.
  PROCEDURE P_Can_MF_SIP_Order(P_Exm_Id        IN VARCHAR2  ,
                               p_Settlement_Type  IN VARCHAR2,
                               o_Ret_Val       OUT VARCHAR2 ,
                               o_Message       OUT VARCHAR2 ) IS
    l_Pam_Curr_Dt                    DATE                       ;
    l_Pam_Next_Dt                    DATE                       ;
    l_Pam_Last_Dt                    DATE                       ;
    l_Sql_Stmt                       VARCHAR2(1000)             ;
    l_Exception                      EXCEPTION                  ;
    l_Log_File_Ptr                   Utl_File.File_Type         ;
    l_Prg_Id                         VARCHAR2(10) := 'CSSMFCO'  ;
    l_Log_File_Path                  VARCHAR2(300)              ;
    l_Process_Id                     NUMBER(10) := 0            ;
    o_Sqlerrm                        VARCHAR2(3000)             ;
    l_Process_Count                  NUMBER :=0                 ;
    l_Ret_Msg                        VARCHAR2(3000)             ;
    l_Total_Bills_Reversed           NUMBER(5);

    CURSOR C_Can_File_Rec IS
      SELECT Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Security_Id,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ROWID
      FROM   Mfss_Trades t
      WHERE  t.Exm_Id       = P_Exm_Id
      AND    t.BUY_SELL_FLG = 'P'
      --AND    order_no = '90228355'
      AND    t.terminal_id  IS NULL
      AND    t.Order_Status = 'VALID'
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND    t.Order_Date   = l_Pam_Curr_Dt
      AND    Channel_Id     = 'DEFAULT'
      AND    NVL(t.Fund_Hold_Success_Flg,'N') = 'N'
      AND    Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND    t.Mft_Hrt_Batch_No IS NOT NULL
      UNION ALL
      SELECT Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Security_Id,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             Mft_Hrt_Batch_No,
             ROWID
      FROM   Mfss_Trades t
      WHERE  t.Exm_Id       = P_Exm_Id
      AND    t.Buy_Sell_Flg = 'P'
      AND    T.Order_Status = 'F'
      --AND    order_no = '90228355'
      AND    Settlement_Type IN ((Decode(p_Settlement_Type,'L','L0','A',Settlement_Type)),
                                  Decode(p_Settlement_Type,'L','L1'),Decode(p_Settlement_Type,'N','MF'))
      AND    T.SIP_REGN_NO IS NOT NULL
      AND    t.Order_Date   = l_Pam_Curr_Dt
      AND    Channel_Id     = 'DEFAULT'
      AND    NVL(t.Fund_Hold_Success_Flg,'N') = 'N'
      AND    Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND    t.Mft_Hrt_Batch_No IS NOT NULL
      ORDER BY Ent_Id,Amount DESC;

  BEGIN

    o_Ret_Val := 'FAIL';

    l_Sql_Stmt:= 'Selecting Current,Next and Last Working Date';
    SELECT Pam_Curr_Dt,
           Pam_Next_Dt,
           Pam_Last_Dt
    INTO   l_Pam_Curr_Dt,
           l_Pam_Next_Dt,
           l_Pam_Last_Dt
    FROM   Parameter_Master;

    l_Sql_Stmt := 'Performing Housekeeping ';

    Std_Lib.P_Housekeeping(l_Prg_Id        ,
                           P_Exm_Id        ,
                           l_Pam_Curr_Dt||'-'||P_Exm_Id,
                           'M'             ,
                           l_Log_File_Ptr  ,
                           l_Log_File_Path ,
                           l_Process_Id    ,
                           'Y')            ;

    FOR i IN C_Can_File_Rec
    LOOP
      l_Sql_Stmt := 'reversing bills for Entity ID <'||i.Ent_Id||'> and Order No. <'||i.Order_No||'>';
      Pkg_Mfss_Settlement_Funds.p_Reverse_Bills(i.Ent_Id,
                                                i.Order_No,
                                                l_Pam_Curr_Dt,
                                                i.Buy_Sell_Flg,
                                                p_Exm_Id,
                                                i.Stc_No,
                                                i.Security_Id,
                                                'Cancel in CSSMFCO process',
                                                'A',
                                                l_Ret_Msg,
                                                l_Total_Bills_Reversed);

      IF l_Ret_Msg = 'SUCCESS' THEN
        l_Process_Count := l_Process_Count + 1;
      ELSE
        RAISE l_Exception;
      END IF;
    END LOOP;

    l_Sql_Stmt := 'Updating Program Status ';

    Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                            l_Pam_Curr_Dt ,
                            l_Process_Id  ,
                            'C'           ,
                            'Y'           ,
                            o_Sqlerrm)    ;

    o_Ret_Val := 'SUCCESS';
    l_Sql_Stmt:= 'Process Completed Successfully ';
    o_Message := l_Sql_Stmt;

    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Cancelled records                         : ' || l_Process_Count);
    COMMIT;
    UTL_FILE.FCLOSE(l_Log_File_Ptr);
  EXCEPTION
    WHEN OTHERS THEN
      o_Ret_Val := 'FAIL';
      o_Message := 'Error while '||l_Sql_Stmt ||' '||SQLCODE||' '||Substr(SQLERRM,1,200);

      Utl_File.New_Line(l_Log_File_Ptr,2);
      Utl_File.Put_Line(l_Log_File_Ptr,l_Sql_Stmt);
      Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed ');

      Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                              l_Pam_Curr_Dt ,
                              l_Process_Id  ,
                              'E'           ,
                              'Y'           ,
                              o_Sqlerrm)    ;
      UTL_FILE.FCLOSE(l_Log_File_Ptr);
  END P_Can_MF_SIP_Order;

  -- Procedure to marked hold which has been regenerated by system with batch id.
  PROCEDURE P_Regen_MF_Batch(P_Exm_Id      IN VARCHAR2  ,
                             P_Batch_Id    IN NUMBER    ,
                             P_Ent_Id      IN VARCHAR2  ,
                             o_Ret_Val     OUT VARCHAR2 ,
                             o_Message     OUT VARCHAR2 ) IS
    l_Pam_Curr_Dt                    DATE                       ;
    l_Index                          NUMBER := 0                ;
    l_Agency_Id                      VARCHAR2(30)               ;
    l_Thread                         NUMBER                     ;
    l_length_Threads                 NUMBER                     ;
    l_No_Of_Threads                   NUMBER                     ;
    l_Sql_Stmt                       VARCHAR2(1000)             ;
    l_Exception                      EXCEPTION                  ;
    l_Status                         NUMBER                     ;
    l_Success_Count                  NUMBER(7):=0               ;
    l_Fail_Count                     NUMBER(7):=0               ;
    l_Partial_Count                  NUMBER(7):=0               ;
    --l_Failed_Ent                     VARCHAR2(2000)             ;
    --l_Partial_Ent                    VARCHAR2(2000)             ;
    l_Sqlerrm                        VARCHAR2(4000)             ;
    l_Log_File_Ptr                   Utl_File.File_Type         ;
    l_Prg_Id                         VARCHAR2(10) := 'CSSMFBP'  ;
    l_Log_File_Path                  VARCHAR2(300)              ;
    l_Process_Id                     NUMBER(10) := 0            ;
    o_Sqlerrm                        VARCHAR2(3000)             ;
    l_Process_Count                  NUMBER :=0                 ;
    --l_Release_Ent_Id                 VARCHAR2(4000)             ;
    l_Remain_Amt                     NUMBER(15,2)               ;
    l_Adjust_Amt                     NUMBER(15,2)               ;
    l_Adjusted                       NUMBER(15,2)               ;
    l_Hrt_Pending_Amt                NUMBER(15,2)               ;
    l_Release_Amt                    NUMBER(15,2):=0            ;
    l_Hold_Record                    NUMBER                     ;
    l_msg                            VARCHAR2(3000)             ;
    l_Multi_Agency_Active_Yn          VARCHAR2(5)                ;



    TYPE R_Order_Hold IS RECORD
      (Ent_Id                    VARCHAR2(30) ,
       Order_No                  NUMBER(20)   ,
       Amount                    NUMBER(24,2) ,
       Member_Code               VARCHAR2(5)  ,
       Stc_No                    VARCHAR2(7)  ,
       First_Client_Name         VARCHAR2(250),
       Amc_Code                  VARCHAR2(30) ,
       Scheme_Name               VARCHAR2(300),
       ISIN                      VARCHAR2(12) ,
       buy_sell_flg              VARCHAR2(1)  ,
       Dp_Folio_No               VARCHAR2(30) ,
       Creat_By                  VARCHAR2(30) ,
       Internal_Ref_No           VARCHAR2(10) ,
       Settlement_Type           VARCHAR2(5)  ,
       Order_Type                VARCHAR2(3)  ,
       Sip_Regn_No               NUMBER       ,
       Sip_Regn_Date             DATE         ,
       Holding_Mode              VARCHAR2(10) ,
       Row_Id                    VARCHAR2(30));

    TYPE T_Order_Hold IS TABLE OF R_Order_Hold INDEX BY BINARY_INTEGER;

    l_Order_Hold      T_Order_Hold;

    TYPE R_Hold_Status IS RECORD
      (Hrt_Ent_Id                  VARCHAR2(30)   ,
       Hrt_Status                  VARCHAR2(1)    ,
       Hrt_Response_Code           VARCHAR2(1000) ,
       hrt_actual_hold_amount      NUMBER(20,2)   ,
       Hrt_Success_Hold_Amount     NUMBER(20,2)   ,
       HRT_Client_Bank_Account_No  VARCHAR2(20)   ,
       HRT_Broker_Bank_Account_No  VARCHAR2(20)   ,
       HRT_Inter_Agency_Id         VARCHAR2(30)   ,
       Hrt_Batch_Id                NUMBER(12))  ;

    TYPE T_Hold_Status IS TABLE OF R_Hold_Status INDEX BY BINARY_INTEGER;
    l_Out_Hold_Status        T_Hold_Status;

    T_Hrt_Funds_Transaction_Rl     Pkg_Funds_Payout_Release.Tab_Hrt_Funds_Transaction;


    ---
    Cursor C_Sip_Ord(c_batch varchar2,c_ent_id varchar2) is
    SELECT Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             t.ROWID
      --BULK COLLECT INTO l_Order_Hold
      FROM   Mfss_Trades t
      WHERE t.BUY_SELL_FLG = 'P'
      AND   t.terminal_id  IS NULL
      AND   t.Order_Date   = l_Pam_Curr_Dt
      AND   t.Fund_Hold_Success_Flg = 'N'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND   t.Mft_Hrt_Batch_No = c_batch--P_Batch_Id
      AND   t.Ent_Id       = c_ent_id--l_Out_Hold_Status(i).Hrt_Ent_Id

      UNION ALL

      SELECT Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             t.ROWID
      --BULK COLLECT INTO l_Order_Hold
      FROM   Mfss_Trades t
      WHERE t.BUY_SELL_FLG = 'P'
      --AND   t.terminal_id  IS NULL
      AND   T.Order_Status = 'F'
      AND   t.Order_Date   = l_Pam_Curr_Dt
      AND   t.Fund_Hold_Success_Flg = 'N'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND   t.Mft_Hrt_Batch_No = c_batch--P_Batch_Id
      AND   t.Ent_Id       = c_ent_id--l_Out_Hold_Status(i).Hrt_Ent_Id

      ORDER BY Amount DESC;
    ---

  BEGIN

    o_Ret_Val := 'FAIL';

    l_Sql_Stmt:= 'Selecting Current,Next and Last Working Date';
    SELECT Pam_Curr_Dt
    INTO   l_Pam_Curr_Dt
    FROM   Parameter_Master;

    l_Sql_Stmt := 'Performing Housekeeping ';

    Std_Lib.P_Housekeeping(l_Prg_Id        ,
                           P_Exm_Id        ,
                           l_Pam_Curr_Dt||'-'||P_Exm_Id,
                           'M'             ,
                           l_Log_File_Ptr  ,
                           l_Log_File_Path ,
                           l_Process_Id    ,
                           'Y')            ;


    l_Sql_Stmt:= 'Selecting Agency Id for the client';
    BEGIN
      SELECT /* +IDX_BAM_ENT_ID */
              DISTINCT Bim_Agency_Id
      INTO   l_Agency_Id
      FROM   Bank_Account_Master,
             Bank_Interface_Master Bim
      WHERE  Bam_Ent_Id =(SELECT Ent_Id FROM Entity_Master WHERE Ent_Type = 'BR')
      AND    Bam_Def_Bnk_Ind = 'Y'
      AND    Bim_Bkm_Cd = Bam_Bkm_Cd
      AND    Bim_Status = 'A';
    EXCEPTION
      WHEN OTHERS THEN
        l_Agency_Id := '101';
    END;

    l_Sql_Stmt := 'Fetching the status of processed records..';
    SELECT  DISTINCT  Hrt_Ent_Id,
                      Hrt_Status,
                      Hrt_Response_Code,
                      Hrt_Actual_Hold_Amount,
                      Hrt_Success_Hold_Amount,
                      HRT_Client_Bank_Account_No,
                      HRT_Broker_Bank_Account_No,
                      Hrt_Inter_Agency_Id,
                      Hrt_Batch_Id
    BULK COLLECT INTO l_Out_Hold_Status
    FROM    V_Hrt_Funds_Transaction,
            Mfss_Trades f
    WHERE   Hrt_Txn_Type   = 'HL'
    AND     Hrt_Date       = l_Pam_Curr_Dt
    AND     Hrt_Batch_Id   = P_Batch_Id
    AND     Hrt_Ent_Id     = NVL(P_Ent_Id,Hrt_Ent_Id)
    AND     Hrt_Ent_Id     = f.Ent_Id
    AND     Hrt_Date       = f.Order_Date
    AND     Hrt_Status     = 'S'
    AND     Hrt_Batch_Id   = f.Mft_Hrt_Batch_No
    AND     f.Fund_Hold_Success_Flg = 'N'
    AND   Nvl(f.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
    ORDER BY Hrt_Ent_Id;

    l_Index := 0;
    l_Sql_Stmt := 'Checking the status of processed records..';
    FOR i IN 1..l_Out_Hold_Status.Count
    LOOP
      IF l_Out_Hold_Status(i).Hrt_Status = 'S' AND l_Out_Hold_Status(i).Hrt_Actual_Hold_Amount = l_Out_Hold_Status(i).Hrt_Success_Hold_Amount AND l_Out_Hold_Status(i).Hrt_Response_Code = 0 THEN
        l_Success_Count := l_Success_Count + 1;

        UPDATE Mfss_Trades t
        SET    t.Fund_Hold_Success_Flg = 'Y'
        WHERE t.BUY_SELL_FLG = 'P'
        AND   t.terminal_id  IS NULL
        AND   t.Order_Date       = l_Pam_Curr_Dt
        AND   t.Ent_Id           = l_Out_Hold_Status(i).Hrt_Ent_Id
        AND   t.Mft_Hrt_Batch_No = P_Batch_Id;

        UPDATE Mfss_Trades t
        SET    t.Fund_Hold_Success_Flg = 'Y',
               T.Order_Status = 'VALID'
        WHERE t.Exm_Id       = P_Exm_Id
        AND   t.BUY_SELL_FLG = 'P'
        AND   t.Order_Date   = l_Pam_Curr_Dt
        AND   T.SIP_REGN_NO IS NOT NULL
        AND   T.Order_Status = 'F'
        AND   t.Ent_Id       = l_Out_Hold_Status(i).Hrt_Ent_Id;

        GOTO Next_Record;
      ELSIF l_Out_Hold_Status(i).Hrt_Status = 'S' AND l_Out_Hold_Status(i).Hrt_Actual_Hold_Amount > l_Out_Hold_Status(i).Hrt_Success_Hold_Amount AND l_Out_Hold_Status(i).Hrt_Response_Code = 0 THEN
        l_Partial_Count := l_Partial_Count + 1;
        --l_Partial_Ent   := l_partial_Ent || ' : ' || l_Out_Hold_Status(i).Hrt_Ent_Id;
      ELSIF l_Out_Hold_Status(i).Hrt_Status = 'F' THEN
        l_Fail_Count := l_Fail_Count + 1;
        --l_Failed_Ent := l_Failed_Ent || ' : ' || l_Out_Hold_Status(i).Hrt_Ent_Id;
      END IF;

      l_Sql_Stmt := 'Fetching order no wise hold required for the client: ' || l_Out_Hold_Status(i).Hrt_Ent_id ;

      /*SELECT Ent_Id,
             Order_No,
             Amount,
             Member_Code,
             Stc_No,
             First_Client_Name,
             Amc_Code,
             Scheme_Name,
             ISIN,
             buy_sell_flg,
             Dp_Folio_No,
             Creat_By,
             Internal_Ref_No,
             Settlement_Type,
             Order_Type,
             Sip_Regn_No,
             Sip_Regn_Date,
             Holding_Mode,
             t.ROWID
      BULK COLLECT INTO l_Order_Hold
      FROM   Mfss_Trades t
      WHERE t.BUY_SELL_FLG = 'P'
      AND   t.terminal_id  IS NULL
      AND   t.Order_Date   = l_Pam_Curr_Dt
      AND   t.Fund_Hold_Success_Flg = 'N'
      AND   Nvl(t.Mfss_Funds_Payin_Success_Yn,'N') <> 'Y'
      AND   t.Mft_Hrt_Batch_No = P_Batch_Id
      AND   t.Ent_Id       = l_Out_Hold_Status(i).Hrt_Ent_Id
      ORDER BY Amount DESC;*/

      l_Order_Hold.DELETE;

      OPEN C_Sip_Ord(P_Batch_Id,l_Out_Hold_Status(i).Hrt_Ent_Id);
      FETCH C_Sip_Ord BULK COLLECT
      INTO l_Order_Hold ;
      close C_Sip_Ord;



      l_Sql_Stmt := 'Checking the adjusted amount for the client '||l_Out_Hold_Status(i).Hrt_Ent_Id;
      SELECT NVL(SUM(Amount),0)
      INTO l_Adjusted
      FROM MFSS_TRades f
      WHERE ent_id = l_Out_Hold_Status(i).Hrt_Ent_Id
      AND f.Mft_Hrt_Batch_No = P_Batch_Id
      AND f.Fund_Hold_Success_Flg = 'Y';

      SELECT Nvl(SUM(Decode(Hrt_Txn_Type,'RL',-1,1) * (Nvl(Hrt_Success_Payin_Amount,0)+ Nvl(Hrt_Success_Hold_Amount,0))),0)
      INTO   l_Hrt_Pending_Amt
      FROM   Hrt_Funds_Transaction
      WHERE  Hrt_Date   = l_Pam_Curr_Dt
      AND    Hrt_Status    = 'S'
      AND    Hrt_Batch_Id  = P_Batch_Id
      AND    Hrt_Ent_Id    = l_Out_Hold_Status(i).Hrt_Ent_Id
      AND    Hrt_Txn_Type IN ('RL','HL')
      GROUP BY Hrt_Ent_Id;

      IF (l_Adjusted - l_Hrt_Pending_Amt) = 0 THEN
        l_Remain_Amt := 0;
      ELSE
        l_Remain_Amt    := l_Out_Hold_Status(i).Hrt_Success_Hold_Amount;
      END IF;

      l_Sql_Stmt := 'Checking the status of processed record for the client: ' || l_Out_Hold_Status(i).Hrt_Ent_id ;

      IF l_Remain_Amt > 0 THEN
        FOR j IN 1..l_Order_Hold.COUNT
        LOOP
          IF l_Out_Hold_Status(i).Hrt_Status = 'S' AND l_Out_Hold_Status(i).Hrt_Actual_Hold_Amount > l_Out_Hold_Status(i).Hrt_Success_Hold_Amount AND l_Out_Hold_Status(i).Hrt_Response_Code = 0 THEN

            l_Adjust_Amt := l_Order_Hold(j).Amount;
            IF l_Adjust_Amt <=  l_Remain_Amt THEN
              UPDATE Mfss_Trades t
              SET    t.Fund_Hold_Success_Flg = 'Y'
              WHERE  t.ROWID = l_Order_Hold(j).Row_Id;
            END IF;

            l_Release_Amt:= l_Remain_Amt;
            l_Remain_Amt := l_Remain_Amt - l_Adjust_Amt;

            IF l_Remain_Amt < 0 THEN
              l_Remain_Amt := l_Release_Amt;

            END IF;
            l_Release_Amt:= l_Remain_Amt;

          END IF;
        END LOOP;
      END IF;
      IF l_Release_Amt > 0 THEN

        l_Sql_Stmt:='Checking Whether Multi Threading Is Active';
        BEGIN
          SELECT Nvl(MAX(Rv_Low_Value),'Y')
          INTO   l_Multi_Agency_Active_Yn
          FROM   Cg_Ref_Codes
          WHERE  Rv_Domain = 'MULTI_AGENCY_ACTIVE' ;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Multi_Agency_Active_Yn := 'N';
        END;

        IF l_Multi_Agency_Active_Yn ='Y' THEN
          l_Sql_Stmt :='Getting Number of Thread';
          SELECT COUNT(DISTINCT Rv_High_value)
          INTO   l_No_Of_Threads
          FROM   Cg_Ref_Codes
          WHERE  Rv_Domain = 'MULTI_INTER_ACCOUNT_NO';
          l_length_Threads := Length(l_No_Of_Threads);
        END IF;

        l_Index := l_Index + 1;
        l_Thread := To_number(Mod(Substr(l_Out_Hold_Status(i).Hrt_Client_Bank_Account_No,-1 * l_length_Threads,l_length_Threads) ,
                                         l_No_Of_Threads));
        l_Sql_Stmt := 'Creating New Data for Release';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Date                    := l_Pam_Curr_Dt;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Ent_Id                   := l_Out_Hold_Status(i).Hrt_Ent_Id;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Exm_Id                   := P_Exm_Id;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Seg_Id                   := 'M';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Agency_Id               := l_Agency_Id;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Client_Bank_Account_No  := l_Out_Hold_Status(i).Hrt_Client_Bank_Account_No;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Broker_Bank_Account_No  := l_Out_Hold_Status(i).Hrt_Broker_Bank_Account_No;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Txn_Type                 := 'RL';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Dbcr                     := 'C';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Existing_Hold_Amount     := 0;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Proposed_Hold_Amount     := 0;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Proposed_Payin_Amount   := l_Release_Amt;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Actual_Hold_Amount       := 0;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Actual_Payin_Amount     := l_Release_Amt;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Status                   := 'I';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Creat_By                 := User;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Creat_Dt                 := Sysdate;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Prg_Id                   := 'CSSFMFSS';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Batch_Id                := P_Batch_Id;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Batch_Seq                := l_Index;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Qry_Processed_Date_Type := 'C';
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Qry_Include_Margin_Flag := NULL;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Qry_Hold_Payin_Type     := NULL;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Inter_Agency_Id         := l_Out_Hold_Status(i).Hrt_Inter_Agency_Id;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Inter_Funds_Reversal_Id := Null;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Internal_Failure_Reason := Null;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_File_Amount              := NULL;
        T_Hrt_Funds_Transaction_Rl(l_Index).Hrt_Thread_Id                := l_Thread;
        --l_Release_Ent_Id                                                := l_Release_Ent_Id  ||' : '|| l_Out_Hold_Status(i).Hrt_Ent_Id;
        l_process_Count                                                 := l_process_Count + 1;
      END IF;
      l_Release_Amt := 0;
      <<Next_Record>>
      NULL;
    END LOOP;

    l_Sql_Stmt := 'Sending Online transaction for Hold..';
    IF T_Hrt_Funds_Transaction_Rl.COUNT > 0 THEN
      Pkg_Funds_Payout_Release.P_Insert_Payout_Release(T_Hrt_Funds_Transaction_Rl ,
                                                        'ONLINE'                   ,
                                                       P_Batch_Id                 ,
                                                       l_Status                   ,
                                                       l_Sqlerrm);

      IF l_Status = 0 Then
        l_Sql_Stmt:= 'Release Process Completed Successfully ';
      ELSE
        l_Sql_Stmt := l_Sqlerrm;
        RAISE l_Exception;
      END IF;
    END IF;

    l_Sql_Stmt := 'Updating Program Status ';

    Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                            l_Pam_Curr_Dt ,
                            l_Process_Id  ,
                            'C'           ,
                            'Y'           ,
                            o_Sqlerrm)    ;

    o_Ret_Val := 'SUCCESS';
    l_Sql_Stmt:= 'Process Completed Successfully ';
    o_Message := l_Sql_Stmt;

    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Processed records                          : ' || l_Hold_Record);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Success Hold records                       : ' || l_Success_Count);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Partial Hold records                       : ' || l_Partial_Count);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Failed Hold records                        : ' || l_Fail_Count);
    Utl_File.Put_Line(l_Log_File_Ptr,'Number of Success Release records after partial hold : ' || l_Process_Count);

    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    IF l_Success_Count > 0 THEN
      Utl_File.Put_Line(l_Log_File_Ptr,'Clients having Success hold     :' || l_Success_Count);
      Utl_File.New_Line(l_Log_File_Ptr,1);
          Utl_File.Put_Line(l_Log_File_Ptr,l_Msg);
    END IF;

    /* IF l_Partial_Count > 0 THEN
      Utl_File.Put_Line(l_Log_File_Ptr,'Clients having partial hold     :' || l_Partial_Ent);
    END IF;

    IF l_process_Count > 0 THEN
      Utl_File.Put_Line(l_Log_File_Ptr,'Clients having Release record   :' || l_Release_Ent_Id);
    END IF;

    IF l_Fail_Count > 0 THEN
      Utl_File.Put_Line(l_Log_File_Ptr,'Clients having Fail hold record :' || l_Failed_Ent);
    END IF;*/

    Utl_File.Put_Line(l_Log_File_Ptr,'---------------------------------------------------------------------------');
    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,o_Message);
    Utl_File.Fclose(l_Log_File_Ptr);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      o_Ret_Val := 'FAIL';
      o_Message := 'Error while '||l_Sql_Stmt ||' '||SQLCODE||' '||Substr(SQLERRM,1,200);

      Utl_File.New_Line(l_Log_File_Ptr,2);
      Utl_File.Put_Line(l_Log_File_Ptr,l_Sql_Stmt);
      Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed ');

      Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                              l_Pam_Curr_Dt ,
                              l_Process_Id  ,
                              'E'           ,
                              'Y'           ,
                              o_Sqlerrm)    ;
    UTL_FILE.FCLOSE(l_Log_File_Ptr);
  END P_Regen_MF_Batch;

  -- Procedure for mutual funds ledger netting and updation of Mfss_Funds_Payin_Success_Yn flag of Mfss_Trades
  /*PROCEDURE P_Mutual_Fund_Netting(P_Ent_Id          IN VARCHAR2,
                                  P_Exm_Id          IN VARCHAR2,
                                  o_Message         OUT VARCHAR2,
                                  o_Ret_Val         OUT VARCHAR2)
  IS

    l_Ent_Id                        VARCHAR2(30)                        ;
    l_Prg_Id                        VARCHAR2(10) := 'CSSMFLN'           ;
    l_Exm_Id                        VARCHAR2(5)                         ;
    l_Prev_Dbcr                     VARCHAR2(1)                         ;
    l_Sql_Stmt                      VARCHAR2(1000)                      ;
    l_Alloc_Amt                     NUMBER :=0                          ;
    l_Alloc_Amt_Bills               NUMBER :=0                          ;
    l_Dr_Adj_Amt                    NUMBER :=0                          ;
    l_Cr_Adj_Amt                    NUMBER :=0                          ;
    l_Process_Id                    NUMBER(10) := 0                     ;
    o_Sqlerrm                       VARCHAR2(3000)                      ;
    l_Pam_Curr_Dt                   DATE                                ;
    l_Pam_Last_Dt                   DATE                                ;
    l_Log_File_Ptr                  Utl_File.File_Type                  ;
    l_Log_File_Path                 VARCHAR2(300)                       ;
    l_Remain_Dr                     NUMBER:=0                           ;
    l_Remain_Cr                     NUMBER:=0                           ;
    l_Actual_Dr                     NUMBER:=0                           ;
    l_Actual_Cr                     NUMBER:=0                           ;
    l_Count                         NUMBER(1) :=0                       ;
    l_Check_Amt                     NUMBER                              ;
    l_Amt_Tobe_Adjusted             NUMBER                              ;
    l_Prev_Bld_Remarks              VARCHAR2(150) := '-1'               ;
    l_Alloc_Amt_Bills_MSC           NUMBER :=0                          ;
    l_Alloc_Amt_Bills_MSD           NUMBER :=0                          ;
    l_Act_Amt_Tobe_Adjusted         NUMBER                              ;
    l_Alloc_Amt_Bills_Cr            NUMBER :=0                          ;
    l_Alloc_Amt_Bills_Dr            NUMBER :=0                          ;

    CURSOR C_MF_Bills IS
      SELECT Ent_Id     ,
             Exm_Id     ,
             Bill_Amt   ,
             Table_Rowid,
             E.ROWID      ,
             Due_Date   ,
             dr_cr_flag ,
             Table_Name ,
             Least(SUM(Decode(dr_cr_flag,'D',Bill_Amt,0)) over (PARTITION BY Ent_Id,Exm_Id),
                      SUM(Decode(dr_cr_flag,'C',Bill_Amt,0)) over (PARTITION BY Ent_Id,Exm_Id))  Amt_Tobe_Adjusted,
             E.Bld_Remarks,
             Bld_Tcm_Cd
      FROM   Tmp_Ledger_Netting E,
             (SELECT Bld_Remarks, ROWNUM RN
              FROM (
                   SELECT Bld_Remarks
                   FROM   Tmp_Ledger_Netting
                   WHERE  Bld_Tcm_Cd = 'FPI'
                   ORDER BY Bill_Amt DESC)) B
      WHERE  E.Bld_Remarks = B.Bld_Remarks(+)
      AND    Bill_Amt > 0
      ORDER BY Ent_Id,Exm_Id,dr_cr_flag DESC ,Table_Name,Due_Date, Nvl(RN, 999999999),Bill_Amt DESC;


    CURSOR C_Adj_Bills IS
      SELECT Bld_Remarks OrdeR_No,
             Bld_Stc_Stt_Exm_Id,
             Bld_Ent_Id,
             SUM(Bld_Due_Amt - NVL(Bld_Amt_Recd,0)) Due_Amt
      FROM   Bill_Details t
      WHERE  t.Bld_Pam_Dt               BETWEEN l_Pam_Last_Dt AND l_Pam_Curr_Dt
      AND    t.Bld_Seg_Id               = 'M'
      AND    t.Bld_Mf_Purc_Redm_Flag    = 'P'
      AND    Bld_Arks                   NOT LIKE '%REVERSED IN%'
      AND    Bld_Tcm_Cd                 NOT IN ('MSC','MSD')
      AND    Bld_Remarks                IS NOT NULL
      Group By Bld_Remarks,
            Bld_Stc_Stt_Exm_Id,
            Bld_Ent_Id
      Order By Bld_Stc_Stt_Exm_Id,
               Bld_Ent_Id,
               Bld_remarks;

  BEGIN
    l_Sql_Stmt := 'Selecting the Parameter Date';
    SELECT Pam_Curr_Dt,Pam_Last_Dt
    INTO   l_Pam_Curr_Dt,l_Pam_Last_Dt
    FROM Parameter_Master;

    l_Sql_Stmt := 'Performing Housekeeping ';

    Std_Lib.P_Housekeeping(l_Prg_Id        ,
                           P_Exm_Id        ,
                           l_Pam_Curr_Dt||'-'||P_Exm_Id,
                           'M'             ,
                           l_Log_File_Ptr  ,
                           l_Log_File_Path ,
                           l_Process_Id    ,
                           'Y')            ;
    l_Sql_Stmt := 'Calling ledger netting process for Redemption orders';

    --Pkg_Ledger_Netting.P_Mutual_Fund_Netting('R',P_Ent_Id,l_Pam_Curr_Dt);

    DELETE FROM Tmp_Ledger_Netting;

    l_Sql_Stmt := 'Inserting data into Tmp_Ledger_Netting';
    INSERT INTO Tmp_Ledger_Netting T
     (ENT_ID,       SEG_ID,        EXM_ID,
      BILL_AMT,     TABLE_ROWID,   DR_CR_FLAG,
      DUE_DATE,     TABLE_NAME ,   Bld_Remarks,
      Bld_Tcm_Cd)
    SELECT Bld_Ent_Id           ,          Bld_Seg_Id,
           Bld_Stc_Stt_Exm_Id   ,          Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) ,
           B.ROWID              ,          Bld_Dr_Cr_Flag,
           B.Bld_Due_Dt         ,          'B',
           Bld_Remarks          ,
           Bld_Tcm_Cd
    FROM   Bill_Details B,Entity_master e
    WHERE  Bld_Stage               = 'O'
    AND    Bld_Ent_Id              = Nvl(P_Ent_Id,Bld_Ent_Id)
    AND    Bld_Seg_Id              = 'M'
    AND    decode(Bld_Mf_Purc_Redm_Flag,'P',Bld_Pam_Dt, Bld_Due_Dt) <= l_Pam_Curr_Dt
    AND    e.ent_id = b.bld_ent_id
    AND    decode(e.ent_category,'NRI',b.bld_special_attribute,'B') = 'B'
    AND    Bld_Tcm_Cd              NOT IN ('MSC','MSD')
    AND    Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) > 0
    UNION ALL
    SELECT Bld_Ent_Id           ,          Bld_Seg_Id,
           Bld_Stc_Stt_Exm_Id   ,          Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) ,
           B.ROWID              ,          Bld_Dr_Cr_Flag,
           B.Bld_Due_Dt         ,          'B',
           Bld_Remarks        ,          Bld_Tcm_Cd
    FROM   Bill_Details B, Entity_master e
    WHERE  Bld_Stage               = 'O'
    AND    Bld_Ent_Id              = Nvl(P_Ent_Id,Bld_Ent_Id)
    AND    Bld_Pam_Dt              <= l_Pam_Curr_Dt
    AND    e.ent_id = b.bld_ent_id
    AND    decode(e.ent_category,'NRI',b.bld_special_attribute,'B') = 'B'
    AND    Bld_Seg_Id              = 'M'
    AND    Bld_Tcm_Cd              IN  ('MSC','MSD')
    AND    Nvl(Bld_Due_Amt,0) - Nvl(Bld_Amt_Recd,0) > 0
    UNION ALL
    SELECT Pmt_Ent_Id           ,          Pmt_Seg_Id,
           Pmt_Stc_Stt_Exm_Id   ,          Nvl(Pmt_Amt,0) - Nvl(Pmt_Allocated,0) ,
           P.ROWID              ,          Decode(Pmt_Db_Cr ,'D','C','C','D') ,
           Pmt_Dt               ,          'P', NULL,
           '@@@'
    FROM   Payment_Master P,Entity_Master E
    WHERE  Pmt_Status                 = 'A'
    AND    Pmt_Stage                  = 'O'
    AND    Pmt_Ent_Id                 = Nvl(P_Ent_Id,Pmt_Ent_Id)
    AND    Pmt_Seg_Id                 = 'M'
    AND    Nvl(Pmt_Amt,0) - Nvl(Pmt_Allocated,0) > 0
    AND    Ent_Id = pmt_ent_id
    AND    decode(e.ent_category,'NRI','D',p.pmt_db_cr) = p.pmt_db_cr
    AND    Pmt_Approval_Flg  = 'A'
    AND    Pmt_Dt <= l_Pam_Curr_Dt
    AND    Pmt_Reconcile_Flg = 'Y';

    l_Sql_Stmt := 'Fetching the cursor C_MF_Bills';
    FOR i IN C_MF_Bills
    LOOP
      IF (l_Ent_Id IS NULL AND l_Exm_Id IS NULL) OR (l_Ent_Id <> i.Ent_Id) OR (l_Exm_Id <> i.Exm_Id) THEN
        l_Alloc_Amt                     :=0                          ;
        l_Alloc_Amt_Bills               :=0                          ;
        l_Remain_Dr                     :=0                          ;
        l_Remain_Cr                     :=0                          ;
        l_Count                         :=0                          ;
        l_Check_Amt                     :=0                          ;
        l_Prev_Bld_Remarks              :='-1'                       ;
        l_Alloc_Amt_Bills_MSC           :=0                          ;
        l_Alloc_Amt_Bills_MSD           :=0                          ;
        l_Alloc_Amt_Bills_Cr            :=0                          ;
        l_Ent_Id                        := i.Ent_Id                  ;
        l_Exm_Id                        := i.Exm_Id                  ;
        l_Amt_Tobe_Adjusted             := i.Amt_Tobe_Adjusted       ;
        l_Act_Amt_Tobe_Adjusted         := i.Amt_Tobe_Adjusted       ;
        l_Dr_Adj_Amt                    := l_Amt_Tobe_Adjusted       ;
        l_Cr_Adj_Amt                    := l_Amt_Tobe_Adjusted       ;
        l_Actual_Dr                     := l_Dr_Adj_Amt              ;
        l_Actual_Cr                     := l_Cr_Adj_Amt              ;
        l_Alloc_Amt_Bills_Dr            := 0                         ;

      END IF;

      IF INSTR(i.Bld_Remarks,'JV') = 0 THEN
        l_Check_Amt := F_Bill_Amt(i.Ent_Id,
                                  i.due_date,
                                  to_number(i.Bld_Remarks));
      ELSE
        l_Check_Amt               := -1;
      END IF;



      IF l_Check_Amt > l_Amt_Tobe_Adjusted THEN
        GOTO GOTO_ONE;
      END IF;

      IF (l_Act_Amt_Tobe_Adjusted - l_Alloc_Amt_Bills)=0 AND i.Table_Name ='B' AND i.Dr_Cr_Flag = 'D' THEN--i.Dr_Cr_Flag = l_Prev_Dbcr THEN
        GOTO GOTO_ONE;
      END IF;

      IF NVL(i.Bld_Remarks,'-100') <> l_Prev_Bld_Remarks THEN
        l_Prev_Bld_Remarks := NVL(i.Bld_Remarks,'-100');
        IF l_Check_Amt < i.Amt_Tobe_Adjusted THEN
          l_Amt_Tobe_Adjusted := l_Amt_Tobe_Adjusted - i.Bill_Amt;
        END IF;
      END IF;

      IF l_Amt_Tobe_Adjusted < 0 THEN
        l_Amt_Tobe_Adjusted := 0;
      END IF;

      IF i.Table_Name = 'P' AND l_Count =0 THEN
        l_Cr_Adj_Amt := Least(l_Cr_Adj_Amt , (l_Act_Amt_Tobe_Adjusted - l_Alloc_Amt_Bills_Cr - l_Alloc_Amt_Bills_MSC));
        --l_Cr_Adj_Amt := Least((l_Cr_Adj_Amt - l_Alloc_Amt_Bills_Cr),(l_Alloc_Amt_Bills-l_Alloc_Amt_Bills_MSC));
        l_Count :=1;
      END IF;

      l_Sql_Stmt := 'Checking for the dr cr flag for entity '|| i.Ent_Id;
      IF i.Dr_Cr_Flag = 'D' THEN
         l_Alloc_Amt  := Least(i.Bill_Amt,l_Dr_Adj_Amt);
         l_Dr_Adj_Amt := Nvl(l_Dr_Adj_Amt,0) - l_Alloc_Amt ;
         l_Remain_Dr := l_Remain_Dr + l_Alloc_Amt;
         IF l_Dr_Adj_Amt = 0 AND (l_Actual_Dr >= l_Remain_Dr) AND (i.bld_tcm_cd NOT IN ('MSC','MSD')) THEN
           l_Dr_Adj_Amt := l_Alloc_Amt ;
         END IF;
      ELSE
         l_Alloc_Amt := Least(i.Bill_Amt,l_Cr_Adj_Amt,l_Alloc_Amt_Bills_Dr);
         l_Alloc_Amt_Bills_Dr := l_Alloc_Amt_Bills_Dr - l_Alloc_Amt;
         l_Cr_Adj_Amt := Nvl(l_Cr_Adj_Amt,0) - l_Alloc_Amt ;
         l_Remain_Cr := l_Remain_Cr + l_Alloc_Amt;
         IF l_Cr_Adj_Amt = 0 AND (l_Actual_Cr >= l_Remain_Cr) AND (i.bld_tcm_cd NOT IN ('MSC','MSD')) THEN
           l_Cr_Adj_Amt := l_Alloc_Amt ;
         END IF;
      END IF;

      l_Sql_Stmt := 'Checking allocate amount for table '|| i.Table_Name||i.Table_Rowid;
      IF l_Alloc_Amt > 0 THEN
        IF i.Table_Name = 'B' THEN
          IF i.Bld_Tcm_Cd = 'MSD' THEN
            UPDATE Bill_Details B
            SET    Bld_Amt_Recd      = Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt,
                   Bld_Stage         = Decode(Bld_Due_Amt ,(Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt),'C',Bld_Stage),
                   Bld_Last_Updt_By  = USER,
                   Bld_Last_Updt_Dt  = SYSDATE,
                   Bld_Prg_Id        = l_Prg_Id
            WHERE  ROWID             = i.Table_Rowid;
            IF SQL%ROWCOUNT = 1 THEN
              l_Alloc_Amt_Bills := l_Alloc_Amt_Bills + l_Alloc_Amt;
              l_Alloc_Amt_Bills_Dr := l_Alloc_Amt_Bills_Dr + l_Alloc_Amt;
            END IF;
          ELSIF i.Bld_Tcm_Cd = 'MSC' THEN
            IF (l_Alloc_Amt_Bills - l_Alloc_Amt_Bills_MSC) > 0 THEN
              UPDATE Bill_Details B
              SET    Bld_Amt_Recd      = Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt,
                     Bld_Stage         = Decode(Bld_Due_Amt ,(Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt),'C',Bld_Stage),
                     Bld_Last_Updt_By  = USER,
                     Bld_Last_Updt_Dt  = SYSDATE,
                     Bld_Prg_Id        = l_Prg_Id
              WHERE  ROWID             = i.Table_Rowid;
              IF SQL%ROWCOUNT = 1 THEN
                l_Alloc_Amt_Bills_MSC := l_Alloc_Amt_Bills_MSC + l_Alloc_Amt;
              END IF;
            END IF;
          ELSE
            IF i.Dr_Cr_Flag = 'D' THEN
              UPDATE Bill_Details B
              SET    Bld_Amt_Recd      = Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt,
                     Bld_Stage         = Decode(Bld_Due_Amt ,(Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt),'C',Bld_Stage),
                     Bld_Last_Updt_By  = USER,
                     Bld_Last_Updt_Dt  = SYSDATE,
                     Bld_Prg_Id        = l_Prg_Id
              WHERE  ROWID             = i.Table_Rowid
              AND    Decode(Sign(l_Alloc_Amt - bld_Due_Amt),1,1,0,1,-1) = 1;
              IF SQL%ROWCOUNT = 1 THEN
                l_Alloc_Amt_Bills := l_Alloc_Amt_Bills + l_Alloc_Amt;
                l_Alloc_Amt_Bills_Dr := l_Alloc_Amt_Bills_Dr + l_Alloc_Amt;
              END IF;
            ELSE
              UPDATE Bill_Details B
              SET    Bld_Amt_Recd      = Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt,
                     Bld_Stage         = Decode(Bld_Due_Amt ,(Nvl(Bld_Amt_Recd,0) + l_Alloc_Amt),'C',Bld_Stage),
                     Bld_Last_Updt_By  = USER,
                     Bld_Last_Updt_Dt  = SYSDATE,
                     Bld_Prg_Id        = l_Prg_Id
              WHERE  ROWID             = i.Table_Rowid
              AND    Decode(Sign(bld_Due_Amt - l_Alloc_Amt),1,1,0,1,-1) = 1;
              IF SQL%ROWCOUNT = 1 THEN
                l_Alloc_Amt_Bills := l_Alloc_Amt_Bills + l_Alloc_Amt;
                l_Alloc_Amt_Bills_Cr := l_Alloc_Amt_Bills_Cr + l_Alloc_Amt;
              END IF;
            END IF;
          END IF;
        ELSE
          UPDATE Payment_Master P
          SET    Pmt_Allocated    = Nvl(Pmt_Allocated,0) +  l_Alloc_Amt ,
                 Pmt_Stage        = Decode(Pmt_Amt , (Nvl(Pmt_Allocated,0) +  l_Alloc_Amt),'C',Pmt_Stage),
                 Pmt_Last_Updt_By = USER ,
                 Pmt_Last_Updt_Dt = SYSDATE ,
                 Pmt_Prg_Id       = l_Prg_Id
          WHERE  ROWID            = i.Table_Rowid;
        END IF;
      END IF;

      <<GOTO_ONE>>
      NULL;
      l_Prev_Dbcr := i.dr_cr_flag;

    END LOOP;

    l_Sql_Stmt := 'Updating the stage of Bills';
    UPDATE Bill_Details
    SET Bld_Stage         = 'C',
        Bld_Last_Updt_By  = USER,
        Bld_Last_Updt_Dt  = SYSDATE,
        Bld_Prg_Id        = l_Prg_Id
     WHERE  bld_pam_dt <= l_Pam_Curr_Dt
     AND    Bld_Ent_Id = Nvl(P_Ent_Id,Bld_Ent_Id)
     AND bld_stage = 'O'
     AND bld_seg_id = 'M'
     AND bld_due_amt = bld_amt_recd;

     l_Sql_Stmt := 'Fetching the cursor C_Adj_Bills';
     FOR i IN C_Adj_Bills
     LOOP
       IF i.Due_Amt = 0 THEN
         l_Sql_Stmt := 'Updating the Mfss_Funds_Payin_Success_Yn for order_No '|| i.Order_No;
         UPDATE Mfss_Trades a
         SET a.Mfss_Funds_Payin_Success_Yn = 'Y',
             a.Last_Updt_Dt = SYSDATE,
             a.Last_Updt_By = l_Prg_Id
         WHERE a.Order_No = to_number(i.Order_No)
         AND   a.Exm_Id   = i.Bld_Stc_Stt_Exm_Id
         AND   a.Ent_Id   = i.Bld_Ent_Id
         AND a.Order_Status = 'VALID';
       END IF;
     END LOOP;

    l_Sql_Stmt := 'Updating Program Status ';

    Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                            l_Pam_Curr_Dt ,
                            l_Process_Id  ,
                            'C'           ,
                            'Y'           ,
                            o_Sqlerrm)    ;

    o_Ret_Val := 'SUCCESS';
    l_Sql_Stmt:= 'Process Completed Successfully ';

    UTL_FILE.PUT_LINE(l_Log_File_Ptr,' MF Ledger Netting Process Completed Successfully at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    UTL_FILE.FCLOSE(l_Log_File_Ptr);
    o_Message := l_Sql_Stmt;

   COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    o_Ret_Val := 'FAIL';
    o_Message := 'Error while '||l_Sql_Stmt ||' '||SQLCODE||' '||Substr(SQLERRM,1,200);
    Utl_File.New_Line(l_Log_File_Ptr,2);
    Utl_File.Put_Line(l_Log_File_Ptr,o_Message);
    Utl_File.Put_Line(l_Log_File_Ptr,'Process Failed ');

    Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                            l_Pam_Curr_Dt ,
                            l_Process_Id  ,
                            'E'           ,
                            'Y'           ,
                            o_Sqlerrm)    ;

    UTL_FILE.FCLOSE(l_Log_File_Ptr);
  END P_Mutual_Fund_Netting;*/


END Pkg_Mfss_Settlement_Funds;
/
