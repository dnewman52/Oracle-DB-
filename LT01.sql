create or replace PROCEDURE ADD_CUST_TO_DB (pcustid NUMBER, pcustname VARCHAR2)AS
vcount number;
BEGIN
    IF(pcustid > 499 OR pcustid < 1) THEN        
        RAISE_APPLICATION_ERROR (-20024,'Error: Customer ID out of range');    
    ELSE
        SELECT COUNT(*) INTO vcount FROM CUSTOMER
        WHERE custid = pcustid;
        IF (vcount > 0) THEN
          RAISE_APPLICATION_ERROR (-20012,'Error: Duplicate Customer ID');        
        END IF;
    END IF;
    
    
    INSERT INTO customer VALUES(pcustid, pcustname, 0, 'OK');
    

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);

END ADD_CUST_TO_DB;
/
create or replace PROCEDURE ADD_CUSTOMER_VIASQLDEV (pcustid NUMBER, pcustname VARCHAR2)AS
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Customer. ID:' || pcustid || ' Name: ' || pcustname);
add_cust_to_db(pcustid,pcustname);
DBMS_OUTPUT.PUT_LINE('Added OK');
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;
/
create or replace PROCEDURE ADD_LOCATION_TO_DB(ploccode VARCHAR2, pminqty NUMBER, pmaxqty NUMBER) AS 
verrm VARCHAR2(1000);
CHECK_CONSTRAINT_VIOLATION EXCEPTION;
CHECK_LOCID_VIOLATION EXCEPTION;
PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
PRAGMA EXCEPTION_INIT(CHECK_LOCID_VIOLATION, -12899); 
BEGIN

INSERT INTO LOCATION VALUES (ploccode, pminqty, pmaxqty);

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
RAISE_APPLICATION_ERROR (-20182, 'Duplicate Location ID');

WHEN CHECK_LOCID_VIOLATION THEN
       RAISE_APPLICATION_ERROR (-20194, 'Location Code Length Invalid');

WHEN CHECK_CONSTRAINT_VIOLATION THEN
    verrm := SQLERRM;
    IF  INSTR(verrm,'CHECK_MINQTY_RANGE') > 0 THEN
        RAISE_APPLICATION_ERROR (-20206, 'Minimum QTY out of range');
    ELSIF INSTR(verrm, 'CHECK_MAXQTY_RANGE') >0 THEN
        RAISE_APPLICATION_ERROR (-20218, 'Maximum QTY out of range');
    ELSIF INSTR(verrm, 'CHECK_MAXQTY_GREATER_MIXQTY') >0 THEN
        RAISE_APPLICATION_ERROR (-20229, 'Minimum QTY larger than Maximum QTY');     
END IF;

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);      
END ADD_LOCATION_TO_DB;
/
create or replace PROCEDURE ADD_LOCATION_VIASQLDEV(ploccode VARCHAR2, pminqty NUMBER, pmaxqty NUMBER) AS 
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Location. LocID:' || ploccode || ' MinQTY: ' || pminqty || ' MaxQTY: ' || pmaxqty);
ADD_LOCATION_TO_DB(ploccode, pminqty, pmaxqty);
DBMS_OUTPUT.PUT_LINE('Location Added OK');
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END ADD_LOCATION_VIASQLDEV;
/
create or replace PROCEDURE ADD_PRODUCT_TO_DB(pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER) AS
duplicate_key EXCEPTION;
pprodid_out_of_range EXCEPTION;
pprice_out_of_range EXCEPTION;
vcount NUMBER;
Begin
IF(pprodid > 2500 OR pprodid < 1000) THEN
    RAISE_APPLICATION_ERROR (-20044,'Error: Product ID out of range');    
        
ELSE IF(pprice > 999.99 OR pprice < 0) THEN
    RAISE_APPLICATION_ERROR (-20056,'Error: Price out of range');    
    
ELSE
    SELECT COUNT(*) INTO vcount FROM PRODUCT
        WHERE prodid = pprodid;
        IF (vcount > 0) THEN
            RAISE_APPLICATION_ERROR (-20032,'Error: Duplicate Product ID');    
        END IF;
    END IF;
END IF;

INSERT INTO product VALUES (pprodid, pprodname, pprice, 0);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
        
End;
/
create or replace PROCEDURE ADD_PRODUCT_VIASQLDEV (pprodid NUMBER, pprodname VARCHAR2, pprice NUMBER)AS
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Product. ID:' || pprodid || ' Name: ' || pprodname || ' Price: ' || pprice);
add_product_to_db(pprodid,pprodname,pprice);
DBMS_OUTPUT.PUT_LINE('Product Added OK');
COMMIT WORK;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;
/
create or replace PROCEDURE ADD_SIMPLE_SALE_TO_DB(pcustid NUMBER, pprodid NUMBER, pqty NUMBER) AS 
vcount NUMBER;
vstatus VARCHAR2(100);
vtotal NUMBER;
BEGIN

