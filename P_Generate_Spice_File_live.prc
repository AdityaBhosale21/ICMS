CREATE OR REPLACE Procedure P_Generate_Spice_File(P_Exm_Id                 IN VARCHAR2,
                                                  P_From_Date              IN DATE,
                                                  P_To_Date                IN DATE,
                                                  P_ReGen_Flg              IN VARCHAR2,
                                                  P_Log_File               OUT VARCHAR2,
                                                  O_Status_File            OUT VARCHAR2)
   IS
     l_File_Tag                     VARCHAR2(2)   := '{}' ;
     l_File_Start                   VARCHAR2(100) := 'SPICE_STATUS';
     Fil_Dt_Fmt                     VARCHAR2(8)   := 'YYYYMMDD';
     l_File_Extn                    VARCHAR2(1)   := 'T';
     l_Log_Env                      VARCHAR2(100);
     l_Status_File                  VARCHAR2(100);
     l_Off_Mkt_File                 VARCHAR2(100);
     l_Prg_Id                       VARCHAR2(30)  := 'CSSQSPICE';
     l_Prg_Process_Id               NUMBER ;
     l_Batch_Number                 VARCHAR2(10);
     l_CMBP_Id                      VARCHAR2(30);
     l_Pam_Curr_Date                DATE     ;
     l_File_Handle                  Utl_File.File_Type;
     l_Log_File_Handle              Utl_File.File_Type;
     l_File_Handle_Off              Utl_File.File_Type;
     l_Insert                       NUMBER        := 0;
     l_Msg                          VARCHAR2(32767)  ;
     l_Err_Msg                      VARCHAR2(2000)  ;
     l_hdr_str                      VARCHAR2(2000);
     l_hdr_dtl                      VARCHAR2(4000);
     l_hdr_record_type              VARCHAR2(2)   := '11';
     l_dtl_record_type              VARCHAR2(2)   := '12';
     l_code                         VARCHAR2(8)  := '00100008';
     l_count                        NUMBER        := 0;
     l_Fetched_Data                 NUMBER        ;
     o_Sqlerrm                      VARCHAR2(3000);
     Fail_Process                   EXCEPTION     ;
     l_line_no                      NUMBER := 0;
     l_Mdi_acc_no                   VARCHAR2(8) := '10813540';
     l_IDBI_DP_Id                   VARCHAR2(10);
     l_ICMS_DP_Id                   VARCHAR2(10);
     l_LVB_DP_ID                    VARCHAR2(10);
     l_KVB_DP_ID                    VARCHAR2(10);

     Cursor C_Spice_File
      IS
      SELECT Ent_Id                               Ent_Id,
             Max(Substr(Mdi_Dp_Acc_No, 1, 8))     Mdi_Dp_Acc_No,
             Mdi_Dpm_Id                           Mdi_Dpm_Id,
             Max(Nvl(Dpm_Poa_Id, ''))             Dpm_Poa_Id,
             COUNT( Mdi_Dpm_Id) OVER ( PARTITION BY Mdi_Dpm_Id)  Cnt
        FROM
        (SELECT Em.Ent_Id                           Ent_Id,
                Substr(d.Mdi_Dp_Acc_No, 1, 8)       Mdi_Dp_Acc_No,
                d.Mdi_Dpm_Id                        Mdi_Dpm_Id,
                Nvl(p.Dpm_Poa_Id, '')               Dpm_Poa_Id
           FROM Entity_Master            Em,
                Entity_Privilege_Mapping Ep,
                Member_Dp_Info           d,
                Depo_Participant_Master  p
           WHERE Mdi_Id = Em.Ent_Id
             AND Mdi_Dp_Acc_No IS NOT NULL
             AND NOT Exists (SELECT 1
                              FROM Dp_History_Details dp
                             WHERE Dhd_Ent_Id = d.Mdi_Id
                               AND Dhd_Dpm_id = d.mdi_dpm_id
                               AND Dhd_Acc_no = d.mdi_dp_acc_no
                               AND Dhd_Exm_Id = P_Exm_Id)
             AND Mdi_Dpm_id = Dpm_Id
             AND Mdi_Status <> 'C'
             AND Em.Ent_Status = 'E'
             AND Ep.Epm_Ent_Id = Em.Ent_Id
             AND d.Mdi_Dpm_Dem_id = p.Dpm_Dem_Id
             AND Decode(P_Exm_Id,'NSE',Nvl(Ep.Epm_Seg_Equity, 'N'), Nvl(Ep.Epm_Seg_Equity_Bse, 'N')) = 'Y'
             AND d.Mdi_Dpm_Dem_Id = 'NSDL'
             --AND d.Mdi_Default_flag = 'Y' --1619 , 9jun2022 , ameya
             AND Nvl(Em.Ent_Spice_Gen_Yn, 'N') = 'Y'--test
             AND Nvl(P_ReGen_Flg, 'N') = 'N'
             And (Trunc(Nvl(Ent_Last_Updt_Dt, Nvl(Ent_Br_Reg_Dt, Ent_Creat_Dt))) Between P_From_Date And P_To_Date OR
                  Trunc(Nvl(EPM_LAST_UPDT_DT, EPM_CREAT_DT)) Between P_From_Date And P_To_Date OR
                  Trunc(Nvl(MDI_LAST_UPDT_DT, MDI_CREAT_DT)) Between P_From_Date And P_To_Date OR
                  Trunc(Nvl(DPM_LAST_UPDT_DT, DPM_CREAT_DT)) Between P_From_Date And P_To_Date )

         UNION

         SELECT Em.Ent_Id                         Ent_Id,
               Substr(d.Mdi_Dp_Acc_No, 1, 8)      Mdi_Dp_Acc_No,
               d.Mdi_Dpm_Id                       Mdi_Dpm_Id,
               Nvl(p.Dpm_Poa_Id, '')              Dpm_Poa_Id
          FROM Entity_Master            Em,
               Entity_Privilege_Mapping Ep,
               Member_Dp_Info           d,
               Depo_Participant_Master  p
         WHERE Mdi_Id = Em.Ent_Id
           AND Mdi_Dp_Acc_No IS NOT NULL
              /*AND    NOT Exists ( SELECT 1
                                              FROM   Dp_History_Details   dp
                                              WHERE  Dhd_Ent_Id  = d.Mdi_Id
                                              AND    Dhd_Dpm_id  = d.mdi_dpm_id
                                              AND    Dhd_Acc_no  = d.mdi_dp_acc_no
                                              AND    Dhd_Exm_Id  = P_Exm_Id
                                              )*/
           AND Mdi_Dpm_id = Dpm_Id
           AND Mdi_Status <> 'C'
           AND Em.Ent_Status = 'E'
           AND Ep.Epm_Ent_Id = Em.Ent_Id
           AND d.Mdi_Dpm_Dem_id = p.Dpm_Dem_Id
           AND Decode(P_Exm_Id,'NSE',Nvl(Ep.Epm_Seg_Equity, 'N'),Nvl(Ep.Epm_Seg_Equity_Bse, 'N')) = 'Y'
           AND d.Mdi_Dpm_Dem_Id = 'NSDL'
           --AND d.Mdi_Default_flag = 'Y'   --1619 , 9jun2022 , ameya
           AND Nvl(Em.Ent_Spice_Gen_Yn, 'N') = 'Y'
           AND  Nvl(P_ReGen_Flg, 'N') = 'Y'
           And (Trunc(Nvl(Ent_Last_Updt_Dt, Nvl(Ent_Br_Reg_Dt, Ent_Creat_Dt))) Between P_From_Date And P_To_Date OR
                Trunc(Nvl(EPM_LAST_UPDT_DT, EPM_CREAT_DT)) Between P_From_Date And P_To_Date OR
                Trunc(Nvl(MDI_LAST_UPDT_DT, MDI_CREAT_DT)) Between P_From_Date And P_To_Date OR
                Trunc(Nvl(DPM_LAST_UPDT_DT, DPM_CREAT_DT)) Between P_From_Date And P_To_Date ) )
      GROUP BY Mdi_Dpm_Id , Ent_Id
      ORDER BY Mdi_Dpm_Id ;

     TYPE T_R_Spice is table of C_Spice_File%Rowtype INDEX BY BINARY_INTEGER ;
     T_Spice T_R_Spice ;

   BEGIN

      l_Msg := 'Getting Spice Log file.';
      Std_Lib.P_Housekeeping(l_Prg_Id,
                             P_Exm_Id,
                             P_Exm_Id||','||To_Char(P_From_Date,'DD-MON-YYYY')||','||To_Char(P_To_Date,'DD-MON-YYYY'),
                             'E',
                             l_Log_File_Handle,
                             P_Log_File,
                             l_Prg_Process_Id);

      l_Pam_Curr_Date := Std_Lib.l_Pam_Curr_Date;

      l_Msg := 'Fetching Server File Path';
      Select Rv_High_Value
        Into l_Log_Env
        From Cg_Ref_Codes
       Where Rv_Domain = 'DATA_FILES'
         And Rv_Low_Value = 'CSS_FILES';

      l_Msg := 'Selecting SPICE dp id';
      Select Rv_Low_Value
        Into l_IDBI_DP_Id
        From Cg_Ref_Codes
       Where Rv_Domain = 'COLL_HOLD_TRF_DP'
         And Rv_High_Value = 'IDBI';

      l_Msg := 'Selecting ICMS dp id';
      Select Rv_Low_Value
        Into l_ICMS_DP_Id
        From Cg_Ref_Codes
       Where Rv_Domain = 'COLL_HOLD_TRF_DP'
         And Rv_High_Value = 'ICMS';


      l_Msg := 'Selecting LVB dp id';
      Select Rv_Low_Value
        Into l_LVB_DP_ID
        From Cg_Ref_Codes
       Where Rv_Domain = 'COLL_HOLD_TRF_DP'
         And Rv_High_Value = 'LVB';

      l_Msg := 'Selecting KVB dp id';
      Select Rv_Low_Value
        Into l_KVB_DP_ID
        From Cg_Ref_Codes
       Where Rv_Domain = 'COLL_HOLD_TRF_DP'
         And Rv_High_Value = 'KVB';

      IF Substr(l_Log_Env,-1) <> '/' THEN
        l_Log_Env := l_Log_Env || '/';
      END IF;

      l_Msg := 'Fetching CM BP Id ';
      Select Nvl(Max(Substr(Eam_Cmbp_Id, 1, 8)), '-1') Eam_Cmbp_Id
        Into l_Cmbp_Id
        From Exch_Admin_Master
       Where Eam_Exm_Id = p_Exm_Id
         And Eam_Seg_Id = 'E';

      IF  l_Cmbp_Id = '-1' THEN
          RAISE Fail_Process;
      END IF;

      T_Spice.Delete;
      OPEN C_Spice_File;
      LOOP
        l_count := l_count +1 ;
        T_Spice(0).Mdi_Dpm_Id := 'DUMMY';
        FETCH  C_Spice_File INTO  T_Spice(l_count).Ent_Id,
                                  T_Spice(l_count).Mdi_Dp_Acc_No,
                                  T_Spice(l_count).Mdi_Dpm_Id,
                                  T_Spice(l_count).Dpm_Poa_Id,
                                  T_Spice(l_count).Cnt;

        Exit When  C_Spice_File%Notfound ;
      END LOOP;

      Utl_File.New_Line(l_Log_File_Handle,2);
      Utl_File.Put_Line(l_Log_File_Handle, ' ************************Files Generated*************************************** : ');
      Utl_File.New_Line(l_Log_File_Handle,2);

       FOR I in 1..T_Spice.Count - 1
       LOOP
           Begin

           IF   T_Spice(i).Mdi_Dpm_Id = l_IDBI_DP_Id Then
                l_code := '00100161';
           ELSIF T_Spice(i).Mdi_Dpm_Id = l_LVB_DP_ID THEN
                l_code := '00100016';
           ELSIF T_Spice(i).Mdi_Dpm_Id = l_KVB_DP_ID THEN
                l_code := '';
           ELSE
                l_code := '00100008';
           End If;

          --For Header file
             IF I = 1 OR T_Spice(i).Mdi_Dpm_Id <> T_Spice(i-1).Mdi_Dpm_Id THEN
                    If T_Spice(i).Mdi_Dpm_Id <> T_Spice(i-1).Mdi_Dpm_Id AND I <> 1  THEN
                      l_line_no := 0;
                       Utl_File.Put_Line(l_File_Handle,l_File_Tag);
                       Utl_File.Fflush(l_File_Handle);
                        IF Utl_File.Is_Open(l_File_Handle_Off) THEN
                           Utl_File.Put_Line(l_File_Handle_Off,l_File_Tag);
                           Utl_File.Fflush(l_File_Handle_Off);
                        END IF;
                       IF Utl_File.Is_Open(l_File_Handle) THEN
                          l_Msg := 'Closing Spice File.';
                          Utl_File.Fclose(l_File_Handle);
                       END IF;
                       IF Utl_File.Is_Open(l_File_Handle_Off) THEN
                          l_Msg := 'Closing Spice Off Market File.';
                          Utl_File.Fclose(l_File_Handle_Off);
                       END IF;
                    END IF;
                    l_line_no := 1;
                    SELECT To_Char(Substr(Spice_Batch.NEXTVAL, -7, 7)) -- For Last seven digits only for batch number
                    INTO   l_Batch_Number
                    FROM   Dual;

                    l_Msg := 'Opening SPICE File For Generation ';
                    l_Status_File := l_File_Start || '_' || To_Char(l_Pam_Curr_Date,Fil_Dt_Fmt) || '.' || l_File_Extn || l_Batch_Number;
                    O_Status_File := l_Log_Env || l_Status_File;
                    Utl_File.Put_Line(l_Log_File_Handle,'Spice File for DP              : '  || T_Spice(i).Mdi_Dpm_Id ||  ' : ' ||  '  is ' || ' << '||O_Status_File || ' >>') ;
                   IF   T_Spice(i).Mdi_Dpm_Id = l_ICMS_DP_Id Or T_Spice(i).Mdi_Dpm_Id = l_IDBI_DP_Id THEN
                        l_Off_Mkt_File := 'SPICE_Off_Mkt_' || T_Spice(i).Mdi_Dpm_Id || '_' || To_Char(l_Pam_Curr_Date,Fil_Dt_Fmt) || '.' || l_File_Extn || l_Batch_Number;
                        O_Status_File :=  l_Log_Env || l_Off_Mkt_File;
                        Utl_File.Put_Line(l_Log_File_Handle,'Spice Off marketr file for DP  : '  || T_Spice(i).Mdi_Dpm_Id ||  ' : ' ||  '  is ' || ' << '||O_Status_File || ' >>') ;
                   END IF;
                   BEGIN
                     l_File_Handle := Utl_File.Fopen(l_Log_Env,l_Status_File,'A',4000);
                   EXCEPTION
                     WHEN OTHERS THEN
                        Utl_File.Put_Line(l_Log_File_Handle,'Exception Occured While Opening File For Writing :'||l_Status_File) ;
                        RAISE;
                   END;

                    IF   T_Spice(i).Mdi_Dpm_Id = l_ICMS_DP_Id Or T_Spice(i).Mdi_Dpm_Id = l_IDBI_DP_Id THEN
                        BEGIN
                          l_File_Handle_Off := Utl_File.Fopen(l_Log_Env,l_Off_Mkt_File,'A',4000);
                        EXCEPTION
                         WHEN OTHERS THEN
                            Utl_File.Put_Line(l_Log_File_Handle,'Exception Occured While Opening File For Writing :'||l_Off_Mkt_File) ;
                            RAISE;
                        END;
                    END IF;

                    l_Msg := 'Fetching Header Record ';
                    l_hdr_str  := l_Batch_Number                  ||--Batch number to display in file
                                  l_hdr_record_type               ||---Record Type is 11 for Header
                                  l_Cmbp_Id                       ||---Clearing Member ID
                                  LPAD(T_Spice(I).Cnt,5,'0')      ||---Total Number of records
                                  LPAD(' ',10);                     ----Space
                    Utl_File.Put_Line(l_File_Handle,l_File_Tag);
                    Utl_File.Put_Line(l_File_Handle,l_hdr_str);

                    IF   T_Spice(i).Mdi_Dpm_Id = l_ICMS_DP_Id Or T_Spice(i).Mdi_Dpm_Id = l_IDBI_DP_Id THEN
                          l_Msg := 'Fetching Header Data for Off Market Spice file ';
                           l_hdr_str := l_Batch_Number                           || --Batch, Number,7,M
                                              l_hdr_record_type                  || --Record Type, Number,2,M,Header Record (11)
                                              l_ICMS_DP_Id                       || --DP ID,Character,8,M,DP Id of POA holder
                                              l_Mdi_acc_no                       || --Client Id,Number,8,M,Client Id of POA holder
                                              LPAD(T_Spice(I).Cnt,5,'0')         || --Total number of Records,Number,5,M
                                              LPAD(' ',10);                         --Filler,Character,10,Spaces,O

                          Utl_File.Put_Line(l_File_Handle_Off,l_File_Tag);
                          Utl_File.Put_Line(l_File_Handle_Off,l_hdr_str);
                    END IF;
             End IF;

             l_Msg := 'Fetching Detail Record ';
             l_Hdr_Dtl:=  l_Batch_Number                   ||---Batch number to display in file
                          l_Dtl_Record_Type                        ||---Record Type is 12 for details
                          Lpad(l_line_no,5,'0')                      ||--- Line Number of the record
                          T_Spice(I).Mdi_Dpm_Id                 ||---Member depository id
                          T_Spice(I).Mdi_Dp_Acc_No           ||--- Account Number
                          LPAD(T_Spice(I).Dpm_Poa_Id,8,'0')||---POA id
                          l_code                                            || --IDBI hard code request
                          LPAD(' ',12);

             Utl_File.Put_Line(l_File_Handle,l_Hdr_Dtl);

             IF   T_Spice(i).Mdi_Dpm_Id = l_ICMS_DP_Id Or T_Spice(i).Mdi_Dpm_Id = l_IDBI_DP_Id THEN
                   l_Msg := 'Fetching Detail Record for Spice Off market File ';
                   l_Hdr_Dtl:=  l_Batch_Number                   ||--Batch, Number,7,M
                                        l_Dtl_Record_Type                ||--Record Type,Number,2,M,12 Default
                                        Lpad(l_line_no,5,'0')              ||-- Line Number,Number,5,M
                                        T_Spice(I).Mdi_Dpm_Id         || --DP ID,Character,8,M,DP Id of POA holder
                                        T_Spice(I).Mdi_Dp_Acc_No   ||--Client Id,Number,8,M,Client Id of POA holder
                                        l_code                                    || --SPICE ID,Number,8,O
                                        LPAD(' ',12);                               --Filler,Character,12,Spaces

                   Utl_File.Put_Line(l_File_Handle_Off,l_Hdr_Dtl);
             END IF;
             l_line_no := l_line_no + 1;

             l_Msg := 'Inserting DP details < '||T_Spice(I).Mdi_Dp_Acc_No||' > Into Dp_History_Details Table.';
             BEGIN
               INSERT INTO Dp_History_Details
                 (Dhd_Ent_Id,                  Dhd_Exm_Id,             Dhd_Acc_No,
                  Dhd_Dpm_Id,                Dhd_Poa_Id,             Dhd_Prg_Id,
                  Dhd_Date,                     Dhd_Status_File)
               VALUES
                 (T_Spice(I).Ent_Id,                P_Exm_Id ,                      T_Spice(I).Mdi_Dp_Acc_No,
                  T_Spice(I).Mdi_Dpm_Id,     T_Spice(I).Dpm_Poa_Id,  l_Prg_Id,
                  l_Pam_Curr_Date,               O_Status_File);

                l_Insert := l_Insert + sql%rowcount ;
             EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                 NULL;
             END;

        EXCEPTION
           WHEN OTHERS THEN
             l_Err_Msg := ' Error Occurred While '||l_Msg||' : '||Substr(Sqlerrm,1,100);
             Utl_File.Put_Line(l_Log_File_Handle, l_Err_Msg);
        END;
      END LOOP;

      l_Fetched_Data := C_Spice_File%RowCount ;


      If l_Fetched_Data <> 0 THEN
         Utl_File.Put_Line(l_File_Handle,l_File_Tag);
         Utl_File.Fflush(l_File_Handle);
         IF Utl_File.Is_Open(l_File_Handle_Off) THEN
            Utl_File.Put_Line(l_File_Handle_Off,l_File_Tag);
            Utl_File.Fflush(l_File_Handle_Off);
         END IF;
         IF Utl_File.Is_Open(l_File_Handle) THEN
           l_Msg := 'Closing Spice File.';
           Utl_File.Fclose(l_File_Handle);
         END IF;
         IF Utl_File.Is_Open(l_File_Handle_Off) THEN
           l_Msg := 'Closing Spice File Off Market.';
           Utl_File.Fclose(l_File_Handle_Off);
         END IF;
      ELSE
        Utl_File.Fclose(l_File_Handle);
        IF Utl_File.Is_Open(l_File_Handle_Off) THEN
            Utl_File.Fclose(l_File_Handle_Off);
        END IF;
      END IF;

      CLOSE C_Spice_File;

      Utl_File.New_Line(l_Log_File_Handle,2);
      Utl_File.Put_Line(l_Log_File_Handle, ' --------------------------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' Summary:');
      Utl_File.Put_Line(l_Log_File_Handle, ' --------------------------------------------------------------------------------------------');
      Utl_File.Put_Line(l_Log_File_Handle, ' File Generated                      : '||O_Status_File);
      Utl_File.Put_Line(l_Log_File_Handle, ' Number of Records generated in File : '||l_Insert);
      Utl_File.Put_Line(l_Log_File_Handle, ' --------------------------------------------------------------------------------------------');

      Utl_File.New_Line(l_Log_File_Handle,2);
      Utl_File.Put_Line(l_Log_File_Handle, ' Process Completed On '||TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
      Utl_File.Fflush(l_Log_File_Handle);

      l_Msg := 'Updating Program_Status Table.';
      UPDATE Program_Status
      SET    Prg_Status         = 'C',
             Prg_Status_File    = Nvl(O_Status_File,'No Status File'),
             Prg_Partial_Run_Yn = 'N',
             Prg_End_Time       = SYSDATE,
             Prg_Last_Updt_By   = USER,
             Prg_Last_Updt_Dt   = SYSDATE
      WHERE  Prg_Dt             = l_Pam_Curr_Date
      AND    Prg_Process_Id     = l_Prg_Process_Id
      AND    Prg_Cmp_Id         = l_Prg_Id;

      Commit;

      IF NOT(Utl_File.Is_Open(l_Log_File_Handle)) THEN
          Utl_File.Fclose(l_Log_File_Handle);
      END IF;

   EXCEPTION
     WHEN Fail_Process THEN
       Utl_File.New_Line(l_Log_File_Handle,2);
       Utl_File.Put_Line(l_Log_File_Handle,'ERROR:While Getting CM BP ID '||SQLERRM);
       Utl_File.Put_Line(l_Log_File_Handle,'Process Failed');
       Utl_File.Fclose(l_Log_File_Handle);

       Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                               l_Pam_Curr_Date ,
                               l_Prg_Process_Id  ,
                               'E'           ,
                               'Y'           ,
                               o_Sqlerrm)    ;


     WHEN OTHERS THEN
       ROLLBACK;
       l_Err_Msg := ' Error occurred while '||l_Msg||' : '||Substr(Sqlerrm,1,100);
       Utl_File.Put_Line(l_Log_File_Handle, l_Err_Msg);
       Utl_File.Fflush(l_Log_File_Handle);
       IF NOT(Utl_File.Is_Open(l_Log_File_Handle)) THEN
          Utl_File.Fclose(l_Log_File_Handle);
       END IF;
       Std_Lib.P_Updt_Prg_Stat(l_Prg_Id      ,
                               l_Pam_Curr_Date ,
                               l_Prg_Process_Id  ,
                               'E'           ,
                               'Y'           ,
                               o_Sqlerrm)    ;


END P_Generate_Spice_File;
/
