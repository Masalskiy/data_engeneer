

--insert into public.instancebook(pkibarcode, iisbn)
--values ('102030', '10000400007000'),
--       ('102031', '10000400907000'),
--       ('105555', '60000400007000');
      
insert into public.rlibticket (pktcard, pktbarcode, dategive, datereturnexpect)
values ('1', '102030', '2023-01-15', '2023-04-15'),
	   ('1', '102031', '2023-01-15', '2023-04-15'),
	   ('2', '102031', '2023-01-15', '2023-04-15'),
	   ('2', '105555', '2023-01-15', '2023-04-15')

update rlibticket set datereturnfact = '2023-04-15' where pktcard = 1 and pktbarcode = '102030'

INSERT INTO public.libcard (lastname, firstname)
VALUES ('Иванов', 'Сидор'),
       ('Сидоров', 'Петр'),
       ('Петров', 'Иван'),
       ('Наличный', 'Артем');
      
INSERT INTO public.libcard (lastname, firstname, thirdname)
VALUES ('Масальский', 'Сидор', 'Петрович'),
       ('Киров', 'Петр', 'Иванович'),
       ('Богданец', 'Иван', 'Сидорович'), 
       ('Куликов', 'Артем', 'Андреевич');

insert INTO public.rchild(fkpassadult, fkccard, bcert, releasecrt)
values ('12345468', 5, '0078568', '2020-01-15'),
       ('12345468', 5, '0000001', '2020-01-15');
       
      
