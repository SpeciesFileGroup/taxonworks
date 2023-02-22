FROM sfgrp/taxonworks

COPY init.rb /app/exe
COPY should_not_run_job.rb /app/app/jobs

RUN { echo "bundle exec rails r /app/exe/init.rb"; } >> /etc/my_init.d/init.sh

RUN echo "===[Built from revision `cat /app/REVISION`"]===