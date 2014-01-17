#!/bin/sh

createlang -U postgres plpgsql taxonworks_development
psql -U postgres -d taxonworks_development -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
psql -U postgres -d taxonworks_development -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
