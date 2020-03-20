create or replace procedure Excel_Loader_Type_452
/** ��������� ��� ������� ������ ������ - ���� �������� 
  * ��������� �������� � ������ ���� 14522/1
  * @author   DAYakimov 
  * @version 1 (17.02.2020)
  * @param IN_CLILIBL  -- ����. �������
  * @param IN_CFINFILC  -- �/� ����������
  * @param IN_FCCNUM    -- ��� ��
  * @param IN_CLSL    -- ���� ��������
  * @param IN_CLSS    -- ���� ��������
  * @param IN_ROBID     -- ��������
  * @param IN_PRIOR     -- ���������
  * @param IN_ACTION    -- ��� ��������
  * @param IN_DDEB      -- ���� ������ �������� ������
  * @param IN_DFIN     -- ���� ����� �������� ������
  * @param IN_USER     
  * @param OUT_ERR      -- ��� ������
  * @param OUT_MSG      -- ����. ������
  * @return ��� ������
  */
(IN_CLINCLI in CS.CLIDGENE.CLINCLI%TYPE, -- ��� �������
 -- IN_CLILIBL  in CS.CLIDGENE.CLILIBL%TYPE, -- ����. �������
 IN_CNUF     in CS.FOUDGENE.FOUCNUF%TYPE, -- ��� ����������
 IN_CFINFILC in CS.FOUFILIE.FFINFILF%TYPE, -- �/� ����������
 IN_FCCNUM   in CS.FOUCCOM.FCCNUM%TYPE, -- ��� ��
 IN_CLSL     in CS.CLISITEL.CLSENTL%TYPE, -- ���� ��������
 IN_CLSS     in CS.CLISITEL.CLSENTS%TYPE, -- ���� ��������
 IN_PRIOR    in NUMBER, -- ���������
 IN_CLSC     in CS.CLISITEL.CLSMFAC%TYPE, -- ����� �������� ���
 IN_ACTION   in NUMBER, -- ��� ��������
 IN_DDEB     in DATE, -- ���� ������ �������� ������
 IN_DFIN     in DATE, -- ���� ����� �������� ������
 IN_USER     in VARCHAR2,
 OUT_ERR     in out NUMBER, -- ��� ������
 OUT_MSG     in out VARCHAR2 -- ����. ������
 ) is
  P_CFIN    CS.FOUDGENE.FOUCFIN%TYPE;
  P_CCIN    CS.FOUCCOM.FCCCCIN%TYPE;
  P_ERR     NUMBER(5) := 0;
  P_FOUND_A BOOLEAN := true;
  P_FOUND_B BOOLEAN := true;
  MAX_DDEB  DATE;
  MAX_DFIN  DATE;
