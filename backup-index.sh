elasticdump --input='http://localhost:9200/bro-*' --output=$ | gzip > backup_bro.json.gz
elasticdump --input='http://localhost:9200/clamd-*' --output=$ | gzip > backup_clamd.json.gz
elasticdump --input='http://localhost:9200/suricata-*' --output=$ | gzip > backup_suricata.json.gz
elasticdump --input='http://localhost:9200/twitter-*' --output=$ | gzip > backup_twitter.json.gz
elasticdump --input='http://localhost:9200/paste-*' --output=$ | gzip > backup_paste.json.gz
