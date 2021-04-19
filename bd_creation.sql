-- auto-generated definition
drop table if exists Provider cascade;
create table Provider --E1
(
    ProviderID INT NOT NULL PRIMARY KEY,
    ProviderName varchar(50) not null unique,
    Address varchar(100) not null,
    NumberPhone varchar(13) null CHECK (NumberPhone similar to '+7[0-9]{10}'),
    License INT not null unique,
    FIO varchar(50) not null

);

drop table if exists GoodsGrp cascade;
create table GoodsGrp --E3
(
        GrpId SERIAL NOT NULL PRIMARY KEY,
		GrpName VARCHAR(50) NOT NULL UNIQUE,
		Properties VARCHAR(200) NULL

);

drop table if exists Goods cascade;
CREATE TABLE Goods
( --E2
		GoodsId INT NOT NULL PRIMARY KEY,
		GrpId INT NOT NULL,
		Name VARCHAR(50) NOT NULL,
		Firma varchar(100) NOT NULL,
		Weight DECIMAL(10,2) not null,
		Dimensions varchar(50) not null,
        Pack varchar(50) not null,
		FOREIGN KEY(GrpId) REFERENCES GoodsGrp ON DELETE NO ACTION
);

drop table if exists Employee cascade;

CREATE TABLE Employee
( --E8
    EmployeeID SERIAL not null PRIMARY KEY,
    PassportID INT not null,
    PassportSeries INT not null,
    FIO varchar(50) not null,
    Address varchar(100)  null,
    NumberPhone varchar(11)  null CHECK(NumberPhone SIMILAR TO '+7[0-9]{10}'),
    Date DATE NOT NULL,
    Category varchar(20) not null,
    UNIQUE (PassportSeries,PassportID)
);

drop table if exists Storage cascade;

CREATE TABLE  Storage
( --E9
    StorageID serial not null PRIMARY KEY,
    GrpId INT NOT NULL references GoodsGrp
);

drop table if exists DocDelivery cascade;

CREATE TABLE DocDelivery
( --E4
    DocDeliveryID INT not null PRIMARY KEY,
     EmployeeID INT not null references Employee,
     ProviderID INT NOT NULL references Provider,
     Date DATE NOT NULL,
     FirstDate DATE NOT NULL,
     DocDeliveryCheck CHAR(11) CHECK (DocDeliveryCheck IN ('completed', 'uncompleted')), --completed/uncopleted
     TermsContract DATE not null
);

drop table if exists CommercialEnterprise cascade;

CREATE TABLE CommercialEnterprise
( --E6
    CommercialEnterpriseID serial not null PRIMARY KEY,
    EmployeeID INT not null references Employee,
    Name varchar(50) not null,
    Specialization varchar(30) not null,
    NameAddress varchar(50) not null,
    NumberPhone varchar(12)  null CHECK (NumberPhone similar to '+7[0-9]{10}'),
    FIO varchar(50) not null

);

drop table if exists PackingList cascade;

CREATE TABLE PackingList
( --E5
    PackingListID INT not null PRIMARY KEY,
    CommercialEnterpriseID  INT NOT NULL references CommercialEnterprise,
    EmployeeID INT not null references Employee,
    Date DATE not null,
    TermsContract DATE not null, --сроки
    ProviderID INT NOT NULL references Provider,
    DocDeliveryID INT not null references DocDelivery

);

drop table if exists DocTransfer cascade;

CREATE TABLE DocTransfer
( --E7
    DocTransferID serial not null PRIMARY KEY,
    EmployeeID INT not null references Employee,
    CommercialEnterpriseID  INT NOT NULL references CommercialEnterprise,
    Date DATE not null,
    Time time not null

);

drop table if exists DocDeliveryGoods cascade;

CREATE TABLE DocDeliveryGoods
( --E10
    GoodsId INT NOT NULL references Goods,
    DocDeliveryID INT not null references DocDelivery,
    DocDeliveryGoodsAmount INT not null,
    DocDeliveryGoodsCost DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (GoodsId,DocDeliveryID)
);

drop table if exists DocDeliveryGoodsOnStorage cascade;

CREATE TABLE DocDeliveryGoodsOnStorage
( --E12
    GoodsId INT NOT NULL,
    DocDeliveryID INT not null,
    PackingListID INT not null references PackingList,
    StorageID INT not null references Storage,
    Amount INT not null,
    FOREIGN KEY (GoodsId,DocDeliveryID) references DocDeliveryGoods,
    PRIMARY KEY (GoodsId,DocDeliveryID,PackingListID)

);

drop table if exists DocTransferGoods cascade;



drop table if exists DocTransferGoodsViaDocDelivery cascade;

CREATE TABLE DocTransferGoodsViaDocDelivery
( --E13
     GoodsId INT NOT NULL references Goods,
     StorageID INT not null references Storage,
     Amount int not null,
     PRIMARY KEY (GoodsId,StorageID)
);

CREATE TABLE DocTransferGoods
( --E11
    DocTransferID INT not null references DocTransfer,
    NumberString serial not null,
    Amount INT not null,
    Cost DECIMAL(10, 2) NOT NULL,
    StorageID INT not null,
    GoodsId INT NOT NULL,
    FOREIGN KEY (StorageID,GoodsId) references DocTransferGoodsViaDocDelivery,
    PRIMARY KEY (DocTransferID,NumberString)
);






