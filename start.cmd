docker pull rabbitmq
docker build -t test_rabbit .
docker run -d --hostname my_rabbit --name test_rabbit -p 15672:15672 -p 61613:61613 test_rabbit