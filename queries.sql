--Запрос 1
--Получить информация об ассортименте товаров:
--артикул;
--наименование;
--наличие на скалде; (сейчас)
--кол-во всех договоров о поставка, в которые входит этот товар
--суммарное кол-во договорного товара
--количество товарных накладных, в которых этот товар указан
--суммарное кол-во поступившего товара
--доля выполнения договоров: соотношение кол-ва поступившего товара к договрному товару.
-- Результат упорядочить по убывание последней колонки.
explain analyze
with  tab2 as (
     select goods.goodsid,
            name ,
            doctransfergoodsviadocdelivery.amount as storage_amount,
            sum(docdeliverygoods.docdeliverygoodsamount) as docdeliveryid_count
     from goods left join doctransfergoodsviadocdelivery
    on doctransfergoodsviadocdelivery.goodsid = goods.goodsid
    left join docdeliverygoods
         on goods.goodsid=docdeliverygoods.goodsid
     group by goods.goodsid, name, doctransfergoodsviadocdelivery.amount),
tab3 as (
        select tab2.goodsid,
               tab2.name,
               tab2.storage_amount,
               tab2.docdeliveryid_count,
               sum(docdeliverygoodsonstorage.amount) as packing_list_count
        from tab2 left join docdeliverygoodsonstorage on tab2.goodsid=docdeliverygoodsonstorage.goodsid
        group by tab2.goodsid, tab2.name, tab2.storage_amount, tab2.docdeliveryid_count)
select tab3.goodsid,
       tab3.name,
       tab3.docdeliveryid_count,
       tab3.storage_amount,
       tab3.packing_list_count,
       cast((tab3.packing_list_count/cast(tab3.docdeliveryid_count as numeric(10,3))) as numeric(10,3)) as dolya
from tab3 order by dolya;

explain analyze
with tab1 as (
    select goods.goodsid,
           name,
           amount as storage_amount
    from goods left join doctransfergoodsviadocdelivery
    on doctransfergoodsviadocdelivery.goodsid = goods.goodsid),
 tab2 as (
     select tab1.goodsid ,
            tab1.name ,
            tab1.storage_amount,
            sum(docdeliverygoods.docdeliverygoodsamount) as docdeliveryid_count
     from tab1 left join docdeliverygoods
         on tab1.goodsid=docdeliverygoods.goodsid
     group by tab1.goodsid, tab1.name, tab1.storage_amount),
tab3 as (
        select tab2.goodsid,
               tab2.name,
               tab2.storage_amount,
               tab2.docdeliveryid_count,
               sum(docdeliverygoodsonstorage.amount) as packing_list_count
        from tab2 left join docdeliverygoodsonstorage on tab2.goodsid=docdeliverygoodsonstorage.goodsid
        group by tab2.goodsid, tab2.name, tab2.storage_amount, tab2.docdeliveryid_count)
select tab3.goodsid,
       tab3.name,
       tab3.docdeliveryid_count,
       tab3.storage_amount,
       tab3.packing_list_count,
       cast((tab3.packing_list_count/cast(tab3.docdeliveryid_count as numeric(10,3))) as numeric(10,3)) as dolya
from tab3 order by dolya;
;
--Запрос 2
--Получить информацию об обспечении торговых предприятий.
--торговое предприятие
--кол-во документов передачи
--колв-во разных видов товаров, которые были направлены в это предприятие
--общий вес всех товаров.

with tab1 as (
    select doctransfergoods.doctransferid,
           doctransfergoods.goodsid,
           (goods.weight*doctransfergoods.amount) as weight_goodsid
    from doctransfergoods left join goods on doctransfergoods.goodsid=goods.goodsid),
     tab2 as (
         select distinct tab1.doctransferid,
                         tab1.goodsid,
                         doctransfer.commercialenterpriseid,
                         weight_goodsid
                from  tab1 left join doctransfer on tab1.doctransferid=doctransfer.doctransferid)
select tab2.commercialenterpriseid,
       commercialenterprise.name,
       count(tab2.doctransferid) as doctransferid_count,
       sum(tab2.weight_goodsid)  as  weight_goodsid
from tab2 join commercialenterprise on tab2.commercialenterpriseid=commercialenterprise.commercialenterpriseid
group by tab2.commercialenterpriseid, commercialenterprise.name;