SELECT COUNT(*) into vcount from customer where custid = pcustid;
IF (vcount = 0) THEN
    RAISE_APPLICATION_ERROR (-20166,'Error: Customer ID not found');
end if;    

SELECT COUNT(*) INTO vcount from product where prodid = pprodid;
IF (vcount = 0) THEN
    RAISE_APPLICATION_ERROR (-20178,'Error: Product ID not found');    
end if;

SELECT status into vstatus from customer where custid = pcustid;
if vstatus != 'OK' THEN
    RAISE_APPLICATION_ERROR (-20154,'Error: Customer status is not OK');
end if;

if(pqty < 1 or pqty > 999) THEN
    RAISE_APPLICATION_ERROR (-20142,'Error: Sale Quantity outside valid range');
end if;

SELECT selling_price into vtotal FROM product where prodid = pprodid;
vtotal := vtotal * pqty;

UPD_CUST_SALESYTD_IN_DB(pcustid, vtotal);
UPD_PROD_SALESYTD_IN_DB(pprodid, vtotal);


EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END ADD_SIMPLE_SALE_TO_DB;
/
create or replace PROCEDURE ADD_SIMPLE_SALE_VIASQLDEV (pcustid NUMBER, pprodid NUMBER, pqty NUMBER)AS
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------');
DBMS_OUTPUT.PUT_LINE('Adding Simple Sale. CustID:' || pcustid || ' ProdId: ' || pprodid || ' QTY: ' || pqty);
ADD_SIMPLE_SALE_TO_DB(pcustid,pprodid,pqty);
DBMS_OUTPUT.PUT_LINE('Added Simple Sale OK');
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;
/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."DELETE_ALL_CUSTOMERS_VIASQLDEV" AS
vcount NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Customer rows');
vcount := delete_all_customers_from_db();
DBMS_OUTPUT.PUT_LINE(vcount || ' rows deleted');
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."DELETE_ALL_PRODUCTS_VIASQLDEV" AS
vcount NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------------');
DBMS_OUTPUT.PUT_LINE('Deleting all Product rows');
vcount := delete_all_products_from_db();
DBMS_OUTPUT.PUT_LINE(vcount || ' rows deleted');
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."GET_ALLCUST_VIASQLDEV" AS 
vrefcur SYS_REFCURSOR;
vcustrow customer%rowtype;

BEGIN
DBMS_OUTPUT.PUT_LINE('------------------------------------');
DBMS_OUTPUT.PUT_LINE('Listing all Customer Details');
vrefcur := GET_ALLCUST();
IF (vrefcur%NOTFOUND) THEN
    DBMS_OUTPUT.PUT_LINE('No Rows Found');
ELSE
  LOOP FETCH vrefcur into vcustrow;
    EXIT WHEN vrefcur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Custid: '|| vcustrow.custid ||' Name: '|| vcustrow.custname || ' Status: '|| vcustrow.status ||' SalesYTD: '|| vcustrow.sales_ytd);    
END LOOP;
CLOSE vrefcur;
END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || SQLERRM);
END GET_ALLCUST_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."GET_ALLPROD_VIASQLDEV" AS 
vrefcur SYS_REFCURSOR;
vprodrow product%rowtype;

BEGIN
DBMS_OUTPUT.PUT_LINE('------------------------------------');
DBMS_OUTPUT.PUT_LINE('Listing all Product Details');
vrefcur := GET_ALLPROD_FROM_DB();
IF (vrefcur%NOTFOUND) THEN
    DBMS_OUTPUT.PUT_LINE('No Rows Found');
ELSE
  LOOP FETCH vrefcur into vprodrow;
    EXIT WHEN vrefcur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Prodid: '|| vprodrow.prodid ||' Name: '|| vprodrow.prodname || ' Price: '|| vprodrow.selling_price ||' SalesYTD: '|| vprodrow.sales_ytd);    
END LOOP;
CLOSE vrefcur;
END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || SQLERRM);
END GET_ALLPROD_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."GET_CUST_STRING_VIASQLDEV" (pcustid NUMBER) AS 
BEGIN
  dbms_output.PUT_LINE('-----------------------------------------------');
  dbms_output.PUT_LINE('Getting Details for CustID ' || pcustid);
  dbms_output.PUT_LINE(get_cust_string_from_db(pcustid));
  
  EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END GET_CUST_STRING_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."GET_PROD_STRING_VIASQLDEV" (pprodid NUMBER) AS 
