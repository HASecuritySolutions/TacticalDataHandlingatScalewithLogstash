#!/bin/bash

#### CA Generation ####
# This generates the CA key, certificate, and serial file
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -config ca.conf
openssl x509 -in ca.crt -text -noout -serial | grep serial= | cut -d"=" -f2 > serial

#### AGENT ####
# This generates certificate files for log agent(s)
openssl genrsa -out agent.key 2048
openssl req -sha512 -new -key agent.key -out agent.csr -config agent.conf
openssl x509 -days 3650 -req -sha512 -in agent.csr -CAserial serial -CA ca.crt -CAkey ca.key -out agent.crt -extensions v3_req -extfile agent.conf

#### LOGSTASH ####
# This generates certificate files for Logstash
openssl genrsa -out logstash.key 2048
openssl req -sha512 -new -key logstash.key -out logstash.csr -config logstash.conf
openssl x509 -days 3650 -req -sha512 -in logstash.csr -CAserial serial -CA ca.crt -CAkey ca.key -out logstash.crt -extensions v3_req -extfile logstash.conf

# This section converst the Logstash certificate files into pcks8 and java keystore files so the Logstash can use them
cp logstash.key logstash.key.orig
mv logstash.key logstash.pem
openssl pkcs8 -in logstash.pem -topk8 -nocrypt -out logstash.key
# Generate P12 version of certificate for conversion into java keystore
openssl pkcs12 -export -in logstash.crt -inkey logstash.key -certfile ca.crt -out logstash.p12 -passout pass:sec455
# Generate java keystore version of certificate
keytool -importkeystore -srckeystore logstash.p12 -srcstoretype pkcs12 -srcstorepass sec455 -destkeystore logstash.jks -deststoretype JKS -storepass sec455
keytool -import -keystore logstash.jks -storepass sec455 -file ca.crt --noprompt

#### ELASTICSEARCH - BONUS ####
# This generates certificate files for an Elasticsearch node
openssl genrsa -out elasticsearch.key 2048
openssl req -sha512 -new -key elasticsearch.key -out elasticsearch.csr -config elasticsearch.conf
openssl x509 -days 3650 -req -sha512 -in elasticsearch.csr -CAserial serial -CA ca.crt -CAkey ca.key -out elasticsearch.crt -extensions v3_req -extfile elasticsearch.conf
# This converts the Elasticsearch key and crt to formats Elasticsearch needs
# Generate P12 version of certificate with a password of sec455
openssl pkcs12 -export -in elasticsearch.crt -inkey elasticsearch.key -certfile elasticsearch.crt -out elasticsearch.p12 -passout pass:sec455
# Generate java keystore version of certificate
keytool -importkeystore -srckeystore elasticsearch.p12 -srcstoretype pkcs12 -srcstorepass sec455 -destkeystore elasticsearch.jks -deststoretype JKS -storepass sec455
# Import the ca.crt into the java keystore
keytool -import -keystore elasticsearch.jks -storepass sec455 -file ca.crt --noprompt

#### KIBANA - BONUS ####
# This generates certificate files for Kibana users
openssl genrsa -out kibana.key 2048
# This generates a certificate signing request (CSR)
openssl req -sha512 -new -key kibana.key -out kibana.csr -config kibana.conf
# This signs the request using the root CA and generates a public key (CRT)
openssl x509 -days 3650 -req -sha512 -in kibana.csr -CAserial serial -CA ca.crt -CAkey ca.key -out kibana.crt -extensions v3_req -extfile kibana.conf
