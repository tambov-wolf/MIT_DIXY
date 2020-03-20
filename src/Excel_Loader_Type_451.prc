create or replace procedure Excel_Loader_Type_451
/** ��������� ��� ������� ������ ������ - �����-���� 
  * ��������� �������� � ������ ���� 14522/1
  * @author   DAYakimov 
  * @version 1 (14.02.2020)
  * @param IN_CLILIBL  -- ����. �������
  * @param IN_CFINFILC  -- �/� �������
  * @param IN_WPLNUM    -- ��� ��
  * @param IN_WPLLIB    -- ����. ��
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
 IN_WPLNUM   in CS.WPLINE.WPLNUM%TYPE, -- ��� ��
 -- IN_WPLLIB   in CS.WPLINE.WPLLIB%TYPE, -- �������� ��
 IN_ROBID  in CS.RESOBJ.ROBID%TYPE, -- ��������
 IN_PRIOR  in NUMBER, -- ���������
 IN_ACTION in NUMBER, -- ��� ��������
 IN_DDEB   in DATE, -- ���� ������ �������� ������
 IN_DFIN   in DATE, -- ���� ����� �������� ������
 IN_USER   in VARCHAR2,
 OUT_ERR   in out NUMBER, -- ��� ������
 OUT_MSG   in out VARCHAR2 -- ����. ������
 ) is
  P_WPLCIN  CS.WPLIG.WLGCINWPL%TYPE;
  P_ERR     NUMBER(5) := 0;
  P_FOUND_A BOOLEAN := true;
  P_FOUND_B BOOLEAN := true;
  MAX_DDEB  DATE;
  MAX_DFIN  DATE;
begin
  OUT_ERR := 0;
  OUT_MSG := 'OK';

  dbms_output.put_line('-----451-----');
  P_WPLCIN := pkwpline.Get_Wplcinwpl(1, IN_WPLNUM);

  if (IN_ACTION = 1) then
    dbms_output.put_line('��� �������� 1:');
    -- ��������� ����������� ���
    -- ������� ������ �� �������, ������� ���� ���-�� ��������
    FOR X IN (select CLI, FILC, CINWP, ROBJ, DDEB, DFIN, PRIO, ACTION
                from (select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             0           ACTION -- ������, ������� ������� ��������� ��������� ���� (1)
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = IN_ROBID
                         and IN_DFIN between l.lwcddeb and l.lwcdfin
                         and IN_DDEB <= l.lwcddeb
                         and IN_DFIN <> l.lwcdfin
                      
                      union
                      select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             1           ACTION -- ������, ������� ������� ��������� �������� ���� (3)
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = IN_ROBID
                         and IN_DFIN >= l.lwcdfin
                         and IN_DDEB between l.lwcddeb and l.lwcdfin
                         and IN_DDEB <> l.lwcddeb
                      
                      union
                      select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             2           ACTION -- ������, ������� ������� ��������� �������� ���� � ��������� ���� (2)
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = IN_ROBID
                         and IN_DFIN between l.lwcddeb and l.lwcdfin
                         and IN_DDEB between l.lwcddeb and l.lwcdfin
                         and IN_DDEB <> l.lwcddeb
                         and IN_DFIN <> l.lwcdfin
                      
                      union
                      select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             3           ACTION -- ������, ������� ������� �������� (2)
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = IN_ROBID
                         and IN_DFIN >= l.lwcdfin
                         and IN_DDEB <= l.lwcddeb)) loop
    
      case X.ACTION
        when 0 then
          if X.PRIO <> IN_PRIOR then
            -- 3 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DFIN = IN_DFIN then
              continue;
            end if;
            pklienwplcli.update_LienWplCli(1,
                                           X.CLI,
                                           X.CLI,
                                           X.FILC,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
                                           X.ROBJ,
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
            pklienwplcli.update_LienWplCli(1,
                                           X.CLI,
                                           X.CLI,
                                           X.FILC,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
                                           X.ROBJ,
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
            OUT_MSG := '������ 451 ������. 0 �������� (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 ��������� ������, ��� ��� ��� ������ ����� ������� ��� ��������
            if X.DDEB = IN_DDEB then
              continue;
            end if;
            pklienwplcli.update_LienWplCli(1,
                                           X.CLI,
                                           X.CLI,
                                           X.FILC,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                           X.PRIO,
                                           IN_USER,
                                           P_ERR);
            dbms_output.put_line('1 ��������:');
            dbms_output.put_line(P_ERR);
          elsif P_FOUND_B then
            pklienwplcli.update_LienWplCli(1,
                                           X.CLI,
                                           X.CLI,
                                           X.FILC,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
                                           X.ROBJ,
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
            OUT_MSG := '������ 451 ������. 1 �������� (1)';
            return;
          end if;
        
        when 2 then
          if X.PRIO <> IN_PRIOR then
            pklienwplcli.update_LienWplCli(1,
                                           X.CLI,
                                           X.CLI,
                                           X.FILC,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
                                           X.ROBJ,
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(X.DDEB, 'DD/MM/RR'),
                                           TO_CHAR(IN_DDEB - 1, 'DD/MM/RR'),
                                           X.PRIO,
                                           IN_USER,
                                           P_ERR);
          
            pklienwplcli.insert_LienWplCli(1,
                                           X.CLI,
                                           X.FILC,
                                           X.CINWP,
                                           X.ROBJ,
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
            OUT_MSG := '������ 451 ������. 2 �������� (1)';
            return;
          end if;
        
        when 3 then
          pklienwplcli.delete_LienWplCli(1,
                                         X.CLI,
                                         X.FILC,
                                         X.CINWP,
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
  
    -- ������ ��������� ���� ������
    if P_FOUND_A and P_FOUND_B then
      pklienwplcli.insert_LienWplCli(1,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     P_WPLCIN,
                                     IN_ROBID,
                                     TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                     TO_CHAR(IN_DFIN, 'DD/MM/RR'),
                                     IN_PRIOR,
                                     IN_USER,
                                     P_ERR);
    
      dbms_output.put_line('���������� ������:');
      dbms_output.put_line(P_ERR);
    elsif P_FOUND_A = false and P_FOUND_B = false then
      pklienwplcli.delete_LienWplCli(1,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     P_WPLCIN,
                                     IN_ROBID,
                                     TO_CHAR(IN_DDEB, 'DD/MM/RR'),
                                     P_ERR);
      pklienwplcli.update_LienWplCli(1,
                                     IN_CLINCLI,
                                     IN_CLINCLI,
                                     IN_CFINFILC,
                                     IN_CFINFILC,
                                     P_WPLCIN,
                                     IN_ROBID,
                                     IN_ROBID,
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
    FOR Y IN (select CLI, FILC, CINWP, ROBJ, DDEB, DFIN, PRIO, ACTION
                from (select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             0           ACTION -- ������, ������� ������� �������� ������������ �����
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = (case
                               when IN_ROBID is not null then
                                IN_ROBID
                               else
                                l.lwcsite
                             end)
                         and (IN_DFIN between l.lwcddeb and l.lwcdfin)
                      
                      union
                      select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             1           ACTION -- ������, ������� ������� ��������
                        from lienwplcli l
                       where l.lwcncli = IN_CLINCLI
                         and l.lwccinwpl = P_WPLCIN
                         and l.lwcnfilc = IN_CFINFILC
                         and l.lwcsite = (case
                               when IN_ROBID is not null then
                                IN_ROBID
                               else
                                l.lwcsite
                             end)
                         and (IN_DFIN <= l.lwcddeb))) loop
    
      case Y.ACTION
        when 0 then
          pklienwplcli.update_LienWplCli(1,
                                         Y.CLI,
                                         Y.CLI,
                                         Y.FILC,
                                         Y.FILC,
                                         Y.CINWP,
                                         Y.ROBJ,
                                         Y.ROBJ,
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
            OUT_MSG := '������ 451 ������. 0 �������� (2)';
            return;
          end if;
        
        when 1 then
          pklienwplcli.delete_LienWplCli(1,
                                         Y.CLI,
                                         Y.FILC,
                                         Y.CINWP,
                                         Y.ROBJ,
                                         TO_CHAR(Y.DDEB, 'DD/MM/RR'),
                                         P_ERR);
        
          dbms_output.put_line('1 ��������:');
          dbms_output.put_line(P_ERR);
        
          -- ���������� ��������� ������
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := '������ 451 ������. 1 �������� (2)';
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
    out_msg := '������ ���������� Excel_Loader_Type_451:' || SQLERRM;
    return;
  
end Excel_Loader_Type_451;
/
