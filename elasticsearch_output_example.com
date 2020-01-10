input {
  stdin {
    
  }
}
filter {
  kv {
    source => "message"
  }
}
output {
  elasticsearch {
    index => "logstash-test-%{+YYYY.MM.dd}"
    hosts => ["http://localhost:9200"]
    #user => "${LOGSTASH_USER}"
    #password => "${LOGSTASH_PASSWORD}"
    #ssl_certificate_verification => "${SSL_CERTIFICATE_VERIFICATION}"
    #keystore => "${KEYSTORE}"
    #keystore_password => "${KEYSTORE_PASSWORD}"
    #truststore => "${KEYSTORE}"
    #truststore_password => "${KEYSTORE_PASSWORD}"
    #ilm_enabled => "false"
  }
}
