CREATE MATERIALIZED view IF NOT exists reader_list_books as
	select r.lclastn, r.lcfirstn, r2.bname, r2.pkisbn, j.datereturnexpect from rlibcard r 
	left join jlibticket j on r.pkcard = j.fktcard 
	left join instancebook i on j.fktbarcode = i.pkibarcode 
	left join rbook r2 on i.iisbn = r2.pkisbn
WHERE j.datereturnfact is null and r2.bname is not null

--DROP MATERIALIZED view reader_list_books
--обновить представление
--REFRESH MATERIALIZED VIEW reader_list_books


