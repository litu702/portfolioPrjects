
--Cleaning data in SQL Queries
------------------------------------------------
select * from housedata
--select * from housedata where OWNERADDRESS is null

--------------------------------------------------------------------
--standardise the date format
----------------------------------------------------------
select saledate from housedata 
--select TO_CHAR(TO_DATE(saledate,'MM/DD/YYYY'), 'DD-MON-YYYY') from housedata
select TO_DATE(saledate,'MM/DD/YYYY')from housedata

alter table housedata
add saledateconverted Date

update housedata
set saledateconverted = TO_DATE(saledate,'MM/DD/YYYY')

---------------------------------------------------
--populate property address data
----------------------------------------------
select propertyaddress from housedata
select * from housedata 
where propertyaddress is null 
order by parcelID

/*select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,NVL(a.propertyaddress,b.propertyaddress)
from housedata a join housedata b
on a.parcelid=b.parcelid
and a.ID!=b.ID
where a.propertyaddress is null


create or replace view propertyaddress_vw
as
select a.parcelid,NVL(a.propertyaddress,b.propertyaddress) "Address"
from housedata a join housedata b
on a.parcelid=b.parcelid
and a.ID!=b.ID
where a.propertyaddress is null

select * from propertyaddress_vw

--drop view property
--commit



MERGE
INTO    housedata a
USING   housedata b
ON      (
        a.parcelid = b.parcelid
        AND a.id != b.id
       --and a.propertyaddress is null
        )
WHEN MATCHED THEN
UPDATE
SET propertyaddress = NVL(a.propertyaddress,b.propertyaddress)
where  propertyaddress is null

MERGE 
INTO housedata a
      USING 
      (select distinct b.parcelid,b.propertyaddress,NVL(a.propertyaddress,b.propertyaddress)
      from housedata a,housedata b
              WHERE a.propertyaddress is null
               and a.id != b.id) src
              ON (a.parcelid = src.parcelid)
  WHEN MATCHED THEN 
  UPDATE 
  SET propertyaddress = NVL(a.propertyaddress,src.propertyaddress)




select distinct b.parcelid,b.propertyaddress,NVL(a.propertyaddress,b.propertyaddress) address
      from housedata a,housedata b
              WHERE a.propertyaddress is null
               and a.id != b.id  
               */
               
               
               
MERGE 
INTO housedata a
      USING 
      (select b.parcelid
             , max(b.propertyaddress) as propertyaddress
      from housedata b
      where b.propertyaddress is not null
      group by b.parcelid
               ) src
   ON (a.parcelid = src.parcelid)
  WHEN MATCHED THEN 
  UPDATE 
  SET a.propertyaddress = src.propertyaddress
  WHERE a.propertyaddress is null

commit

------------------------------------------

--Breaking the Property Address Data (Address, city,state)
---------------------------------------------

select propertyaddress from housedata

select propertyaddress,substr(propertyaddress,1,(INSTR(propertyaddress,',')-1)) as Address from housedata

select propertyaddress,substr(propertyaddress,(INSTR(propertyaddress,',')+2)) as City from housedata

select substr(propertyaddress,1,(INSTR(propertyaddress,',')-1)) as Address,
substr(propertyaddress,(INSTR(propertyaddress,',')+2)) as City
from housedata

alter table housedata
add PropertySplitAddress VARCHAR2(100)

update housedata
set PropertySplitAddress = substr(propertyaddress,1,(INSTR(propertyaddress,',')-1))

alter table housedata
add PropertySplitCity VARCHAR2(100)

update housedata
set PropertySplitCity = substr(propertyaddress,(INSTR(propertyaddress,',')+2))

commit

select * from housedata
-------------------------------------------------

--Breaking the owner Address Data (Address, city,state)
-----------------------------
select owneraddress from housedata 
select owneraddress,substr(owneraddress,1,(INSTR(owneraddress,',')-1)) as Address from housedata
select owneraddress,substr(owneraddress,(INSTR(owneraddress,',')+2),(INSTR(owneraddress,',')-1)) as City from housedata
select owneraddress,substr(owneraddress,-2) as state from housedata 


select owneraddress,
regexp_substr(owneraddress, '[^,]+',1,1) as Address,
regexp_substr(owneraddress, '[^,]+',1,2) as City,
regexp_substr(owneraddress, '[^,]+',2,3) as state
from housedata


alter table housedata
add OwnerSplitAddress VARCHAR2(100)

update housedata
set OwnerSplitAddress = regexp_substr(owneraddress, '[^,]+',1,1)

alter table housedata
add OwnerSplitCity VARCHAR2(100)

update housedata
set OwnerSplitCity = regexp_substr(owneraddress, '[^,]+',1,2)

alter table housedata
add OwnerSplitState VARCHAR2(100)

update housedata
set OwnerSplitState = regexp_substr(owneraddress, '[^,]+',2,3)

commit

select * from housedata

----------------------------------------
--change y and N to Yes and No in "soldasvacant" field
------------------------------------------------------------
select distinct(soldasvacant),count(soldasvacant) 
from housedata
group by soldasvacant

select soldasvacant, 
CASE WHEN soldasvacant='Y' THEN 'Yes'
    WHEN soldasvacant='N' THEN 'No'
    ELSE soldasvacant
    END
from housedata
where soldasvacant='Y'

UPDATE housedata
set soldasvacant=(CASE WHEN soldasvacant='Y' THEN 'Yes'
    WHEN soldasvacant='N' THEN 'No'
    ELSE soldasvacant
    END)
    
commit
-------------------------------
--remove duplicates
--------------------------------
with RowNumCTE as (
    SELECT ID, parcelid,PROPERTYSPLITADDRESS,SALEDATECONVERTED,SALEPRICE,LEGALREFERENCE,
    ROW_NUMBER() OVER(PARTITION BY parcelid,PROPERTYSPLITADDRESS,SALEDATECONVERTED,SALEPRICE,LEGALREFERENCE order by id) rn
    from housedata
    )
SELECT * FROM RowNumCTE where rn>1




SELECT ID, parcelid,PROPERTYADDRESS,SALEDATE,SALEPRICE,LEGALREFERENCE,
ROW_NUMBER() OVER(PARTITION BY parcelid,PROPERTYADDRESS,SALEDATE,SALEPRICE,LEGALREFERENCE order by id) rn
from housedata


Create or replace view row_num_vw as 
SELECT ID, parcelid,PROPERTYADDRESS,SALEDATE,SALEPRICE,LEGALREFERENCE,
ROW_NUMBER() OVER(PARTITION BY parcelid,PROPERTYADDRESS,SALEDATE,SALEPRICE,LEGALREFERENCE order by id) rn
from housedata



DELETE from housedata WHERE ID IN (with RowNumCTE as 
( SELECT ID
, parcelid
,PROPERTYSPLITADDRESS
,SALEDATECONVERTED
,SALEPRICE,LEGALREFERENCE
, ROW_NUMBER() OVER(PARTITION BY parcelid,PROPERTYSPLITADDRESS,SALEDATECONVERTED,SALEPRICE,LEGALREFERENCE order by id) rn 
from housedata ) SELECT ID FROM RowNumCTE where rn>1)



--delete from row_num_vw where rn>1

----------------------------------

--Delete unused columns
--------------------------------------------
select * from housedata

Alter table housedata drop (landuse,propertyaddress,owneraddress,saledate,taxdistrict)

commit
rollback