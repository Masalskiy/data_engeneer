Запуск 
	docker compose up -d
Остановка
	docker compose down
Подключиться к командной строке 
	docker exec -it  1_3_homework-db-1  psql -U denis -d database
или 
	docker exec -it 1_3_homework-db-1 bash
	psql -U denis -d database
