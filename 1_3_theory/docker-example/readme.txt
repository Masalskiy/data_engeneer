суть образа создать базу данных с заполненной таблицей и 
пользователем=username
паролем=secret

создать образ
docker build -t test_image:latest .
запустить контейнер
docker run --rm -d -p 5432:5432 --name test_container test_image:latest
