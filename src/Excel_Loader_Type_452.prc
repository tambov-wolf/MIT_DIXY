create or replace procedure Excel_Loader_Type_452
/** процедура для заливки связки Клиент - Сайт доставки 
  * процедура написана в рамках УРИС 14522/1
  * @author   DAYakimov 
  * @version 1 (17.02.2020)
  * @param IN_CLILIBL  -- наим. клиента
  * @param IN_CFINFILC  -- а/ц поставщика
  * @param IN_FCCNUM    -- код КК
  * @param IN_CLSL    -- сайт доставки
  * @param IN_CLSS    -- сайт хранения
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
 IN_CNUF     in CS.FOUDGENE.FOUCNUF%TYPE, -- код поставщика
 IN_CFINFILC in CS.FOUFILIE.FFINFILF%TYPE, -- а/ц поставщика
 IN_FCCNUM   in CS.FOUCCOM.FCCNUM%TYPE, -- код КК
 IN_CLSL     in CS.CLISITEL.CLSENTL%TYPE, -- сайт доставки
 IN_CLSS     in CS.CLISITEL.CLSENTS%TYPE, -- сайт хранения
 IN_PRIOR    in NUMBER, -- приоритет
 IN_CLSC     in CS.CLISITEL.CLSMFAC%TYPE, -- режим подсчета цен
 IN_ACTION   in NUMBER, -- код действия
 IN_DDEB     in DATE, -- дата начала действия связки
 IN_DFIN     in DATE, -- дата конца действия связки
 IN_USER     in VARCHAR2,
 OUT_ERR     in out NUMBER, -- код ошибки
 OUT_MSG     in out VARCHAR2 -- наим. ошибки
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
    dbms_output.put_line('Тип действия 1:');
    -- проверяем пересечение дат
    -- сначала строки из системы, которые надо как-то изменить
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
                             0          ACTION -- записи, которые требуют изменения начальной даты (1)
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
                             1          ACTION -- записи, которые требуют изменения конечной даты (3)
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
                             2          ACTION -- записи, которые требуют изменения конечной даты и начальной даты (2)
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
                             3          ACTION -- записи, которые требуют удаления (2)
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
            -- 3 граничный случай, так как эта запись точно попадет под удаление
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
          
            dbms_output.put_line('0 действие:');
            dbms_output.put_line(P_ERR);
          
          elsif P_FOUND_A then
            -- если же эта запись с одинаковым приоритетом, то мы ее удлиняем и выстявляем флаг, что больше такого рода записи растягивать не надо
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
            dbms_output.put_line('0 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DFIN := X.DFIN;
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_A := false;
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 0 действие (1)';
            return;
          end if;
        
        when 1 then
          if X.PRIO <> IN_PRIOR then
            -- 2 граничный случай, так как эта запись точно попадет под удаление
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
          
            dbms_output.put_line('1 действие:');
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
            dbms_output.put_line('1 действие and X.PRIO = IN_PRIOR:');
            dbms_output.put_line(P_ERR);
            MAX_DDEB := X.DDEB;
            -- выставляем значение флага в положение false, т.к. растягивать более не требуется такие записи
            P_FOUND_B := false;
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 1 действие (1)';
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
          
            dbms_output.put_line('2 действие:');
            dbms_output.put_line(P_ERR);
          
          end if;
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 2 действие (1)';
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
        
          dbms_output.put_line('3 действие:');
          dbms_output.put_line(P_ERR);
        
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 3 действие (1)';
            return;
          end if;
      end case;
      commit;
    end loop;
  
    -- теперь вставляем нашу запись
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
    
      dbms_output.put_line('добавление записи:');
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
                             0          ACTION -- записи, которые требуют закрытия определенной датой
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
                             1          ACTION -- записи, которые требуют удаления
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
        
          dbms_output.put_line('0 действие:');
          dbms_output.put_line(P_ERR);
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 0 действие (2)';
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
        
          dbms_output.put_line('1 действие:');
          dbms_output.put_line(P_ERR);
          -- записываем возможную ошибку
          if P_ERR <> 0 then
            OUT_ERR := P_ERR;
            OUT_MSG := 'Ошибка 452 импорт. 1 действие (2)';
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
    out_msg := 'Ошибка выполнения Excel_Loader_Type_452:' || SQLERRM;
    return;
  
end Excel_Loader_Type_452;
/
