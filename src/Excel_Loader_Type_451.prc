create or replace procedure Excel_Loader_Type_451
/** процедура для заливки связки Клиент - Прайс-Лист 
  * процедура написана в рамках УРИС 14522/1
  * @author   DAYakimov 
  * @version 1 (14.02.2020)
  * @param IN_CLILIBL  -- наим. клиента
  * @param IN_CFINFILC  -- а/ц клиента
  * @param IN_WPLNUM    -- код ПЛ
  * @param IN_WPLLIB    -- наим. ПЛ
  * @param IN_ROBID     -- иерархия
  * @param IN_PRIOR     -- приоритет
  * @param IN_ACTION    -- код действия
  * @param IN_DDEB      -- дата начала действия связки
  * @param IN_DFIN     -- дата конца действия связки
  * @param IN_USER     
  * @param OUT_ERR      -- код ошибки
  * @param OUT_MSG      -- наим. ошибки
  * @return код ошибки
  */
(IN_CLINCLI in CS.CLIDGENE.CLINCLI%TYPE, -- код клиента
 -- IN_CLILIBL  in CS.CLIDGENE.CLILIBL%TYPE, -- наим. клиента
 IN_CFINFILC in CS.CLIFILIE.CFINFILC%TYPE, -- а/ц клиента
 IN_WPLNUM   in CS.WPLINE.WPLNUM%TYPE, -- код ПЛ
 -- IN_WPLLIB   in CS.WPLINE.WPLLIB%TYPE, -- описание ПЛ
 IN_ROBID  in CS.RESOBJ.ROBID%TYPE, -- иерархия
 IN_PRIOR  in NUMBER, -- приоритет
 IN_ACTION in NUMBER, -- код действия
 IN_DDEB   in DATE, -- дата начала действия связки
 IN_DFIN   in DATE, -- дата конца действия связки
 IN_USER   in VARCHAR2,
 OUT_ERR   in out NUMBER, -- код ошибки
 OUT_MSG   in out VARCHAR2 -- наим. ошибки
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
    dbms_output.put_line('Тип действия 1:');
    -- проверяем пересечение дат
    -- сначала строки из системы, которые надо как-то изменить
    FOR X IN (select CLI, FILC, CINWP, ROBJ, DDEB, DFIN, PRIO, ACTION
                from (select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             0           ACTION -- записи, которые требуют изменения начальной даты (1)
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
                             1           ACTION -- записи, которые требуют изменения конечной даты (3)
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
                             2           ACTION -- записи, которые требуют изменения конечной даты и начальной даты (2)
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
                             3           ACTION -- записи, которые требуют удаления (2)
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
            -- 3 граничный случай, так как эта запись точно попадет под удаление
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
          
            dbms_output.put_line('0 действие:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_A then
            -- если же эта запись с одинаковым приоритетом, то мы ее удлиняем и выстявляем флаг, что больше такого рода записи растягивать не надо
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
            dbms_output.put_line('0 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DFIN := X.DFIN;
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_A := false;
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 451 импорт. 0 действие (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 граничный случай, так как эта запись точно попадет под удаление
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
            dbms_output.put_line('1 действие:');
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
            dbms_output.put_line('1 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DDEB := X.DDEB;
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_B := false;
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 451 импорт. 1 действие (1)';
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
          
            dbms_output.put_line('2 действие:');
            dbms_output.put_line(P_ERR);
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 451 импорт. 2 действие (1)';
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
        
          dbms_output.put_line('3 действие:');
          dbms_output.put_line(P_ERR);
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 3 действие (1)';
            return;
          end if;
        
      end case;
      commit;
    end loop;
  
    -- теперь вставляем нашу запись
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
    
      dbms_output.put_line('добавление записи:');
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
        OUT_MSG := 'Ошибка 450 импорт. XXX';
        return;
      end if;
      commit;
    end if;
    commit;
  
  end if;

  -- тип действия 2
  IF (IN_ACTION = 2) THEN
    dbms_output.put_line('Тип действия 2:');
    FOR Y IN (select CLI, FILC, CINWP, ROBJ, DDEB, DFIN, PRIO, ACTION
                from (select l.lwcncli   CLI,
                             l.lwcnfilc  FILC,
                             l.lwccinwpl CINWP,
                             l.lwcsite   ROBJ,
                             l.lwcddeb   DDEB,
                             l.lwcdfin   DFIN,
                             l.lwcprio   PRIO,
                             0           ACTION -- записи, которые требуют закрытия определенной датой
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
                             1           ACTION -- записи, которые требуют удаления
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
        
          dbms_output.put_line('0 действие:');
          dbms_output.put_line(P_ERR);
        
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 451 импорт. 0 действие (2)';
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
        
          dbms_output.put_line('1 действие:');
          dbms_output.put_line(P_ERR);
        
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 451 импорт. 1 действие (2)';
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
    out_msg := 'Ошибка выполнения Excel_Loader_Type_451:' || SQLERRM;
    return;
  
end Excel_Loader_Type_451;
/
