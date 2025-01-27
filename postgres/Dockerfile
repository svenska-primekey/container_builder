# Ansible managed
FROM quay.io/krestomatio/base-stream AS old_pg_bin

# Component bash variables
ENV POSTGRES_PREV_VERSION="10"

RUN microdnf module enable postgresql:${POSTGRES_PREV_VERSION} && \
    install-pkgs postgresql-server && \
    mkdir -p /opt/pg_bin && \
    cp -rp /usr/bin/{postgres,pg_*} /opt/pg_bin/


FROM quay.io/krestomatio/base-stream

# General variables
ENV IMAGE_NAME=postgres \
    IMAGE_SUMMARY="Postgres 13" \
    IMAGE_DESCRIPTION="This CentOS 8 Stream minimal based container image runs Postgres 13. \
It follows https://github.com/sclorg/postgresql-container" \
    IMAGE_TITLE="Postgres 13" \
    IMAGE_SERVICE_PORT="5432" \
    IMAGE_SERVICE_NAME="postgres" \
    TZ="UTC"

# Container variables
ENV CTR_USER=postgres \
    CTR_USER_ID="26" \
    CTR_HOME=/var/lib/pgsql \
    CTR_CMD="run-postgresql" \
    CTR_SCRIPTS_PATH=/usr/share/container-scripts/postgresql

# Component bash variables
ENV POSTGRES_VERSION="13" \
    POSTGRES_PREV_VERSION="10" \
    POSTGRES_PORT=${IMAGE_SERVICE_PORT} \
    POSTGRES_RUN=/var/run/postgresql \
    POSTGRES_HOME=${CTR_HOME} \
    POSTGRES_DATA="${CTR_HOME}/data"

# Frequent environment variables
ENV HOME="${CTR_HOME}" \
    PGUSER="$CTR_USER" \
    LANG="en_US.UTF-8"

ENV OS_INSTALL_PKGS="postgresql-server postgresql-contrib gettext nss_wrapper"

USER 0

COPY conf/usr /usr/
COPY conf/container-entrypoint.d ${CTR_ENTRYPOINT_OPT_PATH}/

COPY --from=old_pg_bin /opt/pg_bin/ ${HOME}/old_pg_bin_${POSTGRES_PREV_VERSION}

RUN container-setup && container-setup-postgres

WORKDIR ${CTR_HOME}

USER ${CTR_USER_ID}

EXPOSE ${POSTGRES_PORT}

CMD ${CTR_CMD}

# Labels
LABEL name="${IMAGE_NAME}" \
      summary="${IMAGE_SUMMARY}" \
      description="${IMAGE_DESCRIPTION}" \
      maintainer="Job Céspedes Ortiz <jobcespedes@krestomatio.com>" \
      org.opencontainers.image.title="${IMAGE_TITLE}" \
      org.opencontainers.image.authors="Job Céspedes Ortiz <jobcespedes@krestomatio.com>" \
      org.opencontainers.image.description="${IMAGE_DESCRIPTION}" \
      org.opencontainers.image.version="0.1" \
      io.k8s.description="${IMAGE_DESCRIPTION}" \
      io.k8s.display-name="${IMAGE_TITLE}" \
      io.openshift.expose-services="${IMAGE_SERVICE_PORT}:${IMAGE_SERVICE_NAME}" \
      io.openshift.tags="${IMAGE_NAME},postgres,postgres-${POSTGRES_VERSION},postgres${POSTGRES_VERSION}"