--Запрос 3
--Получить информацию о загруженности складов.
--Номер скалда
--категория товара,хранящаяся на этом складе
--суммарное кол-во товара, переданное на этот склад(поступивший товар)
--суммарное кол-во товара отапрвленный товара
--суммарное кол-во товара на складе.


with tab1 as
    (select storageid,
            goodsgrp.grpname
    from storage join goodsgrp on storage.grpid=goodsgrp.grpid),
    tab2 as
        (select tab1.storageid,
                tab1.grpname,
                sum(docdeliverygoodsonstorage.amount) as PackingListAmount
        from tab1 left join docdeliverygoodsonstorage on docdeliverygoodsonstorage.storageid=tab1.storageid
        group by tab1.storageid,tab1.grpname),
     tab3 as
         ( select tab1.storageid,
                  tab1.grpname,
                  sum(doctransfergoodsviadocdelivery.amount) as Storage_Amount
         from tab1 left join doctransfergoodsviadocdelivery on tab1.storageid=doctransfergoodsviadocdelivery.storageid
        group by tab1.storageid,tab1.grpname),
    tab4 as
        (select tab1.storageid,
                tab1.grpname,
                sum(doctransfergoods.amount) as DoxTransferGoodsAmount
        from tab1 left join lab_var12.public.doctransfergoods on tab1.storageid=doctransfergoods.storageid
        group by tab1.storageid,tab1.grpname)
select distinct tab2.storageid,
                tab2.grpname,
                PackingListAmount,
                Storage_Amount,
                DoxTransferGoodsAmount
from tab2 join tab3 on tab2.storageid=tab3.storageid
join tab4 on tab2.storageid=tab4.storageid;


--Запрос 4
--Получить информацию о наиболее активных(ого) сотрудниках(а) фирмы.
--ФИО сотрудника
--табельный номер
--общее кол-во всех оформленных документов - макисмальное среди всех.

with tab1 as (
    select employeeid,
           fio,
           category
    from lab_var12.public.employee),
tab2 as (
    select distinct tab1.employeeid,
                    tab1.fio,
                    tab1.category,
                    packinglist.packinglistid,
                    doctransfer.doctransferid,
                    docdelivery.docdeliveryid
    from tab1 left join packinglist on tab1.employeeid=packinglist.employeeid
    left join doctransfer on tab1.employeeid=doctransfer.employeeid
    left join docdelivery on tab1.employeeid=docdelivery.employeeid),
     tab3 as (
         select employeeid,
                fio,
                category,
                count(packinglistid)+count(doctransferid)+count(docdeliveryid) as count_doc
        from tab2 group by employeeid, fio, category)
select employeeid,
       fio,
       category,
       count_doc from tab3
where count_doc= (select count_doc from tab3 order by count_doc desc limit 1);

--селект максиммум от коунт док (план выполнения)



--Запрос 5
--Получить информацию о самом востребованном товаре. Он встречается в максимальном кол0ве договором о поставках.
--Данные о товаре
--кол-во договоров о поставке
--кол-во разных постващиков
--суммарный объем заказанного товара.



with tab1 as (
    select docdeliverygoods.goodsid,
           docdeliverygoods.docdeliveryid,
            docdelivery.providerid
    from docdeliverygoods left join docdelivery on docdeliverygoods.docdeliveryid = docdelivery.docdeliveryid),
     tab2 as (
    select distinct goodsid,
                    providerid
    from tab1),
     tab3 as (
            select goodsid,
                   count(providerid) as providercount

            from tab2
            group by goodsid),
    tab4 as (
      select goodsid,
             count(docdeliveryid) as docdelivercount,
             sum(docdeliverygoods.docdeliverygoodsamount) as docdeliverygoodsamount
      from docdeliverygoods
      group by goodsid)
select tab4.goodsid,goods.name,
        goods.grpid,goods.firma,
        goods.dimensions,
        goods.pack,
        tab4.docdelivercount,
        tab3.providercount,
       goods.weight* tab4.docdeliverygoodsamount as weight_all

from tab4 join goods on tab4.goodsid=goods.goodsid
left join tab3 on tab4.goodsid=tab3.goodsid
where docdelivercount= (select docdelivercount from tab4 order by docdelivercount desc limit 1);

--получить разные значение через груп бай (план выполнения)

--построить один план выполнения запросов для двух запросов чтобы посомтреть долю выполнения запроса

--вопросы актуальны
--вопрос из каждой части (3 вопроса)
--дистанционная консультация
--очный экзамен