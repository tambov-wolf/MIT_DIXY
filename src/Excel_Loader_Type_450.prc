create or replace procedure Excel_Loader_Type_450
/** ��������� ��� ������� ������ ������ - �������� 
  * ��������� �������� � ������ ���� 14522/1
  * @author   DAYakimov 
  * @version 1 (17.02.2020)
  * @param IN_CLILIBL  -- ����. �������
  * @param IN_CFINFILC  -- �/� �������
  * @param IN_CCLNUM    -- ��� ��
  * @param IN_CCLVERS   -- ������ ��
  * @param IN_CCLLIB    -- ����. ��
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
 IN_CFINFILC in CS.CLIFILIE.CFINFILC%TYPE, -- �/� �������
 IN_CCLNUM   in CS.CLIENCTR.CCLNUM%TYPE, -- ��� ��
 IN_CCLVERS  in CS.CLIENCTR.CCLVERS%TYPE, -- ������ ��
 -- IN_CCLLIB   in CS.CLIENCTR.CCLLIB%TYPE, -- ����. ��
 IN_ROBID  in CS.RESOBJ.ROBID%TYPE, -- ��������
 IN_PRIOR  in NUMBER, -- ���������
 IN_ACTION in NUMBER, -- ��� ��������
 IN_DDEB   in DATE, -- ���� ������ �������� ������
 IN_DFIN   in DATE, -- ���� ����� �������� ������
 IN_USER   in VARCHAR2,
 OUT_ERR   in out NUMBER, -- ��� ������
 OUT_MSG   in out VARCHAR2 -- ����. ������
 ) is
  --  P_CNT     NUMBER(5) := 0;
  P_CCLNINT CS.CLIENCTR.CCLNINT%TYPE;
  P_ERR     NUMBER(3);
  -- P_MSG     VARCHAR2(120 char);
  P_FOUND_A BOOLEAN := true;
  P_FOUND_B BOOLEAN := true;
  --  P_DDEB    DATE;
  --  P_DFIN    DATE;
  MAX_DDEB DATE;
  MAX_DFIN DATE;
begin
  OUT_ERR := 0;
  OUT_MSG := 'OK';

  P_CCLNINT := pkclienctr.Get_Cclnint(1, IN_CCLNUM, IN_CCLVERS);
  dbms_output.put_line('-----450-----');

  IF (IN_ACTION = 1) THEN
    dbms_output.put_line('��� �������� 1:');
    -- ��������� ����������� ���
    -- ������� ������ �� �������, ������� ���� ���-�� ��������
    FOR X IN (select ID,
                     CLI,
                     CCN,
                     FILC,
                     ROBJ,
                     DDEB,
                     DFIN,
                     DINV,
                     PRIO,
                     ACTION
                from (select rowid || '' ID,
                             l.lccncli CLI,
                             l.lccnint CCN,
                             l.lccnfilc FILC,
                             l.lccsite ROBJ,
                             l.lccddeb DDEB,
                             l.lccdfin DFIN,
                             l.lccdinv DINV,
                             l.lccprior PRIO,
                             0 ACTION -- ������, ������� ������� ��������� ��������� ���� (1)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DDEB <= l.lccddeb
                         and IN_DFIN between l.lccddeb and l.lccdfin -- ����� ������ ��������� ������
                            /* and IN_DFIN >= l.lccddeb
                            and IN_DFIN <= l.lccdfin */
                         and IN_DFIN <> l.lccdfin
                      
                      union
                      select rowid || '' ID,
                             l.lccncli CLI,
                             l.lccnint CCN,
                             l.lccnfilc FILC,
                             l.lccsite ROBJ,
                             l.lccddeb DDEB,
                             l.lccdfin DFIN,
                             l.lccdinv DINV,
                             l.lccprior PRIO,
                             1 ACTION -- ������, ������� ������� ��������� �������� ���� (3)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DFIN >= l.lccdfin
                            /* and IN_DDEB >= l.lccddeb
                            and IN_DDEB <= l.lccdfin */
                         and IN_DDEB between l.lccddeb and l.lccdfin -- ����� ������ ��������� ������
                         and IN_DDEB <> l.lccddeb
                      
                      union
                      select rowid || '' ID,
                             l.lccncli CLI,
                             l.lccnint CCN,
                             l.lccnfilc FILC,
                             l.lccsite ROBJ,
                             l.lccddeb DDEB,
                             l.lccdfin DFIN,
                             l.lccdinv DINV,
                             l.lccprior PRIO,
                             2 ACTION -- ������, ������� ������� ��������� �������� ���� � ��������� ���� (2)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                            /*and IN_DFIN > l.lccddeb
                            and IN_DFIN < l.lccdfin
                            and IN_DDEB > l.lccddeb
                            and IN_DDEB < l.lccdfin */
                         and IN_DFIN between l.lccddeb and l.lccdfin
                         and IN_DDEB between l.lccddeb and l.lccdfin
                         and IN_DFIN <> l.lccdfin
                         and IN_DDEB <> l.lccddeb
                      
                      union
                      select rowid || '' ID,
                             l.lccncli CLI,
                             l.lccnint CCN,
                             l.lccnfilc FILC,
                             l.lccsite ROBJ,
                             l.lccddeb DDEB,
                             l.lccdfin DFIN,
                             l.lccdinv DINV,
                             l.lccprior PRIO,
                             3 ACTION -- ������, ������� ������� �������� (2)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DFIN >= l.lccdfin
                         and IN_DDEB <= l.lccddeb)) -- ����� 1 ��������� ������ (������ ���������� ���)
     loop
      case X.ACTION
        when 0 then
          if X.PRIO <> IN_PRIOR then
            -- 3 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DFIN = IN_DFIN then
              continue;
            end if;
            pklienconcli.update_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DFIN + 1, 'DD/MM/RR'),
                                           TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
                                           IN_USER,
                                           P_ERR);
            dbms_output.put_line('0 �������� and X.PRIO <> IN_PRIOR:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_A then
            -- ���� �� ��� ������ � ���������� �����������, �� �� �� �������� � ���������� ����, ��� ������ ������ ���� ������ ����������� �� ����
            pklienconcli.update_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
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
            OUT_MSG := '������ 450 ������. 0 �������� (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DDEB = IN_DDEB then
              continue;
            end if;
            pklienconcli.update_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
                                           IN_USER,
                                           P_ERR);
            dbms_output.put_line('1 �������� and X.PRIO <> IN_PRIOR:');
            dbms_output.put_line(P_ERR);
          elsif P_FOUND_B then
            pklienconcli.update_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
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
            OUT_MSG := '������ 450 ������. 1 �������� (1)';
            return;
          end if;
        
        when 2 then
          if X.PRIO <> IN_PRIOR then
            pklienconcli.update_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
                                           IN_USER,
                                           P_ERR);
            pklienconcli.insert_lienconcli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CCN,
                                           X.ROBJ,
                                           TO_CHAR(IN_DFIN + 1, 'DD/MM/RR'),
                                           TO_CHAR(X.DFIN, 'DD/MM/RR'),
                                           X.PRIO,
                                           X.DINV,
                                           IN_USER,
                                           P_ERR);
            dbms_output.put_line('2 ��������:');
            dbms_output.put_line(P_ERR);
          
          end if;
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 450 ������. 2 �������� (1)';
            return;
          end if;
        
        when 3 then
          pklienconcli.delete_lienconcli(1,
                                         X.CLI,
                                         X.FILC,
                                         X.CCN,
                                         X.ROBJ,
                                         TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                         P_ERR);
          dbms_output.put_line('3 ��������:');
          dbms_output.put_line(P_ERR);
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 450 ������. 3 �������� (1)';
            return;
          end if;
        
      end case;
      commit;
    end loop;
  
    -- ������ ��������� ���� ������, ���� ����� �� ������� ������ �� �����������
    if P_FOUND_A and P_FOUND_B then
      pklienconcli.insert_lienconcli(1,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     P_CCLNINT,
                                     IN_ROBID,
                                     TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                     TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                     IN_PRIOR,
                                     null,
                                     IN_USER,
                                     P_ERR);
      dbms_output.put_line('���������� ������:');
      dbms_output.put_line(P_ERR);
      commit;
    elsif P_FOUND_A=false and P_FOUND_B=false then
      pklienconcli.delete_lienconcli(1,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     P_CCLNINT,
                                     IN_ROBID,
                                     TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                     P_ERR);
      pklienconcli.update_lienconcli(1,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     P_CCLNINT,
                                     IN_ROBID,
                                     TO_CHAR(MAX_DDEB, 'DD/MM/RR'),
                                     TO_CHAR(MAX_DDEB, 'DD/MM/RR'),
                                     TO_CHAR(MAX_DFIN, 'DD/MM/RR'),
                                     IN_PRIOR,
                                     null,
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
  
  END IF;

  -- ��� �������� 2
  IF (IN_ACTION = 2) THEN
    dbms_output.put_line('��� �������� 2:');
    FOR Y IN (select CLI, CCN, FILC, ROBJ, DDEB, DFIN, DINV, PRIO, ACTION
                from (select l.lccncli  CLI,
                             l.lccnint  CCN,
                             l.lccnfilc FILC,
                             l.lccsite  ROBJ,
                             l.lccddeb  DDEB,
                             l.lccdfin  DFIN,
                             l.lccdinv  DINV,
                             l.lccprior PRIO,
                             0          ACTION -- ������, ������� ������� �������� ������������ �����
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = (case
                               when IN_ROBID is not null then
                                IN_ROBID
                               else
                                l.lccsite
                             end)
                         and (IN_DFIN between l.lccddeb and l.lccdfin)
                      
                      union
                      select l.lccncli  CLI,
                             l.lccnint  CCN,
                             l.lccnfilc FILC,
                             l.lccsite  ROBJ,
                             l.lccddeb  DDEB,
                             l.lccdfin  DFIN,
                             l.lccdinv  DINV,
                             l.lccprior PRIO,
                             1          ACTION -- ������, ������� ������� ��������
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = (case
                               when IN_ROBID is not null then
                                IN_ROBID
                               else
                                l.lccsite
                             end)
                         and (IN_DFIN <= l.lccddeb))) loop
    
      case Y.ACTION
        when 0 then
          pklienconcli.update_lienconcli(1,
                                         Y.CLI,
                                         Y.FILC,
                                         Y.CCN,
                                         Y.ROBJ,
                                         TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                         TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                         TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                         Y.PRIO,
                                         Y.DINV,
                                         IN_USER,
                                         P_ERR);
          dbms_output.put_line('0 ��������:');
          dbms_output.put_line(P_ERR);
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 450 ������. 0 �������� (2)';
            return;
          end if;
        
        when 1 then
          pklienconcli.delete_lienconcli(1,
                                         Y.CLI,
                                         Y.FILC,
                                         Y.CCN,
                                         Y.ROBJ,
                                         TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                         P_ERR);
          dbms_output.put_line('1 ��������:');
          dbms_output.put_line(P_ERR);
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 450 ������. 1 �������� (2)';
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
    out_msg := '������ ���������� Excel_Loader_Type_450:' || SQLERRM;
    return;
  
end Excel_Loader_Type_450;
/