BEGIN
  dbms_output.PUT_LINE('-----------------------------------------------');
  dbms_output.PUT_LINE('Getting Details for ProdID ' || pprodid);
  dbms_output.PUT_LINE(get_prod_string_from_db(pprodid));
  
  EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."SUM_CUST_SALES_VIASQLDEV" AS
vresult NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------------');
DBMS_OUTPUT.PUT_LINE('Summing Customer SalesYTD');
vresult := SUM_CUST_SALESYTD();
DBMS_OUTPUT.PUT_LINE('All Customer Total: ' || vresult);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('All Customer Total: 0' );
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM || ': ' || SQLCODE);
END SUM_CUST_SALES_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."SUM_PROD_SALES_VIASQLDEV" AS
vresult NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('---------------------------------------');
DBMS_OUTPUT.PUT_LINE('Summing Product SalesYTD');
vresult := SUM_PROD_SALESYTD();
DBMS_OUTPUT.PUT_LINE('All Product Total: ' || vresult);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('All Product Total: 0' );
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM || ': ' || SQLCODE);
END SUM_PROD_SALES_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_CUST_SALESYTD_IN_DB" (pcustid NUMBER, pamt NUMBER) AS 
vresult NUMBER;
BEGIN

    SELECT COUNT(*) INTO vresult FROM customer 
    WHERE custid = pcustid;

    IF(vresult = null) THEN
        RAISE_APPLICATION_ERROR (-20062,'Error: Customer ID not found');
    ELSIF (pamt < -999.99 OR pamt > 999.99) THEN
        RAISE_APPLICATION_ERROR (-20084,'Error: Amount out of range');
    ELSE
        UPDATE customer 
        SET sales_ytd = pamt
        WHERE custid = pcustid;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_CUST_SALESYTD_IN_DB;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_CUST_SALESYTD_VIASQLDEV" (pcustid NUMBER, pamt NUMBER) AS 
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------------');
DBMS_OUTPUT.PUT_LINE('Updating SalesYTD. Customer Id: ' || pcustid || ' Amount: ' || pamt);
UPD_CUST_SALESYTD_IN_DB(pcustid,pamt);
DBMS_OUTPUT.PUT_LINE('Update OK');
COMMIT WORK;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_CUST_SALESYTD_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_CUST_STATUS_IN_DB" (pcustid NUMBER, pstatus VARCHAR2) AS 
vresult NUMBER;
BEGIN

    SELECT COUNT(*) INTO vresult FROM customer 
    WHERE custid = pcustid;

    IF(vresult = null) THEN
        RAISE_APPLICATION_ERROR (-20122,'Error: Customer ID not found');
    ELSIF (pstatus = 'OK') OR (pstatus = 'SUSPEND') THEN
        UPDATE customer 
        SET status = pstatus
        WHERE custid = pcustid;        
    ELSE
        RAISE_APPLICATION_ERROR (-20134,'Error: Invalid Status value');    
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_CUST_STATUS_IN_DB;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_CUST_STATUS_VIASQLDEV" (pcustid NUMBER, pstatus VARCHAR2) AS 
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------------');
DBMS_OUTPUT.PUT_LINE('Updating Status. Customer Id: ' || pcustid || ' Status: ' || pstatus);
UPD_CUST_STATUS_IN_DB(pcustid,pstatus);
DBMS_OUTPUT.PUT_LINE('Update OK');
COMMIT WORK;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_CUST_STATUS_VIASQLDEV;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_PROD_SALESYTD_IN_DB" (pprodid NUMBER, pamt NUMBER) AS 
vresult NUMBER;
BEGIN

    SELECT COUNT(*) INTO vresult FROM product 
    WHERE prodid = pprodid;

    IF(vresult = null) THEN
        RAISE_APPLICATION_ERROR (-20102,'Error: Product ID not found');
    ELSIF (pamt < -999.99 OR pamt > 999.99) THEN
        RAISE_APPLICATION_ERROR (-20114,'Error: Amount out of range');
    ELSE
        UPDATE product 
        SET sales_ytd = pamt
        WHERE prodid = pprodid;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_PROD_SALESYTD_IN_DB;

/

