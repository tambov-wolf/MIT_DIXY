create or replace procedure Excel_Loader_Type_450
/** процедура для заливки связки Клиент - Контракт 
  * процедура написана в рамках УРИС 14522/1
  * @author   DAYakimov 
  * @version 1 (17.02.2020)
  * @param IN_CLILIBL  -- наим. клиента
  * @param IN_CFINFILC  -- а/ц клиента
  * @param IN_CCLNUM    -- код КТ
  * @param IN_CCLVERS   -- версия КТ
  * @param IN_CCLLIB    -- наим. КТ
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
 IN_CCLNUM   in CS.CLIENCTR.CCLNUM%TYPE, -- код КТ
 IN_CCLVERS  in CS.CLIENCTR.CCLVERS%TYPE, -- версия КТ
 -- IN_CCLLIB   in CS.CLIENCTR.CCLLIB%TYPE, -- наим. КТ
 IN_ROBID  in CS.RESOBJ.ROBID%TYPE, -- иерархия
 IN_PRIOR  in NUMBER, -- приоритет
 IN_ACTION in NUMBER, -- код действия
 IN_DDEB   in DATE, -- дата начала действия связки
 IN_DFIN   in DATE, -- дата конца действия связки
 IN_USER   in VARCHAR2,
 OUT_ERR   in out NUMBER, -- код ошибки
 OUT_MSG   in out VARCHAR2 -- наим. ошибки
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
    dbms_output.put_line('Тип действия 1:');
    -- проверяем пересечение дат
    -- сначала строки из системы, которые надо как-то изменить
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
                             0 ACTION -- записи, которые требуют изменения начальной даты (1)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DDEB <= l.lccddeb
                         and IN_DFIN between l.lccddeb and l.lccdfin -- здесь третий граничный случай
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
                             1 ACTION -- записи, которые требуют изменения конечной даты (3)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DFIN >= l.lccdfin
                            /* and IN_DDEB >= l.lccddeb
                            and IN_DDEB <= l.lccdfin */
                         and IN_DDEB between l.lccddeb and l.lccdfin -- здесь второй граничный случай
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
                             2 ACTION -- записи, которые требуют изменения конечной даты и начальной даты (2)
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
                             3 ACTION -- записи, которые требуют удаления (2)
                        from lienconcli l
                       where l.lccncli = IN_CLINCLI
                         and l.lccnint = P_CCLNINT
                         and l.lccnfilc = IN_CFINFILC
                         and l.lccsite = IN_ROBID
                         and IN_DFIN >= l.lccdfin
                         and IN_DDEB <= l.lccddeb)) -- здесь 1 граничный случай (полное совпадение дат)
     loop
      case X.ACTION
        when 0 then
          if X.PRIO <> IN_PRIOR then
            -- 3 граничный случай, так как эта запись точно попадет под удаление
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
            dbms_output.put_line('0 действие and X.PRIO <> IN_PRIOR:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_A then
            -- если же эта запись с одинаковым приоритетом, то мы ее удлиняем и выстявляем флаг, что больше такого рода записи растягивать не надо
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
            dbms_output.put_line('0 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DFIN := X.DFIN;
            
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_A := false;
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 0 действие (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 граничный случай, так как эта запись точно попадет под удаление
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
            dbms_output.put_line('1 действие and X.PRIO <> IN_PRIOR:');
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
            dbms_output.put_line('1 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DDEB := X.DDEB;
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_B := false;
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 1 действие (1)';
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
            dbms_output.put_line('2 действие:');
            dbms_output.put_line(P_ERR);
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 2 действие (1)';
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
  
    -- теперь вставляем нашу запись, если ранее мы никакие записи не растягивали
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
      dbms_output.put_line('добавление записи:');
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
        OUT_MSG := 'Ошибка 450 импорт. XXX';
        return;
      end if;
      commit;
    
    end if;
    commit;
  
  END IF;

  -- тип действия 2
  IF (IN_ACTION = 2) THEN
    dbms_output.put_line('Тип действия 2:');
    FOR Y IN (select CLI, CCN, FILC, ROBJ, DDEB, DFIN, DINV, PRIO, ACTION
                from (select l.lccncli  CLI,
                             l.lccnint  CCN,
                             l.lccnfilc FILC,
                             l.lccsite  ROBJ,
                             l.lccddeb  DDEB,
                             l.lccdfin  DFIN,
                             l.lccdinv  DINV,
                             l.lccprior PRIO,
                             0          ACTION -- записи, которые требуют закрытия определенной датой
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
                             1          ACTION -- записи, которые требуют удаления
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
          dbms_output.put_line('0 действие:');
          dbms_output.put_line(P_ERR);
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 0 действие (2)';
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
          dbms_output.put_line('1 действие:');
          dbms_output.put_line(P_ERR);
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 450 импорт. 1 действие (2)';
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
    out_msg := 'Ошибка выполнения Excel_Loader_Type_450:' || SQLERRM;
    return;
  
end Excel_Loader_Type_450;
/
