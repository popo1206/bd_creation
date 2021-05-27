--ПРОЦЕДУРА 1
--Оформление договора о поставках. Входные параметры:
-- название фирмы поставщика,
-- номер договора о поставка или null,
-- артикул товара и кол-во.
-- Процедура если в качестве номера договора указано null,
-- то тогда формируется новый договор о поставках,
-- если номер указан то тогда проверяем принадлежит ли данный договор данному поставщику
-- и если все в порядке то вставляем соотвествующую строку в таблицу договорной товар.

DROP procedure registration_DocDeliveryGoods(PName varchar, DDID INT, GId INT, DDGoodsAmount INT, EmplID INT, cost numeric);

CREATE OR REPLACE PROCEDURE
    registration_DocDeliveryGoods(IN PName varchar(50),INOUT DDID INT, IN GName varchar(50),IN GFirma varchar(100),
     IN DDGoodsAmount INT, EmplID INT,cost numeric(10,2))
     LANGUAGE 'plpgsql'
     AS $$
    declare
    PrID integer;
    PrID_1 integer;
    GpID integer;
    GID integer;
    DDID_max integer;

        begin
            if not exists (select * from goods where  Name=GName and firma=GFirma) then
                     RAISE EXCEPTION 'Не существует данного товара';
            else
                select goodsid into GID from Goods where Name=GName and firma=GFirma;
                 end if;
                select GrpId  into GpID from goods where  GoodsId=GID;

            if not exists (select * from Provider where PName=ProviderName) then
            RAISE EXCEPTION 'Не существует данного поставщика';
            else
                select ProviderID into PrID from Provider where PName=ProviderName;
            end if;
            if (DDID is null) then
                select max(docdeliveryid) into DDID_max from docdelivery;
                DDID=DDID_max+1;
                 INSERT INTO docdelivery(DocDeliveryID,
                                        EmployeeID,
                                        ProviderID,
                                        Date,
                                        FirstDate,
                                        DocDeliveryCheck,
                                        TermsContract)
                values (DDID,EmplID,PrID,'2021-09-12','2021-09-12','completed','2021-09-12');

            elsif (not exists (select * from DocDelivery where DDID=DocDeliveryID )) then

                INSERT INTO docdelivery(DocDeliveryID,
                                        EmployeeID,
                                        ProviderID,
                                        Date,
                                        FirstDate,
                                        DocDeliveryCheck,
                                        TermsContract)
                values (DDID,EmplID,PrID,'2021-09-12','2021-09-12','completed','2021-09-12');
            else
                select ProviderID into PrID_1 from docdelivery where DDID=DocDeliveryID;
                if (PrID_1!=PrID) then
                    RAISE EXCEPTION 'Не совпадает поставщик';
                end if;



            end if;


                insert into docdeliverygoods (GoodsId ,
                    DocDeliveryID ,
                    DocDeliveryGoodsAmount,
                    DocDeliveryGoodsCost )
                    values (GId, DDID,DDGoodsAmount,cost);

        end


    $$;
do $$
	declare
		res int;
	begin
		call registration_DocDeliveryGoods('ooo tovar',res,'pomidor', 'sadovod',20,1,87.4);
		call registration_DocDeliveryGoods('ooo tovar',res,'укроп', 'sadovod',20,1,87.4);
	end
$$;
call registration_DocDeliveryGoods('ooo tovar',2,'укроп', 'sadovod',100,1,13);

select * from docdelivery;
select * from docdeliverygoods;
select max(docdeliveryid)  from docdelivery;


--Процедура 2
--Входной параметр: номер товарной накладной (Е5)
-- Процедура просматривает все товары, которы поступили для этой товарной накладной
-- и размещает его на соответствующем складе, который указан.
-- В Е13 кол-во товара соответствующим образом увеличится или добавляется новая строка.

create or replace procedure tovar_on_storage(PLID integer)
    LANGUAGE 'plpgsql'
     AS $$
    declare
        cur refcursor;
        rec_cur record;
        amm integer;
        begin
        open cur for
        select * FROM docdeliverygoodsonstorage
        WHERE packinglistid=PLID;

        LOOP
             fetch next from cur into rec_cur;
                exit when rec_cur is null;
         if not exists (select * from  DocTransferGoodsViaDocDelivery where Goodsid=rec_cur.goodsid) then
                     INSERT INTO DocTransferGoodsViaDocDelivery(GoodsId,StorageID,Amount)
                     values (rec_cur.goodsid,rec_cur.storageid,rec_cur.amount);
            else
                select amount into amm from  DocTransferGoodsViaDocDelivery where Goodsid=rec_cur.goodsid;
                UPDATE DocTransferGoodsViaDocDelivery
             SET amount=amm+rec_cur.amount
             where goodsid=rec_cur.goodsid;
        end if;
        end loop;


    end;
    $$;

INSERT INTO DocDeliveryGoodsOnStorage
( --E12
    GoodsId,
    DocDeliveryID,
    PackingListID,
    StorageID,
    Amount)
    values (4,2,3,1,10);

INSERT INTO PackingList
( --E5
    PackingListID,
    CommercialEnterpriseID,
    EmployeeID,
    Date,
    TermsContract, --сроки
    ProviderID,
    DocDeliveryID)
values (3,1,1,'2021-05-13','2022-05-13',1,2);

select * from packinglist;
select * from docdeliverygoodsonstorage;
select * from DocTransferGoodsViaDocDelivery;

call tovar_on_storage(20);
select * from DocTransferGoodsViaDocDelivery;



