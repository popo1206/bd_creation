CREATE OR REPLACE FUNCTION goods_from_storage() RETURNS trigger AS $goods_from_storage$
    declare aa int;
    BEGIN
        select amount into aa from DocTransferGoodsViaDocDelivery
             where DocTransferGoodsViaDocDelivery.goodsid = new.goodsid and DocTransferGoodsViaDocDelivery.storageid=new.storageid;


        IF (TG_OP = 'INSERT') THEN
            IF (aa< new.amount) THEN
                    RAISE EXCEPTION 'exceeds the number of goods on the storage';
            end if;
            UPDATE DocTransferGoodsViaDocDelivery
                SET amount=amount-new.amount
                where DocTransferGoodsViaDocDelivery.goodsid = new.goodsid and DocTransferGoodsViaDocDelivery.storageid=new.storageid;

        end if;
        return new;
    END

$goods_from_storage$ LANGUAGE plpgsql;

drop trigger goods_from_storage on DocTransferGoods;

CREATE TRIGGER goods_from_storage
after INSERT ON DocTransferGoods
    FOR EACH ROW EXECUTE PROCEDURE goods_from_storage();

SELECT * FROM DocTransferGoodsViaDocDelivery;

INSERT INTO DocTransfer( DocTransferID,
    EmployeeID,
    CommercialEnterpriseID,
    Date ,
    Time)

values (1,1,1,'2020-12-03','12:00:00');
select * from doctransfer;
delete from doctransfergoods where doctransfergoods.storageid='1';

insert into DocTransferGoods(DocTransferID,
    NumberString,
    Amount,
    Cost ,
    StorageID ,
    GoodsId)
    values (1,1,800,20.34,1,1);

select * from doctransfergoods;

SELECT * FROM DocTransferGoodsViaDocDelivery;