set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "S6449921"."UPD_PROD_SALESYTD_VIASQLDEV" (pprodid NUMBER, pamt NUMBER) AS 
BEGIN
DBMS_OUTPUT.PUT_LINE('--------------------------');
DBMS_OUTPUT.PUT_LINE('Updating SalesYTD. Product Id: ' || pprodid || ' Amount: ' || pamt);
UPD_PROD_SALESYTD_IN_DB(pprodid,pamt);
DBMS_OUTPUT.PUT_LINE('Update OK');
COMMIT WORK;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END UPD_PROD_SALESYTD_VIASQLDEV;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."DELETE_ALL_CUSTOMERS_FROM_DB" RETURN NUMBER IS
vcount NUMBER;
BEGIN
SELECT COUNT(*) INTO vcount FROM customer; 
DELETE FROM customer;
RETURN vcount;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."DELETE_ALL_PRODUCTS_FROM_DB" RETURN NUMBER IS
vcount NUMBER;
BEGIN
SELECT COUNT(*) INTO vcount FROM product; 
DELETE FROM product;
RETURN vcount;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."GET_ALLCUST" RETURN SYS_REFCURSOR AS 
rv_refcur SYS_REFCURSOR;
BEGIN
OPEN rv_refcur FOR SELECT * FROM CUSTOMER;
RETURN rv_refcur;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END GET_ALLCUST;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."GET_ALLPROD_FROM_DB" RETURN SYS_REFCURSOR AS 
rv_refcur SYS_REFCURSOR;
BEGIN
OPEN rv_refcur FOR SELECT * FROM PRODUCT;
RETURN rv_refcur;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END GET_ALLPROD_FROM_DB;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."GET_CUST_STRING_FROM_DB" (pcustid NUMBER) RETURN VARCHAR2 IS
vresult VARCHAR2(1000);

vcustid NUMBER;
vcustname VARCHAR2(1000);
vsales NUMBER;
vstatus VARCHAR2(1000);

BEGIN
SELECT custid, custname, status, sales_ytd INTO vcustid, vcustname, vstatus, vsales FROM customer
WHERE pcustid = custid; 

IF(vcustid = null) THEN
    RAISE_APPLICATION_ERROR (-20062,'Error: Customer ID not found');
ELSE 
    vresult := 'Custid: '|| vcustid ||' Name: '|| vcustname || ' Status: '|| vstatus ||' SalesYTD: '|| vsales;
    RETURN vresult;
END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END;

/

  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."GET_PROD_STRING_FROM_DB" (pprodid NUMBER) RETURN VARCHAR2 AS 
vresult VARCHAR2(1000);

vprodid NUMBER;
vprodname VARCHAR2(1000);
vsales NUMBER;
vprice NUMBER;

BEGIN
SELECT prodid, prodname, selling_price, sales_ytd INTO vprodid, vprodname, vprice, vsales FROM product
WHERE prodid = pprodid; 

IF(vprodid = null) THEN
    RAISE_APPLICATION_ERROR (-20092,'Error: Product ID not found');
ELSE 
    vresult := 'Prodid: '|| vprodid ||' Name: '|| vprodname || ' Price: '|| vprice ||' SalesYTD: '|| vsales;
    RETURN vresult;
END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR (-20000,SQLERRM);
END GET_PROD_STRING_FROM_DB;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."SUM_CUST_SALESYTD" RETURN NUMBER AS
rv_refcur SYS_REFCURSOR;
vcust_sales customer.sales_ytd%TYPE;
vtotal NUMBER := 0;
BEGIN
OPEN rv_refcur FOR SELECT SALES_YTD FROM CUSTOMER;
  LOOP FETCH rv_refcur into vcust_sales;
    EXIT WHEN rv_refcur%NOTFOUND;
    vtotal := vtotal + vcust_sales;
    END LOOP;
CLOSE rv_refcur;
RETURN vtotal;
END SUM_CUST_SALESYTD;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."SUM_PROD_SALESYTD" RETURN NUMBER AS
rv_refcur SYS_REFCURSOR;
vprod_sales product.sales_ytd%TYPE;
vtotal NUMBER := 0;
BEGIN
OPEN rv_refcur FOR SELECT SALES_YTD FROM product;
  LOOP FETCH rv_refcur into vprod_sales;
    EXIT WHEN rv_refcur%NOTFOUND;
    vtotal := vtotal + vprod_sales;
    END LOOP;
CLOSE rv_refcur;
RETURN vtotal;
END SUM_PROD_SALESYTD;

/


  CREATE OR REPLACE EDITIONABLE FUNCTION "S6449921"."SUM_PROD_SALESYTD_FROM_DB" RETURN NUMBER AS
rv_refcur SYS_REFCURSOR;
vprod_sales product.sales_ytd%TYPE;
vtotal NUMBER := 0;
BEGIN
OPEN rv_refcur FOR SELECT SALES_YTD FROM product;
  LOOP FETCH rv_refcur into vprod_sales;
    EXIT WHEN rv_refcur%NOTFOUND;
    vtotal := vtotal + vprod_sales;
    END LOOP;
CLOSE rv_refcur;
RETURN vtotal;
END SUM_PROD_SALESYTD_FROM_DB;

/