begin
  OUT_ERR := 0;
  OUT_MSG := 'OK';

  dbms_output.put_line('-----452-----');
  P_CFIN := pkfoudgene.get_CFIN(1, IN_CNUF);
  P_CCIN := pkfouccom.get_CCIN(1, IN_FCCNUM);

  IF (IN_ACTION = 1) THEN
    dbms_output.put_line('��� �������� 1:');
    -- ��������� ����������� ���
    -- ������� ������ �� �������, ������� ���� ���-�� ��������
    FOR X IN (select CLI,
                     CFIN,
                     CCIN,
                     NFILF,
                     CLSL,
                     CLSS,
                     CLSC,
                     DDEB,
                     DFIN,
                     PRIO,
                     ACTION
                from (select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             0          ACTION -- ������, ������� ������� ��������� ��������� ���� (1)
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                            -- and l.clsmfac = IN_CLSC
                         and IN_DFIN between l.clsddeb and l.clsdfin
                         and IN_DDEB <= l.clsddeb
                         and IN_DFIN <> l.clsdfin
                      
                      union
                      select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             1          ACTION -- ������, ������� ������� ��������� �������� ���� (3)
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                         and IN_DFIN >= l.clsdfin
                         and IN_DDEB between l.clsddeb and l.clsdfin
                         and IN_DDEB <> l.clsddeb
                      
                      union
                      select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             2          ACTION -- ������, ������� ������� ��������� �������� ���� � ��������� ���� (2)
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                         and IN_DFIN between l.clsddeb and l.clsdfin
                         and IN_DDEB between l.clsddeb and l.clsdfin
                         and IN_DFIN <> l.clsdfin
                         and IN_DDEB <> l.clsddeb
                      
                      union
                      select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             3          ACTION -- ������, ������� ������� �������� (2)
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                         and IN_DFIN >= l.clsdfin
                         and IN_DDEB <= l.clsddeb)) loop
    
      case X.ACTION
        when 0 then
          if X.PRIO <> IN_PRIOR then
            -- 3 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DFIN = IN_DFIN then
              continue;
            end if;
            pkclisitel.update_date_clisitel(1,
                                            X.CLI,
                                            X.CFIN,
                                            X.NFILF,
                                            X.CCIN,
                                            X.CLSL,
                                            X.CLSS,
                                            X.CLSC,
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(IN_DFIN + 1, 'DD/MM/RR'),
                                            TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                            X.PRIO,
                                            IN_USER,
                                            P_ERR);
          
            dbms_output.put_line('0 ��������:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_A then
            -- ���� �� ��� ������ � ���������� �����������, �� �� �� �������� � ���������� ����, ��� ������ ������ ���� ������ ����������� �� ����
            pkclisitel.update_date_clisitel(1,
                                            X.CLI,
                                            X.CFIN,
                                            X.NFILF,
                                            X.CCIN,
                                            X.CLSL,
                                            X.CLSS,
                                            X.CLSC,
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                            TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                            X.PRIO,
                                            IN_USER,
                                            P_ERR);
            dbms_output.put_line('0 �������� and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DFIN := X.DFIN;
            -- ���������� �������� ����� � ��������� false, �.�. ����������� ����� �� ��������� ����� ������
            P_FOUND_A := false;
          
          end if;
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 0 �������� (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DDEB = IN_DDEB then
              continue;
            end if;
            pkclisitel.update_date_clisitel(1,
                                            X.CLI,
                                            X.CFIN,
                                            X.NFILF,
                                            X.CCIN,
                                            X.CLSL,
                                            X.CLSS,
                                            X.CLSC,
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                            X.PRIO,
                                            IN_USER,
                                            P_ERR);
          
            dbms_output.put_line('1 ��������:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_B then
            pkclisitel.update_date_clisitel(1,
                                            X.CLI,
                                            X.CFIN,
                                            X.NFILF,
                                            X.CCIN,
                                            X.CLSL,
                                            X.CLSS,
                                            X.CLSC,
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                            X.PRIO,
                                            IN_USER,
                                            P_ERR);
            dbms_output.put_line('1 �������� and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DDEB := X.DDEB;
            -- ���������� �������� ����� � ��������� false, �.�. ����������� ����� �� ��������� ����� ������
            P_FOUND_B := false;
          end if;
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 1 �������� (1)';
            return;
          end if;
        
        when 2 then
          if X.PRIO <> IN_PRIOR then
            pkclisitel.update_date_clisitel(1,
                                            X.CLI,
                                            X.CFIN,
                                            X.NFILF,
                                            X.CCIN,
                                            X.CLSL,
                                            X.CLSS,
                                            X.CLSC,
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                            TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                            X.PRIO,
                                            IN_USER,
                                            P_ERR);
            pkclisitel.insert_clisitel(1,
                                       X.CLI,
                                       X.CFIN,
                                       X.CCIN,
                                       X.NFILF,
                                       X.CLSL,
                                       X.CLSS,
                                       X.CLSC,
                                       TO_CHAR(IN_DFIN + 1, 'DD/MM/RR'),
                                       TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                       X.PRIO,
                                       IN_USER,
                                       P_ERR);
          
            dbms_output.put_line('2 ��������:');
            dbms_output.put_line(P_ERR);
          
          end if;
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 2 �������� (1)';
            return;
          end if;
        
        when 3 then
          pkclisitel.delete_clisitel(1,
                                     X.CLI,
                                     X.CFIN,
                                     X.CCIN,
                                     X.NFILF,
                                     X.CLSL,
                                     X.CLSS,
                                     X.CLSC,
                                     TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                     X.PRIO,
                                     P_ERR);
        
          dbms_output.put_line('3 ��������:');
          dbms_output.put_line(P_ERR);
        
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 3 �������� (1)';
            return;
          end if;
      end case;
      commit;
    end loop;
  
    -- ������ ��������� ���� ������
    if P_FOUND_A and P_FOUND_B then
      pkclisitel.insert_clisitel(1,
                                 IN_CLINCLI,
                                 P_CFIN,
                                 P_CCIN,
                                 IN_CFINFILC,
                                 IN_CLSL,
                                 IN_CLSS,
                                 IN_CLSC,
                                 TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                 TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                 IN_PRIOR,
                                 IN_USER,
                                 P_ERR);
    
      dbms_output.put_line('���������� ������:');
      dbms_output.put_line(P_ERR);
    elsif P_FOUND_A = false and P_FOUND_B = false then
      pkclisitel.delete_clisitel(1,
                                 IN_CLINCLI,
                                 P_CFIN,
                                 P_CCIN,
                                 IN_CFINFILC,
                                 IN_CLSL,
                                 IN_CLSS,
                                 IN_CLSC,
                                 TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                 IN_PRIOR,
                                 P_ERR);
      pkclisitel.update_date_clisitel(1,
                                      IN_CLINCLI,
                                      P_CFIN,
                                      IN_CFINFILC,
                                      P_CCIN,
                                      IN_CLSL,
                                      IN_CLSS,
                                      IN_CLSC,
                                      TO_CHAR(MAX_DDEB, 'DD/MM/RR'),
                                      TO_CHAR(MAX_DDEB, 'DD/MM/RR'),
                                      TO_CHAR(MAX_DFIN, 'DD/MM/RR'),
                                      IN_PRIOR,
                                      IN_USER,
                                      P_ERR);
      commit;
      if P_ERR <> 0 then
        OUT_ERR := P_ERR;
        OUT_MSG := '������ 450 ������. XXX';
        return;
      end if;
      commit;
    end if;
    commit;
  
  end if;

  -- ��� �������� 2
  IF (IN_ACTION = 2) THEN
    dbms_output.put_line('��� �������� 2:');
    FOR Y IN (select CLI,
                     CFIN,
                     CCIN,
                     NFILF,
                     CLSL,
                     CLSS,
                     CLSC,
                     DDEB,
                     DFIN,
                     PRIO,
                     ACTION
                from (select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             0          ACTION -- ������, ������� ������� �������� ������������ �����
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                         and (IN_DFIN between l.clsddeb and l.clsdfin)
                      
                      union
                      select l.clsncli  CLI,
                             l.clscfin  CFIN,
                             l.clsccin  CCIN,
                             l.clsnfilf NFILF,
                             l.clsentl  CLSL,
                             l.clsents  CLSS,
                             l.clsmfac  CLSC,
                             l.clsddeb  DDEB,
                             l.clsdfin  DFIN,
                             l.clsprio  PRIO,
                             1          ACTION -- ������, ������� ������� ��������
                        from clisitel l
                       where l.clsncli = IN_CLINCLI
                         and l.clscfin = P_CFIN
                         and l.clsccin = P_CCIN
                         and l.clsnfilf = IN_CFINFILC
                         and l.clsentl = IN_CLSL
                         and l.clsents = IN_CLSS
                         and (IN_DFIN <= l.clsddeb))) loop
    
      case Y.ACTION
        when 0 then
          pkclisitel.update_date_clisitel(1,
                                          Y.CLI,
                                          Y.CFIN,
                                          Y.NFILF,
                                          Y.CCIN,
                                          Y.CLSL,
                                          Y.CLSS,
                                          Y.CLSC,
                                          TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                          TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                          TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                          Y.PRIO,
                                          IN_USER,
                                          P_ERR);
        
          dbms_output.put_line('0 ��������:');
          dbms_output.put_line(P_ERR);
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 0 �������� (2)';
            return;
          end if;
        
        when 1 then
          pkclisitel.delete_clisitel(1,
                                     Y.CLI,
                                     Y.CFIN,
                                     Y.CCIN,
                                     Y.NFILF,
                                     Y.CLSL,
                                     Y.CLSS,
                                     Y.CLSC,
                                     TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                     Y.PRIO,
                                     P_ERR);
        
          dbms_output.put_line('1 ��������:');
          dbms_output.put_line(P_ERR);
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 452 ������. 1 �������� (2)';
            return;
          end if;
      end case;
    end loop;
  end if;
  commit;
  -- exception block
exception
  when others then
    out_err := -99;
    out_msg := '������ ���������� Excel_Loader_Type_452:' || SQLERRM;
    return;
  
end Excel_Loader_Type_452;
/
