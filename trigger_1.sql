CREATE OR REPLACE FUNCTION goods_on_storage() RETURNS trigger AS $goods_on_storage$
    declare aa int;
            a int;
    BEGIN
        select amount into aa from DocTransferGoodsViaDocDelivery
             where DocTransferGoodsViaDocDelivery.goodsid = new.goodsid and DocTransferGoodsViaDocDelivery.storageid=new.storageid;


        --IF (TG_OP = 'DELETE') THEN
            --UPDATE DocTransferGoodsViaDocDelivery
                --SET amount=amount-old.amount
                --where DocTransferGoodsViaDocDelivery.goodsid = old.goodsid and DocTransferGoodsViaDocDelivery.storageid=old.storageid;

        IF(TG_OP = 'INSERT')
            THEN UPDATE DocTransferGoodsViaDocDelivery
                SET amount=aa+new.amount
                where DocTransferGoodsViaDocDelivery.goodsid = new.goodsid and DocTransferGoodsViaDocDelivery.storageid=new.storageid;
        ELSIF(TG_OP = 'UPDATE')
            THEN UPDATE DocTransferGoodsViaDocDelivery
                SET amount=aa-old.amount+new.amount
                where DocTransferGoodsViaDocDelivery.goodsid = new.goodsid and DocTransferGoodsViaDocDelivery.storageid=new.storageid;

        end if;
        return new;
    END

$goods_on_storage$ LANGUAGE plpgsql;

drop trigger goods_on_storage on DocDeliveryGoodsOnStorage;

CREATE TRIGGER goods_on_storage
after INSERT OR UPDATE ON DocDeliveryGoodsOnStorage
    FOR EACH ROW EXECUTE PROCEDURE goods_on_storage();



INSERT INTO GoodsGrp(GrpId, GrpName) values (1,'vegetables');

INSERT INTO goods(GoodsId, GrpId, Name, Firma, Weight, Dimensions,  Pack ) VALUES
    (1,1,'pomidor','sadovod',10.1,'12,12,12','good');

SELECT * FROM goodsgrp;

SELECT * FROM goods;

INSERT INTO Storage(StorageID, GrpId) values (1,1);

SELECT * FROM storage;

INSERT INTO DocTransferGoodsViaDocDelivery
(
     GoodsId,
     StorageID,
     Amount) values (1,1,100
);

SELECT * FROM DocTransferGoodsViaDocDelivery;
insert into Provider --E1
( ProviderID, ProviderName, Address, License,FIO)
values (1,'ooo tovar', 'Moscow, Kreml',1122,'Pod Po Po');

SELECT * FROM Provider;

INSERT INTO Employee
( --E8
    EmployeeID,
    PassportID ,
    PassportSeries,
    FIO,
    Address,
    Date,
    Category) values
    (1,12,1232,'Ghh HH kk','jdjdjd','2021-04-04','danger');

SELECT * FROM Employee;

insert into DocDelivery
( --E4
    DocDeliveryID,
     EmployeeID ,
     ProviderID,
     Date ,
     FirstDate ,
     DocDeliveryCheck, --completed/uncopleted
     TermsContract) values
     (1,1,1,'2021-04-04','2020-12-22','completed','2021-05-12');


SELECT * FROM DocDelivery;

insert into CommercialEnterprise
( CommercialEnterpriseID ,
    EmployeeID,
    Name,
    Specialization,
    NameAddress,
    FIO) values
    (1,1,'name','veg','Moscow,Kreml','Fam Im Ot');
SELECT * FROM CommercialEnterprise;

insert into  PackingList
( --E5
    PackingListID,
    CommercialEnterpriseID,
    EmployeeID ,
    Date ,
    TermsContract , --сроки
    ProviderID,
    DocDeliveryID) values (1,1,1,'2021-04-04','2021-05-05',1,1);
SELECT * FROM PackingList;
insert into DocDeliveryGoods
( --E10
    GoodsId,
    DocDeliveryID,
    DocDeliveryGoodsAmount,
    DocDeliveryGoodsCost)
    values (1,1,5,200);
SELECT * FROM DocDeliveryGoods;

truncate docdeliverygoodsonstorage;

insert into DocDeliveryGoodsOnStorage( GoodsId, DocDeliveryID, PackingListID, StorageID , Amount)
values (1,1,1,1,20);

UPDATE DocDeliveryGoodsOnStorage
                SET amount=700
                where DocDeliveryGoodsOnStorage.goodsid = '1'and DocDeliveryGoodsOnStorage.storageid='1';

SELECT * FROM  DocDeliveryGoodsOnStorage;
SELECT * FROM DocTransferGoodsViaDocDelivery;
DELETE from docdeliverygoodsonstorage where goodsid = '1' and storageid ='1';
--SELECT * FROM  docdeliverygoodsonstorage;
--SELECT * FROM DocTransferGoodsViaDocDelivery;



