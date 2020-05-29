\c konga_db
insert into konga_kong_nodes (name, type, kong_admin_url, active, "createdAt") values ('Kong','default', 'http://kong:8001', true, CURRENT_DATE);